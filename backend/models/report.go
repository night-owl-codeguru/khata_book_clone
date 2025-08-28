package models

type ReportSummary struct {
	Month       string             `json:"month"`
	TotalCredit float64            `json:"total_credit"`
	TotalDebit  float64            `json:"total_debit"`
	Balance     float64            `json:"balance"`
	ByCategory  map[string]float64 `json:"by_category,omitempty"`
	ByMethod    map[string]float64 `json:"by_method,omitempty"`
}

type DashboardSummary struct {
	TotalCredit   float64       `json:"total_credit"`
	TotalDebit    float64       `json:"total_debit"`
	Balance       float64       `json:"balance"`
	LatestEntries []LedgerEntry `json:"latest_entries"`
}
