package items

import (
	"net/http"
)

func ItemsRoute(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetItems(w, r)
	case "POST":
		// CreateInvoice(w, r)
	case "PUT":
		// UpdateInvoice(w, r)
	case "DELETE":
		// DeleteInvoice(w, r)
	}
}
