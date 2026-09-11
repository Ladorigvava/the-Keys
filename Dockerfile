FROM node:22-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl xz-utils gosu ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/tks
COPY start.sh /opt/tks/start.sh
RUN chmod 0555 /opt/tks/start.sh \
 && mkdir -p /app /data/runs /data/automations /data/state

ENV NODE_ENV=production
ENV TKS_RUNTIME_DIR=/data
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
 CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||8080)+'/healthz').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"

ENTRYPOINT ["/opt/tks/start.sh"]
