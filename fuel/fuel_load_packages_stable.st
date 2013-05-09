"load development"
[ (Smalltalk at: #Gofer) new
	url: 'http://ss3.gemstone.com/ss/Fuel';
	package: 'ConfigurationOfFuel';
	load.
(Smalltalk at: #ConfigurationOfFuel) load ] on: Error do: [
	((Smalltalk at: #Installer) fromUrl: 'http://ss3.gemstone.com/ss/Fuel/')
		install: 'ConfigurationOfFuel-MaxLeske.200.mcz'.
		(Smalltalk at: #ConfigurationOfFuel) load ].