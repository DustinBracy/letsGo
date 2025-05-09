package data

import (
	"time"
)

type Movie struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"-"`
	Title     string    `json:"title"`
	Year      int32     `json:"year,omitempty"`    //prefer omitzero in go 1.24
	Runtime   Runtime   `json:"runtime,omitempty"` //prefer omitzero in go 1.24
	Genres    []string  `json:"genres,omitempty"`
	Version   int32     `json:"version"`
}
