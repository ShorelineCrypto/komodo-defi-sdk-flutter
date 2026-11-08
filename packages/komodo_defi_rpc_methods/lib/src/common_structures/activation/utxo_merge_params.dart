class UtxoMergeParams {
  UtxoMergeParams({
    required this.mergeAt,
    required this.checkEvery,
    required this.maxMergeAtOnce,
  });

  factory UtxoMergeParams.fromJson(Map<String, dynamic> json) {
    return UtxoMergeParams(
      mergeAt: json['merge_at'] as int,
      checkEvery: json['check_every'] as int,
      maxMergeAtOnce: json['max_merge_at_once'] as int,
    );
  }

  final int mergeAt;
  final int checkEvery;
  final int maxMergeAtOnce;

  Map<String, dynamic> toJson() => {
    'merge_at': mergeAt,
    'check_every': checkEvery,
    'max_merge_at_once': maxMergeAtOnce,
  };
}
