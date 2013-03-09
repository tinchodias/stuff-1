o := Object withAllSubclasses collect: [ :class | class allInstances at: 1 ifAbsent: [ 
	(class canUnderstand: #basicNew:)
		ifTrue: [ [ [ class basicNew: 2 ]
			on: Error do: [ class basicNew ] ] 
				on: Error do: [ :ex | ex return: nil ] ]	
		ifFalse: [ [ class basicNew ] on: Error do: [ :ex | ex return: nil ] ] ] ]
	
FLSerializer serialize: Object withAllSubclasses -> o toFileNamed: 'all_objects.fuel'.
FLMaterializer materializeFromFileNamed: 'all_objects.fuel'.
