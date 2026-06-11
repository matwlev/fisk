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

## Quick Start

```bash
# Create a ledger
fisk create checkbook --balance 4200.00

# Create a ledger at a specific path
fisk create savings --balance 10000.00 --path ~/finances/savings.csv

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
     #  Date        Description                Debit      Credit      Balance  Status
  ────  ──────────  ────────────────────  ──────────  ──────────  ───────────  ──────────
     1  2026-06-11  Opening balance                   $ 4,200.00  $  4,200.00
     2  2026-06-11  Electric bill         $   142.50              $  4,057.50  cleared
     3  2026-06-11  Paycheck                          $ 3,200.00  $  7,257.50  pending

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
| `create <name> [--balance AMT] [--path PATH] [--config FILE]` | Create a new ledger |
| `show` | List all ledgers |
| `show <name> [--start-date] [--end-date] [--status] [--sort] [--limit] [--amount]` | Display a ledger |
| `forecast <name> -d <date\|duration> [--sort] [--limit] [--amount]` | Show including future transactions |
| `add <name> --desc "..." --amount N [--date] [--category]` | Add a transaction |
| `clear <name> <id> [id...]` | Mark transactions as cleared |
| `delete <name> <id> [id...]` | Delete transactions (with confirmation) |
| `import <name> --file <path>` | Import from an external CSV |
| `sort <name>` | Sort all transactions by date (reassigns IDs) |
| `sort <name> <id> <position>` | Move a transaction to a position |
| `use <name>` | Enter interactive mode for a ledger |
| → `add` | Add a transaction |
| → `bulk` | Add multiple transactions with the same date |
| → `edit <id>` | Edit a transaction |
| → `delete <id>` | Remove a transaction (with confirmation) |
| → `clear <id>` | Mark as cleared |
| → `reconcile` | Walk through unreconciled transactions, verify balance |
| → `forecast [-d]` | Show including future transactions |
| → `details <id>` | Show full transaction details including notes |
| → `sort` | Sort all transactions by date (reassigns IDs) |
| → `sort <id> <pos>` | Move a transaction to a position (reassigns IDs) |
| → `back` | Return to top-level |
| `--version` | Show version |

## Date Formats

Dates accept `YYYY-MM-DD`, `today`, or relative durations:
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

[defaults]
--sort desc
--limit 20
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
