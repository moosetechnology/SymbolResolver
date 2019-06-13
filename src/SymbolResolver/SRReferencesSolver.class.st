"
I am a class that can solve referencies and is able to give you the current entity for your visit
"
Class {
	#name : #SRReferencesSolver,
	#superclass : #Object,
	#instVars : [
		'scopes'
	],
	#category : #'SymbolResolver-Core'
}

{ #category : #manager }
SRReferencesSolver >> createScopeManager [
	^ SRScopeManager newAssociatedToSolver: self
]

{ #category : #accessing }
SRReferencesSolver >> currentEntity [
	^ (self scopes
		detect: #hasCurrentEntity
		ifNone: [ SRNoCurrentEntityAvailable signalReferencesResolver: self ]) currentEntity
]

{ #category : #alias }
SRReferencesSolver >> defineAliasInCurrentScope: aString for: aBlockClosure [
	self topScope addAlias: aString forEntity: aBlockClosure value
]

{ #category : #accessing }
SRReferencesSolver >> detect: aBlock [
	"Detects the scope for which aBlock evaluates to true."
	^ self scopes detect: aBlock
]

{ #category : #initialization }
SRReferencesSolver >> initialize [
	super initialize.
	self scopes: Stack new
]

{ #category : #accessing }
SRReferencesSolver >> peekScopeAtIndex: anInteger [
	"DISCLAIMER:
	 Returns the scope at index anInteger (index 1 is the top of the stack).
	 This method is really specific and should usually NOT BE USED.
	 Beware, if you use it you're problably doing it wrongly.
	 However there are some special cases where you need to do it."
	^ self scopes at: anInteger
]

{ #category : #'scopes management' }
SRReferencesSolver >> popScope [
	^ self scopes pop
]

{ #category : #'scopes management' }
SRReferencesSolver >> pushEntitiesAsScope: aCollectionOfEntities [
	self pushScope: (SRCollectionScope reachableEntities: aCollectionOfEntities)
]

{ #category : #'scopes management' }
SRReferencesSolver >> pushEntityAsScope: anEntity [
	self pushScope: (SREntityScope entity: anEntity)
]

{ #category : #'scopes management' }
SRReferencesSolver >> pushScope: aScope [
	^ self scopes push: aScope
]

{ #category : #detect }
SRReferencesSolver >> reachableEntitiesFor: aScope detect: aBlockClosure ifFound: aBlockClosureAction [
	"optimisation to avoid recreate collection"

	aScope reachableEntities
		detect: aBlockClosure
		ifFound: [ :f | ^ aBlockClosureAction value: f ]
		ifNone: [ "continue" ].
	NotFound signal
]

{ #category : #removing }
SRReferencesSolver >> removeScope: aPSQLScope [
	self scopes remove: aPSQLScope
]

{ #category : #resolution }
SRReferencesSolver >> resolve: aChainOfIdentifiers [
	"a collection of identifier will be for example {'myTable' . 'columnA'}"
	self scopes
		do: [ :aScope | 
			[ ^ self resolve: aChainOfIdentifiers inScope: aScope ]
				on: NotFound
				do: [ "do nothing to try superior scope" ] ].
	SRReferencesNotFound signalIdentifiers: aChainOfIdentifiers 
]

{ #category : #resolution }
SRReferencesSolver >> resolve: aChainOfIdentifiers inScope: aScope [
	^ self
		reachableEntitiesFor: aScope
		detect: [ :entity | entity name = aChainOfIdentifiers identifier ]
		ifFound: [ :entity | 
			aChainOfIdentifiers entity: entity value.
			aChainOfIdentifiers isLast
				ifTrue: [ ^ aChainOfIdentifiers ]
				ifFalse: [ self resolve: aChainOfIdentifiers next inScope: entity ] ]
]

{ #category : #accessing }
SRReferencesSolver >> scopes [
	^ scopes
]

{ #category : #accessing }
SRReferencesSolver >> scopes: anObject [
	scopes := anObject
]

{ #category : #accessing }
SRReferencesSolver >> topScope [
	^ self scopes top
]

{ #category : #accessing }
SRReferencesSolver >> topScopeReachableEntities [
	^ self topScope reachableEntities
]