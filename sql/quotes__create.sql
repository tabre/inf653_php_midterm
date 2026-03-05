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
RETURNS SETOF quotes AS $$
BEGIN
    RETURN QUERY
    SELECT q.id, q.quote, q.author_id, q.category_id
    FROM quotes q
    WHERE (p_id IS NULL OR q.id = p_id)
      AND (p_author_id IS NULL OR q.author_id = p_author_id)
      AND (p_category_id IS NULL OR q.category_id = p_category_id);
END;
$$ LANGUAGE plpgsql;
