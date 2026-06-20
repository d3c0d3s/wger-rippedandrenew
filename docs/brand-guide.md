# Ripped & Renew — Brand Guide
**Versión:** 1.0 — 2026-06-19  
**Estado:** Aprobado

---

## 1. Nombre y abreviatura

| Forma | Uso |
|---|---|
| **Ripped & Renew** | Nombre completo — textos largos, documentos, comunicaciones |
| **RIPPED & RENEW** | Wordmark — logo, headings, UI |
| **RNR** | Badge compacto — app icon, favicon, espacios reducidos |

---

## 2. Concepto de marca

La dualidad es el núcleo de la identidad: **RIPPED** representa intensidad, entrenamiento y rendimiento. **RENEW** representa recuperación, nutrición y bienestar. Esta dualidad se expresa visualmente en toda la UI mediante la separación `RIPPED | RENEW`.

**Tagline:** Train hard. Recover smarter.

---

## 3. Paleta de colores

| Nombre | Hex | Uso |
|---|---|---|
| Deep Charcoal | `#1A1A1A` | Fondo principal, dark theme |
| Electric Lime | `#CCFF00` | Acento principal, CTAs, estados activos, iconos, progress rings |
| Soft Slate | `#E0E0E0` | Fondos secundarios, texto sutil, separadores |
| Pure White | `#FFFFFF` | Texto principal, headings sobre fondo oscuro |
| Alert Orange | `#FF6B00` | Fatiga alta, errores, advertencias — nunca decorativo |

### Reglas de uso
- El fondo predeterminado de toda la UI es `#1A1A1A`
- `#CCFF00` nunca se usa como fondo de texto largo — solo en elementos de acento
- `#FF6B00` se reserva exclusivamente para estados negativos o de alerta
- No usar colores fuera de esta paleta sin justificación documentada

---

## 4. Logo

### Wordmark
- Tipografía: bold geométrica sans-serif (Barlow Bold / Bebas Neue / Rajdhani Bold)
- "RIPPED" y "& RENEW" en el mismo tamaño y peso — ninguna palabra domina sobre la otra
- Flecha `↗` en `#CCFF00` integrada al wordmark como elemento de acento
- Tagline debajo en peso light: *Train hard. Recover smarter.*

### Badge RNR
- Forma circular
- Fondo `#1A1A1A`
- Borde `#CCFF00`
- Texto "RNR" en `#CCFF00`
- Uso: app icon, favicon, watermark, espacios < 48px

### Usos correctos
- Logo sobre fondo oscuro `#1A1A1A` → wordmark en `#FFFFFF` con flecha `#CCFF00`
- Logo sobre fondo claro `#FFFFFF` o `#E0E0E0` → wordmark en `#1A1A1A` con flecha `#CCFF00`

### Usos incorrectos
- No rotar ni distorsionar el logo
- No cambiar el color de la flecha
- No usar el wordmark sin la flecha
- No colocar el logo sobre fondos de color que no sean `#1A1A1A`, `#FFFFFF` o `#E0E0E0`

---

## 5. Tipografía

| Rol | Fuente | Peso | Uso |
|---|---|---|---|
| Headings | Barlow / Rajdhani | Bold (700) | Títulos, hero, métricas grandes |
| Body | Barlow / Inter | Regular (400) | Texto corrido, descripciones |
| Tagline / Caption | Barlow / Inter | Light (300) | Tagline, labels, metadata |

> Si las fuentes propietarias no están disponibles, usar **system-ui** como fallback.

---

## 6. UI — Dashboard RIPPED | RENEW

El dashboard es la pantalla principal de la app. Su estructura refleja la dualidad de marca:

```
┌─────────────────────────────────────────────┐
│         RIPPED  |  RENEW                    │
│         blanco  lime  lime                  │
├──────────────────┬──────────────────────────┤
│  RIPPED          │  RENEW                   │
│  (intensidad)    │  (recuperación)          │
│                  │                          │
│  FATIGA: BAJA    │  FATIGA: ALTA            │
│  valor: #CCFF00  │  card bg: #FF6B00        │
│                  │                          │
│  Entrenamientos  │  kcal Quemadas           │
│  Minutos Total   │  Score Recuperación      │
├──────────────────┴──────────────────────────┤
│     ◯ 75% Progreso semanal  (#CCFF00)       │
└─────────────────────────────────────────────┘
```

### Cards
- Fondo: `#1A1A1A`
- Border-radius: 10px
- Valores principales: `#CCFF00` (estados positivos) o `#FFFFFF`
- Estado alerta: card completa en `#FF6B00`, texto en `#FFFFFF`
- Iconos: line-style en `#CCFF00` o `#FFFFFF`

### Progress ring
- Color activo: `#CCFF00`
- Color de fondo del ring: `#2A2A2A`
- Valor central en `#FFFFFF`, label en `#E0E0E0`

---

## 7. UI — Hero (Landing page)

- Fondo: foto fitness con overlay oscuro `rgba(26,26,26,0.75)`
- Headline: `#FFFFFF`, bold, uppercase
- Subheadline opcional: `#E0E0E0`
- CTA principal: fondo `#CCFF00`, texto `#1A1A1A`, bold
- CTA secundario: borde `#CCFF00`, texto `#CCFF00`, fondo transparente
- Navegación: fondo `#1A1A1A`, links en `#FFFFFF`, activo en `#CCFF00`

---

## 8. Tono de voz

- **Directo y motivador** — sin rodeos, orientado a la acción
- **Bilingüe** — español como idioma principal de la UI, inglés en elementos de marca (tagline, badge)
- **Inclusivo** — aplica a cualquier audiencia y nivel de experiencia
- **Sin jerga técnica** — fitness accesible, no intimidante

### Ejemplos
| ❌ Evitar | ✅ Usar |
|---|---|
| "Optimiza tu periodización" | "Planifica tu semana de entrenamiento" |
| "Maximiza tu hipertrofia" | "Gana músculo de forma consistente" |
| "Track your macros" | "Registra tu nutrición" |

---

## 9. Navegación principal

| Sección | Concepto |
|---|---|
| Inicio | Dashboard RIPPED\|RENEW |
| Programas | Rutinas y planes de entrenamiento |
| Renovación | Recuperación, nutrición, bienestar |
| Comunidad | Social, challenges, rankings |

---

## 10. Aplicación por plataforma

| Plataforma | Notas |
|---|---|
| Web (wger/Django) | Dark theme por defecto, templates en `rnr_core` |
| App iOS/Flutter | Dark theme, mismo sistema de colores vía `ThemeData` |
| App Android/Flutter | Igual que iOS |
| Email transaccional | Fondo `#1A1A1A`, acento `#CCFF00`, fuente sistema |

---

## Assets pendientes de generar en Gemini

- [ ] Logo vectorial SVG (wordmark completo)
- [ ] Badge RNR SVG (app icon base)
- [ ] Iconografía line-style: entrenamiento, nutrición, recuperación, comunidad, progreso
- [ ] Foto hero principal (atleta, gym, dark mood)
- [ ] Fotos secundarias por sección (Programas, Renovación, Comunidad)
