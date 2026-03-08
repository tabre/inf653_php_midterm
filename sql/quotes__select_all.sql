SELECT
    q.id,
    q.quote,
    a.author,
    c.category
FROM quotes q
LEFT JOIN authors a on q.author_id = a.id
LEFT JOIN categories c on q.category_id = c.id;
