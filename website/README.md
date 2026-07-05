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

There are two supported ways — either works.

### Option A — Root Directory = `website` (recommended)

1. Import the GitHub repo `Aditya060806/Maestro` into Vercel.
2. In **Project Settings → General → Root Directory**, set it to `website`.
3. Framework Preset: **Other**. Build Command: none. Output Directory: leave default.
4. Deploy. Vercel serves the static files directly.

### Option B — Deploy from the repo root

The repo root `vercel.json` is preconfigured with `outputDirectory: "website"` and a
no-op build, so importing the repo with the **default** root also serves this site
without building the monorepo.

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
