# Site IPADECC

Site de l'association IPADECC (praticiens à diplôme hors Union européenne). Ouvrez `LISEZ-MOI.html` pour la mise en route complète.

## Contenu

- `index.html` : le site à rubriques (Statuts, Démarches, EVC, Autorisation, Calendrier, Actualités, Ressources, L'association).
- `simulateur.html` : le simulateur Padhue. Aucune donnée n'est enregistrée ni envoyée.
- `espace.html` : l'espace membres et l'administration (nécessite le service de comptes, voir `LISEZ-MOI.html`).
- `config.js` : adresse et clé publique du service de comptes.
- `supabase/schema.sql` : script de création de la table et des règles de sécurité.
- `vendor/supabase.js` : bibliothèque du service de comptes (version 2.45.4), servie par le site lui-même.
- `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png` : installation sur téléphone.
- `.nojekyll` : évite le traitement Jekyll sur GitHub Pages.

## Mettre à jour

- Montants, seuils et dates du simulateur : constantes de `simulateur.html`.
- Échéances du calendrier : tableau `EV` de `index.html`.
- Membres du bureau : bloc JSON `bur-data` de `index.html` (id, role, name, photo).
