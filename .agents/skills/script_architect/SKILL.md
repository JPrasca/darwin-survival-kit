---
name: script_architect
description: Habilidad para diseñar scripts de Bash seguros, documentados y estandarizados para macOS.
---
# Script Architect Skill

Cuando esta habilidad está activa, el agente debe seguir estas reglas al crear o modificar scripts en este workspace:

## 1. Estándares de Seguridad
- Todos los scripts de Bash deben comenzar con `set -euo pipefail`.
- Si el script realiza acciones destructivas (borrar archivos, desinstalar apps), debe incluir una función de confirmación `confirm_action`.
- Usar siempre variables entre comillas (ej. `"$VARIABLE"`) para evitar problemas con rutas que tengan espacios.

## 2. Documentación y Estructura
- **Encabezado obligatorio**: Nombre del script, descripción, autor y requisitos.
- **Colores**: Definir variables de color (`RED`, `GREEN`, `RESET`) para mensajes de salida legibles.
- **Funciones**: Organizar el código en funciones (ej. `main`, `check_deps`, `cleanup`).

## 3. Entorno macOS
- Priorizar el uso de `brew` para instalaciones.
- Usar rutas absolutas o relativas al workspace de forma segura.

## 4. Ejemplo de Estructura de Salida
Cada vez que el usuario pida un script, debe seguir este formato:
```bash
#!/bin/bash
# Descripcion: [Lo que hace]
# Requisitos: [Dependencias]

set -euo pipefail

# ... resto del código ...
```

## 5. Formato de comentarios
- El formato de comentarios de cabecera no debe tener el campo 'escrito por'.

## 6. Formalizar la vista de scripts
- Usar emojis sólo en casos necesarios y que no sean excesivos en el código cuando se trate de scripts de bash u otro lenguaje de programación.

## 7. Manejo robusto de colores (TTY Detection)
- Los colores deben definirse de forma condicional, verificando si la salida es una terminal interactiva ([ -t 1 ]). Si no lo es, las variables de color deben ser cadenas vacías.

## 8. Estándares de Git
- **Estrategia**: Usar `main` para código estable y ramas descriptivas (`feat/`, `fix/`, `refactor/`) para cambios.
- **Mensajes de Commit (Conventional Commits)**:
  - `feat`: Nueva funcionalidad o script.
  - `fix`: Corrección de errores.
  - `refactor`: Cambios de estructura o código sin alterar la lógica.
  - `docs`: Solo cambios en documentación.
  - `style`: Formateo, colores, eliminación de emojis.
  - `chore`: Mantenimiento general.
- **Formato**: `<tipo>(<ámbito>): <descripción corta en minúsculas>`

## 9. Estándares de Interfaz y Lenguaje (Neutralidad Técnica)
- **Tono**: Evitar el uso de personas gramaticales (tú, usted, yo). Las interacciones deben ser impersonales y enfocadas en la acción.
- **Mensajes de Estado**: Utilizar el gerundio para procesos activos (ej. "Escaneando...", "Analizando...").
- **Confirmaciones**: Las preguntas deben ser directas y técnicas (ej. "¿Confirmar eliminación?", "¿Proceder con la ejecución?").
- **Resultados**: Usar frases afirmativas de misión cumplida (ej. "Limpieza finalizada", "Proceso completado").
- **Estética**: Evitar emojis en las salidas de consola. Usar encabezados en MAYÚSCULAS y divisores limpios (`---` o `===`) para separar secciones.
