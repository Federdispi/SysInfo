class Noeud:
    def __init__(self, valeur1, valeur2=None):
        self.valeur1 = valeur1
        self.valeur2 = valeur2
        self.gauche = None
        self.centre = None
        self.droite = None

    def feuille(self):
        return self.gauche is None and self.centre is None and self.droite is None
    
    def has_value(self, valeur):
        valueIn = self.valeur1 == valeur or self.valeur2 == valeur
        if valueIn:
            return True
        else:
            if self.gauche is not None:
                valueIn = self.gauche.has_value(valeur)
            if self.centre is not None:
                valueIn = self.centre.has_value(valeur)
            if self.droite is not None:
                valueIn = self.droite.has_value(valeur)
            return valueIn

    def find_path(self, valeur):
        path = [self]
        if self.feuille():
            return path
        elif valeur < self.valeur1:
            path.extend(self.gauche.find_path(valeur))
        elif valeur > self.valeur2:
            path.extend(self.droite.find_path(valeur))
        elif valeur == self.valeur1 or valeur == self.valeur2:
            return path
        else:
            path.extend(self.centre.find_path(valeur))
        
    def __str__(self):
        return "(" + str(self.valeur1) + ", " + str(self.valeur2) + ")"

class Arbre:
    def __init__(self, noeud=None):
        self.racine = noeud

    def has_value(self, valeur):
        return self.racine.has_value(valeur)

    def insert(self, valeur, noeud=None):
        if self.racine is None:
            self.racine = Noeud(valeur)
        elif not self.has_value(valeur):
            path = self.racine.find_path(valeur)
            if noeud is None:
                noeud = path[-1]
            if noeud.valeur2 is None:
                if valeur < noeud.valeur1:
                    noeud.valeur2 = noeud.valeur1
                    noeud.valeur1 = valeur
                else:
                    noeud.valeur2 = valeur
            # elif noeud == self.racine:
            #     if valeur < noeud.valeur1:
            #         self.racine = Noeud(noeud.valeur1)
            #         self.racine.gauche = Noeud(valeur)
            #         self.racine.droite = Noeud(noeud.valeur2)
            #     elif valeur > noeud.valeur2:
            #         self.racine = Noeud(noeud.valeur2)
            #         self.racine.gauche = Noeud(noeud.valeur1)
            #         self.racine.droite = Noeud(valeur)
            #     else:
            #         self.racine = Noeud(valeur)
            #         self.racine.gauche = Noeud(noeud.valeur1)
            #         self.racine.droite = Noeud(noeud.valeur2)
            #         self.racine.gauche.gauche = noeud.gauche
            #         self.racine.gauche.droite = noeud.centre
            # else:
            #     if valeur < noeud.valeur1:
            #         self.insert(noeud.valeur1, path[path.index(noeud) - 1])
            #         noeud.valeur1 = valeur
            #     elif valeur > noeud.valeur2:
            #         self.insert(noeud.valeur2, path[path.index(noeud) - 1])
            #         noeud.valeur2 = valeur
            #     else:
            #         self.insert(valeur, path[path.index(noeud) - 1])
            elif noeud == path[-2].gauche:
                if valeur < noeud.valeur1:
                    path[-2].gauche = Noeud(valeur)
                    path[-2].centre = Noeud(noeud.valeur2)
                    self.insert(noeud.valeur1, path[-2])
                elif valeur > noeud.valeur2:
                    path[-2].gauche = Noeud(noeud.valeur1)
                    path[-2].centre = Noeud(valeur)
                    self.insert(noeud.valeur2, path[-2])
                else:
                    path[-2].gauche = Noeud(noeud.valeur1)
                    path[-2].centre = Noeud(noeud.valeur2)
                    self.insert(valeur, path[-2])
                path[-2].gauche.gauche = noeud.gauche
                path[-2].gauche.droite = noeud.droite

            elif noeud == path[-2].droite:
                if valeur < noeud.valeur1:
                    path[-2].centre = Noeud(valeur)
                    path[-2].droite = Noeud(noeud.valeur2)
                    self.insert(noeud.valeur1, path[-2])
                elif valeur > noeud.valeur2:
                    path[-2].centre = Noeud(noeud.valeur1)
                    path[-2].droite = Noeud(valeur)
                    self.insert(noeud.valeur2, path[-2])
                else:
                    if valeur < path[-2].valeur1:
                        if path[-2] == path[-3].gauche:
                            path[-3].gauche = Noeud(path[-2].valeur1)
                            path[-3].centre = Noeud(path[-2].valeur2)
                            self.insert(valeur, path[-3])
                        else:
                            path[-3].centre = Noeud(path[-2].valeur1)
                            path[-3].droite = Noeud(path[-2].valeur2)
                            self.insert(valeur, path[-3])
                    elif valeur > path[-2].valeur2:
                        if path[-2] == path[-3].gauche:
                            path[-3].gauche = Noeud(path[-2].valeur1)
                            path[-3].centre = Noeud(path[-2].valeur2)
                            self.insert(valeur, path[-3])
                        else:
                            path[-3].centre = Noeud(path[-2].valeur1)
                            path[-3].droite = Noeud(path[-2].valeur2)
                            self.insert(valeur, path[-3])
                    else:
                        if path[-2] == path[-3].droite:
                            path[-3].centre = Noeud(path[-2].valeur1)
                            path[-3].droite = Noeud(path[-2].valeur2)
                            self.insert(valeur, path[-3])
                        else:
                            path[-3].centre = Noeud(path[-2].valeur1)
                            path[-3].droite = Noeud(path[-2].valeur2)
                            self.insert(valeur, path[-3])
                path[-2].gauche.gauche = noeud.gauche
                path[-2].gauche.droite = noeud.droite
            elif noeud == path[-2].centre:
                if valeur < noeud.valeur1:
                    path[-2].centre = Noeud(valeur)
                    path[-2].droite = Noeud(noeud.valeur2)
                    self.insert(noeud.valeur1, path[-2])
                elif valeur > noeud.valeur2:
                    path[-2].centre = Noeud(noeud.valeur1)
                    path[-2].droite = Noeud(valeur)
                    self.insert(noeud.valeur2, path[-2])
                else:
                    path[-2].centre = Noeud(noeud.valeur1)
                    path[-2].droite = Noeud(noeud.valeur2)
                    self.insert(valeur, path[-2])
                path[-2].gauche.gauche = noeud.gauche
                path[-2].gauche.droite = noeud.droite
    
    def find_value(self, valeur):
        if self.has_value(valeur):
            path = self.racine.find_path(valeur)
            for noeud in path:
                print(noeud)
        else:
            print("La valeur n'est pas dans l'arbre")


# Main
arbre = Arbre()

arbre.insert(5)
arbre.insert(3)
arbre.insert(7)
arbre.insert(2)
arbre.insert(4)
arbre.insert(6)
arbre.insert(8)
arbre.insert(1)
arbre.insert(9)
arbre.insert(10)
arbre.insert(11)
arbre.insert(12)
arbre.insert(13)
arbre.insert(14)
arbre.insert(15)
arbre.insert(16)
arbre.insert(17)
arbre.insert(18)
arbre.insert(19)
arbre.insert(20)

arbre.find_value(20)