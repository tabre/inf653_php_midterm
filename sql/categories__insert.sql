INSERT INTO categories(category)
VALUES(:category)
RETURNING *;
