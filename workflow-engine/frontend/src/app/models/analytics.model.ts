export interface TramitesByPolicy {
  policyId: string;
  policyName: string;
  count: number;
}

export interface GeneralMetrics {
  totalActive: number;
  totalCompleted: number;
  totalCancelled: number;
  totalTramites: number;
  avgResolutionHours: number;
  tramitesByPolicy: TramitesByPolicy[];
}

export interface FuncionarioMetrics {
  userId: string;
  name: string;
  departmentId: string;
  departmentName: string;
  avgAttentionHours: number;
  tasksProcessed: number;
  tasksCompleted: number;
}

export interface BottleneckInfo {
  nodeLabel: string;
  policyName: string;
  departmentId: string;
  departmentName: string;
  avgWaitHours: number;
  pendingCount: number;
  severity: 'HIGH' | 'MEDIUM' | 'LOW';
}

export interface DepartmentLoad {
  departmentId: string;
  name: string;
  pendingTasks: number;
  activeTramites: number;
  avgWaitHours: number;
  saturationLevel: number;
}

export interface TramiteTrend {
  date: string;
  count: number;
}

export interface DashboardSummary {
  generalMetrics: GeneralMetrics;
  funcionarioMetrics: FuncionarioMetrics[];
  bottlenecks: BottleneckInfo[];
  departmentLoads: DepartmentLoad[];
  trends: TramiteTrend[];
}
