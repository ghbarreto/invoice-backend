package utils

import (
	"encoding/json"
	"net/http"
)

type Response struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Status  int         `json:"status"`
}

func Resp(w http.ResponseWriter, status int, data interface{}) {
	var message string

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if status == 200 {
		message = "success"
	} else if status == 400 {
		message = "bad request"
	} else if status == 404 {
		message = "not found"
	} else if status == 500 {
		message = "internal server error"
	}

	response := Response{
		Message: message,
		Data:    data,
		Status:  status,
	}

	json.NewEncoder(w).Encode(response)
}
