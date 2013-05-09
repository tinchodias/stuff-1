ignoredClasses := { MethodContext }.
ignoredPrefixes := #( 'FL' ).
ignoredClassNameStrings := #( 'Mock' ).

classes := Object withAllSubclasses reject: [ :class |
	class isObsolete
		or: [ (ignoredPrefixes anySatisfy: [ :prefix | class name asString beginsWith: prefix ])
			or: [ (ignoredClasses includes: class)
				or: [ ignoredClassNameStrings anySatisfy: [ :string | (class name asString findString: string) > 0  ] ] ] ] ].
objects := classes collect: [ :class |
	class allInstances 
		at: 1 
		ifAbsent: [ 
			(class canUnderstand: #basicNew:)
				ifTrue: [ [ [ class basicNew: 2 ]
					on: Error do: [ class basicNew ] ] 
						on: Error do: [ :ex | ex return: nil ] ]	
				ifFalse: [ [ class basicNew ] on: Error do: [ :ex | ex return: nil ] ] ] ].
"yes, this is necessary. There are some truly weird objects hanging around."
objects := objects reject: [ :object | object isBehavior and: [ object isObsolete ] ].

analyzer := FLAnalyzer newDefault
	when: [ :object || class |
		class := object isBehavior
			ifTrue: [ object ]
			ifFalse: [ object class ].
		class isObsolete
			or: [ class isWords
			or: [ (ignoredPrefixes anySatisfy: [ :prefix | class name asString beginsWith: prefix ])
				or: [ (ignoredClasses includes: class)
					or: [ ignoredClassNameStrings anySatisfy: [ :string | (class name asString findString: string) > 0  ] ] ] ] ] ]
	substituteBy: [ :object | nil ].

filename := Smalltalk at: #FuelFormatTestFilename.
Smalltalk globals
	at: #FileDirectory
	ifPresent: [ :fileDirectory || scriptsDirectory |
		scriptsDirectory := fileDirectory on: (Smalltalk at: #FuelFormatTestScriptsPath).
		StandardFileStream
			forceNewFileNamed: (scriptsDirectory / filename) fullName
			do: [ :stream |
				FLSerializer newDefault
					analyzer: analyzer;
					serialize: classes -> objects on: stream binary ] ]
	ifAbsent: [ | scriptsDirectory |
		scriptsDirectory := (Smalltalk at: #FuelFormatTestScriptsPath) asFileReference.
		StandardFileStream
			forceNewFileNamed: (scriptsDirectory / filename) pathName
			do: [ :stream |
				FLSerializer newDefault
					analyzer: analyzer;
					serialize: classes -> objects on: stream binary ] ].