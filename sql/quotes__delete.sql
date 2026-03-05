DELETE FROM quotes
WHERE id = :id
RETURNING id;
