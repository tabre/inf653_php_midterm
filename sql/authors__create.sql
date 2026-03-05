CREATE TABLE IF NOT EXISTS authors(
    id serial4 NOT NULL,
    author varchar(64) NOT NULL,
    CONSTRAINT authors_pkey PRIMARY KEY (id),
    CONSTRAINT authors_author_key UNIQUE (author)
);
