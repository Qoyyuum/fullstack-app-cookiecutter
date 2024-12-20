# Use Node.js as base image
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Install Quasar CLI
RUN npm install -g @quasar/cli

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application files
COPY . .

# Build application
RUN quasar build -m ssr

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist/ssr ./
COPY --from=builder /app/package*.json ./
RUN npm install --production

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000

CMD ["node", "index.js"]
