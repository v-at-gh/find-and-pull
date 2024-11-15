#!/usr/bin/env bash

#set -x

usage() {
	cat <<EOF
Usage: $0 [OPTIONS] [TARGET_DIR]

Update Git repositories in the specified directory or the current directory.

If no TARGET_DIR is provided, the script will search for repositories in the
current directory.

Options:
    -h, --help, --usage  Display this help message and exit.
    -q, --quiet          Suppress output to stdout.
    -a, --all            Update all repositories without prompting.
    --dry-run            List repositories that would be updated without updating.

Input examples:
    - 'all'              Update all repositories.
    - '0 2 6-4'          Update repositories by specifying indices and ranges.
EOF
}

quiet_mode=false
select_all=false
dry_run=false

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		-h|--help|--usage)
			usage
			exit 0
			;;
		# -q|--quiet)
		# 	quiet_mode=true
		# 	;;
		-a|--all)
			select_all=true
			;;
		--dry-run)
			dry_run=true
			;;
		*)
			if [ -z "$target_dir" ]; then
				target_dir="$1"
			else
				echo "Unknown argument: $1"
				usage
				exit 1
			fi
			;;
	esac
	shift
done

target_dir="${target_dir:-.}"

if [ ! -d "$target_dir" ]; then
	echo "Target directory does not exist: $target_dir"
	exit 1
fi

if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
	# `mapfile` appeared in Bash 4. macOS pre-installs version 3.2.57.
	repos=()
	while IFS= read -r repo; do
		repos+=("$repo")
	done < <(find "$target_dir" -type d -name '.git')
else
	mapfile -t repos < <(find "$target_dir" -type d -name '.git')
fi

if [ ${#repos[@]} -eq 0 ]; then
	$quiet_mode || echo "No Git repositories found in $target_dir."
	exit 1
fi

$quiet_mode || $dry_run || echo "Found Git repositories in $target_dir:"
for i in "${!repos[@]}"; do
	$quiet_mode || printf "[%d] %s\n" "$i" "${repos[$i]}"
done

if $select_all; then
	selected_indices=("${!repos[@]}")
elif ! $dry_run; then
	read -rp "Enter repositories to update (e.g., 'all', '0 2 6-4'): " input
	if [ "$input" = "all" ]; then
		selected_indices=("${!repos[@]}")
	else
		selected_indices=()
		IFS=" " read -ra input_parts <<< "$input"
		for input_part in "${input_parts[@]}"; do
			if [[ $input_part =~ ([0-9]+)-([0-9]+) ]]; then
				start_idx="${BASH_REMATCH[1]}"
				end_idx="${BASH_REMATCH[2]}"
				for idx in $(seq "$start_idx" "$end_idx"); do
					selected_indices+=("$idx")
				done
			else
				selected_indices+=("$input_part")
			fi
		done
	fi
fi

for idx in "${selected_indices[@]}"; do
	if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#repos[@]} ]; then
		repo="${repos[$idx]}"
		if $dry_run; then
			$quiet_mode || echo "Would update: $repo"
		else
			$quiet_mode || echo "Updating $repo"
			(cd "$(dirname "$repo")" && git pull) &
		fi
	else
		$quiet_mode || echo "Invalid repository index: $idx"
	fi
done

wait
$quiet_mode || echo "Update complete."
