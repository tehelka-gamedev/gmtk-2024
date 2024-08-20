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
- Voir l'éclairage du niveau
- Voir pourquoi la wheel est mal setup
- Tester sur différents navigateurs
- Finir la page Itch.io
- Revoir le cercle de jeu pour mettre un peu de transparence sur les bords peut-être
- Ecrire les crédits !
- Faire quelques niveaux en plus

### Chose à polish
- Menu principal
- Polish le panneau avec les controls
- Photo de la tour à la fin (angle et distance par exemple)
	- Faire un barycentre pondéré par la taille des objets
- Bloquer le zoom in/out à une certaine profondeur
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
- Tuto interactif avec label3d


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
