import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  // Verificar que existe token Y datos de usuario válidos
  if (authService.isLoggedIn() && authService.getCurrentUser()?.id) {
    return true;
  }

  // Si hay token pero no user data, limpiar todo
  authService.logout();
  return false;
};

export const roleGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (!authService.isLoggedIn() || !authService.getCurrentUser()?.id) {
    authService.logout();
    return false;
  }

  const requiredRole = route.data?.['role'] as string;
  if (requiredRole && !authService.hasRole(requiredRole)) {
    router.navigate(['/dashboard']);
    return false;
  }

  return true;
};
