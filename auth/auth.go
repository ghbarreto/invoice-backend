package auth

import (
	"context"
	"fmt"
	"net/http"
	"strings"

	firebase "firebase.google.com/go"
	"google.golang.org/api/option"
)

type contextKey string

const UidContextKey contextKey = "uid"

func Auth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, app := firebaseContext(w)

		authClient, err := app.Auth(ctx)

		if err != nil {
			fmt.Println(err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		token := verifyTokenIsPresent(w, r)[1]

		user, err := authClient.VerifyIDToken(ctx, token)
		if err != nil {
			http.Error(w, "Unauthorized idtoken", http.StatusUnauthorized)
			return
		}

		addCtx := context.WithValue(r.Context(), UidContextKey, user.UID)

		next.ServeHTTP(w, r.WithContext(addCtx))
	}
}

func firebaseContext(w http.ResponseWriter) (context.Context, *firebase.App) {
	ctx := context.Background()

	opt := option.WithCredentialsFile("service_account.json")
	app, err := firebase.NewApp(ctx, nil, opt)

	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}

	return ctx, app
}

func verifyTokenIsPresent(w http.ResponseWriter, r *http.Request) []string {
	authHeader := r.Header.Get("Authorization")

	if authHeader == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
	}

	tokenParts := strings.Split(authHeader, " ")
	if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
		http.Error(w, "Unauthorized token", http.StatusUnauthorized)
	}

	return tokenParts
}
