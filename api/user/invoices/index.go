package invoices

import (
	"net/http"
)

func InvoicesRoute(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetInvoices(w, r)
	case "POST":
		CreateInvoice(w, r)
	case "PUT":
		UpdateInvoice(w, r)
	case "DELETE":
		DeleteInvoice(w, r)
	}
}
