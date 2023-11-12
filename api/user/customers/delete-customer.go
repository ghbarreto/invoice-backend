package customers

import (
	api "backend-api/api/utils"
	"backend-api/db"
	"net/http"
)

type deleteCustomer struct {
	customer
	Uid string `json:"uid"`
}

func DeleteCustomer(w http.ResponseWriter, r *http.Request) {
	var customer deleteCustomer

	api.JsonDecode(r, &customer)

	rw, err := db.GetConnection().Exec(`DELETE FROM customers WHERE id = $1 AND user_id = $2`, customer.Id, customer.Uid)

	if err != nil {
		api.Resp(w, 500, err)
	}

	rows, err := rw.RowsAffected()

	if rows == 0 {
		api.Resp(w, 500, "customer not found")
		return
	}

	if err != nil {
		api.Resp(w, 500, err)
	} else {
		api.Resp(w, 200, "customer deleted")
	}
}
