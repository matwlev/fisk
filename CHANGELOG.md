# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-11

### Added
- Initial release
- Interactive REPL mode (`fisk` with no arguments)
- Non-interactive CLI mode for scripting
- `create` command to create new ledgers with optional starting balance
- `show` command with date and status filtering
- `forecast` command with absolute dates and relative durations (`+2w`, `+30d`, `+3m`)
- `use` interactive mode with `add`, `edit`, `delete`, `clear` commands
- Automatic balance calculation
- Transaction status lifecycle: future → pending → cleared
- Delete confirmation prompt
- CSV storage in `~/.fisk/` (configurable via `FISK_DIR`)
- `--version` flag
