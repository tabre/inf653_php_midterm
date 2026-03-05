<?php
require_once("Route.php");
require_once('authors.php');
require_once('categories.php');
require_once('quotes.php');

$d = '/api';

$server->register_routes([
    new Route($d . "/authors", new AuthorsEndpoint()),
    new Route($d . "/categories", new CategoriesEndpoint()),
    new Route($d . "/quotes", new QuotesEndpoint()),
])
?>
