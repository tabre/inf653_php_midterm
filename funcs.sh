#!/bin/bash
urlencode() {
    local string="$1"
    local encoded=""
    local len=${#string}
    for (( i=0; i<len; i++ )); do
        local char="${string:i:1}"
        case "$char" in
            [a-zA-Z0-9._~-])
                encoded+="$char"
                ;;
            *)
                encoded+=$(printf '%%%02X' "'$char")
                ;;
        esac
    done
    echo "$encoded"
}

get_url() {
    local endpoint=$1
    
    if [[ -z "$endpoint" ]]; then
        echo "Error: endpoint is a required argument"
        return 1
    fi

    local url="${base_url}/${endpoint}"

    if [[ -n "${2:-}" ]]; then
        local -n local_args=$2
        url="${url}?"

        for key in "${!args[@]}"; do
            val=$(urlencode "${args[$key]}")
            url="${url}${key}=${val}"
        done
    fi
    
    echo $url
}

authors_insert() {
    local -A args=(
        [author]="$1"
    )
    # echo $(get_url "authors" args)
    curl -X POST $(get_url "authors" args)
}

categories_insert() {
    local -A args=(
        [category]="$1"
    )
    # echo $(get_url "categories" args)
    curl -X POST $(get_url "categories" args)
}

quotes_insert() {
    local q="$1"
    local -A args=(
        [author_id]="$(jq -r '.author_id' <<< "$q")"
        [category_id]="$(jq -r '.category_id' <<< "$q")"
        [quote]="$(jq -r '.quote' <<< "$q")"
    )
    # echo $(get_url "quotes" args)
    curl -X POST $(get_url "quotes" args)
}
