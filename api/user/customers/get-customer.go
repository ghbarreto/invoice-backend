package customers

import (
	api "backend-api/api/utils"
	"backend-api/auth"
	"backend-api/db"
	"net/http"
)

func GetCustomer(w http.ResponseWriter, r *http.Request) {
	params := api.GetParams(r, `/api/customer/(.+)`, w)

	if params == "error" {
		return
	}

	uid := r.Context().Value(auth.UidContextKey).(string)

	var c customer

	conn := db.GetConnection()

	query := conn.QueryRow(GET_CUSTOMER+" AND customers.id = $2", uid, params)

	query.Scan(&c.Id, &c.First_name, &c.Last_name, &c.Address, &c.Country, &c.City, &c.Client_email, &c.Zip_code, &c.Phone)

	if c.Id == "" {
		api.Resp(w, 400, "There is no customer with this id")
		return
	}

	api.Resp(w, 200, c)
}
