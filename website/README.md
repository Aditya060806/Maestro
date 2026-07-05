<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Maestro — marketing & docs site

A zero-dependency static site (HTML + CSS + vanilla JS) for [Maestro](https://github.com/Aditya060806/Maestro). No build step, no framework — it just serves.

## Files

- `index.html` — landing page + documentation (single page)
- `styles.css` — premium dark theme, animations, responsive layout
- `main.js` — starfield canvas, scroll reveals, nav behaviour, copy-to-clipboard
- `vercel.json` — clean URLs config (used when this folder is the Vercel root)

## Deploy to Vercel

This is a static site in a subdirectory. Deploy it by pointing Vercel's **Root
Directory** at `website` — that is the only setting required.

1. Import the GitHub repo `Aditya060806/Maestro` into Vercel.
2. **Root Directory:** set it to `website` (click **Edit** next to Root Directory).
3. **Framework Preset:** `Other`.
4. **Build & Output Settings:** leave everything blank — no Build Command, no
   Output Directory, no Install Command. There is no build step.
5. **Deploy.** Vercel serves the files in `website/` directly.

> Do not add an `outputDirectory` at the repo root — with Root Directory set to
> `website`, that would make Vercel look for `website/website` and fail. The only
> config is `website/vercel.json` (clean URLs).

## Local preview

Any static server works, for example:

```bash
npx serve website
# or
python3 -m http.server --directory website 5500
```

## Links

- Repository: <https://github.com/Aditya060806/Maestro>
- npm package: <https://www.npmjs.com/package/maestro-devops>
- Author: [Aditya Pandey](https://github.com/Aditya060806) · [LinkedIn](https://www.linkedin.com/in/aditya-pandey-p1002/)
