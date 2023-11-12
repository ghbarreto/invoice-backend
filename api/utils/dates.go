package utils

import "time"

func DateToUTC(date string) time.Time {
	p, err := time.Parse(time.RFC3339, date)

	if err != nil {
		panic(err)
	}

	return p.In(time.UTC)
}
