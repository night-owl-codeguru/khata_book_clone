# 1) Product Context

**Goal**
A digital ledger to record credits/debits per customer, track dues, send reminders, and view reports.

**Primary users**
Shopkeepers, freelancers, micro-business owners who want a simple, trustworthy, bilingual ledger.

**Non-goals**
No payment processing in v1; focus on record-keeping, reminders, and clear summaries.

**Platforms**
Flutter mobile (iOS/Android). Supabase Auth + Database. Resend for email reminders (optional), SMS/WhatsApp via provider configured in backend later.

---

# 2) Design System

**Color tokens**

* `primary/500: #2962FF` (actions, active elements)
* `primary/600: #204EE6` (pressed)
* `primary/gradient: linear( #3B82F6 → #1D4ED8 )`
* `text/primary: #111827`
* `text/secondary: #6B7280`
* `danger/500: #EF4444`
* `success/500: #10B981`
* `surface: #FFFFFF`
* `surface/alt: #F5F7FB`
* `border: #E5E7EB`
* `shadow: rgba(17,24,39,0.08)`

**Typography (example)**

* Headline: 22/28, semi-bold
* Title: 18/24, semi-bold
* Body: 14/20, regular
* Caption: 12/16, medium

**Shape & elevation**

* Radius: 16 for cards and buttons; inputs 12
* Shadows: subtle, y=6, blur=16 on floating buttons/cards

**Iconography**

* Outline icons; duotone where needed
* Credit = arrow-down-left (green), Debit = arrow-up-right (red)

**Controls**

* Primary button: filled, gradient, white text
* Secondary: outline with primary border
* Input: filled surface, 1px border, focus ring primary/500

**Motion**

* Page transition: 200–250ms slide-in
* Button press: 150ms scale 0.98
* Error shake (invalid login/add): 250ms horizontal shake

**Accessibility**

* Minimum contrast 4.5:1
* Hit target ≥ 44×44
* Support dynamic text sizes
* VoiceOver/ TalkBack labels on icons and charts

**Internationalization**

* String keys with English/Hinglish baseline
* Currency symbol and number formatting via locale
* Date formatting via locale

---

# 3) Information Architecture & Navigation

**Bottom navigation (persistent)**

* Home (Dashboard)
* Add (Center FAB + selector)
* Reminders (Notifications)
* Customers

**Secondary navigation**

* Stack push to: Ledger Summary, Entries, Customer Detail, Add Credit/Debit, Reports, Settings

**Top-level flows**

* Onboarding → Auth
* Daily: Home → Add Credit/Debit → Customer Detail
* Collections: Reminders → Send reminder → Mark paid
* Insights: Reports → Month filter → Export

---

# 4) Data Model (for alignment with UI)

* `Customer { id, name, phone?, note?, createdAt, balance }`
* `LedgerEntry { id, customerId, type: "credit"|"debit", amount, method: "cash"|"upi"|"bank", note?, date, createdAt }`
* `Reminder { id, customerId, dueAmount, dueDate, channel: "sms"|"whatsapp"|"email", status: "pending"|"sent"|"snoozed"|"paid" }`
* `ReportSummary { month, totalCredit, totalDebit, balance, byCategory?, byMethod? }`
* `UserProfile { id, businessName, ownerName, locale, currency, theme }`

---

# 5) Page-by-Page Specifications

## 5.1 Onboarding

**Purpose**
Explain value, choose language, lead to authentication.

**Layout**

* App logo header
* 3 slides with illustration + title + subtitle

  1. Record credits and debits
  2. Send reminders and track dues
  3. Get monthly reports
* Pagination dots
* Primary CTA: Continue
* Secondary: Choose Language

**States**

* First install, returning user (skip to Home if session exists)

## 5.2 Authentication (Login)

**Purpose**
Sign in with phone/email via Supabase.

**Layout & behavior**

* Inputs: phone or email, password; show/hide password
* Primary CTA: Login
* Secondary CTAs: Continue with Google, Continue with Apple
* Links: Forgot password, Register
* Error banner on invalid credentials (danger color)

**States**

* Empty, Focused, Filled, Error, Loading

## 5.3 Dashboard (Home)

**Purpose**
Quick financial snapshot and recent activity.

**Layout**

* Greeting with business name
* Summary cards: Total Credit, Total Debit, Balance (Balance highlighted)
* Quick actions: Add Customer, Reminders, Reports
* Latest entries list (credit green badge, debit red badge)
* Center FAB in bottom bar for Add

**Empty state**

* Message: No entries yet. Add your first credit or debit.
* CTA: Add Entry

## 5.4 Ledger Summary (Analytics Light)

**Purpose**
Month view and breakdown by type.

**Layout**

* Month picker (month/year scroller)
* Big total circle for month balance
* Tabs: Credits | Debits
* Each tab: dated list; footer with totals
* Secondary button to open Reports

**States**

* No data for month → "No entries recorded in this period."

## 5.5 Add Entry Selector

**Purpose**
Fast choice between Credit and Debit.

**Layout**

* Two large segmented cards: Add Credit, Add Debit
* Recent entries inline for context

## 5.6 Add Credit

**Purpose**
Create a credit entry.

**Form fields**

* Customer (typeahead; create new if not found)
* Amount (₹, numeric)
* Payment Method (Cash, UPI, Bank)
* Date (default today)
* Note (optional)

**Validation**

* Customer required, amount > 0

**CTA**

* Save Credit (sticky bottom button)

**Post-save**

* Snackbar "Credit saved", navigate to Customer Detail

## 5.7 Add Debit

Same as Add Credit; CTA "Save Debit". If debit exceeds current customer credit, show soft warning.

## 5.8 Entries (All Transactions)

**Purpose**
Search and filter the full ledger.

**Layout**

* Search bar (customer name)
* Filters: Type, Date range, Method
* Grouped list by day
* Bulk actions (future): export/share

**Empty/No results**

* Refine filters message

## 5.9 Customers

**Purpose**
Directory and balances.

**Layout**

* Search + Add Customer button
* Customer cards: name, phone (if any), net balance chip (positive = they owe you; negative = you owe them)
* Tap → Customer Detail

**Add Customer modal**

* Name, phone (optional), note

## 5.10 Customer Detail (Individual Ledger)

**Purpose**
Focused view per customer.

**Layout**

* Header: customer name, phone actions
* Balance pill: Net due
* Quick actions: Add Credit, Add Debit, Send Reminder
* Timeline of entries for this customer
* Settle/Mark Paid flow: creates balancing entry or marks reminder paid

**States**

* New customer with no entries → prompt to add first entry

## 5.11 Reminders

**Purpose**
Track pending dues and send nudges.

**Layout**

* Tabs: Pending | Sent | Paid
* Row: customer, due amount, due date, last reminder status
* Row actions: Send via SMS/WhatsApp/Email, Snooze, Mark Paid
* Compose modal: pre-filled template with variables {customerName}, {amount}, {businessName}

## 5.12 Reports

**Purpose**
Month/quarter summaries and trends.

**Layout**

* Period selector
* Totals: Credit, Debit, Balance
* Charts: Credit vs Debit over time; breakdown by payment method
* Insights box: simple rules-based copy
* Export button: CSV/PDF (link for future)

## 5.13 Settings

**Purpose**
Business profile, language, backup, security.

**Sections**

* Profile: business name, owner name
* Preferences: language, currency
* Data: backup/restore
* Security: PIN/Biometric
* About: version, terms

---

# 6) Unified JSON UI Spec

This single schema describes theme, navigation, components, and every screen. Your Flutter agent can map to widgets (e.g., PageView, TabBar, ListView, Charts). Paths are placeholders.

```json
{
  "app": {
    "name": "LedgerBook",
    "locale": "en_IN",
    "currency": "INR",
    "theme": {
      "colors": {
        "primary": "#2962FF",
        "primaryPressed": "#204EE6",
        "textPrimary": "#111827",
        "textSecondary": "#6B7280",
        "danger": "#EF4444",
        "success": "#10B981",
        "surface": "#FFFFFF",
        "surfaceAlt": "#F5F7FB",
        "border": "#E5E7EB",
        "shadow": "rgba(17,24,39,0.08)"
      },
      "shape": { "radiusLg": 16, "radiusMd": 12 },
      "typography": {
        "headline": { "size": 22, "weight": "600", "lineHeight": 28 },
        "title": { "size": 18, "weight": "600", "lineHeight": 24 },
        "body": { "size": 14, "weight": "400", "lineHeight": 20 },
        "caption": { "size": 12, "weight": "500", "lineHeight": 16 }
      }
    },
    "navigation": {
      "bottomTabs": [
        { "id": "home", "label": "Home", "icon": "assets/icons/home.png" },
        { "id": "add", "label": "Add", "icon": "assets/icons/add_fab.png", "isFab": true },
        { "id": "reminders", "label": "Reminders", "icon": "assets/icons/bell.png" },
        { "id": "customers", "label": "Customers", "icon": "assets/icons/users.png" }
      ],
      "initialRoute": "onboarding"
    },
    "components": {
      "buttonPrimary": {
        "bg": "#2962FF",
        "textColor": "#FFFFFF",
        "gradient": ["#3B82F6", "#1D4ED8"],
        "radius": 16,
        "shadow": true
      },
      "textField": {
        "radius": 12,
        "borderColor": "#E5E7EB",
        "focusColor": "#2962FF",
        "iconColor": "#6B7280"
      },
      "entryListItem": {
        "icon": "assets/icons/entry.png",
        "showMethod": true,
        "showDate": true,
        "amountPositiveColor": "#10B981",
        "amountNegativeColor": "#EF4444"
      }
    },
    "screens": [
      {
        "id": "onboarding",
        "type": "carousel",
        "logo": "assets/images/logo.png",
        "slides": [
          {
            "illustration": "assets/illust/ledger1.png",
            "title": "Record Credits & Debits",
            "subtitle": "One-tap entries for every customer."
          },
          {
            "illustration": "assets/illust/ledger2.png",
            "title": "Send Reminders",
            "subtitle": "Track dues and nudge customers on time."
          },
          {
            "illustration": "assets/illust/ledger3.png",
            "title": "View Clear Reports",
            "subtitle": "Understand your month at a glance."
          }
        ],
        "primaryCta": { "text": "Continue", "action": "route:auth_login" },
        "secondaryCta": { "text": "Choose Language", "action": "route:settings_language" }
      },
      {
        "id": "auth_login",
        "type": "form",
        "title": "Login",
        "fields": [
          { "key": "identifier", "label": "Phone or Email", "placeholder": "Enter phone or email", "inputType": "text", "leadingIcon": "assets/icons/user.png" },
          { "key": "password", "label": "Password", "placeholder": "********", "inputType": "password", "leadingIcon": "assets/icons/lock.png", "trailingIcon": "assets/icons/eye.png", "toggleVisibility": true }
        ],
        "primaryCta": { "text": "Login", "action": "auth:login" },
        "secondary": [
          { "text": "Forgot Password", "action": "route:auth_forgot" },
          { "text": "Continue with Google", "action": "auth:google", "variant": "outline", "icon": "assets/icons/google.png" },
          { "text": "Continue with Apple", "action": "auth:apple", "variant": "outline", "icon": "assets/icons/apple.png" },
          { "text": "Register", "action": "route:auth_register", "variant": "link" }
        ],
        "errorBanner": { "visible": false, "text": "" }
      },
      {
        "id": "home_dashboard",
        "type": "dashboard",
        "appBar": { "title": "Dashboard", "rightIcon": "assets/icons/settings.png", "action": "route:settings" },
        "summaryCards": [
          { "title": "Total Credit", "value": "₹12,000", "icon": "assets/icons/credit.png" },
          { "title": "Total Debit", "value": "₹8,400", "icon": "assets/icons/debit.png" },
          { "title": "Balance", "value": "₹3,600", "highlight": true, "icon": "assets/icons/balance.png" }
        ],
        "quickActions": [
          { "title": "Add Customer", "icon": "assets/icons/user_add.png", "action": "dialog:add_customer" },
          { "title": "Reminders", "icon": "assets/icons/bell.png", "action": "route:reminders" },
          { "title": "Reports", "icon": "assets/icons/report.png", "action": "route:reports" }
        ],
        "latestEntries": {
          "emptyMessage": "No entries yet. Add your first credit or debit.",
          "items": [
            { "id": "e1", "customer": "Ramesh Traders", "date": "2024-08-20", "type": "credit", "amount": 2000, "method": "cash" },
            { "id": "e2", "customer": "Mohan Kirana", "date": "2024-08-19", "type": "debit", "amount": 500, "method": "upi" },
            { "id": "e3", "customer": "Sita Textiles", "date": "2024-08-18", "type": "credit", "amount": 1200, "method": "bank" }
          ]
        },
        "bottomNavActive": "home"
      },
      {
        "id": "ledger_summary",
        "type": "analytics_light",
        "title": "Ledger Summary",
        "dateSelector": { "month": 8, "year": 2024 },
        "bigNumber": { "label": "This Month Balance", "value": "₹3,600" },
        "tabs": [
          {
            "name": "Credits",
            "list": [
              { "customer": "Ramesh Traders", "date": "2024-08-20", "amount": 2000, "method": "cash" },
              { "customer": "Sita Textiles", "date": "2024-08-18", "amount": 1200, "method": "bank" }
            ],
            "total": 3200
          },
          {
            "name": "Debits",
            "list": [
              { "customer": "Mohan Kirana", "date": "2024-08-19", "amount": 500, "method": "upi" },
              { "customer": "Anand Dairy", "date": "2024-08-15", "amount": 800, "method": "cash" }
            ],
            "total": 1300
          }
        ],
        "footerAction": { "text": "Open Reports", "action": "route:reports" },
        "bottomNavActive": "home"
      },
      {
        "id": "add_selector",
        "type": "choice",
        "title": "Add Entry",
        "choices": [
          { "title": "Add Credit", "icon": "assets/icons/credit.png", "action": "route:add_credit", "highlight": true },
          { "title": "Add Debit", "icon": "assets/icons/debit.png", "action": "route:add_debit" }
        ],
        "recent": [
          { "customer": "Mohan Kirana", "date": "2024-08-19", "type": "debit", "amount": 500 },
          { "customer": "Ramesh Traders", "date": "2024-08-20", "type": "credit", "amount": 2000 }
        ],
        "bottomNavActive": "add"
      },
      {
        "id": "add_credit",
        "type": "form",
        "title": "Add Credit",
        "fields": [
          { "key": "customer", "label": "Customer", "placeholder": "Search or add customer", "inputType": "searchSelect", "creatable": true },
          { "key": "amount", "label": "Amount (₹)", "placeholder": "0", "inputType": "currency" },
          { "key": "method", "label": "Payment Method", "inputType": "segmented", "options": ["cash", "upi", "bank"] },
          { "key": "date", "label": "Date", "inputType": "date", "default": "today" },
          { "key": "note", "label": "Note", "placeholder": "Optional", "inputType": "text" }
        ],
        "primaryCta": { "text": "Save Credit", "action": "entry:create_credit" },
        "validation": {
          "required": ["customer", "amount", "method", "date"],
          "min": { "amount": 1 }
        }
      },
      {
        "id": "add_debit",
        "type": "form",
        "title": "Add Debit",
        "fields": [
          { "key": "customer", "label": "Customer", "placeholder": "Search or add customer", "inputType": "searchSelect", "creatable": true },
          { "key": "amount", "label": "Amount (₹)", "placeholder": "0", "inputType": "currency" },
          { "key": "method", "label": "Payment Method", "inputType": "segmented", "options": ["cash", "upi", "bank"] },
          { "key": "date", "label": "Date", "inputType": "date", "default": "today" },
          { "key": "note", "label": "Note", "placeholder": "Optional", "inputType": "text" }
        ],
        "primaryCta": { "text": "Save Debit", "action": "entry:create_debit" },
        "validation": {
          "required": ["customer", "amount", "method", "date"],
          "min": { "amount": 1 },
          "warnings": ["amount_exceeds_credit"]
        }
      },
      {
        "id": "entries",
        "type": "list",
        "title": "All Entries",
        "search": { "placeholder": "Search customer" },
        "filters": {
          "type": ["all", "credit", "debit"],
          "method": ["all", "cash", "upi", "bank"],
          "dateRange": { "from": null, "to": null }
        },
        "items": [],
        "emptyMessage": "No entries match your filters."
      },
      {
        "id": "customers",
        "type": "directory",
        "title": "Customers",
        "search": { "placeholder": "Search customers" },
        "actions": [{ "text": "Add Customer", "action": "dialog:add_customer", "variant": "primary" }],
        "items": [
          { "id": "c1", "name": "Ramesh Traders", "phone": "9876543210", "balance": 3200 },
          { "id": "c2", "name": "Mohan Kirana", "phone": "9876501234", "balance": -500 }
        ]
      },
      {
        "id": "customer_detail",
        "type": "detail",
        "title": "Customer",
        "header": {
          "name": "Ramesh Traders",
          "phone": "9876543210",
          "balance": 3200
        },
        "quickActions": [
          { "title": "Add Credit", "action": "route:add_credit" },
          { "title": "Add Debit", "action": "route:add_debit" },
          { "title": "Send Reminder", "action": "reminder:compose" }
        ],
        "timeline": [
          { "id": "e10", "type": "credit", "amount": 2000, "date": "2024-08-20", "method": "cash", "note": "" },
          { "id": "e09", "type": "debit", "amount": 300, "date": "2024-08-18", "method": "upi", "note": "Partial" }
        ]
      },
      {
        "id": "reminders",
        "type": "reminders",
        "title": "Reminders",
        "tabs": [
          {
            "name": "Pending",
            "rows": [
              { "id": "r1", "customer": "Mohan Kirana", "dueAmount": 500, "dueDate": "2024-08-25", "channel": "whatsapp", "status": "pending" }
            ]
          },
          { "name": "Sent", "rows": [] },
          { "name": "Paid", "rows": [] }
        ],
        "rowActions": [
          { "title": "Send", "action": "reminder:send" },
          { "title": "Snooze", "action": "reminder:snooze" },
          { "title": "Mark Paid", "action": "reminder:mark_paid" }
        ]
      },
      {
        "id": "reports",
        "type": "reports",
        "title": "Reports",
        "period": { "type": "month", "month": 8, "year": 2024 },
        "totals": { "credit": 12000, "debit": 8400, "balance": 3600 },
        "charts": [
          { "kind": "line", "series": ["credit", "debit"], "x": "date" },
          { "kind": "pie", "series": "methodBreakdown" }
        ],
        "insights": [
          "Collections improved 18% vs last month.",
          "UPI accounts for 62% of transactions."
        ],
        "actions": [{ "text": "Export CSV", "action": "export:csv" }]
      },
      {
        "id": "settings",
        "type": "settings",
        "title": "Settings",
        "sections": [
          {
            "name": "Profile",
            "items": [
              { "key": "businessName", "label": "Business Name", "value": "Shree Ram Stores" },
              { "key": "ownerName", "label": "Owner Name", "value": "Jay Patel" }
            ]
          },
          {
            "name": "Preferences",
            "items": [
              { "key": "language", "label": "Language", "value": "English (India)", "action": "route:settings_language" },
              { "key": "currency", "label": "Currency", "value": "INR" }
            ]
          },
          {
            "name": "Security",
            "items": [
              { "key": "pin", "label": "App PIN", "value": "Set", "action": "security:set_pin" },
              { "key": "biometric", "label": "Biometric Unlock", "value": "Enabled" }
            ]
          },
          {
            "name": "Data",
            "items": [
              { "key": "backup", "label": "Backup Now", "action": "data:backup" },
              { "key": "restore", "label": "Restore", "action": "data:restore" }
            ]
          }
        ]
      }
    ]
  }
}
```

---

# 7) Frontend Implementation Blueprint (Flutter)

**Project structure**

* `lib/`

  * `main.dart`
  * `theme/` tokens and extensions
  * `routes/` central router (go\_router or Routemaster)
  * `screens/` each page
  * `widgets/` shared components (SummaryCard, EntryTile, CustomerCard, SegmentedControl, EmptyState)
  * `state/` Riverpod providers or Bloc cubits
  * `data/` repositories (Supabase), models, mappers
  * `l10n/` ARB files for strings

**State management**

* Riverpod (recommended for clarity)

  * `authProvider` (Supabase session)
  * `customersProvider`, `entriesProvider`, `remindersProvider`, `reportsProvider`
  * `uiSpecProvider` to load JSON spec if you want dynamic building

**Routing**

* `/onboarding`
* `/auth/login`, `/auth/forgot`, `/auth/register`
* `/home` (bottom nav shell)

  * tabs: `/home/dashboard`, `/home/add`, `/home/reminders`, `/home/customers`
* `/ledger/summary`
* `/entries`
* `/customer/:id`
* `/add/credit`, `/add/debit`
* `/reports`
* `/settings`

**Widget mapping**

* `type: "carousel"` → `PageView` + dots
* `type: "form"` → generated form with validators
* `type: "dashboard"` → `CustomScrollView` with SummaryCards + List
* `type: "analytics_light"` → Tabs with ListViews
* `type: "choice"` → Grid/List of big cards
* `type: "list"` → Search + Filters + `ListView.separated`
* `type: "directory"` → Search + `SliverList`
* `type: "detail"` → Header + actions + timeline list
* `type: "reminders"` → TabBar + actions
* `type: "reports"` → charts (recharts alternative in Flutter: charts\_flutter or fl\_chart)
* `type: "settings"` → grouped ListTiles

**Loading and error states**

* Each provider exposes `AsyncValue<T>` → show skeletons/spinners; error banners with retry actions.
* Global offline banner when network lost; queue writes for sync (optimistic UI).

**Validation**

* Numeric amounts > 0; customer required
* Debits over current credit → non-blocking warning sheet
* Phone format on customer if provided

**Accessibility and RTL**

* Support large text via `MediaQuery.textScaleFactor`
* Wrap text for RTL if you add Hindi/Gujarati later
* Semantic labels on icons and charts

**Performance**

* Use `const` widgets
* Infinite scrolling for entries and customers
* Debounce search queries
* Image/icon assets as vector where possible

**Theming**

* ThemeData from tokens; retain blue gradient for primary buttons; dark mode optional later

**Telemetry (optional)**

* Log events: login, add\_credit, add\_debit, reminder\_send, export\_report

**Testing**

* Unit: repositories and formatters
* Widget: Add Credit/Debit forms, Customer Detail balance logic
* Golden: Summary cards, list items

---

# 8) Delivery Notes

* Replace placeholder asset paths with your actual assets.
* All texts in the JSON should be keyed if you adopt ARB files; you can map keys now or later.
* The JSON spec is stable enough to drive a schema-based UI builder or to simply serve as a source of truth while you hand-code the widgets.

If you want, I can convert this JSON schema into a small builder that maps `type` → widget in Flutter and stubs the actions like `entry:create_credit` and `dialog:add_customer`.
