{% if cookiecutter.tech_choice.separate.backend == "django" %}
{% include "docker/django.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.backend == "laravel" %}
{% include "docker/laravel.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.backend == "nextjs" %}
{% include "docker/next.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.backend == "nuxtjs" %}
{% include "docker/nuxt.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.backend == "quasar_ssr" %}
{% include "docker/quasar-ssr.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_stack_backend == "Node.js/Express" %}
# Use an official Node runtime as the base image
FROM node:16-alpine

# Set the working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Start the application
CMD ["npm", "start"]
{% endif %}

{% if cookiecutter.tech_stack_backend == "Django" %}
# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev libpq-dev

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Start the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
{% endif %}

{% if cookiecutter.tech_stack_backend == "FastAPI" %}
# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Start the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
{% endif %}
