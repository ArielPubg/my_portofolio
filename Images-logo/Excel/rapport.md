# Tableau de bord des ventes — Épicerie multi-boutiques

**Contexte** — Burkina Faso · Secteur : épicerie / alimentation générale

## Le problème

Une chaîne de 5 boutiques (Ouagadougou ×2, Bobo-Dioulasso, Koudougou, Ouahigouya) enregistre ses ventes en CSV, boutique par boutique, sans vision consolidée. Impossible de répondre rapidement à des questions simples : quelle boutique performe le mieux ? Quel est le panier moyen ? Quels produits génèrent le plus de marge ? Comment les ventes évoluent-elles selon les saisons (Ramadan, Tabaski, hivernage) ?

## L'approche

Le projet s'articule autour d'un système de suivi et de consolidation structuré :

**1. Structure et consolidation des données**
Consolidation de ~20 000 transactions sur 12 mois, couvrant :
- 28 produits d'épicerie courants au Burkina Faso (riz local/importé, mil, sorgho, huile Sunny/Diamaor, sucre, pâtes, lait, thé, café, boissons, savons)
- une saisonnalité calée sur le calendrier burkinabè réel (pic Ramadan +45% sur les produits de base, Tabaski, rentrée scolaire, baisse d'activité pendant l'hivernage à cause des routes, pic des fêtes de fin d'année)
- un effet jour de la semaine (vendredi/week-end plus actifs)
- une répartition réaliste des modes de paiement (Espèces, Orange Money, Moov Money)

**2. Construction du tableau de bord**
Le classeur (7 feuilles) est entièrement piloté par formules Excel natives (`SUMIFS`, `COUNTIFS`, `AVERAGEIFS`) plutôt que par des valeurs codées en dur — si les données changent, tout le tableau de bord se recalcule automatiquement.

| Feuille | Contenu |
|---|---|
| Dashboard | Synthèse visuelle : cartes KPI + graphiques clés |
| KPI | CA total, marge brute, taux de marge, panier moyen |
| Par_Boutique | CA / marge / panier moyen par boutique, avec graphique |
| Par_Mois | Évolution mensuelle du CA, courbe de tendance |
| Top_Produits | Top 10 produits par CA, dégradé de couleur conditionnel |
| Paiements | Répartition des modes de paiement, camembert |

**3. Automatisation via macros VBA**
Un module VBA (`RefreshMacros.bas`) ajoute 4 macros : actualisation complète du classeur, filtrage de la table de données par boutique, export de la feuille Dashboard en PDF, et réinitialisation des filtres.

## Résultats

- **CA total 2025** : 38 415 977 FCFA
- **Taux de marge brute** : 22,6 %
- **Panier moyen** : 1 896 FCFA
- **20 263 transactions** sur 5 boutiques, 12 mois

## Architecture & Méthodologie

Utilisation de **formules Excel natives** (pas de valeurs codées en dur), garantissant un recalcul automatique fluide et vérifié sans erreur sur l'ensemble des 96 formules du classeur.

## Remarques et hypothèses

L'objectif principal est de présenter la méthode d'analyse et de consolidation globale (architecture par formules, suivi de la saisonnalité, automatisation VBA). Les taux de marge par catégorie reposent sur des hypothèses documentées directement dans le classeur.