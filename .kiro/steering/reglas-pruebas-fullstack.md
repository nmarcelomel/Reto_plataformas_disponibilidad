---
inclusion: auto
---

# Reglas de Testing Fullstack — Cobertura SonarQube

## Mandato de Coherencia

Por cada cambio en lógica de negocio (Frontend o Backend), se DEBE generar automáticamente el código del test unitario correspondiente.

---

## Frontend (Angular / HTML estático)

### Framework de Testing
- Jasmine + Karma o Jest como alternativa.
- Cada componente/servicio DEBE tener su archivo `.spec.ts`.

### Reglas Obligatorias
- Simular estados de carga, éxito y error en cada componente con datos asíncronos.
- Mockear llamadas HTTP. Nunca hacer llamadas reales en tests.
- Verificar renderizado condicional.
- Testear event handlers.

---

## Backend — Node.js (Express/Fastify)

### Framework de Testing
- Jest + Supertest para tests de integración de APIs.
- Jest para tests unitarios de servicios y utilidades.

### Reglas Obligatorias
- Probar 3 capas: Controladores, Servicios y Repositorios.
- Mockear conexiones a PostgreSQL y APIs externas con `jest.mock()`.
- Cada endpoint debe tener tests para: 200/201, 400, 401, 404 y 500.
- Validar propagación de `Correlation-ID`.
- Testear middleware de autenticación JWT.

### Estructura de Test de Controlador

```javascript
describe('POST /v1/api/recurso', () => {
  // Test: debe retornar 201 con datos válidos
  // Test: debe retornar 400 con datos inválidos
  // Test: debe retornar 401 sin token JWT
  // Test: debe retornar 500 cuando el servicio falla
});
```

---

## Mocks Dinámicos

- PROHIBIDO hacer llamadas reales a BD o APIs externas en tests.
- Mocks deben cubrir: respuesta exitosa, timeout, error de red, datos vacíos.
- Centralizar fixtures en carpetas dedicadas:
  - Frontend: `src/testing/mocks/`
  - Backend Node: `tests/mocks/` o `__mocks__/`

---

## Métricas SonarQube — Quality Gate

| Métrica | Umbral Mínimo |
|---------|---------------|
| Cobertura de líneas | > 80% |
| Code Smells críticos | 0 |
| Code Smells mayores | < 5 |
| Bugs | 0 |
| Vulnerabilidades | 0 |
| Duplicación de código | < 3% |
| Deuda técnica | < 30 min por archivo |

### Reglas para Quality Gate
- No código muerto (funciones, variables o imports sin usar).
- No usar `any` en TypeScript.
- No `console.log` en producción; usar logging centralizado.
- No `catch` vacíos.
- Complejidad ciclomática máxima por función: 10.
- Máximo 300 líneas por archivo fuente.
