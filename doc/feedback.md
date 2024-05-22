# Feedback

- Utilise `gg.screen_size()` pour obtenir la taille effective de l'écran au lieu de hardcoder la taille.
- Notion d'entité/widget: chaque objet à l'écran devrait être une struct avec une fonction `.draw()` et `.on_click()`, comme ça tu peux sortir toute la logique liée aux objets peuvent être sortis de la fonction on_frame(). 
- En règle générale, si tu as plus de 4 niveaux d'indentation alors tes fonctions sont trop complexes et tu devrais les découper en plusieurs sous-fonctions.
- Ne pas hésiter à rattacher les fonctions aux structs qu'elles manipulent.
- Ne pas utiliser de "magic numbers": toutes les valeurs numériques devraient être nommées!
