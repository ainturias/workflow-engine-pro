export interface TramiteStep {
  id: string;
  nodeId: string;
  nodeType: string;
  nodeLabel: string;
  departmentId: string;
  completedBy?: string;
  completedByName?: string;
  status: string;
  formData?: Record<string, any>;
  comment?: string;
  assignedAt: string;
  startedAt?: string;
  completedAt?: string;
}

export interface Tramite {
  id?: string;
  policyId: string;
  policyName: string;
  requestedBy: string;
  requestedByName: string;
  status: string;
  activeNodeIds: string[];
  steps: TramiteStep[];
  data: Record<string, any>;
  createdAt: string;
  completedAt?: string;
}

export interface PendingTask {
  tramiteId: string;
  tramiteName: string;
  stepId: string;
  nodeId: string;
  taskName: string;
  assignedAt: string;
  requestedBy: string;
}
