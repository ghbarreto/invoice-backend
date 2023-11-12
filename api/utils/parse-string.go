package utils

import "github.com/gofrs/uuid"

func ToUuid(s string) uuid.UUID {
	newStr := uuid.Must(uuid.FromString(s))

	return newStr
}
