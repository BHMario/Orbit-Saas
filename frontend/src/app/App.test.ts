import { describe, it, expect } from "vitest";
import { App } from "./App";

describe("App", () => {
  it("renders without crashing", () => {
    expect(App).toBeDefined();
    expect(typeof App).toBe("function");
    const element = App();
    expect(element).toBeDefined();
  });
});
