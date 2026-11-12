package main

import (
	"backend/internal/database"
	"log"
	"net/http"
)

func main() {
	// Initialize the database connection
	dbPool, err := database.NewDB()
	if err != nil {
		log.Fatalf("Fatal error connecting to database: %v", err)
	}
	defer dbPool.Close()

	// Initialize the Std Library router
	mux := http.NewServeMux()

	// Register Routes
	mux.HandleFunc("GET /api/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy", "database":"connected"}`))
	})

	// Start the HTTP server
	port := ":8080"
	log.Printf("Starting Go Backend on http://localhost%s...\n", port)
	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatalf("Server crashed: %v", err)
	}
}
