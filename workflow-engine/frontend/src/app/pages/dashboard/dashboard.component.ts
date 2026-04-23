import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { AnalyticsService } from '../../services/analytics.service';
import { User } from '../../models/auth.model';
import { GeneralMetrics } from '../../models/analytics.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit {
  user: User | null = null;
  metrics: GeneralMetrics | null = null;
  policiesCount = 0;

  constructor(
    private authService: AuthService,
    private analyticsService: AnalyticsService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.authService.currentUser$.subscribe(user => {
      this.user = user;
    });
    this.loadMetrics();
  }

  loadMetrics(): void {
    this.analyticsService.getGeneralMetrics().subscribe({
      next: (data) => {
        this.metrics = data;
        this.policiesCount = data.tramitesByPolicy?.length || 0;
      },
      error: () => {
        // Fail silently — dashboard still works without metrics
      }
    });
  }

  logout(): void {
    this.authService.logout();
  }

  goToAdmin(): void {
    this.router.navigate(['/admin']);
  }

  goToPolicies(): void {
    this.router.navigate(['/policies']);
  }

  goToTramites(): void {
    this.router.navigate(['/tramites']);
  }

  goToFuncionario(): void {
    this.router.navigate(['/funcionario']);
  }

  goToAnalytics(): void {
    this.router.navigate(['/analytics']);
  }
  }

  isAdmin(): boolean {
    return this.user?.role === 'ADMIN';
  }

  getRoleLabel(role: string): string {
    const roles: Record<string, string> = {
      'ADMIN': 'Administrador',
      'DISEÑADOR': 'Diseñador de Políticas',
      'FUNCIONARIO': 'Funcionario',
      'CLIENTE': 'Cliente'
    };
    return roles[role] || role;
  }
}
