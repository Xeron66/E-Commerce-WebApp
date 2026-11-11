FROM node:20-alpine

WORKDIR /app

# Copy package files for dependency caching
COPY package.json package-lock.json* ./
RUN npm install

# Copy all frontend files
COPY . .

# Expose the Next.js port
EXPOSE 3000

# Start the Next.js development server
CMD ["npm", "run", "dev"]