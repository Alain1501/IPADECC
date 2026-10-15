# Site IPADECC

Site statique de l'association IPADECC (praticiens à diplôme hors Union européenne).

## Contenu

- `index.html` : le site à rubriques (Statuts, Démarches, EVC, Autorisation, Calendrier, Actualités, Ressources, L'association) avec menus déroulants, une page par sujet et le formulaire d'adhésion.
- `simulateur.html` : le simulateur Padhue pour les médecins. Aucune donnée n'est enregistrée ni envoyée.
- `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png` : installation sur téléphone et lecture hors connexion (sur HTTPS, comme GitHub Pages).
- `.nojekyll` : évite le traitement Jekyll sur GitHub Pages.

Aucune étape de compilation. Chaque fichier est autonome (le logo est intégré). Seules les polices Google Fonts sont chargées à distance.

## Mettre en ligne avec GitHub Pages

1. Créer un dépôt GitHub et y déposer le contenu de ce dossier à la racine.
2. Dans le dépôt : Settings, Pages, Source « Deploy from a branch », branche `main`, dossier `/ (root)`.
3. Le site est publié à l'adresse indiquée par GitHub (https://NOM.github.io/DEPOT/).

## Mettre à jour

- Les montants, seuils et dates changent par arrêté. Ils se trouvent dans `simulateur.html` (constantes `PACT`, `PA1`, `PA2`, `SUJ`, `FFI_N`, `FFI_W`, `CLOSE`, tableau `SPECS`) et dans `index.html` (cartes de la rubrique Statuts).
- Les sources de chaque information sont listées dans le tableau `SRC` du simulateur.

## Calendrier

Les échéances du compte à rebours sont dans le tableau `EV` de `index.html` (date ISO avec décalage horaire, titre, source). Pour ajouter ou corriger une date, modifier ce tableau avec la source officielle.

## Limites

- Le formulaire d'adhésion prépare un message à copier ou à ouvrir dans la messagerie. Il n'envoie rien tout seul.
- L'espace membres du site publié sur Claude n'est pas inclus : il dépend de la plateforme Claude (partage et base de données).
- Les informations ne remplacent pas l'avis de l'ARS, du CNG ou de la préfecture.
