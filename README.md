# SharingRemoteConfig

SharingRemoteConfig uses [swift-sharing](https://github.com/pointfreeco/swift-sharing) and [firebase-swift](https://github.com/zunda-pixel/firebase-swift)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fzunda-pixel%2Fsharing-remoteconfig%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/zunda-pixel/sharing-remoteconfig)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fzunda-pixel%2Fsharing-remoteconfig%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/zunda-pixel/sharing-remoteconfig)

```swift
struct ContentView: View {
  @SharedReader(.remoteConfig("parameterBool")) var parameterBoolString: String?
  @SharedReader(.remoteConfig("parameterInt")) var parameterIntString: String?
  @SharedReader(.remoteConfig("parameterString")) var parameterString: String?
  @SharedReader(.remoteConfig("parameterJson")) var parameterJsonString: String?
  
  var parameterInt: Int? {
    parameterIntString.flatMap { Int($0) }
  }
  
  var parameterBool: Bool? {
    parameterBoolString.flatMap { try? JSONDecoder().decode(Bool.self, from: Data($0.utf8)) }
  }
  
  var parameterJson: User? {
    parameterJsonString.flatMap { try? JSONDecoder().decode(User.self, from: Data($0.utf8)) }
  }
  
  var body: some View {
    VStack {
      Text("String: \(parameterString!)")
      Text("Int: \(parameterInt!.description)")
      Text("Bool: \(parameterBool!.description)")
      Text("User.name: \(parameterJson!.name)")
      Text("User.age: \(parameterJson!.age.description)")
    }
  }
}

#Preview {
  ContentView()
    .frame(maxWidth: 500, maxHeight: 500)
}

struct User: Decodable {
  var name: String
  var age: Int
}

extension SharedReaderKey {
  static func remoteConfig(_ key: String) -> Self
  where Self == RemoteConfigValueKey {
    RemoteConfigValueKey(key: key, client: .sampleProject)
  }
}

extension RemoteConfigClient<URLSession> {
  static let sampleProject = RemoteConfigClient(
    apiKey: "AIzaSyCI6lc5~~~~~~~~m4ZQ9PoL5oVtM",
    projectId: "21~~~~~289",
    projectName: "n~~~~s",
    appId: "1:2~~~~~~289:ios:1~~~~~~~~~d5d8",
    appInstanceId: UUID().uuidString,
    httpClient: .urlSession(.shared)
  )
}
```

<img width="700px" src="https://github.com/user-attachments/assets/4c0d5b6e-b964-42c7-83e1-8c9379957055" />
