package main

import (
	"backend/internal/database"
	"backend/internal/handlers"
	"log"
	"net/http"
)

func main() {
	// 1. Connect to the database
	dbPool, err := database.NewDB()
	if err != nil {
		log.Fatalf("Fatal error connecting to database: %v", err)
	}
	defer dbPool.Close()

	// 2. Setup Application Config
	app := &handlers.APIConfig{
		DB: dbPool,
	}

	// 3. Create a Traffic Cop for the API Routes
	mux := http.NewServeMux()

	// 4. Register all the routes for the API
	app.RegisterRoutes(mux)

	// 5. Start the HTTP server
	port := ":8080"
	log.Printf("Starting Go Backend on http://localhost%s...\n", port)
	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatalf("Server crashed: %v", err)
	}
}
