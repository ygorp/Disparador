<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/../../config/config.php';

if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    header('Location: ../../views/login.php');
    exit;
}
$userName = $_SESSION['user_name'] ?? 'Usuário';
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Painel do Cliente - Discador.net</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'fundo-principal': '#1a1a2e',
                        'card-fundo': '#2a2a45',
                        'roxo-principal': '#7e57c2',
                        'laranja-acento': '#ff7043',
                        'verde-sucesso': '#22c55e',
                        'vermelho-erro': '#ef4444',
                        'amarelo-atencao': '#f59e0b',
                    }
                }
            }
        }
    </script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-fundo-principal text-gray-200">

    <div id="app">
        <header class="bg-card-fundo shadow-md">
            <div class="container mx-auto px-6 py-4 flex justify-between items-center">
                <div class="flex items-center space-x-8">
                    <img src="../../assets/images/logo.png" alt="Logo Discador.net" class="h-10">
                    <nav class="hidden md:flex items-center space-x-6">
                        <a href="<?php echo BASE_URL; ?>views/client/dashboard.php" class="text-white font-semibold border-b-2 border-roxo-principal pb-1">Maturação</a>
                        <a href="<?php echo BASE_URL; ?>views/client/disparos.php" class="text-white font-semibold border-b-2 border-roxo-principal pb-1">Disparos</a>
                        <a href="extrato.php" class="hover:text-white transition">Extrato</a>
                        <a href="#" class="hover:text-white transition">Suporte</a>
                        <a href="tutorial.php" class="hover:text-white transition">Tutorial</a>
                    </nav>
                </div>

                <div class="flex items-center space-x-4">                    
                    <div class="relative">
                        <button id="user-menu-button" class="flex items-center space-x-2">
                            <span class="text-white font-medium"><?= htmlspecialchars($userName) ?></span>
                            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                        </button>
                        <div id="user-menu" class="absolute right-0 mt-2 w-48 bg-fundo-principal rounded-md shadow-lg py-1 hidden z-10">
                            <a href="#" class="block px-4 py-2 text-sm text-gray-300 hover:bg-card-fundo">Alterar Senha</a>
                            <a href="<?php echo BASE_URL; ?>src/controllers/logout_controller.php" class="block px-4 py-2 text-sm text-gray-300 hover:bg-card-fundo">Sair</a>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <main class="container mx-auto p-6">