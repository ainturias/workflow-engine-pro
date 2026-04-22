import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PolicyService } from '../../services/policy.service';
import { WorkflowPolicy } from '../../models/workflow.model';
import { User } from '../../models/auth.model';

@Component({
  selector: 'app-policies',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './policies.component.html',
  styleUrl: './policies.component.scss'
})
export class PoliciesComponent implements OnInit {
  policies: WorkflowPolicy[] = [];
  currentUser: User | null = null;
  message = '';
  messageType: 'success' | 'error' = 'success';

  constructor(
    private authService: AuthService,
    private policyService: PolicyService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.loadPolicies();
  }

  loadPolicies(): void {
    this.policyService.getAll().subscribe(data => this.policies = data);
  }

  createNew(): void {
    this.router.navigate(['/designer']);
  }

  editPolicy(id: string): void {
    this.router.navigate(['/designer', id]);
  }

  publishPolicy(id: string): void {
    this.policyService.publish(id).subscribe({
      next: () => {
        this.showMessage('Política publicada', 'success');
        this.loadPolicies();
      },
      error: (err) => this.showMessage(err.error?.error || 'Error al publicar', 'error')
    });
  }

  deletePolicy(id: string): void {
    if (confirm('¿Eliminar esta política?')) {
      this.policyService.delete(id).subscribe({
        next: () => {
          this.showMessage('Política eliminada', 'success');
          this.loadPolicies();
        },
        error: (err) => this.showMessage(err.error?.error || 'Error', 'error')
      });
    }
  }

  goBack(): void {
    this.router.navigate(['/dashboard']);
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
