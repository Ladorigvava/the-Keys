# The Keys Systems AI OS — Encrypted Railway Deployment Shim

This public repository contains **no plaintext TKS source code or provider credentials**.

It exists only to let Railway deploy the verified V4.1 runtime without requiring Railway GitHub App access to the private release repository.

- Runtime payload: AES-256-CBC encrypted
- Decryption key: stored only in Railway environment variables
- Plaintext runtime SHA-256: `14b6215a1a6735872bc4b5834938bbdaf5f3f8c9b94ee97b824d743a1490c4a2`
- Public production service: `https://tks-ai-os-backend-production.up.railway.app`

The container decrypts the runtime at startup, verifies its SHA-256, then launches `app/server.mjs` with the persistent `/data` volume.
