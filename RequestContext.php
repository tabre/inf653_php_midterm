<?php
class RequestContext {
    public $method;
    public $headers;
    public $body;
    public $params;
    
    function __construct() {
        $this->method = $_SERVER['REQUEST_METHOD'];
        $this->headers = $this->get_headers();
        $this->body = json_decode(file_get_contents("php://input"));
        $this->params = $_GET;
    }

    function get_headers() {
        $headers = [];

        foreach ($_SERVER as $key => $value) {

            if (strpos($key, 'HTTP_') === 0) {
                $name = substr($key, 5);
                $name = str_replace('_', '-', $name);
                $headers[$name] = $value;
            }

            // handle special headers not prefixed with HTTP_
            if ($key === 'CONTENT_TYPE' || $key === 'CONTENT_LENGTH') {
                $name = str_replace('_', '-', $key);
                $headers[$name] = $value;
            }
        }

        $this->headers = $headers;
    }
    
}
