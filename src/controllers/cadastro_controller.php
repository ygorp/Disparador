<?php
session_start();
require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../config/database.php';

// Verifica se o formulário foi enviado
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ' . BASE_URL . 'views/client/cadastro.php');
    exit;
}

// 1. Coleta e limpa os dados do formulário
$nome = trim($_POST['nome'] ?? '');
$email = trim($_POST['email'] ?? '');
$senha = $_POST['senha'] ?? '';
$senha_confirm = $_POST['senha_confirm'] ?? '';

// 2. Validação dos dados
if (empty($nome) || empty($email) || empty($senha) || empty($senha_confirm)) {
    $_SESSION['error_message'] = "Todos os campos são obrigatórios.";
    header('Location: ' . BASE_URL . 'views/client/cadastro.php');
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $_SESSION['error_message'] = "O formato do e-mail é inválido.";
    header('Location: ' . BASE_URL . 'views/client/cadastro.php');
    exit;
}

if (strlen($senha) < 6) {
    $_SESSION['error_message'] = "A senha deve ter no mínimo 6 caracteres.";
    header('Location: ' . BASE_URL . 'views/client/cadastro.php');
    exit;
}

if ($senha !== $senha_confirm) {
    $_SESSION['error_message'] = "As senhas não coincidem.";
    header('Location: ' . BASE_URL . 'views/client/cadastro.php');
    exit;
}

try {
    // 3. Verifica se o e-mail já está cadastrado
    $stmt = $pdo->prepare("SELECT id FROM clientes WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error_message'] = "Este e-mail já está em uso.";
        header('Location: ' . BASE_URL . 'views/client/cadastro.php');
        exit;
    }

    // 4. Criptografa a senha (passo de segurança CRUCIAL)
    $senha_hash = password_hash($senha, PASSWORD_DEFAULT);

    // 5. Insere o novo cliente no banco de dados
    $stmt_insert = $pdo->prepare("INSERT INTO clientes (nome, email, senha) VALUES (?, ?, ?)");
    $stmt_insert->execute([$nome, $email, $senha_hash]);

    // 6. Redireciona para a página de login com mensagem de sucesso
    $_SESSION['success_message'] = "Cadastro realizado com sucesso! Faça seu login.";
    header('Location: ' . BASE_URL . 'views/login.php');
    exit;

} catch (PDOException $e) {
    // Em caso de erro no banco de dados
    $_SESSION['error_message'] = "Ocorreu um erro no servidor. Tente novamente mais tarde.";
    // Para depuração: error_log($e->getMessage());
    header('Location: ' . BASE_URL . 'views/client/cadastro.php');
    exit;
}
?>