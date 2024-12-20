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

{% if cookiecutter.tech_choice.separate.frontend == "react" %}
{% include "docker/react.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.frontend == "vue" %}
{% include "docker/vue.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.frontend == "quasar" %}
{% include "docker/quasar.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.frontend == "nextjs" %}
{% include "docker/next.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.frontend == "nuxtjs" %}
{% include "docker/nuxt.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.frontend == "flutter" %}
{% include "docker/flutter.Dockerfile" %}
{% endif %}

{% if cookiecutter.tech_choice.separate.frontend == "hono" %}
{% include "docker/hono.Dockerfile" %}
{% endif %}
