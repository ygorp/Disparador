<?php
require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/asaas_config.php';

// Log de entrada
error_log("=== ASAAS WEBHOOK RECEBIDO ===");
error_log("Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Headers: " . json_encode(getallheaders()));

// Só aceita POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die('Method Not Allowed');
}

// Lê o corpo da requisição
$input = file_get_contents('php://input');
error_log("Body: " . $input);

// Decodifica o JSON
$webhookData = json_decode($input, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    error_log("Erro ao decodificar JSON: " . json_last_error_msg());
    http_response_code(400);
    die('Invalid JSON');
}

// Validação básica de segurança (opcional - adicione validação de token se necessário)
$receivedToken = $_SERVER['HTTP_X_WEBHOOK_TOKEN'] ?? '';
if (defined('ASAAS_WEBHOOK_TOKEN') && ASAAS_WEBHOOK_TOKEN && $receivedToken !== ASAAS_WEBHOOK_TOKEN) {
    error_log("Token inválido recebido: " . $receivedToken);
    http_response_code(401);
    die('Invalid Token');
}

// Registra o webhook no banco (para auditoria)
try {
    $stmt = $pdo->prepare("INSERT INTO webhook_logs (provider, event_type, payload, processed_at) VALUES (?, ?, ?, NOW())");
    $stmt->execute([
        'asaas',
        $webhookData['event'] ?? 'unknown',
        $input
    ]);
} catch (Exception $e) {
    error_log("Erro ao salvar log do webhook: " . $e->getMessage());
}

// Processa o webhook
try {
    $result = AsaasAPI::processWebhook($webhookData);
    
    if ($result['success']) {
        error_log("Webhook processado com sucesso: " . $result['message']);
        http_response_code(200);
        echo json_encode(['status' => 'success', 'message' => $result['message']]);
    } else {
        error_log("Erro no processamento do webhook: " . $result['message']);
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => $result['message']]);
    }
    
} catch (Exception $e) {
    error_log("Erro crítico no webhook: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Internal Server Error']);
}
?>