package invoices

import (
	api "backend-api/api/utils"
	"backend-api/db"
	"fmt"
	"net/http"

	"github.com/lib/pq"
)

type manageInvoice struct {
	invoice
	Uid string `json:"uid"`
}

func CreateInvoice(w http.ResponseWriter, r *http.Request) {
	var invoice manageInvoice

	api.JsonDecode(r, &invoice)

	insertInvoice := `WITH inserted_invoice AS (
		INSERT INTO invoices (user_id, date_due, currency_code, description, price, status)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id as invoice_id
	)
	INSERT INTO invoice_address (first_name, last_name, address, country, city, client_email, zip_code, invoice_id, user_id)
	SELECT $7, $8, $9, $10, $11, $12, $13, invoice_id, $14
	FROM inserted_invoice
	RETURNING invoice_id`

	row := db.GetConnection().QueryRow(insertInvoice, invoice.Uid, api.DateToUTC(invoice.Date_due), invoice.Currency_code, invoice.Description,
		invoice.Price, invoice.Status, invoice.First_name, invoice.Last_name, invoice.Address,
		invoice.Country, invoice.City, invoice.Client_Email, invoice.Zip_Code, invoice.Uid)

	err := row.Scan(&invoice.Id)

	if err != nil {
		api.Resp(w, 500, err)
	}

	bulkInsert(invoice.Items, invoice.Id)

	if err != nil {
		api.Resp(w, 500, err)
	} else {
		api.Resp(w, 200, invoice)
	}

	api.Resp(w, 200, invoice)

}

func bulkInsert(invoiceItems []invoiceItem, invoice_id string) {
	insert, err := db.GetConnection().Begin()

	if err != nil {
		fmt.Println(err)
	}

	stmt, err := insert.Prepare(pq.CopyIn("invoice_items", "item_id", "invoice_id", "item_amount", "overcharge"))

	if err != nil {
		fmt.Println(err)
	}

	for _, item := range invoiceItems {
		_, err = stmt.Exec(item.Item_id, invoice_id, item.Item_amount, item.Overcharge)

		if err != nil {
			fmt.Println(err)
		}
	}

	a, err := stmt.Exec()

	fmt.Println(a)

	if err != nil {
		fmt.Println(err)
	}

	err = stmt.Close()

	if err != nil {
		fmt.Println(err)
	}

	err = insert.Commit()

	if err != nil {
		fmt.Println(err)
	}

}
