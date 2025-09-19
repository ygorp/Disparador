import mysql from 'mysql2/promise';
import axios from 'axios';
import 'dotenv/config';

// --- CONFIGURAÇÕES ---
const DB_CONFIG = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};
const EVOLUTION_API_URL = process.env.EVOLUTION_API_URL;
const EVOLUTION_API_KEY = process.env.EVOLUTION_API_KEY; // Chave global da API
const pool = mysql.createPool(DB_CONFIG);

// --- FUNÇÕES AUXILIARES ---
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

function getRandomDelay(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min) * 1000; // Converte para milissegundos
}

// --- FUNÇÕES DE GERENCIAMENTO DE CAMPANHA ---

async function checkScheduledCampaigns(connection) {
    console.log(`[${new Date().toLocaleString('pt-BR')}] Verificando campanhas agendadas...`);
    try {
        const [campaignsToStart] = await connection.query(
            "SELECT id FROM campanhas WHERE status = 'Agendada' AND data_agendamento <= NOW()"
        );

        if (campaignsToStart.length > 0) {
            const idsToStart = campaignsToStart.map(c => c.id);
            console.log(`> Ativando ${idsToStart.length} campanha(s) agendada(s).`);
            await connection.query("UPDATE campanhas SET status = 'Enviando' WHERE id IN (?)", [idsToStart]);
        }
    } catch (error) {
        console.error("ERRO ao verificar agendamentos:", error.message);
    }
}

async function checkCompletedCampaigns(connection) {
    console.log(`[${new Date().toLocaleString('pt-BR')}] Verificando campanhas concluídas...`);
    try {
        const [campaigns] = await connection.query("SELECT id FROM campanhas WHERE status = 'Enviando'");
        if (campaigns.length === 0) return;

        for (const campaign of campaigns) {
            const [pending] = await connection.query(
                "SELECT COUNT(id) as count FROM fila_envio WHERE campanha_id = ? AND status = 'Pendente'",
                [campaign.id]
            );

            if (pending[0].count === 0) {
                await connection.execute("UPDATE campanhas SET status = 'Concluída' WHERE id = ?", [campaign.id]);
                console.log(`>> Campanha ID ${campaign.id} finalizada e marcada como 'Concluída'!`);
            }
        }
    } catch (error) {
        console.error("ERRO ao verificar campanhas concluídas:", error.message);
    }
}

// --- CICLO PRINCIPAL DE ENVIO ---

async function sendingCycle() {
    let connection;
    try {
        connection = await pool.getConnection();

        // 1. CORREÇÃO PRINCIPAL: A consulta SQL foi ajustada
        // - O JOIN agora usa `fe.instancia_id` para se conectar à tabela `instancias`.
        // - Também buscamos `delay_min` e `delay_max` da campanha.
        const [messages] = await connection.query(`
            SELECT 
                fe.id as fila_id, 
                fe.numero_destino, 
                fe.mensagem_personalizada,
                c.cliente_id, 
                c.caminho_midia,
                c.delay_min,
                c.delay_max,
                i.instance_name_api
            FROM fila_envio fe
            JOIN campanhas c ON fe.campanha_id = c.id
            JOIN instancias i ON fe.instancia_id = i.id
            WHERE fe.status = 'Pendente' AND c.status = 'Enviando'
            ORDER BY fe.id ASC
            LIMIT 1
        `);

        // Se não houver mensagens, retorna false para o loop principal saber que deve esperar.
        if (messages.length === 0) {
            console.log("Nenhuma mensagem pendente encontrada. Aguardando...");
            return { sent: false };
        }

        const message = messages[0];
        console.log(`> Mensagem ID ${message.fila_id} encontrada. Enviando para ${message.numero_destino} via instância ${message.instance_name_api}...`);
        
        // Marca a mensagem como 'Processando' para evitar que outro worker a pegue
        await connection.execute("UPDATE fila_envio SET status = 'Processando' WHERE id = ?", [message.fila_id]);

        const axiosConfig = { headers: { 'apikey': EVOLUTION_API_KEY } };

        // Envio do texto
        await axios.post(
            `${EVOLUTION_API_URL}/message/sendText/${message.instance_name_api}`,
            { number: message.numero_destino, text: message.mensagem_personalizada },
            axiosConfig
        );

        // Envio de mídia (se houver)
        if (message.caminho_midia) {
            await sleep(1500); // Pequena pausa antes de enviar a mídia
            // IMPORTANTE: A URL da mídia deve ser pública e acessível pela API.
            const mediaUrl = `${process.env.BASE_URL_UPLOADS}/${message.caminho_midia}`;
            console.log(`> Enviando mídia: ${mediaUrl}`);

            // A lógica para determinar o mediatype (image, document, video) deve ser adicionada aqui
            // Por enquanto, vamos assumir que é uma imagem para simplificar.
            await axios.post(
                `${EVOLUTION_API_URL}/message/sendMedia/${message.instance_name_api}`,
                {
                    number: message.numero_destino,
                        mediatype: 'image', // TODO: Tornar dinâmico com base na extensão do arquivo
                        media: mediaUrl
                },
                axiosConfig
            );
        }

        // Se tudo deu certo, marca como 'Enviado' e debita o crédito
        await connection.execute("UPDATE fila_envio SET status = 'Enviado', data_envio = NOW() WHERE id = ?", [message.fila_id]);
        
        // Esta parte foi comentada porque o crédito já foi debitado na criação da campanha.
        // Se o seu modelo de negócio for debitar no envio, descomente a linha abaixo.
        // await connection.execute("UPDATE clientes SET saldo_creditos_disparo = saldo_creditos_disparo - 1 WHERE id = ?", [message.cliente_id]);
        
        console.log(`>> Mensagem para ${message.numero_destino} enviada com sucesso.`);
        
        // Retorna true e os delays para o loop principal saber quanto tempo esperar.
        return { sent: true, delay_min: message.delay_min, delay_max: message.delay_max };

    } catch (error) {
        const errorMessage = error.response?.data?.error || error.message;
        console.error(`ERRO no ciclo de envio:`, errorMessage);

        // Se a mensagem foi pega mas falhou, marca como 'Falhou'
        if (connection && error.config?.data) {
             const messageData = JSON.parse(error.config.data);
             const failedMessage = await connection.query("SELECT id FROM fila_envio WHERE numero_destino = ? AND status = 'Processando' LIMIT 1", [messageData.number]);
             if(failedMessage[0].length > 0) {
                await connection.execute("UPDATE fila_envio SET status = 'Falhou' WHERE id = ?", [failedMessage[0][0].id]);
                console.log(`>> Mensagem para ${messageData.number} marcada como 'Falhou'.`);
             }
        }
        return { sent: false }; // Retorna false para o loop principal não aplicar delay de sucesso.
    } finally {
        if (connection) connection.release();
    }
}


// --- LOOP PRINCIPAL DO WORKER ---
async function main() {
    console.log("Worker de Disparo iniciado com sucesso.");
    let managementTasksCounter = 0;

    while (true) {
        // Tenta enviar uma mensagem
        const result = await sendingCycle();

        // A cada 4 ciclos de envio (ou quando não houver envios), executa tarefas de gerenciamento
        managementTasksCounter++;
        if (!result.sent || managementTasksCounter >= 4) {
            const connection = await pool.getConnection();
            await checkScheduledCampaigns(connection);
            await checkCompletedCampaigns(connection);
            connection.release();
            managementTasksCounter = 0; // Reseta o contador
        }

        // Lógica de delay
        if (result.sent) {
            const delay = getRandomDelay(result.delay_min, result.delay_max);
            console.log(`Aguardando por ${delay / 1000} segundos...`);
            await sleep(delay);
        } else {
            // Se não enviou nada, espera um tempo fixo antes de tentar de novo
            await sleep(10000); // 10 segundos
        }
    }
}

main().catch(err => {
    console.error("Um erro fatal ocorreu no worker:", err);
    process.exit(1);
});