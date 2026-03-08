<?php
require_once'Endpoint.php';

class AuthorsEndpoint extends Endpoint {
    public $required_fields = array(
        "GET" => [],
        "HEAD" => [],
        "POST" => ["author"],
        "PUT" => ["id", "author"],
        "DELETE" => ["id"],
        "CONNECT" => [],
        "OPTIONS" => [],
        "TRACE" => [],
        "PATH" => []
    );

    function get($context): Response {
        global $server;

        if ($context->has_params(["id"])) {
            $result = $server->db->prep_query(
                "authors",
                "select_id",
                array("id" => $context->get_param("id"))
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }
            
            return $this->get_message_response(200, "author_id Not Found");

        } else {
            return new Response(
                body: json_encode($server->db->query("authors", "select_all"))
            );
        }
    }

    function post($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "authors",
            "insert",
            array("author" => $context->get_param("author"))
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(500, "Error while inserting author");
    }
    
    function put($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "authors",
            "update",
            array(
                "id" => $context->get_param("id"),
                "author" => $context->get_param("author")
            )
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(500, "Error while inserting author");
    }
    
    function delete($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "authors",
            "delete",
            array("id" => $context->get_param("id"))
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(200, "No Authors Found");
    }
}
