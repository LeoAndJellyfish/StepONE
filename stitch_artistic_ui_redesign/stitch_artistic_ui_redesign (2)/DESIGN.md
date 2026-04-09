# Design System Document

## 1. Overview & Creative North Star: "The Ethereal Canvas"

This design system is anchored in the **"Ethereal Canvas"**—a philosophy that treats the digital interface not as a rigid software grid, but as a series of translucent layers suspended over a living, painterly landscape. We are moving away from the "app-in-a-box" look toward a cinematic editorial experience.

By blending the organic unpredictability of digital watercolor with the precision of modern glassmorphism, we create a UI that breathes. We break the standard template through **intentional asymmetry**: content is often offset to allow the background landscape to "speak," and we utilize massive typographic shifts to establish a clear, authoritative, yet calm hierarchy.

---

## 2. Colors: Tonal Depth & The Watercolor Palette

The palette is derived from the interplay between the deep `#111827` (Foundational Ink) and the ethereal `#FFFFFF` (Pure Light). We utilize Material Design token logic to manage depth without ever resorting to harsh dividers.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are strictly prohibited for sectioning. Structural boundaries must be defined solely through background color shifts. For example, a `surface-container-low` section sitting on a `surface` background provides all the separation necessary. We define space through "islands of content," not "cells of data."

### Surface Hierarchy & Nesting
Treat the UI as physical layers of frosted glass.
*   **Base Layer:** The painterly landscape background.
*   **Surface / Surface-Low:** The primary content area, often using glassmorphism.
*   **Surface-Container-Highest:** Reserved for interactive elements or elevated cards that need to "pop" against the glass background.

### The "Glass & Gradient" Rule
To achieve the "premium" mood, all primary foreground containers must utilize **Glassmorphism**:
*   **Background:** Use `surface_container_lowest` at 60%–80% opacity.
*   **Blur:** Apply a `backdrop-blur` of 12px to 20px.
*   **Signature Gradient:** For primary CTAs, use a subtle linear gradient from `primary` (#000000) to `primary_container` (#141B2B) at a 135-degree angle to provide a "velvet" texture.

---

## 3. Typography: The Editorial Voice

We use a dual-font strategy to balance the artistic aesthetic with modern readability.

*   **Display & Headlines (Manrope):** These are our "Artistic Anchors." Use `display-lg` (3.5rem) with wide letter-spacing to create a cinematic feel. Manrope’s geometric clarity provides the "trustworthy" foundation.
*   **Body & Labels (Inter/Noto Sans SC):** These provide the "Functional Precision." We utilize light weights (300-400) to maintain the "Modern Minimalist" aesthetic. 

**Hierarchy Note:** Always prioritize extreme contrast in scale. A `display-md` headline paired with a `body-sm` caption creates an editorial, high-end magazine feel that standard "balanced" scales cannot reach.

---

## 4. Elevation & Depth: Tonal Layering

Traditional drop shadows are too "heavy" for a watercolor aesthetic. We use **Tonal Layering** to convey lift.

*   **The Layering Principle:** Place a `surface_container_lowest` (#FFFFFF) card on a `surface_container_low` (#EEF4FF) background. The subtle shift in hex value creates a soft, natural lift.
*   **Ambient Shadows:** If a floating effect is required (e.g., a modal or floating action button), use an extra-diffused shadow: `box-shadow: 0 12px 40px rgba(21, 28, 37, 0.06);`. The shadow color is a tint of our `on_surface` color, making it feel like ambient light, not a dark smudge.
*   **The "Ghost Border" Fallback:** If a container sits on a background of the same color, use a "Ghost Border": `outline_variant` (#C6C6CD) at **15% opacity**. It should be felt, not seen.

---

## 5. Components: The Softened Interface

### Buttons
*   **Primary:** Solid `primary` background with `on_primary` text. Corners: `xl` (1.5rem).
*   **Secondary (Glass):** Semi-transparent `surface_container_highest` with a backdrop blur. This allows the button to feel integrated into the background landscape.
*   **Interaction:** On hover, increase opacity by 10% and shift the Y-axis by -1px.

### Input Fields
Forgo the traditional "box." Use a `surface_container_low` background with a `sm` (0.25rem) bottom-only radius, creating a sophisticated "underlined" feel that is still a contained shape. Labels should use `label-md` and be placed 8px above the field.

### Cards & Lists
*   **Constraint:** Zero dividers. 
*   **Separation:** Use `spacing-lg` (1.5rem to 2rem) of vertical white space to separate list items. 
*   **Visual Grouping:** Group related items inside a single glassmorphism container (`rounded-xl`) rather than individual boxes.

### Signature Component: The "Atmospheric Hero"
A wide, cinematic header component where the `display-lg` typography is partially overlapped by a `surface_container_lowest` glass card. This "overlapping" breaks the grid and creates a custom, high-end feel.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** embrace negative space. If a layout feels "full," remove an element.
*   **Do** use asymmetrical layouts (e.g., text on the left 40%, image/landscape on the right 60%).
*   **Do** ensure text contrast ratios meet WCAG AA standards, especially when using glassmorphism over watercolor backgrounds. Use a dark overlay on the background if necessary.

### Don't:
*   **Don't** use pure black (#000000) for body text; use `on_surface_variant` (#45464C) for a softer, more premium look.
*   **Don't** use 90-degree sharp corners. Everything must feel "honed" and organic (minimum `DEFAULT` 0.5rem radius).
*   **Don't** use standard "Blue" for links. Use an underlined `primary` (#000000) or a subtle shift to `secondary` to maintain the minimalist palette.