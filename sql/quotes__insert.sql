INSERT INTO quotes(quote, author_id, category_id)
VALUES(:quote, :author_id, :category_id)
RETURNING *;
