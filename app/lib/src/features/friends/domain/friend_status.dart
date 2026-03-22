/// Friend relationship status.
enum FriendStatus {
  pending,
  accepted,
  rejected;

  String get value => name;

  static FriendStatus fromString(String? raw) {
    if (raw == null) return FriendStatus.pending;
    return FriendStatus.values.firstWhere(
      (status) => status.value == raw,
      orElse: () => FriendStatus.pending,
    );
  }

  bool get isPending => this == FriendStatus.pending;
  bool get isAccepted => this == FriendStatus.accepted;
  bool get isRejected => this == FriendStatus.rejected;
}
