package db

import (
	env "backend-api/config"
	"database/sql"
	"fmt"
	"strconv"

	_ "github.com/lib/pq"
)

var dbConn *sql.DB

func Init() {
	dbConn = Db()
}

func Db() *sql.DB {
	var (
		DB_HOST     = env.Env("DB_HOST")
		DB_PORT     = env.Env("DB_PORT")
		DB_USERNAME = env.Env("DB_USERNAME")
		DB_PASSWORD = env.Env("DB_PASSWORD")
		DB_NAME     = env.Env("DB_NAME")
	)

	db_port, err := strconv.ParseInt(DB_PORT, 10, 64)

	if err != nil {
		panic(err)
	}

	psql_conn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		DB_HOST, db_port, DB_USERNAME, DB_PASSWORD, DB_NAME)

	db, err := sql.Open("postgres", psql_conn)

	if err != nil {
		fmt.Println(err)
	}

	err = db.Ping()
	if err != nil {
		panic(err)
	}

	return db
}

func GetConnection() *sql.DB {
	return dbConn
}
