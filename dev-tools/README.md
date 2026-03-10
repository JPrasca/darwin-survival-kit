# 💻 Módulo: Dev-Tools

Guía de uso para las herramientas de desarrollo y monitoreo del flujo de trabajo.

---

## 🛠️ Herramientas Disponibles

### 1. `scan-sql.sh`
Escáner de prevención para detectar sentencias SQL peligrosas en subdirectorios de proyectos.

**Uso:**
```bash
./dev-tools/scan-sql.sh [ruta_directorio]
```
**Ejemplo:**
```bash
./dev-tools/scan-sql.sh ./proyect/sql_migrations
```
**Alertas Detectadas:**
- `DROP TABLE | DATABASE`
- `DELETE FROM` (análisis básico de cláusula WHERE omitida)
- `TRUNCATE TABLE`
- `UPDATE TABLE` (análisis básico de seguridad)

---

### 2. `check-antigravity-quota.sh`
Monitor de consumo para la API de Gemini (Antigravity). Permite ver el uso actual y la cuota restante de la clave API configurada.

**Uso:**
```bash
./dev-tools/check-antigravity-quota.sh
```
**Nota:** El script solicita el ingreso de la clave API de Gemini si no se encuentra configurada previamente en las variables de entorno.

---

> [!TIP]
> Estas herramientas son útiles para fases de pre-commit o auditoría de proyectos locales antes de la integración continua.
