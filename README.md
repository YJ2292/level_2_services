# level_2_services
Code sur matlab pour créer une matrice de destination de trajets de transport en commun. Par exemple, pour un trajet de bus qui part d’une station A, qui se dirige vers une station D et qui passe par les stations B et C, les segments de trajet complet seront: AB AC AD BC BD CD. De plus, le programme effectue un nettoyage des segments qui partent d’une même origine et qui se superposent.
Comme entrée, il faut un fichier CSV rangé en ordre croissant selon les champs suivants: le numéro de la ligne de bus, la direction du trajet de bus, les heures de départ,  et le numéro de la séquence du trajet.
Il est possible de choisir la plage horaire souhaitée et l’angle de similarité limite.
