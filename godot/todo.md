## TODO

- Retirer le highlight jaune de l'objet quand la photo de fin de niveau est prise
- Mettre toutes les textures en 1K (il en reste qlq unes en 2K, par exemple celle des rochers)
- Reste qlq bugs sur les assets
	- Rainures du ballon de foot avec de l'aliasing ?

### Chose à polish
- Bloquer le zoom in/out à une certaine profondeur
- Faire en sorte que le score bouge pas quand on lâche un objet de haut


### Choses pour plus tard
- fix le bug pour la roue qui rotate brusquement quand on la rotate (après être tombée au sol)
- maybe update the heightlabel when the game is launcherz
	-> currently, 1 second is elapsed before the first update
	-> problem is if we use _detect_current_max_height at launched,
	main.gd has not connected the signal yet to change the heighlabel on the billboard
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
