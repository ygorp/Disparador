-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: disparador
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administradores`
--

DROP TABLE IF EXISTS `administradores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `administradores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administradores`
--

LOCK TABLES `administradores` WRITE;
/*!40000 ALTER TABLE `administradores` DISABLE KEYS */;
INSERT INTO `administradores` VALUES (1,'Administrador Principal','admin@admin.com','$2y$10$K6B6MAUYgsRmZTGON179T.UQhdS.r2PoAnBetjK60CpX/tWRV1qBq');
/*!40000 ALTER TABLE `administradores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assinaturas`
--

DROP TABLE IF EXISTS `assinaturas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assinaturas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `plano_id` int NOT NULL,
  `asaas_subscription_id` varchar(255) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','OVERDUE','EXPIRED') DEFAULT 'ACTIVE',
  `valor_mensal` decimal(10,2) NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date DEFAULT NULL,
  `proximo_vencimento` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `plano_id` (`plano_id`),
  KEY `idx_cliente_status` (`cliente_id`,`status`),
  KEY `idx_asaas_subscription` (`asaas_subscription_id`),
  CONSTRAINT `assinaturas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assinaturas_ibfk_2` FOREIGN KEY (`plano_id`) REFERENCES `planos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assinaturas`
--

LOCK TABLES `assinaturas` WRITE;
/*!40000 ALTER TABLE `assinaturas` DISABLE KEYS */;
/*!40000 ALTER TABLE `assinaturas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campanhas`
--

DROP TABLE IF EXISTS `campanhas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `campanhas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `instancia_id` int DEFAULT NULL,
  `nome_campanha` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mensagem` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `caminho_midia` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pendente',
  `data_criacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_agendamento` datetime DEFAULT NULL,
  `delay_min` int NOT NULL DEFAULT '5' COMMENT 'Delay mínimo em segundos entre os envios',
  `delay_max` int NOT NULL DEFAULT '15' COMMENT 'Delay máximo em segundos entre os envios',
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  KEY `instancia_id` (`instancia_id`),
  CONSTRAINT `campanhas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `campanhas_ibfk_2` FOREIGN KEY (`instancia_id`) REFERENCES `instancias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campanhas`
--

LOCK TABLES `campanhas` WRITE;
/*!40000 ALTER TABLE `campanhas` DISABLE KEYS */;
/*!40000 ALTER TABLE `campanhas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `saldo_creditos_disparo` int DEFAULT '0',
  `saldo_creditos_maturacao` decimal(10,2) DEFAULT '0.00',
  `reset_token` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token_expires_at` datetime DEFAULT NULL,
  `data_cadastro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cpf` varchar(14) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `asaas_customer_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_asaas_customer_id` (`asaas_customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'teste','teste@teste.com','$2y$10$FPRYmkmrYisjkBhgptc9cOp8zyHbQJiEHgnpOWiSUCl.7RGIQYjge',50494,50000.00,NULL,NULL,'2025-06-26 10:37:40',NULL,NULL,NULL);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracoes_sistema`
--

DROP TABLE IF EXISTS `configuracoes_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracoes_sistema` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chave` varchar(100) NOT NULL,
  `valor` text,
  `descricao` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chave` (`chave`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracoes_sistema`
--

LOCK TABLES `configuracoes_sistema` WRITE;
/*!40000 ALTER TABLE `configuracoes_sistema` DISABLE KEYS */;
INSERT INTO `configuracoes_sistema` VALUES (1,'asaas_webhook_configured','0','Indica se o webhook do ASAAS foi configurado','2025-09-18 21:30:46'),(2,'taxa_processamento_pix','0.99','Taxa fixa para PIX em R$','2025-09-18 21:30:46'),(3,'taxa_processamento_boleto','3.49','Taxa fixa para boleto em R$','2025-09-18 21:30:46'),(4,'emails_notificacao_ativo','1','Ativa/desativa emails de notificação','2025-09-18 21:30:46');
/*!40000 ALTER TABLE `configuracoes_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conteudo_maturacao`
--

DROP TABLE IF EXISTS `conteudo_maturacao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conteudo_maturacao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo` enum('texto','imagem','audio','localizacao') COLLATE utf8mb4_unicode_ci NOT NULL,
  `conteudo` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Para texto: a mensagem. Para mídia: a URL.',
  `caption` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Legenda para mídias',
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `nome_local` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endereco` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1' COMMENT '0 = inativo, 1 = ativo',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1025 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conteudo_maturacao`
--

LOCK TABLES `conteudo_maturacao` WRITE;
/*!40000 ALTER TABLE `conteudo_maturacao` DISABLE KEYS */;
INSERT INTO `conteudo_maturacao` VALUES (551,'texto','Bom dia! Tudo certo por aí?',NULL,NULL,NULL,NULL,NULL,1),(552,'texto','Opa, e aí? Como vai?',NULL,NULL,NULL,NULL,NULL,1),(553,'texto','Que correria hoje, hein? ?',NULL,NULL,NULL,NULL,NULL,1),(554,'texto','Só passando pra dar um oi!',NULL,NULL,NULL,NULL,NULL,1),(555,'texto','Nossa, que calor!',NULL,NULL,NULL,NULL,NULL,1),(556,'texto','E as novidades?',NULL,NULL,NULL,NULL,NULL,1),(557,'texto','Espero que seu dia esteja sendo produtivo.',NULL,NULL,NULL,NULL,NULL,1),(558,'texto','Você viu aquele filme que comentei?',NULL,NULL,NULL,NULL,NULL,1),(559,'texto','Depois me conta o que achou.',NULL,NULL,NULL,NULL,NULL,1),(560,'texto','Qualquer coisa, me chama aqui.',NULL,NULL,NULL,NULL,NULL,1),(561,'texto','Boa tarde! ☀️',NULL,NULL,NULL,NULL,NULL,1),(562,'texto','Lembrei de uma coisa engraçada aqui haha',NULL,NULL,NULL,NULL,NULL,1),(563,'texto','Planejando algo para o fim de semana?',NULL,NULL,NULL,NULL,NULL,1),(564,'texto','Frio chegou com tudo por aqui.',NULL,NULL,NULL,NULL,NULL,1),(565,'texto','Precisamos combinar aquele café.',NULL,NULL,NULL,NULL,NULL,1),(566,'texto','Tudo tranquilo?',NULL,NULL,NULL,NULL,NULL,1),(567,'texto','Estou ouvindo uma música muito boa agora.',NULL,NULL,NULL,NULL,NULL,1),(568,'texto','Que trânsito pra chegar em casa hoje...',NULL,NULL,NULL,NULL,NULL,1),(569,'texto','Finalmente um pouco de chuva pra refrescar.',NULL,NULL,NULL,NULL,NULL,1),(570,'texto','Tenha uma ótima noite!',NULL,NULL,NULL,NULL,NULL,1),(571,'texto','Até amanhã!',NULL,NULL,NULL,NULL,NULL,1),(572,'texto','Se cuida.',NULL,NULL,NULL,NULL,NULL,1),(573,'texto','Abraços!',NULL,NULL,NULL,NULL,NULL,1),(574,'texto','Falou!',NULL,NULL,NULL,NULL,NULL,1),(575,'texto','Tamo junto!',NULL,NULL,NULL,NULL,NULL,1),(576,'texto','Bom dia, galera!',NULL,NULL,NULL,NULL,NULL,1),(577,'texto','Bom dia, galera!',NULL,NULL,NULL,NULL,NULL,1),(578,'texto','E aí, pessoal? Tudo certo?',NULL,NULL,NULL,NULL,NULL,1),(579,'texto','Partiu happy hour hoje?',NULL,NULL,NULL,NULL,NULL,1),(580,'texto','Quem anima um cinema no fds?',NULL,NULL,NULL,NULL,NULL,1),(581,'texto','Tô dentro!',NULL,NULL,NULL,NULL,NULL,1),(582,'texto','Comigo não rola hoje, galera. Malz!',NULL,NULL,NULL,NULL,NULL,1),(583,'texto','Kkkkkkkk só observo',NULL,NULL,NULL,NULL,NULL,1),(584,'texto','Vocês viram o que aconteceu?',NULL,NULL,NULL,NULL,NULL,1),(585,'texto','Me contem a fofoca!',NULL,NULL,NULL,NULL,NULL,1),(586,'texto','Manda o link aí, por favor',NULL,NULL,NULL,NULL,NULL,1),(587,'texto','Nossa, que notícia triste.',NULL,NULL,NULL,NULL,NULL,1),(588,'texto','Finalmente sexta-feira!',NULL,NULL,NULL,NULL,NULL,1),(589,'texto','Sextou com S de saudade do que a gente não viveu ainda kkkk',NULL,NULL,NULL,NULL,NULL,1),(590,'texto','Qual a boa pra hoje à noite?',NULL,NULL,NULL,NULL,NULL,1),(591,'texto','Tamo junto!',NULL,NULL,NULL,NULL,NULL,1),(592,'texto','Fechado então!',NULL,NULL,NULL,NULL,NULL,1),(593,'texto','Beleza, combinado.',NULL,NULL,NULL,NULL,NULL,1),(594,'texto','O trânsito tá impossível hoje.',NULL,NULL,NULL,NULL,NULL,1),(595,'texto','Alguém me busca?',NULL,NULL,NULL,NULL,NULL,1),(596,'texto','Chego em 10 minutos.',NULL,NULL,NULL,NULL,NULL,1),(597,'texto','Hahahahahaha morri',NULL,NULL,NULL,NULL,NULL,1),(598,'texto','Não acredito nisso!',NULL,NULL,NULL,NULL,NULL,1),(599,'texto','É sério isso?',NULL,NULL,NULL,NULL,NULL,1),(600,'texto','Pode crer.',NULL,NULL,NULL,NULL,NULL,1),(601,'texto','Concordo plenamente.',NULL,NULL,NULL,NULL,NULL,1),(602,'texto','Alguém indica uma série boa?',NULL,NULL,NULL,NULL,NULL,1),(603,'texto','Acabei de maratonar uma incrível!',NULL,NULL,NULL,NULL,NULL,1),(604,'texto','Já assisti essa, é top!',NULL,NULL,NULL,NULL,NULL,1),(605,'texto','Valeu pela dica!',NULL,NULL,NULL,NULL,NULL,1),(606,'texto','Bom almoço, pessoal!',NULL,NULL,NULL,NULL,NULL,1),(607,'texto','Que fome!',NULL,NULL,NULL,NULL,NULL,1),(608,'texto','Bora pedir um açaí?',NULL,NULL,NULL,NULL,NULL,1),(609,'texto','Opa, quero!',NULL,NULL,NULL,NULL,NULL,1),(610,'texto','Manda o pix que eu pago o meu.',NULL,NULL,NULL,NULL,NULL,1),(611,'texto','Galera, alguém tem um carregador de celular pra emprestar?',NULL,NULL,NULL,NULL,NULL,1),(612,'texto','O meu tá na bolsa, pode pegar.',NULL,NULL,NULL,NULL,NULL,1),(613,'texto','Valeu, mano!',NULL,NULL,NULL,NULL,NULL,1),(614,'texto','De nada!',NULL,NULL,NULL,NULL,NULL,1),(615,'texto','Boa noite, grupo!',NULL,NULL,NULL,NULL,NULL,1),(616,'texto','Sonhem com os anjos.',NULL,NULL,NULL,NULL,NULL,1),(617,'texto','Fui!',NULL,NULL,NULL,NULL,NULL,1),(618,'texto','Até amanhã.',NULL,NULL,NULL,NULL,NULL,1),(619,'texto','Gente, que calor é esse?',NULL,NULL,NULL,NULL,NULL,1),(620,'texto','Aqui tá chovendo canivete!',NULL,NULL,NULL,NULL,NULL,1),(621,'texto','A previsão do tempo errou de novo.',NULL,NULL,NULL,NULL,NULL,1),(622,'texto','Normal kkkk',NULL,NULL,NULL,NULL,NULL,1),(623,'texto','Alguém vai no jogo domingo?',NULL,NULL,NULL,NULL,NULL,1),(624,'texto','Com certeza estarei lá!',NULL,NULL,NULL,NULL,NULL,1),(625,'texto','Vamoooo!',NULL,NULL,NULL,NULL,NULL,1),(626,'texto','Quem mais vai?',NULL,NULL,NULL,NULL,NULL,1),(627,'texto','Ainda não sei, vou ver aqui.',NULL,NULL,NULL,NULL,NULL,1),(628,'texto','Me avisem pra gente ir junto.',NULL,NULL,NULL,NULL,NULL,1),(629,'texto','Fechou!',NULL,NULL,NULL,NULL,NULL,1),(630,'texto','Manda foto!',NULL,NULL,NULL,NULL,NULL,1),(631,'texto','Olha esse meme que eu recebi kkkkkk',NULL,NULL,NULL,NULL,NULL,1),(632,'texto','Muito bom hahahaha',NULL,NULL,NULL,NULL,NULL,1),(633,'texto','A cara do fulano kkkk',NULL,NULL,NULL,NULL,NULL,1),(634,'texto','Não espalha!',NULL,NULL,NULL,NULL,NULL,1),(635,'texto','Meu Deus, que vergonha alheia.',NULL,NULL,NULL,NULL,NULL,1),(636,'texto','Eu não digo é nada.',NULL,NULL,NULL,NULL,NULL,1),(637,'texto','Só li verdades.',NULL,NULL,NULL,NULL,NULL,1),(638,'texto','Assino embaixo.',NULL,NULL,NULL,NULL,NULL,1),(639,'texto','Preciso de férias urgente.',NULL,NULL,NULL,NULL,NULL,1),(640,'texto','Somos dois.',NULL,NULL,NULL,NULL,NULL,1),(641,'texto','Contando os dias...',NULL,NULL,NULL,NULL,NULL,1),(642,'texto','Falta muito ainda?',NULL,NULL,NULL,NULL,NULL,1),(643,'texto','Força, guerreiro(a)!',NULL,NULL,NULL,NULL,NULL,1),(644,'texto','Obrigado pelo apoio moral kkk',NULL,NULL,NULL,NULL,NULL,1),(645,'texto','Que dia é o aniversário de ciclano?',NULL,NULL,NULL,NULL,NULL,1),(646,'texto','Acho que é semana que vem.',NULL,NULL,NULL,NULL,NULL,1),(647,'texto','Vamos organizar uma festa surpresa?',NULL,NULL,NULL,NULL,NULL,1),(648,'texto','Apoio a ideia!',NULL,NULL,NULL,NULL,NULL,1),(649,'texto','Eu ajudo a organizar.',NULL,NULL,NULL,NULL,NULL,1),(650,'texto','Vamos falando no privado pra ele(a) não ver.',NULL,NULL,NULL,NULL,NULL,1),(651,'texto','Boa ideia!',NULL,NULL,NULL,NULL,NULL,1),(652,'texto','Gente, perdi meu guarda-chuva. Alguém viu?',NULL,NULL,NULL,NULL,NULL,1),(653,'texto','Acho que ficou no meu carro.',NULL,NULL,NULL,NULL,NULL,1),(654,'texto','Ufa, que alívio!',NULL,NULL,NULL,NULL,NULL,1),(655,'texto','Pego com você amanhã, ok?',NULL,NULL,NULL,NULL,NULL,1),(656,'texto','Tranquilo.',NULL,NULL,NULL,NULL,NULL,1),(657,'texto','Top!',NULL,NULL,NULL,NULL,NULL,1),(658,'texto','Show de bola!',NULL,NULL,NULL,NULL,NULL,1),(659,'texto','Massa!',NULL,NULL,NULL,NULL,NULL,1),(660,'texto','Daora!',NULL,NULL,NULL,NULL,NULL,1),(661,'texto','Que roubada...',NULL,NULL,NULL,NULL,NULL,1),(662,'texto','Se precisar de ajuda, é só chamar.',NULL,NULL,NULL,NULL,NULL,1),(663,'texto','Tamo na área!',NULL,NULL,NULL,NULL,NULL,1),(664,'texto','É nós!',NULL,NULL,NULL,NULL,NULL,1),(665,'texto','Saudades de vocês!',NULL,NULL,NULL,NULL,NULL,1),(666,'texto','Precisamos marcar de nos ver.',NULL,NULL,NULL,NULL,NULL,1),(667,'texto','Verdade, sumiram!',NULL,NULL,NULL,NULL,NULL,1),(668,'texto','A vida adulta é complicada.',NULL,NULL,NULL,NULL,NULL,1),(669,'texto','Nem me fale.',NULL,NULL,NULL,NULL,NULL,1),(670,'texto','Mas vamos dar um jeito!',NULL,NULL,NULL,NULL,NULL,1),(671,'texto','Com certeza!',NULL,NULL,NULL,NULL,NULL,1),(672,'texto','Alguém online?',NULL,NULL,NULL,NULL,NULL,1),(673,'texto','Opa, to aqui.',NULL,NULL,NULL,NULL,NULL,1),(674,'texto','Bora jogar?',NULL,NULL,NULL,NULL,NULL,1),(675,'texto','Chama!',NULL,NULL,NULL,NULL,NULL,1),(676,'texto','Entrando agora.',NULL,NULL,NULL,NULL,NULL,1),(677,'texto','Já tô no lobby.',NULL,NULL,NULL,NULL,NULL,1),(678,'texto','Ganhamos!',NULL,NULL,NULL,NULL,NULL,1),(679,'texto','Fácil demais kkkk',NULL,NULL,NULL,NULL,NULL,1),(680,'texto','Da próxima vez vai ser mais difícil.',NULL,NULL,NULL,NULL,NULL,1),(681,'texto','Duvido!',NULL,NULL,NULL,NULL,NULL,1),(682,'texto','Qual foi o placar?',NULL,NULL,NULL,NULL,NULL,1),(683,'texto','Pergunta pro freguês kkkk',NULL,NULL,NULL,NULL,NULL,1),(684,'texto','Hahahaha sem maldade.',NULL,NULL,NULL,NULL,NULL,1),(685,'texto','Zoeira never ends.',NULL,NULL,NULL,NULL,NULL,1),(686,'texto','Vocês não prestam!',NULL,NULL,NULL,NULL,NULL,1),(687,'texto','Amo esse grupo!',NULL,NULL,NULL,NULL,NULL,1),(688,'texto','Melhor grupo!',NULL,NULL,NULL,NULL,NULL,1),(689,'texto','Vocês são demais.',NULL,NULL,NULL,NULL,NULL,1),(690,'texto','Abraços!',NULL,NULL,NULL,NULL,NULL,1),(691,'texto','Beijos!',NULL,NULL,NULL,NULL,NULL,1),(692,'texto','Falou!',NULL,NULL,NULL,NULL,NULL,1),(693,'texto','Inté!',NULL,NULL,NULL,NULL,NULL,1),(694,'texto','Fui dormir.',NULL,NULL,NULL,NULL,NULL,1),(695,'texto','Acordei agora.',NULL,NULL,NULL,NULL,NULL,1),(696,'texto','Bom dia pra quem é de bom dia.',NULL,NULL,NULL,NULL,NULL,1),(697,'texto','O café tá pronto?',NULL,NULL,NULL,NULL,NULL,1),(698,'texto','Só se você fizer kkk',NULL,NULL,NULL,NULL,NULL,1),(699,'texto','Folgado!',NULL,NULL,NULL,NULL,NULL,1),(700,'texto','Já volto.',NULL,NULL,NULL,NULL,NULL,1),(701,'texto','Ok.',NULL,NULL,NULL,NULL,NULL,1),(702,'texto','Blz.',NULL,NULL,NULL,NULL,NULL,1),(703,'texto','Vlw.',NULL,NULL,NULL,NULL,NULL,1),(704,'texto','Flw.',NULL,NULL,NULL,NULL,NULL,1),(705,'imagem','https://picsum.photos/200/300?random=1',NULL,NULL,NULL,NULL,NULL,1),(706,'imagem','https://picsum.photos/200/300?random=2',NULL,NULL,NULL,NULL,NULL,1),(707,'imagem','https://picsum.photos/200/300?random=3',NULL,NULL,NULL,NULL,NULL,1),(708,'imagem','https://picsum.photos/200/300?random=4',NULL,NULL,NULL,NULL,NULL,1),(709,'imagem','https://picsum.photos/200/300?random=5',NULL,NULL,NULL,NULL,NULL,1),(710,'imagem','https://picsum.photos/200/300?random=6',NULL,NULL,NULL,NULL,NULL,1),(711,'imagem','https://picsum.photos/200/300?random=7',NULL,NULL,NULL,NULL,NULL,1),(712,'imagem','https://picsum.photos/200/300?random=8',NULL,NULL,NULL,NULL,NULL,1),(713,'imagem','https://picsum.photos/200/300?random=9',NULL,NULL,NULL,NULL,NULL,1),(714,'imagem','https://picsum.photos/200/300?random=10',NULL,NULL,NULL,NULL,NULL,1),(715,'imagem','https://picsum.photos/200/300?random=11',NULL,NULL,NULL,NULL,NULL,1),(716,'imagem','https://picsum.photos/200/300?random=12',NULL,NULL,NULL,NULL,NULL,1),(717,'imagem','https://picsum.photos/200/300?random=13',NULL,NULL,NULL,NULL,NULL,1),(718,'imagem','https://picsum.photos/200/300?random=14',NULL,NULL,NULL,NULL,NULL,1),(719,'imagem','https://picsum.photos/200/300?random=15',NULL,NULL,NULL,NULL,NULL,1),(720,'imagem','https://picsum.photos/200/300?random=16',NULL,NULL,NULL,NULL,NULL,1),(721,'imagem','https://picsum.photos/200/300?random=17',NULL,NULL,NULL,NULL,NULL,1),(722,'imagem','https://picsum.photos/200/300?random=18',NULL,NULL,NULL,NULL,NULL,1),(723,'imagem','https://picsum.photos/200/300?random=19',NULL,NULL,NULL,NULL,NULL,1),(724,'imagem','https://picsum.photos/200/300?random=20',NULL,NULL,NULL,NULL,NULL,1),(725,'imagem','https://picsum.photos/200/300?random=21',NULL,NULL,NULL,NULL,NULL,1),(726,'imagem','https://picsum.photos/200/300?random=22',NULL,NULL,NULL,NULL,NULL,1),(727,'imagem','https://picsum.photos/200/300?random=23',NULL,NULL,NULL,NULL,NULL,1),(728,'imagem','https://picsum.photos/200/300?random=24',NULL,NULL,NULL,NULL,NULL,1),(729,'imagem','https://picsum.photos/200/300?random=25',NULL,NULL,NULL,NULL,NULL,1),(730,'imagem','https://picsum.photos/200/300?random=26',NULL,NULL,NULL,NULL,NULL,1),(731,'imagem','https://picsum.photos/200/300?random=27',NULL,NULL,NULL,NULL,NULL,1),(732,'imagem','https://picsum.photos/200/300?random=28',NULL,NULL,NULL,NULL,NULL,1),(733,'imagem','https://picsum.photos/200/300?random=29',NULL,NULL,NULL,NULL,NULL,1),(734,'imagem','https://picsum.photos/200/300?random=30',NULL,NULL,NULL,NULL,NULL,1),(735,'imagem','https://picsum.photos/200/300?random=31',NULL,NULL,NULL,NULL,NULL,1),(736,'imagem','https://picsum.photos/200/300?random=32',NULL,NULL,NULL,NULL,NULL,1),(737,'imagem','https://picsum.photos/200/300?random=33',NULL,NULL,NULL,NULL,NULL,1),(738,'imagem','https://picsum.photos/200/300?random=34',NULL,NULL,NULL,NULL,NULL,1),(739,'imagem','https://picsum.photos/200/300?random=35',NULL,NULL,NULL,NULL,NULL,1),(740,'imagem','https://picsum.photos/200/300?random=36',NULL,NULL,NULL,NULL,NULL,1),(741,'imagem','https://picsum.photos/200/300?random=37',NULL,NULL,NULL,NULL,NULL,1),(742,'imagem','https://picsum.photos/200/300?random=38',NULL,NULL,NULL,NULL,NULL,1),(743,'imagem','https://picsum.photos/200/300?random=39',NULL,NULL,NULL,NULL,NULL,1),(744,'imagem','https://picsum.photos/200/300?random=40',NULL,NULL,NULL,NULL,NULL,1),(745,'imagem','https://picsum.photos/200/300?random=41',NULL,NULL,NULL,NULL,NULL,1),(746,'imagem','https://picsum.photos/200/300?random=42',NULL,NULL,NULL,NULL,NULL,1),(747,'imagem','https://picsum.photos/200/300?random=43',NULL,NULL,NULL,NULL,NULL,1),(748,'imagem','https://picsum.photos/200/300?random=44',NULL,NULL,NULL,NULL,NULL,1),(749,'imagem','https://picsum.photos/200/300?random=45',NULL,NULL,NULL,NULL,NULL,1),(750,'imagem','https://picsum.photos/200/300?random=46',NULL,NULL,NULL,NULL,NULL,1),(751,'imagem','https://picsum.photos/200/300?random=47',NULL,NULL,NULL,NULL,NULL,1),(752,'imagem','https://picsum.photos/200/300?random=48',NULL,NULL,NULL,NULL,NULL,1),(753,'imagem','https://picsum.photos/200/300?random=49',NULL,NULL,NULL,NULL,NULL,1),(754,'imagem','https://picsum.photos/200/300?random=50',NULL,NULL,NULL,NULL,NULL,1),(755,'imagem','https://picsum.photos/200/300?random=51',NULL,NULL,NULL,NULL,NULL,1),(756,'imagem','https://picsum.photos/200/300?random=52',NULL,NULL,NULL,NULL,NULL,1),(757,'imagem','https://picsum.photos/200/300?random=53',NULL,NULL,NULL,NULL,NULL,1),(758,'imagem','https://picsum.photos/200/300?random=54',NULL,NULL,NULL,NULL,NULL,1),(759,'imagem','https://picsum.photos/200/300?random=55',NULL,NULL,NULL,NULL,NULL,1),(760,'imagem','https://picsum.photos/200/300?random=56',NULL,NULL,NULL,NULL,NULL,1),(761,'imagem','https://picsum.photos/200/300?random=57',NULL,NULL,NULL,NULL,NULL,1),(762,'imagem','https://picsum.photos/200/300?random=58',NULL,NULL,NULL,NULL,NULL,1),(763,'imagem','https://picsum.photos/200/300?random=59',NULL,NULL,NULL,NULL,NULL,1),(764,'imagem','https://picsum.photos/200/300?random=60',NULL,NULL,NULL,NULL,NULL,1),(765,'imagem','https://picsum.photos/200/300?random=61',NULL,NULL,NULL,NULL,NULL,1),(766,'imagem','https://picsum.photos/200/300?random=62',NULL,NULL,NULL,NULL,NULL,1),(767,'imagem','https://picsum.photos/200/300?random=63',NULL,NULL,NULL,NULL,NULL,1),(768,'imagem','https://picsum.photos/200/300?random=64',NULL,NULL,NULL,NULL,NULL,1),(769,'imagem','https://picsum.photos/200/300?random=65',NULL,NULL,NULL,NULL,NULL,1),(770,'imagem','https://picsum.photos/200/300?random=66',NULL,NULL,NULL,NULL,NULL,1),(771,'imagem','https://picsum.photos/200/300?random=67',NULL,NULL,NULL,NULL,NULL,1),(772,'imagem','https://picsum.photos/200/300?random=68',NULL,NULL,NULL,NULL,NULL,1),(773,'imagem','https://picsum.photos/200/300?random=69',NULL,NULL,NULL,NULL,NULL,1),(774,'imagem','https://picsum.photos/200/300?random=70',NULL,NULL,NULL,NULL,NULL,1),(775,'imagem','https://picsum.photos/200/300?random=71',NULL,NULL,NULL,NULL,NULL,1),(776,'imagem','https://picsum.photos/200/300?random=72',NULL,NULL,NULL,NULL,NULL,1),(777,'imagem','https://picsum.photos/200/300?random=73',NULL,NULL,NULL,NULL,NULL,1),(778,'imagem','https://picsum.photos/200/300?random=74',NULL,NULL,NULL,NULL,NULL,1),(779,'imagem','https://picsum.photos/200/300?random=75',NULL,NULL,NULL,NULL,NULL,1),(780,'imagem','https://picsum.photos/200/300?random=76',NULL,NULL,NULL,NULL,NULL,1),(781,'imagem','https://picsum.photos/200/300?random=77',NULL,NULL,NULL,NULL,NULL,1),(782,'imagem','https://picsum.photos/200/300?random=78',NULL,NULL,NULL,NULL,NULL,1),(783,'imagem','https://picsum.photos/200/300?random=79',NULL,NULL,NULL,NULL,NULL,1),(784,'imagem','https://picsum.photos/200/300?random=80',NULL,NULL,NULL,NULL,NULL,1),(785,'imagem','https://picsum.photos/200/300?random=81',NULL,NULL,NULL,NULL,NULL,1),(786,'imagem','https://picsum.photos/200/300?random=82',NULL,NULL,NULL,NULL,NULL,1),(787,'imagem','https://picsum.photos/200/300?random=83',NULL,NULL,NULL,NULL,NULL,1),(788,'imagem','https://picsum.photos/200/300?random=84',NULL,NULL,NULL,NULL,NULL,1),(789,'imagem','https://picsum.photos/200/300?random=85',NULL,NULL,NULL,NULL,NULL,1),(790,'imagem','https://picsum.photos/200/300?random=86',NULL,NULL,NULL,NULL,NULL,1),(791,'imagem','https://picsum.photos/200/300?random=87',NULL,NULL,NULL,NULL,NULL,1),(792,'imagem','https://picsum.photos/200/300?random=88',NULL,NULL,NULL,NULL,NULL,1),(793,'imagem','https://picsum.photos/200/300?random=89',NULL,NULL,NULL,NULL,NULL,1),(794,'imagem','https://picsum.photos/200/300?random=90',NULL,NULL,NULL,NULL,NULL,1),(795,'imagem','https://picsum.photos/200/300?random=91',NULL,NULL,NULL,NULL,NULL,1),(796,'imagem','https://picsum.photos/200/300?random=92',NULL,NULL,NULL,NULL,NULL,1),(797,'imagem','https://picsum.photos/200/300?random=93',NULL,NULL,NULL,NULL,NULL,1),(798,'imagem','https://picsum.photos/200/300?random=94',NULL,NULL,NULL,NULL,NULL,1),(799,'imagem','https://picsum.photos/200/300?random=95',NULL,NULL,NULL,NULL,NULL,1),(800,'imagem','https://picsum.photos/200/300?random=96',NULL,NULL,NULL,NULL,NULL,1),(801,'imagem','https://picsum.photos/200/300?random=97',NULL,NULL,NULL,NULL,NULL,1),(802,'imagem','https://picsum.photos/200/300?random=98',NULL,NULL,NULL,NULL,NULL,1),(803,'imagem','https://picsum.photos/200/300?random=99',NULL,NULL,NULL,NULL,NULL,1),(804,'imagem','https://picsum.photos/200/300?random=100',NULL,NULL,NULL,NULL,NULL,1),(805,'imagem','https://picsum.photos/200/300?random=101',NULL,NULL,NULL,NULL,NULL,1),(806,'imagem','https://picsum.photos/200/300?random=102',NULL,NULL,NULL,NULL,NULL,1),(807,'imagem','https://picsum.photos/200/300?random=103',NULL,NULL,NULL,NULL,NULL,1),(808,'imagem','https://picsum.photos/200/300?random=104',NULL,NULL,NULL,NULL,NULL,1),(809,'imagem','https://picsum.photos/200/300?random=105',NULL,NULL,NULL,NULL,NULL,1),(810,'imagem','https://picsum.photos/200/300?random=106',NULL,NULL,NULL,NULL,NULL,1),(811,'imagem','https://picsum.photos/200/300?random=107',NULL,NULL,NULL,NULL,NULL,1),(812,'imagem','https://picsum.photos/200/300?random=108',NULL,NULL,NULL,NULL,NULL,1),(813,'imagem','https://picsum.photos/200/300?random=109',NULL,NULL,NULL,NULL,NULL,1),(814,'imagem','https://picsum.photos/200/300?random=110',NULL,NULL,NULL,NULL,NULL,1),(815,'imagem','https://picsum.photos/200/300?random=111',NULL,NULL,NULL,NULL,NULL,1),(816,'imagem','https://picsum.photos/200/300?random=112',NULL,NULL,NULL,NULL,NULL,1),(817,'imagem','https://picsum.photos/200/300?random=113',NULL,NULL,NULL,NULL,NULL,1),(818,'imagem','https://picsum.photos/200/300?random=114',NULL,NULL,NULL,NULL,NULL,1),(819,'imagem','https://picsum.photos/200/300?random=115',NULL,NULL,NULL,NULL,NULL,1),(820,'imagem','https://picsum.photos/200/300?random=116',NULL,NULL,NULL,NULL,NULL,1),(821,'imagem','https://picsum.photos/200/300?random=117',NULL,NULL,NULL,NULL,NULL,1),(822,'imagem','https://picsum.photos/200/300?random=118',NULL,NULL,NULL,NULL,NULL,1),(823,'imagem','https://picsum.photos/200/300?random=119',NULL,NULL,NULL,NULL,NULL,1),(824,'imagem','https://picsum.photos/200/300?random=120',NULL,NULL,NULL,NULL,NULL,1),(825,'imagem','https://picsum.photos/200/300?random=121',NULL,NULL,NULL,NULL,NULL,1),(826,'imagem','https://picsum.photos/200/300?random=122',NULL,NULL,NULL,NULL,NULL,1),(827,'imagem','https://picsum.photos/200/300?random=123',NULL,NULL,NULL,NULL,NULL,1),(828,'imagem','https://picsum.photos/200/300?random=124',NULL,NULL,NULL,NULL,NULL,1),(829,'imagem','https://picsum.photos/200/300?random=125',NULL,NULL,NULL,NULL,NULL,1),(830,'imagem','https://picsum.photos/200/300?random=126',NULL,NULL,NULL,NULL,NULL,1),(831,'imagem','https://picsum.photos/200/300?random=127',NULL,NULL,NULL,NULL,NULL,1),(832,'imagem','https://picsum.photos/200/300?random=128',NULL,NULL,NULL,NULL,NULL,1),(833,'imagem','https://picsum.photos/200/300?random=129',NULL,NULL,NULL,NULL,NULL,1),(834,'imagem','https://picsum.photos/200/300?random=130',NULL,NULL,NULL,NULL,NULL,1),(835,'imagem','https://picsum.photos/200/300?random=131',NULL,NULL,NULL,NULL,NULL,1),(836,'imagem','https://picsum.photos/200/300?random=132',NULL,NULL,NULL,NULL,NULL,1),(837,'imagem','https://picsum.photos/200/300?random=133',NULL,NULL,NULL,NULL,NULL,1),(838,'imagem','https://picsum.photos/200/300?random=134',NULL,NULL,NULL,NULL,NULL,1),(839,'imagem','https://picsum.photos/200/300?random=135',NULL,NULL,NULL,NULL,NULL,1),(840,'imagem','https://picsum.photos/200/300?random=136',NULL,NULL,NULL,NULL,NULL,1),(841,'imagem','https://picsum.photos/200/300?random=137',NULL,NULL,NULL,NULL,NULL,1),(842,'imagem','https://picsum.photos/200/300?random=138',NULL,NULL,NULL,NULL,NULL,1),(843,'imagem','https://picsum.photos/200/300?random=139',NULL,NULL,NULL,NULL,NULL,1),(844,'imagem','https://picsum.photos/200/300?random=140',NULL,NULL,NULL,NULL,NULL,1),(845,'imagem','https://picsum.photos/200/300?random=141',NULL,NULL,NULL,NULL,NULL,1),(846,'imagem','https://picsum.photos/200/300?random=142',NULL,NULL,NULL,NULL,NULL,1),(847,'imagem','https://picsum.photos/200/300?random=143',NULL,NULL,NULL,NULL,NULL,1),(848,'imagem','https://picsum.photos/200/300?random=144',NULL,NULL,NULL,NULL,NULL,1),(849,'imagem','https://picsum.photos/200/300?random=145',NULL,NULL,NULL,NULL,NULL,1),(850,'imagem','https://picsum.photos/200/300?random=146',NULL,NULL,NULL,NULL,NULL,1),(851,'imagem','https://picsum.photos/200/300?random=147',NULL,NULL,NULL,NULL,NULL,1),(852,'imagem','https://picsum.photos/200/300?random=148',NULL,NULL,NULL,NULL,NULL,1),(853,'imagem','https://picsum.photos/200/300?random=149',NULL,NULL,NULL,NULL,NULL,1),(854,'imagem','https://picsum.photos/200/300?random=150',NULL,NULL,NULL,NULL,NULL,1),(855,'localizacao','',NULL,-22.95190000,-43.21050000,'Cristo Redentor','Parque Nacional da Tijuca, Rio de Janeiro, RJ',1),(856,'localizacao','',NULL,-23.54650000,-46.63430000,'Mercado Municipal de São Paulo','R. da Cantareira, 306, São Paulo, SP',1),(857,'localizacao','',NULL,-12.97140000,-38.50140000,'Pelourinho','Centro Histórico, Salvador, BA',1),(858,'localizacao','',NULL,-8.06320000,-34.87070000,'Marco Zero','Praça Rio Branco, Recife, PE',1),(859,'localizacao','',NULL,-15.79980000,-47.86450000,'Congresso Nacional','Praça dos Três Poderes, Brasília, DF',1),(860,'localizacao','',NULL,-25.42840000,-49.27330000,'Jardim Botânico de Curitiba','R. Engo. Ostoja Roguski, Curitiba, PR',1),(861,'localizacao','',NULL,-3.10720000,-60.02580000,'Teatro Amazonas','Largo de São Sebastião, Manaus, AM',1),(862,'localizacao','',NULL,-22.90220000,-43.17840000,'Museu do Amanhã','Praça Mauá, 1, Rio de Janeiro, RJ',1),(863,'localizacao','',NULL,-23.55580000,-46.63960000,'MASP','Av. Paulista, 1578, São Paulo, SP',1),(864,'localizacao','',NULL,-30.03460000,-51.23000000,'Parque Farroupilha (Redenção)','Av. João Pessoa, Porto Alegre, RS',1),(865,'localizacao','',NULL,-2.53070000,-44.30680000,'Centro Histórico de São Luís','Praia Grande, São Luís, MA',1),(866,'localizacao','',NULL,-19.92450000,-43.93520000,'Praça da Liberdade','Bairro Funcionários, Belo Horizonte, MG',1),(867,'localizacao','',NULL,-27.59540000,-48.54800000,'Ponte Hercílio Luz','Centro, Florianópolis, SC',1),(868,'localizacao','',NULL,-20.31550000,-40.31280000,'Praia de Camburi','Av. Dante Michelini, Vitória, ES',1),(869,'localizacao','',NULL,-5.79450000,-35.21000000,'Ponte Newton Navarro','Santos Reis, Natal, RN',1),(870,'localizacao','',NULL,-3.73190000,-38.52670000,'Praia de Iracema','Av. Beira Mar, Fortaleza, CE',1),(871,'localizacao','',NULL,-1.45580000,-48.50360000,'Estação das Docas','Av. Boulevard Castilhos França, Belém, PA',1),(872,'localizacao','',NULL,-23.58690000,-46.65870000,'Parque Ibirapuera','Av. Pedro Álvares Cabral, São Paulo, SP',1),(873,'localizacao','',NULL,-16.67990000,-49.25500000,'Parque Vaca Brava','Av. T-10, Goiânia, GO',1),(874,'localizacao','',NULL,-22.97600000,-43.19460000,'Jardim Botânico do Rio de Janeiro','R. Jardim Botânico, 1008, Rio de Janeiro, RJ',1),(875,'localizacao','',NULL,-22.91000000,-43.20750000,'Estádio do Maracanã','Av. Pres. Castelo Branco, Rio de Janeiro, RJ',1),(876,'localizacao','',NULL,-12.98180000,-38.51470000,'Farol da Barra','Largo do Farol da Barra, Salvador, BA',1),(877,'localizacao','',NULL,-22.90640000,-43.12350000,'Museu de Arte Contemporânea de Niterói','Mirante da Boa Viagem, Niterói, RJ',1),(878,'localizacao','',NULL,-20.75330000,-42.87850000,'Universidade Federal de Viçosa','Av. Peter Henry Rolfs, Viçosa, MG',1),(879,'localizacao','',NULL,-2.53870000,-44.28220000,'Palácio dos Leões','Av. Dom Pedro II, São Luís, MA',1),(880,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(881,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(882,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(883,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(884,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(885,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(886,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(887,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(888,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(889,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(890,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(891,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(892,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(893,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(894,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(895,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(896,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(897,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(898,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(899,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(900,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(901,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(902,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(903,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(904,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(905,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(906,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(907,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(908,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(909,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(910,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(911,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(912,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(913,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(914,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(915,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(916,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(917,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(918,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(919,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(920,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(921,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(922,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(923,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(924,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(925,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(926,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(927,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(928,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(929,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(930,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(931,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(932,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(933,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(934,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(935,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(936,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(937,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(938,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(939,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(940,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(941,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(942,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(943,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(944,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(945,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(946,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(947,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(948,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(949,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(950,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(951,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(952,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(953,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(954,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(955,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(956,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(957,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(958,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(959,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(960,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(961,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(962,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(963,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(964,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(965,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(966,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(967,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(968,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(969,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(970,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(971,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(972,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(973,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(974,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(975,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(976,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(977,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(978,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(979,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(980,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(981,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(982,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(983,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(984,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(985,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(986,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(987,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(988,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(989,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(990,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(991,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(992,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(993,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(994,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(995,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(996,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(997,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(998,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(999,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(1000,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(1001,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(1002,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(1003,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(1004,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(1005,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1),(1006,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp3',NULL,NULL,NULL,NULL,NULL,1),(1007,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',NULL,NULL,NULL,NULL,NULL,1),(1008,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',NULL,NULL,NULL,NULL,NULL,1),(1009,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',NULL,NULL,NULL,NULL,NULL,1),(1010,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',NULL,NULL,NULL,NULL,NULL,1),(1011,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',NULL,NULL,NULL,NULL,NULL,1),(1012,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',NULL,NULL,NULL,NULL,NULL,1),(1013,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,NULL,NULL,NULL,NULL,1),(1014,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',NULL,NULL,NULL,NULL,NULL,1),(1015,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',NULL,NULL,NULL,NULL,NULL,1),(1016,'audio','https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',NULL,NULL,NULL,NULL,NULL,1),(1017,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',NULL,NULL,NULL,NULL,NULL,1),(1018,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',NULL,NULL,NULL,NULL,NULL,1),(1019,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',NULL,NULL,NULL,NULL,NULL,1),(1020,'audio','https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.ogg',NULL,NULL,NULL,NULL,NULL,1),(1021,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',NULL,NULL,NULL,NULL,NULL,1),(1022,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',NULL,NULL,NULL,NULL,NULL,1),(1023,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',NULL,NULL,NULL,NULL,NULL,1),(1024,'audio','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',NULL,NULL,NULL,NULL,NULL,1);
/*!40000 ALTER TABLE `conteudo_maturacao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fila_envio`
--

DROP TABLE IF EXISTS `fila_envio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fila_envio` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `campanha_id` int NOT NULL,
  `instancia_id` int DEFAULT NULL COMMENT 'ID da instância responsável por este envio específico',
  `numero_destino` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mensagem_personalizada` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pendente',
  `data_envio` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `campanha_id` (`campanha_id`),
  KEY `idx_instancia_id` (`instancia_id`),
  CONSTRAINT `fila_envio_ibfk_1` FOREIGN KEY (`campanha_id`) REFERENCES `campanhas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fila_envio`
--

LOCK TABLES `fila_envio` WRITE;
/*!40000 ALTER TABLE `fila_envio` DISABLE KEYS */;
/*!40000 ALTER TABLE `fila_envio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instancias`
--

DROP TABLE IF EXISTS `instancias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instancias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `plano_maturacao_id` int DEFAULT NULL,
  `nome_instancia` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `instance_name_api` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_telefone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Desconectado',
  `proxy_ativo` tinyint(1) NOT NULL DEFAULT '0',
  `data_criacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_fim_maturacao` datetime DEFAULT NULL,
  `maturacao_restante_secs` int DEFAULT NULL COMMENT 'Guarda o tempo restante da maturação em segundos quando pausado',
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  KEY `plano_maturacao_id` (`plano_maturacao_id`),
  CONSTRAINT `instancias_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instancias_ibfk_2` FOREIGN KEY (`plano_maturacao_id`) REFERENCES `planos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instancias`
--

LOCK TABLES `instancias` WRITE;
/*!40000 ALTER TABLE `instancias` DISABLE KEYS */;
INSERT INTO `instancias` VALUES (37,1,NULL,'teste2','teste2_68cc6ee75bd1a4.86589403','552734415852','Conectado',1,'2025-09-18 20:43:27',NULL,NULL);
/*!40000 ALTER TABLE `instancias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificacoes`
--

DROP TABLE IF EXISTS `notificacoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificacoes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `tipo` enum('payment_confirmed','payment_overdue','credits_added','system_alert') NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `mensagem` text NOT NULL,
  `lida` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cliente_lida` (`cliente_id`,`lida`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `notificacoes_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificacoes`
--

LOCK TABLES `notificacoes` WRITE;
/*!40000 ALTER TABLE `notificacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `notificacoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagamentos_detalhes`
--

DROP TABLE IF EXISTS `pagamentos_detalhes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagamentos_detalhes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transacao_id` int NOT NULL,
  `asaas_payment_id` varchar(255) NOT NULL,
  `status_anterior` varchar(50) DEFAULT NULL,
  `status_atual` varchar(50) NOT NULL,
  `valor_pago` decimal(10,2) DEFAULT NULL,
  `taxa_asaas` decimal(10,2) DEFAULT NULL,
  `valor_liquido` decimal(10,2) DEFAULT NULL,
  `data_evento` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `observacoes` text,
  PRIMARY KEY (`id`),
  KEY `idx_transacao` (`transacao_id`),
  KEY `idx_asaas_payment` (`asaas_payment_id`),
  KEY `idx_data_evento` (`data_evento`),
  CONSTRAINT `pagamentos_detalhes_ibfk_1` FOREIGN KEY (`transacao_id`) REFERENCES `transacoes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagamentos_detalhes`
--

LOCK TABLES `pagamentos_detalhes` WRITE;
/*!40000 ALTER TABLE `pagamentos_detalhes` DISABLE KEYS */;
/*!40000 ALTER TABLE `pagamentos_detalhes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planos`
--

DROP TABLE IF EXISTS `planos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `planos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci,
  `tipo` enum('disparo','maturacao') COLLATE utf8mb4_unicode_ci NOT NULL,
  `preco` decimal(10,2) NOT NULL,
  `creditos_disparo` int DEFAULT NULL COMMENT 'Créditos específicos para planos de disparo',
  `creditos` int DEFAULT '0',
  `duracao_dias` int DEFAULT NULL COMMENT 'Usado para planos de maturação',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planos`
--

LOCK TABLES `planos` WRITE;
/*!40000 ALTER TABLE `planos` DISABLE KEYS */;
INSERT INTO `planos` VALUES (1,'Fluxo Bronze','','maturacao',30.00,NULL,0,3,1),(2,'Fluxo Prata','','maturacao',70.00,NULL,0,7,1),(3,'Fluxo Ouro','','maturacao',150.00,NULL,0,15,1),(4,'Fluxo Diamante','','maturacao',300.00,NULL,0,30,1),(5,'Pacote Básico','Ideal para pequenas empresas','disparo',29.90,500,0,0,1),(6,'Pacote Profissional','Recomendado para médias empresas','disparo',79.90,1500,0,0,1),(7,'Pacote Premium','Para grandes volumes','disparo',149.90,3500,0,0,1),(8,'Pacote Empresarial','Volume máximo','disparo',299.90,8000,0,0,1),(9,'Maturação Básica','Aquecimento de 15 dias','maturacao',50.00,0,0,15,1),(10,'Maturação Padrão','Aquecimento de 30 dias','maturacao',90.00,0,0,30,1),(11,'Maturação Premium','Aquecimento de 60 dias','maturacao',150.00,0,0,60,1);
/*!40000 ALTER TABLE `planos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transacoes`
--

DROP TABLE IF EXISTS `transacoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transacoes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int NOT NULL,
  `plano_id` int DEFAULT NULL,
  `tipo_transacao` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `status_pagamento` enum('Pendente','Pago','Cancelado','Vencido','Processando','Estornado') COLLATE utf8mb4_unicode_ci DEFAULT 'Pendente',
  `data_transacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `asaas_payment_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `external_reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metodo_pagamento` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_vencimento` date DEFAULT NULL,
  `data_pagamento` timestamp NULL DEFAULT NULL,
  `creditos_quantidade` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`),
  KEY `plano_id` (`plano_id`),
  KEY `idx_asaas_payment_id` (`asaas_payment_id`),
  KEY `idx_external_reference` (`external_reference`),
  KEY `idx_status_pagamento` (`status_pagamento`),
  CONSTRAINT `transacoes_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transacoes_ibfk_2` FOREIGN KEY (`plano_id`) REFERENCES `planos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transacoes`
--

LOCK TABLES `transacoes` WRITE;
/*!40000 ALTER TABLE `transacoes` DISABLE KEYS */;
INSERT INTO `transacoes` VALUES (1,1,NULL,'compra_disparo',-3.00,'Pago','2025-06-26 18:45:26',NULL,NULL,NULL,NULL,NULL,NULL),(2,1,1,'compra_maturacao',-30.00,'Pago','2025-06-26 19:20:27',NULL,NULL,NULL,NULL,NULL,NULL),(3,1,1,'compra_maturacao',-30.00,'Pago','2025-06-26 19:23:13',NULL,NULL,NULL,NULL,NULL,NULL),(4,1,1,'compra_maturacao',-30.00,'Pago','2025-06-26 19:24:53',NULL,NULL,NULL,NULL,NULL,NULL),(5,1,NULL,'compra_disparo',-3.00,'Pago','2025-06-26 19:39:09',NULL,NULL,NULL,NULL,NULL,NULL),(6,1,1,'compra_maturacao',-30.00,'Pago','2025-07-01 16:02:47',NULL,NULL,NULL,NULL,NULL,NULL),(7,1,4,'compra_maturacao',-300.00,'Pago','2025-07-01 18:08:55',NULL,NULL,NULL,NULL,NULL,NULL),(8,1,4,'compra_maturacao',-300.00,'Pago','2025-07-01 18:20:25',NULL,NULL,NULL,NULL,NULL,NULL),(13,1,1,'compra_maturacao',-30.00,'Pago','2025-07-04 01:31:39',NULL,NULL,NULL,NULL,NULL,NULL),(14,1,1,'compra_maturacao',-30.00,'Pago','2025-07-04 01:35:53',NULL,NULL,NULL,NULL,NULL,NULL),(18,1,1,'compra_maturacao',-30.00,'Pago','2025-07-08 18:23:22',NULL,NULL,NULL,NULL,NULL,NULL),(19,1,4,'compra_maturacao',-300.00,'Pago','2025-07-14 12:54:53',NULL,NULL,NULL,NULL,NULL,NULL),(20,1,1,'compra_maturacao',-30.00,'Pago','2025-08-11 21:44:49',NULL,NULL,NULL,NULL,NULL,NULL),(24,1,1,'compra_maturacao',-30.00,'Pago','2025-08-26 13:38:14',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `transacoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook_logs`
--

DROP TABLE IF EXISTS `webhook_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider` varchar(50) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `payload` text NOT NULL,
  `processed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_event` (`provider`,`event_type`),
  KEY `idx_processed_at` (`processed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_logs`
--

LOCK TABLES `webhook_logs` WRITE;
/*!40000 ALTER TABLE `webhook_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook_logs` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-19  8:48:32
