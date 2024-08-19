## TODO

Processus d'import des assets 3D
- changer le root scale
- décocher animation
- clicker reimport
- faire un new inherited scene de gameobject.tscn
- rajouter le fbx en enfant du root node
- setup le scale_pivot sur le root node qui fait office de centre de gravité
- renomme le mesh "Mesh"
- ajouter un fiston à $Mesh : "MassCenter" (Marker3D)
- mettre le mesh dans la variable exportée "model" du GameObject
- créer les collisions shapes à la main / ou les générer par godot
- retype les collisions shapes en ScallableCollisionShape3D


### Choses à faire en priorité
- Ajouter le scale factor à l'UI
- Faire la page Itch.io
- Faire environment
	- Ajouter des arbres
	- Faire backdrop ou je sais pas quoi
	- Trouver une texture pour le sol
	- Mettre de l'herbe
- Menu pause avec bouton pour relancer le niveau (et pas aller au menu principal)
	- Afficher les controls sur le menu pause
- Améliorer le menu principale
	- renommer bouton play en sandbox et le déplacer sans les paramètres (renommer label debug paramètres)
	- mettre les niveaux en liste vbox sur la gauche
- Intégrer le titre au menu principal
- Mettre un grand cylindre de collision arène
- Intégrer les musiques
- Ecrire les crédits !
- Bruit de collision
- Faire quelques niveaux en plus

### Chose à polish
- Photo de la tour à la fin (angle et distance par exemple)
	- Faire un barycentre pondéré par la taille des objets
- Bloquer le zoom in/out à une certaine profondeur
- Tuto interactif avec label3d
- Demander à Meru de faire de l'UI ingame HUD voir pour les menus
- Faire en sorte que le score bouge pas quand on lâche un objet de haut


### Choses pour plus tard
- mettre plus de chiffres sur l'UI pour que le joueur sente mieux les différences
	de scaling factor entre les objets ? Voire les indiquer directement d'une
	manière ou d'une autre
- fix le bug pour la roue qui rotate brusquement quand on la rotate (après être tombée au sol)
- mettre un bouton pour faire tourner la caméra autour de l'objet sélectionné
- maybe update the heightlabel when the game is launcherz
	-> currently, 1 second is elapsed before the first update
	-> problem is if we use _detect_current_max_height at launched,
	main.gd has not connected the signal yet to change the heighlabel on the billboard
- pause menu
- center camera on selected object (done for now, object is moving and not the camera)
- improve object rotation
- Fond interractif pour le menu principal


### Basic level
- basic lighting and environment
- basic plane for floor
- basic objects to prototype: cube, sphere, ...

### Core mechanics
- free roaming camera
- selecting object : hold select input
	- inputs to rotate XYZ the object and scale the object
- make sure collision between objects is ok
- detect a given height

### Other
- outline shader (when hovering object)
