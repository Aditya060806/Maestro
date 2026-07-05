import { existsSync, readFileSync } from "node:fs"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

const MAESTRO_TITLE_SUFFIX_RE = /\s+· Maestro \d+\.\d+\.\d+$/

function readVersionFile(path: string): string {
  try {
    if (!existsSync(path)) return ""
    return readFileSync(path, "utf8").trim()
  } catch {
    return ""
  }
}

export function getMaestroVersion(): string {
  if (process.env.MAESTRO_VERSION) return process.env.MAESTRO_VERSION.trim()

  const here = dirname(fileURLToPath(import.meta.url))
  const candidates = [
    join(here, "..", "..", "VERSION"),
    join(here, "..", "..", ".agents", "VERSION"),
    join(process.env.HOME || "", ".maestro", "agents", "VERSION"),
  ]

  for (const candidate of candidates) {
    const version = readVersionFile(candidate)
    if (version) return version
  }

  return ""
}

export function withMaestroTitleSuffix(title: string, version = getMaestroVersion()): string {
  const baseTitle = title.replace(MAESTRO_TITLE_SUFFIX_RE, "")
  if (!version) return baseTitle
  return `${baseTitle} · Maestro ${version}`
}
