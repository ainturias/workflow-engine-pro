import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { TramiteService } from '../../services/tramite.service';
import { User } from '../../models/auth.model';

interface TaskItem {
  tramiteId: string;
  tramiteName: string;
  stepId: string;
  nodeId: string;
  taskName: string;
  status: string;
  assignedAt: string;
  completedAt?: string;
  completedByName?: string;
  comment?: string;
  requestedBy: string;
  tramiteStatus: string;
  formFields?: FormFieldDef[];
}

interface FormFieldDef {
  name: string;
  label: string;
  type: string;
  required: boolean;
  options?: string[];
  defaultValue?: string;
}

@Component({
  selector: 'app-funcionario',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './funcionario.component.html',
  styleUrl: './funcionario.component.scss'
})
export class FuncionarioComponent implements OnInit, OnDestroy {
  currentUser: User | null = null;

  pendingTasks: TaskItem[] = [];
  completedTasks: TaskItem[] = [];

  activeTab: 'pending' | 'completed' = 'pending';

  // Modal de completar tarea
  showTaskModal = false;
  selectedTask: TaskItem | null = null;
  formValues: Record<string, any> = {};
  taskComment = '';

  message = '';
  messageType: 'success' | 'error' = 'success';

  private refreshInterval: any;

  constructor(
    private authService: AuthService,
    private tramiteService: TramiteService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.loadTasks();

    // Auto-refresh cada 15 segundos
    this.refreshInterval = setInterval(() => this.loadTasks(), 15000);
  }

  ngOnDestroy(): void {
    if (this.refreshInterval) clearInterval(this.refreshInterval);
  }

  loadTasks(): void {
    if (!this.currentUser?.departmentId) {
      this.pendingTasks = [];
      this.completedTasks = [];
      return;
    }

    this.tramiteService.getUserTasks(this.currentUser.departmentId).subscribe({
      next: (data: any) => {
        this.pendingTasks = data.pending || [];
        this.completedTasks = data.completed || [];
      },
      error: () => this.showMessage('Error al cargar tareas', 'error')
    });
  }

  // ==================== FORMULARIO DINÁMICO ====================

  openTaskModal(task: TaskItem): void {
    this.selectedTask = task;
    this.formValues = {};
    this.taskComment = '';

    // Inicializar valores por defecto
    if (task.formFields) {
      task.formFields.forEach(field => {
        this.formValues[field.name] = field.defaultValue || '';
        if (field.type === 'CHECKBOX') {
          this.formValues[field.name] = false;
        }
      });
    }

    this.showTaskModal = true;
  }

  closeTaskModal(): void {
    this.showTaskModal = false;
    this.selectedTask = null;
  }

  isFormValid(): boolean {
    if (!this.selectedTask?.formFields) return true;
    return this.selectedTask.formFields
      .filter(f => f.required)
      .every(f => {
        const val = this.formValues[f.name];
        return val !== undefined && val !== null && val !== '';
      });
  }

  submitTask(): void {
    if (!this.selectedTask || !this.currentUser) return;

    // Convertir valores numéricos
    const formData: Record<string, any> = {};
    Object.entries(this.formValues).forEach(([key, val]) => {
      if (typeof val === 'string') {
        const num = parseFloat(val);
        formData[key] = isNaN(num) ? val : num;
      } else {
        formData[key] = val;
      }
    });

    this.tramiteService.completeTask(
      this.selectedTask.tramiteId,
      this.selectedTask.nodeId,
      this.currentUser.id,
      `${this.currentUser.firstName} ${this.currentUser.lastName}`,
      formData,
      this.taskComment
    ).subscribe({
      next: () => {
        this.showMessage('✅ Tarea completada. El trámite avanzó al siguiente paso.', 'success');
        this.closeTaskModal();
        this.loadTasks();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al completar', 'error')
    });
  }

  // ==================== UI ====================

  goBack(): void {
    this.router.navigate(['/dashboard']);
  }

  showMessage(msg: string, type: 'success' | 'error'): void {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => this.message = '', 4000);
  }

  getTimeAgo(dateStr: string): string {
    const date = new Date(dateStr);
    const now = new Date();
    const diff = Math.floor((now.getTime() - date.getTime()) / 60000);
    if (diff < 1) return 'Ahora';
    if (diff < 60) return `hace ${diff} min`;
    if (diff < 1440) return `hace ${Math.floor(diff / 60)}h`;
    return `hace ${Math.floor(diff / 1440)}d`;
  }
}
