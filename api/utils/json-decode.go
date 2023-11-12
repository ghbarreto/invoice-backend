package utils

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func JsonDecode(r *http.Request, data interface{}) {
	err := json.NewDecoder(r.Body).Decode(&data)

	if err != nil {
		fmt.Println("Error decoding JSON")
		panic(err)
	}
}
