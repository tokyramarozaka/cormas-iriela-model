Class {
	#name : 'IMCell',
	#superclass : 'CMCell',
	#instVars : [
		'state'
	],
	#category : 'Iriela-Model',
	#package : 'Iriela-Model'
}

{ #category : 'accessing' }
IMCell >> beNormal [
	"Changes the state to normal"
	self setState: #normal
]

{ #category : 'accessing' }
IMCell >> beOffice [
	"Changes the state to be an office"

	self setState: #office
]

{ #category : 'accessing' }
IMCell >> beProtected [
	"Changes the state of the cell to protected"
	self setState: #protected
]

{ #category : 'accessing' }
IMCell >> beSacred [
	"Changes the set of the cell to be sacred"
	self setState: #sacred
]

{ #category : 'testing' }
IMCell >> hasResource [ 
	^ (self hasOccupantsOfClass: IMWood) or: [self hasOccupantsOfClass: IMFish] 
]

{ #category : 'accessing' }
IMCell >> isNormal [
	"Returns true if the cell is normal, returns false otherwise"

	^ state = #normal
]

{ #category : 'accessing' }
IMCell >> isOffice [
	"Returns true if the cell is an office, returns false otherwise"

	^ state = #office
]

{ #category : 'accessing' }
IMCell >> isProtected [
	"Returns true if the cell is protected, returns false otherwise"
	^ state = #protected
]

{ #category : 'accessing' }
IMCell >> isSacred [
	"Returns true if the cell is sacred, returns false otherwise"
	^ state = #sacred
]

{ #category : 'accessing' }
IMCell >> pov [
	<pov>
	^ CMPointOfView new
		color: CMColor white;
		borderColor: CMColor gray;
		yourself
]

{ #category : 'testing' }
IMCell >> setState: aSymbol [
	"Changes the state of the cell to a valid state, generates an error if the new state is invalid"
	(#( #sacred #protected #normal ) includes: aSymbol) ifFalse: [ self error: 'Invalid cell state: ' , aSymbol ].
	state := aSymbol
]
