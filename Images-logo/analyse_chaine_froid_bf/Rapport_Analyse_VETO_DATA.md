# Rapport d'Analyse de la Base de Données VETO_DATA

**Thèse de doctorat — DRABO FOGNANIE GLORIA**
**Thème :** Évaluation de la gestion de la chaîne de froid des vaccins à usage vétérinaire dans les structures publiques au Burkina Faso.

**Script analysé :** `veto_data_analyse.R`
**Outils utilisés :** R (`readxl`, `writexl`, `openxlsx`, `dplyr`, `clipr`, `epitools`), graphiques de base R (`barplot`, `pie`, `png`)

---

## 1. Objectif de l'analyse

Ce script prend le relais du script de nettoyage (`veto_data_colonne_uniformiser.xlsx` / `veto_data_corr_modalite_analyse.xlsx`) pour produire l'ensemble des **résultats descriptifs, croisés et inférentiels** de la thèse : tableaux de fréquences, tableaux croisés par poste/région, graphiques (camemberts et diagrammes en barres), scores de connaissances et de pratiques, puis tests statistiques (Chi², Odds Ratio, régression logistique). Il comprend **17 parties**, exportant systématiquement les résultats vers des classeurs Excel (`tableaux/`, `nouveaux_tableaux/`) et des images PNG.

---

## 2. Chargement des données

- Importation de la base nettoyée `veto_data_corr_modalite_analyse.xlsx` (issue du script de traitement).
- Répertoire de travail fixé sur le poste local de l'utilisatrice.

---

## 3. Partie I — Structures chargées de la gestion des vaccins

Tableau croisé **Niveau de la chaîne × Région** (avec marges), exporté dans `tableaux/structures.xlsx` (feuille « vaccin »). Cette étape dresse la cartographie des répondants selon leur position dans la chaîne de froid et leur région d'exercice.

---

## 4. Partie II — Caractéristiques socio-démographiques

Production de tableaux de fréquences (avec marges/totaux) exportés individuellement :

| Variable | Fichier |
|---|---|
| Genre | `tableau1.xlsx` |
| Poste / statut | `tableau2.xlsx` |
| Niveau d'éducation | `tableau3.xlsx` |
| Tranche d'âge | `tableau4.xlsx` |
| Expérience d'utilisation des vaccins | `tableau5_experience_vaccins.xlsx` |
| Formation sur la chaîne de froid | `tableau6_formation_vaccins.xlsx` |

Une tentative de fusion (`bind_rows`) des tableaux « genre » et « formation » est esquissée mais non exploitée par la suite.

---

## 5. Partie III — Approvisionnement et rôles des structures

- Tableau de fréquence de la structure principale d'approvisionnement (`tableau7_vaccin_approvisionnement.xlsx`).
- Tableau croisé **Niveau de la chaîne × Structure d'approvisionnement** (`tableau8_approvisionnement.xlsx`).
- **Reconstitution du rôle de chaque poste** : une boucle parcourt chaque répondant et concatène en texte libre les responsabilités actives (réception/stockage, distribution, suivi de température, administration, tenue de registres, autre responsabilité déclarée), stockées dans une table `poste_role`.
- Cette table est ensuite ventilée par poste-type (chef ZATE, chef SRSV, chef UATE, directeur provincial, chef SPSV) : une feuille Excel par poste recense la fréquence des combinaisons de rôles (`tableau10.xlsx`).

---

## 6. Partie IV — Calcul des taux de responsabilité par poste

Une fonction générique **`calcul_taux()`** a été créée : pour une variable binaire donnée et une liste de postes, elle calcule le nombre de répondants « actifs » (valeur = 1), le nombre « inactifs » et le total par poste. Elle est appliquée aux cinq responsabilités clés (réception/stockage, distribution, suivi de température, administration des vaccins, tenue de registres), avec export consolidé dans `tableau_taux.xlsx` (une feuille par responsabilité).

---

## 7. Partie V — Correction des provinces

Harmonisation orthographique des noms de provinces via un dictionnaire de correspondance (`recode()`) : *bougouiriba → bougouriba*, *kourritenga → kouritenga*, *sandbontenga/sandbondtenga → boulgou*, *sissilli → sissili*. La base corrigée est réexportée (`veto_data_corr_modalite_analyse.xlsx`), consolidant ainsi la version de référence utilisée pour le reste de l'analyse.

---

## 8. Partie VI — Taux d'utilisation des vaccins par poste

Application de `calcul_taux()` à chacune des maladies/vaccins ciblés par l'enquête (PPCB, PPR, charbon bactéridien, maladie de Newcastle, variole aviaire, rage, fièvre aphteuse, autre vaccin), avec consolidation dans `resultats_vaccins.xlsx` (une feuille par vaccin).

---

## 9. Partie VII — Matériel de stockage (conservation)

- **Analyse globale** : fréquences pour 8 équipements de conservation (réfrigérateur, thermomètre, alarme de température, source d'énergie de secours, boîtes de rangement, carnet de suivi, chambre froide, autre moyen) → `resultats_conservation.xlsx`.
- **Croisement avec le poste** via `calcul_taux()` → `resultats_conservation_taux.xlsx`.
- **Croisement Région × Poste** pour chaque équipement (comptages « possède / ne possède pas ») → `resultats_region_poste.xlsx`.

---

## 10. Partie VIII — Équipement des chaînes de froid (analyse la plus développée)

Cette partie combine de nombreux tableaux et **visualisations graphiques** (camemberts et diagrammes en barres, exportés en PNG haute résolution) :

- État global des équipements (camembert).
- Diagramme en barres du nombre de structures possédant chaque type de matériel.
- Détail par type de matériel (barplots individuels + tableaux Excel).
- Fonctionnalité des réfrigérateurs (camembert, en excluant la modalité « pas de refrigirateur »).
- Adéquation des réfrigérateurs à la source d'énergie locale (camembert + croisement Région/Poste).
- Suffisance de la capacité de stockage (camembert + croisement Région/Poste).
- Disponibilité des formulaires de commande/déclaration (camembert + croisement Région/Poste).
- Disponibilité de thermomètres fonctionnels (camembert + croisement Région/Poste).
- Source principale d'énergie utilisée (tableau croisé Région/Poste + barplot).
- Fréquence des arrêts du réfrigérateur (camembert + croisement Région/Poste).
- Causes principales des arrêts (gaz, électricité, pause de convenance, pétrole, autre) : tableaux croisés par région/poste et diagramme en barres comparatif.
- Fréquence hebdomadaire des coupures d'électricité (diagramme en barres).

---

## 11. Partie IX — Questions oui/non (environnement et sécurité du local)

Boucle générique sur 8 questions fermées (surveillance de la température au transport, propreté des équipements, sécurisation des locaux, étanchéité du toit, état du sol, alternatives de chaîne de froid, politique de renouvellement du matériel, connaissance du fonctionnement d'un réfrigérateur) : pour chacune, un tableau de fréquence et un tableau croisé par poste sont générés et exportés (`nouveaux_tableaux/`). Les exports graphiques (camemberts) sont présents dans le code mais **désactivés** (mis en commentaire).

Une analyse complémentaire distingue les répondants surveillant la température via un thermomètre de ceux utilisant une autre méthode.

---

## 12. Partie X — Matériel de transport des équipements

Même logique appliquée à 7 équipements de transport (glacières isothermes, packs réfrigérants, boîtes de protection, thermomètres portables, véhicules équipés, étiquettes/identifiants, autre moyen) : fréquences, camemberts, tableaux croisés par poste, et un diagramme en barres comparatif de synthèse.

---

## 13. Partie XI — Formation des agents

Boucle sur 6 questions relatives à la formation et aux connaissances de base (formation au monitorage de température, formation au fonctionnement d'un réfrigérateur, connaissance de la température de stockage recommandée, sensibilité des vaccins à la chaleur, réactivation après exposition à la chaleur, capacité à distinguer un flacon inactif sans analyse de laboratoire) : fréquences, camemberts, tableaux croisés par poste.

Analyse spécifique de la variable « température de stockage connue » (modalité normalisée `[2,8]` vs autres réponses) : comparaison globale et par poste, avec diagramme en barres.

---

## 14. Partie XII — Pratiques sur le terrain

Boucle sur **17 questions de pratiques** (vaccins expirés, test de secousse, principe premier expiré/premier sorti, dédicace du réfrigérateur aux vaccins, conformité des températures, séparation des vaccins par nature, système de relais en cas de panne, nettoyage du réfrigérateur, nettoyage des glacières, calendrier de remplacement, inventaire des équipements, vérification du niveau de gaz/pétrole, dégivrage, vérification des joints, présence d'un technicien dédié, description de tâches) : fréquences, camemberts, tableaux croisés par poste.

Analyses complémentaires : fréquence et périodicité de la maintenance, identité du responsable pendant les week-ends/vacances, autres difficultés rencontrées, et un croisement **Sexe × Niveau dans la chaîne × Expérience d'utilisation des vaccins**.

---

## 15. Partie XIII — Score de connaissances

- Importation d'un fichier dédié « connaissance compilés.xlsx ».
- Calcul d'un **score de connaissances** par sommation des réponses correctes : +1 point par réponse « oui » pour la majorité des items, mais logique **inversée** (+1 point pour « non ») sur les deux derniers items du questionnaire.
- Récapitulatif du nombre de répondants avec un score ≥ 5 vs ≤ 4, par poste (`scores_recap.xlsx`).

---

## 16. Partie XIV — Score de pratiques

- Importation d'un fichier dédié « pratiques compilés nettoyées.xlsx ».
- Calcul d'un **score de pratiques** par sommation des réponses « oui », à l'exception de deux items exclus du décompte (fuite du toit, vaccins expirés).
- Récapitulatif du nombre de répondants avec un score ≥ 17 vs ≤ 16, par poste (`scores_recap_pratiques.xlsx`).

---

## 17. Partie XV — Tests statistiques (Chi² et Odds Ratio)

- **Catégorisation des scores** de connaissances et de pratiques en trois classes (Bonne / Passable / Faible) par comparaison à la moyenne du score.
- **Tests du Chi²** entre le niveau dans la chaîne et la catégorie de connaissances, avec repli automatique sur une simulation de Monte Carlo en cas d'avertissement (effectifs faibles).
- Tests similaires entre l'expérience d'utilisation des vaccins / le poste et la catégorie de pratiques.
- **Croisement connaissances × pratiques** (tableau de contingence + Chi²).
- **Régression logistique** (`glm`, famille binomiale) pour estimer les **Odds Ratios** et leurs intervalles de confiance à 95 %, avec avertissement automatique en cas d'effectif nul dans une cellule du tableau croisé.

Tous les résultats textuels sont redirigés vers des fichiers `.txt` via `sink()` (`resultats_tests_connaissances.txt`, `resultats_tests_pratiques.txt`, `resultats_tests_pratiques_corriges.txt`).

---

## 18. Partie XVI — Analyse des pratiques (fichier unifié)

Reprise du calcul de score de pratiques sur un fichier unifié (`pratiques uniq vf.xlsx`), avec la même règle de sommation des « oui » (à l'exception des deux items déjà cités). Le résultat est classé en deux catégories (« bonnes pratiques » si score ≥ 16, sinon « mauvaises pratiques »), puis complété par des variables socio-démographiques importées depuis `df_var_Associe`. Des **tests du Chi² et Odds Ratio** sont ensuite exécutés pour chacune des variables associées (poste, sexe, tranche d'âge, expérience, formation, existence d'un protocole) face à cette évaluation, avec bascule automatique vers le test exact de Fisher pour les tableaux 2×2 en cas d'échec du Chi².

---

## 19. Partie XVII — Connaissances : association et tests du Chi²

- Import de deux fichiers : les scores de connaissances (`scores connaissances VF1.xlsx`) et les variables associées (`V. associés connaissances VF1.xlsx`).
- Classement en deux catégories (« satisfaisant » si score ≥ 5, sinon « non satisfaisant »).
- Génération de **tableaux croisés** pour chacune des variables du fichier contre l'évaluation des connaissances (`tableaux_croise_connaissances.txt`).
- **Tests du Chi² et Odds Ratio** (méthode de Wald) pour chaque variable, avec message d'avertissement explicite lorsque le tableau n'est pas de dimension 2×2 (OR non calculable).

---

## 20. Synthèse méthodologique

| Type d'analyse | Méthode / fonction | Sorties produites |
|---|---|---|
| Fréquences simples | `table()`, `addmargins()` | Tableaux Excel |
| Tableaux croisés | `group_by()` + `summarise()` | Feuilles Excel par variable |
| Taux par poste | Fonction maison `calcul_taux()` | `tableau_taux.xlsx` et équivalents |
| Visualisation univariée | `pie()`, `barplot()` | Fichiers PNG |
| Score composite | Boucles de sommation conditionnelle | Colonnes `Scores` / `Scores_cat` |
| Association bivariée | `chisq.test()`, `fisher.test()` | Fichiers `.txt` (via `sink()`) |
| Mesure d'association | `oddsratio()` (package `epitools`), `glm()` binomial | Tableaux d'OR avec IC 95 % |

---
