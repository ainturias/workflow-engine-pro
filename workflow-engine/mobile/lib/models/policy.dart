class WorkflowPolicy {
  final String? id;
  final String name;
  final String? description;
  final String status;
  final String? createdAt;

  WorkflowPolicy({
    this.id,
    required this.name,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory WorkflowPolicy.fromJson(Map<String, dynamic> json) {
    return WorkflowPolicy(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'DRAFT',
      createdAt: json['createdAt']?.toString(),
    );
  }
}
