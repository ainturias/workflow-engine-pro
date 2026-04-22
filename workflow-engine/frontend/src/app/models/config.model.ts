export interface Department {
  id?: string;
  name: string;
  description: string;
  active?: boolean;
  createdAt?: string;
}

export interface FormField {
  name: string;
  label: string;
  type: 'TEXT' | 'NUMBER' | 'DATE' | 'TEXTAREA' | 'SELECT' | 'CHECKBOX';
  required: boolean;
  options?: string[];
  defaultValue?: string;
}

export interface Activity {
  id?: string;
  name: string;
  description: string;
  departmentId: string;
  formFields?: FormField[];
  active?: boolean;
  createdAt?: string;
}
