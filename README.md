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
| `show <name> [--start-date] [--end-date] [--status]` | Display a ledger |
| `forecast <name> -d <date\|duration>` | Show including future transactions |
| `add <name> --desc "..." --amount N [--date] [--category]` | Add a transaction |
| `clear <name> <id> [id...]` | Mark transactions as cleared |
| `delete <name> <id> [id...]` | Delete transactions (with confirmation) |
| `use <name>` | Enter interactive mode for a ledger |
| `--version` | Show version |

## Date Formats

Dates accept `YYYY-MM-DD`, `today`, or relative durations:
- `+7d` — 7 days from today
- `+2w` — 2 weeks from today
- `+3m` — 3 months from today

## Transaction Status

```
future → pending → cleared
```

- **future** — dated in the future, only visible in `forecast`
- **pending** — entered but not yet confirmed at the bank
- **cleared** — confirmed/posted

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
