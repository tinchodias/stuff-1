[ | filename imageNames |
"materialize all objects from the serializations of all the other images"
filename := Smalltalk at: #FuelFormatTestFilename.
imageNames := Smalltalk at: #FuelFormatTestImageNames.
imageNames := imageNames copyWithout: filename.

"wait before starting serialization to make sure that all files are there"
Smalltalk globals
	at: #FileDirectory
	ifPresent: [ :fileDirectory || scriptsDirectory |
		scriptsDirectory := fileDirectory on: (Smalltalk at: #FuelFormatTestScriptsPath).
		[ (scriptsDirectory entries select: [ :entry | entry name beginsWith: 'run_it_' ]) size = (imageNames size + 1) ] 
			whileFalse: [ (Delay forSeconds: 5) wait ].
			
		imageNames do: [ :imageName |
			FLMaterializer materializeFromFileNamed: (scriptsDirectory / imageName) fullName ] ]
	ifAbsent: [ | scriptsDirectory |
		scriptsDirectory := (Smalltalk at: #FuelFormatTestScriptsPath) asFileReference.
		[ (scriptsDirectory fileNames select: [ :theFilename | theFilename beginsWith: 'run_it_' ]) size = (imageNames size + 1) ] 
			whileFalse: [ (Delay forSeconds: 5) wait ].
			
		imageNames do: [ :imageName |
			FLMaterializer materializeFromFileNamed: (scriptsDirectory / imageName) pathString ] ] ] value.
			
