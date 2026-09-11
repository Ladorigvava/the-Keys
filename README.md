# The Keys Systems AI OS — Encrypted Railway Deployment Shim

This public repository contains **no plaintext TKS source code or provider credentials**.

It exists only to let Railway deploy the verified V4.1 runtime without requiring Railway GitHub App access to the private release repository.

- Runtime payload: AES-256-CBC encrypted `tar.xz`, split into four Base64 text chunks
- Decryption key: stored only in Railway environment variables
- Plaintext runtime SHA-256: `fb4d1fca1a0431351b0b0aab401e891fd5e34a9bf1a2d7c2e7e1cc2685f1f28d`
- Public production service: `https://tks-ai-os-backend-production.up.railway.app`

At startup the container reconstructs and decrypts the runtime, verifies the exact plaintext SHA-256, extracts it into its private filesystem, then launches `app/server.mjs` using the persistent `/data` volume.

The public repository is therefore only a deployment transport. Possession of these files alone is insufficient to recover the proprietary TKS runtime.
