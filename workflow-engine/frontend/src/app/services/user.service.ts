import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { User } from '../models/auth.model';

@Injectable({
  providedIn: 'root'
})
export class UserService {

  private readonly API_URL = 'http://localhost:8080/api/users';

  constructor(private http: HttpClient) {}

  getAll(): Observable<User[]> {
    return this.http.get<User[]>(this.API_URL);
  }

  getById(id: string): Observable<User> {
    return this.http.get<User>(`${this.API_URL}/${id}`);
  }

  getByRole(role: string): Observable<User[]> {
    return this.http.get<User[]>(`${this.API_URL}/role/${role}`);
  }

  assignDepartment(userId: string, departmentId: string): Observable<User> {
    return this.http.patch<User>(`${this.API_URL}/${userId}/department`, { departmentId });
  }

  updateRole(userId: string, role: string): Observable<User> {
    return this.http.patch<User>(`${this.API_URL}/${userId}/role`, { role });
  }

  deactivate(userId: string): Observable<any> {
    return this.http.delete(`${this.API_URL}/${userId}`);
  }
}
