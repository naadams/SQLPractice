--
-- @StudentID: 
--
--
-- Designed for PostgreSQL 9.x with PostGIS

CREATE EXTENSION IF NOT EXISTS HSTORE;

-- Write your SQL here.

--1.) Create relational database 
CREATE TABLE tweet(
	tweet_id		integer PRIMARY KEY
	twitter_handle	text	NOT NULL
	tweet_date      date	NOT NULL,
	tweet_message	text	NOT NULL,		
	retweets		integer,
	location		text	NOT NULL
	);

CREATE TABLE tower_location(
	tower_id		integer	PRIMARY KEY,
	latitude		numeric,	
	longitude		numeric,
	website_link 	text	NOT NULL,
	build_type		text 	NOT NULL,
	year_complete	year
	);
--combined the 2 separate articles into one relational table due to 
--much of the information for both of them being similar.
CREATE TABLE articles(
	article_id		integer PRIMARY KEY,
	publisher		text	NOT NULL,
	article_title	text 	NOT NULL,	
	author			text,
	date_written 	text	NOT NULL,
	link_to_article	text 	NOT NULL,
	aritcle_topics	text 	
	);

--2.) Create NoSQL database for the same data
DROP TABLE IF EXISTS tweets_articles;
CREATE TABLE tweets_articles (
    id integer PRIMARY KEY,
    info HSTORE NOT NULL 
);

INSERT INTO tweets_articles VALUES(1,
	'"twitter_handle" => "@realdonaldtrump",
	 "date" => "11/09/2016",
	 "body" => "I would like to extend my best wishes to all, even the
	  haters and losers, on this special date, September 11th.",
	 "retweets" => 50344,
	 "location" => "Trump Tower in New York"
	');
INSERT INTO tweets_articles VALUES(2,
   '"tower_location" => "40.7625°N 73.9734°W",
	"wiki_link" => "https://en.wikipedia.org/wiki/Trump_Tower",
	"tower_type" => "building",
	"year_complete" => 1983
	');
INSERT INTO tweets_articles VALUES(3,
'	"newspaper_name" => "New York Times",
	"article_title"  => "Overrated? Loser? Not if It’s Trump Who Calls You Out",
	"article_author" => "S. Kurutz",
	"date_published" => "Jan 2017",
	"article_link" => "https://www.nytimes.com/2017/01/11/style/donald-trump-twitter-insults.html?_r=0"
	');
INSERT INTO tweets_articles VALUES(4,
'	"newspaper_name" => "The Guardian",
	"article_title" => "How colonial violence came home: the ugly truth of the first world war",
	"year_published" => 2017,
	"article_link" => "https://www.theguardian.com/news/2017/nov/10/how-colonial-violence-came-home-the-ugly-truth-of-the-first-world-war",
	"topics_covered" => "first world war, colonialism, violence"
	
');
--3.) Add tables using JSON format
DROP TABLE IF EXISTS json_table;
CREATE TABLE json_table (
    id integer PRIMARY KEY,
    info JSONB NOT NULL 
);

INSERT INTO json_table VALUES ( 1, '{ 
	"tweet_info":{
		"handle": "@realdonaldtrump",
		"body":"I would like to extend my best wishes to all, even the haters and losers, on this special date, September 11th.",
		"retweets":50344,
		"location_name":"Trump Tower"
		},
	"location_info":{
			"latitude":40.7625,
			"longitude":73.9734,
			"wiki_link":"https://en.wikipedia.org/wiki/Trump_Tower",
			"type":"building",
			"year_complete":1983}
			}
');
INSERT INTO json_table VALUES ( 2, '{ 
	"article1":{
			"publisher":"New York Times",
			"title":"Overrated? Loser? Not if It’s Trump Who Calls You Out",
			"author":"S. Kurutz",
			"published_date":"Jan 2017",
			"link":"https://www.nytimes.com/2017/01/11/style/donald-trump-twitter-insults.html?_r=0"
		 },
	"article2":{
			"publisher":"The Guardian",
			"title":"How colonial violence came home: the ugly truth of the first world war",
			"link":"https://www.theguardian.com/news/2017/nov/10/how-colonial-violence-came-home-the-ugly-truth-of-the-first-world-war",
			"topics":["first world war", "colonialism", "violence"],
			"year_published":2017
		 }
		 
	}');
--Tweet as GeoJSON
INSERT INTO json_table VALUES (3, '{
	"type": "Feature",
	"geometry": {
		"type": "Point",
		"coordinates": [-73.9734, 40.7625]
		},
	"properties": {
		"handle": "@realdonaldtrump",
		"body":"I would like to extend my best wishes to all, even the haters and losers, on this special date, September 11th.",
		"retweets":50344,
		"location_name":"Trump Tower",
		"wiki_link":"https://en.wikipedia.org/wiki/Trump_Tower",
		"type":"building",
		"year_complete":1983
  }
}');
	
--4. Queries for JSON and HSTORE	
--HSTORE QUERIES
--A.)Show the wiki link to the Trump Tower
	select info -> 'wiki_link'
	from tweets_articles
	where id = 2

--B.) Show the body of the tweet from September 11, 2016
	SELECT  info -> 'body'
	FROM  tweets_articles
	WHERE  info @> '"date" => "11/09/2016"' :: hstore;

--C.) Select newspapers that have both a title and author
	SELECT info -> 'newspaper_name'
	FROM tweets_articles
	WHERE info ?& ARRAY [ 'article_title', 'article_author' ]

--D.) Show articles written by S. Kurutz
	SELECT info->'article_title' as ArticleTitle
	FROM tweets_articles
	WHERE info->'article_author' = 'S. Kurutz'


--JSON QUERIES
--A.) Select the twitter handle from the tweet
	select info -> 'tweet_info' -> 'handle'
	from json_table;

--B.) Find the year as text that The Guardian article was published
	select info -> 'article2' -> 'year_published'
	from json_table
	where id = 2

--C.) Count the number of topics in The Guardian article
	select info -> 'article2' -> 'topics' as topics,
	jsonb_array_length(info -> 'article2' -> 'topics') as n_topics
	from json_table
	where id = 2
	;
	
--D.) select the coordinates of the tweet as text 
	select info -> 'geometry' ->> 'coordinates'
	from json_table
	where id = 3


