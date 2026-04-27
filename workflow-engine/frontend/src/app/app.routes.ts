import { Routes } from '@angular/router';
import { authGuard, roleGuard } from './guards/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.component').then(m => m.LoginComponent)
  },
  {
    path: 'register',
    loadComponent: () => import('./pages/register/register.component').then(m => m.RegisterComponent)
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./pages/dashboard/dashboard.component').then(m => m.DashboardComponent),
    canActivate: [authGuard]
  },
  {
    path: 'admin',
    loadComponent: () => import('./pages/admin/admin.component').then(m => m.AdminComponent),
    canActivate: [roleGuard],
    data: { role: 'ADMIN' }
  },
  {
    path: 'policies',
    loadComponent: () => import('./pages/policies/policies.component').then(m => m.PoliciesComponent),
    canActivate: [authGuard]
  },
  {
    path: 'designer',
    loadComponent: () => import('./pages/workflow-designer/workflow-designer.component').then(m => m.WorkflowDesignerComponent),
    canActivate: [authGuard]
  },
  {
    path: 'designer/:id',
    loadComponent: () => import('./pages/workflow-designer/workflow-designer.component').then(m => m.WorkflowDesignerComponent),
    canActivate: [authGuard]
  },
  {
    path: 'designer/:policyId/form-builder/:nodeId',
    loadComponent: () => import('./pages/form-builder/form-builder.component').then(m => m.FormBuilderComponent),
    canActivate: [authGuard]
  },
  {
    path: 'tramites',
    loadComponent: () => import('./pages/tramites/tramites.component').then(m => m.TramitesComponent),
    canActivate: [authGuard]
  },
  {
    path: 'funcionario',
    loadComponent: () => import('./pages/funcionario/funcionario.component').then(m => m.FuncionarioComponent),
    canActivate: [authGuard]
  },
  {
    path: 'analytics',
    loadComponent: () => import('./pages/analytics/analytics.component').then(m => m.AnalyticsComponent),
    canActivate: [roleGuard],
    data: { role: 'ADMIN' }
  },
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  },
  {
    path: '**',
    redirectTo: 'login'
  }
];
