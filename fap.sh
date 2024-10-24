#!/usr/bin/env bash

#set -x

usage() {
  cat <<EOF
Usage: $0 [TARGET_DIR]

Update Git repositories in the specified directory or the current directory.

If no TARGET_DIR is provided, the script will search for repositories in the
current directory.

Options:
    -h, --help, --usage  Display this help message and exit.

Input examples:
    - 'all'             Update all repositories.
    - '0 2 6-4'         Update repositories by specifying indices and ranges.
EOF
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "--usage" ]; then
	usage
	exit 0
fi

if [ "$#" -eq 0 ]; then
	target_dir="."
else
	target_dir="$1"
	if [ ! -d "$target_dir" ]; then
		echo "Target directory does not exist: $target_dir"
		exit 1
	fi
fi

if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
	# `mapfile` appeared in the fourth version of Bash.
	# The pre-installed version in macOS is 3.2.57
	repos=()
	while IFS= read -r repo; do
		repos+=("$repo")
	done < <(find "$target_dir" -type d -name '.git')
else
	mapfile -t repos < <(find "$target_dir" -type d -name '.git')
fi

if [ ${#repos[@]} -eq 0 ]; then
	echo "No Git repositories found in $target_dir."
	exit 1
fi

echo "Found Git repositories in $target_dir:"
for i in "${!repos[@]}"; do
	echo "[$i] ${repos[$i]}"
done

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

for idx in "${selected_indices[@]}"; do
	if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#repos[@]} ]; then
		repo="${repos[$idx]}"
		echo "Updating $repo"
		(cd "$(dirname "$repo")" && git pull) &
	else
		echo "Invalid repository index: $idx"
	fi
done

wait
echo "Update complete."
