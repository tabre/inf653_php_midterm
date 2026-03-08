<?php
require_once'Endpoint.php';

class QuotesEndpoint extends Endpoint {
    public $required_fields = array(
        "GET" => [],
        "HEAD" => [],
        "POST" => ["quote", "author_id", "category_id"],
        "PUT" => ["id", "quote", "author_id", "category_id"],
        "DELETE" => ["id"],
        "CONNECT" => [],
        "OPTIONS" => [],
        "TRACE" => [],
        "PATH" => []
    );
    function get($context): Response {
        global $server;

        $id = $context->get_param("id");
        $rnd = $context->get_param("random");

        if (!is_null($id) ||
            $context->has_params(["author_id"]) ||
            $context->has_params(["category_id"])) {
            $result = $server->db->prep_query(
                "quotes",
                "select",
                array(
                    "id" => $context->get_param("id"),
                    "author_id" => $context->get_param("author_id"),
                    "category_id" => $context->get_param("category_id")
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
            
            return $this->get_message_response(200, "No Quotes Found");

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

        try {
            $result = $server->db->prep_query(
                "quotes",
                "insert",
                array(
                    "quote" => $context->get_param("quote"),
                    "author_id" => $context->get_param("author_id"),
                    "category_id" => $context->get_param("category_id")
                )
            );
        } catch (Exception $e) {
            error_log($e->getMessage()); 

            $sub_result = $server->db->prep_query(
                "authors",
                "select_id",
                array(
                    "id" => $context->get_param("author_id")
                )
            );

            if (count($sub_result) === 0) {
                return $this->get_message_response(200, "author_id Not Found");
            }

            $sub_result = $server->db->prep_query(
                "categories",
                "select_id",
                array(
                    "id" => $context->get_param("category_id")
                )
            );

            if (count($sub_result) === 0) {
                return $this->get_message_response(200, "category_id Not Found");
            }
            
        }

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(500, "Error while inserting quote");
    }
    
    function put($context): Response {
        global $server;

        try {
            $sub_result = $server->db->prep_query(
                "quotes",
                "select_id",
                array(
                    "id" => $context->get_param("id")
                )
            );

            if (count($sub_result) === 0) {
                return $this->get_message_response(200, "No Quotes Found");
            }

        } catch (Exception $e) {
                return this->get_message_response(200, $e->getMessage());
        }

        try {
            $result = $server->db->prep_query(
                "quotes",
                "update",
                array(
                    "id" => $context->get_param("id"),
                    "quote" => $context->get_param("quote"),
                    "author_id" => $context->get_param("author_id"),
                    "category_id" => $context->get_param("category_id")
                )
            );
        } catch (Exception $e) {

            $sub_result = $server->db->prep_query(
                "authors",
                "select_id",
                array(
                    "id" => $context->get_param("author_id")
                )
            );

            if (count($sub_result) === 0) {
                return $this->get_message_response(200, "author_id Not Found");
            }

            $sub_result = $server->db->prep_query(
                "categories",
                "select_id",
                array(
                    "id" => $context->get_param("category_id")
                )
            );

            if (count($sub_result) === 0) {
                return $this->get_message_response(200, "category_id Not Found");
            }
            
        }

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(500, "Error while updating quote");
    }

    function delete($context): Response {
        global $server;

        $result = $server->db->prep_query(
            "quotes",
            "delete",
            array("id" => $context->get_param("id"))
        );

        if (count($result) > 0) {
            return new Response(body: json_encode($result[0]));
        }

        return $this->get_message_response(200, "No Quotes Found");
    }
}
