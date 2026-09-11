import fs from 'node:fs';
import crypto from 'node:crypto';

const base = '/opt/tks';
const output = '/tmp/tks-runtime.tar.xz.enc';
const expectedEncryptedSha256 = 'acba19175a0101f2a5621c85b3d6ff671e62d52ec5578d9556c3ff1f859db6d3';
const files = [1, 2, 3, 4].map((n) => `${base}/runtime.part${n}.b64`);

const clean = (value) => value.replace(/[^A-Za-z0-9+/=]/g, '');
const parts = files.map((file) => clean(fs.readFileSync(file, 'utf8')));
const sha256 = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');
const decode = (value) => Buffer.from(value, 'base64');

let encoded = parts.join('');
let binary = decode(encoded);

if (sha256(binary) !== expectedEncryptedSha256) {
  const prefix = parts.slice(0, 3).join('');
  const finalPart = parts[3];
  let recovered = null;

  // The GitHub text transport has introduced one extra Base64 character in the
  // final chunk. Recover only a candidate that reproduces the canonical
  // encrypted-runtime SHA-256. No unverified candidate is ever executed.
  for (let index = 0; index < finalPart.length; index += 1) {
    const candidate = prefix + finalPart.slice(0, index) + finalPart.slice(index + 1);
    if (candidate.length % 4 !== 0) continue;
    const decoded = decode(candidate);
    if (sha256(decoded) === expectedEncryptedSha256) {
      recovered = decoded;
      break;
    }
  }

  if (!recovered) {
    throw new Error('Unable to reconstruct verified encrypted TKS runtime payload');
  }
  binary = recovered;
}

if (sha256(binary) !== expectedEncryptedSha256) {
  throw new Error('Encrypted TKS runtime SHA-256 verification failed');
}

fs.writeFileSync(output, binary, { mode: 0o600 });
console.log('Encrypted TKS runtime transport verified.');
