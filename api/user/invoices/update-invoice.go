package invoices

import (
	api "backend-api/api/utils"
	"backend-api/db"
	"fmt"
	"net/http"

	"github.com/lib/pq"
)

func UpdateInvoice(w http.ResponseWriter, r *http.Request) {
	var invoice manageInvoice

	api.JsonDecode(r, &invoice)

	updateInvoice :=
		`UPDATE invoices SET date_due = $1, currency_code = $2, 
			description = $3, status = $4, price = $5 
			WHERE id = $6 AND user_id = $7;
		`

	_, err := db.GetConnection().Exec(updateInvoice, invoice.Date_due, invoice.Currency_code,
		invoice.Description, invoice.Status, invoice.Price, invoice.Id, invoice.Uid)

	if err != nil {
		api.Resp(w, 500, err)
	}

	err = updateAddress(invoice)

	if err != nil {
		api.Resp(w, 500, err)
	}

	err = bulkUpdateItems(invoice.Items, invoice.Id)

	if err != nil {
		api.Resp(w, 500, err)
	}

	api.Resp(w, 200, invoice)
}

func updateAddress(invoice manageInvoice) error {
	u := `UPDATE invoice_address SET first_name = $1, last_name = $2, 
				address = $3, country = $4, city = $5, client_email = $6, zip_code = $7
			WHERE invoice_id = $8 AND user_id = $9`

	_, err := db.GetConnection().Exec(u, invoice.First_name,
		invoice.Last_name, invoice.Address, invoice.Country,
		invoice.City, invoice.Client_Email, invoice.Zip_Code, invoice.Id, invoice.Uid)

	return err
}

func bulkUpdateItems(items []invoiceItem, invoice_id string) error {
	update, err := db.GetConnection().Begin()

	if err != nil {
		fmt.Println(err)
	}

	_, err = update.Exec("DELETE FROM invoice_items WHERE invoice_id = $1", invoice_id)

	if err != nil {
		update.Rollback()
		fmt.Println(err)
	}

	stmt, err := update.Prepare(pq.CopyIn("invoice_items", "invoice_id", "item_id", "item_amount"))

	if err != nil {
		fmt.Println(err)
	}

	for _, item := range items {
		_, err = stmt.Exec(invoice_id, item.Item_id, item.Item_amount)

		if err != nil {
			fmt.Println(err)
		}
	}

	_, err = stmt.Exec()

	if err != nil {
		fmt.Println(err)
	}

	err = stmt.Close()

	if err != nil {
		fmt.Println(err)
	}

	err = update.Commit()

	return err
}
