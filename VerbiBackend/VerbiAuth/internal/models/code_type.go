package models

type CodeType int

const (
	EmailConfirmation CodeType = iota + 1
	PasswordReset
)

func (ct CodeType) String() string {
	return [...]string{"EmailConfirmation", "PasswordReset"}[ct-1]
}

func (ct CodeType) EnumIndex() int {
	return int(ct)
}
