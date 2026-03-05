UPDATE quotes
SET
    quote = :quote,
    author_id = :author_id,
    category_id = :category_id
WHERE id = :id
RETURNING *;
