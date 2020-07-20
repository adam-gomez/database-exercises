USE albums_db;
SELECT * FROM albums;

#Select the name of all albums by Pink Floyd

SELECT name AS 'Album Name' FROM albums
WHERE artist = 'Pink Floyd';

#Select the year Sgt. Pepper's Lonely Hearts Club Band was released

SELECT release_date FROM albums
WHERE name = 'Sgt. Pepper''s Lonely Hearts Club Band';

#Select the genre for the album Nevermind

SELECT genre FROM albums
WHERE name = 'Nevermind';

#Select which albums were released in the 1990s

SELECT * FROM albums
WHERE release_date >= 1990;

#Select which albums had less than 20 million certified sales

SELECT * FROM albums
WHERE sales < 20;

#Select all the albums with a genre of "Rock"

SELECT * FROM albums
WHERE genre = 'Rock';

#Why do these query results not include albums with a genre of "Hard rock" or "Progressive rock"? 
#The query must be specific. These strings are not identical. To include these albums, we would need to expand the query with the ADD command
#Example

#SELECT * FROM albums
#WHERE genre = 'Rock' 
#OR genre = 'Hard rock'
#OR genre = 'Progressive rock';

#Also, this would miss albums that with genres of 'Hard rock, Progressive rock' as well as any other genre that included 'Rock' with other characters (i.e. 'Pop, Rock, R&B')