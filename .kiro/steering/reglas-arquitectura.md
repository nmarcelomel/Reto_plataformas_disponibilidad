---
inclusion: auto
---

# 📐 Reglas de Arquitectura para Proyectos de Autogestión (v2.1)

## 🎯 Regla Principal: Consistencia

**"Un proyecto debe parecer escrito por una sola persona"**

* **Validación Obligatoria:** Antes de modificar código, identifica el patrón estándar existente y replícalo.
* **Uniformidad:** Se prohíbe el *vibe coding* (programar por intuición del momento). No inventar nuevas formas.
* **Mantenibilidad:** El código debe ser lo suficientemente claro para permitir correcciones en menos de **1 día** en casos críticos y **5 días** para temas no productivos.

---

## 🏗️ Estándar de Solución: 3 Capas y Usabilidad

1. **Capa de Presentación (Frontend):** Responsable del renderizado de UI y eventos de usuario. **NUNCA** debe contener lógica de negocio.
2. **Capa de Lógica (Backend):** Intermediario obligatorio donde residen las reglas de dominio, cálculos y validaciones de seguridad.
3. **Capa de Persistencia (Datos):** Repositorios oficiales (Postgres, Mongo, Data Lake). Se prohíbe la conexión directa desde el Front; siempre vía API.

**💡 Regla de Usabilidad:**
* Toda funcionalidad principal debe ser intuitiva y ejecutable en un máximo de **5 clics** sin requerir manuales de usuario.

---

## 🛡️ Seguridad y Protección de Datos

* **Identidad y Acceso (IAM):** OAuth 2.0 y OIDC obligatorio. JWT firmados por IdP institucional.
* **Sanitización y Tipado:** Definición estricta de tipos de datos en todos los campos para evitar inyecciones.
* **Enmascaramiento:** 100% de datos sensibles (PII, financiero, salud) enmascarados en respuestas API.
* **Comunicación DNS (No IPs):** Prohibido el uso de direcciones IP fijas.
* **Gestión de Secretos:** No incluir API keys o credenciales en código fuente. Uso obligatorio de Variables de Entorno o Secret Manager.
* **Seguridad Web:** Tokens NO en `localStorage`; usar `httpOnly cookies`.
* **Retención de Datos:** Políticas de borrado máximo **90 días**.

---

## ⚙️ Resiliencia, Desempeño y Operación

* **Métricas de Desempeño:** Frontend < **3 segundos**, Backend APIs < **15 segundos**.
* **Trazabilidad:** `Correlation-ID` obligatorio en cada petición entre capas.
* **Observabilidad:** Logs estandarizados enviados a servicios centrales, nunca almacenados localmente.
* **Manejo de Fallos:** Retries y Circuit Breakers obligatorios.
* **Asincronía:** Tareas de larga duración en segundo plano.
* **Throttling:** Rate Limiting para proteger componentes core.
* **Versionamiento de Contratos (API First):** Prefijos en rutas (`/v1/api/`, `/v2/api/`).

---

## 🏷️ Estándares de Desarrollo

### Naming Conventions

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Componentes | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase con `use` | `useUserData.ts` |
| Servicios | camelCase | `userService.ts` |
| Constantes | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Variables/Funciones | camelCase | `userName`, `fetchUser()` |
| Event Handlers | `handle` prefix | `handleClick`, `handleSubmit` |

### Estructura Modular

```text
src/
├── assets/             # Estilos globales e imágenes
├── components/         # Componentes transversales (ui/layout)
├── features/           # Lógica por dominio de negocio
│   └── modulo-ejemplo/ 
│       ├── components/ # UI específica del módulo
│       ├── hooks/      # Lógica de estado local
│       ├── services/   # Llamadas a API del módulo
│       └── index.ts    # Punto de exposición
├── services/           # Clientes globales
├── hooks/              # Hooks globales reutilizables
├── types/              # Interfaces y tipos de TypeScript
└── config/             # Variables de entorno y constantes
```

---

## 🚀 Ciclo de Vida y Gobierno de TI

* **Fuentes Oficiales:** Toda librería desde repositorio institucional (Jfrog).
* **Versionamiento:** Código en repositorio oficial.
* **Separación de Entornos:** Dev, Stage y Prod físicamente separados.
* **Cierre Limpio (Graceful Shutdown):** Completar transacciones antes de reiniciar.
