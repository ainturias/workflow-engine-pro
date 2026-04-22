export interface WorkflowNode {
  id: string;
  type: 'START' | 'END' | 'ACTIVITY' | 'DECISION' | 'FORK' | 'JOIN';
  label: string;
  departmentId?: string;
  activityId?: string;
  formFields?: any[];
  x: number;
  y: number;
  config?: Record<string, any>;
}

export interface WorkflowTransition {
  id: string;
  sourceNodeId: string;
  targetNodeId: string;
  label?: string;
  condition?: string;
}

export interface PolicySwimlane {
  id: string;
  departmentId: string;
  departmentName: string;
  order: number;
  color: string;
}

export interface WorkflowPolicy {
  id?: string;
  name: string;
  description: string;
  createdBy?: string;
  status?: string;
  nodes: WorkflowNode[];
  transitions: WorkflowTransition[];
  swimlanes: PolicySwimlane[];
  active?: boolean;
  createdAt?: string;
}
