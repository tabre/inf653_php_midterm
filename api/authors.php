<?php
require_once'Endpoint.php';

class AuthorsEndpoint extends Endpoint {
    function get($context): Response {
        global $server;

        if (array_key_exists("id", $context->params)) {
            $result = $server->db->prep_query(
                "authors",
                "select_id",
                array("id" => $context->params["id"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }
            
            return $this->get_message_response(404, "author_id Not Found");

        } else {
            return new Response(
                body: json_encode($server->db->query("authors", "select_all"))
            );
        }
    }

    function post($context): Response {
        global $server;

        if (array_key_exists("author", $context->params)) {
            $result = $server->db->prep_query(
                "authors",
                "insert",
                array("author" => $context->params["author"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(500, "Error while inserting author");
        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }
    
    function put($context): Response {
        global $server;

        if (array_key_exists("id", $context->params) &&
            array_key_exists("author", $context->params)
        ) {
            $result = $server->db->prep_query(
                "authors",
                "update",
                array(
                    "id" => $context->params["id"],
                    "author" => $context->params["author"]
                )
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(500, "Error while inserting author");
        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }
    
    function delete($context): Response {
        global $server;

        if (array_key_exists("id", $context->params)) {
            $result = $server->db->prep_query(
                "authors",
                "delete",
                array("id" => $context->params["id"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(404, "No Authors Found");
        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }
}
