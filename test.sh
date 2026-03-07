#!/bin/bash
source cfg.sh
source funcs.sh

# ============================================================================
# general
# ============================================================================

# A.) All requests should provide a JSON data response.
#
#   - Note: other than 500 response, all remaining tests will pass this
#     category

#   - 500 response returns JSON
general__500_json_valid() {
    local -A args=([author]="Boe Jiden")
    local url=$(get_url "authors" args)
    echo -e "\t${url}"

    # Inserting the same author twice should generate 500 response due to 
    # unique constraint on table
    local id=$(curl -s -X POST $url | jq -r '.id')

    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)

    authors_delete $id >>/dev/null

    if [[ "$status" == "500" ]] && json_valid "$body"; then
        echo -e "\tValid JSON for 500 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 500 or invalid JSON"
        return 1
    fi
}

# E) Appropriate not found and missing parameter messages as indicated
#    below.
#
#   - Note: All tests for item E are covered in the proceeding tests

# ============================================================================
# quotes
# ============================================================================

# B.) All requests for quotes should return the id, quote, author (name),
# and category (name)
# 
# Create (POST) ..............................................................
#   

#   - /quotes/ created quote (id, quote, author_id, category_id)
quotes_post__valid_fields() {
    local -A args=(
        [author_id]="1"
        [category_id]="1"
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')

    quotes_delete $id >>/dev/null

    fields=("id" "quote" "author_id" "category_id")
    
    if [[ "$status" == "200" ]] && json_has_fields "$body" fields; then
        echo -e "\tValid JSON for 200 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 200, invalid JSON, or missing fields"
        return 1
    fi
}

#   - author_id does not exist { message: ‘author_id Not Found’ }
quotes_post__404_author_id() {
    local -A args=(
        [author_id]="42069"  # ID must not exist
        [category_id]="1"
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="author_id Not Found"
    
    if [[ "$status" == "404" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 404 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 404, invalid JSON, or missing fields, or incorrect message"
        return 1
    fi
}

#   - category_id does not exist { message: ‘category_id Not Found’ }
quotes_post__404_category_id() {
    local -A args=(
        [author_id]="1"  
        [category_id]="42069" # ID must not exist
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="category_id Not Found"
    
    if [[ "$status" == "404" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 404 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 404, invalid JSON, or missing fields, or incorrect message"
        return 1
    fi
}

#   -If missing any parameters { message: ‘Missing Required Parameters’ }
quotes_post__422_missing_params() {
    local -A args=(
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or incorrect message"
        return 1
    fi
}

#   
# Read (GET) .................................................................
#

#   - /quotes/ All quotes are returned
#     Expect >= 25 items returned in array
quotes_get__all_returned() {
    local url=$(get_url "quotes")
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local count=$(echo "$body" | jq 'length')
    local expected=25
    
    if [[ "$status" == "200" ]] && [[ $count -ge $expected ]]; then
        echo -e "\tValid JSON response with >=25 results"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tCount: ${count}\n\tStatus not 200, invalid JSON, or less than 25 results returned"
        return 1
    fi
}

#   - /quotes/?id=4 The specific quote
quotes_get__by_id() {
    local -A args=(
        [id]="1"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')
    local expected=1
    
    if [[ "$status" == "200" ]] && [[ $id == $expected ]]; then
        echo -e "\tValid JSON response with correct id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 200, invalid JSON, or wrong id returned"
        return 1
    fi
}

#   - /quotes/?author_id=5 All quotes from author_id=5
quotes_get__by_author_id() {
    local -A args=(
        [author_id]="5"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local author_id=$(echo "$body" | jq -r '.[0].author_id')
    local expected=5
    
    if [[ "$status" == "200" ]] && [[ $author_id == $expected ]]; then
        echo -e "\tValid JSON response with correct author_id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tauthor_id: ${author_id}\n\tStatus not 200, invalid JSON, or wrong author_id returned"
        return 1
    fi
}

#   - /quotes/?category_id=5 All quotes in category_id=5
quotes_get__by_category_id() {
    local -A args=(
        [category_id]="5"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local category_id=$(echo "$body" | jq -r '.[0].category_id')
    local expected=5
    
    if [[ "$status" == "200" ]] && [[ $category_id == $expected ]]; then
        echo -e "\tValid JSON response with correct category_id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tcategory_id: ${category_id}\n\tStatus not 200, invalid JSON, or wrong category_id returned"
        return 1
    fi
}

#   - /quotes/?author_id=3&category_id=5 All quotes from authorId=3 that are in 
#     category_id=5
quotes_get__by_author_id_and_category_id() {
    # This combination of arguments must return at least one result
    local -A args=(
        [author_id]="3"
        [category_id]="5"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local author_id=$(echo "$body" | jq -r '.[0].author_id')
    local category_id=$(echo "$body" | jq -r '.[0].category_id')
    
    if [[ "$status" == "200" ]] && [[ $author_id == "3" ]] && [[ $category_id == "5" ]]; then
        echo -e "\tValid JSON response with correct author_id and category_id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tauthor_id: ${author_id}\n\tcategory_id: ${category_id}\n\tStatus not 200, invalid JSON, wrong author_id, or wrong category_id returned"
        return 1
    fi
}

#   - If no quotes found for routes above { message: ‘No Quotes Found’ }
quotes_get__404_none_found() {
    local -A args=(
        [id]="42069" # ID must not exist
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="No Quotes Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON response with correct message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 404, invalid JSON, or wrong message"
        return 1
    fi
}

#
# Update (PUT) ...............................................................
#

#   - /quotes/ updated quote (id, quote, author_id, category_id)
quotes_put__valid_fields() {
    local -A args=(
        [id]="1"
        [author_id]="5"
        [category_id]="5"
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
   
    # Prepare request to get original data
    local -A o_args=(
        [id]="1"
    )
    local o_url=$(get_url "quotes" o_args)
   
    # Save original data
    local o_response=$(curl -s -X GET -w "\n%{http_code}" "${o_url}")
    local o_body=$(echo "$o_response" | sed '$d')
    local o_quote=$(echo "$o_body" | jq -r '.quote')
    local o_aid=$(echo "$o_body" | jq -r '.author_id')
    local o_cid=$(echo "$o_body" | jq -r '.category_id')
   
    # Execute update
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local quote=$(echo "$body" | jq -r '.quote')
    local author_id=$(echo "$body" | jq -r '.author_id')
    local category_id=$(echo "$body" | jq -r '.category_id')

    # Restore original data
    local -A r_args=(
        [id]="1"
        [author_id]="${o_aid}"
        [category_id]="${o_cid}"
        [quote]="${o_quote}"
    )
    local r_url=$(get_url "quotes" r_args)
    curl -s -X PUT "${r_url}" >>/dev/null

    if [[ "$status" == "200" ]] && [[ "$author_id" == "5" ]] && [[ "$category_id" == "5" ]] && [[ "$quote" == "foobarbaz" ]]; then
        echo -e "\tValid JSON response with correct data"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 200, invalid JSON, or incorrect data"
        return 1
    fi
}

#   - author_id does not exist { message: ‘author_id Not Found’ }
quotes_put__404_author_id() {
    local -A args=(
        [id]=1
        [author_id]="42069"  # ID must not exist
        [category_id]="1"
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="author_id Not Found"
    
    if [[ "$status" == "404" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 404 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 404, invalid JSON, or missing fields, or incorrect message"
        return 1
    fi
}

#   - category_id does not exist { message: ‘category_id Not Found’ }
quotes_put__404_category_id() {
    local -A args=(
        [id]=1
        [author_id]="1"
        [category_id]="42069"  # ID must not exist
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="category_id Not Found"
    
    if [[ "$status" == "404" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 404 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 404, invalid JSON, or missing fields, or incorrect message"
        return 1
    fi
}

#   - If no quotes found to update { message: ‘No Quotes Found’ }
quotes_put__404_none_found() {
    local -A args=(
        [id]="42069" # ID must not exist
        [author_id]="1"
        [category_id]="1"
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="No Quotes Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON response with correct message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 404, invalid JSON, or wrong message"
        return 1
    fi
}

#   - If missing any parameters { message: ‘Missing Required Parameters’ }
quotes_put__422_missing_params() {
    local -A args=(
        [quote]="foobarbaz"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or incorrect message"
        return 1
    fi
}

#
# Delete (DELETE) ............................................................
#
#   - /api/quotes/ id of deleted quote
quotes_delete__by_id() {
    local -A o_args=(
        [quote]="foobarbaz"
        [author_id]="1"
        [category_id]="1"
    )
    local o_url=$(get_url "quotes" o_args)
    local o_response=$(curl -s -X POST -w "\n%{http_code}" "${o_url}")
    local o_body=$(echo "$o_response" | sed '$d')
    local o_status=$(echo "$o_response" | tail -n1)
    local o_id=$(echo "$o_body" | jq -r '.id')

    local -A args=(
        [id]="${o_id}"
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')
    
    if [[ "$status" == "200" ]] && [[ $id == $o_id ]]; then
        echo -e "\tValid JSON response with correct id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 200, invalid JSON, or wrong id returned"
        return 1
    fi
}

#   - If no quotes found to delete { message: ‘No Quotes Found’ }
quotes_delete__404_none_found() {
    local -A args=(
        [id]="42069"  # ID must not exist
    )
    local url=$(get_url "quotes" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="No Quotes Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON 404 message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 404, invalid JSON, or wrong message"
        return 1
    fi
}

#   - If missing any parameters { message: ‘Missing Required Parameters’ }
quotes_delete__422_missing_params() {
    local url=$(get_url "quotes")
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON 422 message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 422 or wrong message"
        return 1
    fi
}

# ============================================================================
# authors
# ============================================================================

# C.) All requests for authors should return the id and author fields.
#
# Create (POST) ..............................................................
#
#   - /authors/ created author (id, author)
authors_post__valid_fields() {
    local -A args=(
        [author]="Boe Jiden"
    )
    local url=$(get_url "authors" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')

    authors_delete $id >>/dev/null

    fields=("id" "author")
    
    if [[ "$status" == "200" ]] && json_has_fields "$body" fields; then
        echo -e "\tValid JSON for 200 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 200, invalid JSON, or missing fields"
        return 1
    fi
}

#   -If missing any parameters { message: ‘Missing Required Parameters’ }
authors_post__422_missing_params() {
    local url=$(get_url "authors")
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or wrong message"
        return 1
    fi
}

#
# Read (GET) .................................................................
#

#   - /authors/ All authors with their id
#     Expect >= 5 items returned in array
authors_get__all_returned() {
    local url=$(get_url "authors")
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local count=$(echo "$body" | jq 'length')
    local expected=5
    
    if [[ "$status" == "200" ]] && [[ $count -ge $expected ]]; then
        echo -e "\tValid JSON response with >=5 results"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tCount: ${count}\n\tStatus not 200, invalid JSON, or less than 5 results returned"
        return 1
    fi
}

#   - /authors/?id=5 The specific author with their id
authors_get__by_id() {
    local -A args=(
        [id]="5"
    )
    local url=$(get_url "authors" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')
    local expected=5
    
    if [[ "$status" == "200" ]] && [[ $id == $expected ]]; then
        echo -e "\tValid JSON response with correct id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 200, invalid JSON, or wrong id returned"
        return 1
    fi
}

#   - If no authors found for routes above { message: ‘author_id Not Found’ }
authors_get__404_id() {
    local -A args=(
        [id]="42069"  # ID must not exist
    )
    local url=$(get_url "authors" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="author_id Not Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON response with correct message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 404 or wrong message"
        return 1
    fi
}

#
# Update (PUT) ...............................................................
#

#   - /authors/ updated author (id, author)
authors_put__valid_fields() {
    local -A args=(
        [id]="1"
        [author]="Boe Jiden"
    )
    local url=$(get_url "authors" args)
    echo -e "\t${url}"
   
    # Prepare request to get original data
    local -A o_args=(
        [id]="1"
    )
    local o_url=$(get_url "authors" o_args)
   
    # Save original data
    local o_response=$(curl -s -X GET -w "\n%{http_code}" "${o_url}")
    local o_body=$(echo "$o_response" | sed '$d')
    local o_author=$(echo "$o_body" | jq -r '.author')
   
    # Execute update
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local author=$(echo "$body" | jq -r '.author')

    # Restore original data
    local -A r_args=(
        [id]="1"
        [author]="${o_author}"
    )
    local r_url=$(get_url "authors" r_args)
    curl -s -X PUT "${r_url}" >>/dev/null

    if [[ "$status" == "200" ]] && [[ "$author" == "Boe Jiden" ]]; then
        echo -e "\tValid JSON response with correct data"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 200, invalid JSON, or incorrect data"
        return 1
    fi
}

#   - If missing any parameters { message: ‘Missing Required Parameters’ }
authors_put__422_missing_params() {
    local url=$(get_url "authors")
    echo -e "\t${url}"
    
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or incorrect message"
        return 1
    fi
}

#
# Delete (DELETE) ............................................................
#

#   - /api/authors/ id of deleted author
authors_delete__by_id() {
    local -A o_args=(
        [author]="foobarbaz"
    )
    local o_url=$(get_url "authors" o_args)
    local o_response=$(curl -s -X POST -w "\n%{http_code}" "${o_url}")
    local o_body=$(echo "$o_response" | sed '$d')
    local o_status=$(echo "$o_response" | tail -n1)
    local o_id=$(echo "$o_body" | jq -r '.id')

    local -A args=(
        [id]="${o_id}"
    )
    local url=$(get_url "authors" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')
    
    if [[ "$status" == "200" ]] && [[ $id == $o_id ]]; then
        echo -e "\tValid JSON response with correct id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 200, invalid JSON, or wrong id returned"
        return 1
    fi
}

#   - If no authors found to delete { message: ‘No Authors Found’ }
authors_delete__404_none_found() {
    local -A args=(
        [id]="42069"  # ID must not exist
    )
    local url=$(get_url "authors" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="No Authors Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON 404 message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 404, invalid JSON, or wrong message"
        return 1
    fi
}

#   - If missing any parameters { message: ‘Missing Required Parameters’ }
authors_delete__422_missing_params() {
    local url=$(get_url "authors")
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or incorrect message"
        return 1
    fi
}

# ============================================================================
# categories
# ============================================================================

# D.) All requests for categories should return the id and category fields.
#
# Create (POST) ..............................................................
# 

#   - /categories/ created category (id, category)
categories_post__valid_fields() {
    local -A args=(
        [category]="HTML rUl3z d00d!"
    )
    local url=$(get_url "categories" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')

    categories_delete $id >>/dev/null

    fields=("id" "category")
    
    if [[ "$status" == "200" ]] && json_has_fields "$body" fields; then
        echo -e "\tValid JSON for 200 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 200, invalid JSON, or missing fields"
        return 1
    fi
}
#   -If missing any parameters { message: ‘Missing Required Parameters’ }
categories_post__422_missing_params() {
    local url=$(get_url "categories")
    echo -e "\t${url}"
    
    local response=$(curl -s -X POST -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or wrong message"
        return 1
    fi
}

#
# Read (GET) .................................................................
#   
#   - /categories/ All categories with their ids (id, category)
#     Expect >= 5 items returned in array
categories_get__all_returned() {
    local url=$(get_url "categories")
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local count=$(echo "$body" | jq 'length')
    local expected=5
    
    if [[ "$status" == "200" ]] && [[ $count -ge $expected ]]; then
        echo -e "\tValid JSON response with >=5 results"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tCount: ${count}\n\tStatus not 200, invalid JSON, or less than 5 results returned"
        return 1
    fi
}

#   - /categories/?id=3 The specific category with its id
categories_get__by_id() {
    local -A args=(
        [id]="3"
    )
    local url=$(get_url "categories" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')
    local expected=3
    
    if [[ "$status" == "200" ]] && [[ $id == $expected ]]; then
        echo -e "\tValid JSON response with correct id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 200, invalid JSON, or wrong id returned"
        return 1
    fi
}

#   - If no categories found for routes above { message: ‘category_id Not Found’ }
categories_get__404_id() {
    local -A args=(
        [id]="42069"  # ID must not exist
    )
    local url=$(get_url "categories" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X GET -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="category_id Not Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON response with correct message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 404 or wrong message"
        return 1
    fi
}

#
# Update (PUT) ...............................................................
#

#   - /categories/ updated category (id, category)
categories_put__valid_fields() {
    local -A args=(
        [id]="1"
        [category]="HTML rUl3z d00d!"
    )
    local url=$(get_url "categories" args)
    echo -e "\t${url}"
   
    # Prepare request to get original data
    local -A o_args=(
        [id]="1"
    )
    local o_url=$(get_url "categories" o_args)
   
    # Save original data
    local o_response=$(curl -s -X GET -w "\n%{http_code}" "${o_url}")
    local o_body=$(echo "$o_response" | sed '$d')
    local o_category=$(echo "$o_body" | jq -r '.category')
   
    # Execute update
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local category=$(echo "$body" | jq -r '.category')

    # Restore original data
    local -A r_args=(
        [id]="1"
        [category]="${o_category}"
    )
    local r_url=$(get_url "categories" r_args)
    curl -s -X PUT "${r_url}" >>/dev/null

    if [[ "$status" == "200" ]] && [[ "$category" == "HTML rUl3z d00d!" ]]; then
        echo -e "\tValid JSON response with correct data"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 200, invalid JSON, or incorrect data"
        return 1
    fi
}

#   - If missing any parameters { message: ‘Missing Required Parameters’ }
categories_put__422_missing_params() {
    local url=$(get_url "categories")
    echo -e "\t${url}"
    
    local response=$(curl -s -X PUT -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or incorrect message"
        return 1
    fi
}

#
# Delete (DELETE) ............................................................
#

#   - /api/categories/ id of deleted category
categories_delete__by_id() {
    local -A o_args=(
        [category]="HTML rUl3z d00d!"
    )
    local o_url=$(get_url "categories" o_args)
    local o_response=$(curl -s -X POST -w "\n%{http_code}" "${o_url}")
    local o_body=$(echo "$o_response" | sed '$d')
    local o_status=$(echo "$o_response" | tail -n1)
    local o_id=$(echo "$o_body" | jq -r '.id')

    local -A args=(
        [id]="${o_id}"
    )
    local url=$(get_url "categories" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local id=$(echo "$body" | jq -r '.id')
    
    if [[ "$status" == "200" ]] && [[ $id == $o_id ]]; then
        echo -e "\tValid JSON response with correct id"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 200, invalid JSON, or wrong id returned"
        return 1
    fi
}

#   - If no quotes found to delete { message: ‘No Categories Found’ }
categories_delete__404_none_found() {
    local -A args=(
        [id]="42069"  # ID must not exist
    )
    local url=$(get_url "categories" args)
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="No Categories Found"
    
    if [[ "$status" == "404" ]] && [[ $message == $expected ]]; then
        echo -e "\tValid JSON 404 message"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tid: ${id}\n\tStatus not 404, invalid JSON, or wrong message"
        return 1
    fi
}

#   - If missing any parameters { message: ‘Missing Required Parameters’ }
categories_delete__422_missing_params() {
    local url=$(get_url "categories")
    echo -e "\t${url}"
    
    local response=$(curl -s -X DELETE -w "\n%{http_code}" "${url}")
    local body=$(echo "$response" | sed '$d')
    local status=$(echo "$response" | tail -n1)
    local message=$(echo "$body" | jq -r '.message')
    local expected="Missing Required Parameters"
    
    if [[ "$status" == "422" ]] && [[ "$message" == "$expected" ]]; then
        echo -e "\tValid JSON message for 422 response"
        return 0
    else
        echo -e "\t${status}\n\t${body}\n\tStatus not 422 or incorrect message"
        return 1
    fi
}

# ============================================================================
# EXECUTION
# ============================================================================

tests=(
    "general__500_json_valid"
    "quotes_post__valid_fields"
    "quotes_post__404_author_id"
    "quotes_post__404_category_id"
    "quotes_post__422_missing_params"
    "quotes_get__all_returned"
    "quotes_get__by_id"
    "quotes_get__by_author_id"
    "quotes_get__by_category_id"
    "quotes_get__by_author_id_and_category_id"
    "quotes_get__404_none_found"
    "quotes_put__valid_fields"
    "quotes_put__404_author_id"
    "quotes_put__404_category_id"
    "quotes_put__404_none_found"
    "quotes_post__422_missing_params"
    "quotes_delete__by_id"
    "quotes_delete__404_none_found"
    "quotes_delete__422_missing_params"
    "authors_post__valid_fields"
    "authors_post__422_missing_params"
    "authors_get__all_returned"
    "authors_get__by_id"
    "authors_get__404_id"
    "authors_put__valid_fields"
    "authors_put__422_missing_params"
    "authors_delete__by_id"
    "authors_delete__404_none_found"
    "authors_delete__422_missing_params"
    "categories_post__valid_fields"
    "categories_post__422_missing_params"
    "categories_get__all_returned"
    "categories_get__by_id"
    "categories_get__404_id"
    "categories_put__valid_fields"
    "categories_put__422_missing_params"
    "categories_delete__by_id"
    "categories_delete__404_none_found"
    "categories_delete__422_missing_params"
)

test_keys=(
    "General - Status 500 JSON"
    "Quotes - POST Valid Fields"
    "Quotes - POST 404 author_id"
    "Quotes - POST 404 category_id"
    "Quotes - POST 422 Missing Parameters"
    "Quotes - GET All Returned"
    "Quotes - GET By id"
    "Quotes - GET By author_id"
    "Quotes - GET By category_id"
    "Quotes - GET By author_id And category_id"
    "Quotes - GET 404 None Found"
    "Quotes - PUT Update Valid"
    "Quotes - PUT 404 author_id"
    "Quotes - PUT 404 category_id"
    "Quotes - PUT 404 None Found"
    "Quotes - PUT 422 Missing Parameters"
    "Quotes - DELETE By id"
    "Quotes - DELETE 404 None Found"
    "Quotes - DELETE 422 Missing Parameters"
    "Authors - POST JSON Fields"
    "Authors - POST 422 Missing Parameters"
    "Authors - GET All Returned"
    "Authors - GET By id"
    "Authors - GET 404 id"
    "Authors - PUT Valid Fields"
    "Authors - PUT 422 Missing Parameters"
    "Authors - DELETE By id"
    "Authors - DELETE 404 None Found"
    "Authors - DELETE 422 Missing Parameters"
    "Categories - POST JSON Fields"
    "Categories - POST 422 Missing Parameters"
    "Categories - GET All Returned"
    "Categories - GET By id"
    "Categories - GET 404 id"
    "Categories - PUT Valid Fields"
    "Categories - PUT 422 Missing Parameters"
    "Categories - DELETE By id"
    "Categories - DELETE 404 None Found"
    "Categories - DELETE 422 Missing Parameters"
)

pass_count=0
fail_count=0
total_count=0

green=$'\033[0;32m'
red=$'\033[0;31m'
reset=$'\033[0m'

get_header() {
    local label="$1"
    local len=${#label}

    printf '%*s\n' "$len" '' | tr ' ' '='
    echo "$label"
    printf '%*s\n' "$len" '' | tr ' ' '='
}

run_test() {
    local label="$1"
    local fn="$2"

    ((total_count++))

    get_header "${label}"

    if "$fn"; then
        echo -e "\t${green}PASS${reset}"
        ((pass_count++))
    else
        echo -e "\t${red}FAIL${reset}"
        ((fail_count++))
    fi

    echo
}

run_tests() {
    if [[ -n "${1:-}" ]]; then
        local -n local_tests=$1
        local -n local_test_keys=$2

        for i in "${!local_test_keys[@]}"; do
            run_test "${local_test_keys[$i]}" "${local_tests[$i]}"
        done
    fi
}

run_tests tests test_keys

echo "Results:"
echo -e "\tTotal: $total_count"
echo -e "\t${green}Passed: $pass_count${reset}"
echo -e "\t${red}Failed: $fail_count${reset}"

if (( fail_count > 0 )); then
    exit 1
else
    exit 0
fi
