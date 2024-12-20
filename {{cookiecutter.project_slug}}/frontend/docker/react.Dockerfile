# Use an official Node runtime as the base image
FROM node:20-alpine as builder

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

# Production stage
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
