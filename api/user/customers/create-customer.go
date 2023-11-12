package customers

import (
	api "backend-api/api/utils"
	"backend-api/db"
	"database/sql"
	"net/http"
)

type createCustomer struct {
	customer
	Uid string `json:"uid"`
}

func CreateCustomer(w http.ResponseWriter, r *http.Request) {
	var new_customer createCustomer

	api.JsonDecode(r, &new_customer)

	insertUser :=
		`INSERT INTO customers (user_id, first_name, last_name, ` +
			`address, country, city, client_email, zip_code, phone) ` +
			`VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id;`

	row := db.GetConnection().QueryRow(insertUser, new_customer.Uid, new_customer.First_name,
		new_customer.Last_name, new_customer.Address, new_customer.Country, new_customer.City, new_customer.Client_email, new_customer.Zip_code, new_customer.Phone)
	err := row.Scan(&new_customer.Id)

	if err != nil && err != sql.ErrNoRows {
		api.Resp(w, 500, err)
	} else {
		api.Resp(w, 200, new_customer)
	}

}
