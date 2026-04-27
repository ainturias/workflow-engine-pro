import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { PolicyService } from '../../services/policy.service';
import { WorkflowPolicy, WorkflowNode } from '../../models/workflow.model';

interface FormField {
  name: string;
  label: string;
  type: string;
  required: boolean;
  placeholder?: string;
  options?: string[];
  optionsText?: string;
  minLength?: number;
  maxLength?: number;
  width?: number; // Ancho en porcentaje (25, 33, 50, 66, 75, 100)
}

@Component({
  selector: 'app-form-builder',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './form-builder.component.html',
  styleUrl: './form-builder.component.scss'
})
export class FormBuilderComponent implements OnInit {
  policyId: string = '';
  nodeId: string = '';
  policy: WorkflowPolicy | null = null;
  node: WorkflowNode | null = null;
  fields: FormField[] = [];

  // Componentes disponibles en grilla
  fieldTypes = [
    { value: 'TEXT',      label: 'Texto',       icon: 'T',  iconClass: 'ic-text' },
    { value: 'TEXTAREA',  label: 'Área texto',  icon: '¶',  iconClass: 'ic-textarea' },
    { value: 'SELECT',    label: 'Desplegable', icon: '≡',  iconClass: 'ic-select' },
    { value: 'CHECKBOX',  label: 'Check',       icon: '☑',  iconClass: 'ic-check' },
    { value: 'RADIO',     label: 'Radio',       icon: '◉',  iconClass: 'ic-radio' },
    { value: 'NUMBER',    label: 'Número',      icon: '#',  iconClass: 'ic-number' },
    { value: 'DATE',      label: 'Fecha',       icon: '📅', iconClass: 'ic-date' },
    { value: 'TIME',      label: 'Hora',        icon: '🕐', iconClass: 'ic-time' },
    { value: 'EMAIL',     label: 'Email',       icon: '@',  iconClass: 'ic-email' },
    { value: 'FILE',      label: 'Archivo',     icon: '📎', iconClass: 'ic-file' },
    { value: 'IMAGE',     label: 'Imagen',      icon: '🖼', iconClass: 'ic-image' },
    { value: 'SIGNATURE', label: 'Firma',       icon: '✍',  iconClass: 'ic-signature' },
    { value: 'TITLE',     label: 'Título',      icon: 'H1', iconClass: 'ic-title' },
    { value: 'LABEL',     label: 'Etiqueta',    icon: 'Aa', iconClass: 'ic-label' },
    { value: 'DIVIDER',   label: 'Separador',   icon: '—',  iconClass: 'ic-divider' },
  ];

  // Opciones de ancho
  widthOptions = [
    { value: 100, label: '100% (Fila completa)' },
    { value: 75,  label: '75% (Tres cuartos)' },
    { value: 66,  label: '66% (Dos tercios)' },
    { value: 50,  label: '50% (Mitad)' },
    { value: 33,  label: '33% (Un tercio)' },
    { value: 25,  label: '25% (Un cuarto)' },
  ];

  // Estado de la UI
  selectedFieldIndex: number = -1;
  accordionComponents = true;
  accordionProperties = true;
  previewMode: 'desktop' | 'mobile' = 'desktop';
  showPreviewColumn = true; // Control de visibilidad de la columna derecha
  message = '';
  messageType: 'success' | 'error' = 'success';
  saving = false;

  constructor(
    private policyService: PolicyService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe(params => {
      this.policyId = params['policyId'];
      this.nodeId = params['nodeId'];
      this.loadPolicy();
    });
  }

  loadPolicy(): void {
    this.policyService.getById(this.policyId).subscribe({
      next: (policy) => {
        this.policy = policy;
        this.node = policy.nodes.find(n => n.id === this.nodeId) || null;
        if (this.node && this.node.formFields) {
          this.fields = this.node.formFields.map(f => ({
            ...f,
            width: f.width || 100,
            optionsText: f.options ? f.options.join(', ') : ''
          }));
        }
      },
      error: () => this.showMessage('Error al cargar la política', 'error')
    });
  }

  // ==================== CAMPO SELECCIONADO ====================
  get selectedField(): FormField | null {
    return this.selectedFieldIndex >= 0 && this.selectedFieldIndex < this.fields.length
      ? this.fields[this.selectedFieldIndex] : null;
  }

  selectField(index: number): void {
    this.selectedFieldIndex = index;
    this.accordionProperties = true;
  }

  // ==================== GESTIÓN DE CAMPOS ====================
  addField(type: string): void {
    const fieldType = this.fieldTypes.find(f => f.value === type);
    const newField: FormField = {
      name: 'campo_' + Date.now(),
      label: fieldType?.label || 'Nuevo Campo',
      type: type,
      required: false,
      placeholder: '',
      width: 100,
      options: (type === 'SELECT' || type === 'RADIO') ? ['Opción 1', 'Opción 2'] : undefined,
      optionsText: (type === 'SELECT' || type === 'RADIO') ? 'Opción 1, Opción 2' : ''
    };
    this.fields.push(newField);
    this.selectField(this.fields.length - 1);
  }

  removeField(index: number): void {
    this.fields.splice(index, 1);
    if (this.selectedFieldIndex === index) {
      this.selectedFieldIndex = -1;
    } else if (this.selectedFieldIndex > index) {
      this.selectedFieldIndex--;
    }
  }

  moveField(from: number, to: number): void {
    if (to < 0 || to >= this.fields.length) return;
    const item = this.fields.splice(from, 1)[0];
    this.fields.splice(to, 0, item);
    this.selectedFieldIndex = to;
  }

  duplicateField(index: number): void {
    const original = this.fields[index];
    const copy: FormField = {
      ...original,
      name: 'campo_' + Date.now(),
      label: original.label + ' (copia)'
    };
    this.fields.splice(index + 1, 0, copy);
    this.selectField(index + 1);
  }

  updateOptions(field: FormField): void {
    if (field.optionsText) {
      field.options = field.optionsText.split(',').map(o => o.trim()).filter(o => o.length > 0);
    }
  }

  // ==================== HELPERS ====================
  getFieldTypeInfo(type: string) {
    return this.fieldTypes.find(f => f.value === type);
  }

  needsPlaceholder(type: string): boolean {
    return ['TEXT', 'TEXTAREA', 'NUMBER', 'EMAIL', 'DATE', 'TIME'].includes(type);
  }

  needsOptions(type: string): boolean {
    return ['SELECT', 'RADIO'].includes(type);
  }

  isInputField(type: string): boolean {
    return !['TITLE', 'LABEL', 'DIVIDER'].includes(type);
  }

  // ==================== GUARDAR ====================
  saveForm(): void {
    if (!this.policy || !this.node) return;
    this.saving = true;

    const cleanFields = this.fields.map(f => {
      const clean: any = {
        name: f.name,
        label: f.label,
        type: f.type,
        required: f.required,
        placeholder: f.placeholder || '',
        width: f.width || 100
      };
      if (this.needsOptions(f.type) && f.options) {
        clean.options = f.options;
      }
      return clean;
    });

    const nodeIndex = this.policy.nodes.findIndex(n => n.id === this.nodeId);
    if (nodeIndex >= 0) {
      this.policy.nodes[nodeIndex].formFields = cleanFields;
    }

    this.policyService.update(this.policyId, this.policy).subscribe({
      next: () => {
        this.saving = false;
        this.showMessage('Formulario guardado exitosamente', 'success');
      },
      error: () => {
        this.saving = false;
        this.showMessage('Error al guardar el formulario', 'error');
      }
    });
  }

  goBack(): void {
    this.router.navigate(['/designer', this.policyId]);
  }

  showMessage(msg: string, type: 'success' | 'error'): void {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => this.message = '', 3000);
  }
}
