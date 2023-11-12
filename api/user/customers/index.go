// SELECT c.id, c.first_name, invoices.price from customers as c
// INNER JOIN invoices  ON c.id = invoices.customer_id
// WHERE invoices.user_id = 'sZq0R42xeSgSS4V9yK48GC4l0WD3'

package customers

import "net/http"

func CustomersRoute(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetCustomers(w, r)
	case "POST":
		CreateCustomer(w, r)
	case "PUT":
		UpdateCustomer(w, r)
	case "DELETE":
		DeleteCustomer(w, r)
	}

}
