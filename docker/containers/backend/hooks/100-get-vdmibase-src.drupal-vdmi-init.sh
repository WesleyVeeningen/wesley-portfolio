# Allow unset variables.
set +u

# Create custom profile directory
if [ ! -d src/web/profiles/custom/vdmibase ]; then
  mkdir -p src/web/profiles/custom/vdmibase
fi
echo "vdmibase/.git/*" > src/web/profiles/custom/.gitignore
cd src/web/profiles/custom/vdmibase

VDMIBASE_VERSION=""

while [ -z "${SHOW_VERSIONS_OR_USE_BRANCH}" ]; do
  read -p $"Show VDMIBASE available versions(tags) or use a branch? [versions] " INDEX
  [ ! -z "${INDEX}" ] || INDEX="V"
  case ${INDEX,,} in
    (v|version|versions|tag|tags|b|branch|branches)
      SHOW_VERSIONS_OR_USE_BRANCH="${INDEX,,}"
    ;;
  esac
done
echo ""

# if user wants to select a tag
if [[ "$SHOW_VERSIONS_OR_USE_BRANCH" =~ ^(v|version|versions|tag|tags)$ ]]; then
  UNFILTERED_POSSIBLE_VDMIBASE_VERSIONS=($(git ls-remote --tags git@git.vdmi.nl:vdmi-algemeen/vdmibase.git | grep -Po 'refs\/tags\/\K.*[^\\]'))

  # Should we only show the tags that are of the right drupal version (example v10.0.0 shows if drupal 10 is selected but not if drupal 9 is selected)
  while [ -z "${SHOULD_FILTER}" ]; do
    read -p $"Only showing recommended VDMIBASE versions for your drupal version? [Y] " INDEX
    [ ! -z "${INDEX}" ] || INDEX="y"
    case ${INDEX,,} in
      (y|yes|n|no)
        SHOULD_FILTER="${INDEX,,}"
      ;;
    esac
  done
  echo ""

  # Filter values
  POSSIBLE_VDMIBASE_VERSIONS=()
  if [[ "$SHOULD_FILTER" =~ ^(no|n)$ ]]; then
      POSSIBLE_VDMIBASE_VERSIONS+=("${UNFILTERED_POSSIBLE_VDMIBASE_VERSIONS[@]}")
  else
    for (( i=0; i<=${#UNFILTERED_POSSIBLE_VDMIBASE_VERSIONS[@]}; i++ )); do
      if [[ "${UNFILTERED_POSSIBLE_VDMIBASE_VERSIONS[$i]}" =~ ${MAIN_DRUPAL_VERSION}\.[0-9]+\.[0-9]+ ]]; then
        POSSIBLE_VDMIBASE_VERSIONS+=("${UNFILTERED_POSSIBLE_VDMIBASE_VERSIONS[$i]}")
      fi
    done
  fi

  # Show available versions (tags)
  echo $"Select a VDMIBASE version to install."
  for (( i=${#POSSIBLE_VDMIBASE_VERSIONS[@]}; i>=1; i-- )); do
    POSSIBLE_VERSION=${POSSIBLE_VDMIBASE_VERSIONS[$i-1]}
    PADDING=$"     "
    VISUAL_INDEX=${PADDING:0:-${#i}}$((${#POSSIBLE_VDMIBASE_VERSIONS[@]} - $i + 1))
    echo $"${VISUAL_INDEX}) ${POSSIBLE_VERSION}"
  done
  echo ""

  # Select vdmibase version (tag)
  while [ -z "${VDMIBASE_VERSION}" ]; do
    DEFAULT_VERSION=$((${#POSSIBLE_VDMIBASE_VERSIONS[@]} - 1))
    if (( DEFAULT_VERSION < 1 )); then
      DEFAULT_VERSION=1
    fi
    read -p $"Which version of VDMIBASE to install? [$((${DEFAULT_VERSION}))] " INDEX
    [ ! -z "${INDEX}" ] || INDEX=$DEFAULT_VERSION
    if [[ "$INDEX" =~ ^[0-9]+$ ]] && (( INDEX > 0 )); then
      VDMIBASE_VERSION=${POSSIBLE_VDMIBASE_VERSIONS[${#POSSIBLE_VDMIBASE_VERSIONS[@]}-$INDEX]}
    fi
  done
  echo ""
else
  POSSIBLE_VDMIBASE_VERSIONS=($(git ls-remote --heads git@git.vdmi.nl:vdmi-algemeen/vdmibase.git | grep -Po 'refs\/heads\/\K.*[^\\]'))

  # Ask a version
  echo $"Select a VDMIBASE version to install."
  for (( i=${#POSSIBLE_VDMIBASE_VERSIONS[@]}; i>=1; i-- )); do
    POSSIBLE_VERSION=${POSSIBLE_VDMIBASE_VERSIONS[$i-1]}
    PADDING=$"     "
    VISUAL_INDEX=${PADDING:0:-${#i}}$((${#POSSIBLE_VDMIBASE_VERSIONS[@]} - $i + 1))
    echo $"${VISUAL_INDEX}) ${POSSIBLE_VERSION}"
  done
  echo ""

  # Select vdmibase version (branch)
  while [ -z "${VDMIBASE_VERSION}" ]; do
    DEFAULT_VERSION=$((${#POSSIBLE_VDMIBASE_VERSIONS[@]} - 1))
    if (( DEFAULT_VERSION < 1 )); then
      DEFAULT_VERSION=1
    fi
    read -p $"Which version of VDMIBASE to install? [$((${DEFAULT_VERSION}))] " INDEX
    [ ! -z "${INDEX}" ] || INDEX=$DEFAULT_VERSION
    if [[ "$INDEX" =~ ^[0-9]+$ ]] && (( INDEX > 0 )); then
      VDMIBASE_VERSION=${POSSIBLE_VDMIBASE_VERSIONS[${#POSSIBLE_VDMIBASE_VERSIONS[@]}-$INDEX]}
    fi
  done
  echo ""
fi

cd "$PROJECT_DIR"

# Add the correct repositories
"$(dirname "${BASH_SOURCE[0]}")"/files/bash-json-user --file=src/composer.json --key=repositories --value="[
        {
            \"type\": \"composer\",
            \"url\": \"https://packages.drupal.org/8\"
        },
        {
            \"type\": \"composer\",
            \"url\": \"https://asset-packagist.org\"
        },
        {
            \"type\": \"vcs\",
            \"url\": \"https://gitlab+deploy-token-10:N5ognKrWH-AJZKM2xH36@git.vdmi.nl/vdmi-algemeen/vdmibase.git\",
            \"options\": {
                \"http\": {
                    \"header\": {
                        \"gitlab+deploy-token-10\": \"N5ognKrWH-AJZKM2xH36\"
                    }
                }
            }
        }
    ]" > src/.composer-tmp.json

# Save changes
cp src/.composer-tmp.json src/composer.json

# Add vdmibase to required packages
if [[ "$SHOW_VERSIONS_OR_USE_BRANCH" =~ ^(v|version|versions)$ ]]; then
  "$(dirname "${BASH_SOURCE[0]}")"/files/bash-json-user --file=src/composer.json --key="require.vdmi-profile/vdmibase" --value="~$VDMIBASE_VERSION" > src/.composer-tmp.json
else
  "$(dirname "${BASH_SOURCE[0]}")"/files/bash-json-user --file=src/composer.json --key="require.vdmi-profile/vdmibase" --value="dev-$VDMIBASE_VERSION" > src/.composer-tmp.json
fi

# Save changes
cp src/.composer-tmp.json src/composer.json

# Remove temp file
rm src/.composer-tmp.json

# Disallow unset variables (back to default).
set -u
