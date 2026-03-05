<?php

class Table {
    public array $statements = [];

    public function __construct(private string $table_name) {
        $this->load_statements();
    }

    private function load_statements(): void {
        $sqlDir = __DIR__ . '/sql';
        $files = glob($sqlDir . '/' . $this->table_name . '__*.sql');

        foreach ($files as $file) {
            $basename = basename($file);
            $parts = explode('__', $basename);
            $operation = str_replace('.sql', "", $parts[1]);
            $this->statements[$operation] = file_get_contents($file);
        }
    }    
}
