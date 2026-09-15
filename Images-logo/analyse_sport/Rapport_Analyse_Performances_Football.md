# Analyse des Performances des Clubs de Football Européens (2008–2016)

**Un projet de data analytics appliqué au football professionnel**

---

## 1. Objectif de l'étude

L'objectif de cette étude est d'analyser les performances des équipes de football européennes et d'en extraire les indicateurs clés de réussite sportive. Au-delà d'une simple description statistique, le projet cherche à identifier **quelles caractéristiques tactiques et stylistiques d'une équipe influencent réellement son nombre de points en fin de saison**, à l'aide de modèles économétriques de données de panel.

## 2. Source et description des données

Les données proviennent du jeu de données **"European Soccer Database"** disponible sur Kaggle, construit à partir de plusieurs sources :

- [football-data.mx-api.enetscores.com](http://football-data.mx-api.enetscores.com/) — scores, compositions d'équipe et événements de match
- [football-data.co.uk](http://www.football-data.co.uk/) — cotes de paris sportifs
- [sofifa.com](http://sofifa.com/) — attributs des joueurs et des équipes issus des jeux vidéo FIFA d'EA Sports

La base contient :

- Plus de **25 000 matchs**
- Plus de **10 000 joueurs**
- **11 championnats** européens de première division
- Les saisons **2008 à 2016**
- Les attributs des joueurs et des équipes (FIFA/EA Sports), mis à jour hebdomadairement
- La composition des équipes avec la formation tactique (coordonnées X, Y)
- Les cotes de paris de jusqu'à 10 bookmakers
- Les événements détaillés de plus de 10 000 matchs (buts, possession, corners, centres, fautes, cartons, etc.)

Techniquement, la base est fournie sous forme de fichier **SQLite**, interrogé directement en SQL depuis Python (tables `Match`, `Team`, `Team_Attributes`).

## 3. Méthodologie

Le projet se déroule en trois grandes étapes :

### 3.1 Préparation des données
- Extraction des tables `Match`, `Team` et `Team_Attributes` depuis la base SQLite.
- Filtrage temporel : conservation des matchs à partir du **22 février 2010**, date à partir de laquelle les attributs d'équipe (`Team_Attributes`) sont disponibles, afin de pouvoir croiser performances sportives et style de jeu.
- Construction d'une variable **saison** (ex : `2009-2010`) à partir de la date du match.
- Duplication de chaque match en deux lignes (perspective "domicile" et "extérieur") puis concaténation, afin de calculer, pour chaque équipe et chaque saison : victoires, nuls, défaites, buts marqués, buts encaissés.
- Calcul de la **différence de buts** et des **points** (3 pts / victoire, 1 pt / nul), selon le barème standard du football.
- Jointure avec la table `Team` pour récupérer les noms d'équipe, puis avec `Team_Attributes` pour associer à chaque équipe et chaque saison son profil tactique (vitesse de relance, pressing défensif, style de passes, etc.).
- Traitement des valeurs manquantes (imputation par la moyenne pour `buildUpPlayDribbling`).

### 3.2 Analyse exploratoire (statistiques descriptives)
- Identification des meilleures et des moins bonnes équipes par saison.
- Calcul du nombre de points moyen et de son écart-type par saison, afin d'évaluer le niveau de compétitivité des championnats au fil du temps.
- Visualisation de la distribution des points via un boxplot (quartiles Q1, médiane, Q3).
- Classement des équipes par moyenne de buts marqués et de buts encaissés sur l'ensemble de la période.
- Visualisation de la trajectoire de performance d'un club sur plusieurs saisons (fonction interactive permettant de choisir n'importe quelle équipe, illustrée ici avec le PSG).

### 3.3 Modélisation économétrique (données de panel)
Les données combinent une dimension **individuelle** (273 équipes) et une dimension **temporelle** (6 saisons), avec en moyenne ~4 observations par équipe — une structure typique de **panel non cylindré**. Cette configuration justifie l'usage de modèles économétriques de panel plutôt qu'une simple régression linéaire, afin de tenir compte de l'hétérogénéité non observée entre équipes.

Deux modèles ont été estimés avec la bibliothèque `linearmodels`, en expliquant les **points** par un ensemble de variables tactiques encodées (pressing défensif, style de centres, de passes, de relance, etc.) :

- **Modèle à effets fixes (Fixed Effects / Within)** : contrôle toute caractéristique constante et non observée propre à chaque équipe (qualité de l'effectif, culture de club, infrastructure…).
- **Modèle à effets aléatoires (Random Effects)** : suppose que ces caractéristiques individuelles sont non corrélées aux variables explicatives.

Le choix entre les deux a été tranché à l'aide du **test de Hausman**.

## 4. Résultats

### 4.1 Statistiques descriptives clés

| Indicateur | Valeur |
|---|---|
| Nombre d'observations (équipe × saison) | 1 082 |
| Nombre d'équipes distinctes | 273 |
| Points moyens par équipe et par saison | ~16 à 49 selon la saison |
| Écart-type des points par saison | ~8 à 21 |
| Buts marqués (moyenne, max sur la période) | jusqu'à ~100 buts/saison pour les meilleures équipes |

Les équipes les plus performantes sur la période incluent notamment le **Real Madrid CF** (100 points en 2011-2012), la **Juventus** (102 points en 2013-2014) et le **FC Barcelone**, illustrant la domination de quelques grands clubs sur leurs championnats respectifs. Le **Real Madrid** et le **FC Barcelone** dominent également le classement des meilleures attaques, avec près de 95 à 100 buts marqués par saison en moyenne.

L'écart-type des points par saison, compris entre 8 et 21, révèle une hétérogénéité croissante des championnats étudiés au fil du temps — signe d'une polarisation entre grands clubs et clubs plus modestes.

### 4.2 Modélisation : effets fixes vs effets aléatoires

| | Effets Fixes (FE) | Effets Aléatoires (RE) |
|---|---|---|
| R² (Within) | 0.389 | 0.352 |
| Observations | 1 082 | 1 082 |
| Entités (équipes) | 273 | 273 |
| F-statistique (p-value) | 26.45 (0.0000) | 18.89 (0.0000) |

Le modèle à effets fixes explique environ **39 %** de la variance intra-équipe des points par les variables tactiques retenues. Plusieurs variables ressortent comme significatives, notamment liées au **pressing** (`High_d`, `Contain_c`), à la **largeur du jeu** (`Narrow_b`, `Double_c`) et au **style de couverture défensive** (`Cover_a`, `Normal_b`), avec des effets parfois marqués (jusqu'à -15 points associés à certains styles de couverture par rapport à la référence).

### 4.3 Test de Hausman

Le test de Hausman, comparant les coefficients des deux modèles, donne :

- **Statistique** : 422.46
- **Degrés de liberté** : 19
- **P-value** : < 0.0001

Ce résultat rejette fortement l'hypothèse nulle (H0 : absence de corrélation entre les effets individuels et les régresseurs), indiquant que le **modèle à effets aléatoires est biaisé** dans ce contexte. Le **modèle à effets fixes est donc retenu** comme modèle de référence : il existe bien des caractéristiques propres à chaque club (qualité de l'effectif, budget, culture de jeu historique, etc.) corrélées avec leur style tactique, qu'il est indispensable de contrôler pour obtenir des estimations non biaisées.

## 5. Conclusion et limites

Cette étude montre que le style tactique d'une équipe — en particulier son approche du pressing et sa largeur de jeu défensive — est significativement associé à sa performance en championnat, même après avoir contrôlé pour l'hétérogénéité propre à chaque club via un modèle à effets fixes.

**Limites du projet :**
- Le modèle explique une part significative mais non totale de la variance des points (R² ≈ 0.39) : d'autres facteurs (qualité individuelle des joueurs, blessures, calendrier, arbitrage, effets d'entraîneur) ne sont pas captés directement.
- Les variables tactiques proviennent des jeux vidéo FIFA, une approximation du style réel des équipes qui peut comporter un biais de mesure.
- Le modèle à effets fixes, bien que privilégié par le test de Hausman, ne permet pas d'estimer l'effet de variables invariantes dans le temps (comme le pays ou la ligue).

**Pistes d'amélioration futures :**
- Intégrer des variables individuelles issues de la table `Player_Attributes` (qualité de l'effectif).
- Tester des modèles non linéaires (arbres, gradient boosting) pour capter des interactions plus complexes entre variables tactiques.
- Étendre l'analyse aux cotes de paris comme proxy du niveau perçu des équipes.

## 6. Outils et bibliothèques utilisés

- **Python** : `pandas`, `sqlite3` (extraction et manipulation des données)
- **Visualisation** : `matplotlib`, `seaborn`
- **Modélisation** : `statsmodels`, `scikit-learn`, `linearmodels` (`PanelOLS`, `RandomEffects`)
- **Statistiques** : `scipy.stats` (test de Hausman)
- **Source des données** : `kagglehub`

---

*Projet réalisé à des fins d'analyse de données sportives et de démonstration de compétences en économétrie des panels appliquée au football.*
