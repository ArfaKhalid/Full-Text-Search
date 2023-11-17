
########################## FullTextSearchInDictionories ##########################

# Stop Words : Stop words are words that are very common, appear in almost every document, 
# and have no discrimination value. Therefore, they can be ignored in the context of full text searching.

SELECT to_tsvector('english', 'welcome to the postgres tutorial');

# output

        to_tsvector
----------------------------
'postgr':4 'tutori':5 'welcom':1

# The missing positions 2,3 are because of stop words.

# Ranks calculated for documents with and without stop words are quite different

SELECT ts_rank_cd (to_tsvector('english', 'welcome to the postgres tutorial'), to_tsquery('welcome & tutorial'));

# Following is the output

 ts_rank_cd
------------
       0.025


SELECT ts_rank_cd (to_tsvector('english', 'welcome postgres tutorial'), to_tsquery('welcome & tutorial'));

 ts_rank_cd
------------
        0.05


# Simple Dictionaries

CREATE TEXT SEARCH DICTIONARY public.simple_dict (
    TEMPLATE = pg_catalog.simple,
    STOPWORDS = english
);

SELECT ts_lexize('public.simple_dict', 'Shoes');

# It will return the following

 ts_lexize
-----------
 {shoes}


SELECT ts_lexize('public.simple_dict', 'The');

# It will return following result because it is a stop word

 ts_lexize
-----------
 {}

# Let's try the following one to see of is a stop word or not

SELECT ts_lexize('public.simple_dict', 'of');


# Above query will return empty because those are the stop words


# We can also choose to return NULL, instead of the lower-cased word, 
# if it is not found in the stop words file. 

# Alternatively, the dictionary can be configured to report non-stop-words as unrecognized, allowing them to be passed on to the next dictionary in the list.
# This behavior is selected by setting the dictionary's Accept parameter to false.

ALTER TEXT SEARCH DICTIONARY public.simple_dict ( Accept = false );

# Run following query to search

SELECT ts_lexize('public.simple_dict', 'Shoes');

# Run following query

SELECT ts_lexize('public.simple_dict', 'ShoeS');

# Run following query

SELECT ts_lexize('public.simple_dict', 'The');

 # default setting of Accept = true, 
 # it is only useful to place a simple dictionary at the end of a list of dictionaries, 
 # since it will never pass on any token to a following dictionary.