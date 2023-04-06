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
		listenNotifications(listener)
	}
}
