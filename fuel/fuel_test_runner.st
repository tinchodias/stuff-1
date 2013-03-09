
[ Gofer new
	url: 'http://ss3.gemstone.com/ss/Fuel';
	package: 'ConfigurationOfFuel';
	load.
(Smalltalk at: #ConfigurationOfFuel) load ] on: Error do: [
	(Installer fromUrl: 'http://ss3.gemstone.com/ss/Fuel/')
		install: 'ConfigurationOfFuel-MartinDias.194.mcz'.
		(Smalltalk at: #ConfigurationOfFuel)  load ].

classes := (PackageOrganizer default packages detect: [ :package |
	package packageName = 'FuelTests' ]) classes.
testClasses := OrderedCollection new.
classes do: [ :class | (class theNonMetaClass inheritsFrom: TestCase) ifTrue: [ testClasses add: class theNonMetaClass ] ].
suite := TestSuite new.
testClasses do: [ :class | class addToSuiteFromSelectors: suite ].

TestRunner open model runSuite: suite.
