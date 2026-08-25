---
inclusion: always
---

# Frontend Rules — NOC Dashboard (Sistema de Diseño Seguros Bolívar)

## Sistema de Diseño Corporativo

Este proyecto usa el sistema de diseño de Seguros Bolívar adaptado para HTML estático con Tailwind CDN.

### Paleta de Colores (Brand)

| Nombre | Hex | Uso |
|--------|-----|-----|
| Verde Oscuro | `#005727` | Fondos dark premium, gradientes |
| Verde Principal | `#00823b` | Botones primarios, acentos |
| Verde Claro | `#00a64d` | Hover states, gradientes suaves |
| Verde Correo/Header | `#009056` | Headers, badges activos |
| Fondo Verde Claro | `#f4f9f6` | Background principal de página |
| Borde Verde | `#cce6d8` | Bordes sutiles en cards |
| Dorado/Amarillo | `#fed100` | Acento, premios, warnings |
| Dorado Hover | `#f2c700` | Hover del acento dorado |

### Colores de Texto

| Nombre | Hex | Uso |
|--------|-----|-----|
| Texto Oscuro | `#2B2B2B` | Cuerpo principal |
| Texto Gris | `#666666` | Texto secundario |
| Texto Card | `#333333` | Títulos de cards |
| Texto Suave | `#555555` | Párrafos intermedios |

### Fondos Neutros

| Nombre | Hex | Uso |
|--------|-----|-----|
| Blanco | `#ffffff` | Cards, contenido |
| Gris Claro | `#f7f7f7` | Fondos de secciones |
| Gris Ultra Claro | `#fafafa` | Fondos sutiles |

### Tokens CSS (sb-ui equivalentes)

| Token | Valor | Propósito |
|-------|-------|-----------|
| `--sb-ui-color-primary-base` | `#009056` | Verde primario |
| `--sb-ui-color-primary-D200` | `#005727` | Verde oscuro/hover |
| `--sb-ui-color-primary-L300` | `#f4f9f6` | Fondo verde claro |
| `--sb-ui-color-secondary-base` | `#fed100` | Dorado acento |
| `--sb-ui-color-feedback-error-base` | `#dc3545` | Errores |
| `--sb-ui-color-feedback-warning-base` | `#ffc100` | Warnings |
| `--sb-ui-color-feedback-success-base` | `#28a745` | Success |
| `--sb-ui-color-grayscale-D400` | `#282828` | Texto primario |
| `--sb-ui-color-grayscale-D200` | `#5B5B5B` | Texto secundario |
| `--sb-ui-color-grayscale-L200` | `#E1E1E1` | Bordes |
| `--sb-ui-color-grayscale-L400` | `#FAFAFA` | Section backgrounds |

---

## Tailwind Config para Web Apps

```javascript
tailwind.config = {
  theme: {
    extend: {
      colors: {
        brand: {
          dark: '#005727',
          main: '#00823b',
          light: '#00a64d',
          header: '#009056',
          bg: '#f4f9f6',
          border: '#cce6d8'
        },
        accent: {
          main: '#fed100',
          hover: '#f2c700'
        }
      }
    }
  }
};
```

---

## Tipografía

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');
body { font-family: 'Inter', sans-serif; }
```

---

## Patrones de Diseño Obligatorios

### Glass Card (estándar para cards)

```css
.glass-card {
  background: rgba(255,255,255,0.92);
  backdrop-filter: blur(12px);
  border-radius: 1rem;
  border: 1px solid #cce6d8;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
```

### Botón Primario

```html
<button class="bg-brand-main hover:bg-brand-dark text-white font-bold py-3 px-8 rounded-xl transition-all shadow-md active:scale-95">
  Texto →
</button>
```

### Badge/Chip

```html
<div class="inline-flex items-center gap-2 bg-brand-main/10 text-brand-main text-sm font-semibold px-4 py-1.5 rounded-full">
  Texto del badge
</div>
```

### Barra de Progreso

```css
.progress-fill {
  transition: width 0.5s cubic-bezier(0.4,0,0.2,1);
  background: linear-gradient(90deg, #00823b, #00a64d, #fed100);
}
```

---

## Principios de Diseño

1. **Glassmorphism** en cards (fondo semi-transparente + blur)
2. **Bordes redondeados grandes** — mínimo `rounded-xl` (12px), preferir `rounded-2xl` (16px)
3. **Sombras sutiles** — `shadow-sm` para cards, `shadow-2xl` solo CTAs
4. **Animaciones suaves** — `transition-all` con `active:scale-95` en botones
5. **Espaciado generoso** — padding mínimo 24px en contenido
6. **Jerarquía por peso tipográfico** — `font-black` títulos, `font-bold` subtítulos
7. **Dorado solo como acento** — premios, highlights, barras de progreso
8. **Verde oscuro para headers/fondos premium**, verde principal para acciones
9. **Fondo de página**: `bg-gradient-to-br from-gray-50 via-white to-brand-bg`

---

## Prohibiciones

- NO hardcodear colores sin usar la paleta definida
- NO usar frameworks CSS externos (Bootstrap, Material) — solo Tailwind CDN
- NO usar fuentes diferentes a Inter (web apps) o Roboto (emails)
- NO omitir estados de loading/error en componentes con datos asíncronos
- NO usar `overflow: hidden` en containers principales
- NO mezclar estilos inline arbitrarios con Tailwind — elegir uno

---

## Estructura HTML Base (Web App)

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>tailwind.config = { /* brand colors */ };</script>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');
    body { font-family: 'Inter', sans-serif; }
    .glass-card { background: rgba(255,255,255,0.92); backdrop-filter: blur(12px); }
  </style>
</head>
<body class="bg-gradient-to-br from-gray-50 via-white to-brand-bg min-h-screen text-gray-800">
  <div class="max-w-6xl mx-auto p-4 sm:p-6">
    <!-- Contenido -->
  </div>
</body>
</html>
```

---

## Accesibilidad

- Contraste mínimo: 4.5:1 texto normal, 3:1 elementos UI
- `#282828` sobre blanco → AAA ✅
- `#FFFFFF` sobre `#009056` → AA ✅ (headers, botones)
- Todos los elementos interactivos deben tener focus visible
- Imágenes con `alt`, botones con texto descriptivo
