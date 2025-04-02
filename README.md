# SharingFirebase

SharingFirebase uses [swift-sharing](https://github.com/pointfreeco/swift-sharing) and [firebase-swift](https://github.com/zunda-pixel/firebase-swift)

## SharingRemoteConfig

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
      Text("String: \(parameterString ?? "Nothing")")
      Text("Int: \(parameterInt?.description ?? "Nothing")")
      Text("Bool: \(parameterBool?.description ?? "Nothing")")
      Text("User.name: \(parameterJson?.name ?? "Nothing")")
      Text("User.age: \(parameterJson?.age.description ?? "Nothing")")
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
