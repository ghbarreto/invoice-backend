package invoices

import (
	"backend-api/db"
)

func getInvoiceItems(invoice_id string) []invoiceItem {
	var items []invoiceItem
	conn := db.GetConnection()

	query := `
		SELECT invoice_items.invoice_id, items.id as item_id, items.name, invoice_items.item_amount,  items.price, overcharge
			FROM invoice_items
			FULL JOIN items ON invoice_items.item_id = items.id
			WHERE invoice_items.invoice_id = $1
	`

	rows, err := conn.Query(query, invoice_id)

	if err != nil {
		panic(query)
	}

	for rows.Next() {
		var i invoiceItem

		err := rows.Scan(&i.Invoice_id, &i.Item_id, &i.Name, &i.Item_amount, &i.Price, &i.Overcharge)

		if err != nil {
			panic(err)
		}

		i.Total = float64(i.Item_amount) * i.Price
		i.Total += i.Overcharge

		items = append(items, i)
	}

	defer rows.Close()

	return items
}
