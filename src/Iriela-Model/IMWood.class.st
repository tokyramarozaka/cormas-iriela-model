Class {
	#name : 'IMWood',
	#superclass : 'CMAgent',
	#category : 'Iriela-Model',
	#package : 'Iriela-Model'
}

{ #category : 'initialization' }
IMWood >> initialize [ 
	super initialize .
]

{ #category : 'accessing' }
IMWood >> pov [ 
	<pov> 
	^ CMPointOfView 
		tile: IMTileset tree
		size: 0.5
]

{ #category : 'control' }
IMWood >> step [
]
