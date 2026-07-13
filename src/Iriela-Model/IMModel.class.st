Class {
	#name : 'IMModel',
	#superclass : 'CMModel',
	#instVars : [
		'cells',
		'agents',
		'woods',
		'fishes',
		'numberOfRows',
		'numberOfColumns',
		'numberOfAgents',
		'numberOfWoods',
		'numberOfFishes'
	],
	#classInstVars : [
		'numberOfRows',
		'numberOfColumns',
		'numberOfAgents',
		'numberOfWoods',
		'numberOfFishes'
	],
	#category : 'Iriela-Model',
	#package : 'Iriela-Model'
}

{ #category : 'as yet unclassified' }
IMModel class >> prefix [

	^ 'IM'
]

{ #category : 'initialization' }
IMModel >> init [

	<init>
	self
		createGridNumberOfRows: self numberOfRows
		numberOfColumns: self numberOfColumns
		neighbourhood: 4
		closed: true.

	self
		create: self numberOfWoods
		randomlyLocatedAloneEntitiesOfClass: IMWood.
	self
		create: self numberOfFishes
		randomlyLocatedAloneEntitiesOfClass: IMFish.
	self
		create: self numberOfAgents
		randomlyLocatedAloneEntitiesOfClass: IMAgent
]

{ #category : 'accessing' }
IMModel >> numberOfAgents [
	<parameterIntegerMin: 0 max: 10 default: 5>
	^ numberOfAgents
]

{ #category : 'accessing' }
IMModel >> numberOfAgents: anObject [

	numberOfAgents := anObject
]

{ #category : 'accessing' }
IMModel >> numberOfColumns [
	<parameterIntegerMin: 0 max: 10 default: 5>
	^ numberOfColumns
]

{ #category : 'accessing' }
IMModel >> numberOfColumns: anObject [

	numberOfColumns := anObject
]

{ #category : 'accessing' }
IMModel >> numberOfFishes [
	<parameterIntegerMin: 0 max: 10 default: 2>
	^ numberOfFishes
]

{ #category : 'accessing' }
IMModel >> numberOfFishes: anObject [

	numberOfFishes := anObject
]

{ #category : 'accessing' }
IMModel >> numberOfRemainingWoods [ 
	<probeNamed: 'Remaining woods' color: 'E5B80B'>
	^ (self @@ IMWood) count: [ :each | each cell isNotNil ]
]

{ #category : 'accessing' }
IMModel >> numberOfRows [
	<parameterIntegerMin: 0 max: 10 default: 5>
	^ numberOfRows
]

{ #category : 'accessing' }
IMModel >> numberOfRows: anObject [

	numberOfRows := anObject
]

{ #category : 'accessing' }
IMModel >> numberOfWoods [
	<parameterIntegerMin: 0 max: 10 default: 2>
	^ numberOfWoods
]

{ #category : 'accessing' }
IMModel >> numberOfWoods: anObject [

	numberOfWoods := anObject
]

{ #category : 'initialization' }
IMModel >> step [ 
	<control> 
	(self @@ IMAgent) do: [ :each | each step ]
]
