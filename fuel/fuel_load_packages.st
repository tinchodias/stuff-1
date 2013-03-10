"load latest stable version"
[ Gofer new
	url: 'http://ss3.gemstone.com/ss/Fuel';
	package: 'ConfigurationOfFuel';
	load.
(Smalltalk at: #ConfigurationOfFuel) load ] on: Error do: [
	(Installer fromUrl: 'http://ss3.gemstone.com/ss/Fuel/')
		install: 'ConfigurationOfFuel-MartinDias.194.mcz'.
		(Smalltalk at: #ConfigurationOfFuel)  load ].