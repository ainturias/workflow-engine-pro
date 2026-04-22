import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Department } from '../models/config.model';

@Injectable({
  providedIn: 'root'
})
export class DepartmentService {

  private readonly API_URL = 'http://localhost:8080/api/departments';

  constructor(private http: HttpClient) {}

  getAll(): Observable<Department[]> {
    return this.http.get<Department[]>(this.API_URL);
  }

  getById(id: string): Observable<Department> {
    return this.http.get<Department>(`${this.API_URL}/${id}`);
  }

  create(department: Department): Observable<Department> {
    return this.http.post<Department>(this.API_URL, department);
  }

  update(id: string, department: Department): Observable<Department> {
    return this.http.put<Department>(`${this.API_URL}/${id}`, department);
  }

  delete(id: string): Observable<any> {
    return this.http.delete(`${this.API_URL}/${id}`);
  }
}
