# build source
FROM node:lts-alpine AS source
RUN npm install pnpm -g
COPY . .

WORKDIR /web
RUN sed -i "$ s/'https:\/\/sub.store'//g" .env.production
RUN pnpm install && pnpm build

WORKDIR /backend
RUN pnpm install && pnpm build

# service
FROM node:lts-alpine
WORKDIR /app
VOLUME /data

RUN apk update && apk add nginx

COPY --from=source /web/dist /usr/share/nginx/html

COPY --from=source /backend/sub-store.min.js /app

COPY --from=source /backend/node_modules /app/node_modules

COPY nginx.conf /etc/nginx/http.d/default.conf

CMD nginx && node sub-store.min.js

EXPOSE 80
