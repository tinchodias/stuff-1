"serialize all objects"
o := Object withAllSubclasses collect: [ :class | class allInstances at: 1 ifAbsent: [ 
	(class canUnderstand: #basicNew:)
		ifTrue: [ [ [ class basicNew: 2 ]
			on: Error do: [ class basicNew ] ] 
				on: Error do: [ :ex | ex return: nil ] ]	
		ifFalse: [ [ class basicNew ] on: Error do: [ :ex | ex return: nil ] ] ] ].

filename := Smalltalk at: #FuelFormatTestFilename.
Smalltalk globals
	at: #FileDirectory
	ifPresent: [ :fileDirectory || scriptsDirectory |
		scriptsDirectory := fileDirectory on: (Smalltalk at: #FuelFormatTestScriptsPath).
		FLSerializer 
			serialize: Object withAllSubclasses -> o 
			toFileNamed: (scriptsDirectory / filename) fullName ]
	ifAbsent: [ |scriptsDirectory |
		scriptsDirectory := (Smalltalk at: #FuelFormatTestScriptsPath) asFileReference.
		FLSerializer 
			serialize: Object withAllSubclasses -> o 
			toFileNamed: (scriptsDirectory / filename) pathName ].