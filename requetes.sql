PRAGMA foreign_keys = ON;


DROP TABLE IF EXISTS Publication;
DROP TABLE IF EXISTS Article;
DROP TABLE IF EXISTS Journaliste;

CREATE TABLE Article
(
    idArticle INT PRIMARY KEY NOT NULL,
    titre TEXT NOT NULL,
    rubrique TEXT
);

CREATE TABLE Journaliste
(
    idJournaliste INT PRIMARY KEY NOT NULL,
    nom TEXT NOT NULL,
    prenom TEXT NOT NULL
);

CREATE TABLE Publication
(
    idArticle INT ,
    idJournaliste INT,
    PRIMARY KEY(idArticle, idJournaliste),
    FOREIGN KEY(idArticle)
        REFERENCES Article(idArticle)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY(idJournaliste)
        REFERENCES Journaliste(idJournaliste)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

.mode csv

.import articles.csv Article --csv
.import journalistes.csv Journaliste --csv
.import correspondance.csv Publication --csv


-- select nom, prenom, count(*) from Journaliste, Publication where Journaliste.idJournaliste = Publication.idJournaliste group by nom, prenom;

-- select nom, prenom, count(*) from Journaliste, Publication where Journaliste.idJournaliste = Publication.idJournaliste group by nom, prenom order by count(*) desc;

-- select nom, prenom, count(*) from Journaliste, Publication, Article where Journaliste.idJournaliste = Publication.idJournaliste and Article.idArticle = Publication.idArticle and Article.rubrique = 'tech' group by nom, prenom order by count(*) desc;

-- delete from Article where idArticle in (select idArticle from Publication where idJournaliste = 10) and rubrique = 'tech';

-- select nom, prenom, count(*) from Journaliste, Publication, Article where Journaliste.idJournaliste = Publication.idJournaliste and Article.idArticle = Publication.idArticle and Article.rubrique = 'tech' group by nom, prenom having count(*) >= 30 order by count(*) desc;

-- select nom, prenom, rubrique, count(*) from Journaliste, Publication, Article where Journaliste.idJournaliste = Publication.idJournaliste and Article.idArticle = Publication.idArticle group by nom, prenom, rubrique order by nom, prenom, rubrique;

-- select nom, prenom, count(*) from Journaliste, Publication where Journaliste.idJournaliste = Publication.idJournaliste group by nom, prenom having count(distinct idArticle);

-- select titre from Article, Publication where Article.idArticle = Publication.idArticle and idJournaliste is null;

CREATE VIEW IF NOT EXISTS articles_tech
AS
SELECT * 
FROM Article 
WHERE rubrique = 'tech';

-- SELECT * FROM articles_tech LIMIT 10;

-- SELECT idJournaliste FROM Publication WHERE idArticle IN (SELECT idArticle FROM Article WHERE rubrique = 'tech');

-- SELECT idJournaliste FROM Publication WHERE idArticle IN (SELECT idArticle FROM articles_tech);

-- SELECT idJournaliste FROM Publication, articles_tech WHERE Publication.idArticle = articles_tech.idArticle;

CREATE TABLE IF NOT EXISTS nb_articles_par_rubrique AS
SELECT rubrique, count(*) as count
FROM Article 
GROUP BY rubrique;


CREATE TRIGGER IF NOT EXISTS add_nb_articles_par_rubrique
AFTER INSERT ON Article
BEGIN
    UPDATE nb_articles_par_rubrique
    SET count = count + 1
    WHERE rubrique = NEW.rubrique;
END;

CREATE TRIGGER IF NOT EXISTS delete_nb_articles_par_rubrique
AFTER DELETE ON Article
BEGIN
    UPDATE nb_articles_par_rubrique
    SET count = count - 1
    WHERE rubrique = OLD.rubrique;
END;

CREATE TRIGGER IF NOT EXISTS update_nb_articles_par_rubrique
AFTER UPDATE ON Article
BEGIN
    UPDATE nb_articles_par_rubrique
    SET count = count - 1
    WHERE rubrique = OLD.rubrique;
    UPDATE nb_articles_par_rubrique
    SET count = count + 1
    WHERE rubrique = NEW.rubrique;
END;

-- SELECT * FROM nb_articles_par_rubrique;

CREATE TRIGGER IF NOT EXISTS delete_journaliste
BEFORE DELETE ON Journaliste
FOR EACH ROW
WHEN EXISTS (SELECT 1 FROM Publication WHERE idJournaliste = OLD.idJournaliste)
BEGIN
    SELECT RAISE(ABORT, 'Impossible de supprimer le journaliste car il a écrit au moins un article.');
END;