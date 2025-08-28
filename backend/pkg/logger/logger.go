package logger

import (
	"os"

	log "github.com/sirupsen/logrus"
)

func init() {
	// Use JSON formatter for structured logs in production-like environments
	log.SetFormatter(&log.JSONFormatter{})

	// Output to stdout (compatible with most container platforms)
	log.SetOutput(os.Stdout)

	// Default level
	log.SetLevel(log.InfoLevel)
}

// L exports the package logger for import convenience
var L = log.StandardLogger()
