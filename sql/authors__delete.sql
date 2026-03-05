DELETE FROM authors
WHERE id = :id
RETURNING id;
