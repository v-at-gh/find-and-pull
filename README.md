# Find and pull (git repos)

**FAP** is a Bash script designed to simplify updating multiple Git repositories within a specified directory. It scans for Git repositories, presents a list of options, and allows you to update selected repositories or all at once.

## Usage

```bash
./fap.sh [TARGET_DIR]
```

- `TARGET_DIR`: The directory where the script will search for Git repositories. If no directory is specified, it defaults to the current directory.

### Options

- `-h`, `--help`, `--usage`: Display the help message and exit.
- `-a`, `--all`            : Update all repositories without prompting.
- `--dry-run`              : List repositories that would be updated without updating.

### Input Examples

- `all`: Update all repositories.
- `0 2 6-4`: Update repositories by specifying indices and ranges (e.g., repositories 0, 2, and 6 to 4).

## How It Works

1. The script searches for Git repositories (`.git` directories) in the target directory.
2. It lists all found repositories by index.
3. You input either `all` to update all repositories or provide indices and ranges (e.g., `0 2 6-4`).
4. The selected repositories are updated in parallel using `git pull`.

## Example

```bash
./fap.sh ~/projects
```

```bash
Found Git repositories in ~/projects:
[0] ~/projects/repo1/.git
[1] ~/projects/repo2/.git
[2] ~/projects/repo3/.git

Enter repositories to update (e.g., 'all', '0 2 6-4'): all
Updating ~/projects/repo1
Updating ~/projects/repo2
Updating ~/projects/repo3
Update complete.
```
