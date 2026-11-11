FROM golang:1.23-alpine

WORKDIR /app

# Install Air for hot-reloading
RUN go install github.com/air-verse/air@latest

# Copy go.mod and go.sum first to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Expose the API port
EXPOSE 8080

# Run Air instead of standard go run
CMD ["air", "-c", ".air.toml"]