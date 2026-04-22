import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PolicyService } from '../../services/policy.service';
import { DepartmentService } from '../../services/department.service';
import { WorkflowPolicy, WorkflowNode, WorkflowTransition, PolicySwimlane } from '../../models/workflow.model';
import { Department } from '../../models/config.model';

@Component({
  selector: 'app-workflow-designer',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './workflow-designer.component.html',
  styleUrl: './workflow-designer.component.scss'
})
export class WorkflowDesignerComponent implements OnInit {
  @ViewChild('canvas', { static: false }) canvasRef!: ElementRef<SVGElement>;

  // Política actual
  policy: WorkflowPolicy = {
    name: '',
    description: '',
    nodes: [],
    transitions: [],
    swimlanes: []
  };

  policyId: string | null = null;
  departments: Department[] = [];

  // Estado del editor
  selectedNode: WorkflowNode | null = null;
  selectedTransition: WorkflowTransition | null = null;
  draggingNode: WorkflowNode | null = null;
  connectingFrom: WorkflowNode | null = null;

  // Configuración del canvas
  canvasWidth = 3000;
  canvasHeight = 2000;
  swimlaneHeight = 200;

  // Panel lateral
  showProperties = false;
  editingTransitionLabel = '';
  editingTransitionCondition = '';

  // Mensajes
  message = '';
  messageType: 'success' | 'error' = 'success';

  // Paleta de nodos
  nodeTypes = [
    { type: 'START', label: 'Inicio', icon: '▶', color: '#34d399' },
    { type: 'ACTIVITY', label: 'Actividad', icon: '📋', color: '#667eea' },
    { type: 'DECISION', label: 'Decisión', icon: '◆', color: '#fbbf24' },
    { type: 'FORK', label: 'Fork', icon: '⑂', color: '#f97316' },
    { type: 'JOIN', label: 'Join', icon: '⑃', color: '#8b5cf6' },
    { type: 'END', label: 'Fin', icon: '⏹', color: '#ef4444' },
  ];

  // Colores para swimlanes
  swimlaneColors = ['#667eea', '#f093fb', '#4facfe', '#43e97b', '#fbbf24', '#f97316', '#ef4444', '#8b5cf6'];

  private nodeCounter = 0;
  private dragOffsetX = 0;
  private dragOffsetY = 0;

  constructor(
    private authService: AuthService,
    private policyService: PolicyService,
    private deptService: DepartmentService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    this.deptService.getAll().subscribe(depts => this.departments = depts);

    this.route.params.subscribe(params => {
      if (params['id']) {
        this.policyId = params['id'];
        this.loadPolicy(this.policyId!);
      }
    });
  }

  loadPolicy(id: string): void {
    this.policyService.getById(id).subscribe({
      next: (policy) => {
        this.policy = policy;
        this.nodeCounter = policy.nodes.length;
      },
      error: () => this.showMessage('Error al cargar la política', 'error')
    });
  }

  // ==================== SWIMLANES ====================
  addSwimlane(dept: Department): void {
    if (this.policy.swimlanes.find(s => s.departmentId === dept.id)) {
      this.showMessage('Este departamento ya tiene una calle', 'error');
      return;
    }
    const swimlane: PolicySwimlane = {
      id: 'sl-' + Date.now(),
      departmentId: dept.id!,
      departmentName: dept.name,
      order: this.policy.swimlanes.length,
      color: this.swimlaneColors[this.policy.swimlanes.length % this.swimlaneColors.length]
    };
    this.policy.swimlanes.push(swimlane);
    this.canvasHeight = Math.max(2000, (this.policy.swimlanes.length + 1) * this.swimlaneHeight);
  }

  removeSwimlane(id: string): void {
    this.policy.swimlanes = this.policy.swimlanes.filter(s => s.id !== id);
    // Reordenar
    this.policy.swimlanes.forEach((s, i) => s.order = i);
  }

  getSwimlaneY(swimlane: PolicySwimlane): number {
    return 60 + swimlane.order * this.swimlaneHeight;
  }

  // ==================== NODOS ====================
  addNode(type: string): void {
    this.nodeCounter++;
    const defaultLabel = this.getDefaultLabel(type);
    const firstSwimlane = this.policy.swimlanes[0];

    const node: WorkflowNode = {
      id: 'node-' + Date.now() + '-' + this.nodeCounter,
      type: type as any,
      label: defaultLabel,
      departmentId: firstSwimlane?.departmentId || '',
      x: 200 + (this.policy.nodes.length * 60) % 800,
      y: firstSwimlane ? this.getSwimlaneY(firstSwimlane) + this.swimlaneHeight / 2 : 160,
    };

    this.policy.nodes.push(node);
    this.selectNode(node);
  }

  getDefaultLabel(type: string): string {
    const labels: Record<string, string> = {
      'START': 'Inicio',
      'END': 'Fin',
      'ACTIVITY': 'Actividad ' + (this.nodeCounter),
      'DECISION': 'Decisión ' + (this.nodeCounter),
      'FORK': 'Fork',
      'JOIN': 'Join'
    };
    return labels[type] || type;
  }

  selectNode(node: WorkflowNode): void {
    this.selectedNode = node;
    this.selectedTransition = null;
    this.showProperties = true;
  }

  deleteNode(nodeId: string): void {
    this.policy.nodes = this.policy.nodes.filter(n => n.id !== nodeId);
    this.policy.transitions = this.policy.transitions.filter(
      t => t.sourceNodeId !== nodeId && t.targetNodeId !== nodeId
    );
    this.selectedNode = null;
    this.showProperties = false;
  }

  // ==================== DRAG ====================
  onNodeMouseDown(event: MouseEvent, node: WorkflowNode): void {
    event.preventDefault();
    event.stopPropagation();

    if (this.connectingFrom) {
      // Estamos en modo conexión — conectar al nodo
      this.createTransition(this.connectingFrom, node);
      this.connectingFrom = null;
      return;
    }

    this.draggingNode = node;
    const svgRect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.dragOffsetX = event.clientX - svgRect.left - node.x;
    this.dragOffsetY = event.clientY - svgRect.top - node.y;

    this.selectNode(node);
  }

  onCanvasMouseMove(event: MouseEvent): void {
    if (!this.draggingNode) return;
    const svgRect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.draggingNode.x = Math.max(20, event.clientX - svgRect.left - this.dragOffsetX);
    this.draggingNode.y = Math.max(20, event.clientY - svgRect.top - this.dragOffsetY);

    // Snap to swimlane
    const swimlane = this.getClosestSwimlane(this.draggingNode.y);
    if (swimlane) {
      this.draggingNode.departmentId = swimlane.departmentId;
    }
  }

  onCanvasMouseUp(): void {
    this.draggingNode = null;
  }

  getClosestSwimlane(y: number): PolicySwimlane | null {
    for (const sl of this.policy.swimlanes) {
      const slY = this.getSwimlaneY(sl);
      if (y >= slY && y <= slY + this.swimlaneHeight) {
        return sl;
      }
    }
    return null;
  }

  // ==================== CONEXIONES ====================
  startConnection(node: WorkflowNode): void {
    this.connectingFrom = node;
  }

  cancelConnection(): void {
    this.connectingFrom = null;
  }

  createTransition(from: WorkflowNode, to: WorkflowNode): void {
    if (from.id === to.id) return;

    const exists = this.policy.transitions.find(
      t => t.sourceNodeId === from.id && t.targetNodeId === to.id
    );
    if (exists) {
      this.showMessage('Esta conexión ya existe', 'error');
      return;
    }

    const transition: WorkflowTransition = {
      id: 'tr-' + Date.now(),
      sourceNodeId: from.id,
      targetNodeId: to.id,
      label: '',
      condition: ''
    };
    this.policy.transitions.push(transition);
  }

  selectTransition(transition: WorkflowTransition): void {
    this.selectedTransition = transition;
    this.selectedNode = null;
    this.editingTransitionLabel = transition.label || '';
    this.editingTransitionCondition = transition.condition || '';
    this.showProperties = true;
  }

  updateTransition(): void {
    if (!this.selectedTransition) return;
    this.selectedTransition.label = this.editingTransitionLabel;
    this.selectedTransition.condition = this.editingTransitionCondition;
  }

  deleteTransition(id: string): void {
    this.policy.transitions = this.policy.transitions.filter(t => t.id !== id);
    this.selectedTransition = null;
    this.showProperties = false;
  }

  // Calcular ruta de flecha entre nodos
  getTransitionPath(transition: WorkflowTransition): string {
    const source = this.policy.nodes.find(n => n.id === transition.sourceNodeId);
    const target = this.policy.nodes.find(n => n.id === transition.targetNodeId);
    if (!source || !target) return '';

    const sx = source.x + 60;
    const sy = source.y;
    const tx = target.x - 60;
    const ty = target.y;

    // Curva bezier suave
    const midX = (sx + tx) / 2;
    return `M ${sx} ${sy} C ${midX} ${sy}, ${midX} ${ty}, ${tx} ${ty}`;
  }

  getTransitionMidPoint(transition: WorkflowTransition): { x: number; y: number } {
    const source = this.policy.nodes.find(n => n.id === transition.sourceNodeId);
    const target = this.policy.nodes.find(n => n.id === transition.targetNodeId);
    if (!source || !target) return { x: 0, y: 0 };
    return {
      x: (source.x + target.x) / 2,
      y: (source.y + target.y) / 2 - 15
    };
  }

  // ==================== NODO VISUAL ====================
  getNodeColor(type: string): string {
    return this.nodeTypes.find(n => n.type === type)?.color || '#667eea';
  }

  getNodeWidth(type: string): number {
    if (type === 'START' || type === 'END') return 50;
    if (type === 'DECISION') return 50;
    if (type === 'FORK' || type === 'JOIN') return 60;
    return 120;
  }

  getNodeHeight(type: string): number {
    if (type === 'START' || type === 'END') return 50;
    if (type === 'DECISION') return 50;
    if (type === 'FORK' || type === 'JOIN') return 30;
    return 50;
  }

  // ==================== GUARDAR ====================
  savePolicy(): void {
    if (!this.policy.name.trim()) {
      this.showMessage('El nombre de la política es obligatorio', 'error');
      return;
    }

    if (this.policyId) {
      this.policyService.update(this.policyId, this.policy).subscribe({
        next: () => this.showMessage('Política guardada exitosamente', 'success'),
        error: (err) => this.showMessage(err.error?.error || 'Error al guardar', 'error')
      });
    } else {
      this.policyService.create(this.policy).subscribe({
        next: (created) => {
          this.policyId = created.id!;
          this.policy = created;
          this.showMessage('Política creada exitosamente', 'success');
          this.router.navigate(['/designer', created.id], { replaceUrl: true });
        },
        error: (err) => this.showMessage(err.error?.error || 'Error al crear', 'error')
      });
    }
  }

  publishPolicy(): void {
    if (!this.policyId) {
      this.showMessage('Primero guarda la política', 'error');
      return;
    }
    this.policyService.publish(this.policyId).subscribe({
      next: (updated) => {
        this.policy = updated;
        this.showMessage('¡Política publicada! Ya puede usarse para crear trámites.', 'success');
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al publicar', 'error')
    });
  }

  // ==================== UI ====================
  goBack(): void {
    this.router.navigate(['/policies']);
  }

  getSwimlaneNameForNode(node: WorkflowNode): string {
    const sl = this.policy.swimlanes.find(s => s.departmentId === node.departmentId);
    return sl?.departmentName || 'Sin departamento';
  }

  showMessage(msg: string, type: 'success' | 'error'): void {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => this.message = '', 3000);
  }

  logout(): void {
    this.authService.logout();
  }
}
