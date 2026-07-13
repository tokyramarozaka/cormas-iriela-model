Class {
	#name : 'IMCell',
	#superclass : 'CMCell',
	#category : 'Iriela-Model',
	#package : 'Iriela-Model'
}

{ #category : 'testing' }
IMCell >> hasResource [ 
	^ (self hasOccupantsOfClass: IMWood) or: [self hasOccupantsOfClass: IMFish] 
]

{ #category : 'accessing' }
IMCell >> pov [
	<pov>
	^ CMPointOfView new
		color: CMColor white;
		borderColor: CMColor gray;
		yourself
]
