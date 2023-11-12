package env

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

func Env(api_key string) string {
	if api_key == "" {
		fmt.Println("API Key is not set")

	}

	err := godotenv.Load()

	if err != nil {
		log.Fatal(".env file could not be loaded")
	}

	return os.Getenv(api_key)
}
