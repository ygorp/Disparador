import mysql from 'mysql2/promise';
import axios from 'axios';
import 'dotenv/config';
import { parse } from 'dotenv';

// --- CONFIGURAÇÕES (Lidas do arquivo .env) ---
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
const EVOLUTION_API_KEY = process.env.EVOLUTION_API_KEY;
const MATURATION_GROUP_ID = process.env.MATURATION_GROUP_ID;

// --- VALIDAÇÃO INICIAL DAS VARIÁVEIS DE AMBIENTE ---
if (!EVOLUTION_API_URL || !EVOLUTION_API_KEY || !MATURATION_GROUP_ID) {
    console.error("ERRO CRÍTICO: As variáveis de ambiente EVOLUTION_API_URL, EVOLUTION_API_KEY, e MATURATION_GROUP_ID devem ser definidas no arquivo .env");
    process.exit(1); // Encerra o worker se as configurações essenciais não estiverem presentes.
}

const pool = mysql.createPool(DB_CONFIG);

let maturationContent = {
    texto: [], imagem: [], audio: [], localizacao: []
};

// Função para carregar/recarregar o conteúdo do banco de dados
async function loadMaturationContent() {
    console.log("> Carregando conteúdo de maturação do banco de dados...");
    try {
        const [rows] = await pool.execute("SELECT * FROM conteudo_maturacao WHERE ativo = 1");
        // Reseta o conteúdo antes de preencher
        maturationContent = { texto: [], imagem: [], audio: [], localizacao: [] };
        rows.forEach(row => {
            if (maturationContent[row.tipo]) {
                maturationContent[row.tipo].push(row);
            }
        });
        console.log(`> Conteúdo carregado: ${maturationContent.texto.length} textos, ${maturationContent.imagem.length} imagens, ${maturationContent.audio.length} áudios, ${maturationContent.localizacao.length} localizações.`);
    } catch (error) {
        console.error("ERRO ao carregar conteúdo de maturação:", error.message);
    }
}

async function sendMessage(instanceName, type, content) {
    let endpoint = '';
    let payload = {};
    const axiosConfig = { headers: { 'apikey': EVOLUTION_API_KEY, 'Content-Type': 'application/json' } }; // Config de autenticação

    switch (type) {
        case 'texto':
            endpoint = `${EVOLUTION_API_URL}/message/sendText/${instanceName}`;
            // Payload correto para a sua collection
            payload = {
                number: MATURATION_GROUP_ID,
                delay: 1200,
                text: content.conteudo
            };
            break;
        case 'imagem':
            endpoint = `${EVOLUTION_API_URL}/message/sendMedia/${instanceName}`;
             // Payload correto para a sua collection
            payload = {
                number: MATURATION_GROUP_ID,
                delay: 1200,
                mediatype: 'image',
                caption: content.caption || 'Imagem de maturação',
                media: content.conteudo
            };
            break;
        case 'audio':
            endpoint = `${EVOLUTION_API_URL}/message/sendWhatsAppAudio/${instanceName}`;
             // CORREÇÃO APLICADA AQUI: Usar 'mediatype' e 'media' para áudio
            payload = {
                number: MATURATION_GROUP_ID,
                delay: 1200,
                audio: content.conteudo 
            };
            break;
        case 'localizacao':
            endpoint = `${EVOLUTION_API_URL}/message/sendLocation/${instanceName}`;
             // Payload correto para a sua collection (sem objeto aninhado)
            payload = { 
                number: MATURATION_GROUP_ID, 
                delay: 1200,
                name: content.nome_local,
                address: content.endereco,
                latitude: parseFloat(content.latitude),
                longitude: parseFloat(content.longitude)
            };
            break;
        default: 
            console.log(`- Tipo de mensagem desconhecido: ${type}`);
            return;
    }

    try {
        await axios.post(endpoint, payload, axiosConfig);
        console.log(`- [${type}] Mensagem enviada com sucesso para o grupo via instância ${instanceName}`);
    } catch (error) {
        const errorMsg = error.response ? JSON.stringify(error.response.data) : error.message;
        console.error(`- Erro ao enviar [${type}] por ${instanceName}: ${errorMsg}`);
    }
}

async function maturationCycle() {
    console.log(`[${new Date().toLocaleString('pt-BR')}] Iniciando ciclo de maturação...`);
    
    try {
        const [instances] = await pool.execute(
            `SELECT * FROM instancias WHERE status = 'Conectado' AND plano_maturacao_id IS NOT NULL AND data_fim_maturacao >= NOW()`
        );
        if (instances.length === 0) {
            console.log("> Nenhuma instância ativa para maturar no momento.");
            return;
        }
        console.log(`> Encontradas ${instances.length} instâncias para maturar.`);

        for (const instance of instances) {
            console.log(`>> Processando instância: ${instance.nome_instancia}`);
            
            const availableTypes = Object.keys(maturationContent).filter(type => maturationContent[type].length > 0);
            if(availableTypes.length === 0) {
                console.log(">> Nenhum conteúdo de maturação disponível no banco de dados.");
                continue;
            }

            const randomType = availableTypes[Math.floor(Math.random() * availableTypes.length)];
            const contentArray = maturationContent[randomType];
            const randomContent = contentArray[Math.floor(Math.random() * contentArray.length)];
            
            await sendMessage(instance.instance_name_api, randomType, randomContent);

            const delay = Math.floor(Math.random() * 12000) + 60000;
            console.log(`   Aguardando ${delay / 1000} segundos...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    } catch (error) {
        console.error("ERRO GERAL no ciclo de maturação:", error.message);
    } finally {
        console.log(`[${new Date().toLocaleString('pt-BR')}] Ciclo de maturação finalizado.`);
    }
}

// Inicia o worker
async function startWorker() {
    console.log("Worker de Maturação iniciado. Carregando conteúdo inicial...");
    await loadMaturationContent(); // Carrega o conteúdo uma vez ao iniciar
    setInterval(loadMaturationContent, 3600000); // Recarrega o conteúdo a cada hora
    
    console.log("Iniciando o primeiro ciclo de maturação...");
    await maturationCycle(); // Executa o ciclo imediatamente ao iniciar
    setInterval(maturationCycle, 120000); // E continua a cada 2 minutos
}

startWorker();
