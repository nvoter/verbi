package models

// Document data model
type Document struct {
	ID     uint   `gorm:"primaryKey" json:"id"`
	UserId uint   `gorm:"not null" json:"user_id"`
	Title  string `gorm:"not null" json:"title"`
	Path   string `gorm:"unique;not null" json:"path"`
}
