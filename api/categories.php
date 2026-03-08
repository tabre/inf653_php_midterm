<?php
require_once'Endpoint.php';

class CategoriesEndpoint extends Endpoint {
    public $required_fields = array(
        "GET" => [],
        "HEAD" => [],
        "POST" => ["category"],
        "PUT" => ["id", "category"],
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
                "categories",
                "select_id",
                array("id" => $context->get_param("id"))
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }
            
            return $this->get_message_response(200, "category_id Not Found");

        } else {
            return new Response(
                body: json_encode($server->db->query("categories", "select_all"))
            );
        }
    }

    function post($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "categories",
            "insert",
            array("category" => $context->get_param("category"))
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(500, "Error while inserting category");
    }

    function put($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "categories",
            "update",
            array(
                "id" => $context->get_param("id"),
                "category" => $context->get_param("category")
            )
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(500, "Error while inserting category");
    }

    function delete($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "categories",
            "delete",
            array("id" => $context->get_param("id"))
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(200, "No Categories Found");
    }
}
