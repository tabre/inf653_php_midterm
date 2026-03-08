<?php
require_once("Route.php");
require_once('authors.php');
require_once('categories.php');
require_once('quotes.php');

$d = '/api';

$authors_endpoint = new AuthorsEndpoint();
$categories_endpoint = new CategoriesEndpoint();
$quotes_endpoint = new QuotesEndpoint();

$server->register_routes([
    new Route($d . "/authors", $authors_endpoint),
    new Route($d . "/authors/", $authors_endpoint),
    new Route($d . "/categories", $categories_endpoint),
    new Route($d . "/categories/", $categories_endpoint),
    new Route($d . "/quotes", $quotes_endpoint),
    new Route($d . "/quotes/", $quotes_endpoint),
])
?>
