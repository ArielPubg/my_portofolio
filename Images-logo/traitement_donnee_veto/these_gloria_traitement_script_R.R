#==============================================================================#
#  SCRIPT DE TRAITEMENT — BASE DE DONNÉES VETO_DATA
#  Thèse DRABO FOGNANIE GLORIA — Doctorat 
#  Thème :  Évaluation de la gestion de la chaîne de froid des vaccins 
#           à usage vétérinaire dans les structures publiques au Burkina Faso. 
#==============================================================================#

#------------------------------------------------------------------------------#
#  1. CHARGEMENT DES BIBLIOTHÈQUES
#------------------------------------------------------------------------------#
library(readxl)
library(dplyr)
library(stringi)
library(writexl)

#------------------------------------------------------------------------------#
#  2. CHARGEMENT DE LA BASE DE DONNÉES
#------------------------------------------------------------------------------#
veto_data <- read_excel("C:\\Users\\pc\\these_Gloria\\veto_data2.xlsx")
View(veto_data)

veto_data_copie <- veto_data

# Renommage des colonnes (suppression du préfixe avant « / »)
colnames(veto_data_copie) <- gsub(".*/", "", colnames(veto_data_copie))
colnames(veto_data_copie)
View(veto_data_copie)

options(max.print = 10000)
str(veto_data_copie)


#==============================================================================#
#  PARTIE 1 — APUREMENT GÉNÉRAL DES COLONNES
#==============================================================================#

#------------------------------------------------------------------------------#
#  3.1 Nettoyage textuel global
#------------------------------------------------------------------------------#
nettoyer_texte <- function(vecteur) {
  # 1. Supprimer les accents (é -> e)
  x <- stri_trans_general(vecteur, "Latin-ASCII")

  # 2. Tout mettre en minuscules
  x <- tolower(x)

  # 3. Supprimer les espaces en double ou en début/fin de texte
  x <- trimws(x)

  return(x)
}

for (valeur in colnames(veto_data_copie)) {
  if (is.character(veto_data_copie[[valeur]])) {
    veto_data_copie[[valeur]] <- nettoyer_texte(veto_data_copie[[valeur]])
  } else {
    print("Non textuelle")
    print(valeur)
  }
}

# Nouveau dataset
head(veto_data_copie)

#------------------------------------------------------------------------------#
#  3.2 Uniformisation des colonnes « Autre / Préciser »
#------------------------------------------------------------------------------#

# --- 3.2.1 Colonne `préciser si autre` → variable `poste` ---
poste <- veto_data_copie[!is.na(veto_data_copie$`préciser si autre`), ]
View(poste)

index <- which(colnames(veto_data_copie) == 'préciser si autre')[1]
index
veto_data_copie <- veto_data_copie[, -index]
View(veto_data_copie)

options(width = 200)

# --- 3.2.2 Colonne `Préciser si Autre` → niveau `cesa` ---
niveau <- veto_data_copie[!is.na(veto_data_copie$`Préciser si Autre`), ]
View(niveau)

veto_data_copie[!is.na(veto_data_copie$`Préciser si Autre`), ]$Niveau = 'cesa'
niveau$Niveau = 'cesa'

index <- which(colnames(veto_data_copie) == 'Préciser si Autre')[1]
veto_data_copie <- veto_data_copie[, -index]
niveau <- niveau[, index]

View(niveau)
View(veto_data_copie)

# --- 3.2.3 Colonne `si autre préciser` → structure d'approvisionnement ---
structure <- veto_data_copie[!is.na(veto_data_copie$`si autre préciser`), ]$`si autre préciser`

veto_data_copie[!is.na(veto_data_copie$`si autre préciser`), ]$
  `Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` <- structure

View(structure)

index <- which(colnames(veto_data_copie) == 'si autre préciser')[1]
veto_data_copie <- veto_data_copie[, -index]
View(veto_data_copie)

# --- 3.2.4 Colonne `Préciser si Autre` → structures impliquées ---
View(veto_data_copie[!is.na(veto_data_copie$`Préciser si Autre`), ])

veto_data_copie[!is.na(veto_data_copie$`Préciser si Autre`), ]$
  `Quelles sont les structures impliquées dans la gestion et la distribution des vaccins vétérinaires dans votre localité ?` <-
  veto_data_copie[!is.na(veto_data_copie$`Préciser si Autre`), ]$`Préciser si Autre`

index <- which(colnames(veto_data_copie) == 'Préciser si Autre')[1]
veto_data_copie <- veto_data_copie[, -index]
View(veto_data_copie)

# --- 3.2.5 Autres colonnes « à préciser » ---
index <- which(colnames(veto_data_copie) == 'Quelles sont les responsabilités spécifiques de votre structure en matière de gestion des vaccins ?')
veto_data_copie <- veto_data_copie[, -index]
View(veto_data_copie)

index <- which(colnames(veto_data_copie) == 'Autre (à préciser)')[1]
veto_data_copie <- veto_data_copie[, -index]
View(veto_data_copie)

index <- which(colnames(veto_data_copie) == 'préciser si Autre')[1]
colnames(veto_data_copie)[index] = 'autre_responsabilite'
View(colnames(veto_data_copie)[index])
View(veto_data_copie)

#------------------------------------------------------------------------------#
#  3.3 Suppression des colonnes redondantes
#------------------------------------------------------------------------------#
colnames(veto_data_copie) <- make.unique(colnames(veto_data_copie))
veto_data_copie <- veto_data_copie %>% select(-c('Disponible', 'Appliqué', 'Connu de tous les agents'))
View(veto_data_copie)

# Vaccins utilisés + Autre (à préciser) → renommage « autre_vaccin »
veto_data_copie <- veto_data_copie %>% select(-c('Vaccins utilisés', 'Autre (à préciser)'))
veto_data_copie <- veto_data_copie %>% rename("autre_vaccin" = `Si autre préciser`)
View(veto_data_copie)

# Espèces concernées + autre (à préciser) → renommage « autre_espece »
veto_data_copie <- veto_data_copie %>% select(-c('Espèces concernées ?', 'autre (à préciser)'))
View(veto_data_copie)
veto_data_copie <- veto_data_copie %>% rename("autre_espece" = `préciser si autre`)
View(veto_data_copie)

# Matériels de stockage → renommage « autre_moyen_conservation »
veto_data_copie <- veto_data_copie %>% select(-c(` Matériels de stockage des vaccins`, `autre (à préciser).1`))
veto_data_copie <- veto_data_copie %>% rename("autre_moyen_conservation" = `préciser si autre...59`)
View(veto_data_copie)

# Matériel de transport → renommage « autre_moyen_transport »
veto_data_copie <- veto_data_copie %>% select(-c(`Matériel de transport des vaccins`, `autre (à préciser).2`))
veto_data_copie <- veto_data_copie %>% rename("autre_moyen_transport" = `préciser si autre...68`)
View(veto_data_copie)

# Source d'énergie : imputation de la colonne Autre
View(veto_data_copie[!is.na(veto_data_copie$Autre), ])
veto_data_copie[!is.na(veto_data_copie$Autre), ]$`Quelle est la source principale d’énergie utilisée ?` <-
  veto_data_copie[!is.na(veto_data_copie$Autre), ]$Autre
veto_data_copie <- veto_data_copie %>% select(-c('Autre'))
View(veto_data_copie)

# Causes d'arrêt → renommage « autre_cause_arret »
veto_data_copie <- veto_data_copie %>% select(-c('Quelles sont les causes principales de ces arrêts ?', 'Autre (à préciser).1'))
veto_data_copie <- veto_data_copie %>% rename("autre_cause_arret" = `Autre, préciser`)
View(veto_data_copie)

#------------------------------------------------------------------------------#
#  3.4 Export intermédiaire
#------------------------------------------------------------------------------#
getwd()
setwd("C:\\Users\\pc\\these_Gloria")  # répertoire de travail à modifier
write_xlsx(veto_data_copie, "veto_data_colonne_uniformiser.xlsx")

# ---- Fin de la 1ʳᵉ partie : apurement général des colonnes ----


#==============================================================================#
#  PARTIE 2 — UNIFORMISATION DES MODALITÉS
#==============================================================================#

veto_data_corr_modalite <- veto_data_copie

#------------------------------------------------------------------------------#
#  4.1 Cohérence « Niveau chaîne » ↔ « Structure approvisionnement »
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?`)

# --- Direction régionale (déjà uniformisé) ---
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction regionale', ])

# --- Direction provinciale (déjà uniformisé) ---
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction provinciale', ])
veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction provinciale', ]$
  `Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` = 'direction regionale'
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction provinciale', ])

# --- ZATE (déjà uniformisé) ---
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'zate', ])
veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'zate', ]$
  `Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` = 'direction provinciale'
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'zate', ])

# --- SPSA ---
View(veto_data_corr_modalite[veto_data_corr_modalite$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` == 'spsa', ])
veto_data_corr_modalite[veto_data_corr_modalite$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` == 'spsa', ]$
  `A quel niveau de la chaîne vous trouvez vous?` = 'zate'
veto_data_corr_modalite[veto_data_corr_modalite$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` == 'spsa', ]$
  `Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` = 'direction provinciale'
View(veto_data_corr_modalite[veto_data_corr_modalite$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` == 'direction provinciale', ])

# --- UATE ---
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'uate', ])
veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'uate', ]$
  `Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?` = 'zate'
View(veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'uate', ])

# --- Question non pertinente : suppression ---
table(veto_data_corr_modalite$`Quelles sont les structures impliquées dans la gestion et la distribution des vaccins vétérinaires dans votre localité ?`)

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  select(-c('Quelles sont les structures impliquées dans la gestion et la distribution des vaccins vétérinaires dans votre localité ?'))
View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  4.2 Responsabilités des structures
#------------------------------------------------------------------------------#

# --- 4.2.1 Administration des vaccins ---
veto_data_corr_modalite$`Administration des vaccins` <- as.integer(veto_data_corr_modalite$`Administration des vaccins`)

veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'zate' |
                          veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'uate', ]$
  `Administration des vaccins` = 1

View(veto_data_corr_modalite[veto_data_corr_modalite$Région == 'nord' | veto_data_corr_modalite$Région == 'sahel', ])

veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction regionale' |
                          veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'uate', ]$
  `Administration des vaccins` = 1

# --- 4.2.2 Réception, stockage et distribution ---
table(veto_data_corr_modalite$autre_responsabilite)

# Réception et stockage
veto_data_corr_modalite$`Réception et stockage` <- as.integer(veto_data_corr_modalite$`Réception et stockage`)
veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction regionale' |
                          veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction provinciale', ]$
  `Réception et stockage` = 1
veto_data_corr_modalite$`Réception et stockage` <- as.integer(veto_data_corr_modalite$`Réception et stockage`)

# Distribution vers le terrain
veto_data_corr_modalite$`Distribution vers le terrain` <- as.integer(veto_data_corr_modalite$`Distribution vers le terrain`)
veto_data_corr_modalite[veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction regionale' |
                          veto_data_corr_modalite$`A quel niveau de la chaîne vous trouvez vous?` == 'direction provinciale', ]$
  `Distribution vers le terrain` = 1

View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  4.3 Moyens de conservation & transport
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$autre_responsabilite)
table(veto_data_corr_modalite$autre_moyen_conservation)
table(veto_data_corr_modalite$autre_moyen_transport)

# Tout le monde a au moins un pack réfrigérant
veto_data_corr_modalite$`packs réfrigérants` <- as.integer(veto_data_corr_modalite$`packs réfrigérants`)
veto_data_corr_modalite$`packs réfrigérants` = 1

# Uniformisation « moto de service » → « moto »
veto_data_corr_modalite[!is.na(veto_data_corr_modalite$autre_moyen_transport) &
                          veto_data_corr_modalite$autre_moyen_transport == 'moto de service', ]$autre_moyen_transport = 'moto'

table(veto_data_corr_modalite$`si oui, combien selon vous?`)

#------------------------------------------------------------------------------#
#  4.4 Plage de température
#------------------------------------------------------------------------------#
library(tidyverse)

extraire_plage_temp <- function(texte) {
  # Nettoyage : supprimer espaces entre signe et chiffre
  texte_clean <- str_replace_all(texte, "([+-])\\s+", "\\1")

  # Extraire tous les nombres (entiers avec signe optionnel)
  nombres <- str_extract_all(texte_clean, "[+-]?\\d+") %>% unlist() %>% as.numeric()

  # Si on a au moins deux nombres
  if (length(nombres) >= 2) {
    v_min <- min(nombres[1:2])
    v_max <- max(nombres[1:2])
    return(paste0("[", v_min, ",", v_max, "]"))
  }
  # Si on a un seul nombre
  else if (length(nombres) == 1) {
    return(paste0("[", nombres[1], ",", nombres[1], "]"))
  }
  # Si rien n'est trouvé
  else {
    return(NA_character_)
  }
}

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  mutate(`si oui, combien selon vous?` = map_chr(`si oui, combien selon vous?`, extraire_plage_temp))

View(veto_data_corr_modalite)

# Suppressions de colonnes non pertinentes
veto_data_corr_modalite <- veto_data_corr_modalite %>% select(-c('Doit – on congeler un vaccin ?'))

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  select(-c(' Combien de temps le vaccin est-il conservé au niveau de la région avant d’être utilisé sur le  terrain (en moyenne) ?'))

#------------------------------------------------------------------------------#
#  4.5 Cohérence thermomètre / réfrigérateur
#------------------------------------------------------------------------------#

# --- 4.5.1 Thermomètre ---
veto_data_corr_modalite[veto_data_corr_modalite$thermomètre == 0, ]$
  `Des thermomètres fonctionnels sont-ils disponibles ?` = 'pas de thermometre'

veto_data_corr_modalite[veto_data_corr_modalite$thermomètre == 0, ]$
  `Le thermomètre pour la vérification de la température est-il placé correctement ?` = 'pas de thermometre'

View(veto_data_corr_modalite)

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  select(-c('Savez-vous pendant combien de temps il faut stocker les vaccins ?'))
View(veto_data_corr_modalite)

# --- 4.5.2 Réfrigérateur — état ---
veto_data_corr_modalite[veto_data_corr_modalite$réfrigérateur == 0, ]$
  `Les réfrigérateurs utilisés sont-ils tous fonctionnels ?` = 'pas de refrigirateur'
View(veto_data_corr_modalite)

veto_data_corr_modalite[veto_data_corr_modalite$réfrigérateur == 0, ]$
  `Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?` = 'pas de refrigirateur'
View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  4.6 Source d'énergie
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$`Quelle est la source principale d’énergie utilisée ?`)

liste1 <- c('autre (a preciser)', 'bouteille de gaz', 'butane', 'gaz butane', 'gaz de butane',
            'electronique et gaz', 'bouteilles de gaz de 12kg', 'bouteil de gaz',
            'gaz butane mais les refrigerateur sont en panne', 'frigo a gaz')

for (v in liste1) {
  veto_data_corr_modalite[veto_data_corr_modalite$`Quelle est la source principale d’énergie utilisée ?` == v, ]$
    `Quelle est la source principale d’énergie utilisée ?` = 'gaz'
}

liste2 <- c('electricite mais pas au service on negocie avec pds pour brancher chez lui.',
            'mixte( courant et electricite)')

for (v in liste2) {
  veto_data_corr_modalite[veto_data_corr_modalite$`Quelle est la source principale d’énergie utilisée ?` == v, ]$
    `Quelle est la source principale d’énergie utilisée ?` = 'electricite'
}

table(veto_data_corr_modalite$`Quelle est la source principale d’énergie utilisée ?`)
View(veto_data_corr_modalite)

# Réfrigérateur — arrêts
veto_data_corr_modalite[veto_data_corr_modalite$réfrigérateur == 0, ]$
  `Réfrigérateur est-il souvent en arrêt ?` = 'pas de refrigirateur'
View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  4.7 Causes d'arrêt du réfrigérateur
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$autre_cause_arret)

# Pause de convenance
veto_data_corr_modalite$`Pause de convenance` <- as.integer(veto_data_corr_modalite$`Pause de convenance`)
veto_data_corr_modalite[!is.na(veto_data_corr_modalite$autre_cause_arret) &
                          veto_data_corr_modalite$autre_cause_arret == 'si ya pas besoin de vaccin necessitant la chaine de froid', ]$
  `Pause de convenance` = 1

# Électricité (délestage / coupures)
liste3 <- c('delestage', 'delestages', 'coupure de fois')
veto_data_corr_modalite$Electricité <- as.integer(veto_data_corr_modalite$Electricité)

for (v in liste3) {
  veto_data_corr_modalite[!is.na(veto_data_corr_modalite$autre_cause_arret) &
                            veto_data_corr_modalite$autre_cause_arret == v, ]$Electricité = 1
}

View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  4.8 Classification du mode de transport
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$` Quel mode de transport est utilisé le plus souvent pour envoyer des vaccins dans les sous régions ou les villages ?`)

classer_transport <- function(x) {
  x <- tolower(x)

  case_when(
    str_detect(x, "avion|aerien|elico|voie aerienne|pont aerien") ~ "Aérien",
    str_detect(x, "frigorifique|refrigere|froides") ~ "Véhicule frigorifique",
    str_detect(x, "moto") & str_detect(x, "vehicule|car|transport en commun|4x4|camion") ~ "Mixte (Terrestre)",
    str_detect(x, "moto|motocyclette|mobilette") ~ "Moto",
    str_detect(x, "vehicule|voiture|camion|transport en commun|car|routier|4x4") ~ "Véhicule/Transport commun",
    str_detect(x, "glaciere") ~ "Glacière seule",
    str_detect(x, "aucun|ignore") ~ "Inconnu/Aucun",
    TRUE ~ "Autres/Non spécifié"
  )
}

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  mutate(` Quel mode de transport est utilisé le plus souvent pour envoyer des vaccins dans les sous régions ou les villages ?` =
           classer_transport(` Quel mode de transport est utilisé le plus souvent pour envoyer des vaccins dans les sous régions ou les villages ?`))

table(veto_data_corr_modalite$` Quel mode de transport est utilisé le plus souvent pour envoyer des vaccins dans les sous régions ou les villages ?`)

#------------------------------------------------------------------------------#
#  4.9 Classification de la surveillance du froid
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$`Si  oui, comment ?`)

classer_surveillance_froid <- function(x) {
  x <- scour_text <- tolower(x)

  case_when(
    str_detect(x, "thermometre|tableau de bord|glaciere|glacieres|temperature|verification a chaque moment") ~ "Thermomètre",
    str_detect(x, "presence de la glace|etat de la glace|verifiant le stock|touchant|avec de la glace|ibox|ai box|ice box|higt boxe|glacons|glaces|si les flacons son intacts et le niveau de la fraicheur et bon") ~ "Vérification visuelle (Glace)",
    str_detect(x, "touche") ~ "touche",
    TRUE ~ "Non specifie"
  )
}

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  mutate(`Si  oui, comment ?` = classer_surveillance_froid(`Si  oui, comment ?`))

table(veto_data_corr_modalite$`Si  oui, comment ?`)
View(veto_data_corr_modalite)

# Gestion des valeurs manquantes & cohérence réfrigérateur
table(veto_data_corr_modalite$`Le vaccin peut – il – retrouvé son activité après exposition à la chaleur quand on rétablie la température de stockage ?`)

veto_data_corr_modalite %>% count(is.na(veto_data_corr_modalite$`Le vaccin peut – il – retrouvé son activité après exposition à la chaleur quand on rétablie la température de stockage ?`))

veto_data_corr_modalite[is.na(veto_data_corr_modalite$`Le vaccin peut – il – retrouvé son activité après exposition à la chaleur quand on rétablie la température de stockage ?`), ]$
  `Le vaccin peut – il – retrouvé son activité après exposition à la chaleur quand on rétablie la température de stockage ?` <- 'je ne sais pas'

veto_data_corr_modalite[veto_data_corr_modalite$réfrigérateur == 0, ]$
  `Le réfrigérateur est – il nettoyé régulièrement ?` <- 'pas de refrigirateur'

veto_data_corr_modalite[veto_data_corr_modalite$réfrigérateur == 0, ]$
  `Les réfrigérateurs sont-ils dédiés uniquement qu’aux vaccins ?` <- 'pas de refrigirateur'

veto_data_corr_modalite <- veto_data_corr_modalite %>%
  select(-c('Existe-t-il des vaccins congelés dans les locaux ?'))

View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  4.10 Fréquence de nettoyage  →  `Si oui, à quelle fréquence ?...129`
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$`Si oui, à quelle fréquence ?...129`)

liste_quotidien <- c(
  'chaque jour', 'chaque matin', 'tout les jours', 'journalieres', '3 fois par jour'
)

liste_hebdo_1 <- c(
  '01 par semaine', '01 semaine', '1 fois la semaine', '1 fois par semaine',
  '1 semaine', '1/semaine', '1; fois par semaine', '1fois par semaine',
  '1fois/semaine', 'chaque semaine', 'chaque semaine.', 'chaque semaines',
  'chaque weekend', 'de facon hebdomadaire', 'hebdomadaire',
  'hebdomadaire et ya fois que ya des saletes', 'hebdomadairement',
  'par semaine', 'semaine', 'un fois par semaine', 'une fois par semaine',
  'une fois/semaine'
)

liste_hebdo_2 <- c(
  '2 /semaine au moins', '2 fois par semaine', '2 fois/semaines', '2/semaine',
  '2fois dans la semaine', 'deux fois par semaine'
)

liste_14_jours <- c(
  '10 jours', '14', "14jours d'intervalle", "2 semaine selon les degres d'ouverture",
  '2 semaines', '2semainrs', 'a chaque 2 semaine', 'chaque  deux semaines',
  'chaque 02 semaines', 'chaque 2 semaine', 'chaque 2 semaines',
  'chaque deux semaines', 'deux semaines', '7jours'
)

liste_mensuel_1 <- c(
  '1 fois dans le mois', '1 fois par mois', '1 mois', '1 par mois', '1/mois',
  '1fois par mois', 'chaque 1 mois', 'chaque 1mois', 'chaque moi', 'chaque mois',
  'mensuel', 'mensuelle', 'mensuellement', 'moi', 'mois', 'par mois', 'un mois',
  'une fois dans le mois', 'une fois par mois', 'chaque un mois'
)

liste_Mensuel_2 <- c('une fois deux les mois',
                     'au moins une fois tous les deux mois avant et apres chaque campagne de vaccination',
                     '1 par 2mois')

liste_mensuel_plus <- c(
  '2 fois / mois', '2 fois dans le mois', '2 fois par mois',
  '2 mois', '2/mois', 'deux fois mensuel'
)

liste_trimestriel <- c(
  '1 fois chaque 3 mois', '1 fois par trimestre', '3 mois', '3mois',
  'trimestriel', 'trimestriellement', 'une fois tous les 3 mois',
  '1 a 3 mois et aussi en cas d\'incident', '3 fois par moi', '3fois/ mois'
)

liste_quotidien_2 <- c(' chaque 3jours', '3 jours', 'chaque 3 jours', 'chaque 72h')

liste_annee <- c('1 fois/an ou 2 fois s\'il ya necessite', 'une fois deux les mois', '6 moi')

remplacer_modalite <- function(df, col, liste, nouvelle_valeur) {
  df[[col]][df[[col]] %in% liste] <- nouvelle_valeur
  return(df)
}

nom_col1 <- "Si oui, à quelle fréquence ?...129"

veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_quotidien,   "chaque jour")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_hebdo_1,     "chaque semaine")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_hebdo_2,     "2 fois par semaine")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_14_jours,    "chaque 2 semaines")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_mensuel_1,   "chaque mois")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_trimestriel, "chaque 3 mois")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_mensuel_plus,"2 fois par mois")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_annee,       "chaque 6 mois")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_quotidien_2, "chaque 3 jours")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col1, liste_Mensuel_2,   "chaque 3 mois")

#------------------------------------------------------------------------------#
#  4.11 Périodicité  →  `Si oui, à quelle périodicité ?`
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite$`Si oui, à quelle périodicité ?`)

liste_annuel <- c(
  '1 an', '1 annee', '1 annee', '1an', 'an', 'annee', 'annuel', 'annuelle', 'annuellement',
  'chaque 1 an', 'chaque an', 'chaque annee', 'chaque ans', 'chaque  annee',
  '1 fois par an', '1 fois par annee', '1/an', '1/ans', 'a chaque annee', 'par an',
  'a chaque fin d\'annee', 'a la fin de l\'annee', 'chaque decembre', 'chaque fin d\'annee',
  'chaque fin de l\'annee', 'decembre', 'en fin d\'annee', 'fin d\'annee',
  'vers la fin de l\' annee', 'aout', 'juillet', 'juin'
)

liste_demande <- c(
  'a chaque fois que la direction demande', 'a la demande de l\'autorite', 'a la demande de la direction',
  'a la demande de la dp', 'a la demande de la dparah', 'a la demande de la hierarchie',
  'a la demande du dp, dr et dgsv', 'a la demande du superieur', 'au besoin de la hierarchie',
  'la periode demandee par la hierarchie', 'si toutefois, on demande de faire la situation.'
)

liste_passation <- c(
  'lors des passation de charge', 'lors des passations', 'lors des passations de service',
  'lorsqu\' il y\'a passation de service', 'passation de service'
)

liste_trimestriel <- c(
  '1 fois par trimestre', '3 mois', '3mois', 'chaque 3 mois', 'chaque 03 mois',
  'trimestre', 'trimestriel', 'trimestrielle', 'trimestrielles', '04 mois'
)

liste_semestriel <- c(
  '06 mois', '6 mois', 'six mois', 'chaque semestre', 'semestre'
)

liste_mensuel <- c('1 mois', '2 mois', 'chaque mois', 'mensuel', 'mensuelle', 'mensuellement',
                   'par mois', 'chaque 15 du mois', '30 jours')

liste_hebdo <- c('hebdomadaire', 'semaine', 'chaque semaine', '2 semaine', 'chaque 2 semaines')

liste_quotidien <- c('quotidien', 'de facon continuelle')

liste_besoin <- c('en cas de besoin', 'si besoin en ai', 'si besoin y est', 'si necessaire',
                  'apres chaque usage')

liste_campagne_avant <- c(
  'avant chaque campagne',
  'avant chaque campagne de vaccination',
  'avant la campagne de vaccination',
  'avant le debut des campagnes de vaccination',
  'avant de debut de chaque campagne',
  'debut campagnes',
  'debut de campagne',
  'en debut de campagne',
  'chaque debut de campagne',
  'a l\'approche des campagnes de vaccination',
  'l approche de la campagne de vaccination',
  'a l\'entree et sortie de la campagne'
)

liste_campagne_apres <- c(
  'apres campagne',
  'apres chaque campagne',
  'apres la campagne',
  'fin de chaque campagne',
  'fin de la campagne',
  'a la fin de chaque campagne de vaccination',
  'en mentionnant le reste'
)

liste_campagne_mixte <- c(
  'avant et apres campagne',
  'avant et apres chaque campagne',
  'avant et apres la campagne',
  'a chaque debut et la fin de la campagne',
  'debut et a la fin des compagne de vaccination',
  'fin et debut de campagne',
  'au moment de chaque campagne de vaccination',
  'au moment de la campagne',
  'moment de la campagne',
  'campagne',
  'chaque campagne',
  'periode de la campagne et hors campagne',
  'en debut ou en fin de campagne',
  'debut de la campagne de vaccination contre les maladies animales prioritaires et les zoonoses'
)

nom_col2 <- 'Si oui, à quelle périodicité ?'

veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_campagne_avant, "avant chaque campagne")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_campagne_apres, "apres chaque Campagne")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_campagne_mixte, "avant et apres chaque Campagne")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_annuel,          "Annuel")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_trimestriel,     "Trimestriel")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_semestriel,      "Semestriel")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_mensuel,         "Mensuel")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_hebdo,           "Hebdomadaire")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_quotidien,       "Quotidien")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_demande,         "Sur demande hiérarchique")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_passation,       "Passation de service")
veto_data_corr_modalite <- remplacer_modalite(veto_data_corr_modalite, nom_col2, liste_besoin,          "Au besoin / Si nécessaire")

veto_data_corr_modalite[!is.na(veto_data_corr_modalite$`Si oui, à quelle périodicité ?`) &
                          veto_data_corr_modalite$`Si oui, à quelle périodicité ?` == '1 a 2 fois par an', ]$
  `Si oui, à quelle périodicité ?` <- '2 fois par an'

veto_data_corr_modalite[!is.na(veto_data_corr_modalite$`Si oui, à quelle périodicité ?`) &
                          veto_data_corr_modalite$`Si oui, à quelle périodicité ?` == 'ras', ]$
  `Eliminez – vous régulièrement les givres ?` <- 'non'

veto_data_corr_modalite[!is.na(veto_data_corr_modalite$`Si oui, à quelle périodicité ?`) &
                          veto_data_corr_modalite$`Si oui, à quelle périodicité ?` == 'ras', ]$
  `Si oui, à quelle périodicité ?` <- 'NA'

table(veto_data_corr_modalite$`Si oui, à quelle périodicité ?`)
View(veto_data_corr_modalite)

#------------------------------------------------------------------------------#
#  5. EXPORT FINAL
#------------------------------------------------------------------------------#
getwd()
setwd("C:\\Users\\pc\\these_Gloria")  # répertoire de travail à modifier
write_xlsx(veto_data_corr_modalite, "veto_data_corr_modalite.xlsx")

# ---- Fin du script : base apurée et modalités uniformisées ----