<?php
session_start();

require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../config/database.php';

// VERIFICAÇÃO DE LOGIN
if (!isset($_SESSION['logged_in'])) {
    header('Location: ' . BASE_URL . 'views/login.php');
    exit;
}

// CONFIGURAÇÕES
$evolutionApiUrl = EVOLUTION_API_BASE_URL;
$evolutionApiKey = EVOLUTION_API_GLOBAL_KEY;
$action = $_REQUEST['action'] ?? '';
$cliente_id = $_SESSION['user_id'];

// FUNÇÃO HELPER PARA CHAMADAS cURL
function callEvolutionAPI($method, $endpoint, $apiKey, $payload = null) {
    $ch = curl_init($endpoint);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $headers = ['Content-Type: application/json'];
    if ($apiKey) {
        $headers[] = 'apikey: ' . $apiKey;
    }
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    if (strtoupper($method) === 'POST' && $payload) {
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    } elseif (strtoupper($method) === 'DELETE') {
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
    }

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ['code' => $http_code, 'body' => $response];
}


// --- ROTEADOR DE AÇÕES ---
if ($action === 'create' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // --- LÓGICA PARA CRIAR INSTÂNCIA ---
    
    $nome_instancia_amigavel = $_POST['nome_instancia'];
    $plano_id = $_POST['plano_id'] ?: null;
    $cliente_id = $_SESSION['user_id'];
    $instance_name_api = $nome_instancia_amigavel;
    $data_fim_maturacao = null;
    $numero_telefone = null;

    $proxy_host = PROXY_HOST;
    $proxy_port = PROXY_PORT;
    $proxy_user = PROXY_USER;
    $proxy_pass = PROXY_PASS;


    $proxy_configurado = (defined('PROXY_HOST') && PROXY_HOST);
    $proxy_ativo_db = $proxy_configurado ? 1 : 0;
    $endpoint = $evolutionApiUrl . '/instance/create';
    $payload = json_encode([
        'instanceName' => $instance_name_api,
        'qrcode' => true,
        'token' => $instance_name_api,
        'integration' => "WHATSAPP-BAILEYS",
        'proxyHost' => $proxy_host,
        'proxyPort' => $proxy_port,
        'proxyProtocol' => 'http',
        'proxyUsername' => $proxy_user,
        'proxyPassword' => $proxy_pass,
    ]);

    $ch = curl_init($endpoint);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'apikey: ' . $evolutionApiKey]);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code === 200 || $http_code === 201) {
        $api_data = json_decode($response, true);
        if (isset($api_data['instance'])) {
            $stmt = $pdo->prepare("INSERT INTO instancias (cliente_id, plano_maturacao_id, nome_instancia, instance_name_api, numero_telefone, status, proxy_ativo, data_fim_maturacao) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$cliente_id, $plano_id, $nome_instancia_amigavel, $instance_name_api, $numero_telefone, 'Desconectado', $proxy_ativo_db, $data_fim_maturacao]);
        }
    }
    // No final, redireciona de volta para o dashboard
    header('Location: ' . BASE_URL . 'views/client/dashboard.php');
    exit;

} elseif ($action === 'get_qrcode' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    
    // --- LÓGICA PARA BUSCAR QR CODE ---

    header('Content-Type: application/json');
    $response_data = ['success' => false, 'message' => 'Erro desconhecido.'];
    $instance_name = $_GET['instance_name'] ?? '';

    if (empty($instance_name)) {
        $response_data['message'] = 'Nome da instância não fornecido.';
    } else {
        $endpoint = $evolutionApiUrl . '/instance/connect/' . $instance_name;

        $ch = curl_init($endpoint);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['apikey: ' . $evolutionApiKey]);
        // A API de connect não precisa de ApiKey global
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($http_code === 200 || $http_code === 201) {
            $api_data = json_decode($response, true);
            if (isset($api_data['base64'])) {
                $response_data['success'] = true;
                $response_data['message'] = 'QR Code obtido com sucesso.';
                $response_data['qrcode'] = $api_data['base64'];
            } else {
                $response_data['message'] = 'A API conectou, mas não retornou um QR Code. A instância pode já estar conectada.';
            }
        } else {
            $response_data['message'] = 'Falha ao conectar na API. Código: ' . $http_code;
        }
    }
    echo json_encode($response_data);
    exit;
} elseif ($action === 'check_status' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    header('Content-Type: application/json');
    $response_data = ['success' => false, 'status' => 'unknown'];
    $instance_name = $_GET['instance_name'] ?? '';

    if (!empty($instance_name)) {
        $endpoint = $evolutionApiUrl . '/instance/connectionState/' . $instance_name;
        $ch = curl_init($endpoint);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['apikey: ' . $evolutionApiKey]);
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($http_code === 200) {
            $api_data = json_decode($response, true);
            if (isset($api_data['instance']['state'])) {
                $new_status = ($api_data['instance']['state'] === 'open') ? 'Conectado' : 'Desconectado';
                
                // Atualiza o status no nosso banco
                $stmt = $pdo->prepare("UPDATE instancias SET status = ? WHERE instance_name_api = ?");
                $stmt->execute([$new_status, $instance_name]);
                
                // SE O NOVO STATUS FOR 'CONECTADO', BUSCA E SALVA O NÚMERO
                if ($new_status === 'Conectado') {
                    $fetch_endpoint = $evolutionApiUrl . '/instance/fetchInstances?instanceName=' . $instance_name;
                    $ch_fetch = curl_init($fetch_endpoint);
                    curl_setopt($ch_fetch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch_fetch, CURLOPT_HTTPHEADER, ['apikey: ' . $evolutionApiKey]);
                    $fetch_response = curl_exec($ch_fetch);
                    curl_close($ch_fetch);
                    
                    $instance_data_api = json_decode($fetch_response, true);
                    $numero_telefone = str_replace('@s.whatsapp.net', '', $instance_data_api[0]['ownerJid'] ?? null);

                    if ($numero_telefone) {
                        $stmt_num = $pdo->prepare("UPDATE instancias SET numero_telefone = ? WHERE instance_name_api = ?");
                        $stmt_num->execute([$numero_telefone, $instance_name]);
                    }
                }
                
                $response_data['success'] = true;
                $response_data['status'] = $new_status;
            }
        }
    }
    echo json_encode($response_data);
    exit;
} elseif ($action === 'disconnect' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $instance_name = $_GET['instance_name'] ?? '';
    if ($instance_name) {
        $endpoint = $evolutionApiUrl . '/instance/logout/' . $instance_name;
        $ch = curl_init($endpoint);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE"); // Método DELETE
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['apikey: ' . $evolutionApiKey]);
        curl_exec($ch);
        curl_close($ch);
        // Opcional: Atualizar o status no nosso banco para 'Desconectado'
        $stmt = $pdo->prepare("UPDATE instancias SET status = 'Desconectado' WHERE instance_name_api = ?");
        $stmt->execute([$instance_name]);
    }
    header('Location: ' . BASE_URL . 'views/client/dashboard.php');
    exit;

} elseif ($action === 'delete' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $instance_name = $_GET['instance_name'] ?? '';
    $instance_id = $_GET['instance_id'] ?? '';
    if ($instance_name && $instance_id) {
        // 1. Deleta da API Evolution
        $endpoint = $evolutionApiUrl . '/instance/delete/' . $instance_name;
        $ch = curl_init($endpoint);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['apikey: ' . $evolutionApiKey]);
        curl_exec($ch);
        curl_close($ch);

        // 2. Deleta do nosso banco de dados
        $stmt = $pdo->prepare("DELETE FROM instancias WHERE id = ? AND cliente_id = ?");
        $stmt->execute([$instance_id, $_SESSION['user_id']]);
    }
    header('Location: ' . BASE_URL . 'views/client/dashboard.php');
    exit;
} elseif ($action === 'start_maturation' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    // ================== INÍCIO DAS ALTERAÇÕES ==================
    $instance_id = $_GET['instance_id'] ?? null;
    if ($instance_id) {
        try {
            $pdo->beginTransaction();
            
            // ATUALIZADO: A consulta agora também busca a nova coluna 'maturacao_restante_secs'
            $stmt = $pdo->prepare("SELECT i.numero_telefone, i.plano_maturacao_id, i.cliente_id, i.maturacao_restante_secs, p.preco, p.duracao_dias, c.saldo_creditos_maturacao FROM instancias i JOIN planos p ON i.plano_maturacao_id = p.id JOIN clientes c ON i.cliente_id = c.id WHERE i.id = ? AND i.cliente_id = ?");
            $stmt->execute([$instance_id, $cliente_id]);
            $data = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$data) throw new Exception("Dados da instância, plano ou cliente não encontrados.");
            if (empty($data['numero_telefone'])) throw new Exception("Número de telefone não definido. Conecte a instância primeiro.");

            // Adiciona ao grupo na API
            $endpoint = $evolutionApiUrl . '/group/updateParticipant/' . GROUP_ADMIN_INSTANCE_NAME . '?groupJid=' . MATURATION_GROUP_ID;
            $payload = ['action' => 'add', 'participants' => [$data['numero_telefone'] . '@s.whatsapp.net']];
            $result = callEvolutionAPI('POST', $endpoint, $evolutionApiKey, $payload);
            if (!in_array($result['code'], [200, 201, 409])) {
                throw new Exception("Falha ao adicionar ao grupo. API respondeu: {$result['code']} - {$result['body']}");
            }

            // NOVA LÓGICA: Verifica se está retomando uma maturação pausada ou iniciando uma nova
            if ($data['maturacao_restante_secs'] && $data['maturacao_restante_secs'] > 0) {
                // --- CENÁRIO 1: RETOMANDO UMA MATURAÇÃO PAUSADA ---
                
                // Calcula a nova data de fim com base nos segundos restantes
                $data_fim = (new DateTime())->add(new DateInterval("PT{$data['maturacao_restante_secs']}S"))->format('Y-m-d H:i:s');
                
                // Atualiza a instância com a nova data de fim e limpa os segundos restantes
                $pdo->prepare("UPDATE instancias SET data_fim_maturacao = ?, maturacao_restante_secs = NULL WHERE id = ?")->execute([$data_fim, $instance_id]);
                
                $_SESSION['success_message'] = "Maturação retomada com sucesso!";

            } else {
                // --- CENÁRIO 2: INICIANDO UMA NOVA MATURAÇÃO ---

                // Verifica o saldo (apenas para novas maturações)
                if ((float)$data['saldo_creditos_maturacao'] < (float)$data['preco']) throw new Exception("Saldo de créditos insuficiente.");

                // Debita os créditos do cliente
                $novo_saldo = (float)$data['saldo_creditos_maturacao'] - (float)$data['preco'];
                $pdo->prepare("UPDATE clientes SET saldo_creditos_maturacao = ? WHERE id = ?")->execute([$novo_saldo, $data['cliente_id']]);
                
                // Calcula a data de fim
                $data_fim = (new DateTime())->add(new DateInterval("P{$data['duracao_dias']}D"))->format('Y-m-d H:i:s');
                $pdo->prepare("UPDATE instancias SET data_fim_maturacao = ? WHERE id = ?")->execute([$data_fim, $instance_id]);

                // Registra a transação de compra
                $stmt_transacao = $pdo->prepare("INSERT INTO transacoes (cliente_id, plano_id, tipo_transacao, valor, status_pagamento) VALUES (?, ?, ?, ?, ?)");
                $stmt_transacao->execute([$cliente_id, $data['plano_maturacao_id'], 'compra_maturacao', - (float)$data['preco'], 'Pago']);
                
                $_SESSION['success_message'] = "Maturação iniciada com sucesso!";
            }

            $pdo->commit();
        } catch (Exception $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            $_SESSION['error_message'] = "Erro ao iniciar maturação: " . $e->getMessage();
        }
    }
    header('Location: ' . BASE_URL . 'views/client/dashboard.php');
    exit;
    // =================== FIM DAS ALTERAÇÕES ====================

} elseif ($action === 'stop_maturation' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    // ================== INÍCIO DAS ALTERAÇÕES ==================
    $instance_id = $_GET['instance_id'] ?? null;
    
    if ($instance_id) {
        try {
            $pdo->beginTransaction();

            $stmt = $pdo->prepare("SELECT numero_telefone, data_fim_maturacao FROM instancias WHERE id = ? AND cliente_id = ?");
            $stmt->execute([$instance_id, $cliente_id]);
            $instancia = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($instancia) {
                // NOVA LÓGICA: Calcula e salva os segundos restantes antes de pausar
                $segundos_restantes = null;
                if ($instancia['data_fim_maturacao']) {
                    $data_fim = new DateTime($instancia['data_fim_maturacao']);
                    $agora = new DateTime();
                    if ($data_fim > $agora) {
                        $diferenca = $data_fim->getTimestamp() - $agora->getTimestamp();
                        $segundos_restantes = $diferenca;
                    }
                }
                
                // Remove do grupo via API (opcional, pode-se deixar no grupo)
                if (!empty($instancia['numero_telefone'])) {
                     $endpoint = $evolutionApiUrl . '/group/updateParticipant/' . GROUP_ADMIN_INSTANCE_NAME . '?groupJid=' . MATURATION_GROUP_ID;
                     $payload = ['action' => 'remove', 'participants' => [$instancia['numero_telefone'] . '@s.whatsapp.net']];
                     callEvolutionAPI('POST', $endpoint, $evolutionApiKey, $payload);
                }
                
                // ATUALIZADO: Salva os segundos restantes e limpa a data de fim para indicar que está pausado
                $pdo->prepare("UPDATE instancias SET data_fim_maturacao = NULL, maturacao_restante_secs = ? WHERE id = ?")->execute([$segundos_restantes, $instance_id]);
                
                $_SESSION['success_message'] = "Maturação interrompida com sucesso.";
            }
            
            $pdo->commit();

        } catch (Exception $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            $_SESSION['error_message'] = "Erro ao parar maturação: " . $e->getMessage();
        }
    }
    header('Location: ' . BASE_URL . 'views/client/dashboard.php');
    exit;
    // =================== FIM DAS ALTERAÇÕES ====================
}
// Se nenhuma ação válida for encontrada, redireciona para o dashboard
header('Location: ' . BASE_URL . 'views/client/dashboard.php');
exit;
?>