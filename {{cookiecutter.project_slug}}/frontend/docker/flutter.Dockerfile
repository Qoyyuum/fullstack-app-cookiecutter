# Use the official Dart SDK image as the base image
FROM dart:stable AS builder

# Set the working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Build for web
RUN flutter build web

# Production stage
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
