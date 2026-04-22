import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { User } from '../../models/auth.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit {
  user: User | null = null;

  constructor(private authService: AuthService, private router: Router) {}

  ngOnInit(): void {
    this.authService.currentUser$.subscribe(user => {
      this.user = user;
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
