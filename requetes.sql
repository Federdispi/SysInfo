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

-- affichage des journalistes et du nombre d'articles qu'ils ont écrit
select nom, prenom, count(*) from Journaliste, Publication where Journaliste.idJournaliste = Publication.idJournaliste group by nom, prenom;

-- affichage des journalistes et du nombre d'articles qu'ils ont écrit par ordre décroissant
select nom, prenom, count(*) from Journaliste, Publication where Journaliste.idJournaliste = Publication.idJournaliste group by nom, prenom order by count(*) desc;

-- affichage des journalistes et du nombre d'articles dans la rubrique tech qu'ils ont écrit par ordre décroissant
select nom, prenom, count(*) from Journaliste, Publication, Article where Journaliste.idJournaliste = Publication.idJournaliste and Article.idArticle = Publication.idArticle and Article.rubrique = 'tech' group by nom, prenom order by count(*) desc;

-- suppression des articles de la rubrique tech du journaliste 10
delete from Article where idArticle in (select idArticle from Publication where idJournaliste = 10) and rubrique = 'tech';

-- affichage des journalistes qui ont écrit au moins 30 articles dans la rubrique tech par ordre décroissant
select nom, prenom, count(*) from Journaliste, Publication, Article where Journaliste.idJournaliste = Publication.idJournaliste and Article.idArticle = Publication.idArticle and Article.rubrique = 'tech' group by nom, prenom having count(*) >= 30 order by count(*) desc;

-- affichage des journalistes et du nombre d'articles qu'ils ont écrit pour chaque rubrique
select nom, prenom, rubrique, count(*) from Journaliste, Publication, Article where Journaliste.idJournaliste = Publication.idJournaliste and Article.idArticle = Publication.idArticle group by nom, prenom, rubrique order by nom, prenom, rubrique;

-- affichage des journalistes et du nombre d'articles qu'il a écrit à lui tout seul
select nom, prenom, count(*) from Journaliste, Publication where Journaliste.idJournaliste = Publication.idJournaliste group by nom, prenom having count(distinct idArticle);

-- affichage des titres des articles qui n'ont pas été écrits par un journaliste (on vérifie que chaque article a bien été écrit par un journaliste)
select titre from Article, Publication where Article.idArticle = Publication.idArticle and idJournaliste is null;

-- vue affichant les articles de la rubrique tech
CREATE VIEW IF NOT EXISTS articles_tech
AS
SELECT * 
FROM Article 
WHERE rubrique = 'tech';

-- affichage des 10 premières articles de la rubrique tech
SELECT * FROM articles_tech LIMIT 10;

-- affichage des journalistes qui ont écrit au moins un article de la rubrique tech (sans utiliser la vue, avec une sous-requête)
SELECT idJournaliste FROM Publication WHERE idArticle IN (SELECT idArticle FROM Article WHERE rubrique = 'tech');

-- affichage des journalistes qui ont écrit au moins un article de la rubrique tech (en utilisant la vue, avec une sous-requête)
SELECT idJournaliste FROM Publication WHERE idArticle IN (SELECT idArticle FROM articles_tech);

-- affichage des journalistes qui ont écrit au moins un article de la rubrique tech (en utilisant la vue, avec une jointure)
SELECT idJournaliste FROM Publication, articles_tech WHERE Publication.idArticle = articles_tech.idArticle;

-- table contenant le nombre d'articles par rubrique
CREATE TABLE IF NOT EXISTS nb_articles_par_rubrique AS
SELECT rubrique, count(*) as count
FROM Article 
GROUP BY rubrique;

-- trigger qui met à jour la table nb_articles_par_rubrique lorsqu'on insère
CREATE TRIGGER IF NOT EXISTS add_nb_articles_par_rubrique
AFTER INSERT ON Article
BEGIN
    UPDATE nb_articles_par_rubrique
    SET count = count + 1
    WHERE rubrique = NEW.rubrique;
END;

-- trigger qui met à jour la table nb_articles_par_rubrique lorsqu'on supprime
CREATE TRIGGER IF NOT EXISTS delete_nb_articles_par_rubrique
AFTER DELETE ON Article
BEGIN
    UPDATE nb_articles_par_rubrique
    SET count = count - 1
    WHERE rubrique = OLD.rubrique;
END;

-- trigger qui met à jour la table nb_articles_par_rubrique lorsqu'on met à jour
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

-- affichage de la table nb_articles_par_rubrique
SELECT * FROM nb_articles_par_rubrique;

-- trigger qui empêche la suppression d'un journaliste s'il a écrit au moins un article
CREATE TRIGGER IF NOT EXISTS delete_journaliste
BEFORE DELETE ON Journaliste
FOR EACH ROW
WHEN EXISTS (SELECT 1 FROM Publication WHERE idJournaliste = OLD.idJournaliste)
BEGIN
    SELECT RAISE(ABORT, 'Impossible de supprimer le journaliste car il a écrit au moins un article.');
END;