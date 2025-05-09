package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"
)

var requestCount int32

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		count := atomic.AddInt32(&requestCount, 1)
		fmt.Fprintf(w, "Hello from the self-destructing app! %d\n", count)

		if count > 5 {
			fmt.Println("Request limit exceed. Shutting down...")
			go func() {
				pid := os.Getegid()
				syscall.Kill(pid, syscall.SIGTERM)
			}()
		}
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "OK")
	})

	go func() {
		fmt.Println("Server is running on :80")
		if err := http.ListenAndServe(":80", nil); err != nil {
			fmt.Printf("Server error: %v\n", err)
		}
	}()

	// Handle termination signals
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	fmt.Println("Server stopped...")
}
