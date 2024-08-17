## TODO

- maybe update the heightlabel when the game is launcher
	-> currently, 1 second is elapsed before the first update
	-> problem is if we use _detect_current_max_height at launched,
	main.gd has not connected the signal yet to change the heighlabel on the billboard
- pause menu
- end menu
- main menu
- spawn random objects / or predefined (like a puzzle level)
- zoom/dezoom selected object
- scale selected object
- center camera on selected object
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
