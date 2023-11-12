package items

import (
	api "backend-api/api/utils"
	"backend-api/auth"
	"backend-api/db"
	"fmt"
	"net/http"
)

type Items struct {
	Id           string  `json:"id"`
	Name         string  `json:"name"`
	Price        float64 `json:"price"`
	Stock_amount float64 `json:"stock_amount"`
}

func GetItems(w http.ResponseWriter, r *http.Request) {
	uid := r.Context().Value(auth.UidContextKey).(string)

	var items []Items

	conn := db.GetConnection()

	query, err := conn.Query("SELECT id, name, price, stock_amount from items where user_id = $1", uid)

	if err != nil {
		fmt.Println(err)
		api.Resp(w, 400, "error")
		return
	}

	for query.Next() {
		var item Items
		err := query.Scan(&item.Id, &item.Name, &item.Price, &item.Stock_amount)

		if err != nil {
			fmt.Println(err)
			api.Resp(w, 400, "error")
			return
		}

		items = append(items, item)
	}

	api.Resp(w, 200, items)
}
