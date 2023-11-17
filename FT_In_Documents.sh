########################## Documents ##########################

# Create a table for storing data (notice the tsvector data type for the document_tokens column)

CREATE TABLE documents  
(
    document_id SERIAL,
    document_text TEXT,
    document_tokens TSVECTOR,

    CONSTRAINT documents_pkey PRIMARY KEY (document_id)
)

# Insert the documents into it

INSERT INTO documents (document_text) VALUES  
('The greatest glory in living lies not in never falling, but in rising every time we fall. -Nelson Mandela'),
('The way to get started is to quit talking and begin doing. -Walt Disney'),
('When you reach the end of your rope, tie a knot in it and hang on. -Franklin D. Roosevelt'),
('Never let the fear of striking out keep you from playing the game. -Babe Ruth'),
('You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose. -Dr. Seuss'),
('Life is a long lesson in humility. -James M. Barrie');

# The output will be

INSERT 0 6

# Finally, a little UPDATE command will conveniently populate the tokens column

UPDATE documents d1  
SET document_tokens = to_tsvector(d1.document_text)  
FROM documents d2; 

SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ websearch_to_tsquery('begin doing'); 


SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('hang & on'); 

# There should be one document in the result


SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('long <-> lesson'); 


# One document with the term "long lesson"


SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('direction <2> choose'); 

# One document with "direction you choose"


SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('fear <3> out'); 

# One document with "fear of striking out"


------------------------------------------------

# Rank

SELECT document_text, ts_rank(to_tsvector(document_text), to_tsquery('life|fear')) AS rank
FROM documents
ORDER BY rank DESC
LIMIT 10;



SELECT document_text, ts_rank(to_tsvector(document_text), to_tsquery('never')) AS rank
FROM documents
ORDER BY rank DESC
LIMIT 10;