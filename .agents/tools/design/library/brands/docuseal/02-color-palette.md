<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# docuseal: Colour Palette

## Observed/source-informed colours

- `#181818`
- `#F59F5A`
- `#FFE2C2`
- `#FFFFFF`
- `#F8F4F1`
- `#E3D8CE`
- `#3F3F3F`
- `#111827`

## Semantic report mapping

- `#F8F4F1` — background
- `#FFFFFF` — surface
- `#181818` — on-surface
- `#3F3F3F` — muted
- `#E3D8CE` — outline
- `#F59F5A` — primary
- `#FFE2C2` — primary-container
- `#181818` — code-background
- `#F9FAFB` — code-on-background
- `#F59F5A` — code-accent

## Application rules

- Use source colours as evidence, then map into semantic DESIGN.md roles.
- Adjust brightness when required for readable long-form reports and WCAG contrast.
- Long-form text must use high-contrast `on-surface`, not decorative accent colours.
- Badge/status colours must preserve labels and borders so grayscale PDF output remains meaningful.

## Required contrast checks

- Body text on background and surface: WCAG AA 4.5:1 minimum.
- Large headings and non-text UI indicators: 3:1 minimum.
- Focus rings, table borders, and evidence badge borders: visible against adjacent surfaces.
