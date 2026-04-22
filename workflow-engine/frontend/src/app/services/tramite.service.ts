import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Tramite, PendingTask } from '../models/tramite.model';

@Injectable({
  providedIn: 'root'
})
export class TramiteService {

  private readonly API_URL = 'http://localhost:8080/api/tramites';

  constructor(private http: HttpClient) {}

  startTramite(policyId: string, userId: string, userName: string): Observable<Tramite> {
    return this.http.post<Tramite>(`${this.API_URL}/start`, { policyId, userId, userName });
  }

  completeTask(tramiteId: string, nodeId: string, userId: string, userName: string,
               formData: Record<string, any>, comment: string): Observable<Tramite> {
    return this.http.post<Tramite>(`${this.API_URL}/${tramiteId}/complete`, {
      nodeId, userId, userName, formData, comment
    });
  }

  getAll(): Observable<Tramite[]> {
    return this.http.get<Tramite[]>(this.API_URL);
  }

  getById(id: string): Observable<Tramite> {
    return this.http.get<Tramite>(`${this.API_URL}/${id}`);
  }

  getByStatus(status: string): Observable<Tramite[]> {
    return this.http.get<Tramite[]>(`${this.API_URL}/status/${status}`);
  }

  getByUser(userId: string): Observable<Tramite[]> {
    return this.http.get<Tramite[]>(`${this.API_URL}/user/${userId}`);
  }

  getPendingTasks(departmentId: string): Observable<PendingTask[]> {
    return this.http.get<PendingTask[]>(`${this.API_URL}/tasks/department/${departmentId}`);
  }

  cancel(id: string): Observable<Tramite> {
    return this.http.patch<Tramite>(`${this.API_URL}/${id}/cancel`, {});
  }
}
