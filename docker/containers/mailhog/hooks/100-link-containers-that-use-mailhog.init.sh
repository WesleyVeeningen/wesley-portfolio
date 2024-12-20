LINK_STR=""$'\n'
if [ ! -z "${MAILHOG_CONTAINER:-}" ];then
  for LINK in ${MAILHOG_CONTAINER//;/ }; do
    [[ -z "${LINK:-}" ]] && continue;

LINK_STR=${LINK_STR}$(cat <<-EOF_CONFIG_STR
  ${LINK}:
    links:
      - mailhog:mailhog
    environment:
      - SMTPSERVER=mailhog
EOF_CONFIG_STR
)$'\n'

  done
fi
LINK_STR="#LINKED_SERVICES_START"$LINK_STR"#LINKED_SERVICES_END"
LINK_STR_SED_ESCAPED=$(printf '%s\n' "$LINK_STR" | sed 's,[\/&],\\&,g;s/$/\\/')
LINK_STR_SED_ESCAPED=${LINK_STR_SED_ESCAPED%?}

sed -i "/#LINKED_SERVICES_START/,/#LINKED_SERVICES_END/c$LINK_STR_SED_ESCAPED" "$(dirname "${BASH_SOURCE[0]}")"/../docker-compose-development.yml
sed -i "/#LINKED_SERVICES_START/,/#LINKED_SERVICES_END/c$LINK_STR_SED_ESCAPED" "$(dirname "${BASH_SOURCE[0]}")"/../docker-compose-staging.yml
