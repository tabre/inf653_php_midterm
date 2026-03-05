<?php
include 'DatabaseManager.php';
include 'RequestContext.php';

class Server {
    public $db;
    public $routes;

    function __construct($dbname, $dbtables) {
        $this->db = new DatabaseManager($dbname, $dbtables);
        $this->routes = [];
    }
 
    function handle_request() {
        $uri = explode('?', $_SERVER['REQUEST_URI'])[0];

        if (array_key_exists($uri, $this->routes)) {
            $context = new RequestContext();
            $this->routes[$uri]->handle($context);
        } else {
            http_response_code(404);
            header("Content-Type: application/json");

            echo '{"status_code": 404, "status": "Not Found", "message": "Invalid path"}';
        }
    }
    
    function register_routes($routes) {
        foreach ($routes as $route) {
            if (!array_key_exists($route->path, $this->routes)) {
                $this->routes[$route->path] = $route->endpoint;
            } else { error_log(
                "Path, " . $route->path . ", already exists."
            );}
        }
    }
}
?>
