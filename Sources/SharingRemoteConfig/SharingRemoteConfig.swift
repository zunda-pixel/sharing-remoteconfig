import Sharing
import Synchronization
import RemoteConfig
import HTTPClient
import Foundation
import Dependencies


public final class RemoteConfigValueKey: SharedReaderKey {
  public typealias Value = String?
  public var id: RemoteConfig<URLSession> { client }
  public let key: String
  private let client: RemoteConfig<URLSession>
  private let store: DefaultRemoteConfigStore
  
  init(key: String, client: RemoteConfig<URLSession>) {
    @Dependency(\.defaultRemoteConfigStore) var store
    self.key = key
    self.store = store
    self.client = client
  }

  deinit {
    store.tasks.withLock { tasks in
      tasks[client]?.cancel()
    }
  }

  public func load(
    context: Sharing.LoadContext<Value>,
    continuation: Sharing.LoadContinuation<Value>
  ) {
    store.configs.withLockIfAvailable {
      continuation.resume(returning: $0[client]?[key])
    }
  }
  
  public func subscribe(
    context: Sharing.LoadContext<Value>,
    subscriber: Sharing.SharedSubscriber<Value>
  ) -> Sharing.SharedSubscription {
    store.tasks.withLockIfAvailable { tasks in
      guard tasks[client] == nil || tasks[client]?.isCancelled == true else { return }
      tasks[client] = Task {
        do {
          for try await result in client.realtimeStream() {
            do {
              _ = try result.get()
              let result = try await client.fetch()
              store.configs.withLockIfAvailable {
                $0[client] = result.entries
              }
              subscriber.yield(result.entries[key])
            } catch {
              subscriber.yield(throwing: error)
            }
          }
        } catch {
          subscriber.yield(throwing: error)
        }
      }
    }

    return SharedSubscription { [weak self] in
      guard let self else { return }
      store.tasks.withLock { tasks in
        tasks[client]?.cancel()
      }
    }
  }
}

public final class RemoteConfigKey: SharedReaderKey {
  public typealias Value = [String: String]
  public var id: RemoteConfig<URLSession> { client }
  private let client: RemoteConfig<URLSession>
  private let store: DefaultRemoteConfigStore
  
  init(client: RemoteConfig<URLSession>) {
    @Dependency(\.defaultRemoteConfigStore) var store
    self.store = store
    self.client = client
  }

  deinit {
    store.tasks.withLock { tasks in
      tasks[client]?.cancel()
    }
  }

  public func load(
    context: Sharing.LoadContext<Value>,
    continuation: Sharing.LoadContinuation<Value>
  ) {
    store.configs.withLock {
      continuation.resume(returning: $0[client] ?? [:])
    }
  }
  
  public func subscribe(
    context: Sharing.LoadContext<Value>,
    subscriber: Sharing.SharedSubscriber<Value>
  ) -> Sharing.SharedSubscription {
    store.tasks.withLockIfAvailable { tasks in
      guard tasks[client] == nil || tasks[client]?.isCancelled == true else { return }
      tasks[client] = Task {
        do {
          for try await result in client.realtimeStream() {
            do {
              _ = try result.get()
              let result = try await client.fetch()
              store.configs.withLockIfAvailable {
                $0[client] = result.entries
              }
              subscriber.yield(result.entries)
            } catch {
              subscriber.yield(throwing: error)
            }
          }
        } catch {
          subscriber.yield(throwing: error)
        }
      }
    }

    return SharedSubscription { [weak self] in
      guard let self else { return }
      store.tasks.withLock { tasks in
        tasks[client]?.cancel()
      }
    }
  }
}

extension SharedReaderKey {
  public static func remoteConfig(_ client: RemoteConfig<URLSession>) -> Self
  where Self == RemoteConfigKey {
    RemoteConfigKey(client: client)
  }
  
  public static func remoteConfig(_ key: String, client: RemoteConfig<URLSession>) -> Self
  where Self == RemoteConfigValueKey {
    RemoteConfigValueKey(key: key, client: client)
  }
}

enum DefaultRemoteConfigStoreKey: DependencyKey {
  static var liveValue: DefaultRemoteConfigStore { DefaultRemoteConfigStore() }
}

public final class DefaultRemoteConfigStore: Sendable {
  let tasks = Mutex<[RemoteConfig<URLSession>: Task<Void, Never>]>([:])
  let configs = Mutex<[RemoteConfig<URLSession>: [String: String]]>([:])
}

extension DependencyValues {
  public var defaultRemoteConfigStore: DefaultRemoteConfigStore {
    get { self[DefaultRemoteConfigStoreKey.self] }
    set { self[DefaultRemoteConfigStoreKey.self] = newValue }
  }
}
