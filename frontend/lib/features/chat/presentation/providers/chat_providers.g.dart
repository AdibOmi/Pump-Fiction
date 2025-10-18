// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'6d10b08bd0874be267a7792da2e10e0c1b034706';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$chatSessionsHash() => r'5d9978538e5203097d8de333aaa0381d8076657b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatSessions
    extends BuildlessAutoDisposeAsyncNotifier<List<ChatSessionModel>> {
  late final bool isArchived;

  FutureOr<List<ChatSessionModel>> build({bool isArchived = false});
}

/// See also [ChatSessions].
@ProviderFor(ChatSessions)
const chatSessionsProvider = ChatSessionsFamily();

/// See also [ChatSessions].
class ChatSessionsFamily extends Family<AsyncValue<List<ChatSessionModel>>> {
  /// See also [ChatSessions].
  const ChatSessionsFamily();

  /// See also [ChatSessions].
  ChatSessionsProvider call({bool isArchived = false}) {
    return ChatSessionsProvider(isArchived: isArchived);
  }

  @override
  ChatSessionsProvider getProviderOverride(
    covariant ChatSessionsProvider provider,
  ) {
    return call(isArchived: provider.isArchived);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatSessionsProvider';
}

/// See also [ChatSessions].
class ChatSessionsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChatSessions,
          List<ChatSessionModel>
        > {
  /// See also [ChatSessions].
  ChatSessionsProvider({bool isArchived = false})
    : this._internal(
        () => ChatSessions()..isArchived = isArchived,
        from: chatSessionsProvider,
        name: r'chatSessionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatSessionsHash,
        dependencies: ChatSessionsFamily._dependencies,
        allTransitiveDependencies:
            ChatSessionsFamily._allTransitiveDependencies,
        isArchived: isArchived,
      );

  ChatSessionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isArchived,
  }) : super.internal();

  final bool isArchived;

  @override
  FutureOr<List<ChatSessionModel>> runNotifierBuild(
    covariant ChatSessions notifier,
  ) {
    return notifier.build(isArchived: isArchived);
  }

  @override
  Override overrideWith(ChatSessions Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatSessionsProvider._internal(
        () => create()..isArchived = isArchived,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isArchived: isArchived,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatSessions, List<ChatSessionModel>>
  createElement() {
    return _ChatSessionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSessionsProvider && other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatSessionsRef
    on AutoDisposeAsyncNotifierProviderRef<List<ChatSessionModel>> {
  /// The parameter `isArchived` of this provider.
  bool get isArchived;
}

class _ChatSessionsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChatSessions,
          List<ChatSessionModel>
        >
    with ChatSessionsRef {
  _ChatSessionsProviderElement(super.provider);

  @override
  bool get isArchived => (origin as ChatSessionsProvider).isArchived;
}

String _$currentChatSessionHash() =>
    r'd72f8f57b4da31e8f1ad92d257cb1b367cd4afd1';

abstract class _$CurrentChatSession
    extends BuildlessAutoDisposeAsyncNotifier<ChatSessionDetailModel?> {
  late final String? sessionId;

  FutureOr<ChatSessionDetailModel?> build(String? sessionId);
}

/// See also [CurrentChatSession].
@ProviderFor(CurrentChatSession)
const currentChatSessionProvider = CurrentChatSessionFamily();

/// See also [CurrentChatSession].
class CurrentChatSessionFamily
    extends Family<AsyncValue<ChatSessionDetailModel?>> {
  /// See also [CurrentChatSession].
  const CurrentChatSessionFamily();

  /// See also [CurrentChatSession].
  CurrentChatSessionProvider call(String? sessionId) {
    return CurrentChatSessionProvider(sessionId);
  }

  @override
  CurrentChatSessionProvider getProviderOverride(
    covariant CurrentChatSessionProvider provider,
  ) {
    return call(provider.sessionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentChatSessionProvider';
}

/// See also [CurrentChatSession].
class CurrentChatSessionProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CurrentChatSession,
          ChatSessionDetailModel?
        > {
  /// See also [CurrentChatSession].
  CurrentChatSessionProvider(String? sessionId)
    : this._internal(
        () => CurrentChatSession()..sessionId = sessionId,
        from: currentChatSessionProvider,
        name: r'currentChatSessionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentChatSessionHash,
        dependencies: CurrentChatSessionFamily._dependencies,
        allTransitiveDependencies:
            CurrentChatSessionFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  CurrentChatSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final String? sessionId;

  @override
  FutureOr<ChatSessionDetailModel?> runNotifierBuild(
    covariant CurrentChatSession notifier,
  ) {
    return notifier.build(sessionId);
  }

  @override
  Override overrideWith(CurrentChatSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: CurrentChatSessionProvider._internal(
        () => create()..sessionId = sessionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CurrentChatSession,
    ChatSessionDetailModel?
  >
  createElement() {
    return _CurrentChatSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentChatSessionProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrentChatSessionRef
    on AutoDisposeAsyncNotifierProviderRef<ChatSessionDetailModel?> {
  /// The parameter `sessionId` of this provider.
  String? get sessionId;
}

class _CurrentChatSessionProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CurrentChatSession,
          ChatSessionDetailModel?
        >
    with CurrentChatSessionRef {
  _CurrentChatSessionProviderElement(super.provider);

  @override
  String? get sessionId => (origin as CurrentChatSessionProvider).sessionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
