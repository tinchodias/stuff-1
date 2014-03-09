(FileSystem disk workingDirectory / 'serialization.log') writeStreamDo: [ :log |
Object withAllSubclasses do: [ :class | 
	3 timesRepeat: [Smalltalk garbageCollect].
analyzer := FLAnalyzer newDefault.

[ | instances scriptsDirectory |
	scriptsDirectory := Smalltalk globals at: #FileDirectory
		ifPresent: [ :fileDirectory | (fileDirectory default / 'serialized') assureExistence ]
		ifAbsent: [ ((Smalltalk at: #FileSystem) workingDirectory / 'serialized') ensureCreateDirectory ].
	instances := class allInstances.
	instances size > 2 ifTrue: [ instances := instances first: 2 ].
	filename := class name, '_', instances size asString, '_instances_.fueltest'.

	StandardFileStream
		forceNewFileNamed: (scriptsDirectory / filename) fullName
		do: [ :stream |
			FLSerializer newDefault
				analyzer: FLAnalyzer newDefault;
				serialize: class -> instances on: stream binary ].
			
	FLMaterializer materializeFromFileNamed: (scriptsDirectory / filename) fullName ]
		on: Exception 
		do: [ :ex | 
			log 
				nextPutAll: class name; crlf; 
				nextPutAll: ex printString; crlf; crlf; 
				flush. 
			ex pass ] ] ]