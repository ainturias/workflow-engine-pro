import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { DepartmentService } from '../../services/department.service';
import { ActivityService } from '../../services/activity.service';
import { UserService } from '../../services/user.service';
import { Department, Activity } from '../../models/config.model';
import { User } from '../../models/auth.model';

@Component({
  selector: 'app-admin',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin.component.html',
  styleUrl: './admin.component.scss'
})
export class AdminComponent implements OnInit {
  activeTab = 'departments';
  currentUser: User | null = null;

  // Departamentos
  departments: Department[] = [];
  newDepartment: Department = { name: '', description: '' };
  editingDeptId: string | null = null;

  // Actividades
  activities: Activity[] = [];
  newActivity: Activity = { name: '', description: '', departmentId: '' };
  editingActId: string | null = null;

  // Usuarios
  users: User[] = [];
  selectedUserId: string | null = null;
  selectedDeptForUser = '';

  // Estado
  loading = false;
  message = '';
  messageType: 'success' | 'error' = 'success';

  constructor(
    private authService: AuthService,
    private deptService: DepartmentService,
    private actService: ActivityService,
    private userService: UserService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.loadDepartments();
    this.loadActivities();
    this.loadUsers();
  }

  setTab(tab: string): void {
    this.activeTab = tab;
    this.clearMessage();
  }

  // ==================== DEPARTAMENTOS ====================
  loadDepartments(): void {
    this.deptService.getAll().subscribe(data => this.departments = data);
  }

  createDepartment(): void {
    if (!this.newDepartment.name.trim()) return;
    this.deptService.create(this.newDepartment).subscribe({
      next: () => {
        this.showMessage('Departamento creado exitosamente', 'success');
        this.newDepartment = { name: '', description: '' };
        this.loadDepartments();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al crear', 'error')
    });
  }

  startEditDept(dept: Department): void {
    this.editingDeptId = dept.id!;
    this.newDepartment = { name: dept.name, description: dept.description };
  }

  updateDepartment(): void {
    if (!this.editingDeptId) return;
    this.deptService.update(this.editingDeptId, this.newDepartment).subscribe({
      next: () => {
        this.showMessage('Departamento actualizado', 'success');
        this.cancelEditDept();
        this.loadDepartments();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al actualizar', 'error')
    });
  }

  cancelEditDept(): void {
    this.editingDeptId = null;
    this.newDepartment = { name: '', description: '' };
  }

  deleteDepartment(id: string): void {
    if (confirm('¿Deseas eliminar este departamento?')) {
      this.deptService.delete(id).subscribe({
        next: () => {
          this.showMessage('Departamento eliminado', 'success');
          this.loadDepartments();
        },
        error: (err) => this.showMessage(err.error?.error || 'Error al eliminar', 'error')
      });
    }
  }

  // ==================== ACTIVIDADES ====================
  loadActivities(): void {
    this.actService.getAll().subscribe(data => this.activities = data);
  }

  createActivity(): void {
    if (!this.newActivity.name.trim() || !this.newActivity.departmentId) return;
    this.actService.create(this.newActivity).subscribe({
      next: () => {
        this.showMessage('Actividad creada exitosamente', 'success');
        this.newActivity = { name: '', description: '', departmentId: '' };
        this.loadActivities();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al crear', 'error')
    });
  }

  startEditAct(act: Activity): void {
    this.editingActId = act.id!;
    this.newActivity = { name: act.name, description: act.description, departmentId: act.departmentId };
  }

  updateActivity(): void {
    if (!this.editingActId) return;
    this.actService.update(this.editingActId, this.newActivity).subscribe({
      next: () => {
        this.showMessage('Actividad actualizada', 'success');
        this.cancelEditAct();
        this.loadActivities();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al actualizar', 'error')
    });
  }

  cancelEditAct(): void {
    this.editingActId = null;
    this.newActivity = { name: '', description: '', departmentId: '' };
  }

  deleteActivity(id: string): void {
    if (confirm('¿Deseas eliminar esta actividad?')) {
      this.actService.delete(id).subscribe({
        next: () => {
          this.showMessage('Actividad eliminada', 'success');
          this.loadActivities();
        },
        error: (err) => this.showMessage(err.error?.error || 'Error al eliminar', 'error')
      });
    }
  }

  getDeptName(deptId: string): string {
    return this.departments.find(d => d.id === deptId)?.name || 'Sin asignar';
  }

  // ==================== USUARIOS ====================
  loadUsers(): void {
    this.userService.getAll().subscribe(data => this.users = data);
  }

  assignDepartment(userId: string, departmentId: string): void {
    this.userService.assignDepartment(userId, departmentId).subscribe({
      next: () => {
        this.showMessage('Departamento asignado', 'success');
        this.loadUsers();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error', 'error')
    });
  }

  // ==================== UTILIDADES ====================
  showMessage(msg: string, type: 'success' | 'error'): void {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => this.clearMessage(), 3000);
  }

  clearMessage(): void {
    this.message = '';
  }

  logout(): void {
    this.authService.logout();
  }

  goToDashboard(): void {
    this.router.navigate(['/dashboard']);
  }
}
