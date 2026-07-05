import { describe, expect, test } from "bun:test";
import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { statusFixture } from "@maestro/gui-shared";
import { DashboardHeadline } from "../src/DashboardHeadline";

describe("DashboardHeadline component", () => {
  test("renders the headline summary strip from status data", () => {
    const html = renderToStaticMarkup(createElement(DashboardHeadline, { status: statusFixture }));

    expect(html).toContain("1 working · 1 merged · 86% healthy · 1.8M / $14");
    expect(html).toContain("all managed repos");
    expect(html).toContain('data-value-policy="metadata_only_no_secrets"');
  });

  test("renders every derived metric with status and label", () => {
    const html = renderToStaticMarkup(createElement(DashboardHeadline, { status: statusFixture }));

    for (const label of ["Workers active", "PRs merged", "Session health", "Token / cost", "Systemic fixes", "Repos tracked", "Model providers"]) {
      expect(html).toContain(label);
    }
    expect(html).toContain('data-metric="active-workers"');
    expect(html).toContain('data-status="running"');
    expect(html).toContain('data-status="attention"'); // providers = 0 in fixture
  });

  test("surfaces the attention count when the queue is non-empty", () => {
    const html = renderToStaticMarkup(createElement(DashboardHeadline, { status: statusFixture }));
    expect(html).toContain("need attention");
  });
});
