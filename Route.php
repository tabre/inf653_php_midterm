<?php
class Route {
    public $path;
    public $endpoint;

    function __construct($path, $endpoint) {
        $this->path = $path;
        $this->endpoint = $endpoint; 
    }
}
?>
