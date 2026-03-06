#!/bin/bash

host="localhost"
port="8080"
base_url="http://${host}:${port}/api"
data_file="quotesdb.json"

source funcs.sh

authors_populate() {
    jq -rc '.authors[]' "$data_file" |
    while read -r author; do
        authors_insert "$author"
    done
}

categories_populate() {
    jq -rc '.categories[]' "$data_file" |
    while read -r author; do
        categories_insert "$author"
    done
}

quotes_populate() {
    jq -rc '.quotes[]' "$data_file" |
    while read -r quote; do
        quotes_insert "$quote"
    done
}

authors_populate
categories_populate
quotes_populate
