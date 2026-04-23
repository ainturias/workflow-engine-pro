import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import {
  DashboardSummary,
  GeneralMetrics,
  FuncionarioMetrics,
  BottleneckInfo,
  DepartmentLoad,
  TramiteTrend
} from '../models/analytics.model';

@Injectable({
  providedIn: 'root'
})
export class AnalyticsService {

  private readonly API_URL = 'http://localhost:8080/api/analytics';

  constructor(private http: HttpClient) {}

  getSummary(): Observable<DashboardSummary> {
    return this.http.get<DashboardSummary>(`${this.API_URL}/summary`);
  }

  getGeneralMetrics(): Observable<GeneralMetrics> {
    return this.http.get<GeneralMetrics>(`${this.API_URL}/general`);
  }

  getFuncionarioMetrics(departmentId?: string): Observable<FuncionarioMetrics[]> {
    const params = departmentId ? `?departmentId=${departmentId}` : '';
    return this.http.get<FuncionarioMetrics[]>(`${this.API_URL}/funcionarios${params}`);
  }

  getBottlenecks(): Observable<BottleneckInfo[]> {
    return this.http.get<BottleneckInfo[]>(`${this.API_URL}/bottlenecks`);
  }

  getDepartmentLoad(): Observable<DepartmentLoad[]> {
    return this.http.get<DepartmentLoad[]>(`${this.API_URL}/departments`);
  }

  getTrends(): Observable<TramiteTrend[]> {
    return this.http.get<TramiteTrend[]>(`${this.API_URL}/trends`);
  }
}
