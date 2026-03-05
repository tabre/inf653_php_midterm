<?php
class Response {
    public $status_code;
    public $content_type;
    public $body;

    function __construct($status_code=200, $content_type="application/json", $body='{}') {
        $this->status_code = $status_code;
        $this->content_type = $content_type;
        $this->body = $body;
    }
}
