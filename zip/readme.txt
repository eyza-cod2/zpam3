Installation
Extract files into following locations:
	- ./Call of Duty 2/main/zpam333.iwd
	- ./Call of Duty 2/main/zpam_maps_v3.iwd (*required only for 1.3 game version)
	- ./Call of Duty 2/main/server.cfg

Add +exec server.cfg into command line arguments.

Edit the server.cfg file to configure your server.

Make sure the server is runned without a mod (set fs_game "").
	- PAM uses default main folder because mods does not exec player's configs correctly and settings changed in game would not be persisted to next game session.

For game version 1.3:
	- Mappack file zpam_maps_v3.iwd needs to be included in main folder.
	- Fast download must be enabled via these settings (custom URL may be used):
		- sv_wwwDownload 1
		- sv_wwwBaseURL "http://cod2x.me/zpam"
	- This is to make sure that maps are downloaded in fast way for players

More info at: https://github.com/eyza-cod2/zpam3

Contact
Write message on discord TLS CoD2 Community in #zpam3-chat channel. https://discord.gg/HDsC6u5k6y
Or add me on discord eyza_ (old name eyza#7930)
Or write me on email kratas.tom@seznam.cz
