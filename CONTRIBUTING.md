# 🤝 Guía de Contribución - Project Jaina Game Modes

¡Gracias por tu interés en contribuir a **Wanos_GameModes**! Este documento establece el flujo de trabajo, las pautas de calidad y los requisitos técnicos para que cualquier aporte sea aceptado en el proyecto oficial de Project Jaina.

---

## 1. Principios de Desarrollo

El selector de modos de juego opera en el cliente WoW 3.3.5a (Build 12340). Todo código debe cumplir:

1. **Lua 5.1 Estricto:** Prohibido el uso de APIs o sintaxis de versiones posteriores (sin `goto`, sin `table.pack`).
2. **Sin APIs de Retail:** No usar `SetColorTexture()`, `C_Timer.After()`, ni ninguna función inexistente en WotLK.
3. **Texturas de Color Sólido:**
   ```lua
   -- ❌ PROHIBIDO en 3.3.5a:
   tex:SetTexture(r, g, b, a)
   -- ✅ OBLIGATORIO en 3.3.5a:
   tex:SetTexture("Interface\\Buttons\\WHITE8X8")
   tex:SetVertexColor(r, g, b, a)
   ```
4. **Temporizadores Seguros:**
   ```lua
   -- ❌ PROHIBIDO en 3.3.5a:
   C_Timer.After(1.0, callback)
   -- ✅ OBLIGATORIO en 3.3.5a: OnUpdate con cancelación explícita al terminar
   frame:SetScript("OnUpdate", function(self, dt)
       elapsed = elapsed + dt
       if elapsed >= delay then
           self:SetScript("OnUpdate", nil) -- Cancelar SIEMPRE
           callback()
       end
   end)
   ```
5. **Límite de 255 Bytes:** Los mensajes `SendAddonMessage` nunca deben exceder 255 bytes.
6. **Pool de Frames:** Las 4 tarjetas de modo se crean una sola vez al primer uso y se reutilizan. No instanciar frames en bucles o en `OnUpdate`.

---

## 2. Flujo de Trabajo en Git

1. **Rama Canónica:** El repositorio utiliza exclusivamente la rama `main`. No crear ni hacer pull requests dirigidos a `master`.
2. **Ramas de Trabajo:**
   - Correcciones de errores: `fix/nombre-del-bug`
   - Nuevas funcionalidades: `feature/nombre-de-la-mejora`
   - Documentación: `docs/nombre-del-cambio`
3. **Mensajes de Commit:** Seguir la convención de Commits Convencionales:
   - `fix: cancelar timer OnUpdate en CreateConfirmDialog`
   - `feat: agregar modo Reto Andino x1 con recompensas al nivel 60`
   - `docs: actualizar guia de integracion para AzerothCore 3.x`
   - `perf: evitar CreateFrame dinamico en cards de modo`

---

## 3. Cómo Agregar o Modificar un Modo de Juego

**El único archivo que debe editarse para gestionar modos es [Config.lua](Config.lua).** No es necesario tocar `Core.lua` ni `UI.lua` para operaciones normales de configuración de modos.

```lua
-- En Config.lua, añadir una nueva entrada en M.Config.Modes:
{
    id = "MI_MODO",                         -- ID único, mayúsculas, sin espacios
    enabled = true,                         -- false para ocultarlo sin borrarlo
    title = "Nombre del Modo",
    badge = "Texto del Badge",
    badgeColor = {0.5, 0.8, 1.0},          -- Color RGB del badge
    accentColor = {0.4, 0.7, 0.9},         -- Color de acento de la tarjeta
    icon = "Interface\\Icons\\SPELL_...",   -- Icono de 3.3.5a DBC
    tagline = "Frase corta del modo",
    description = "Descripción completa...",
    perks = {
        "Beneficio 1",
        "Beneficio 2",
    },
    command = ".mi_comando",                -- Comando de servidor (vacío si no aplica)
    addonPayload = "SET_MODE:MI_MODO",      -- Payload para el script Eluna
    requireConfirmation = false,            -- true para modos de riesgo extremo
},
```

---

## 4. Checklist Obligatorio Antes de Enviar un Pull Request

- [ ] **Balance de Sintaxis Lua:** Verificar que el depth de bloques es 0 en todos los archivos `.lua`.
- [ ] **Prueba in-game:** Hacer `/reload` sin errores Lua en consola de error.
- [ ] **Prueba de Primer Login:** Entrar con personaje Nivel 1 y verificar que el selector aparece automáticamente.
- [ ] **Prueba de Modo Hardcore:** Verificar que el modal de doble confirmación bloquea correctamente los clicks de fondo.
- [ ] **Prueba de ACK:** Verificar que el servidor envía `ACK:<modo>` y el cliente sella la UI correctamente.
- [ ] **Prueba de OnUpdate:** Verificar en `/framestack` que no hay frames con `OnUpdate` activo después de cerrar la UI.

---

## 5. Reporte de Vulnerabilidades

Si descubres una vulnerabilidad que permita evadir la selección de modo, duplicar ACKs, o manipular el flag `hasSelectedMode` de forma maliciosa, **NO abras un issue público**. Consulta las instrucciones en [SECURITY.md](SECURITY.md).
