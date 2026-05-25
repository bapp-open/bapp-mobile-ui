class Node {
  final String kind;
  final Map<String, dynamic> props;
  final List<Node> children;
  final Map<String, dynamic>? onTap;
  final Map<String, dynamic>? showWhen;

  const Node({
    required this.kind,
    this.props = const {},
    this.children = const [],
    this.onTap,
    this.showWhen,
  });

  factory Node.fromJson(Map<String, dynamic> j) => Node(
        kind: j['kind'] as String,
        props: (j['props'] as Map?)?.cast<String, dynamic>() ?? const {},
        children: ((j['children'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(Node.fromJson)
            .toList(),
        onTap: (j['on_tap'] as Map?)?.cast<String, dynamic>(),
        showWhen: (j['show_when'] as Map?)?.cast<String, dynamic>(),
      );
}
