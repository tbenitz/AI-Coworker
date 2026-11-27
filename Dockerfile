FROM node:22-bookworm-slim
WORKDIR /app
COPY index.html app.js engine.js server.js ./
RUN mkdir -p /app/data && chown -R node:node /app
USER node
ENV HOST=0.0.0.0 PORT=8080 DATA_DIR=/app/data
EXPOSE 8080
CMD ["node","server.js"]
