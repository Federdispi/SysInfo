import sqlite3

con = sqlite3.connect('tp.db')

cur = con.cursor()

res = cur.execute('SELECT * FROM nb_articles_par_rubrique')
print(res.fetchall())

#cur.execute('INSERT INTO Journaliste VALUES (16, "Secouille", "Lucas")')
#con.commit()

res = cur.execute('SELECT * FROM Journaliste')
print(res.fetchall())

def info_journaliste(nom, prenom):
    result = prenom + " " + nom
    return result

con.create_function("info_journaliste", 2, info_journaliste)

for row in con.execute('SELECT info_journaliste(nom, prenom) FROM Journaliste'):
    print(row[0])

def info_journaliste(id):
    res = con.execute('SELECT info_journaliste(nom, prenom) FROM Journaliste WHERE idJournaliste = ?', (id,))
    print(res.fetchone()[0])

info_journaliste(16)

class LongestString:
    def __init__(self):
        self.longest = ''

    def step(self, value):
        if len(value) > len(self.longest):
            self.longest = value

    def finalize(self):
        return self.longest
    
con.create_aggregate("longest_string", 1, LongestString)

res = cur.execute("SELECT longest_string(info_journaliste(nom, prenom)) FROM Journaliste")
print(res.fetchone()[0])

def longestNameLength():
    res = cur.execute("SELECT longest_string(info_journaliste(nom, prenom)) FROM Journaliste")
    return len(res.fetchone()[0])

print(longestNameLength())

class MainRubric:
    def __init__(self):
        self.mainRubric = ''
        self.countRubric = 0

    def step(self, rubric, countRubric):
        if countRubric > self.countRubric:
            self.mainRubric = rubric
            self.countRubric = countRubric

    def finalize(self):
        return self.mainRubric

con.create_aggregate("main_rubric", 2, MainRubric)

def rubriquePrincipale(id):
    cur.execute('DROP TABLE IF EXISTS rubricCount')
    cur.execute('CREATE TABLE IF NOT EXISTS rubricCount AS SELECT rubrique, count(*) as countRubric FROM Article, Publication WHERE Publication.idJournaliste = ? AND Publication.idArticle = Article.idArticle GROUP BY rubrique', (id,))
    res = cur.execute('SELECT main_rubric(rubrique, countRubric) FROM rubricCount')
    return res.fetchone()[0]

print(rubriquePrincipale(8))
