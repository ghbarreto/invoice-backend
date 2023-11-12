package utils

import (
	"fmt"
	"net/http"
	"regexp"
)

func GetParams(r *http.Request, regex string, w http.ResponseWriter) string {
	path := r.URL.Path
	fmt.Println(path)
	re := regexp.MustCompile(regex)
	matches := re.FindStringSubmatch(path)

	if len(matches) < 2 {
		Resp(w, 400, "error getting param")
		return "error"
	}

	return matches[1]
}
