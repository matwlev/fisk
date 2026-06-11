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

Installs to `~/.local/bin/fisk`. Data is stored in `~/.fisk/`.

```bash
./install.sh --update                # update binary only, skip data directory
./install.sh --no-data               # same as --update
./install.sh --data-dir=~/Dropbox/finances  # custom data directory (sets FISK_DIR in shell rc)
```

## Uninstall

```bash
./uninstall.sh
```

Note: your data in `~/.fisk/` is preserved. Remove it manually if no longer needed.

## Quick Start

```bash
# Create a ledger
fisk create checkbook --balance 4200.00

# Add transactions
fisk add checkbook --desc "Electric bill" --amount -142.50 --category Utilities
fisk add checkbook --desc "Paycheck" --amount 3200.00 --category Income

# View it
fisk show checkbook

# Mark transactions as cleared
fisk clear checkbook 2 3

# Forecast future transactions
fisk forecast checkbook -d +2w
```

## Interactive Mode

Run `fisk` with no arguments to enter the REPL:

```
$ fisk
fisk> show
  checkbook
  savings

fisk> show checkbook
  #  Date        Description      Debit     Credit    Balance  Status
  1  2026-06-11  Opening balance            4200.00   4200.00
  2  2026-06-11  Electric bill    142.50               4057.50  ✓
  3  2026-06-11  Paycheck                   3200.00   7257.50  ·

fisk> use checkbook
checkbook> add
checkbook> edit 3
checkbook> clear 2
checkbook> delete 4
checkbook> back

fisk> quit
```

## Commands

| Command | Description |
|---------|-------------|
| `create <name> [--balance AMT]` | Create a new ledger |
| `show` | List all ledgers |
| `show <name> [--start-date] [--end-date] [--status] [--sort]` | Display a ledger |
| `forecast <name> -d <date\|duration> [--sort]` | Show including future transactions |
| `add <name> --desc "..." --amount N [--date] [--category]` | Add a transaction |
| `clear <name> <id> [id...]` | Mark transactions as cleared |
| `delete <name> <id> [id...]` | Delete transactions (with confirmation) |
| `import <name> --file <path>` | Import from an external CSV |
| `use <name>` | Enter interactive mode for a ledger |
| `--version` | Show version |

## Date Formats

Dates accept `YYYY-MM-DD`, `today`, or relative durations:
- `+7d` — 7 days from today
- `+2w` — 2 weeks from today
- `+3m` — 3 months from today

## Sort Order

Transactions default to `desc` (most recent first). Use `--sort asc` for chronological order:

```bash
fisk show checkbook --sort asc
```

## Transaction Status

```
future → pending → cleared
```

- **future** — dated in the future, only visible in `forecast`
- **pending** — entered but not yet confirmed at the bank
- **cleared** — confirmed/posted

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

CSV files are stored in `~/.fisk/` by default. Set the `FISK_DIR` environment variable to use a different location:

```bash
export FISK_DIR=~/Dropbox/finances
```

The CSV format is simple and portable:

```csv
id,date,description,amount,category,status
1,2026-06-11,Opening balance,4200.00,,starting
2,2026-06-11,Electric bill,-142.50,Utilities,cleared
3,2026-06-11,Paycheck,3200.00,Income,pending
```

## License

MIT
