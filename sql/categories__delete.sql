DELETE FROM categories
WHERE id = :id
RETURNING id;
