import { describe, expect, test } from "bun:test";
import {
  assertNoSecretSentinels,
  deriveDashboardHeadline,
  statusFixture,
  type GuiStatusData,
} from "../src";

describe("dashboard headline derivation", () => {
  test("derives compact headline metrics from the status fixture", () => {
    const headline = deriveDashboardHeadline(statusFixture);

    expect(headline.value_policy).toBe("metadata_only_no_secrets");
    expect(headline.scope_label).toBe("all managed repos");
    expect(headline.metrics.map((metric) => metric.id)).toEqual([
      "active-workers",
      "merged-prs",
      "health",
      "budget",
      "systemic-fixes",
      "repos-tracked",
      "providers",
    ]);
  });

  test("counts running workers and merged PRs from pulse events", () => {
    const headline = deriveDashboardHeadline(statusFixture);
    const byId = Object.fromEntries(headline.metrics.map((m) => [m.id, m]));

    // Fixture has one running worker_session and one merged review event.
    expect(byId["active-workers"].value).toBe("1");
    expect(byId["active-workers"].status).toBe("running");
    expect(byId["merged-prs"].value).toBe("1");
    expect(byId["merged-prs"].status).toBe("completed");
  });

  test("pulls health, budget, and systemic-fix KPIs through", () => {
    const headline = deriveDashboardHeadline(statusFixture);
    const byId = Object.fromEntries(headline.metrics.map((m) => [m.id, m]));

    expect(byId["health"].value).toBe("86%");
    expect(byId["budget"].value).toBe("1.8M / $14");
    expect(byId["systemic-fixes"].value).toBe("9");
    expect(headline.headline).toBe("1 working · 1 merged · 86% healthy · 1.8M / $14");
  });

  test("reports the attention queue length", () => {
    const headline = deriveDashboardHeadline(statusFixture);
    expect(headline.attention_count).toBe(statusFixture.pulse_workers.attention.length);
  });

  test("flags missing providers as needing attention", () => {
    const headline = deriveDashboardHeadline(statusFixture);
    const providers = headline.metrics.find((m) => m.id === "providers");

    // The fixture ships with no configured provider pools.
    expect(providers?.value).toBe("0");
    expect(providers?.status).toBe("attention");
  });

  test("tolerates null, empty, and partially loaded payloads without throwing", () => {
    const empty = deriveDashboardHeadline(null);
    expect(empty.headline).toBe("0 working · 0 merged · — healthy · —");
    expect(empty.attention_count).toBe(0);
    expect(empty.metrics).toHaveLength(7);

    const partial: Partial<GuiStatusData> = {
      repos: { path_ref: "~/.config/maestro/repos.json", health: "present", total: 4, repos: [] },
    };
    const partialHeadline = deriveDashboardHeadline(partial);
    const repos = partialHeadline.metrics.find((m) => m.id === "repos-tracked");
    expect(repos?.value).toBe("4");
  });

  test("never leaks secret sentinels into the derived headline", () => {
    const headline = deriveDashboardHeadline(statusFixture);
    expect(() => assertNoSecretSentinels(headline)).not.toThrow();
  });
});
