"load development"
[ (Smalltalk at: #Gofer) new
	url: 'http://ss3.gemstone.com/ss/Fuel';
	package: 'ConfigurationOfFuel';
	load.
(Smalltalk at: #ConfigurationOfFuel) load ] on: Error do: [
	(Smalltalk at: #Installer) monticello
		http: 'http://ss3.gemstone.com/ss/';
		project: 'Fuel';
		install: 'ConfigurationOfFuel'.
	(Smalltalk at: #ConfigurationOfFuel) load ].
