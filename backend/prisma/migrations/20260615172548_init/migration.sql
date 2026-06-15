-- CreateTable
CREATE TABLE `config` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `chiave` VARCHAR(191) NOT NULL,
    `valore` TEXT NOT NULL,
    `descrizione` TEXT NULL,
    `aggiornatoIl` DATETIME(3) NOT NULL,

    UNIQUE INDEX `config_chiave_key`(`chiave`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `utenti_cache` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(191) NOT NULL,
    `nome` VARCHAR(191) NULL,
    `cognome` VARCHAR(191) NULL,
    `ruolo` ENUM('ADMIN', 'DOCENTE', 'STUDENTE', 'NON_AUTORIZZATO') NOT NULL,
    `ultimoAccesso` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `attivo` BOOLEAN NOT NULL DEFAULT true,

    UNIQUE INDEX `utenti_cache_email_key`(`email`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
