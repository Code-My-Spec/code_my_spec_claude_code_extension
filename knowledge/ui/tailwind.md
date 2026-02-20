# Tailwind CSS 4

## Sources
- https://tailwindcss.com/docs/installation/using-postcss
- https://tailwindcss.com/docs/responsive-design
- https://tailwindcss.com/docs/flex

---

## Setup (Tailwind 4 — CSS-first)

```css
@import "tailwindcss";
```

Configuration via CSS `@theme` directive (replaces `tailwind.config.js`):

```css
@import "tailwindcss";

@theme {
  --color-brand: oklch(55% 0.3 240);
  --breakpoint-3xl: 120rem;
}
```

---

## Responsive Breakpoints

Mobile-first: unprefixed = all sizes, prefix = that size and up.

| Prefix | Min width          | CSS                            |
|--------|--------------------|--------------------------------|
| `sm`   | 40rem (640px)      | `@media (width >= 40rem)`      |
| `md`   | 48rem (768px)      | `@media (width >= 48rem)`      |
| `lg`   | 64rem (1024px)     | `@media (width >= 64rem)`      |
| `xl`   | 80rem (1280px)     | `@media (width >= 80rem)`      |
| `2xl`  | 96rem (1536px)     | `@media (width >= 96rem)`      |

```heex
<%!-- Stacked on mobile, side-by-side on md+ --%>
<div class="flex flex-col md:flex-row gap-4">

<%!-- 1 col mobile, 2 on md, 3 on lg --%>
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
```

Max-width variants: `max-sm:`, `max-md:`, `max-lg:`, `max-xl:`, `max-2xl:`

```heex
<div class="md:max-lg:flex">Only flex at md breakpoint</div>
```

---

## Flexbox

### Container

```heex
<div class="flex">           <%!-- flex row (default) --%>
<div class="flex flex-col">   <%!-- flex column --%>
<div class="flex flex-wrap">  <%!-- allow wrapping --%>
<div class="inline-flex">     <%!-- inline flex --%>
```

### Item sizing

| Class          | CSS                   | Behavior                        |
|----------------|-----------------------|---------------------------------|
| `flex-1`       | `flex: 1`             | Grow & shrink, ignore initial   |
| `flex-auto`    | `flex: auto`          | Grow & shrink, respect initial  |
| `flex-initial` | `flex: 0 auto`        | Shrink only, no grow            |
| `flex-none`    | `flex: none`          | No grow, no shrink              |

### Alignment

| Class              | CSS                          |
|--------------------|------------------------------|
| `items-start`      | `align-items: flex-start`    |
| `items-center`     | `align-items: center`        |
| `items-end`        | `align-items: flex-end`      |
| `items-baseline`   | `align-items: baseline`      |
| `items-stretch`    | `align-items: stretch`       |
| `justify-start`    | `justify-content: flex-start`|
| `justify-center`   | `justify-content: center`    |
| `justify-end`      | `justify-content: flex-end`  |
| `justify-between`  | `justify-content: space-between` |
| `justify-around`   | `justify-content: space-around`  |
| `justify-evenly`   | `justify-content: space-evenly`  |

---

## Grid

```heex
<%!-- Basic grid --%>
<div class="grid grid-cols-3 gap-4">
  <div>1</div><div>2</div><div>3</div>
</div>

<%!-- Responsive grid --%>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

<%!-- Spanning columns --%>
<div class="col-span-2">Takes 2 columns</div>
<div class="col-span-full">Full width row</div>

<%!-- Rows --%>
<div class="grid grid-rows-3 grid-flow-col gap-4">
```

| Class                 | Effect                      |
|-----------------------|-----------------------------|
| `grid-cols-{1-12}`   | Column count                |
| `grid-cols-none`     | No grid                     |
| `col-span-{1-12}`   | Span N columns              |
| `col-span-full`     | Span all columns            |
| `col-start-{n}`     | Start at column N           |
| `grid-rows-{1-12}`  | Row count                   |
| `row-span-{1-12}`   | Span N rows                 |
| `grid-flow-col`      | Flow columns first          |

---

## Spacing

### Gap

```heex
<div class="flex gap-4">         <%!-- all directions --%>
<div class="grid gap-x-4 gap-y-2"> <%!-- separate axes --%>
```

### Padding & Margin

| Pattern   | Example         | Effect                |
|-----------|-----------------|----------------------|
| `p-{n}`   | `p-4`          | All sides            |
| `px-{n}`  | `px-6`         | Left + right         |
| `py-{n}`  | `py-2`         | Top + bottom         |
| `pt/pr/pb/pl-{n}` | `pt-4` | Single side         |
| `m-{n}`   | `m-4`          | Margin (same pattern)|
| `mx-auto` | `mx-auto`      | Center horizontally  |
| `space-x-{n}` | `space-x-4` | Between children (x)|
| `space-y-{n}` | `space-y-2` | Between children (y)|

Scale: 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 72, 80, 96

1 unit = 0.25rem = 4px

---

## Sizing

| Class         | Example      | CSS                      |
|---------------|--------------|--------------------------|
| `w-{n}`       | `w-64`       | `width: 16rem`          |
| `w-full`      | —            | `width: 100%`           |
| `w-screen`    | —            | `width: 100vw`          |
| `w-auto`      | —            | `width: auto`           |
| `w-fit`       | —            | `width: fit-content`    |
| `max-w-{size}`| `max-w-md`   | Max-width breakpoints   |
| `min-w-0`     | —            | `min-width: 0`          |
| `h-{n}`       | `h-12`       | Height                  |
| `h-full`      | —            | `height: 100%`          |
| `h-screen`    | —            | `height: 100vh`         |
| `min-h-screen`| —            | `min-height: 100vh`     |

Max-width values: `max-w-xs` (320px), `max-w-sm` (384px), `max-w-md` (448px), `max-w-lg` (512px), `max-w-xl` (576px), `max-w-2xl` (672px), ..., `max-w-7xl` (1280px)

---

## Typography

| Class            | Effect                          |
|------------------|---------------------------------|
| `text-xs/sm/base/lg/xl/2xl/...` | Font size         |
| `font-thin/light/normal/medium/semibold/bold/extrabold/black` | Weight |
| `text-left/center/right/justify` | Alignment         |
| `leading-tight/normal/relaxed`   | Line height       |
| `tracking-tight/normal/wide`     | Letter spacing    |
| `truncate`       | Overflow ellipsis (single line) |
| `line-clamp-{n}` | Clamp to N lines               |
| `uppercase/lowercase/capitalize` | Transform         |
| `underline/line-through/no-underline` | Decoration   |

---

## Common Layout Patterns

### Centered page content
```heex
<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
```

### Vertically centered
```heex
<div class="flex min-h-screen items-center justify-center">
```

### Sidebar layout
```heex
<div class="flex min-h-screen">
  <aside class="w-64 shrink-0">Sidebar</aside>
  <main class="flex-1">Content</main>
</div>
```

### Space-between header
```heex
<header class="flex items-center justify-between px-4 py-3">
  <div>Logo</div>
  <nav class="flex gap-4">Links</nav>
</header>
```

### Card grid
```heex
<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
  <div class="card" :for={item <- @items}>...</div>
</div>
```

### Stack with spacing
```heex
<div class="flex flex-col gap-4">
  <div>Section 1</div>
  <div>Section 2</div>
</div>
```

---

## Borders & Shadows

```heex
<div class="rounded-lg">          <%!-- border radius --%>
<div class="rounded-full">         <%!-- circle/pill --%>
<div class="border border-base-300"> <%!-- border --%>
<div class="shadow-sm">            <%!-- small shadow --%>
<div class="shadow-md">            <%!-- medium shadow --%>
<div class="ring-2 ring-primary">  <%!-- outline ring --%>
<div class="divide-y">             <%!-- dividers between children --%>
```

---

## Visibility & Display

| Class       | Effect                            |
|-------------|-----------------------------------|
| `hidden`    | `display: none`                  |
| `block`     | `display: block`                 |
| `inline`    | `display: inline`               |
| `flex`      | `display: flex`                  |
| `grid`      | `display: grid`                  |
| `invisible` | `visibility: hidden` (keeps space)|
| `sr-only`   | Screen reader only               |

---

## Overflow

```heex
<div class="overflow-hidden">     <%!-- clip content --%>
<div class="overflow-auto">       <%!-- scrollbar when needed --%>
<div class="overflow-x-auto">     <%!-- horizontal scroll --%>
<div class="overflow-y-scroll">   <%!-- always show scrollbar --%>
```

---

## Transitions & Animation

```heex
<div class="transition-all duration-200 ease-in-out">
<div class="hover:scale-105 transition-transform">
<div class="animate-spin">        <%!-- spinner --%>
<div class="animate-pulse">       <%!-- fade pulse --%>
```

---

## State Variants

| Prefix      | When applied                   |
|-------------|--------------------------------|
| `hover:`    | Mouse over                     |
| `focus:`    | Focused                        |
| `active:`   | Being clicked                  |
| `disabled:` | Disabled state                 |
| `first:`    | First child                    |
| `last:`     | Last child                     |
| `odd:`      | Odd children                   |
| `even:`     | Even children                  |
| `group-hover:` | Parent `.group` hovered     |
| `peer-*:`   | Sibling `.peer` state          |
| `dark:`     | Dark mode                      |
