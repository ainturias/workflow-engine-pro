import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration, ChartData, ChartType } from 'chart.js';
import {
  Chart,
  CategoryScale,
  LinearScale,
  BarElement,
  BarController,
  LineElement,
  LineController,
  PointElement,
  ArcElement,
  DoughnutController,
  Tooltip,
  Legend,
  Filler
} from 'chart.js';
import { AnalyticsService } from '../../services/analytics.service';
import {
  DashboardSummary,
  FuncionarioMetrics,
  BottleneckInfo,
  DepartmentLoad
} from '../../models/analytics.model';

// Registrar componentes de Chart.js
Chart.register(
  CategoryScale,
  LinearScale,
  BarElement,
  BarController,
  LineElement,
  LineController,
  PointElement,
  ArcElement,
  DoughnutController,
  Tooltip,
  Legend,
  Filler
);

@Component({
  selector: 'app-analytics',
  standalone: true,
  imports: [CommonModule, BaseChartDirective],
  templateUrl: './analytics.component.html',
  styleUrl: './analytics.component.scss'
})
export class AnalyticsComponent implements OnInit {

  summary: DashboardSummary | null = null;
  loading = true;
  error: string | null = null;

  // ===== Doughnut: Distribución por Estado =====
  doughnutData: ChartData<'doughnut'> = {
    labels: ['En Curso', 'Completados', 'Cancelados'],
    datasets: [{
      data: [0, 0, 0],
      backgroundColor: ['#667eea', '#43e97b', '#f5576c'],
      borderColor: 'transparent',
      hoverOffset: 8
    }]
  };
  doughnutOptions: ChartConfiguration<'doughnut'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom',
        labels: { color: 'rgba(255,255,255,0.7)', padding: 16, font: { size: 12 } }
      },
      tooltip: {
        backgroundColor: 'rgba(15,14,23,0.9)',
        titleColor: '#fff',
        bodyColor: 'rgba(255,255,255,0.8)',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1
      }
    },
    cutout: '65%'
  };

  // ===== Line: Tendencia 30 días =====
  lineData: ChartData<'line'> = {
    labels: [],
    datasets: [{
      data: [],
      label: 'Trámites creados',
      borderColor: '#667eea',
      backgroundColor: 'rgba(102,126,234,0.1)',
      fill: true,
      tension: 0.4,
      pointRadius: 2,
      pointHoverRadius: 6,
      pointBackgroundColor: '#667eea',
      pointBorderColor: '#667eea'
    }]
  };
  lineOptions: ChartConfiguration<'line'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: 'rgba(15,14,23,0.9)',
        titleColor: '#fff',
        bodyColor: 'rgba(255,255,255,0.8)',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1
      }
    },
    scales: {
      x: {
        ticks: { color: 'rgba(255,255,255,0.4)', maxTicksLimit: 10, font: { size: 10 } },
        grid: { color: 'rgba(255,255,255,0.05)' }
      },
      y: {
        beginAtZero: true,
        ticks: { color: 'rgba(255,255,255,0.4)', stepSize: 1, font: { size: 10 } },
        grid: { color: 'rgba(255,255,255,0.05)' }
      }
    }
  };

  // ===== Bar: Trámites por Política =====
  policyBarData: ChartData<'bar'> = {
    labels: [],
    datasets: [{
      data: [],
      label: 'Trámites',
      backgroundColor: [
        'rgba(102,126,234,0.7)', 'rgba(118,75,162,0.7)', 'rgba(240,147,251,0.7)',
        'rgba(79,172,254,0.7)', 'rgba(67,233,123,0.7)', 'rgba(245,87,108,0.7)'
      ],
      borderColor: 'transparent',
      borderRadius: 8
    }]
  };
  policyBarOptions: ChartConfiguration<'bar'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    indexAxis: 'y',
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: 'rgba(15,14,23,0.9)',
        titleColor: '#fff',
        bodyColor: 'rgba(255,255,255,0.8)',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1
      }
    },
    scales: {
      x: {
        beginAtZero: true,
        ticks: { color: 'rgba(255,255,255,0.4)', stepSize: 1, font: { size: 11 } },
        grid: { color: 'rgba(255,255,255,0.05)' }
      },
      y: {
        ticks: { color: 'rgba(255,255,255,0.7)', font: { size: 11 } },
        grid: { display: false }
      }
    }
  };

  // ===== Bar: Comparación de Funcionarios =====
  funcionarioBarData: ChartData<'bar'> = {
    labels: [],
    datasets: [
      {
        data: [],
        label: 'Tareas completadas',
        backgroundColor: 'rgba(102,126,234,0.7)',
        borderRadius: 6
      },
      {
        data: [],
        label: 'Tiempo prom. (horas)',
        backgroundColor: 'rgba(245,87,108,0.5)',
        borderRadius: 6
      }
    ]
  };
  funcionarioBarOptions: ChartConfiguration<'bar'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
        labels: { color: 'rgba(255,255,255,0.7)', padding: 12, font: { size: 11 } }
      },
      tooltip: {
        backgroundColor: 'rgba(15,14,23,0.9)',
        titleColor: '#fff',
        bodyColor: 'rgba(255,255,255,0.8)',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1
      }
    },
    scales: {
      x: {
        ticks: { color: 'rgba(255,255,255,0.5)', font: { size: 10 } },
        grid: { display: false }
      },
      y: {
        beginAtZero: true,
        ticks: { color: 'rgba(255,255,255,0.4)', font: { size: 10 } },
        grid: { color: 'rgba(255,255,255,0.05)' }
      }
    }
  };

  // ===== Bar: Carga por Departamento =====
  deptBarData: ChartData<'bar'> = {
    labels: [],
    datasets: [{
      data: [],
      label: 'Tareas pendientes',
      backgroundColor: [],
      borderRadius: 8
    }]
  };
  deptBarOptions: ChartConfiguration<'bar'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    indexAxis: 'y',
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: 'rgba(15,14,23,0.9)',
        titleColor: '#fff',
        bodyColor: 'rgba(255,255,255,0.8)',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1
      }
    },
    scales: {
      x: {
        beginAtZero: true,
        ticks: { color: 'rgba(255,255,255,0.4)', stepSize: 1, font: { size: 11 } },
        grid: { color: 'rgba(255,255,255,0.05)' }
      },
      y: {
        ticks: { color: 'rgba(255,255,255,0.7)', font: { size: 11 } },
        grid: { display: false }
      }
    }
  };

  constructor(
    private analyticsService: AnalyticsService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.loading = true;
    this.error = null;

    this.analyticsService.getSummary().subscribe({
      next: (data) => {
        this.summary = data;
        this.updateCharts();
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading analytics:', err);
        this.error = 'Error al cargar las métricas. Verifica que el backend esté corriendo.';
        this.loading = false;
      }
    });
  }

  private updateCharts(): void {
    if (!this.summary) return;

    const gm = this.summary.generalMetrics;

    // Doughnut
    this.doughnutData = {
      ...this.doughnutData,
      datasets: [{
        ...this.doughnutData.datasets[0],
        data: [gm.totalActive, gm.totalCompleted, gm.totalCancelled]
      }]
    };

    // Line — Tendencia
    const trends = this.summary.trends;
    this.lineData = {
      labels: trends.map(t => t.date.substring(5)),  // MM-DD
      datasets: [{
        ...this.lineData.datasets[0],
        data: trends.map(t => t.count)
      }]
    };

    // Bar — Por política
    const policies = gm.tramitesByPolicy;
    this.policyBarData = {
      labels: policies.map(p => p.policyName.length > 25 ? p.policyName.substring(0, 25) + '...' : p.policyName),
      datasets: [{
        ...this.policyBarData.datasets[0],
        data: policies.map(p => p.count)
      }]
    };

    // Bar — Funcionarios
    const funcs = this.summary.funcionarioMetrics;
    this.funcionarioBarData = {
      labels: funcs.map(f => f.name.length > 15 ? f.name.substring(0, 15) + '...' : f.name),
      datasets: [
        {
          ...this.funcionarioBarData.datasets[0],
          data: funcs.map(f => f.tasksCompleted)
        },
        {
          ...this.funcionarioBarData.datasets[1],
          data: funcs.map(f => f.avgAttentionHours)
        }
      ]
    };

    // Bar — Departamentos
    const depts = this.summary.departmentLoads;
    this.deptBarData = {
      labels: depts.map(d => d.name),
      datasets: [{
        ...this.deptBarData.datasets[0],
        data: depts.map(d => d.pendingTasks),
        backgroundColor: depts.map(d => {
          if (d.saturationLevel >= 70) return 'rgba(245,87,108,0.7)';
          if (d.saturationLevel >= 40) return 'rgba(251,191,36,0.7)';
          return 'rgba(67,233,123,0.7)';
        })
      }]
    };
  }

  getSeverityClass(severity: string): string {
    switch (severity) {
      case 'HIGH': return 'severity-high';
      case 'MEDIUM': return 'severity-medium';
      default: return 'severity-low';
    }
  }

  getSeverityLabel(severity: string): string {
    switch (severity) {
      case 'HIGH': return '🔴 Crítico';
      case 'MEDIUM': return '🟡 Medio';
      default: return '🟢 Bajo';
    }
  }

  getSaturationClass(level: number): string {
    if (level >= 70) return 'saturation-high';
    if (level >= 40) return 'saturation-medium';
    return 'saturation-low';
  }

  formatHours(hours: number): string {
    if (hours < 1) {
      return Math.round(hours * 60) + ' min';
    }
    return hours.toFixed(1) + ' hrs';
  }

  goBack(): void {
    this.router.navigate(['/dashboard']);
  }
}
