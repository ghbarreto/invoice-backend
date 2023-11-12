package main

import (
	r "backend-api/api/user"
	c "backend-api/api/user/customers"
	i "backend-api/api/user/invoices"
	items "backend-api/api/user/items"
	utils "backend-api/api/utils"
	"backend-api/db"
	"net/http"
)

func main() {
	db.Init()

	// TODO very important: fix every connection pool to use the connection returned by GetConnection()
	// customers wrapper
	utils.Routes("customers", c.CustomersRoute)
	utils.Routes("customer/", c.GetCustomer)

	// invoice wrapper
	utils.Routes("invoices", i.InvoicesRoute)
	utils.Routes("invoice/", i.GetInvoice)

	// user wrapper
	utils.Routes("credentials", r.Registration)

	// items
	utils.Routes("items", items.ItemsRoute)

	http.ListenAndServe(":8080", nil)
}
