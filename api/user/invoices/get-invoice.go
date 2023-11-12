package invoices

import (
	api "backend-api/api/utils"
	"backend-api/auth"
	"backend-api/db"
	"fmt"
	"net/http"
)

func GetInvoice(w http.ResponseWriter, r *http.Request) {
	match := api.GetParams(r, `/api/invoice/([a-zA-Z0-9]+)`, w)

	if match == "error" {
		return
	}

	uid := r.Context().Value(auth.UidContextKey).(string)

	var invoice invoices_get

	conn := db.GetConnection()

	query := conn.QueryRow(GET_INVOICE+" AND invoices.id = $2", uid, match)

	err := query.Scan(&invoice.Id, &invoice.Created_at, &invoice.Date_due,
		&invoice.Currency_code,
		&invoice.Description, &invoice.Status,
		&invoice.First_name, &invoice.Last_name, &invoice.Price, &invoice.Address,
		&invoice.Country, &invoice.City, &invoice.Client_Email, &invoice.Zip_Code, &invoice.Business.Address, &invoice.Business.City,
		&invoice.Business.Country, &invoice.Business.Zip)

	if invoice.Id == "" {
		api.Resp(w, 400, "There is no invoice with this id")
		return
	}

	invoice.Items = getInvoiceItems(invoice.Id)

	for _, items := range invoice.Items {
		invoice.Total += items.Total
	}

	if err != nil {
		fmt.Println(err)
		api.Resp(w, 400, "error")
		return
	}

	api.Resp(w, 200, invoice)
}
