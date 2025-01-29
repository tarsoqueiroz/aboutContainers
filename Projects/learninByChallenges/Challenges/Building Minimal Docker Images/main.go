package main

import (
	"fmt"
	"net/http"
	"runtime"
)

func handleIndex(w http.ResponseWriter, r *http.Request) {
	strMessage := "Minimal HTTP Server in GO!!!"

	fmt.Println(strMessage)
	fmt.Fprint(w, strMessage)
}

func handlePing(w http.ResponseWriter, r *http.Request) {
	strMessage := "Pong"

	fmt.Println(strMessage)
	fmt.Fprint(w, strMessage)
}

func handleVersion(w http.ResponseWriter, r *http.Request) {
	strMessage := fmt.Sprintf("Version: server 1.0 / runtime: %v", runtime.Version())

	fmt.Println(strMessage)
	fmt.Fprint(w, strMessage)
}

func main() {
	http.HandleFunc("/", handleIndex)
	http.HandleFunc("/ping", handlePing)
	http.HandleFunc("/version", handleVersion)

	fmt.Println("Listening on :8910")
	http.ListenAndServe(":8910", nil)
}
