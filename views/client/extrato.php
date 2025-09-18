<?php
require_once '../partials/header.php';
require_once __DIR__ . '/../../config/database.php';

$cliente_id = $_SESSION['user_id'];

// Lógica de Filtro e Paginação
$data_inicial = $_GET['data_inicial'] ?? '';
$data_final = $_GET['data_final'] ?? '';
$limit = 10; // Itens por página

// Constrói a query SQL com base nos filtros
$sql = "SELECT t.*, p.nome as nome_plano 
        FROM transacoes t 
        LEFT JOIN planos p ON t.plano_id = p.id 
        WHERE t.cliente_id = ?";
$params = [$cliente_id];

if ($data_inicial) {
    $sql .= " AND DATE(t.data_transacao) >= ?";
    $params[] = $data_inicial;
}
if ($data_final) {
    $sql .= " AND DATE(t.data_transacao) <= ?";
    $params[] = $data_final;
}
$sql .= " ORDER BY t.data_transacao DESC";

try {
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $transacoes = $stmt->fetchAll();
} catch (PDOException $e) {
    die("Erro ao buscar transações: " . $e->getMessage());
}

?>

<h1 class="text-3xl font-bold text-white mb-6">Extrato da Conta</h1>

<div class="bg-card-fundo p-6 rounded-lg shadow-lg mb-8">
    <form method="GET" action="extrato.php" class="flex items-center space-x-4">
        <div>
            <label for="data_inicial" class="text-sm text-gray-400">Data Inicial</label>
            <input type="date" name="data_inicial" id="data_inicial" value="<?= htmlspecialchars($data_inicial) ?>" class="bg-fundo-principal text-white rounded-md p-2 mt-1">
        </div>
        <div>
            <label for="data_final" class="text-sm text-gray-400">Data Final</label>
            <input type="date" name="data_final" id="data_final" value="<?= htmlspecialchars($data_final) ?>" class="bg-fundo-principal text-white rounded-md p-2 mt-1">
        </div>
        <div class="pt-5">
            <button type="submit" class="bg-roxo-principal text-white px-6 py-2 rounded-md hover:bg-purple-600">Filtrar</button>
        </div>
    </form>
</div>

<div class="bg-card-fundo rounded-lg shadow-lg p-6">
    <div class="overflow-x-auto">
        <table class="w-full text-left">
            <thead>
                <tr class="text-gray-400 border-b border-gray-700">
                    <th class="p-4">Data</th>
                    <th class="p-4">Descrição</th>
                    <th class="p-4 text-right">Valor</th>
                    <th class="p-4 text-center">Status</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($transacoes)): ?>
                    <tr><td colspan="4" class="text-center p-6 text-gray-400">Nenhum registro encontrado.</td></tr>
                <?php else: ?>
                    <?php foreach ($transacoes as $transacao): ?>
                        <tr class="border-b border-gray-700">
                            <td class="p-4 text-gray-300"><?= (new DateTime($transacao['data_transacao']))->format('d/m/Y H:i:s') ?></td>
                            <td class="p-4 text-white">
                                <?php // Lógica para gerar a descrição
                                    $descricao = "Transação desconhecida";
                                    if ($transacao['tipo_transacao'] === 'recarga_disparo') $descricao = "Depósito para Créditos de Disparo";
                                    if ($transacao['tipo_transacao'] === 'recarga_maturacao') $descricao = "Depósito para Créditos de Maturação";
                                    if ($transacao['tipo_transacao'] === 'compra_maturacao') $descricao = "Início de Maturação - " . htmlspecialchars($transacao['nome_plano']);
                                    if ($transacao['tipo_transacao'] === 'compra_disparo') $descricao = "Crédito utilizado em Campanha de Disparo";
                                    echo $descricao;
                                ?>
                            </td>
                            <td class="p-4 text-right font-semibold <?= $transacao['valor'] > 0 ? 'text-green-500' : 'text-red-500' ?>">
                                <?= ($transacao['valor'] > 0 ? '+R$ ' : '-R$ ') . number_format(abs($transacao['valor']), 2, ',', '.') ?>
                            </td>
                            <td class="p-4 text-center">
                                <?php
                                    $status_class = 'bg-gray-500';
                                    if ($transacao['status_pagamento'] === 'Pago') $status_class = 'bg-green-500';
                                    if ($transacao['status_pagamento'] === 'Cancelado') $status_class = 'bg-red-500';
                                ?>
                                <span class="px-3 py-1 text-xs rounded-full text-white <?= $status_class ?>"><?= htmlspecialchars($transacao['status_pagamento']) ?></span>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    </div>

<?php require_once '../partials/footer.php'; ?>