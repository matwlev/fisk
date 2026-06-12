# fisk

A personal finance ledger CLI. Lightweight, interactive, and backed by plain CSV files.

## Prerequisites

fisk requires Python 3.9+:

```bash
python3 --version    # check if installed
brew install python  # macOS (if needed)
```

## Install

```bash
cd ~/projects/fisk
./install.sh
```

Installs to `~/.local/bin/fisk` and creates `~/.fisk/config`.

```bash
./install.sh --update         # update binary only, skip config
./install.sh --reset-config   # overwrite existing ~/.fisk/config
```

## Uninstall

```bash
./uninstall.sh
```

Note: your data in `~/.fisk/` is preserved. Remove it manually if no longer needed.

## Workflow: Ledgers

### Create a ledger

```bash
fisk create checkbook --balance 4200.00
fisk create savings --balance 10000.00 --path ~/finances/savings.csv
```

### Add transactions

From the command line:

```bash
fisk add checkbook --desc "Electric bill" --amount -142.50 --category Utilities
fisk add checkbook --desc "Paycheck" --amount 3200.00 --category Income
```

Or interactively:

```
fisk> ledgers checkbook
checkbook> add
  Date [2026-06-12]:
  Description: Groceries
  Amount: -87.34
  Category []: Food
  Notes []:
  Added.
```

Use `bulk` to add multiple transactions with the same date:

```
checkbook> bulk
  Date [2026-06-12]:
  Enter transactions (empty description to finish):
  Description: Coffee
  Amount: -5.50
  Category []: Food
  Notes []:
  ✓
  Description: Gas
  Amount: -42.00
  Category []: Auto
  Notes []:
  ✓
  Description:
  Added 2 transactions.
```

### View transactions

```bash
fisk show checkbook                          # last 20 transactions
fisk show checkbook --limit 0               # all transactions
fisk show checkbook --status pending        # only pending
fisk show checkbook --amount ">=100"        # $100+
fisk show checkbook --start-date 2026-05-01 # since a date
fisk forecast checkbook -d +2w             # include future-dated transactions
```

### Clear and reconcile

Mark transactions as confirmed at the bank:

```
checkbook> clear 2 3
  #2  2026-06-12  Electric bill  -142.50
  #3  2026-06-12  Paycheck  3200.00
  Mark as cleared? [Y/n]: y
  Cleared.
```

Reconcile against a bank statement:

```
checkbook> reconcile
  Statement ending balance: 7057.50
  Statement date [2026-06-12]:

  3 unreconciled transaction(s) through 2026-06-12:

  #2  2026-06-12  Electric bill  -142.50  [Y/n/s]: y
  #3  2026-06-12  Paycheck  3200.00  [Y/n/s]: y

  Reconciled balance: 7057.50
  Statement balance:  7057.50  ✓ Balanced!
  2 transaction(s) reconciled.
```

### Summary

```
checkbook> summary
  Transactions:  15
  Total:         $3,200.00
  Total spent:   $-1,842.34
  ...

  By category:
    Food                 $  -312.50
    Utilities            $  -285.00
    ...
```

## Workflow: Bills

### Create a bill file

```bash
fisk bills create bills --path ~/finances/bills.csv
```

Or from the REPL:

```
fisk> bills create bills --path ~/finances/bills.csv
Created: /Users/you/finances/bills.csv
```

### Add a recurring bill

```
fisk> bills bills
bills> add
  Name: Electric
  Amount (blank if variable): 142.50
  Category: Utilities
  Frequency (monthly, bimonthly, quarterly, semiannual, annual, or Nd e.g. 14d):
  Frequency: monthly
  Due day of month: 16
  Start date [2026-06-12]: 2026-01-01
  End date (blank for ongoing):
  Added.
```

Leave amount blank for bills that vary each month (e.g. electric, water). The amount will be estimated from past payments or prompted at receive/pay time.

### See what's coming up

The dashboard shows upcoming bills across all bill files:

```
fisk> show
  Ledgers
  ────────────────
  checkbook

  Bills (next 30 days)
  ────────────────────────────────────────────────────────
  Electric          $   142.50  due Jun 16  predicted
  Netflix           $    15.99  due Jul 01  predicted
```

For more detail, enter the bill file:

```
bills> show
  Bill                Amount  Due         Status      Paid
  ────────────────── ──────────  ──────────  ──────────  ──────────
  Electric            $ 142.50  Jun 16      predicted
  Netflix             $  15.99  Jul 01      predicted
```

### Receive a bill (record the actual statement)

When the bill arrives with the real due date and amount:

```
bills> receive Electric --due 2026-06-15 --amount 148.23
  ✓ Electric due 2026-06-15 — $148.23
```

This converts the predicted instance to `unpaid` with real data. If the actual due date differs from the predicted one (e.g. 15th vs 16th), the prediction is suppressed within ±7 days.

```
bills> show
  Bill                Amount  Due         Status      Paid
  ────────────────── ──────────  ──────────  ──────────  ──────────
  Electric            $ 148.23  Jun 15      unpaid
  Netflix             $  15.99  Jul 01      predicted
```

### Pay a bill

Mark it paid, optionally recording a ledger transaction:

```
bills> pay Electric --add checkbook
  Paid date [2026-06-14]: 2026-06-14
  ✓ Transaction added to checkbook (#5)
  ✓ Electric paid 2026-06-14 (due 2026-06-15)
```

This:
1. Creates a transaction in the checkbook ledger (negative amount, category from the bill)
2. Links the ledger transaction to the bill instance (viewable via `details`)
3. Advances `paid_through` so next month's prediction appears

From the ledger, you can see the link:

```
checkbook> details 5
  ID:          5
  Date:        2026-06-14
  Description: Electric
  Amount:      -148.23
  Category:    Utilities
  Status:      pending
  Linked bill: bills/Electric
  Due date:    2026-06-15
  Paid date:   2026-06-14
```

### Bill instance lifecycle

```
predicted → unpaid → paid
```

- **predicted** — auto-generated from frequency; amount estimated from history
- **unpaid** — actual statement received; real due date and amount recorded
- **paid** — payment confirmed; linked to ledger transaction

## Interactive Mode

Run `fisk` with no arguments to enter the REPL. The interface has three tiers:

### Top level (`fisk>`)

```
$ fisk
fisk> show
  Ledgers
  ────────────────
  checkbook
  savings

  Bills (next 30 days)
  ────────────────────────────────────────────────────────
  Electric          $   142.50  due Jun 15  unpaid      [bills]
  Netflix           $    15.99  due Jul 01  predicted   [subscriptions]

fisk> ledgers
fisk> bills
fisk> quit
```

### Ledgers mode (`fisk (ledgers)>`)

```
fisk> ledgers
fisk (ledgers)> show
  checkbook
  savings
fisk (ledgers)> new
  Name: checking
  Opening balance [0.00]: 5000
  Path [~/.fisk/checking.csv]:
  Created.
fisk (ledgers)> use checkbook
fisk (ledger: checkbook)> ...
fisk (ledger: checkbook)> back
fisk (ledgers)> back
```

### Ledger context (`fisk (ledger: name)>`)

```
fisk (ledger: checkbook)> show
fisk (ledger: checkbook)> debit
fisk (ledger: checkbook)> credit
fisk (ledger: checkbook)> add
fisk (ledger: checkbook)> edit 3
fisk (ledger: checkbook)> clear 2
fisk (ledger: checkbook)> delete 4
fisk (ledger: checkbook)> reconcile
fisk (ledger: checkbook)> forecast -d +2w
fisk (ledger: checkbook)> summary
fisk (ledger: checkbook)> back
```

### Bills mode (`fisk (bills)>`)

```
fisk> bills
fisk (bills)> show
  monthly
  subscriptions
fisk (bills)> new
  Name: subscriptions
  Path [~/.fisk/subscriptions.csv]:
  Created.
fisk (bills)> pay Electric --add checkbook
fisk (bills)> receive Netflix --due 2026-07-01 --amount 15.99
fisk (bills)> use monthly
fisk (bills: monthly)> ...
fisk (bills: monthly)> back
fisk (bills)> back
```

### Bill file context (`fisk (bills: name)>`)

```
fisk (bills: monthly)> show
fisk (bills: monthly)> add
fisk (bills: monthly)> receive Electric --due 15 --amount 148.23
fisk (bills: monthly)> pay Electric --add checkbook
fisk (bills: monthly)> back
```

## Commands

| Command | Description |
|---------|-------------|
| `create ledger --name NAME [--balance AMT] [--path PATH]` | Create a new ledger |
| `create bills --name NAME [--path PATH]` | Create a new bill file |
| `show <ledger> [--start-date] [--end-date] [--status] [--sort] [--limit] [--amount]` | Display a ledger |
| `forecast <ledger> -d <date\|duration> [--sort] [--limit] [--amount]` | Show including future transactions |
| `add <ledger> --desc "..." --amount N [--date] [--category]` | Add a transaction |
| `add <ledger> --desc "..." --debit N [--date] [--category]` | Add a debit (stored negative) |
| `add <ledger> --desc "..." --credit N [--date] [--category]` | Add a credit (stored positive) |
| `clear <ledger> <id> [id...]` | Mark transactions as cleared |
| `delete <ledger> <id> [id...]` | Delete transactions (with confirmation) |
| `import <ledger> --file <path>` | Import from an external CSV |
| `sort <ledger>` | Sort all transactions by date (reassigns IDs) |
| `sort <ledger> <id> <position>` | Move a transaction to a position |
| `summary <ledger> [--description] [--category] [--start-date] [--end-date]` | Transaction statistics |
| `bills <file> [show]` | Show upcoming bills from a file |
| `bills <file> pay <name> [--add <ledger>]` | Mark a bill as paid |
| `bills <file> receive <name> [--due DATE] [--amount AMT]` | Record a bill statement received |
| `--version` | Show version |

### Ledger REPL commands

| Command | Description |
|---------|-------------|
| `show` | Show transactions |
| `add` | Add a transaction |
| `debit` | Add a debit (expense) — amount stored as negative |
| `credit` | Add a credit (income) — amount stored as positive |
| `bulk` | Add multiple transactions with the same date |
| `edit <id>` | Edit a transaction |
| `delete <id>` | Remove a transaction (with confirmation) |
| `clear <id>` | Mark as cleared |
| `reconcile` | Walk through unreconciled transactions, verify balance |
| `forecast [-d]` | Show including future transactions |
| `summary` | Transaction statistics |
| `details <id>` | Show full transaction details including bill links |
| `sort` | Sort all transactions by date (reassigns IDs) |
| `sort <id> <pos>` | Move a transaction to a position |
| `back` | Return to ledgers mode |

### Bills REPL commands

| Command | Description |
|---------|-------------|
| `show` | Show upcoming bill instances |
| `add` | Add a recurring bill |
| `receive <name> [--due DATE] [--amount AMT]` | Record a bill statement received |
| `pay <name> [--add <ledger>] [--date DATE]` | Mark a bill as paid |
| `edit <id>` | Edit a bill |
| `remove <id>` | Remove a bill |
| `back` | Return to bills mode |

## Bills

Track recurring bills and subscriptions. Bills are stored in CSV files referenced from the `[bills]` config section.

### Config

```
[bills]
bills           ~/finances/bills.csv
subscriptions   ~/finances/subscriptions.csv
```

### Bills CSV format

```csv
id,name,amount,category,frequency,due_day,start_date,end_date,paid_through
1,Electric,142.50,Utilities,monthly,15,2026-01-01,,2026-05-15
2,Netflix,15.99,Entertainment,monthly,1,2026-03-01,,2026-06-01
3,Rent,1800.00,Housing,monthly,1,2025-08-01,2027-07-01,2026-06-01
4,Car Insurance,480.00,Auto,quarterly,1,2026-01-01,,2026-04-01
5,Dog Grooming,65.00,Pets,42d,,2026-03-01,,2026-05-24
```

### Instances CSV format

Each bill file has a companion `*_instances.csv` that tracks individual occurrences:

```csv
id,bill_id,due_date,amount,paid_date,status,ledger,transaction_id
1,1,2026-06-15,148.23,2026-06-14,paid,checkbook,47
2,1,2026-07-16,,,predicted,,
3,2,2026-07-01,15.99,,unpaid,,
```

Predicted instances are generated on the fly and not persisted. Only received (unpaid) and paid instances are stored.

### Frequency options

Calendar-based (anchored to `due_day`):
- `monthly` — every month
- `bimonthly` — every 2 months
- `quarterly` — every 3 months
- `semiannual` — every 6 months
- `annual` — every 12 months

Interval-based (rolling from `start_date`):
- `Nd` — every N days (e.g. `14d`, `30d`, `42d`)

### Fields

- **paid_through** — the last due date confirmed as paid; next due is calculated from here
- **end_date** — when the bill stops (empty = ongoing)
- **due_day** — day of month for calendar-based frequencies (blank for interval-based)

### Paying bills

`pay` marks a bill paid through its next due date. The `--add <ledger>` flag also records a transaction:

```bash
fisk bills bills pay Electric               # just mark paid
fisk bills bills pay Netflix --add checkbook # mark paid + add transaction to checkbook
```

The top-level `show` aggregates upcoming bills across all files. Use `--source` to see which file each bill comes from.

## Date Formats

Dates accept `YYYY-MM-DD`, `today`, a bare day number, or relative durations:
- `12` — the 12th of the current month
- `+7d` — 7 days from today
- `+2w` — 2 weeks from today
- `+3m` — 3 months from today

## Filtering

```bash
fisk show checkbook --limit 10               # last 10 entries
fisk show checkbook --limit 0                # show all (no limit)
fisk show checkbook --amount ">=100"         # transactions $100+
fisk show checkbook --amount "<50"           # under $50
fisk show checkbook --status pending         # only pending
fisk show checkbook --start-date 2026-05-01  # since a date
```

By default, `show` displays the last 20 transactions. Use `--limit 0` to show all.

Amount filtering compares against the absolute value (ignores sign).

## Sort Order

Transactions default to `desc` (most recent first). Use `--sort asc` for chronological order:

```bash
fisk show checkbook --sort asc
```

## Transaction Status

```
future → pending → cleared → reconciled
```

- **future** — dated in the future, only visible in `forecast`
- **pending** — entered but not yet confirmed at the bank
- **cleared** — confirmed/posted at the bank
- **reconciled** — verified against bank statement

Transactions can go directly from pending to reconciled (skipping cleared).

## Importing

Import transactions from an external CSV (e.g., a Google Sheets export):

```bash
fisk import checkbook --file ~/Downloads/export.csv
```

Auto-detects columns named `Date`, `Description`, `Credit`, `Debit`, and `✓`/`Cleared`. Separate credit/debit columns are combined into a single signed amount (debit becomes negative).

Override column names if yours differ:

```bash
fisk import checkbook --file export.csv \
  --date-col "Date" \
  --credit-col "Deposit" \
  --debit-col "Withdrawal" \
  --cleared-col "Cleared"
```

Use `--date-format` for non-standard date formats (Python strptime syntax):

```bash
fisk import checkbook --file export.csv --date-format "%a. %m/%d/%y"   # "Fri. 06/05/26"
```

All dates are converted to `YYYY-MM-DD` on import.

Use `--amount-col` instead of `--credit-col`/`--debit-col` if your file has a single signed amount column.

Supported date formats (auto-detected): `YYYY-MM-DD`, `MM/DD/YYYY`, `MM/DD/YY`. Use `--date-format` for anything else.

## Storage

On first install, fisk creates `~/.fisk/config`. Config lookup order:

1. `--config <file>` flag
2. `./fisk.config` (local — useful for per-project setups)
3. `~/.fisk/config` (global)

Config format:

```
[ledgers]
checkbook  ~/finances/checkbook.csv
savings    ~/finances/savings.csv

[bills]
bills           ~/finances/bills.csv
subscriptions   ~/finances/subscriptions.csv

[defaults]
--sort desc
--limit 20
--default-sign debit
```

Ledgers not mapped in config are stored in `~/fisk/` by default. Override with the `FISK_DIR` environment variable.

The CSV format is simple and portable:

```csv
id,date,description,amount,category,status,notes
1,2026-06-11,Opening balance,4200.00,,starting,
2,2026-06-11,Electric bill,-142.50,Utilities,cleared,
3,2026-06-11,Paycheck,3200.00,Income,pending,Direct deposit
```

## License

MIT
