class TramiteStep {
  final String id;
  final String nodeId;
  final String nodeType;
  final String nodeLabel;
  final String? departmentId;
  final String? completedBy;
  final String? completedByName;
  final String status;
  final Map<String, dynamic>? formData;
  final String? comment;
  final String? assignedAt;
  final String? startedAt;
  final String? completedAt;
  final List<dynamic>? formFields;

  TramiteStep({
    required this.id,
    required this.nodeId,
    required this.nodeType,
    required this.nodeLabel,
    this.departmentId,
    this.completedBy,
    this.completedByName,
    required this.status,
    this.formData,
    this.comment,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.formFields,
  });

  factory TramiteStep.fromJson(Map<String, dynamic> json) {
    return TramiteStep(
      id: json['id'] ?? '',
      nodeId: json['nodeId'] ?? '',
      nodeType: json['nodeType'] ?? '',
      nodeLabel: json['nodeLabel'] ?? '',
      departmentId: json['departmentId'],
      completedBy: json['completedBy'],
      completedByName: json['completedByName'],
      status: json['status'] ?? 'PENDING',
      formData: json['formData'] != null
          ? Map<String, dynamic>.from(json['formData'])
          : null,
      comment: json['comment'],
      assignedAt: json['assignedAt']?.toString(),
      startedAt: json['startedAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
      formFields: json['formFields'],
    );
  }
}

class Tramite {
  final String? id;
  final String policyId;
  final String policyName;
  final String requestedBy;
  final String requestedByName;
  final String status;
  final List<String> activeNodeIds;
  final List<TramiteStep> steps;
  final Map<String, dynamic> data;
  final String? createdAt;
  final String? completedAt;

  Tramite({
    this.id,
    required this.policyId,
    required this.policyName,
    required this.requestedBy,
    required this.requestedByName,
    required this.status,
    required this.activeNodeIds,
    required this.steps,
    required this.data,
    this.createdAt,
    this.completedAt,
  });

  factory Tramite.fromJson(Map<String, dynamic> json) {
    return Tramite(
      id: json['id'],
      policyId: json['policyId'] ?? '',
      policyName: json['policyName'] ?? '',
      requestedBy: json['requestedBy'] ?? '',
      requestedByName: json['requestedByName'] ?? '',
      status: json['status'] ?? 'EN_CURSO',
      activeNodeIds: List<String>.from(json['activeNodeIds'] ?? []),
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => TramiteStep.fromJson(s))
              .toList() ??
          [],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: json['createdAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
    );
  }
}

class PendingTask {
  final String tramiteId;
  final String tramiteName;
  final String stepId;
  final String nodeId;
  final String taskName;
  final String? assignedAt;
  final String requestedBy;

  PendingTask({
    required this.tramiteId,
    required this.tramiteName,
    required this.stepId,
    required this.nodeId,
    required this.taskName,
    this.assignedAt,
    required this.requestedBy,
  });

  factory PendingTask.fromJson(Map<String, dynamic> json) {
    return PendingTask(
      tramiteId: json['tramiteId'] ?? '',
      tramiteName: json['tramiteName'] ?? '',
      stepId: json['stepId'] ?? '',
      nodeId: json['nodeId'] ?? '',
      taskName: json['taskName'] ?? '',
      assignedAt: json['assignedAt']?.toString(),
      requestedBy: json['requestedBy'] ?? '',
    );
  }
}
