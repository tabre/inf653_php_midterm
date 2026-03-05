UPDATE authors
SET author = :author
WHERE id = :id
RETURNING *;
