import { describe, expect, test } from "bun:test";
import { assertNoSecretSentinels, createEnvelope, statusFixture } from "../src";

describe("GUI shared redaction guard", () => {
  test("status fixture contains secret references only", () => {
    const envelope = createEnvelope({
      operation_id: "setup.status.read",
      source: {
        surface: "setup",
        authority: "maestro helpers",
        path_refs: ["~/.config/maestro/settings.json"],
      },
      data: statusFixture,
    });

    expect(() => assertNoSecretSentinels(envelope)).not.toThrow();
  });
});
