<?php
require_once'Endpoint.php';

class CategoriesEndpoint extends Endpoint {
    function get($context): Response {
        global $server;

        if (array_key_exists("id", $context->params)) {
            $result = $server->db->prep_query(
                "categories",
                "select_id",
                array("id" => $context->params["id"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }
            
            return $this->get_message_response(404, "category_id Not Found");

        } else {
            return new Response(
                body: json_encode($server->db->query("categories", "select_all"))
            );
        }
    }

    function post($context): Response {
        global $server;

        if (array_key_exists("category", $context->params)) {
            $result = $server->db->prep_query(
                "categories",
                "insert",
                array("category" => $context->params["category"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(500, "Error while inserting category");

        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }

    function put($context): Response {
        global $server;

        if (array_key_exists("id", $context->params) &&
            array_key_exists("category", $context->params)
        ) {
            $result = $server->db->prep_query(
                "categories",
                "update",
                array(
                    "id" => $context->params["id"],
                    "category" => $context->params["category"]
                )
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(500, "Error while inserting category");

        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }

    function delete($context): Response {
        global $server;

        if (array_key_exists("id", $context->params)) {
            $result = $server->db->prep_query(
                "categories",
                "delete",
                array("id" => $context->params["id"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(404, "No Categories Found");
        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }
}
