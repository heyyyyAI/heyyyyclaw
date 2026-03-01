#!/bin/sh
set -e

# Ensure gateway.controlUi.allowedOrigins is set when OPENCLAW_ALLOWED_ORIGIN is provided
if [ -n "$OPENCLAW_ALLOWED_ORIGIN" ]; then
  node -e "
    const fs = require('fs');
    const path = require('path');
    const dir = process.env.OPENCLAW_STATE_DIR || '/data/.openclaw';
    const file = path.join(dir, 'openclaw.json');
    fs.mkdirSync(dir, { recursive: true });
    let config = {};
    try { config = JSON.parse(fs.readFileSync(file, 'utf8')); } catch {}
    config.gateway = config.gateway || {};
    config.gateway.controlUi = config.gateway.controlUi || {};
    config.gateway.controlUi.allowedOrigins = [process.env.OPENCLAW_ALLOWED_ORIGIN];
    fs.writeFileSync(file, JSON.stringify(config, null, 2));
  "
fi

exec node openclaw.mjs gateway --allow-unconfigured --bind lan --port "${PORT:-8080}"
