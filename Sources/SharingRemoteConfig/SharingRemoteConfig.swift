import Dependencies
import Foundation
import HTTPClient
import RemoteConfig
import Sharing
import Synchronization

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct ProjectRemoteConfigKeyID: Hashable, Sendable {
  var remoteConfig: RemoteConfigClient<URLSession>
  var key: String
}

public struct RemoteConfigValueKey: SharedReaderKey {
  public typealias ID = ProjectRemoteConfigKeyID
  public typealias Value = String?
  public var id: ID {
    ID(remoteConfig: client, key: key)
  }
  public let key: String
  private let client: RemoteConfigClient<URLSession>
  private let store: DefaultRemoteConfigStore

  public init(key: String, client: RemoteConfigClient<URLSession>) {
    @Dependency(\.defaultRemoteConfigStore) var store
    self.key = key
    self.store = store
    self.client = client
  }

  public func load(
    context: Sharing.LoadContext<Value>,
    continuation: Sharing.LoadContinuation<Value>
  ) {
    continuation.resumeReturningInitialValue()
  }

  public func subscribe(
    context: Sharing.LoadContext<Value>,
    subscriber: Sharing.SharedSubscriber<Value>
  ) -> Sharing.SharedSubscription {
    subscriber.yieldReturningInitialValue()
    store.subscribers.withLock {
      $0[.init(remoteConfig: client, key: key)] = subscriber
    }
    store.tasks.withLock { tasks in
      guard tasks[client] == nil || tasks[client]?.isCancelled == true else { return }
      tasks[client] = Task {
        do {
          for try await result in client.realtimeStream() {
            do {
              _ = try result.get()
              let result = try await client.fetch()
              store.subscribers.withLock {
                for (key, subscriber) in $0 where key.remoteConfig == client {
                  subscriber.yield(result.entries[key.key])
                }
              }
            } catch {
              store.subscribers.withLock {
                for (key, subscriber) in $0 where key.remoteConfig == client {
                  subscriber.yield(throwing: error)
                }
              }
            }
          }
        } catch {
          store.subscribers.withLock {
            for (key, subscriber) in $0 where key.remoteConfig == client {
              subscriber.yield(throwing: error)
            }
          }
        }
      }
    }

    return SharedSubscription {
      store.tasks.withLock { tasks in
        tasks[client]?.cancel()
      }
    }
  }
}


#if canImport(FoundationNetworking)
extension RemoteConfigClient {
  func realtimeStream() -> AsyncThrowingStream<Result<Never?, any Error>, any Error> {
    return AsyncThrowingStream { continuation in
      while true {
        continuation.yield(nil)
        try await Task.sleep(for: .seconds(60))
      }
    }
  }
}
#endif

extension SharedReaderKey {
  public static func remoteConfig(_ key: String, client: RemoteConfigClient<URLSession>) -> Self
  where Self == RemoteConfigValueKey {
    RemoteConfigValueKey(key: key, client: client)
  }
}

enum DefaultRemoteConfigStoreKey: DependencyKey {
  static var liveValue: DefaultRemoteConfigStore { DefaultRemoteConfigStore() }
}

public final class DefaultRemoteConfigStore: Sendable {
  let tasks = Mutex<[RemoteConfigClient<URLSession>: Task<Void, Never>]>([:])
  let subscribers: Mutex<[RemoteConfigValueKey.ID: SharedSubscriber<String?>]> = .init([:])
}

extension DependencyValues {
  public var defaultRemoteConfigStore: DefaultRemoteConfigStore {
    get { self[DefaultRemoteConfigStoreKey.self] }
    set { self[DefaultRemoteConfigStoreKey.self] = newValue }
  }
}
