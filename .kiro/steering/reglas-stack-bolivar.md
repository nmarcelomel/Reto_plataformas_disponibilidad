---
inclusion: auto
---

# 🛠️ Stack Tecnológico de Autogestión (v3.3)

## 🏗️ Perfil Standard

| Capa | Tecnología | Versión |
| :--- | :--- | :--- |
| **Frontend** | Angular / HTML+Tailwind | 17+ (LTS) o estático |
| **Backend** | Node.js | 20.x (LTS) |
| **Framework Backend** | Express.js | 4.x |
| **Build Tool** | npm | 10.x |
| **Persistencia** | PostgreSQL | 15.4+ |

## Frontend - Frameworks y Librerías

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| Angular CLI | 17+ (LTS) | Apps Web corporativas |
| React + Vite | 18.x / 5.x | Interfaces dinámicas |
| TypeScript | 5.x | Tipado estricto |
| Tailwind CSS | 3.x | Estilizado rápido |
| Shadcn UI / Radix UI | Latest | Componentes accesibles |
| Lucide React | Latest | Iconos modernos |
| Recharts | 2.x | Gráficos |

## Backend - Node.js

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| Node.js | 20.x (LTS) | Runtime JS |
| Express.js | 4.x | Framework web |
| Fastify | 4.x | Alto rendimiento |
| pg (node-postgres) | 8.x | Cliente PostgreSQL |
| Jest | 30.x | Testing |
| Supertest | 7.x | Testing de APIs |
| Helmet | 8.x | Security headers |
| CORS | 2.x | Cross-Origin |
| JWT (jsonwebtoken) | 9.x | Autenticación |
| bcrypt | 6.x | Hashing |

## Backend - Java

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| Java JDK | 21 (LTS) | Empresarial |
| Spring Boot | 3.x | Framework |
| Gradle | 8.x | Build tool |
| JUnit | 5.x | Testing |

## Backend - Python

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| Python | 3.12+ | Alto nivel |
| FastAPI | 0.115+ | APIs modernas |
| SQLAlchemy | 2.0+ | ORM |
| pytest | 8.0+ | Testing |

## Infraestructura

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| Docker | 24.x+ | Contenedorización |
| Docker Compose | Latest | Orquestación |
| AWS ECS Fargate | Latest | Contenedores sin servidor |
| AWS S3 | Latest | Almacenamiento |
| AWS CloudFront | Latest | CDN |
| AWS Parameter Store | Latest | Secretos y config |

## Reglas de Conectividad

- n8n: Webhook como único punto de entrada para Frontend
- n8n: Prohibido nodos de conexión directa a BD
- Google Apps Script: Sincronización obligatoria con Git
- Google Apps Script: Prohibido usar Sheets como BD

## IAM Estándar

| Componente | Estándar |
| :--- | :--- |
| Protocolo | OAuth 2.0 / OIDC |
| Tokens | JWT |
| Almacenamiento | httpOnly cookies |
| Validación | Firma y Scopes en Backend |
