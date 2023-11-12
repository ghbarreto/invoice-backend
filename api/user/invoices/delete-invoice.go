package invoices

import (
	api "backend-api/api/utils"
	"backend-api/db"
	"net/http"
)

type DelInvoice struct {
	Id  string `json:"id"`
	Uid string `json:"uid"`
}

func DeleteInvoice(w http.ResponseWriter, r *http.Request) {
	var invoice_to_delete DelInvoice

	api.JsonDecode(r, &invoice_to_delete)

	deleteInvoice := `UPDATE invoices SET is_visible = false
	WHERE id = $1 AND user_id = $2`

	_, err := db.GetConnection().Exec(deleteInvoice, invoice_to_delete.Id, invoice_to_delete.Uid)

	if err != nil {
		panic(err)
	}

	api.Resp(w, 200, "invoice deleted")
}
