CREATE TABLE IF NOT EXISTS quotes(
    id serial4 NOT NULL,
    quote varchar(1024) NOT NULL,
    author_id int4 NOT NULL,
    category_id int4 NOT NULL,
    CONSTRAINT quotes_pkey PRIMARY KEY (id),
    FOREIGN KEY (author_id) REFERENCES authors(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE OR REPLACE FUNCTION quotes_select(
    p_id int4 DEFAULT NULL,
    p_author_id int4 DEFAULT NULL,
    p_category_id int4 DEFAULT NULL
)
RETURNS TABLE (id int4, quote varchar(1024), author varchar(255), category varchar(255)) AS $$
BEGIN
    RETURN QUERY
    SELECT q.id, q.quote, a.author, c.category
    FROM quotes q
    LEFT JOIN authors a ON q.author_id = a.id
    LEFT JOIN categories c ON q.category_id = c.id
    WHERE (p_id IS NULL OR q.id = p_id)
      AND (p_author_id IS NULL OR q.author_id = p_author_id)
      AND (p_category_id IS NULL OR q.category_id = p_category_id);
END;
$$ LANGUAGE plpgsql;
