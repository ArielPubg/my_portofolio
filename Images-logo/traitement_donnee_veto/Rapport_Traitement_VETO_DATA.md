# Rapport de Traitement de la Base de Données VETO_DATA

**Thèse de doctorat — DRABO FOGNANIE GLORIA**
**Thème :** Évaluation de la gestion de la chaîne de froid des vaccins à usage vétérinaire dans les structures publiques au Burkina Faso.

**Outil utilisé :** R (packages `readxl`, `dplyr`, `stringi`, `writexl`, `tidyverse`)

---

## 1. Objectif du traitement

Le script vise à nettoyer, harmoniser et restructurer la base de données brute `veto_data2.xlsx`, issue d'une enquête de terrain, afin d'obtenir un jeu de données exploitable pour les analyses statistiques de la thèse. Le traitement se déroule en deux grandes parties :

1. **Apurement général des colonnes** (renommage, suppression des doublons, uniformisation des variables « Autre / Préciser »)
2. **Uniformisation des modalités** (harmonisation des réponses textuelles en catégories cohérentes)

---

## 2. Chargement des données

- Importation de la base brute via `read_excel()` à partir du fichier `veto_data2.xlsx`.
- Création d'une copie de travail (`veto_data_copie`) pour préserver les données originales.
- Nettoyage des noms de colonnes : suppression du préfixe technique situé avant le caractère `/` (résidu de l'export du formulaire de collecte, ex. Kobo/ODK).

---

## 3. Partie 1 — Apurement général des colonnes

### 3.1 Nettoyage textuel global
Une fonction `nettoyer_texte()` a été appliquée à toutes les colonnes de type texte, réalisant :
- la suppression des accents (translittération Latin → ASCII) ;
- la mise en minuscules systématique ;
- la suppression des espaces superflus en début/fin de chaîne.

Cette étape garantit une cohérence orthographique avant toute comparaison ou regroupement de modalités.

### 3.2 Uniformisation des colonnes « Autre / Préciser »
Plusieurs champs du questionnaire proposaient une modalité « Autre » avec une précision en texte libre. Ces informations ont été réintégrées dans les variables principales correspondantes, puis les colonnes de précision devenues inutiles ont été supprimées :

| Champ « Autre / Préciser » d'origine | Variable cible réintégrée |
|---|---|
| préciser si autre | poste occupé |
| Préciser si Autre | Niveau (modalité « cesa ») |
| si autre préciser | Structure principale d'approvisionnement |
| Préciser si Autre (2ᵉ occurrence) | Structures impliquées dans la gestion/distribution |
| préciser si Autre | renommée en `autre_responsabilite` |

### 3.3 Suppression des colonnes redondantes
Suppression des colonnes devenues obsolètes après réintégration des précisions, et renommage systématique des colonnes « Autre » restantes en variables explicites :

- `Vaccins utilisés` + précision → **autre_vaccin**
- `Espèces concernées` + précision → **autre_espece**
- `Matériels de stockage des vaccins` + précision → **autre_moyen_conservation**
- `Matériel de transport des vaccins` + précision → **autre_moyen_transport**
- `Source d'énergie` : la précision « Autre » a été réintégrée directement dans la variable principale
- `Causes d'arrêt du réfrigérateur` + précision → **autre_cause_arret**

Suppression également des colonnes binaires redondantes : `Disponible`, `Appliqué`, `Connu de tous les agents`.

### 3.4 Export intermédiaire
La base apurée est exportée sous le nom **`veto_data_colonne_uniformiser.xlsx`**, marquant la fin de la première partie du traitement.

---

## 4. Partie 2 — Uniformisation des modalités

### 4.1 Cohérence « Niveau de la chaîne » ↔ « Structure d'approvisionnement »
Correction des incohérences entre le niveau hiérarchique déclaré par le répondant et la structure d'approvisionnement mentionnée, selon la logique de la chaîne de froid vétérinaire :

- **Direction provinciale** → structure d'approvisionnement reclassée en *direction régionale*
- **ZATE** → structure d'approvisionnement reclassée en *direction provinciale*
- **SPSA** → niveau reclassé en *zate* ; structure reclassée en *direction provinciale*
- **UATE** → structure reclassée en *zate*

La colonne « Structures impliquées dans la gestion/distribution », jugée non pertinente pour l'analyse, a été supprimée.

### 4.2 Responsabilités des structures
Correction/complétion des variables binaires de responsabilité (`Administration des vaccins`, `Réception et stockage`, `Distribution vers le terrain`) en fonction du niveau de la chaîne :
- Les niveaux **zate** et **uate** se voient attribuer la responsabilité de l'administration des vaccins.
- Les niveaux **direction régionale** et **direction provinciale** se voient attribuer la responsabilité de la réception/stockage et de la distribution vers le terrain.

### 4.3 Moyens de conservation et de transport
- La variable « packs réfrigérants » est fixée à 1 pour tous les répondants (équipement jugé universel).
- Harmonisation de la modalité « moto de service » en « moto » dans `autre_moyen_transport`.

### 4.4 Plage de température
Une fonction personnalisée `extraire_plage_temp()` extrait automatiquement les valeurs numériques (avec signe) contenues dans les réponses en texte libre à la question sur la température recommandée, pour produire une plage standardisée au format `[min,max]`. Deux colonnes jugées non pertinentes ont ensuite été supprimées (congélation du vaccin, durée de conservation au niveau régional).

### 4.5 Cohérence thermomètre / réfrigérateur
Application d'une règle de cohérence logique : lorsque la structure ne dispose pas de thermomètre (`thermomètre == 0`), les questions relatives à son utilisation sont recodées en « pas de thermometre ». De même, lorsque la structure ne dispose pas de réfrigérateur (`réfrigérateur == 0`), les variables dépendantes (fonctionnalité, adaptation à la source d'énergie, fréquence des arrêts, nettoyage, usage exclusif) sont recodées en « pas de refrigirateur ».

### 4.6 Source d'énergie
Regroupement des multiples libellés en deux catégories principales :
- **« gaz »** : bouteille/gaz butane, électronique et gaz, frigo à gaz, etc.
- **« electricite »** : branchements informels, systèmes mixtes courant/électricité.

### 4.7 Causes d'arrêt du réfrigérateur
Recodage des précisions textuelles (`autre_cause_arret`) vers les variables binaires existantes :
- Motifs liés à l'absence de besoin en froid → **Pause de convenance**
- Motifs liés au délestage/coupures → **Électricité**

### 4.8 Classification du mode de transport
Une fonction `classer_transport()` basée sur la détection de mots-clés (expressions régulières) classe chaque réponse libre en catégories standardisées :
Aérien, Véhicule frigorifique, Mixte (terrestre), Moto, Véhicule/Transport commun, Glacière seule, Inconnu/Aucun, Autres/Non spécifié.

### 4.9 Classification de la surveillance du froid
Une fonction `classer_surveillance_froid()` regroupe les modes de contrôle du froid déclarés en quatre catégories : Thermomètre, Vérification visuelle (glace), Touche, Non spécifié.

Traitement complémentaire des valeurs manquantes (imputées en « je ne sais pas ») et des incohérences liées à l'absence de réfrigérateur (nettoyage, usage dédié). La colonne relative à l'existence de vaccins congelés a été supprimée.

### 4.10 Harmonisation de la fréquence de nettoyage
Une fonction générique `remplacer_modalite()` a été créée pour recoder par lot de longues listes de variantes textuelles en catégories unifiées : chaque jour, chaque semaine, 2 fois par semaine, chaque 2 semaines, chaque mois, 2 fois par mois, chaque 3 mois, chaque 6 mois, chaque 3 jours.

### 4.11 Harmonisation de la périodicité
Même logique appliquée à la variable de périodicité, avec un jeu de catégories plus riche tenant compte du contexte des campagnes de vaccination : Annuel, Trimestriel, Semestriel, Mensuel, Hebdomadaire, Quotidien, Sur demande hiérarchique, Passation de service, Au besoin/Si nécessaire, ainsi que trois catégories spécifiques aux campagnes (avant, après, avant et après chaque campagne).

*(Le script se poursuit au-delà du point où il a été fourni ; cette section documente le traitement jusqu'à la dernière instruction disponible.)*

---

## 5. Synthèse méthodologique

| Étape | Objectif | Fonctions/outils clés |
|---|---|---|
| Nettoyage textuel | Uniformiser accents, casse, espaces | `stri_trans_general`, `tolower`, `trimws` |
| Réintégration des « Autre » | Récupérer l'information des champs libres | Indexation conditionnelle, `is.na()` |
| Suppression des redondances | Alléger la base | `select(-c(...))` |
| Cohérence logique inter-variables | Garantir la validité interne des réponses | Recodage conditionnel |
| Extraction de plages numériques | Standardiser les températures | Expression régulière + `map_chr` |
| Classification par mots-clés | Réduire la variabilité des réponses libres | `case_when` + `str_detect` |
| Harmonisation par listes | Regrouper les variantes orthographiques d'une même modalité | Fonction générique `remplacer_modalite()` |

---
