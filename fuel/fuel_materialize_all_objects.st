"materialize all objects from the serializations of all the other images"
filename := Smalltalk at: #FuelFormatTestFilename.
imageNames := Smllatalk at: #FuelFormatTestImageNames.
imageNames := imageNames copyWithout: filename.

"wait before starting serialization to make sure that all files are there"
Smalltalk globals
	at: #FileDirectory
	ifPresent: [ :fileDirectory || scriptsDirectory |
		scriptsDirectory := fileDirectory on: (Smalltalk at: #FuelFormatTestScriptPath).
		[ (scriptsDirectory entries select: [ :entry | entry name beginsWith: 'run_it_' ]) size = imageNames + 1 ] 
			whileFalse: [ (Delay forSeconds: 5) wait ].
			
		imageNames do: [ :imageName |
			FLMaterializer materializeFromFileNamed: (scriptsDirectory / imageName) fullName ] ]
	ifAbsent: [ | scriptsDirectory |
		scriptsDirectory := (Smalltalk at: #FuelFormatTestScriptPath) asFileReference.
		[ (scriptsDirectory fileNames select: [ :filename | filename beginsWith: 'run_it_' ]) size = imageNames + 1 ] 
			whileFalse: [ (Delay forSeconds: 5) wait ].
			
		imageNames do: [ :imageName |
			FLMaterializer materializeFromFileNamed: (sciptsDirectory / imageName) pathString ] ].
