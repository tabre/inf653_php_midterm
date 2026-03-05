CREATE TABLE IF NOT EXISTS categories(
    id serial4 NOT NULL,
    category varchar(64) NOT NULL,
    CONSTRAINT categories_pkey PRIMARY KEY (id),
    CONSTRAINT categories_category_key UNIQUE (category)
);
