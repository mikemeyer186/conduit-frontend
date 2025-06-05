# Build stage
FROM node:20-slim AS build

ARG API_URL
ENV API_URL=$API_URL

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN cat > src/environments/environment.ts <<EOF
export const environment = {
  production: true,
  apiUrl: '${API_URL}'
};
EOF

# Run for development build (environment.development.ts will be used)
# RUN npm run build -- --configuration=development

# Run for production build (environment.ts will be used)
RUN npm run build


# Production stage
FROM nginx:1.28-alpine-slim

COPY --from=build /app/dist/angular-conduit /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]