<?php
require_once '../partials/header.php';
require_once __DIR__ . '/../../config/database.php';

// Busca os planos de DISPARO
$planos_disparo = [];
try {
    $stmt_disparo = $pdo->prepare("SELECT * FROM planos WHERE tipo = 'disparo' AND ativo = TRUE ORDER BY preco");
    $stmt_disparo->execute();
    $planos_disparo = $stmt_disparo->fetchAll();
} catch (PDOException $e) { /* Tratar erro */ }

// Busca os planos de MATURAÇÃO
$planos_maturacao = [];
try {
    $stmt_maturacao = $pdo->prepare("SELECT * FROM planos WHERE tipo = 'maturacao' AND ativo = TRUE ORDER BY preco");
    $stmt_maturacao->execute();
    $planos_maturacao = $stmt_maturacao->fetchAll();
} catch (PDOException $e) { /* Tratar erro */ }
?>

<h1 class="text-3xl font-bold text-white mb-6">Loja de Planos e Créditos</h1>

<div class="mb-12">
    <h2 class="text-2xl font-semibold text-roxo-principal mb-4 border-b-2 border-roxo-principal pb-2">Pacotes de Créditos de Disparo</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-6">
        <?php foreach ($planos_disparo as $plano): ?>
            <div class="bg-card-fundo rounded-lg p-8 flex flex-col text-center items-center border-2 border-gray-700 hover:border-roxo-principal transition">
                <h3 class="text-xl font-bold text-white mb-4"><?= htmlspecialchars($plano['nome']) ?></h3>
                <p class="text-5xl font-bold text-roxo-principal mb-2"><?= number_format($plano['creditos_disparo'], 0, ',', '.') ?></p>
                <p class="text-gray-400 mb-6 font-semibold">CRÉDITOS</p>
                <div class="text-2xl font-bold text-white mb-8">R$ <?= number_format($plano['preco'], 2, ',', '.') ?></div>
                <form action="../../src/controllers/plano_controller.php" method="POST" class="w-full mt-auto">
                    <input type="hidden" name="action" value="buy_credits_disparo">
                    <input type="hidden" name="plano_id" value="<?= $plano['id'] ?>">
                    <button type="submit" class="w-full bg-roxo-principal text-white font-bold py-3 rounded-md hover:bg-purple-600">Comprar Pacote</button>
                </form>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<div>
    <h2 class="text-2xl font-semibold text-blue-400 mb-4 border-b-2 border-blue-400 pb-2">Planos de Maturação</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-6">
        <?php foreach ($planos_maturacao as $plano): ?>
            <div class="bg-card-fundo rounded-lg p-8 flex flex-col text-center items-center border-2 border-gray-700 hover:border-blue-400 transition">
                <h3 class="text-xl font-bold text-white mb-4"><?= htmlspecialchars($plano['nome']) ?></h3>
                <p class="text-5xl font-bold text-blue-400 mb-2"><?= number_format($plano['preco'], 0, ',', '.') ?></p>
                <p class="text-gray-400 mb-6 font-semibold">CRÉDITOS DE MATURAÇÃO</p>
                <div class="text-xl font-bold text-white mb-8"><?= htmlspecialchars($plano['duracao_dias']) ?> dias de aquecimento</div>
                <form action="../../src/controllers/plano_controller.php" method="POST" class="w-full mt-auto">
                    <input type="hidden" name="action" value="buy_credits_maturacao">
                    <input type="hidden" name="plano_id" value="<?= $plano['id'] ?>">
                    <button type="submit" class="w-full bg-blue-500 text-white font-bold py-3 rounded-md hover:bg-blue-600">Comprar Créditos</button>
                </form>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<?php require_once '../partials/footer.php'; ?>