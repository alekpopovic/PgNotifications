package main

import (
	"database/sql"
	"fmt"
	"os"
	"time"

	"github.com/lib/pq"
)

func startMonitoring() {
	dsn := os.Getenv("DB_DSN")
	//username := os.Getenv("DB_USER")
	//password := os.Getenv("DB_PASSWORD")
	//databaseName := os.Getenv("DB_NAME")
	//port := os.Getenv("DB_PORT")

	//dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Europe/Belgrade", host, username, password, databaseName, port)

	_, err := sql.Open("postgres", dsn)
	if err != nil {
		panic(err)
	}

	reportProblem := func(ev pq.ListenerEventType, err error) {
		if err != nil {
			fmt.Println(err.Error())
		}
	}

	listener := pq.NewListener(dsn, 10*time.Second, time.Minute, reportProblem)
	err = listener.Listen("events")
	if err != nil {
		panic(err)
	}

	fmt.Println("Start monitoring PostgreSQL...")
	for {
		waitForNotification(listener)
	}
}
