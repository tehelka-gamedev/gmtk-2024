## TODO

- maybe update the heightlabel when the game is launcher
	-> currently, 1 second is elapsed before the first update
	-> problem is if we use _detect_current_max_height at launched,
	main.gd has not connected the signal yet to change the heighlabel on the billboard
- change l'albedo de l'objet sur lequel est peut cliquer
- pause menu
- end menu
- main menu
- spawn random objects / or predefined (like a puzzle level)
- center camera on selected object (done for now, object is moving and not the camera)
- improve object rotation
- improve worldEnvironment and polish
- scale jauge UI

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
