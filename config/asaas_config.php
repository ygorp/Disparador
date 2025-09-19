<?php
// === CONFIGURAÇÕES DO ASAAS ===
// IMPORTANTE: Substitua pelas suas credenciais do ASAAS

// Ambiente de desenvolvimento (sandbox)
define('ASAAS_API_KEY_SANDBOX', '$aact_hmlg_000MzkwODA2MWY2OGM3MWRlMDU2NWM3MzJlNzZmNGZhZGY6OjliYTVhMDM3LWNmODYtNDg1Ny1hMTU4LTc0ZjhiNzk1YjE4YTo6JGFhY2hfMTAzZmM5NTYtMzJjYi00YzQ1LWJkY2EtYzNkYzY4MTUwODAx');
define('ASAAS_BASE_URL_SANDBOX', 'https://sandbox.asaas.com/api/v3');

// Ambiente de produção
define('ASAAS_API_KEY_PRODUCTION', 'SUA_CHAVE_DE_PRODUCAO_AQUI');
define('ASAAS_BASE_URL_PRODUCTION', 'https://www.asaas.com/api/v3');

// Configuração atual (altere para 'production' quando for para produção)
define('ASAAS_ENVIRONMENT', 'sandbox');

// URLs dinâmicas baseadas no ambiente
if (ASAAS_ENVIRONMENT === 'production') {
    define('ASAAS_API_KEY', ASAAS_API_KEY_PRODUCTION);
    define('ASAAS_BASE_URL', ASAAS_BASE_URL_PRODUCTION);
} else {
    define('ASAAS_API_KEY', ASAAS_API_KEY_SANDBOX);
    define('ASAAS_BASE_URL', ASAAS_BASE_URL_SANDBOX);
}

// Webhook URLs
define('ASAAS_WEBHOOK_URL', BASE_URL . 'src/webhooks/asaas_webhook.php');

// Configurações de cobrança
define('ASAAS_WEBHOOK_TOKEN', 'webhook_token_secreto_123'); // Token para validar webhooks
define('ASAAS_DUE_DATE_DAYS', 7); // Vencimento padrão em dias
define('ASAAS_FINE_PERCENTAGE', 2); // Multa por atraso (%)
define('ASAAS_INTEREST_PERCENTAGE', 1); // Juros por mês de atraso (%)

// Configurações do cliente
define('ASAAS_NOTIFICATION_DISABLED', false); // Notificações por email/SMS
define('ASAAS_POSTAL_SERVICE', false); // Envio de boleto por correio

// === CLASSE PARA INTEGRAÇÃO COM ASAAS - CORRIGIDA ===
class AsaasAPI {
    private $apiKey;
    private $baseUrl;
    
    public function __construct() {
        $this->apiKey = ASAAS_API_KEY;
        $this->baseUrl = ASAAS_BASE_URL;
    }
    
    /**
     * Executa uma requisição para a API do ASAAS - CORRIGIDA
     */
    private function makeRequest($method, $endpoint, $data = null) {
        $url = $this->baseUrl . $endpoint;
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
        
        // *** CORREÇÃO PRINCIPAL: ASAAS usa 'access_token' no header, não Authorization ***
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'access_token: ' . $this->apiKey,
            'User-Agent: Discador.net/1.0'
        ]);
        
        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            if ($data) {
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            }
        } elseif ($method === 'PUT') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
            if ($data) {
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            }
        } elseif ($method === 'DELETE') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
        }
        
        // Desabilitar verificação SSL apenas para desenvolvimento local
        if (strpos($this->baseUrl, 'sandbox') !== false) {
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        // Log para debug
        error_log("ASAAS API Request: $method $url");
        error_log("ASAAS API Response Code: $httpCode");
        if ($error) {
            error_log("ASAAS API Error: $error");
        }
        
        $decodedResponse = json_decode($response, true);
        
        return [
            'success' => $httpCode >= 200 && $httpCode < 300,
            'http_code' => $httpCode,
            'data' => $decodedResponse,
            'raw_response' => $response,
            'error' => $error
        ];
    }
    
    /**
     * Método público para fazer requisições (necessário para setup)
     */
    public function makeRequestPublic($method, $endpoint, $data = null) {
        return $this->makeRequest($method, $endpoint, $data);
    }
    
    /**
     * Cria ou atualiza um cliente no ASAAS
     */
    public function createOrUpdateCustomer($customerData) {
        // Verifica se já existe cliente com este email
        $existing = $this->getCustomerByEmail($customerData['email']);
        
        if ($existing['success'] && !empty($existing['data']['data'])) {
            // Cliente já existe, atualiza
            $customerId = $existing['data']['data'][0]['id'];
            return $this->makeRequest('PUT', "/customers/{$customerId}", $customerData);
        } else {
            // Cliente não existe, cria novo
            return $this->makeRequest('POST', '/customers', $customerData);
        }
    }
    
    /**
     * Busca cliente por email
     */
    public function getCustomerByEmail($email) {
        return $this->makeRequest('GET', "/customers?email=" . urlencode($email));
    }
    
    /**
     * Cria uma cobrança no ASAAS
     */
    public function createPayment($paymentData) {
        return $this->makeRequest('POST', '/payments', $paymentData);
    }
    
    /**
     * Busca uma cobrança específica
     */
    public function getPayment($paymentId) {
        return $this->makeRequest('GET', "/payments/{$paymentId}");
    }
    
    /**
     * Lista cobranças com filtros
     */
    public function listPayments($filters = []) {
        $queryString = http_build_query($filters);
        $endpoint = '/payments' . ($queryString ? '?' . $queryString : '');
        return $this->makeRequest('GET', $endpoint);
    }
    
    /**
     * Cancela uma cobrança
     */
    public function cancelPayment($paymentId) {
        return $this->makeRequest('DELETE', "/payments/{$paymentId}");
    }
    
    /**
     * Gera link de pagamento PIX
     */
    public function getPixQrCode($paymentId) {
        return $this->makeRequest('GET', "/payments/{$paymentId}/pixQrCode");
    }
    
    /**
     * Webhook - processa notificação do ASAAS
     */
    public static function processWebhook($webhookData) {
        global $pdo;
        
        // Log do webhook recebido
        error_log("ASAAS Webhook recebido: " . json_encode($webhookData));
        
        $event = $webhookData['event'] ?? '';
        $payment = $webhookData['payment'] ?? [];
        
        if (empty($payment['id'])) {
            return ['success' => false, 'message' => 'Payment ID não encontrado'];
        }
        
        // Processa diferentes tipos de evento
        switch ($event) {
            case 'PAYMENT_CONFIRMED':
            case 'PAYMENT_RECEIVED':
                return self::handlePaymentConfirmed($payment);
            
            case 'PAYMENT_OVERDUE':
                return self::handlePaymentOverdue($payment);
            
            case 'PAYMENT_DELETED':
                return self::handlePaymentDeleted($payment);
            
            default:
                error_log("Evento não tratado: " . $event);
                return ['success' => true, 'message' => 'Evento ignorado'];
        }
    }
    
    /**
     * Processa pagamento confirmado
     */
    private static function handlePaymentConfirmed($payment) {
        global $pdo;
        
        try {
            $pdo->beginTransaction();
            
            // Busca a transação pelo external_reference
            $stmt = $pdo->prepare("SELECT * FROM transacoes WHERE asaas_payment_id = ? OR external_reference = ?");
            $stmt->execute([$payment['id'], $payment['externalReference'] ?? '']);
            $transacao = $stmt->fetch();
            
            if (!$transacao) {
                throw new Exception("Transação não encontrada para payment ID: " . $payment['id']);
            }
            
            // Atualiza status da transação
            $stmt_update = $pdo->prepare("UPDATE transacoes SET status_pagamento = 'Pago', asaas_payment_id = ?, data_pagamento = NOW() WHERE id = ?");
            $stmt_update->execute([$payment['id'], $transacao['id']]);
            
            // Adiciona créditos ao cliente
            if ($transacao['tipo_transacao'] === 'recarga_disparo') {
                $stmt_credito = $pdo->prepare("UPDATE clientes SET saldo_creditos_disparo = saldo_creditos_disparo + ? WHERE id = ?");
                $stmt_credito->execute([$transacao['creditos_quantidade'], $transacao['cliente_id']]);
            } elseif ($transacao['tipo_transacao'] === 'recarga_maturacao') {
                $stmt_credito = $pdo->prepare("UPDATE clientes SET saldo_creditos_maturacao = saldo_creditos_maturacao + ? WHERE id = ?");
                $stmt_credito->execute([$transacao['creditos_quantidade'], $transacao['cliente_id']]);
            }
            
            $pdo->commit();
            
            error_log("Pagamento confirmado com sucesso: " . $payment['id']);
            return ['success' => true, 'message' => 'Pagamento processado'];
            
        } catch (Exception $e) {
            $pdo->rollBack();
            error_log("Erro ao processar pagamento: " . $e->getMessage());
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }
    
    /**
     * Processa pagamento em atraso
     */
    private static function handlePaymentOverdue($payment) {
        global $pdo;
        
        $stmt = $pdo->prepare("UPDATE transacoes SET status_pagamento = 'Vencido' WHERE asaas_payment_id = ?");
        $stmt->execute([$payment['id']]);
        
        return ['success' => true, 'message' => 'Pagamento marcado como vencido'];
    }
    
    /**
     * Processa pagamento cancelado
     */
    private static function handlePaymentDeleted($payment) {
        global $pdo;
        
        $stmt = $pdo->prepare("UPDATE transacoes SET status_pagamento = 'Cancelado' WHERE asaas_payment_id = ?");
        $stmt->execute([$payment['id']]);
        
        return ['success' => true, 'message' => 'Pagamento cancelado'];
    }
}
?>