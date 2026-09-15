#==============================================================================#
#  ANALYSE CHAÎNE DE FROID — VACCINS VÉTÉRINAIRES AU BURKINA FASO
#  Auteur : DRABO ARIEL — Tous droits réservés
#  Thème  : Évaluation de la gestion de la chaîne de froid des vaccins
#           à usage vétérinaire dans les structures publiques au Burkina Faso.
#==============================================================================#

#------------------------------------------------------------------------------#
#  1. BIBLIOTHÈQUES & RÉPERTOIRE DE TRAVAIL
#------------------------------------------------------------------------------#
library(readxl)
library(clipr)
library(readxl)
library(writexl)
library(openxlsx)
library(dplyr)

setwd("C:\\Users\\pc\\these_Gloria")  # répertoire de travail à modifier

#------------------------------------------------------------------------------#
#  2. IMPORTATION DE LA BASE DE DONNÉES
#------------------------------------------------------------------------------#
veto_data_corr_modalite_analyse <- read_excel("C:\\Users\\pc\\Downloads\\veto_data_corr_modalite_analyse.xlsx")
View(veto_data_corr_modalite_analyse)


#==============================================================================#
#  PARTIE I — DESCRIPTION DES STRUCTURES CHARGÉES DE LA GESTION
#            DES VACCINS VÉTÉRINAIRES PUBLICS AU BURKINA FASO
#==============================================================================#

#------------------------------------------------------------------------------#
#  3. STRUCTURE ET RÉGION
#------------------------------------------------------------------------------#
structures <- as.data.frame.array(addmargins(table(veto_data_corr_modalite_analyse$`A quel niveau de la chaîne vous trouvez vous?`, veto_data_corr_modalite_analyse$Région)))
dir.create("tableaux")

# Création d'une feuille
wb <- createWorkbook()

# Feuille nommée VACCIN
addWorksheet(wb, 'vaccin')

# Écriture des données dans la feuille VACCIN
writeData(wb, sheet = 'vaccin', x = structures, rowNames = TRUE)

# Sauvegarde du fichier dans le sous-dossier TABLEAUX
saveWorkbook(wb, "tableaux/structures.xlsx", overwrite = TRUE)

View(structures)


#==============================================================================#
#  PARTIE II — CARACTÉRISTIQUES SOCIO-DÉMOGRAPHIQUES
#==============================================================================#

#------------------------------------------------------------------------------#
#  4.1 Genre
#------------------------------------------------------------------------------#
genre <- as.data.frame(addmargins(table(veto_data_corr_modalite_analyse$Sexe)))
colnames(genre) <- c('Genre', 'Frequence')

write_xlsx(genre, 'tableaux/tableau1.xlsx')
View(genre)

#------------------------------------------------------------------------------#
#  4.2 Statut / Poste
#------------------------------------------------------------------------------#
statut <- as.data.frame(addmargins(table(veto_data_corr_modalite_analyse$`Poste ou statut de la personne enquêtée`)))
colnames(statut) <- c('POSTE', 'FREQUENCE')

write_xlsx(niveau_education, 'tableaux/tableau2.xlsx')
View(statut)

#------------------------------------------------------------------------------#
#  4.3 Niveau d'éducation
#------------------------------------------------------------------------------#
niveau_education <- as.data.frame(addmargins(table(veto_data_corr_modalite_analyse$Niveau)))
colnames(niveau_education) <- c('Niveau d\'education', 'Frequence')

write_xlsx(niveau_education, 'tableaux/tableau3.xlsx')
View(niveau_education)

#------------------------------------------------------------------------------#
#  4.4 Tranche d'âge
#------------------------------------------------------------------------------#
tranche_age <- as.data.frame(addmargins(table(veto_data_corr_modalite_analyse$`Tranche d’âges`)))
View(tranche_age)
colnames(tranche_age) <- c('Tranche d\'age', 'Frequence')

write_xlsx(tranche_age, 'tableaux/tableau4.xlsx')

#------------------------------------------------------------------------------#
#  4.5 Expérience d'utilisation des vaccins
#------------------------------------------------------------------------------#
experience_vaccin <- as.data.frame(addmargins(
  table(veto_data_corr_modalite_analyse$`utilisation des vaccins`)
))
colnames(experience_vaccin) <- c("Utilisation_vaccins", "Fréquence")
View(experience_vaccin)

write_xlsx(experience_vaccin, "tableaux/tableau5_experience_vaccins.xlsx")

#------------------------------------------------------------------------------#
#  4.6 Formation sur la chaîne de froid
#------------------------------------------------------------------------------#
formation_vaccin <- as.data.frame(addmargins(
  table(veto_data_corr_modalite_analyse$`Avez-vous déjà été formé sur la gestion de la chaine de froid des vaccins ?`)
))
colnames(formation_vaccin) <- c("Formation_chaine_froid", "Fréquence")
View(formation_vaccin)

write_xlsx(formation_vaccin, "tableaux/tableau6_formation_vaccins.xlsx")

#------------------------------------------------------------------------------#
#  4.7 Fusion des caractéristiques socio-démographiques
#------------------------------------------------------------------------------#
fusion <- rbind(genre, formation_vaccin)

fusion <- bind_rows(
  genre,              # colonnes : Genre, Fréquence
  formation_vaccin    # colonnes : Formation_chaine_froid, Fréquence
)
library(dplyr)


#==============================================================================#
#  PARTIE III — APPROVISIONNEMENT & RÔLES DES STRUCTURES
#==============================================================================#

#------------------------------------------------------------------------------#
#  5.1 Structures d'approvisionnement des vaccins
#------------------------------------------------------------------------------#
vaccin_ap <- as.data.frame(addmargins(
  table(veto_data_corr_modalite_analyse$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?`)
))
colnames(vaccin_ap) <- c("Structure_approvisionnement", "Fréquence")
View(vaccin_ap)

write_xlsx(vaccin_ap, "tableaux/tableau7_vaccin_approvisionnement.xlsx")

#------------------------------------------------------------------------------#
#  5.2 Processus de distribution
#------------------------------------------------------------------------------#
dist <- as.data.frame.array(addmargins(table(
  veto_data_corr_modalite_analyse$`A quel niveau de la chaîne vous trouvez vous?`,
  veto_data_corr_modalite_analyse$`Quelle est la structure principale chargée de l’approvisionnement des vaccins vétérinaires dans votre zone ?`
)))
dist

wb2 <- createWorkbook()
addWorksheet(wb2, 'approvisionnement')
writeData(wb2, sheet = 'approvisionnement', x = dist, rowNames = TRUE)
saveWorkbook(wb2, "tableaux/tableau8_approvisionnement.xlsx", overwrite = TRUE)

#------------------------------------------------------------------------------#
#  5.3 Rôle spécifique de chaque structure
#------------------------------------------------------------------------------#
role <- ''
indice <- 1
indice2 <- 1
veto_data_corr_modalite_analyse[] <- lapply(veto_data_corr_modalite_analyse, as.character)

n <- nrow(veto_data_corr_modalite_analyse)
poste_role <- data.frame(
  poste = character(n),
  role  = character(n),
  stringsAsFactors = FALSE
)

colnames(poste_role)
for (v in veto_data_corr_modalite_analyse$`Poste ou statut de la personne enquêtée`) {

  if (veto_data_corr_modalite_analyse$`Réception et stockage`[indice] == '1') {
    role <- paste(role, 'Reception et stockage')
  }
  if (veto_data_corr_modalite_analyse$`Distribution vers le terrain`[indice] == '1') {
    role <- paste(role, 'Distribution vers le terrain')
    cat('oui', indice)
  }
  if (veto_data_corr_modalite_analyse$`Suivi de température`[indice] == '1') {
    role <- paste(role, 'suivi de temperature')
  }
  if (veto_data_corr_modalite_analyse$`Administration des vaccins`[indice] == '1') {
    role <- paste(role, 'administration de vaccin')
  }
  if (veto_data_corr_modalite_analyse$`Tenue de registres`[indice] == '1') {
    role <- paste(role, 'tenue de registres')
  }

  if (!is.na(veto_data_corr_modalite_analyse$autre_responsabilite[indice])) {
    role <- paste(role, veto_data_corr_modalite_analyse$autre_responsabilite[indice])
  }

  # Enregistrement
  poste_role$poste[indice2] <- v
  poste_role$role[indice2]  <- role
  role <- ''  # état initial
  indice <- indice + 1
  indice2 <- indice2 + 1
}

View(poste_role)
library(openxlsx)

# Liste des postes
liste7 <- c('chef zate', 'chef srsv', 'chef uate', 'directeur provincial', 'chef spsv')

# Créer le workbook une seule fois
wb3 <- createWorkbook()

# Boucle pour créer une feuille par poste
for (v in unique(liste7)) {
  df3 <- as.data.frame(table(poste_role[poste_role$poste == v, ]$role))
  addWorksheet(wb3, v)
  writeData(wb3, sheet = v, x = df3, rowNames = TRUE)
}

saveWorkbook(wb3, "tableaux/tableau10.xlsx", overwrite = TRUE)


#==============================================================================#
#  PARTIE IV — CALCUL DES TAUX PAR POSTE
#==============================================================================#

#------------------------------------------------------------------------------#
#  6.1 Fonction générique de calcul des taux
#------------------------------------------------------------------------------#
calcul_taux <- function(data, liste_postes, variable) {
  res <- data.frame(
    poste    = character(length(liste_postes)),
    font     = integer(length(liste_postes)),
    font_pas = integer(length(liste_postes)),
    total    = integer(length(liste_postes))
  )

  indice <- 1
  for (v in liste_postes) {
    nombre <- data %>%
      filter(`Poste ou statut de la personne enquêtée` == v,
             !!sym(variable) == "1") %>%
      nrow()

    nombre_total <- data %>%
      filter(`Poste ou statut de la personne enquêtée` == v) %>%
      nrow()

    res$poste[indice]    <- v
    res$font[indice]     <- nombre
    res$font_pas[indice] <- nombre_total - nombre
    res$total[indice]    <- nombre_total

    cat(variable, "-", v, ":", nombre, "sur", nombre_total, "\n")
    indice <- indice + 1
  }

  return(res)
}

# Application aux différentes colonnes
reception_stockage    <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Réception et stockage")
distribution_terrain  <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Distribution vers le terrain")
suivi_temperature     <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Suivi de température")
administration_vaccins<- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Administration des vaccins")
tenue_registres       <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Tenue de registres")

# Visualiser un tableau
View(reception_stockage)
View(distribution_terrain)
View(suivi_temperature)
View(administration_vaccins)
View(tenue_registres)

library(openxlsx)

wb4 <- createWorkbook()

liste_tableaux <- list(
  "Réception et stockage"  = reception_stockage,
  "Distribution terrain"   = distribution_terrain,
  "Suivi température"      = suivi_temperature,
  "Administration vaccins" = administration_vaccins,
  "Tenue registres"        = tenue_registres
)

for (nom in names(liste_tableaux)) {
  addWorksheet(wb4, nom)
  writeData(wb4, sheet = nom, x = liste_tableaux[[nom]], rowNames = FALSE)
}

saveWorkbook(wb4, "tableaux/tableau_taux.xlsx", overwrite = TRUE)


#==============================================================================#
#  PARTIE V — CORRECTION DES PROVINCES & EXPORT INTERMÉDIAIRE
#==============================================================================#
corrections <- c(
  "bougouiriba"    = "bougouriba",
  "kourritenga"    = "kouritenga",
  "sandbontenga"   = "boulgou",
  "sandbontenga"   = "boulgou",
  "sandbondtenga"  = "boulgou",
  "sissilli"       = "sissili"
)

veto_data_corr_modalite_analyse$Province <- recode(veto_data_corr_modalite_analyse$Province, !!!corrections)

# Uniformisation PROVINCE
table(veto_data_corr_modalite_analyse$Province)

getwd()
write_xlsx(veto_data_corr_modalite_analyse, 'veto_data_corr_modalite_analyse.xlsx')


#==============================================================================#
#  PARTIE VI — TAUX D'UTILISATION DES VACCINS PAR POSTE
#==============================================================================#
ppcb             <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "PPCB")
ppr              <- calcul_taux(veto_data_corr_modalite_analyse, liste7, 'PPR')
charbon_bacterien<- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Charbon bactéridien")
mnc              <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "MNC (maladie de NewCastle)")
variole_aviaire  <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Variole Aviaire")
rage             <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Rage")
fievre_aphteuse  <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Fièvre aphteuse")
autre_vaccin     <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "autre_vaccin")

vaccins_resultats <- list(
  PPCB              = ppcb,
  PPR               = ppr,
  Charbon_bacterien = charbon_bacterien,
  MNC               = mnc,
  Variole_Aviaire   = variole_aviaire,
  Rage              = rage,
  Fievre_Aphteuse   = fievre_aphteuse,
  Autre_vaccin      = autre_vaccin
)
wb5 <- createWorkbook()

for (nom in names(vaccins_resultats)) {
  addWorksheet(wb5, nom)
  writeData(wb5, nom, vaccins_resultats[[nom]])
}

saveWorkbook(wb5, "tableaux/resultats_vaccins.xlsx", overwrite = TRUE)


#==============================================================================#
#  PARTIE VII — MATÉRIEL DE STOCKAGE (CONSERVATION)
#==============================================================================#

#------------------------------------------------------------------------------#
#  7.1 Analyse globale
#------------------------------------------------------------------------------#
colonnes <- c(
  "réfrigérateur",
  "thermomètre",
  "alarme de température",
  "source d'énergie secours",
  "boîtes de rangement pour les flacons",
  "carnet ou registre de suivi",
  "Chambre froide",
  "autre_moyen_conservation"
)

wb6 <- createWorkbook()

for (col in colonnes) {
  tab    <- table(veto_data_corr_modalite_analyse[[col]])
  df_tab <- as.data.frame(tab)
  colnames(df_tab) <- c("Modalité", "Fréquence")

  if (col == "boîtes de rangement pour les flacons") {
    addWorksheet(wb6, 'boite_rangement')
    writeData(wb6, 'boite_rangement', df_tab)
  } else {
    addWorksheet(wb6, col)
    writeData(wb6, col, df_tab)
  }
}

saveWorkbook(wb6, "tableaux/resultats_conservation.xlsx", overwrite = TRUE)

#------------------------------------------------------------------------------#
#  7.2 Croisement avec les postes
#------------------------------------------------------------------------------#
refrigerateur      <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "réfrigérateur")
thermometre        <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "thermomètre")
alarme_temperature <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "alarme de température")
source_secours     <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "source d'énergie secours")
boites_rangement   <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "boîtes de rangement pour les flacons")
carnet_registre    <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "carnet ou registre de suivi")
chambre_froide     <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "Chambre froide")
autre_conservation <- calcul_taux(veto_data_corr_modalite_analyse, liste7, "autre_moyen_conservation")

conservation_resultats <- list(
  Refrigerateur      = refrigerateur,
  Thermometre        = thermometre,
  Alarme_temperature = alarme_temperature,
  Source_secours     = source_secours,
  Boites_rangement   = boites_rangement,
  Carnet_registre    = carnet_registre,
  Chambre_froide     = chambre_froide,
  Autre_conservation = autre_conservation
)

wb8 <- createWorkbook()

for (nom in names(conservation_resultats)) {
  addWorksheet(wb8, nom)
  writeData(wb8, nom, conservation_resultats[[nom]])
}

saveWorkbook(wb8, "tableaux/resultats_conservation_taux.xlsx", overwrite = TRUE)

#------------------------------------------------------------------------------#
#  7.3 Analyse par Région et Poste
#------------------------------------------------------------------------------#
wb9 <- createWorkbook()

for (col in colonnes) {
  df <- veto_data_corr_modalite_analyse %>%
    group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
    summarise(
      possede     = sum(.data[[col]] == "1"),
      possede_pas = sum(.data[[col]] == '0'),
      Total       = sum(.data[[col]] == '1' | .data[[col]] == '0'),
      .groups     = "drop"
    )

  sheet_name <- substr(col, 1, 30)

  addWorksheet(wb9, sheet_name)
  writeData(wb9, sheet_name, df)
}

saveWorkbook(wb9, "tableaux/resultats_region_poste.xlsx", overwrite = TRUE)


#==============================================================================#
#  PARTIE VIII — ÉQUIPEMENT DES CHAÎNES DE FROID
#==============================================================================#

#------------------------------------------------------------------------------#
#  8.1 État global des équipements
#------------------------------------------------------------------------------#
write.xlsx(table(veto_data_corr_modalite_analyse$`Les équipements de chaîne de froid sont-ils tous en bon état ?`), 'tableaux/etat_equipement.xlsx')

# Enregistrement dans une image
png(filename = "etat_equipements.png", width = 600, height = 600)
pie(table(veto_data_corr_modalite_analyse$`Les équipements de chaîne de froid sont-ils tous en bon état ?`),
    main = "Etat des equipements de chaine de froid")
dev.off()

#------------------------------------------------------------------------------#
#  8.2 Nombre de personnes possédant chaque matériel
#------------------------------------------------------------------------------#
bar_plot <- table(veto_data_corr_modalite_analyse[[colonnes[1]]])

for (col in colonnes) {
  if (col != colonnes[1] & col != 'autre_moyen_conservation') {
    bar_plot <- c(bar_plot, table(veto_data_corr_modalite_analyse[[col]]))
    table(veto_data_corr_modalite_analyse[[col]])
  }
}
bar_plot_1 <- bar_plot[names(bar_plot) == '1']

png(filename = 'bar_plot_equipement.png', width = 2000, height = 1500, res = 150)

names(bar_plot_1) <- c("réfrigérateur",
                       "thermomètre",
                       "alarme de température",
                       "source d'énergie secours",
                       "boîtes_rangement_flacons",
                       "carnet_registre_suivi",
                       "Chambre froide")
par(mar = c(16, 4, 4, 2))
barplot(bar_plot_1, main = "Barplot des differentes equipements",
        ylab = "Frequences", las = 2, cex.names = 1.5, cex.axis = 1.2)

dev.off()

#------------------------------------------------------------------------------#
#  8.3 Détail par type de matériel
#------------------------------------------------------------------------------#
for (col in colonnes) {
  if (col != 'autre_moyen_conservation') {
    png(filename = paste("etat_", col, '.png'), width = 2000, height = 1500, res = 150)
    barplot(table(veto_data_corr_modalite_analyse[[col]]),
            main = paste('Nombre de personne qui ont ', col), xlab = col)
    dev.off()
    write.xlsx(table(veto_data_corr_modalite_analyse[[col]]), paste('tableaux/', col, '.xlsx'))
  }
}

#------------------------------------------------------------------------------#
#  8.4 Réfrigérateurs fonctionnels ?
#------------------------------------------------------------------------------#
rf <- table(veto_data_corr_modalite_analyse$`Les réfrigérateurs utilisés sont-ils tous fonctionnels ?`)
labels <- paste(names(rf), rf)

rf <- rf[names(rf) != 'pas de refrigirateur']
png(filename = 'etat_refrigirateur.png', width = 2000, height = 1500, res = 150)

pie(rf, main = "Etat des Refrigirateur disponibles", labels = labels)

dev.off()

write.xlsx(rf, 'tableaux/etat_refrigirateur.xlsx')

#------------------------------------------------------------------------------#
#  8.5 Réfrigérateurs adaptés à la zone ?
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?`)

rf1 <- table(veto_data_corr_modalite_analyse$`Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?`)
rf1 <- rf1[names(rf1) != 'pas de refrigirateur']

label1 <- paste(names(rf1), rf1)
png(filename = 'etat_refrigirateur_adapter_zone.png', width = 2000, height = 1500, res = 150)
pie(rf1, labels = label1, main = 'refrigerateur adapte a la zone')
dev.off()

# Croisement avec Poste et Région
praz <- veto_data_corr_modalite_analyse %>%
  group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
  summarise(
    adapte     = sum(.data[['Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?']] == 'oui'),
    pas_adapte = sum(.data[['Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?']] == 'non'),
    Total      = sum(.data[['Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?']] == 'non' |
                       .data[['Tous les réfrigérateurs disponibles sont ils adaptés à votre zone par rapport à la source d’énergie utilisée ?']] == 'oui'),
    .groups = 'drop'
  )

praz

wb10 <- createWorkbook()
addWorksheet(wb10, 'global')
addWorksheet(wb10, 'specifique')

writeData(wb10, 'global', rf1)
writeData(wb10, 'specifique', praz)

saveWorkbook(wb10, 'tableaux/zone_adapte_refrigirateur.xlsx')

#------------------------------------------------------------------------------#
#  8.6 Capacité de stockage suffisante ?
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Avez-vous une capacité de stockage suffisante pour les vaccins dans votre installation ?`)
rf2 <- table(veto_data_corr_modalite_analyse$`Avez-vous une capacité de stockage suffisante pour les vaccins dans votre installation ?`)

label2 <- paste(names(rf2), rf2)
png(filename = 'capcite_stockage_suffisante.png', width = 2000, height = 1500, res = 150)
pie(rf2, labels = label2, main = 'Capcite de stockage suffisante pour les vaccins')
dev.off()

acsv <- veto_data_corr_modalite_analyse %>%
  group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
  summarise(
    adapte     = sum(.data[['Avez-vous une capacité de stockage suffisante pour les vaccins dans votre installation ?']] == 'oui'),
    pas_adapte = sum(.data[['Avez-vous une capacité de stockage suffisante pour les vaccins dans votre installation ?']] == 'non'),
    Total      = sum(.data[['Avez-vous une capacité de stockage suffisante pour les vaccins dans votre installation ?']] == 'non' |
                       .data[['Avez-vous une capacité de stockage suffisante pour les vaccins dans votre installation ?']] == 'oui'),
    .groups = 'drop'
  )

wb11 <- createWorkbook()
addWorksheet(wb11, 'global')
addWorksheet(wb11, 'specifique')

writeData(wb11, 'global', rf2)
writeData(wb11, 'specifique', acsv)

saveWorkbook(wb10, 'tableaux/capacite_stockage_suffisante.xlsx')

#------------------------------------------------------------------------------#
#  8.7 Formulaires de commandes et déclarations ?
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Avez-vous des formulaires de commandes et de déclarations des vaccins ?`)
rf3 <- table(veto_data_corr_modalite_analyse$`Avez-vous des formulaires de commandes et de déclarations des vaccins ?`)

label3 <- paste(names(rf3), rf3)
png(filename = 'formulaire_commande_vaccin.png', width = 2000, height = 1500, res = 150)
pie(rf3, labels = label3, main = 'Avez-vous des formulaires de commandes et de déclarations des vaccins ?')
dev.off()

fcv <- veto_data_corr_modalite_analyse %>%
  group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
  summarise(
    adapte     = sum(.data[['Avez-vous des formulaires de commandes et de déclarations des vaccins ?']] == 'oui'),
    pas_adapte = sum(.data[['Avez-vous des formulaires de commandes et de déclarations des vaccins ?']] == 'non'),
    Total      = sum(.data[['Avez-vous des formulaires de commandes et de déclarations des vaccins ?']] == 'non' |
                       .data[['Avez-vous des formulaires de commandes et de déclarations des vaccins ?']] == 'oui'),
    .groups = 'drop'
  )

wb12 <- createWorkbook()
addWorksheet(wb12, 'global')
addWorksheet(wb12, 'specifique')

writeData(wb12, 'global', rf3)
writeData(wb12, 'specifique', fcv)

saveWorkbook(wb12, 'tableaux/formulaire_vaccin.xlsx')

#------------------------------------------------------------------------------#
#  8.8 Thermomètres fonctionnels disponibles ?
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Des thermomètres fonctionnels sont-ils disponibles ?`)
rf4 <- table(veto_data_corr_modalite_analyse$`Des thermomètres fonctionnels sont-ils disponibles ?`)
rf4 <- rf4[names(rf4) != 'pas de thermometre']

label4 <- paste(names(rf4), rf4)
png(filename = 'thermometre_fonctionnelle.png', width = 2000, height = 1500, res = 150)
pie(rf4, labels = label4, main = 'Des thermomètres fonctionnels sont-ils disponibles ?')
dev.off()

tfd <- veto_data_corr_modalite_analyse %>%
  group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
  summarise(
    adapte     = sum(.data[['Des thermomètres fonctionnels sont-ils disponibles ?']] == 'oui'),
    pas_adapte = sum(.data[['Des thermomètres fonctionnels sont-ils disponibles ?']] == 'non'),
    Total      = sum(.data[['Des thermomètres fonctionnels sont-ils disponibles ?']] == 'non' |
                       .data[['Des thermomètres fonctionnels sont-ils disponibles ?']] == 'oui'),
    .groups = 'drop'
  )

wb13 <- createWorkbook()
addWorksheet(wb13, 'global')
addWorksheet(wb13, 'specifique')

writeData(wb13, 'global', rf4)
writeData(wb13, 'specifique', tfd)

saveWorkbook(wb13, 'tableaux/thermometre_fonctionelle.xlsx')

#------------------------------------------------------------------------------#
#  8.9 Source principale d'énergie utilisée
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Quelle est la source principale d’énergie utilisée ?`)

wb14 <- createWorkbook()

seu <- veto_data_corr_modalite_analyse %>%
  group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
  summarise(
    electricite    = sum(.data[["Quelle est la source principale d’énergie utilisée ?"]] == "electricite"),
    gaz            = sum(.data[["Quelle est la source principale d’énergie utilisée ?"]] == "gaz"),
    kerosene       = sum(.data[["Quelle est la source principale d’énergie utilisée ?"]] == "kerosene"),
    plaque_solaire = sum(.data[["Quelle est la source principale d’énergie utilisée ?"]] == "plaque solaire"),
    .groups = "drop"
  )

sheet_name <- 'source_energie'
addWorksheet(wb14, sheet_name)
writeData(wb14, sheet_name, seu)

saveWorkbook(wb14, "tableaux/principale_source_energie.xlsx", overwrite = TRUE)

#------------------------------------------------------------------------------#
#  8.10 Barplot des sources d'énergie
#------------------------------------------------------------------------------#
bar_plot_2 <- table(veto_data_corr_modalite_analyse$`Quelle est la source principale d’énergie utilisée ?`)
bar_plot_2

png(filename = 'bar_plot_source_energie.png', width = 2000, height = 1500, res = 150)
par(mar = c(16, 4, 4, 2))
barplot(bar_plot_2, main = 'Quelle est la source principale d’énergie utilisée ?',
        ylab = 'frequence', las = 2)
dev.off()

write.xlsx(bar_plot_2, 'tableaux/source_energie_categorie.xlsx')

#------------------------------------------------------------------------------#
#  8.11 Réfrigérateur souvent en arrêt ?
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Réfrigérateur est-il souvent en arrêt ?`)

rf5 <- table(veto_data_corr_modalite_analyse$`Réfrigérateur est-il souvent en arrêt ?`)
rf5 <- rf5[names(rf5) != 'pas de refrigirateur']

label5 <- paste(names(rf5), rf5)
png(filename = 'refrigirateur_arret.png', width = 2000, height = 1500, res = 150)
pie(rf5, labels = label5, main = 'Réfrigérateur est-il souvent en arrêt ?')
dev.off()

rsa <- veto_data_corr_modalite_analyse %>%
  group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
  summarise(
    arret     = sum(.data[['Réfrigérateur est-il souvent en arrêt ?']] == 'oui'),
    non_arret = sum(.data[['Réfrigérateur est-il souvent en arrêt ?']] == 'non'),
    Total     = sum(.data[['Réfrigérateur est-il souvent en arrêt ?']] == 'non' |
                      .data[['Réfrigérateur est-il souvent en arrêt ?']] == 'oui'),
    .groups = 'drop'
  )

wb15 <- createWorkbook()
addWorksheet(wb15, 'global')
addWorksheet(wb15, 'specifique')

writeData(wb15, 'global', rf5)
writeData(wb15, 'specifique', rsa)

saveWorkbook(wb15, 'tableaux/refrigirateur_arret.xlsx')

#------------------------------------------------------------------------------#
#  8.12 Causes principales des arrêts
#------------------------------------------------------------------------------#
colonne2 <- c('Gaz',
              'Electricité',
              'Pause de convenance',
              'Pétrole',
              'bouton_autre_cause_arret')

table(veto_data_corr_modalite_analyse$bouton_autre_cause_arret)

wb16 <- createWorkbook()

# Regroupement par Région et Poste (PROBLEME ICI)
for (col in colonne2) {
  print(col)

  veto_data_corr_modalite_analyse[[col]] <- as.character(veto_data_corr_modalite_analyse[[col]])
  df <- veto_data_corr_modalite_analyse %>%
    group_by(Région, `Poste ou statut de la personne enquêtée`) %>%
    summarise(
      cause     = sum(.data[[col]] == "1", na.rm = TRUE),
      cause_pas = sum(.data[[col]] == '0', na.rm = TRUE),
      Total     = sum(.data[[col]] == '1' | .data[[col]] == '0', na.rm = TRUE),
      .groups = "drop"
    )

  sheet_name <- substr(col, 1, 30)

  addWorksheet(wb16, sheet_name)
  writeData(wb16, sheet_name, df)
}

saveWorkbook(wb16, "tableaux/cause_arret_refrigirateur.xlsx", overwrite = TRUE)

#------------------------------------------------------------------------------#
#  8.13 Barplot comparatif des causes d'arrêt
#------------------------------------------------------------------------------#
bar_plot3 <- table(veto_data_corr_modalite_analyse[[colonne2[1]]])

for (col in colonne2) {
  if (col != colonne2[1]) {
    bar_plot3 <- c(bar_plot3, table(veto_data_corr_modalite_analyse[[col]]))
    table(veto_data_corr_modalite_analyse[[col]])
  }
}
bar_plot_4 <- bar_plot3[names(bar_plot3) == '1']

png(filename = 'bar_plot_cause_arret_refri.png', width = 2000, height = 1500, res = 150)

names(bar_plot_4) <- colonne2
par(mar = c(16, 4, 4, 2))
barplot(bar_plot_4, main = "Barplot des differentes equipements",
        ylab = "Frequences", las = 2, cex.names = 1.5, cex.axis = 1.2)

dev.off()

#------------------------------------------------------------------------------#
#  8.14 Fréquence des coupures d'électricité
#------------------------------------------------------------------------------#
cfs <- table(veto_data_corr_modalite_analyse$`Environ combien de fois par semaine  l’électricité  est-elle généralement ‘coupée’ ?`)
png(filename = 'coupure_elec_fois.png', width = 2000, height = 1500, res = 150)
par(mar = c(16, 4, 4, 2))
barplot(cfs, main = "combien de coupure par semaine", ylab = "Frequences",
        las = 2, cex.names = 1.5, cex.axis = 1.2)
dev.off()

write.xlsx(cfs, 'tableaux/coupure_elec_fois.xlsx')


#==============================================================================#
#  PARTIE IX — QUESTIONS OUI / NON
#==============================================================================#
questions_yn <- c(
  "La température du vaccin est-elle surveillée durant le transport jusque sur le terrain ?",
  "Les matériels et équipements de la chaine de froid sont-ils propres , exemptes de saleté ?",
  "Les fenêtres et la salle externe du local ou ils se trouvent sont-elles sécurisées ?",
  "Le toit  présente-t-il des fuites ?",
  "Le sol est sec et est à une hauteur raisonnable",
  "Existe – t – il des possibilités de la chaîne de froid alternative pour stocker les vaccins ?",
  "Existe – t – il une politique de renouvellement du matériel ?",
  "Connaissez-vous les conditions de fonctionnement d’un réfrigérateur ?"
)

for (col in questions_yn) {
  rf6 <- table(veto_data_corr_modalite_analyse[[col]])
  label5 <- paste(names(rf6), rf6)

  # Enregistrement graphique
  safe_name <- gsub("[^[:alnum:]_]", "_", col)
  safe_name <- substr(safe_name, 1, 100)
  print(safe_name)
  # png(filename = paste(safe_name, '.png'), width = 2000, height = 1500, res = 150)
  # pie(rf6, labels = label5, main = safe_name)
  # dev.off()

  # Enregistrement Tableaux croisés
  df <- veto_data_corr_modalite_analyse %>%
    group_by(`Poste ou statut de la personne enquêtée`) %>%
    summarise(
      Oui   = sum(.data[[col]] == "oui", na.rm = TRUE),
      Non   = sum(.data[[col]] == 'non', na.rm = TRUE),
      Total = sum(.data[[col]] == 'oui' | .data[[col]] == 'non', na.rm = TRUE),
      .groups = "drop"
    )

  wb <- createWorkbook()

  safe_name  <- substr(safe_name, 1, 28)
  safe_name1 <- paste(safe_name, '1')
  safe_name2 <- paste(safe_name, '2')
  addWorksheet(wb, safe_name1)
  addWorksheet(wb, safe_name2)

  writeData(wb, safe_name1, rf6)
  writeData(wb, safe_name2, df)
  col <- gsub("[^[:alnum:]_]", "_", col)
  saveWorkbook(wb, paste0('nouveaux_tableaux/', col, '.xlsx'), overwrite = TRUE)
}

#------------------------------------------------------------------------------#
#  9.1 Si oui, comment ? — Surveillance de la température durant le transport
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse$`Si  oui, comment ?`)

thermo            <- veto_data_corr_modalite_analyse[veto_data_corr_modalite_analyse$`Si  oui, comment ?` == 'Thermomètre', ]
autres_que_thermo <- veto_data_corr_modalite_analyse[veto_data_corr_modalite_analyse$`Si  oui, comment ?` != 'Thermomètre', ]

wb <- createWorkbook()
addWorksheet(wb, 'thermometre')
addWorksheet(wb, 'Autres')
writeData(wb, 'thermometre', thermo)
writeData(wb, 'Autres', thermo)

saveWorkbook(wb, 'nouveaux_tableaux\\temperature_vaccin_surveille_Si_oui_comment.xlsx')


#==============================================================================#
#  PARTIE X — MATÉRIEL DE TRANSPORT DES ÉQUIPEMENTS
#==============================================================================#
colonne3 <- c('glacières isothermes',
              'packs réfrigérants',
              'boîtes de protection pour les flacons',
              'thermomètres portables',
              'véhicules de transport équipés',
              'étiquettes et identifiants',
              'autre_moyen_transport')

for (col in colonne3) {
  print(col)
  cat('\n')
  print(table(veto_data_corr_modalite_analyse[[col]]))
  cat('\n')

  rf6 <- table(veto_data_corr_modalite_analyse[[col]])
  label5 <- paste(names(rf6), rf6)

  # Enregistrement graphique
  safe_name <- gsub("[^[:alnum:]_]", "_", col)
  safe_name <- substr(safe_name, 1, 100)
  print(safe_name)
  png(filename = paste(safe_name, '.png'), width = 2000, height = 1500, res = 150)
  pie(rf6, labels = label5, main = safe_name)
  dev.off()

  # Enregistrement Tableaux
  df <- veto_data_corr_modalite_analyse %>%
    group_by(`Poste ou statut de la personne enquêtée`) %>%
    summarise(
      cause     = sum(.data[[col]] == "1", na.rm = TRUE),
      cause_pas = sum(.data[[col]] == '0', na.rm = TRUE),
      Total     = sum(.data[[col]] == '1' | .data[[col]] == '0', na.rm = TRUE),
      .groups = "drop"
    )

  wb <- createWorkbook()

  safe_name  <- substr(safe_name, 1, 28)
  safe_name1 <- paste(safe_name, '1')
  safe_name2 <- paste(safe_name, '2')
  addWorksheet(wb, safe_name1)
  addWorksheet(wb, safe_name2)

  writeData(wb, safe_name1, rf6)
  writeData(wb, safe_name2, df)
  col <- gsub("[^[:alnum:]_]", "_", col)
  saveWorkbook(wb, paste0('tableaux/', col, '.xlsx'), overwrite = TRUE)
}

#------------------------------------------------------------------------------#
#  10.1 Barplot comparatif — équipements de transport
#------------------------------------------------------------------------------#
bar_plot5 <- table(veto_data_corr_modalite_analyse[[colonne3[1]]])
bar_plot5

for (col in colonne3) {
  if (col != colonne3[1] & col != 'autre_moyen_transport') {
    bar_plot5 <- c(bar_plot5, table(veto_data_corr_modalite_analyse[[col]]))
    table(veto_data_corr_modalite_analyse[[col]])
  }
}
bar_plot_5 <- bar_plot5[names(bar_plot5) == '1']

png(filename = 'bar_plot_recensem_equipement_transp.png', width = 2000, height = 1500, res = 150)

names(bar_plot_5) <- c('glacières isothermes',
                       'packs réfrigérants',
                       'boîtes de protection pour les flacons',
                       'thermomètres portables',
                       'véhicules de transport équipés',
                       'étiquettes et identifiants')
par(mar = c(16, 4, 4, 2))
barplot(bar_plot_5, main = "Barplot des differentes equipements de transport",
        ylab = "Frequences", las = 2, cex.names = 1.5, cex.axis = 1.2)

dev.off()


#==============================================================================#
#  PARTIE XI — FORMATION DES AGENTS
#==============================================================================#
colnames(veto_data_corr_modalite_analyse)

# Questions à traiter après : si oui, combien selon vous ? | Si oui, à quelle fréquence ?...105 | Si oui, à quelle périodicité ?
colonne4 <- c(
  "Avez-vous été formé sur le monitorage de la température de refrigérateur ?",
  "Avez-vous été formé sur le fonctionnement d’un refrigérateur?",
  "Connaissez-vous la température de stockage recommandée pour les vaccins ?",
  "Les vaccins sont-ils sensibles à la chaleur ?",
  "Le vaccin peut – il – retrouvé son activité après exposition à la chaleur quand on rétablie la température de stockage ?",
  "Est – t – il possible de distinguer un flacon de vaccin inactif sans un essai de laboratoire complet ?"
)

for (col in colonne4) {
  print(col)
  cat('\n')
  print(table(veto_data_corr_modalite_analyse[[col]]))
  cat('\n')

  rf6 <- table(veto_data_corr_modalite_analyse[[col]])
  label5 <- paste(names(rf6), rf6)

  safe_name <- gsub("[^[:alnum:]_]", "_", col)
  safe_name <- substr(safe_name, 1, 100)
  print(safe_name)
  png(filename = paste(safe_name, '.png'), width = 2000, height = 1500, res = 150)
  pie(rf6, labels = label5, main = safe_name)
  dev.off()

  df <- veto_data_corr_modalite_analyse %>%
    group_by(`Poste ou statut de la personne enquêtée`) %>%
    summarise(
      oui   = sum(.data[[col]] == "oui", na.rm = TRUE),
      non   = sum(.data[[col]] == 'non', na.rm = TRUE),
      Total = sum(.data[[col]] == 'oui' | .data[[col]] == 'non', na.rm = TRUE),
      .groups = "drop"
    )

  wb <- createWorkbook()

  safe_name  <- substr(safe_name, 1, 28)
  safe_name1 <- paste(safe_name, '1')
  safe_name2 <- paste(safe_name, '2')
  addWorksheet(wb, safe_name1)
  addWorksheet(wb, safe_name2)

  writeData(wb, safe_name1, rf6)
  writeData(wb, safe_name2, df)
  col <- gsub("[^[:alnum:]_]", "_", col)
  saveWorkbook(wb, paste0('nouveaux_tableaux/', col, '.xlsx'), overwrite = TRUE)
}

#------------------------------------------------------------------------------#
#  11.1 Température de stockage — si oui, combien selon vous ?
#------------------------------------------------------------------------------#
x <- table(veto_data_corr_modalite_analyse[["si oui, combien selon vous?"]])

x <- as.data.frame(x)
colnames(x) <- c('valeurs', 'freq')
x_autres <- x[x['valeurs'] != '[2,8]', ]

somme_autres <- sum(x_autres[, 'freq'])
somme_autres

x_vrai <- x[x['valeurs'] == '[2,8]', ]
vrai   <- x_vrai[, 'freq']

x <- data.frame(nom = c('autres', '[2,8]'), frequences = c(somme_autres, vrai))
x
row.names(x) <- c('autres', '[2,8]')
write.xlsx(x, 'nouveaux_tableaux\\temperature_stocckage_si_oui_combien_selon_vous.xlsx')

# Par poste
veto_data_corr_modalite_analyse_copy <- veto_data_corr_modalite_analyse

veto_data_corr_modalite_analyse_copy[!is.na(veto_data_corr_modalite_analyse_copy$`si oui, combien selon vous?`) &
                                       veto_data_corr_modalite_analyse_copy$`si oui, combien selon vous?` != "[2,8]", 'si oui, combien selon vous?'] <- 'autres'

veto_data_corr_modalite_analyse_copy$`si oui, combien selon vous?`
table(veto_data_corr_modalite_analyse_copy$`Poste ou statut de la personne enquêtée`)

x <- veto_data_corr_modalite_analyse_copy %>%
  group_by(`Poste ou statut de la personne enquêtée`) %>%
  summarise(
    normal = sum(.data[['si oui, combien selon vous?']] == "[2,8]", na.rm = TRUE),
    autre  = sum(.data[['si oui, combien selon vous?']] != "[2,8]", na.rm = TRUE)
  )
x
write.xlsx(x, 'nouveaux_tableaux\\temperature_stocckage_si_oui_combien_selon_vous_POSTE.xlsx')

# Barplot comparatif
png(filename = 'bar_plot_comparaison_connaissance_temp.png', width = 2000, height = 1500, res = 150)
barplot(table(veto_data_corr_modalite_analyse[["si oui, combien selon vous?"]]),
        main = "si oui, combien selon vous?", ylab = "Frequences",
        las = 2, cex.names = 1.5, cex.axis = 1.2)
dev.off()


#==============================================================================#
#  PARTIE XII — PRATIQUES SUR LE TERRAIN
#==============================================================================#
# Questions à traiter après : si oui, combien selon vous ?
#   "Si oui, à quelle fréquence ?...105"
#   "Si oui, à quelle périodicité ?"
#   "Si oui, à quelle fréquence ?...113"
#   "Autres difficultés que vous rencontrez dans la gestion de la chaîne de froid des vaccins dans votre zone"
#   "Qui est responsable de la chaîne du froid et du générateur pendant les week-ends et les vacances ?"

colnames(veto_data_corr_modalite_analyse)

colonne5 <- c(
  "Y a t-il des vaccins expirés dans le réfrigérateur ?",
  "Le test de secousse est-il réalisé  ?",
  "Le principe Premier expiré, premier sorti est-il appliqué ?",
  "Les réfrigérateurs sont-ils dédiés uniquement qu’aux vaccins ?",
  "Les températures de conservation correspondent-elles aux recommandations du fabriquant ?",
  "Les vaccins sont-ils séparés en fonction de leur nature ?",
  "En cas d’arrêt du réfrigérateur, existe-t-il un système de relais pour le maintien de la chaîne de froid ?",
  "Le réfrigérateur est – il nettoyé régulièrement ?",
  "Les glacières et portes-vaccins sont - ils nettoyés, séchés et entrepris le couvercle ouvert après utilisation ?",
  "Existe-t-il un calendrier de remplacement adapté ?",
  "Réalisez-vous souvent l'inventaire des équipements ?",
  "Vérifiez – vous régulièrement le niveau de gaz dans les réfrigérateurs ?",
  "Vérifiez – vous régulièrement le niveau de pétrole et de la mèche (ou tout autre source d’énergie) ?",
  "Eliminez – vous régulièrement les givres ?",
  "Vérifiez – vous l’état des joints de la porte du réfrigérateur ?",
  "Existe – t – il un technicien chargé de l’entretien des appareils de la chaîne de froid ?",
  "Existe-t-il une description des tâches pour cet agent ?"
)

for (col in colonne5) {
  print(col)
  cat('\n')
  print(table(veto_data_corr_modalite_analyse[[col]]))
  cat('\n')

  rf6 <- table(veto_data_corr_modalite_analyse[[col]])
  label5 <- paste(names(rf6), rf6)

  safe_name <- gsub("[^[:alnum:]_]", "_", col)
  safe_name <- substr(safe_name, 1, 100)
  print(safe_name)
  png(filename = paste(safe_name, '.png'), width = 2000, height = 1500, res = 150)
  pie(rf6, labels = label5, main = safe_name)
  dev.off()

  df <- veto_data_corr_modalite_analyse %>%
    group_by(`Poste ou statut de la personne enquêtée`) %>%
    summarise(
      Oui   = sum(.data[[col]] == "oui", na.rm = TRUE),
      Non   = sum(.data[[col]] == 'non', na.rm = TRUE),
      Total = sum(.data[[col]] == 'oui' | .data[[col]] == 'non', na.rm = TRUE),
      .groups = "drop"
    )

  wb <- createWorkbook()

  safe_name  <- substr(safe_name, 1, 28)
  safe_name1 <- paste(safe_name, '1')
  safe_name2 <- paste(safe_name, '2')
  addWorksheet(wb, safe_name1)
  addWorksheet(wb, safe_name2)

  writeData(wb, safe_name1, rf6)
  writeData(wb, safe_name2, df)
  col <- gsub("[^[:alnum:]_]", "_", col)
  saveWorkbook(wb, paste0('nouveaux_tableaux/', col, '.xlsx'), overwrite = TRUE)
}

#------------------------------------------------------------------------------#
#  12.1 Si oui, à quelle fréquence ?...105
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse[["Si oui, à quelle fréquence ?...105"]])
png(filename = 'Si oui, à quelle fréquence ...105.png', width = 2000, height = 1500, res = 150)

par(mar = c(16, 4, 4, 2))
barplot(table(veto_data_corr_modalite_analyse[["Si oui, à quelle fréquence ?...105"]]),
        main = "Si oui, à quelle fréquence ?...105", ylab = "Frequences",
        las = 2, cex.names = 1.5, cex.axis = 1.2)
dev.off()

#------------------------------------------------------------------------------#
#  12.2 Si oui, à quelle périodicité ?
#------------------------------------------------------------------------------#
table(veto_data_corr_modalite_analyse[['Si oui, à quelle périodicité ?']])

png(filename = 'Si oui, à quelle périodicité.png', width = 2000, height = 1500, res = 150)
par(mar = c(16, 4, 4, 2))
barplot(table(veto_data_corr_modalite_analyse[["Si oui, à quelle périodicité ?"]]),
        main = "Si oui, à quelle périodicité ?", ylab = "Frequences",
        las = 2, cex.names = 1.5, cex.axis = 1.2)
dev.off()

#------------------------------------------------------------------------------#
#  12.3 Si oui, à quelle fréquence ?...113
#------------------------------------------------------------------------------#
sf <- table(veto_data_corr_modalite_analyse[['Si oui, à quelle fréquence ?...113']])
write.xlsx(sf, 'tableaux/Si oui, à quelle fréquence...113.xlsx')

#------------------------------------------------------------------------------#
#  12.4 Responsable de la chaîne du froid pendant les week-ends / vacances
#------------------------------------------------------------------------------#
rfg <- table(veto_data_corr_modalite_analyse[["Qui est responsable de la chaîne du froid et du générateur pendant les week-ends et les  vacances ?"]])
write.xlsx(rfg, 'tableaux/Qui est responsable de la chaîne du froid et du générateur pendant les week-ends et les  vacances.xlsx')

#------------------------------------------------------------------------------#
#  12.5 Autres difficultés rencontrées
#------------------------------------------------------------------------------#
adr <- table(veto_data_corr_modalite_analyse[['Autres difficultés que vous rencontrez dans la gestion de la chaîne de froid des vaccins dans votre zone']])
write.xlsx(adr, 'tableaux/Autres difficultés que vous rencontrez dans la gestion de la chaîne de froid des vaccins dans votre zone.xlsx')

#------------------------------------------------------------------------------#
#  12.6 Croisement Sexe / Niveau / Utilisation des vaccins
#------------------------------------------------------------------------------#
spne <- veto_data_corr_modalite_analyse %>%
  group_by(Sexe, `A quel niveau de la chaîne vous trouvez vous?`, `utilisation des vaccins`) %>%
  count()

View(spne)
write.xlsx(spne, 'spne.xlsx')


#==============================================================================#
#  PARTIE XIII — ATTRIBUTION DE SCORES — CONNAISSANCES
#==============================================================================#
df <- read_excel("C:\\Users\\pc\\Downloads\\connaissance compilés.xlsx")
colonnes <- colnames(df)
nrow(df)
colonnes <- colonnes[-c(1)]
colonnes

somme <- 0
df$Scores <- 0
head(df)

for (indice in seq(1, nrow(df))) {
  for (col in colonnes) {
    if (df[indice, col] == 'oui' && !(col %in% c(colonnes[length(colonnes)], colonnes[length(colonnes) - 1]))) {
      somme = somme + 1
    }
    if (col %in% c(colonnes[length(colonnes)], colonnes[length(colonnes) - 1])) {
      if (df[indice, col] == 'non') {
        somme = somme + 1
        print(somme)
        print(col %in% c(colonnes[length(colonnes)], colonnes[length(colonnes) - 1]))
      }
    }
  }
  df[indice, 'Scores'] <- somme

  somme <- 0
  print(indice)
}

View(df)

# Scores >= 5
scores_recap <- df %>%
  group_by(`Poste ou statut de la personne enquêtée`) %>%
  summarise(
    scores_plus_de_5  = sum(.data[["Scores"]] >= 5, na.rm = TRUE),
    scores_moins_de_4 = sum(.data[["Scores"]] <= 4, na.rm = TRUE),
    Total             = sum(.data[["Scores"]] >= 5 | .data[["Scores"]] <= 4, na.rm = TRUE)
  )
View(scores_recap)

write.xlsx(scores_recap, "scores_recap.xlsx")
write.xlsx(df, 'connaissance_compile.xlsx')


#==============================================================================#
#  PARTIE XIV — ATTRIBUTION DE SCORES — PRATIQUES
#==============================================================================#
df2 <- read_excel("C:\\Users\\pc\\Downloads\\pratiques compilés nettoyées.xlsx")
colonnes <- colnames(df2)
nrow(df2)
colonnes <- colonnes[-c(1)]
length(colonnes)

somme <- 0
df2$Scores <- 0
head(df2)
is.na(df2)

# Initialiser la colonne Scores
df2$Scores <- 0

for (indice in seq_len(nrow(df2))) {
  somme <- 0  # réinitialisation à chaque ligne

  for (col in colonnes) {
    if (!(col %in% c("le toit  présente-t-il des fuites ?",
                     "Y a t-il des vaccins expirés dans le réfrigérateur ?"))) {
      if (!is.na(df2[indice, col]) && df2[indice, col] == "oui") {
        somme <- somme + 1
      }
    }
  }

  df2$Scores[indice] <- somme
  cat("Ligne", indice, "traitée\n")
}

View(df2)
ncol(df2)

# Scores >= 17
scores_recap_pratiques <- df2 %>%
  group_by(`Poste ou statut de la personne enquêtée`) %>%
  summarise(
    scores_plus_de_17  = sum(.data[["Scores"]] >= 17, na.rm = TRUE),
    scores_moins_de_17 = sum(.data[["Scores"]] <= 16, na.rm = TRUE),
    Total              = sum(.data[["Scores"]] >= 17 | .data[["Scores"]] <= 16, na.rm = TRUE)
  )
View(scores_recap_pratiques)

write.xlsx(scores_recap_pratiques, "scores_recap_pratiques.xlsx")
write.xlsx(df2, 'pratique_compile.xlsx')

table(df2$Scores)
sum(df2$Scores)


#==============================================================================#
#  PARTIE XV — TESTS DE CHI² (CONNAISSANCES & PRATIQUES)
#==============================================================================#

#------------------------------------------------------------------------------#
#  15.1 Catégorisation des scores — CONNAISSANCES
#------------------------------------------------------------------------------#
moyenne <- mean(df[["Scores"]], na.rm = TRUE)
moyenne

df$Scores_cat <- ifelse(df[["Scores"]] > moyenne, "Bonne",
                        ifelse(df[["Scores"]] == moyenne, "Passable", "Faible"))

getwd()
setwd("C:\\Users\\pc\\these_Gloria")
View(df)
df

df$annee_experience <- veto_data_corr_modalite_analyse$`utilisation des vaccins`
df$Niveau           <- veto_data_corr_modalite_analyse$Niveau
View(df)
View(veto_data_corr_modalite_analyse)

# Tableau croisé chi² — CONNAISSANCES
sink("resultats_tests_connaissances.txt")

print(df$Niveau)

for (col in c("Niveau")) {
  tb <- table(df[[col]], df$Scores_cat)
  print(tb)

  cat("TEST ", col, "vs connaissances\n")

  result <- tryCatch(
    chisq.test(tb),
    warning = function(w) {
      cat("Avertissement :", conditionMessage(w), "\n")
      return(chisq.test(tb, simulate.p.value = TRUE, B = 10000))
    },
    error = function(e) {
      cat("Erreur :", conditionMessage(e), "\n")
      if (all(dim(tb) == 2)) {
        return(fisher.test(tb))
      } else {
        return(NULL)
      }
    }
  )

  print(result)
  cat("\n--------------------------------------\n")
}

sink()

head(df)

#------------------------------------------------------------------------------#
#  15.2 Catégorisation des scores — PRATIQUES
#------------------------------------------------------------------------------#
moyenne_2 <- mean(df2[["Scores"]], na.rm = TRUE)
moyenne_2

df2$Scores_cat_2 <- ifelse(df2[["Scores"]] > moyenne, "Bonne",
                           ifelse(df2[["Scores"]] == moyenne, "Passable", "Faible"))

head(df2)

df2$annee_experience <- veto_data_corr_modalite_analyse$`utilisation des vaccins`
View(df2)

sink("resultats_tests_pratiques.txt")
for (col in c("annee_experience", "Poste ou statut de la personne enquêtée")) {
  tb <- table(df2[[col]], df2$Scores_cat_2)

  cat("TEST ", col, "vs les pratiques\n")

  result <- tryCatch(
    chisq.test(tb),
    warning = function(w) {
      cat("Avertissement :", conditionMessage(w), "\n")
      return(chisq.test(tb, simulate.p.value = TRUE, B = 10000))
    },
    error = function(e) {
      cat("Erreur :", conditionMessage(e), "\n")
      if (all(dim(tb) == 2)) {
        return(fisher.test(tb))
      } else {
        return(NULL)
      }
    }
  )

  print(result)
  cat("\n--------------------------------------\n")
}

sink()

#------------------------------------------------------------------------------#
#  15.3 Croisement pratiques ↔ connaissances
#------------------------------------------------------------------------------#
df_t   <- df[, 'Scores_cat']
df_t

df2_t  <- df2[, 'Scores_cat_2']
df2_t

df_final <- cbind(df_t, df2_t)

crosstab <- table(df_final$Scores_cat, df_final$Scores_cat_2)
crosstab

chisq.test(crosstab)

#------------------------------------------------------------------------------#
#  15.4 Tests pratiques corrigés + Odds Ratios
#------------------------------------------------------------------------------#
sink("resultats_tests_pratiques_corriges.txt")

for (col in c("annee_experience", "Poste ou statut de la personne enquêtée")) {

  # 1. Préparation des données
  df2[[col]]        <- as.factor(df2[[col]])
  df2$Scores_cat_2  <- as.factor(df2$Scores_cat_2)

  tb <- table(df2[[col]], df2$Scores_cat_2)

  cat("\n==================================================================\n")
  cat("TEST ET ODDS RATIOS :", col, "vs les pratiques (Scores_cat_2)\n")
  cat("==================================================================\n\n")

  cat("--- Table de contingence ---\n")
  print(tb)
  cat("\n")

  # 2. TEST DE KHI-DEUX (avec simulation de Monte Carlo)
  cat("--- Test de Chi-deux ---\n")
  result_chisq <- tryCatch(
    chisq.test(tb, simulate.p.value = TRUE, B = 10000),
    error = function(e) {
      cat("Erreur lors du Chi-deux :", conditionMessage(e), "\n")
      return(NULL)
    }
  )
  if (!is.null(result_chisq)) {
    print(result_chisq)
  }
  cat("\n")

  # 3. ODDS RATIOS VIA RÉGRESSION LOGISTIQUE
  cat("--- Odds Ratios (OR) et Intervalles de Confiance (IC 95%) ---\n")
  cat("Note : La première modalité alphabétique est prise comme référence (OR = 1).\n\n")

  modele <- tryCatch(
    glm(Scores_cat_2 ~ df2[[col]], data = df2, family = binomial),
    error = function(e) {
      cat("Erreur lors de la modélisation :", conditionMessage(e), "\n")
      return(NULL)
    }
  )

  if (!is.null(modele)) {
    coefficients <- summary(modele)$coefficients
    or <- exp(coef(modele))

    ic <- tryCatch(
      exp(confint.default(modele)),
      error = function(e) {
        return(matrix(NA, ncol = 2, nrow = length(or)))
      }
    )

    table_or <- data.frame(
      `Odds Ratio (OR)` = round(or, 3),
      `IC 95% Inf`      = round(ic[, 1], 3),
      `IC 95% Sup`      = round(ic[, 2], 3),
      `p-value`         = round(coefficients[, 4], 4),
      check.names = FALSE
    )

    rownames(table_or) <- gsub("df2\\[\\[col\\]\\]", paste0(col, " : "), rownames(table_or))
    rownames(table_or)[1] <- paste0("(Référence) ", levels(df2[[col]])[1])

    print(table_or)

    if (any(tb[, "Faible"] == 0) || any(tb[, "Bonne"] == 0)) {
      cat("\nRemarque : Certains OR ou IC peuvent être extrêmes (proches de 0 ou Inf)\n")
      cat("en raison d'un effectif nul (0) dans l'une des cases de la table.\n")
    }
  } else {
    cat("Impossible de calculer les Odds Ratios pour cette variable.\n")
  }

  cat("\n------------------------------------------------------------------\n")
}

sink()


#==============================================================================#
#  PARTIE XVI — ANALYSE 2 : PRATIQUES (fichier unifié)
#==============================================================================#
getwd()
setwd("C:/Users/pc/these_Gloria")
df <- read_excel("pratiques uniq vf.xlsx")
View(df)
ncol(df)

colonnes <- colnames(df)
colonnes

df$Scores <- 0

for (indice in seq_len(nrow(df))) {
  somme <- 0  # réinitialisation à chaque ligne

  for (col in colonnes) {
    if (!(col %in% c("le toit  présente-t-il des fuites ?",
                     "Y a t-il des vaccins expirés dans le réfrigérateur ?",
                     "Le toit  présente-t-il des fuites ?",
                     "Y a t-il des vaccins expirés dans le réfrigérateur ?"))) {

      if (!is.na(df[indice, col]) && df[indice, col] == "oui") {
        somme <- somme + 1
      }
    }
    else if (col %in% c("Y a t-il des vaccins expirés dans le réfrigérateur ?",
                        "Le toit  présente-t-il des fuites ?")) {
      if ((!is.na(df[indice, col]) && df[indice, col] == "non")) {
        somme <- somme + 1
      }
    }
  }

  df$Scores[indice] <- somme
  cat("Ligne", indice, "traitée\n")
}

View(df)
write.xlsx(df, 'pratiques.xlsx')
write.csv(df, 'pratique_compile.csv')

vars <- c(
  "Poste ou statut de la personne enquêtée",
  "Sexe",
  "Tranche d’âges",
  "utilisation des vaccins",
  "Avez-vous déjà été formé sur la gestion de la chaine de froid des vaccins ?",
  "Existe-t-il un protocole ou guide de gestion de la chaîne du froid dans votre structure ?",
  "evaluation"
)

for (col in vars) {
  df[col] <- df_var_Associe[[col]]
}

df$evaluation_pratiques <- ''

for (i in seq(1, length(df$Scores))) {
  if (df$Scores[i] >= 16) {
    df$evaluation_pratiques[i] = "bonnes pratiques"
  } else {
    df$evaluation_pratiques[i] = "mauvaises pratiques"
  }
}
View(df)

#------------------------------------------------------------------------------#
#  16.1 Chi² et Odds Ratio — Pratiques
#------------------------------------------------------------------------------#
if (!require(epitools)) install.packages("epitools")
library(epitools)

vars <- c(
  "Poste ou statut de la personne enquêtée",
  "Sexe",
  "Tranche d’âges",
  "utilisation des vaccins",
  "Avez-vous déjà été formé sur la gestion de la chaine de froid des vaccins ?",
  "Existe-t-il un protocole ou guide de gestion de la chaîne du froid dans votre structure ?",
  "evaluation"
)

sink("resultats_tests_chi2_oddsratio.txt")

for (col in vars) {
  cat("\n=============================================\n")
  cat("Variable :", col, "vs evaluation pratiques \n")
  cat("=============================================\n")

  tb <- table(df[[col]], df$evaluation_pratiques)
  print(tb)

  result <- tryCatch(
    chisq.test(tb),
    warning = function(w) {
      cat("⚠️ Avertissement :", conditionMessage(w), "\n")
      cat("Relance avec simulation Monte Carlo...\n")
      return(chisq.test(tb, simulate.p.value = TRUE, B = 10000))
    },
    error = function(e) {
      cat("❌ Erreur :", conditionMessage(e), "\n")
      if (all(dim(tb) == 2)) {
        cat("Utilisation du test exact de Fisher.\n")
        return(fisher.test(tb))
      } else {
        return(NULL)
      }
    }
  )

  cat("\n--- Résultats du test ---\n")
  print(result)

  if (all(dim(tb) == 2)) {
    cat("\n--- Odds Ratio ---\n")
    or <- oddsratio(tb)
    print(or)
  }

  cat("\n---------------------------------------------\n")
}

sink()


#==============================================================================#
#  PARTIE XVII — CONNAISSANCES : ASSOCIATION & TESTS CHI²
#==============================================================================#
df1           <- read_excel("C:\\Users\\pc\\these_Gloria\\scores connaissances VF1.xlsx")
df_var_Associe <- read_excel("V. associés connaissances VF1.xlsx")
View(df_var_Associe)
View(df1)

#------------------------------------------------------------------------------#
#  17.1 Calcul des connaissances
#------------------------------------------------------------------------------#
df_var_Associe$evaluation_connaissance <- ''

for (i in seq(1, length(df_var_Associe$`Scores Total`))) {
  if (df_var_Associe$`Scores Total`[i] >= 5) {
    df_var_Associe$evaluation[i] = "satisfaisant"
  } else {
    df_var_Associe$evaluation[i] = "non satisfaisant"
  }
}
View(df_var_Associe)

col <- colnames(df_var_Associe)
print(col)

#------------------------------------------------------------------------------#
#  17.2 Tableaux croisés — Connaissances
#------------------------------------------------------------------------------#
sink("tableaux_croise_connaissances.txt")
cat("---------------------TABLEAUX CROISÉS --------------------\n")

for (v in col) {
  tb <- table(df_var_Associe[[v]], df_var_Associe$evaluation)

  cat("Tableau croisé", v, "vs evaluation\n")
  print(tb)
  cat("\n")
}
View(df_var_Associe)
sink()

#------------------------------------------------------------------------------#
#  17.3 Test de Chi² — Connaissances
#------------------------------------------------------------------------------#
if (!require(epitools)) install.packages("epitools")
library(epitools)

sink("TEST_CHI2_connaissances.txt")
cat("---------------------TABLEAUX CROISÉS, CHI² ET ODDS RATIO --------------------\n")

for (v in col) {
  if (v %in% names(df_var_Associe)) {
    tb <- table(df_var_Associe[[v]], df_var_Associe$evaluation)

    cat("\n### Variable :", v, "vs evaluation ###\n")
    print(tb)
    cat("\n")

    chi <- tryCatch(chisq.test(tb), error = function(e) NULL)
    if (!is.null(chi)) {
      cat("Test du Chi² :\n")
      cat("Chi² =", chi$statistic, " | ddl =", chi$parameter, " | p-value =", chi$p.value, "\n\n")
    }

    if (all(dim(tb) == c(2, 2))) {
      or <- oddsratio(tb, method = "wald")
      cat("Odds Ratio (OR) avec IC95% :\n")
      print(or$measure)
      cat("\n")
      cat("Test d'association (p-value) :\n")
      print(or$p.value)
      cat("\n")
    } else {
      cat("⚠️ OR non calculé (tableau non 2x2)\n\n")
    }

    cat("--------------------------------------\n")
  } else {
    cat("⚠️ Colonne", v, "absente du data frame\n")
  }
}

sink()

View(df_var_Associe)

#==============================================================================#
#  FIN DE L'ANALYSE — CHAÎNE DE FROID VACCINS VÉTÉRINAIRES BURKINA FASO
#==============================================================================#