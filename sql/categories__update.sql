UPDATE categories
SET category = :category
WHERE id = :id
RETURNING *;
