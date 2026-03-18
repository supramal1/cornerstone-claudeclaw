import { spawnSync } from "node:child_process";
import os from "node:os";
import path from "node:path";

const CLAUDECLAW_HOME = process.env.CLAUDECLAW_HOME || path.join(os.homedir(), ".claudeclaw");
const SCRIPT =
  process.env.CLAUDECLAW_POST_SESSION_EXTRACT ||
  path.join(CLAUDECLAW_HOME, "scripts", "memory", "post_session_extract.py");
const PYTHON = process.env.CLAUDECLAW_MEMORY_PYTHON || "python3";

const handler = async (event) => {
  if (event.type !== "command") return;

  const action = event.action;
  if (action !== "new" && action !== "reset" && action !== "stop") return;

  try {
    spawnSync(PYTHON, [SCRIPT], {
      timeout: 30_000,
      stdio: ["pipe", "ignore", "ignore"],
      input: Array.isArray(event.messages) ? JSON.stringify(event.messages) : undefined,
    });
  } catch {
    // Fail silently so hook issues never disrupt session lifecycle.
  }
};

export default handler;
