#!/bin/bash

json_valid() {
    local json="$1"
    jq -e . >/dev/null 2>&1 <<<"$json"
}

json_has_fields() {
    local json="$1"
    local -n local_fields="$2"

    if ! json_valid "${json}"; then
        return 1
    fi

    for field in "${local_fields[@]}"; do
        if ! jq -e --arg field "$field" 'has($field)' >/dev/null 2>&1 <<<"$json"; then
            return 1
        fi
    done

    return 0
}

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

        for key in "${!local_args[@]}"; do
            val=$(urlencode "${local_args[$key]}")
            url="${url}${key}=${val}&"
        done
    fi

    if [[ "${url: -1}" == "&" ]]; then
        url="${url%?}"
    fi
    
    echo $url
}

authors_insert() {
    local -A args=(
        [author]="$1"
    )
    curl -s -X POST $(get_url "authors" args)
}

authors_select() {
    local -A args=(
        [id]="$1"
    )
    curl -s -X GET $(get_url "authors" args)
}

authors_update() {
    local -A args=(
        [id]="$1"
        [author]="$2"
    )
    curl -s -X PUT $(get_url "authors" args)
}

authors_delete() {
    local -A args=(
        [id]="$1"
    )
    curl -s -X DELETE $(get_url "authors" args)
}

categories_insert() {
    local -A args=(
        [category]="$1"
    )
    curl -s -X POST $(get_url "categories" args)
}

categories_select() {
    local -A args=(
        [id]="$1"
    )
    curl -s -X GET $(get_url "categories" args)
}

categories_update() {
    local -A args=(
        [id]="$1"
        [category]="$2"
    )
    curl -s -X PUT $(get_url "categories" args)
}

categories_delete() {
    local -A args=(
        [id]="$1"
    )
    curl -s -X DELETE $(get_url "categories" args)
}

quotes_insert() {
    local q="$1"
    local author="$(jq -r '.author' <<< "$q")"
    local category="$(jq -r '.category' <<< "$q")"

    local -A args=(
        [author_id]="$(jq -r --arg author "$author" '.[] | select(.author == $author) | .id' <<< $(authors_select))"
        [category_id]="$(jq -r --arg category "$category" '.[] | select(.category == $category) | .id' <<< $(categories_select))"
        [quote]="$(jq -r '.quote' <<< "$q")"
    )
    curl -X POST $(get_url "quotes" args)
}

quotes_delete() {
    local -A args=(
        [id]="$1"
    )
    curl -s -X DELETE $(get_url "quotes" args)
}
