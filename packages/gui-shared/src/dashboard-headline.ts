import type {
  GuiPulseWorkerStatus,
  GuiPulseWorkerSummary,
  GuiStatusData,
} from "./contracts";

/**
 * Dashboard headline model.
 *
 * This derives the "at a glance" strip that sits at the top of the Maestro GUI
 * (and can be rendered as a shareable status card). It is intentionally derived
 * only from already-redacted, metadata-only status data — it never reads prompt
 * payloads, secret values, credential paths, or tokens.
 */

export type GuiDashboardMetricStatus = GuiPulseWorkerStatus | "neutral";

export interface GuiDashboardMetric {
  id: string;
  label: string;
  value: string;
  status: GuiDashboardMetricStatus;
  detail: string;
}

export interface GuiDashboardHeadline {
  headline: string;
  scope_label: string;
  updated_at: string;
  metrics: GuiDashboardMetric[];
  attention_count: number;
  value_policy: "metadata_only_no_secrets";
}

function findKpiValue(
  pulse: GuiPulseWorkerSummary | undefined,
  kpiId: string,
): { value: string; status: GuiDashboardMetricStatus; detail: string } | null {
  const kpi = pulse?.kpis?.find((candidate) => candidate.id === kpiId);
  if (!kpi) {
    return null;
  }
  return { value: kpi.value, status: kpi.status, detail: kpi.detail };
}

function countEvents(
  pulse: GuiPulseWorkerSummary | undefined,
  predicate: (event: GuiPulseWorkerSummary["events"][number]) => boolean,
): number {
  const events = pulse?.events;
  if (!Array.isArray(events)) {
    return 0;
  }
  return events.filter(predicate).length;
}

/**
 * Derive the compact headline card from a GUI status payload.
 *
 * Tolerates partially loaded payloads: any missing section falls back to a
 * neutral, non-alarming value rather than throwing.
 */
export function deriveDashboardHeadline(
  status: Partial<GuiStatusData> | null | undefined,
): GuiDashboardHeadline {
  const pulse = status?.pulse_workers;

  const activeWorkers = countEvents(
    pulse,
    (event) => event.type === "worker_session" && event.status === "running",
  );
  const mergedPrs = countEvents(pulse, (event) => event.outcome === "merged");

  const health = findKpiValue(pulse, "healthy-sessions");
  const cost = findKpiValue(pulse, "token-cost");
  const systemicFixes = findKpiValue(pulse, "systemic-fixes");

  const attentionCount = Array.isArray(pulse?.attention)
    ? pulse.attention.length
    : 0;

  const reposTracked =
    status?.local_repos?.total ?? status?.repos?.total ?? 0;

  const providersConfigured = Array.isArray(status?.oauth_pool?.providers)
    ? status.oauth_pool.providers.filter((provider) => provider.configured).length
    : 0;

  const metrics: GuiDashboardMetric[] = [
    {
      id: "active-workers",
      label: "Workers active",
      value: String(activeWorkers),
      status: activeWorkers > 0 ? "running" : "neutral",
      detail:
        activeWorkers > 0
          ? `${activeWorkers} worker session(s) currently executing.`
          : "No worker sessions are running right now.",
    },
    {
      id: "merged-prs",
      label: "PRs merged",
      value: String(mergedPrs),
      status: mergedPrs > 0 ? "completed" : "neutral",
      detail: `${mergedPrs} pull request(s) merged in the current window.`,
    },
    {
      id: "health",
      label: "Session health",
      value: health?.value ?? "—",
      status: health?.status ?? "neutral",
      detail: health?.detail ?? "Health metrics load once Pulse data is available.",
    },
    {
      id: "budget",
      label: "Token / cost",
      value: cost?.value ?? "—",
      status: cost?.status ?? "neutral",
      detail:
        cost?.detail ??
        "Estimated, metadata-only. Excludes prompts, secrets, and credential paths.",
    },
    {
      id: "systemic-fixes",
      label: "Systemic fixes",
      value: systemicFixes?.value ?? "0",
      status: systemicFixes?.status ?? "neutral",
      detail:
        systemicFixes?.detail ??
        "Repeated blindspots become worker-ready follow-up tasks.",
    },
    {
      id: "repos-tracked",
      label: "Repos tracked",
      value: String(reposTracked),
      status: "neutral",
      detail: `${reposTracked} local repo(s) registered with Maestro.`,
    },
    {
      id: "providers",
      label: "Model providers",
      value: String(providersConfigured),
      status: providersConfigured > 0 ? "healthy" : "attention",
      detail:
        providersConfigured > 0
          ? `${providersConfigured} model provider pool(s) configured.`
          : "No model providers configured yet — add one to start dispatching work.",
    },
  ];

  const headline = `${activeWorkers} working · ${mergedPrs} merged · ${
    health?.value ?? "—"
  } healthy · ${cost?.value ?? "—"}`;

  const scopeLabel = pulse?.scope_label ?? "this machine";
  const updatedAt = pulse?.updated_at ?? status?.update?.message ?? "";

  return {
    headline,
    scope_label: scopeLabel,
    updated_at: updatedAt,
    metrics,
    attention_count: attentionCount,
    value_policy: "metadata_only_no_secrets",
  };
}
