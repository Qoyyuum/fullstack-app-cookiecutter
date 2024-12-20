# Use Node.js as base image
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application files
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy built application
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.nuxt ./.nuxt
COPY --from=builder /app/.output ./.output
COPY --from=builder /app/node_modules ./node_modules

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
