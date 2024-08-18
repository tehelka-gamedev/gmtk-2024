## TODO

Processus d'import des assets 3D
- changer le root scale
- décocher animation
- clicker reimport
- faire un new inherited scene de gameobject.tscn
- rajouter le fbx en enfant du root node
- setup le scale_pivot sur le root node qui fait office de centre de gravité
- créer les collisions shapes à la main / ou les générer par godot
- retype les collisions shapes en ScallableCollisionShape3D


### Choses à faire en priorité
- Menu principal
	- Bouton (avec du son) nombre d'objet
	- Bouton hauteur à atteindre
- Faire en sorte que le pivot de rotation soit plus au centre de l'objet
- Mettre un marqueur sous l'objet sélectionné pour voir où il tombe
- Voir pour le focus de la souris sur l'export web
- Bloquer le zoom in/out à une certaine profondeur
- Déplacer la caméra plus lentement de base
	- Mettre un bouton (shift) pour accélerer


### Choses pour plus tard
- mettre un bouton pour faire tourner la caméra autour de l'objet sélectionné
- maybe update the heightlabel when the game is launcherz
	-> currently, 1 second is elapsed before the first update
	-> problem is if we use _detect_current_max_height at launched,
	main.gd has not connected the signal yet to change the heighlabel on the billboard
- pause menu
- end menu
- main menu
- improve worldEnvironment and polish
- center camera on selected object (done for now, object is moving and not the camera)
- improve object rotation
- mode avec predefined object (like a puzzle level)
- mettre des limites au zoom/dezoom
- mettre des limites pour qu'on puisse pas bouger la caméra à l'infini
- add a feedback to project the drop in place of the selected object
- reduire la taille de l'export pck si possible


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
