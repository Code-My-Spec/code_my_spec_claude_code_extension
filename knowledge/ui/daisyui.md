# DaisyUI 5

## Sources
- https://daisyui.com/components/
- https://daisyui.com/docs/themes/
- https://daisyui.com/docs/colors/
- https://daisyui.com/components/button/
- https://daisyui.com/components/modal/
- https://daisyui.com/components/card/
- https://daisyui.com/components/table/
- https://daisyui.com/components/input/
- https://daisyui.com/components/alert/

---

## Semantic Colors

Use these instead of raw Tailwind colors for theme-awareness:

| Color              | Purpose                    | Content variant        |
|--------------------|----------------------------|------------------------|
| `primary`          | Main brand color           | `primary-content`      |
| `secondary`        | Secondary brand color      | `secondary-content`    |
| `accent`           | Accent color               | `accent-content`       |
| `neutral`          | Dark unsaturated UI parts  | `neutral-content`      |
| `base-100`         | Page background            | `base-content`         |
| `base-200`         | Slightly darker surface    | —                      |
| `base-300`         | Even darker surface        | —                      |
| `info`             | Informational              | `info-content`         |
| `success`          | Success / safe             | `success-content`      |
| `warning`          | Caution                    | `warning-content`      |
| `error`            | Error / danger             | `error-content`        |

Use as Tailwind utilities: `bg-primary`, `text-primary-content`, `border-error`.
Opacity: `bg-primary/50`.

---

## Theme System

### Configuration (CSS-based, DaisyUI 5 + Tailwind 4)

```css
@import "tailwindcss";
@plugin "daisyui" {
  themes: light --default, dark --prefersdark;
}
```

### Applying themes

```html
<html data-theme="light">
```

Themes can nest at any level: `<div data-theme="dark">`.

### Built-in themes (35)

light, dark, cupcake, bumblebee, emerald, corporate, synthwave, retro,
cyberpunk, valentine, halloween, garden, forest, aqua, lofi, pastel,
fantasy, wireframe, black, luxury, dracula, cmyk, autumn, business,
acid, lemonade, night, coffee, winter, dim, nord, sunset,
caramellatte, abyss, silk

### Custom theme

```css
@plugin "daisyui/theme" {
  name: "mytheme";
  default: true;
  --color-primary: oklch(55% 0.3 240);
  --color-secondary: oklch(65% 0.2 300);
  --radius-box: 0.5rem;
}
```

---

## Components Quick Reference

### Button

Base: `btn`

| Class           | Effect                                  |
|-----------------|-----------------------------------------|
| `btn-primary`   | Primary color                          |
| `btn-secondary`  | Secondary color                       |
| `btn-accent`    | Accent color                           |
| `btn-neutral`   | Neutral color                          |
| `btn-info/success/warning/error` | Status colors        |
| `btn-outline`   | Outline style                          |
| `btn-ghost`     | Minimal / transparent                  |
| `btn-soft`      | Muted color                            |
| `btn-dash`      | Dashed border                          |
| `btn-link`      | Link appearance                        |
| `btn-xs/sm/md/lg/xl` | Sizes                            |
| `btn-wide`      | Extra horizontal padding               |
| `btn-block`     | Full width                             |
| `btn-circle`    | Round shape                            |
| `btn-square`    | Square shape                           |
| `btn-active`    | Pressed appearance                     |
| `btn-disabled`  | Disabled (add `tabindex="-1"` + `aria-disabled`) |

```heex
<button class="btn btn-primary">Save</button>
<button class="btn btn-outline btn-error btn-sm">Delete</button>
<.link navigate={~p"/back"} class="btn btn-ghost">Cancel</.link>
```

### Card

Base: `card`

```heex
<div class="card bg-base-100 shadow-sm">
  <figure><img src={@image} alt="" /></figure>
  <div class="card-body">
    <h2 class="card-title">{@title}</h2>
    <p>{@description}</p>
    <div class="card-actions justify-end">
      <button class="btn btn-primary">Action</button>
    </div>
  </div>
</div>
```

| Class         | Effect                         |
|---------------|--------------------------------|
| `card-body`   | Content padding area          |
| `card-title`  | Title styling                 |
| `card-actions` | Actions container            |
| `card-border` | Visible border                |
| `card-dash`   | Dashed border                 |
| `card-side`   | Horizontal layout (image side)|
| `image-full`  | Image as background overlay   |
| `card-xs/sm/md/lg/xl` | Sizes               |

### Modal (uses native `<dialog>`)

```heex
<button onclick="my_modal.showModal()" class="btn">Open</button>
<dialog id="my_modal" class="modal">
  <div class="modal-box">
    <h3 class="text-lg font-bold">Title</h3>
    <p class="py-4">Content</p>
    <div class="modal-action">
      <form method="dialog">
        <button class="btn">Close</button>
      </form>
    </div>
  </div>
  <form method="dialog" class="modal-backdrop">
    <button>close</button>
  </form>
</dialog>
```

Open: `document.getElementById('id').showModal()`
Close: `document.getElementById('id').close()` or `<form method="dialog">`

| Class             | Effect                      |
|-------------------|-----------------------------|
| `modal`           | Container                  |
| `modal-box`       | Content box                |
| `modal-action`    | Button area                |
| `modal-backdrop`  | Click-to-close overlay     |
| `modal-top/middle/bottom` | Vertical position  |
| `modal-start/end` | Horizontal position        |
| `modal-open`      | Force open via CSS         |

### Table

Base: `table`

```heex
<div class="overflow-x-auto">
  <table class="table table-zebra">
    <thead>
      <tr><th>Name</th><th>Email</th></tr>
    </thead>
    <tbody>
      <tr :for={{dom_id, user} <- @streams.users} id={dom_id}>
        <td>{user.name}</td>
        <td>{user.email}</td>
      </tr>
    </tbody>
  </table>
</div>
```

| Class            | Effect                          |
|------------------|---------------------------------|
| `table-zebra`    | Alternating row colors         |
| `table-pin-rows` | Sticky thead/tfoot             |
| `table-pin-cols` | Sticky th columns              |
| `table-xs/sm/md/lg/xl` | Sizes                   |

### Form Inputs

**Text input** — base: `input`

```heex
<input type="text" class="input input-primary" placeholder="Name" />
```

**With label wrapper:**
```heex
<label class="input">
  <svg><!-- icon --></svg>
  <input type="search" class="grow" placeholder="Search" />
</label>
```

**With fieldset:**
```heex
<fieldset class="fieldset">
  <legend class="fieldset-legend">Email</legend>
  <input type="email" class="input" placeholder="email@example.com" />
  <p class="label">Helper text</p>
</fieldset>
```

| Component    | Base class   | Modifiers (color)                                       | Sizes               |
|-------------|-------------|--------------------------------------------------------|---------------------|
| Text input  | `input`     | `input-primary/secondary/accent/info/success/warning/error` | `input-xs/sm/md/lg/xl` |
| Select      | `select`    | `select-primary/...`                                    | `select-xs/sm/md/lg/xl` |
| Textarea    | `textarea`  | `textarea-primary/...`                                  | `textarea-xs/sm/md/lg/xl` |
| Checkbox    | `checkbox`  | `checkbox-primary/...`                                  | `checkbox-xs/sm/md/lg/xl` |
| Radio       | `radio`     | `radio-primary/...`                                     | `radio-xs/sm/md/lg/xl` |
| Toggle      | `toggle`    | `toggle-primary/...`                                    | `toggle-xs/sm/md/lg/xl` |

Ghost variant: `input-ghost`, `select-ghost`, `textarea-ghost`.

### Alert

```heex
<div role="alert" class="alert alert-info">
  <svg class="h-6 w-6 shrink-0 stroke-info"><!-- icon --></svg>
  <span>Info message</span>
</div>
```

| Class               | Effect                     |
|---------------------|----------------------------|
| `alert`             | Base                       |
| `alert-info/success/warning/error` | Status color |
| `alert-outline`     | Outlined style             |
| `alert-soft`        | Muted style                |
| `alert-dash`        | Dashed border              |
| `alert-vertical`    | Stack layout               |
| `alert-horizontal`  | Side-by-side layout        |

### Badge

Base: `badge`

```heex
<span class="badge badge-primary">New</span>
<span class="badge badge-outline badge-sm">Draft</span>
```

Colors: `badge-primary/secondary/accent/info/success/warning/error`
Styles: `badge-outline`, `badge-soft`, `badge-dash`
Sizes: `badge-xs/sm/md/lg/xl`

### Tabs

```heex
<div role="tablist" class="tabs tabs-box">
  <button role="tab" class={"tab #{@tab == "one" && "tab-active"}"}>One</button>
  <button role="tab" class={"tab #{@tab == "two" && "tab-active"}"}>Two</button>
</div>
```

Styles: `tabs-box`, `tabs-border`, `tabs-lift`
Sizes: `tabs-xs/sm/md/lg/xl`

### Dropdown

```heex
<div class="dropdown">
  <div tabindex="0" role="button" class="btn">Click</div>
  <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm">
    <li><a>Item 1</a></li>
    <li><a>Item 2</a></li>
  </ul>
</div>
```

Modifiers: `dropdown-hover`, `dropdown-end`, `dropdown-top`, `dropdown-left`, `dropdown-right`

### Menu

```heex
<ul class="menu bg-base-200 rounded-box w-56">
  <li><a>Item 1</a></li>
  <li><a class="menu-active">Active</a></li>
  <li><a class="menu-disabled">Disabled</a></li>
</ul>
```

### Loading

```heex
<span class="loading loading-spinner loading-md"></span>
<span class="loading loading-dots loading-lg"></span>
```

Styles: `loading-spinner`, `loading-dots`, `loading-ring`, `loading-ball`, `loading-bars`, `loading-infinity`
Sizes: `loading-xs/sm/md/lg/xl`

### Toast (positioned alerts)

```heex
<div class="toast toast-end">
  <div class="alert alert-success">Saved!</div>
</div>
```

Position: `toast-start/center/end` + `toast-top/middle/bottom`

### Tooltip

```heex
<div class="tooltip" data-tip="Hello">
  <button class="btn">Hover me</button>
</div>
```

Position: `tooltip-top/bottom/left/right`

### Stats

```heex
<div class="stats shadow">
  <div class="stat">
    <div class="stat-title">Total Users</div>
    <div class="stat-value">31,200</div>
    <div class="stat-desc">+21% from last month</div>
  </div>
</div>
```

### Steps

```heex
<ul class="steps">
  <li class="step step-primary">Register</li>
  <li class="step step-primary">Choose plan</li>
  <li class="step">Purchase</li>
</ul>
```

### Collapse (accordion)

```heex
<div class="collapse collapse-arrow bg-base-100">
  <input type="radio" name="accordion" checked="checked" />
  <div class="collapse-title font-semibold">Title</div>
  <div class="collapse-content">Content</div>
</div>
```

### Drawer

```heex
<div class="drawer">
  <input id="drawer" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content">
    <label for="drawer" class="btn btn-primary drawer-button">Open</label>
  </div>
  <div class="drawer-side">
    <label for="drawer" aria-label="close" class="drawer-overlay"></label>
    <ul class="menu bg-base-200 min-h-full w-80 p-4">
      <li><a>Item</a></li>
    </ul>
  </div>
</div>
```

### Navbar

```heex
<div class="navbar bg-base-100">
  <div class="navbar-start"><a class="btn btn-ghost text-xl">App</a></div>
  <div class="navbar-center"><a class="btn btn-ghost">Home</a></div>
  <div class="navbar-end"><button class="btn btn-primary">Login</button></div>
</div>
```

### Pagination (join)

```heex
<div class="join">
  <button class="join-item btn">1</button>
  <button class="join-item btn btn-active">2</button>
  <button class="join-item btn">3</button>
</div>
```

### Avatar

```heex
<div class="avatar">
  <div class="w-12 rounded-full">
    <img src={@avatar_url} alt="" />
  </div>
</div>
```

Modifiers: `avatar-online`, `avatar-offline`, `avatar-placeholder`
