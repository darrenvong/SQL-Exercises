/* The following queries are in response to the exercise set by Stanford Lagunita
 * online for the "Movies Rating" tables in rating.sql. The task of the exercise
 * is described in the comments before my responses.
 * Author: Darren Vong
 */ 

/*******************************************************************
 * Initial problem set
*******************************************************************/

/* Find the titles of all movies directed by Steven Spielberg. */
SELECT title
FROM Movie
WHERE director = "Steven Spielberg";

/* Find all years that have a movie that received a rating of 4 or 5, and sort
them in increasing order. */
SELECT DISTINCT year
FROM Movie JOIN Rating using(mID)
WHERE stars >= 4
ORDER BY year;

/* Find the titles of all movies that have no ratings. */
SELECT title
FROM Movie
WHERE mID NOT IN (SELECT mID FROM Rating);

/* Some reviewers didn't provide a date with their rating. Find the names of all
reviewers who have ratings with a NULL value for the date. */
SELECT name
FROM Reviewer
WHERE rID IN (SELECT rID FROM Rating WHERE ratingDate IS NULL);

/* Write a query to return the ratings data in a more readable format:
reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by
reviewer name, then by movie title, and lastly by number of stars. */
SELECT name, title, stars, ratingDate
FROM Movie JOIN Reviewer JOIN Rating
ON Movie.mID = Rating.mID AND Reviewer.rID = Rating.rID
ORDER BY name, title, stars;

/* For all cases where the same reviewer rated the same movie twice and gave it
a higher rating the second time, return the reviewer's name and the title of the movie. */
SELECT name, title
FROM (SELECT R2.rID AS rID, R2.mID AS mID
      FROM Rating R1, Rating R2
      WHERE (R1.rID = R2.rID AND R1.mID = R2.mID AND R1.stars < R2.stars AND
            R1.ratingDate < R2.ratingDate)) AS HigherRating JOIN Movie JOIN Reviewer
ON Movie.mID = HigherRating.mID AND Reviewer.rID = HigherRating.rID;

/* For each movie that has at least one rating, find the highest number of stars
that movie received. Return the movie title and number of stars. Sort by movie title. */
SELECT title, maxStars
FROM (SELECT mID, MAX(stars) AS maxStars
      FROM Rating
      GROUP BY mID) AS MaxStars JOIN Movie USING(mID)
ORDER BY title;

/* For each movie, return the title and the 'rating spread', that is,
the difference between highest and lowest ratings given to that movie.
Sort by rating spread from highest to lowest, then by movie title. */
SELECT title, mx-mn AS range
FROM (SELECT mID, MIN(stars) AS mn, MAX(stars) AS mx
      FROM Rating
      GROUP BY mID) AS Spread JOIN Movie USING(mID)
ORDER BY range DESC, title

/* Find the difference between the average rating of movies released before 1980
and the average rating of movies released after 1980. (Make sure to calculate
the average rating for each movie, then the average of those averages for movies
before 1980 and movies after. Don't just calculate the overall average rating
before and after 1980.) */
SELECT ABS(NewAvgOfAvg.avgRating - OldAvgOfAvg.avgRating)
FROM (SELECT AVG(avgStars) AS avgRating
      FROM (SELECT AVG(stars) AS avgStars
            FROM Rating
            WHERE mID IN (SELECT mID
                          FROM Movie
                          WHERE year > 1980)
            GROUP BY mID) AS NewAvg) /** <- Average rating  of each movie **/
AS NewAvgOfAvg, /** Average of the post-1980 movies' average**/
(SELECT AVG(avgStars) AS avgRating
      FROM (SELECT AVG(stars) AS avgStars
            FROM Rating
            WHERE mID IN (SELECT mID
                          FROM Movie
                          WHERE year < 1980)
                          GROUP BY mID) AS OldAvg)
AS OldAvgOfAvg;


/*******************************************************************
 * Extra problems
*******************************************************************/

/* Find the names of all reviewers who rated Gone with the Wind. */
SELECT DISTINCT name
FROM (SELECT mID
      FROM Movie
      WHERE title = "Gone with the Wind") AS GwtWID JOIN Rating JOIN Reviewer
ON Reviewer.rID = Rating.rID AND GwtWID.mID = Rating.mID;

/* For any rating where the reviewer is the same as the director of the movie,
return the reviewer name, movie title, and number of stars. */
SELECT name, title, stars
FROM (SELECT DISTINCT rID, name
      FROM Movie JOIN Reviewer ON Movie.director = Reviewer.name) AS ownReview,
  Rating, Movie
WHERE ownReview.rID = Rating.rID AND Movie.mID = Rating.mID;

/* Return all reviewer names and movie names together in a single list,
alphabetized. (Sorting by the first name of the reviewer and first word in the
title is fine; no need for special processing on last names or removing "The".) */
SELECT name
FROM (SELECT title AS name FROM Movie
      UNION
      SELECT name FROM Reviewer)
ORDER BY name;

/* Find the titles of all movies not reviewed by Chris Jackson. */
/******************************************************************
 * Additional explanation on the query:
 * Reading from the most inner query (alias'ed as cjID) says what the alias name
 * describes (namely Chris Jackson's (CJ) rID); the second level SELECT query
 * then returns the movie's mID which have been reviewed by CJ. Using this second
 * level query's returned relation in the WHERE clause at the first level SELECT
 * query, the filter tests for non-membership of mID found in the second level
 * query (i.e. Movie's mID not reviewed by CJ) on the Movie relation and return
 * those titles as required. Phew!
*******************************************************************/
SELECT title
FROM Movie
WHERE mID NOT IN (SELECT mID
                  FROM (SELECT rID
                        FROM Reviewer
                        WHERE name = "Chris Jackson") AS cjID
                    JOIN Rating USING(rID));

