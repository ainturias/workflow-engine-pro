import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Activity } from '../models/config.model';

@Injectable({
  providedIn: 'root'
})
export class ActivityService {

  private readonly API_URL = 'http://localhost:8080/api/activities';

  constructor(private http: HttpClient) {}

  getAll(): Observable<Activity[]> {
    return this.http.get<Activity[]>(this.API_URL);
  }

  getByDepartment(departmentId: string): Observable<Activity[]> {
    return this.http.get<Activity[]>(`${this.API_URL}/department/${departmentId}`);
  }

  getById(id: string): Observable<Activity> {
    return this.http.get<Activity>(`${this.API_URL}/${id}`);
  }

  create(activity: Activity): Observable<Activity> {
    return this.http.post<Activity>(this.API_URL, activity);
  }

  update(id: string, activity: Activity): Observable<Activity> {
    return this.http.put<Activity>(`${this.API_URL}/${id}`, activity);
  }

  delete(id: string): Observable<any> {
    return this.http.delete(`${this.API_URL}/${id}`);
  }
}
