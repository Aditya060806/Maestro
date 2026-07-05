<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# FSD Layers Reference — Detailed Specs

> **Source:** [Layers Reference](https://feature-sliced.design/docs/reference/layers) | [FSD Overview](https://feature-sliced.design/docs/get-started/overview)

Layer hierarchy, import rule, and placement decisions are in the parent `feature-slicing-skill.md`. This file provides per-layer detail.

**Note:** `processes/` layer is DEPRECATED. Use pages with composition instead.

---

## Shared Layer

> [Shared Layer Docs](https://feature-sliced.design/docs/reference/layers#shared)

Foundation layer for external connections and utilities. **No business domain knowledge.**

```text
shared/
├── api/           # Backend client, request functions, interceptors
├── ui/            # Business-agnostic UI (buttons, inputs, modals)
├── lib/           # Focused utilities (dates, colors, validation)
├── config/        # Environment variables, feature flags
├── routes/        # Route path constants
├── i18n/          # Translation setup
└── types/         # Global TypeScript types (utility types)
```

- Use purpose-driven segment names — avoid `components/`, `hooks/`, `utils/`
- Should be extractable to a separate package
- NO domain logic

**TypeScript types:** Utility types → `shared/lib/utility-types`. DTOs → `shared/api` near request functions. Avoid generic `shared/types` folder.

---

## Entities Layer

> [Entities Layer Docs](https://feature-sliced.design/docs/reference/layers#entities)

Real-world business concepts the application works with.

```text
entities/
├── user/
│   ├── ui/           # UserAvatar, UserCard, UserBadge
│   ├── api/          # getUser, updateUser, queries
│   ├── model/        # User types, validation, store
│   ├── lib/          # formatUserName, calculateAge
│   └── index.ts      # Public API
├── product/
│   ├── ui/
│   ├── api/
│   ├── model/
│   └── index.ts
└── order/
    └── ...
```

**Belongs here:** Data models/interfaces, CRUD API functions, reusable UI representations, validation schemas (Zod, Yup), entity-specific mappers (DTO → Domain).

**Does NOT belong:** User interactions (→ features), page layouts (→ pages), composed UI blocks (→ widgets).

**Cross-Entity References (@x Notation):**

> [Cross-Imports @x Notation](https://feature-sliced.design/docs/reference/public-api#public-api-for-cross-imports)

When entities must reference each other:

```text
entities/
├── product/
│   ├── @x/
│   │   └── order.ts    # API for order entity only
│   └── index.ts
└── order/
    └── model/types.ts  # imports from product/@x/order
```

```typescript
// entities/product/@x/order.ts
export type { ProductId, ProductName } from '../model/types';

// entities/order/model/types.ts
import type { ProductId } from '@/entities/product/@x/order';
```

---

## Features Layer

> [Features Layer Docs](https://feature-sliced.design/docs/reference/layers#features)

User-facing interactions that provide business value.

**Key principle:** Not everything is a feature. Per [FSD v2.1](https://github.com/feature-sliced/documentation/releases/tag/v2.1), keep non-reused interactions in page slices.

```text
features/
├── auth/
│   ├── ui/           # LoginForm, LogoutButton
│   ├── api/          # login, logout, register
│   ├── model/        # auth state, session, schemas
│   └── index.ts
├── add-to-cart/
│   ├── ui/           # AddToCartButton, QuantitySelector
│   ├── api/          # addToCart mutation
│   ├── model/        # validation
│   └── index.ts
└── search-products/
    ├── ui/           # SearchInput, Filters
    ├── api/          # searchProducts
    ├── model/        # search state
    └── index.ts
```

**Feature vs Entity:**

| Entity | Feature |
|--------|---------|
| Represents a THING | Represents an ACTION |
| `user` — user data | `auth` — login/logout |
| `product` — product info | `add-to-cart` — adding |
| `comment` — comment data | `write-comment` — creating |

---

## Widgets Layer

> [Widgets Layer Docs](https://feature-sliced.design/docs/reference/layers#widgets)

Large, self-sufficient UI components reused across multiple pages.

**Use when:** reused across multiple pages, complex with multiple children, delivers a complete use case.

```text
widgets/
├── header/
│   ├── ui/           # Header, NavMenu, UserDropdown
│   └── index.ts
├── sidebar/
│   ├── ui/           # Sidebar, SidebarItem
│   └── index.ts
└── product-list/
    ├── ui/           # ProductList, ProductGrid, Filters
    └── index.ts
```

**Widget vs Feature:** Widget = composed UI block (visual). Feature = user interaction (behavioral).

Widgets often compose multiple features:

```tsx
// widgets/header/ui/Header.tsx
import { UserAvatar } from '@/entities/user';
import { LogoutButton } from '@/features/auth';
import { SearchBox } from '@/features/search';
```

**Don't create widgets for:** single-use components (keep in page) or simple compositions (compose in page directly).

---

## Pages Layer

> [Pages Layer Docs](https://feature-sliced.design/docs/reference/layers#pages)

Individual screens or routes. One slice per route (generally).

```text
pages/
├── home/
│   ├── ui/           # HomePage, HeroSection
│   ├── api/          # loader functions
│   └── index.ts
├── product-detail/
│   ├── ui/           # ProductDetailPage
│   ├── api/          # getProduct loader
│   └── index.ts
└── checkout/
    ├── ui/           # CheckoutPage, Steps
    ├── api/          # checkout mutations
    ├── model/        # form validation
    └── index.ts
```

- Similar pages can share a slice (login/register)
- Pages compose widgets, features, entities
- Minimal business logic — delegate to lower layers
- Non-reused interactions stay in page slice (v2.1)

---

## App Layer

> [App Layer Docs](https://feature-sliced.design/docs/reference/layers#app)

Application-wide configuration and initialization.

```text
app/
├── providers/        # React context, store setup
│   ├── ThemeProvider.tsx
│   ├── QueryProvider.tsx
│   └── index.ts
├── routes/           # Router configuration
│   └── router.tsx
├── styles/           # Global CSS, theme tokens
│   ├── globals.css
│   └── theme.ts
└── index.tsx         # Entry point
```

Responsibilities: initialize application state, set up routing, configure global providers, define global styles, application-wide error boundaries.
