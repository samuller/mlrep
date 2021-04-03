#!/usr/bin/env bash
#
# mlrep: Multi-line replace file processing script. A thin wrapper around
# ripgrep for using regular expression matching and replace functionality.
#
#
SCRIPT_NAME='mlrep'
SCRIPT_VERSION='1.0'
SCRIPT_DESCRIPTION=$(cat <<-EOF
Allows text files to be searched for text matching a regular expression
and replace it with a string that can contain matching groups from
the regular expression. Specifically supports regular expressions that
can match multiple lines.
EOF
)


########
# Detect installation of required commands
########
if ! command -v rg &> /dev/null
then
	echo >&2 "Ripgrep (rg) not found."
	echo >&2 "Installation required, e.g. apt-get install ripgrep"
	exit
fi

########
# Process command-line arguments
########
find_regex=
replace_string=

function usage
{
	SCRIPT_USAGE=$(cat <<-EOF
	mlrep [OPTIONS] --find REGEX --replace TEXT FILE...
	
	$SCRIPT_DESCRIPTION
	
	Mandatory parameters:
	-f, --find REGEX  	Regular expression to find. Can contain \n or newlines.
	-r, --replace TEXT	Replacement string. Can contain matching groups from 
	                  	from regular expression. E.g. "\$1".
	
	Options:
	    --help   	Display this help and exit.
	    --version
	EOF
	)

	echo "$SCRIPT_USAGE"
}

# Process first parameters starting with dash ("-")
while [[ $1 == -* ]]; do
	case $1 in
		-f | --find )
			shift
			find_regex=$1
			shift
			;;
		-r | --replace )
			shift
			replace_string=$1
			shift
			;;
		--help )
			usage
			exit
			;;
		--version )
			echo "$SCRIPT_NAME $SCRIPT_VERSION"
			exit
			;;
		* ) 
			echo >&2 "Unknown parameter: $1"
			echo >&2 "Use --help to see parameter usage."
			exit 1
	esac
done

# Process remaining arguments which should contain files to process
# At least one file is expected
if [ $# -eq 0 ]; then
	echo >&2 "No files provided to process."
	echo >&2 "Use --help to see parameter usage."
	# "No files" is not considered an error state
	exit 0
fi

########
# Handle file globbing to process each file
########

for filename in "$@"
do
  echo "$filename"

  # Run Ripgrep in replacement mode on each file.
  # Ripgrep usually only shows lines that match the regex (along with 
  # the linenumber), so we have to add arguments to control these.
  rg --replace "$replace_string" --passthru --no-line-number --multiline --multiline-dotall "$find_regex" "$filename" >> output.txt
  if [ $? -eq 2 ]; then
	echo "Error"
	exit 2
  fi
  
done
