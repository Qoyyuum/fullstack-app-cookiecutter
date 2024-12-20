# Use an official Node runtime as the base image
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application for production
RUN npm run build

# Production image
FROM node:20-alpine

WORKDIR /app

# Copy package files and built app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install production dependencies only
RUN npm install --production

EXPOSE 3000

CMD ["npm", "start"]
