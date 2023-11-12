package customers

import "net/http"

func UpdateCustomer(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("updating customer"))
}
