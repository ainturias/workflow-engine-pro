import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { TramiteService } from '../../services/tramite.service';
import { PolicyService } from '../../services/policy.service';
import { Tramite, TramiteStep } from '../../models/tramite.model';
import { WorkflowPolicy } from '../../models/workflow.model';
import { User } from '../../models/auth.model';

@Component({
  selector: 'app-tramites',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './tramites.component.html',
  styleUrl: './tramites.component.scss'
})
export class TramitesComponent implements OnInit {
  currentUser: User | null = null;
  tramites: Tramite[] = [];
  publishedPolicies: WorkflowPolicy[] = [];

  // Filtro
  activeFilter = 'all'; // all, EN_CURSO, COMPLETADO, CANCELADO

  // Detalle
  selectedTramite: Tramite | null = null;

  // Completar tarea
  showCompleteModal = false;
  completingTask: { tramiteId: string; nodeId: string; taskName: string } | null = null;
  taskDataFields: { key: string; value: string }[] = [];
  taskComment = '';

  message = '';
  messageType: 'success' | 'error' = 'success';

  constructor(
    private authService: AuthService,
    private tramiteService: TramiteService,
    private policyService: PolicyService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.loadTramites();
    this.loadPolicies();
  }

  loadTramites(): void {
    this.tramiteService.getAll().subscribe(data => this.tramites = data);
  }

  loadPolicies(): void {
    this.policyService.getPublished().subscribe(data => this.publishedPolicies = data);
  }

  get filteredTramites(): Tramite[] {
    if (this.activeFilter === 'all') return this.tramites;
    return this.tramites.filter(t => t.status === this.activeFilter);
  }

  // Iniciar nuevo trámite
  startTramite(policy: WorkflowPolicy): void {
    if (!this.currentUser) return;
    this.tramiteService.startTramite(
      policy.id!,
      this.currentUser.id,
      `${this.currentUser.firstName} ${this.currentUser.lastName}`
    ).subscribe({
      next: (tramite) => {
        this.showMessage('Trámite iniciado exitosamente', 'success');
        this.loadTramites();
        this.viewTramite(tramite);
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al iniciar', 'error')
    });
  }

  viewTramite(tramite: Tramite): void {
    this.selectedTramite = tramite;
  }

  closeTramite(): void {
    this.selectedTramite = null;
  }

  // Obtener tareas pendientes del trámite
  getPendingSteps(tramite: Tramite): TramiteStep[] {
    return tramite.steps.filter(s => s.status === 'PENDING');
  }

  getCompletedSteps(tramite: Tramite): TramiteStep[] {
    return tramite.steps.filter(s => s.status === 'COMPLETED');
  }

  // Abrir modal para completar tarea
  openCompleteTask(tramiteId: string, nodeId: string, taskName: string): void {
    this.completingTask = { tramiteId, nodeId, taskName };
    this.taskDataFields = []; // Limpiar campos
    this.taskComment = '';
    this.showCompleteModal = true;
  }

  addDataField(): void {
    this.taskDataFields.push({ key: '', value: '' });
  }

  removeDataField(index: number): void {
    this.taskDataFields.splice(index, 1);
  }

  submitTask(): void {
    if (!this.completingTask || !this.currentUser) return;

    // Convertir array de campos a objeto JSON
    const formData: Record<string, any> = {};
    this.taskDataFields.forEach(f => {
      if (f.key) {
        // Intentar convertir a número si es posible
        const numVal = parseFloat(f.value);
        formData[f.key] = isNaN(numVal) ? f.value : numVal;
      }
    });

    this.tramiteService.completeTask(
      this.completingTask.tramiteId,
      this.completingTask.nodeId,
      this.currentUser.id,
      `${this.currentUser.firstName} ${this.currentUser.lastName}`,
      formData,
      this.taskComment
    ).subscribe({
      next: (updated) => {
        this.showMessage('Tarea completada. El trámite avanzó.', 'success');
        this.showCompleteModal = false;
        this.completingTask = null;
        this.loadTramites();
        this.selectedTramite = updated;
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al completar', 'error')
    });
  }

  cancelTramite(id: string): void {
    if (confirm('¿Cancelar este trámite?')) {
      this.tramiteService.cancel(id).subscribe({
        next: () => {
          this.showMessage('Trámite cancelado', 'success');
          this.loadTramites();
          this.selectedTramite = null;
        },
        error: (err) => this.showMessage(err.error?.error || 'Error', 'error')
      });
    }
  }

  getStatusLabel(status: string): string {
    const labels: Record<string, string> = {
      'EN_CURSO': '🟡 En Curso',
      'COMPLETADO': '🟢 Completado',
      'CANCELADO': '🔴 Cancelado'
    };
    return labels[status] || status;
  }

  getStepStatusIcon(status: string): string {
    return status === 'COMPLETED' ? '✅' : status === 'PENDING' ? '⏳' : '🔵';
  }

  goBack(): void {
    this.router.navigate(['/dashboard']);
  }

  showMessage(msg: string, type: 'success' | 'error'): void {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => this.message = '', 4000);
  }
}
