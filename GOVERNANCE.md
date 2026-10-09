# 🏛️ Modelo de Gobernanza del Proyecto - Project Jaina Game Modes

**Versión del Documento:** 1.0.0  
**Fecha de Entrada en Vigor:** 27 de Septiembre de 2026  
**Líder del Proyecto / Autor:** DarckRovert (Ingame: Elnazzareno)  
**Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) - Project Jaina  
**Entorno de Ejecución:** World of Warcraft 3.3.5a (Build 12340) | Eluna Lua Engine (TrinityCore / AzerothCore)  

---

## 1. Misión y Alcance

**ProjectJaina_GameModes** es el selector cinematográfico nativo de modos de juego del servidor Project Jaina. Se activa en el primer inicio de sesión de cualquier personaje nuevo (Nivel 1, 0 XP) y ofrece una elección de destino irreversible entre 4 caminos:

- **Aventurero (Normal):** Experiencia Blizzlike clásica sin restricciones.
- **Hardcore (1 Vida):** Muerte permanente, títulos y monturas exclusivas al Nivel 80.
- **Ironman:** Autosuficiencia total, sin comercio ni subastas.
- **Reto Andino x1:** Progresión pausada tipo Vanilla pura.

### Objetivos Primordiales del Sistema:
1. **UX Cinematográfica Inmersiva:** La pantalla de selección debe oscurecer el mundo y centrar la atención del jugador en la decisión más importante de su carrera.
2. **Seguridad Anti-Missclick:** Todos los modos de riesgo extremo (Hardcore, Ironman) exigen una doble confirmación modal e irreversible con advertencia explícita.
3. **Rendimiento en Cabinas de Internet:** Funcionamiento estable a 60 FPS en resoluciones de $800\times600$ con CPUs dual-core e Intel HD.
4. **Compatibilidad Multi-Servidor:** Despacho de comandos compatible de fábrica con TrinityCore, AzerothCore y scripting C++/Eluna mediante el prefijo `WP_GAMEMODE`.

---

## 2. Estructura de Roles y Responsabilidades

El proyecto se rige bajo un modelo de **Liderazgo Técnico Centralizado**:

```
       ┌─────────────────────────────────────────┐
       │   Líder del Proyecto (Project Lead)     │
       │     DarckRovert (Elnazzareno)            │
       └────────────────────┬────────────────────┘
                            │
       ┌────────────────────▼────────────────────┐
       │      Equipo de Desarrollo y Staff       │
       │   (Core Eluna, Addon Lua, Webmaster)    │
       └────────────────────┬────────────────────┘
                            │
       ┌────────────────────▼────────────────────┐
       │     Game Masters y Soporte In-Game      │
       │     (Atención a Jugadores, Eventos)     │
       └─────────────────────────────────────────┘
```

### 2.1. Project Lead (Líder del Proyecto)
- **Titular:** DarckRovert (Elnazzareno).
- **Atribuciones:**
  - Control de la visión de UX, modos disponibles y balance de recompensas por modo.
  - Aprobación y fusión final de código en la rama `main` del repositorio oficial.
  - Firma de versiones oficiales (`v1.0.0`, `v2.0.0`, etc.).
  - Veto técnico sobre cualquier cambio que comprometa la estabilidad del cliente o el diseño de la experiencia de usuario.

### 2.2. Desarrolladores y Mantenedores
- **Responsabilidades:**
  - Mantenimiento de [Core.lua](Core.lua), [UI.lua](UI.lua) y [Config.lua](Config.lua).
  - Verificación estricta de compatibilidad de APIs con WotLK 3.3.5a (sin `SetColorTexture`, sin `C_Timer.After`).
  - Integración del script de servidor Eluna (`71_GameModesSystem.lua`) con la tabla `character_gamemodes`.
  - Asegurar la integridad de sintaxis Lua (balance de bloques sin fugas).

### 2.3. Game Masters (Staff de Soporte)
- Ajuste de modos disponibles en [Config.lua](Config.lua) habilitando o deshabilitando `enabled = true/false`.
- Uso del comando `/wpmodes reset` (solo con `Config.Debug = true`) para resetear estados en pruebas.

---

## 3. Principios Técnicos Inviolables (Leyes de Arquitectura)

### 3.1. Cero Suposiciones (Empirismo Estricto)
Antes de proponer o aplicar un cambio, es **obligatorio** verificar el código fuente exacto. Prohibido asumir APIs de versiones posteriores a 3.3.5a.

### 3.2. Restricciones del Cliente 3.3.5a (Build 12340)
- **Texturas sólidas:** Usar siempre `SetTexture("Interface\\Buttons\\WHITE8X8")` + `SetVertexColor(r, g, b, a)`.
- **Temporizadores:** No existe `C_Timer.After`. Usar `OnUpdate` con variable acumuladora de `elapsed` y cancelación explícita (`SetScript("OnUpdate", nil)`) cuando el timer finaliza.
- **Registro de prefijos:** `RegisterAddonMessagePrefix` no existe en 3.3.5a nativo. No incluirlo.

### 3.3. Protocolo de Red y Seguridad de Paquetes
- **Prefijo oficial:** `WP_GAMEMODE` (no modificar salvo actualización mayor del protocolo).
- **Límite estricto:** Ningún payload puede exceder los 255 bytes por paquete de `SendAddonMessage`.
- **Despacho dinámico:** El addon intenta `GUILD` → `RAID` → `PARTY` → `SAY` en ese orden de prioridad para personajes sin grupo.

### 3.4. Inmutabilidad de la Decisión
- Una vez que el personaje selecciona un modo, el flag `ProjectJaina_GameModes_CharDB.hasSelectedMode = true` se fija localmente.
- El servidor confirma mediante paquete `ACK:<modo>`. Solo el servidor puede revocar o cambiar un modo en condiciones especiales.

### 3.5. Seguridad de Base de Datos y Eluna
- La tabla `character_gamemodes` debe suscribirse a `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2 de Eluna) para purgar filas huérfanas al borrar personajes y evitar colisiones de LowGUIDs reciclados.

---

## 4. Gestión de Cambios y Versionado

El proyecto utiliza **Versionado Semántico (SemVer)** adaptado al ciclo del servidor:

- **MAJOR (`vX.0.0`):** Adición o eliminación de modos de juego, reestructuración de esquemas MySQL o cambios incompatibles de protocolo `WP_GAMEMODE`.
- **MINOR (`vx.Y.0`):** Nuevos perks o recompensas por modo, nuevas integraciones Eluna o mejoras visuales conservando compatibilidad.
- **PATCH (`vx.y.Z`):** Corrección de bugs, optimización de frames, ajustes de textos o traducciones.

### Política de Ramas en Git
- **`main`:** Rama única y canónica de producción.
- Queda prohibida la coexistencia de ramas duplicadas como `master`.

---

## 5. Procedimiento de Lanzamiento Oficial (Release Checklist)

Antes de generar un nuevo release o actualizar el parche MPQ:
1. [ ] Verificar balance de bloques Lua en `Core.lua` y `UI.lua` (depth = 0).
2. [ ] Confirmar que todos los `OnUpdate` instalados se cancelan con `SetScript("OnUpdate", nil)` al finalizar.
3. [ ] Probar in-game en personaje Nivel 1 con `/reload` sin errores Lua en consola.
4. [ ] Verificar que `ACK:` del servidor es recibido y el flag `hasSelectedMode` queda en `true`.
5. [ ] Generar el paquete ZIP `ProjectJaina_GameModes_vX.Y.Z.zip`.
6. [ ] Publicar en la sección de Releases de GitHub y notificar al Sysadmin para actualizar el MPQ.
