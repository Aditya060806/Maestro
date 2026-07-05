import { deriveDashboardHeadline, type GuiStatusData } from "@maestro/gui-shared";
import type { ReactElement } from "react";

/**
 * Compact "at a glance" strip for the top of the Maestro dashboard.
 *
 * Renders only already-redacted, metadata-only status data via
 * `deriveDashboardHeadline`. It is safe to screenshot and share.
 */
export function DashboardHeadline({ status }: { status: GuiStatusData }): ReactElement {
  const headline = deriveDashboardHeadline(status);

  return (
    <section
      className="dashboard-headline"
      aria-label="Maestro at a glance"
      data-value-policy={headline.value_policy}
    >
      <header className="dashboard-headline-summary">
        <strong className="dashboard-headline-title">{headline.headline}</strong>
        <span className="dashboard-headline-scope">{headline.scope_label}</span>
        {headline.attention_count > 0 ? (
          <span className="dashboard-headline-attention" role="status">
            {headline.attention_count} need attention
          </span>
        ) : null}
      </header>
      <ul className="dashboard-headline-metrics">
        {headline.metrics.map((metric) => (
          <li key={metric.id} data-metric={metric.id} data-status={metric.status}>
            <span className="dashboard-metric-label">{metric.label}</span>
            <strong className="dashboard-metric-value">{metric.value}</strong>
            <small className="dashboard-metric-detail">{metric.detail}</small>
          </li>
        ))}
      </ul>
    </section>
  );
}
