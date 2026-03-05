<?php
include 'Table.php';

class DatabaseManager {
    private $conn;
    private $host;
    private $port;
    private $dbname;
    private $username;
    private $password;
    private $tables;

    /**
     * @param string $dbname
     */
    public function __construct($dbname, $tables) {
        $this->dbname = $dbname;

        $this->username = getenv('POSTGRES_USER');
        $this->password = getenv('POSTGRES_PASSWORD');
        $this->host = getenv('POSTGRES_HOST');
        $this->port = getenv('POSTGRES_PORT');
        foreach ($tables as $table) {
            $this->tables[$table] = new Table($table);
            $this->exec($table, "create");
        }
    }

    private function connect(): PDO {
        if ($this->conn) {
            return $this->conn;

        } else {
            try {
                $this->conn = new PDO(
                    "pgsql:host={$this->host};
                     port={$this->port};
                     dbname={$this->dbname};",
                    $this->username,
                    $this->password
                );

                $this->conn->setAttribute(
                    PDO::ATTR_ERRMODE,
                    PDO::ERRMODE_EXCEPTION
                );

                return $this->conn;

            } catch(PDOException $e) {
                echo 'Connection Error: ' . $e->getMessage();
            }
        }
    }
    
    public function exec($table, $operation) {
        return $this->connect()->exec(
            $this->tables[$table]->statements[$operation]
        );
    }
    
    public function prep_exec($table, $operation, $payload) {
        $s = $this->connect()->prepare(
            $this->tables[$table]->statements[$operation]
        );

        return $s->execute($payload);
    }

    public function query($table, $operation) {
        $s = $this->connect()->query(
            $this->tables[$table]->statements[$operation]
        );

        return $s->fetchAll(PDO::FETCH_ASSOC); 
    }
    
    public function prep_query($table, $operation, $payload) {
        $s = $this->connect()->prepare(
            $this->tables[$table]->statements[$operation]
        );

        $s->execute($payload);
        
        return $s->fetchAll(PDO::FETCH_ASSOC);
    }
}
