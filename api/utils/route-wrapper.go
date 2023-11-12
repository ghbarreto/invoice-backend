package utils

import (
	"backend-api/auth"
	"net/http"

	"github.com/rs/cors"
)

func Routes(endpoint string, r func(http.ResponseWriter, *http.Request)) {
	allowedOrigins := []string{"http://localhost:3000"}
	c := cors.New(
		cors.Options{
			AllowedOrigins:   allowedOrigins,
			AllowedMethods:   []string{"GET", "POST", "OPTIONS", "PUT", "DELETE"},
			AllowedHeaders:   []string{"Authorization", "Content-Type"},
			AllowCredentials: true,
			Debug:            true,
		},
	)
	http.Handle("/api/"+endpoint, c.Handler(auth.Auth(http.HandlerFunc(r))))
}
