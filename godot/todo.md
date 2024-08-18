## TODO

Processus d'import des assets 3D
- set le root name
- changer le root scale
- décocher animation
- mettre le bon import script
- clicker reimport
- faire un new inherited scene de gameobject.tscn
- rajouter le fbx en enfant du root node
- editable children sur le fbx
- générer des collisions shapes en cliquant sur les mesh
- ajuster les collisions shapes à la main


Choses à faire en priorité

- set les variables _collision_shape et _collision_detector_shape en tant qu'array et le faire
	dans la fonction _ready
- dupliquer la collision shape des objects dans le collisiondetector
- scale jauge
	- mettre un UI de la jauge
- change l'albedo de l'objet sur lequel est peut cliquer
	- mettre une distance max pour sélectionner un objet
- faire un export web et le mettre sur itch

Choses pour plus tard

- mettre un bouton pour faire tourner la caméra autour de l'objet sélectionné
- maybe update the heightlabel when the game is launcher
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
