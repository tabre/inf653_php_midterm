<?php
require_once'Endpoint.php';

class QuotesEndpoint extends Endpoint {
    function get($context): Response {
        global $server;

        $id = $context->params["id"];
        $rnd = $context->params["random"];

        if (!is_null($id) ||
            array_key_exists("author_id", $context->params) ||
            array_key_exists("category_id", $context->params)) {
            $result = $server->db->prep_query(
                "quotes",
                "select",
                array(
                    "id" => $context->params["id"],
                    "author_id" => $context->params["author_id"],
                    "category_id" => $context->params["category_id"]
                )
            );

            if (count($result) > 0) {
                if (!is_null($id)) {
                    return new Response(body: json_encode($result[0]));
                }

                if (strcmp($rnd, "true") === 0) {
                    $i = rand(0, count($result) - 1);
                    return new Response(body: json_encode($result[$i]));
                }

                return new Response(body: json_encode($result));
            }
            
            return $this->get_message_response(404, "No Quotes Found");

        } else {
            $result = $server->db->query("quotes", "select_all");

            if (strcmp($rnd, "true") === 0) {
                $i = rand(0, count($result) - 1);
                return new Response(body: json_encode($result[$i]));
            }

            return new Response(body: json_encode($result));
        }
    }
    
    function post($context): Response {
        global $server;

        if (array_key_exists("quote", $context->params) &&
            array_key_exists("author_id", $context->params) &&
            array_key_exists("category_id", $context->params)
        ) {
            $result = $server->db->prep_query(
                "quotes",
                "insert",
                array(
                    "quote" => $context->params["quote"],
                    "author_id" => $context->params["author_id"],
                    "category_id" => $context->params["category_id"]
                )
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(500, "Error while inserting quote");

        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }
    
    function put($context): Response {
        global $server;

        if (array_key_exists("id", $context->params) &&
            array_key_exists("quote", $context->params) &&
            array_key_exists("author_id", $context->params) &&
            array_key_exists("category_id", $context->params)
        ) {
            $result = $server->db->prep_query(
                "quotes",
                "update",
                array(
                    "id" => $context->params["id"],
                    "quote" => $context->params["quote"],
                    "author_id" => $context->params["author_id"],
                    "category_id" => $context->params["category_id"]
                )
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(500, "Error while inserting quote");

        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }

    function delete($context): Response {
        global $server;

        if (array_key_exists("id", $context->params)) {
            $result = $server->db->prep_query(
                "quotes",
                "delete",
                array("id" => $context->params["id"])
            );

            if (count($result) > 0) {
                return new Response(body: json_encode($result[0]));
            }

            return $this->get_message_response(404, "No Quotes Found");
        } else {
            return $this->get_message_response(422, "Missing Required Parameters");
        }
    }
}
