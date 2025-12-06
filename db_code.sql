CREATE DATABASE travel;

CREATE TABLE Producatori (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nume VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    parola VARCHAR(255) NOT NULL,
    nrTelefon VARCHAR(20),
    descriere TEXT,
    latitudine DOUBLE NOT NULL,
    longitudine DOUBLE NOT NULL
);

CREATE TABLE Categorii (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tip VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE ProducatoriCategorii (
    idProducator INT NOT NULL,
    idCategorie INT NOT NULL,
    
    PRIMARY KEY (idProducator, idCategorie),

    FOREIGN KEY (idProducator) REFERENCES Producatori(id)
        ON DELETE CASCADE,
    FOREIGN KEY (idCategorie) REFERENCES Categorii(id)
        ON DELETE CASCADE
);

CREATE TABLE Utilizatori (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nume VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    parola VARCHAR(255) NOT NULL
);

INSERT INTO Categorii (tip) VALUES
('produse alimentare'),
('gastronomic'),
('atelier'),
('artizanal'),
('lavanda'),
('natura'),
('ferme'),
('experiente');

ALTER TABLE Producatori
ADD COLUMN image MEDIUMBLOB;

CREATE TABLE Produse (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idProducator INT NOT NULL,
    nume VARCHAR(100) NOT NULL,
    pret DOUBLE,
    
    FOREIGN KEY (idProducator) REFERENCES Producatori(id)
        ON DELETE CASCADE
);

CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON travel.* TO 'root'@'%';
FLUSH PRIVILEGES;

