# SafeDecoder

[![Travis CI](https://travis-ci.org/Beyova/SafeDecoder.svg?branch=master)](https://travis-ci.org/Beyova/SafeDecoder)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)

SafeDecoder enhance the compatibility for Decodable.

## Installation

#### Carthage

```
github "Beyova/SafeDecoder"
```

## Usage

```swift
import SafeDecoder
```

#### Decode primitive type when acture json is String

```swift
class User: Codable {
	var id: Int
}
let decoder = JSONDecoder()
let data = try JSONSerialization.data(withJSONObject: ["id": "42"], options: [])
let result = try decoder.decode(User.self, from: data)
```

#### Customize fallback value when decode fail

```swift
enum Gender: String, Codable {
    case unknown
    case male
    case female
}

struct User: Codable {
    let gender: Gender
    
    enum CodingKeys: String, FallbackCodingKey 
        case gender
        func fallbackValue() -> FallbackValue {
            switch self {
            case .gender: return (true, Gender.unknown)
            }
        }
    }
}
let decoder = JSONDecoder()
let data = try JSONSerialization.data(withJSONObject: [:], options: [])
let result = try decoder.decode(User.self, from: data)
```











