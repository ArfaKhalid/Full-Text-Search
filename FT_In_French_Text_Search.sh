########################## IntroductionToFullTextSearch ##########################


CREATE TABLE online_courses
(
  id SERIAL PRIMARY KEY, 
  title TEXT NOT NULL, 
  description TEXT NOT NULL
);


INSERT INTO online_courses (title, description) VALUES
  ('Learning Java', 'A complete course that will help you learn Java in simple steps'),
  ('Advanced Java', 'Master advanced topics in Java, with hands-on examples'),
  ('Introduction to Machine Learning', 'Build and train simple machine learning models'),
  ('Learning Springboot', 'Build web applications in Java using SpringBoot'),
  ('Learning TensorFlow', 'Build and train deep learning models using TensorFlow 2.0'),
  ('Learning PyTorch', 'Build and train deep learning models using PyTorch'),
  ('Introduction to Self-supervised Machine Learning', 'Learn more from your unlabelled data'),
  ('Data Analytics and Visualization', 'Visualize, understand, and explore data using Python'),
  ('Learning SQL', 'Learn SQL programming in 21 days'),
  ('Learning C++', 'Take your first steps in C++ programming'),
  ('Learning Python', 'Take your first steps in Python programming'),
  ('Learning PostgreSQL', 'SQL programming using the PostgreSQL object-relational database'),
  ('Advanced PostgreSQL', 'Master advanced features in PostgreSQL');


SELECT 
    id,
    title,
    description
FROM 
    online_courses
WHERE  
    title LIKE '%java%' OR description LIKE '%java%';

# But it returned no results, since the LIKE is case-sensitive, which means we specify the upcase letter as saved in the table:

# Run the following command

SELECT 
    id,
    title,
    description
FROM 
    online_courses
WHERE  
    title LIKE '%Java%' OR description LIKE '%Java%';


# Use the ILIKE which is case-insensitive, 
# So there's no need to upcase as it will perform pattern matching on either capital and non-capital letters



SELECT 
    id,
    title,
    description
FROM 
    online_courses
WHERE  
    title ILIKE '%java%' OR description ILIKE '%java%';


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------



# tsvector
# The to_tsvector function parses an input text and converts it to the search type that represents a searchable document. For instance:
# Run the following query

SELECT to_tsvector('Visualize, understand, and explore data using Python');

# the result is a list of lexemes ready to be searched
# stop words ("in", "a", "the", etc) were removed
# the numbers are the position of the lexemes in the document

# tsquery
# The to_tsquery function parses an input text and converts it to the search type that represents a query. 
# For instance, the user wants to search "java in a nutshell":

SELECT to_tsquery('The & machine & learning');

# the result is a list of tokens ready to be queried
# stop words ("in", "a", "the", etc) were removed

SELECT websearch_to_tsquery('The machine learning');


# The @@ operator
# The @@ operator allows to match a query against a document and returns true or false.

# We can have tsquery @@ tsvector or tsvector @@ tsquery

# This will return "true"
SELECT 'machine & learning'::tsquery @@ 'Build and train simple machine learning models'::tsvector;

# This will return "false"
SELECT 'deep & learning'::tsquery @@ 'Build and train simple machine learning models'::tsvector;


# This will return "true"
SELECT 'Build and train simple machine learning models'::tsvector @@ 'models'::tsquery;

# This will return "false"
SELECT 'Build and train simple machine learning models'::tsvector @@ 'deep'::tsquery;


# We can use a tsquery to search against a tsvector or plain text


# This will return "true"
SELECT to_tsquery('learning & model') @@ to_tsvector('Build and train simple machine learning models');

# This will return "false"
SELECT to_tsquery('learning & model') @@ 'Build and train simple machine learning models';



# The basic full-text search
SELECT *
FROM online_courses
WHERE to_tsquery('learn') @@ to_tsvector(title);


# Search using or

SELECT * 
FROM online_courses
WHERE to_tsquery('machine | deep') @@ to_tsvector(title || description);


# Search using not


SELECT * 
FROM 
    online_courses, 
    to_tsvector(title || description) document
WHERE to_tsquery('programming & !days') @@ document;


########

# We can also have multilingual full search

# If we paste all the commands in one go

# Select one command at a time and hit F5 to execute

SET default_text_search_config = 'pg_catalog.french';

SELECT to_tsvector('english', 'The cake is good');
SELECT to_tsvector('french', 'The cake is good');
SELECT to_tsvector('simple', 'The cake is good');

SELECT to_tsvector('english','le gâteau est bon');
SELECT to_tsvector('french', 'le gâteau est bon');
SELECT to_tsvector('simple', 'le gâteau est bon');


# This is the para that is written in french

    # Welcome to the PostgreSQL.
    # PostgreSQL is used to store data.
    # have a good experience!


SET default_text_search_config = 'pg_catalog.french';


SÉLECTIONNER to_tsvector(
  'Bienvenue dans le PostgreSQL' ||
  'PostgreSQL est utilisé pour stocker des données.' ||
  'Profitez de votre expérience !'
) @@ to_tsquery('bon');

# This is also true as bon is present

# Now let's look at another word

SÉLECTIONNER to_tsvector(
  'Bienvenue dans le PostgreSQL.' ||
  'PostgreSQL est utilisé pour stocker des données.' ||
  'Avoir une bonne expérience !'
) @@ to_tsquery('bon');

# This is also true as bon is present 

# Let's search a word that's not present
SÉLECTIONNER to_tsvector(
  'Bienvenue dans le PostgreSQL.' ||
  'PostgreSQL est utilisé pour stocker des données.' ||
  'Avoir une bonne expérience !'
) @@ to_tsquery('mauvaise');

# This shows false