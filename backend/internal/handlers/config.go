package handlers

import (
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"
)

// This Struct hold the glab dependencies.
type APIConfig struct {
	DB *pgxpool.Pool
}

// Method to register all the routes for the API.
func (cfg *APIConfig) RegisterRoutes(mux *http.ServeMux) {
	// All routes will be registered here
	mux.HandleFunc("GET/api/health", cfg.healthHandler)
}

// Health check handler for the API.
func (cfg *APIConfig) healthHandler(w http.ResponseWriter, r *http.Request) {
	// This is a simple health check endpoint that returns a JSON response indicating the API is healthy.
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}
