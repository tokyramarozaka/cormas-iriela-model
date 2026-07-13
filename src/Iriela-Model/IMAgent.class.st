Class {
	#name : 'IMAgent',
	#superclass : 'CMAgent',
	#category : 'Iriela-Model',
	#package : 'Iriela-Model'
}

{ #category : 'control' }
IMAgent >> move [ 
	<action> 
	self cell neighbourhood 
		detect: [ :c | cell hasResource ]
		ifFound: [ :c | self moveTo: cell ]
		ifNone: [ self moveRandomly ]
]

{ #category : 'as yet unclassified' }
IMAgent >> moveRandomly [ 
	self randomWalk 
]

{ #category : 'accessing' }
IMAgent >> pov [ 
	<pov> 
	^ CMPointOfView 
		tile: IMTileset agent
		size: 0.8
]

{ #category : 'control' }
IMAgent >> step [ 
	self move. 
]
