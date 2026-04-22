import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { WorkflowPolicy } from '../models/workflow.model';

@Injectable({
  providedIn: 'root'
})
export class PolicyService {

  private readonly API_URL = 'http://localhost:8080/api/policies';

  constructor(private http: HttpClient) {}

  getAll(): Observable<WorkflowPolicy[]> {
    return this.http.get<WorkflowPolicy[]>(this.API_URL);
  }

  getPublished(): Observable<WorkflowPolicy[]> {
    return this.http.get<WorkflowPolicy[]>(`${this.API_URL}/published`);
  }

  getById(id: string): Observable<WorkflowPolicy> {
    return this.http.get<WorkflowPolicy>(`${this.API_URL}/${id}`);
  }

  create(policy: WorkflowPolicy): Observable<WorkflowPolicy> {
    return this.http.post<WorkflowPolicy>(this.API_URL, policy);
  }

  update(id: string, policy: WorkflowPolicy): Observable<WorkflowPolicy> {
    return this.http.put<WorkflowPolicy>(`${this.API_URL}/${id}`, policy);
  }

  publish(id: string): Observable<WorkflowPolicy> {
    return this.http.patch<WorkflowPolicy>(`${this.API_URL}/${id}/publish`, {});
  }

  archive(id: string): Observable<WorkflowPolicy> {
    return this.http.patch<WorkflowPolicy>(`${this.API_URL}/${id}/archive`, {});
  }

  delete(id: string): Observable<any> {
    return this.http.delete(`${this.API_URL}/${id}`);
  }
}
