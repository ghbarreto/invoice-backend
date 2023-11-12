package utils

import (
	"encoding/json"
	"fmt"
)

func ToJson(j interface{}) []byte {
	r, err := json.Marshal(j)

	if err != nil {
		fmt.Println("Error: ", err)
	}

	return r
}
