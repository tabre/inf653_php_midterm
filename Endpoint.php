<?php
require_once 'Response.php';

class Endpoint {
    public $status_codes;
    public $required_fields = array(
        "GET" => [],
        "HEAD" => [],
        "POST" => [],
        "PUT" => [],
        "DELETE" => [],
        "CONNECT" => [],
        "OPTIONS" => [],
        "TRACE" => [],
        "PATH" => []
    );
 
    function __construct() {
        $this->status_codes = array(
            100 => "Continue",
            101 => "Switching Protocols",
            102 => "Processing",
            103 => "Early Hints",
            104 => "Upload Resumption Supported",
            // 105 - 199 Unassigned
            200 => "OK",
            201 => "Created",
            202 => "Accepted",
            203 => "Non-Authoritative Information",
            204 => "No Content",
            205 => "Reset Content",
            206 => "Partial Content",
            207 => "Multi-Status",
            208 => "Already Reported",
            // 209 - 225 Unassigned
            226 => "IM Used",
            // 227 - 299 Unassigned
            300 => "Multiple Choices",
            301 => "Moved Permanently",
            302 => "Found",
            303 => "See Other",
            304 => "Not Modified",
            305 => "Use Proxy",
            // 306 Unused
            307 => "Temporary Redirect",
            308 => "Permanent Redirect",
            // 309 - 399 Unassigned
            400 => "Bad Request",
            401 => "Unauthorized",
            402 => "Payment Required",
            403 => "Forbidden",
            404 => "Not Found",
            405 => "Method Not Allowed",
            406 => "Not Acceptable",
            407 => "Proxy Authentication Required",
            408 => "Request Timeout",
            409 => "Conflict",
            410 => "Gone",
            411 => "Length Required",
            412 => "Precondition Failed",
            413 => "Content Too Large",
            414 => "URI Too Long",
            415 => "Unsupported Media Type",
            416 => "Range Not Satisfiable",
            417 => "Expectation Failed",
            // 419 -420 Unassigned
            421 => "Misdirected Requested",
            422 => "Unprocessable Content",
            423 => "Locked",
            424 => "Failed Dependency",
            425 => "Too Early",
            426 => "Upgrade Required",
            // 427 Unassigned
            428 => "Precondition Required",
            429 => "Too Many Requests",
            431 => "Request Handler Fields Too Large",
            // 432 - 450 Unassigned
            451 => "Unavailable For Legal Reasons",
            // 452 - 499 Unassigned
            500 => "Internal Server Error",
            501 => "Not Implemented",
            502 => "Bad Gateway",
            503 => "Service Unavailable",
            504 => "Gateway Timeout",
            505 => "HTTP Version Not Supported",
            506 => "Variant Also Negotiates",
            507 => "Insufficient Storage",
            508 => "Loop Detected",
            // 509 Unassigned
            510 => "Not Extended",
            511 => "Network Authentication Required"
            // 512 - 599 Unassigned
        );
    }

    function get($context): Response {
        return $this->get_405_response($context);
    }
    
    function head($context): Response {
        return $this->get_405_response($context);
    }

    function post($context): Response {
        return $this->get_405_response($context);
    }

    function put($context): Response {
        return $this->get_405_response($context);
    }

    function delete($context): Response {
        return $this->get_405_response($context);
    }

    function connect($context): Response {
        return $this->get_405_response($context);
    }

    function options($context): Response{
        return $this->get_generic_response(200, "OK");
    }

    function trace($context): Response {
        return $this->get_405_response($context);
    }

    function path($context): Response {
        return $this->get_405_response($context);
    }
    
    function get_405_response($context): Response {
        return $this->get_generic_response(
            405, $context->method . " method is not allowed for this endpoint"
        );
    }
    
    function get_generic_response($status_code, $message): Response {
        $body = json_encode(array(
            "status_code" => $status_code,
            "status" => $this->status_codes[$status_code],
            "message" => $message
        )); 
        
        return new Response(
            status_code: $status_code,
            content_type: "application/json",
            body: $body
        );
    }

    function get_message_response($status_code, $message): Response {
        return new Response(
            status_code: $status_code,
            content_type: "application/json",
            body: json_encode(array("message" => $message))
        );
    }

    function context_valid($context): bool {
        return $context->has_params($this->required_fields[$context->method]);
    }

    function handle($context): void {
        if (!$this->context_valid($context)) {
            $response = $this->get_message_response(200, "Missing Required Parameters"); 
        } else {
            try {
                switch ($context->method) {
                    case "GET":
                        $response = $this->get($context);
                        break;
                    case "HEAD":
                        $response = $this->head($context);
                        break;
                    case "POST":
                        $response = $this->post($context);
                        break;
                    case "PUT":
                        $response = $this->put($context);
                        break;
                    case "DELETE":
                        $response = $this->delete($context);
                        break;
                    case "CONNECT":
                        $response = $this->connect($context);
                        break;
                    case "OPTIONS":
                        $response = $this->options($context);
                        break;
                    case "TRACE":
                        $response = $this->trace($context);
                        break;
                    case "PATH":
                        $response = $this->path($context);
                        break;
                    default:
                        $response = $this->get_generic_response(
                            400, "Unrecognized request method: " + $context->method
                        );
                }
            } catch (Exception $e) {
                $msg = $e->getMessage();
                error_log($msg);

                $response = $this->get_generic_response(
                    500, "An error occurred during processing: " . $msg
                );
            }
        }
        
        http_response_code($response->status_code);
        header("Content-Type: " . $response->content_type);

        echo $response->body;
    }
} 
