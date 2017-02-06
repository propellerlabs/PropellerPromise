![Travis](https://api.travis-ci.org/propellerlabs/PropellerPromise.svg?branch=master)
![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)
![Swift](https://img.shields.io/badge/language-swift-orange.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
![MIT License](https://img.shields.io/badge/license-MIT-000000.svg)

#PropellerPromise

This framework is meant to be a lightweight promise/futures framework with support for async result types, piping `then` functions, creating promises from a set of other promises to be fired when that set is complete.

## Installation

### Swift Package Manager 
```
dependencies: [
.Package(url: "https://github.com/propellerlabs/PropellerPromise.git", majorVersion: 1)
]
```

### Carthage

```
github "propellerlabs/PropellerPromise"
```

### CocoaPods

Cocoapods will come soon, faster if there is a demand for it.


##Usage


### 1. Return a promise in a function that asyncronously deals with its result
```Swift
func successPromise() -> Promise<String> {
	// create promise
	let promise = Promise<String>()

	DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
		// make asnc fullfillment of promise result
		promise.fulfill(self.successString)
	}

	//return promise
	return promise
}
```

### 2. Deal with failure/completion cases:
```Swift
successPromise()
.complete { value in
	print("complete with value: \(value)")
}
.failure { error in
	print("failed wih error: \(error)")
}
```

### 3. pipe results together via a `then` functions passing different return types together:
```Swift
successPromise()
.then { val -> Bool in
	// do something with val
	return val == self.successString
}
.then { isSuccess -> Int in
	// do something with isSuccess
	return isSuccess ? 1 : 0
}
.then { successInt -> Void in
	// do something with successInt
}
```

### 4. Create a promise that fires after several other promises finish using `CombinePromise`:
```Swift

// Say we have some promises we are waiting on:

let p1 = successPromise()
.complete { value in
	print("completed! \(value)")
}

let p2 = successPromise()
.complete { value in
	print("completed! \(value)")
}

let p3 = successPromise()
.complete { value in
	print("completed! \(value)")
}

// Then want to fire a combined promise after p1,p2,p3 are all fullfilled/rejected

CombinePromise(promises: [p1,p2,p3])
.complete { results in
	for result in results {
		print(result)
	}
}
.failure(MultiError.self) { errors in
	for error in errors.errors {
		print(error)
	}
}
```
