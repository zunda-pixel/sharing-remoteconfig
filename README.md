# SharingFirebase

SharingFirebase uses [firebase-swift](https://github.com/zunda-pixel/firebase-swift)

## SharingRemoteConfig

```swift
struct ContentView: View {
  @SharedReader(.remoteConfig("parameterBool", client: .sampleProject)) var parameterBool: String?
  @SharedReader(.remoteConfig("parameterInt", client: .sampleProject)) var parameterInt: String?
  @SharedReader(.remoteConfig("parameterString", client: .sampleProject)) var parameterString: String?
  @SharedReader(.remoteConfig("parameterJson", client: .sampleProject)) var parameterJson: String?
  
  var body: some View {
    VStack {
      Text(parameterBool ?? "Nothing")
      Text(parameterString ?? "Nothing")
      Text(parameterInt ?? "Nothing")
      Text(parameterJson ?? "Nothing")
    }
  }
}

#Preview {
  ContentView()
    .frame(maxWidth: 500, maxHeight: 500)
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
