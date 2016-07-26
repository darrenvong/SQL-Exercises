/* The following queries are in response to the exercise set by Stanford Lagunita
 * online for the "Social Network" tables in social.sql. The task of the exercise
 * is described in the comments before my responses.
 * Author: Darren Vong
 */ 

/* Find the names of all students who are friends with someone named Gabriel. */
SELECT name
FROM (SELECT ID FROM Highschooler WHERE name = "Gabriel") AS GabrielID, Friend,
  Highschooler
/* By the way the join conditions are written, ID1 is Gabriel's ID, whilst ID2s
are the IDs of Gabriel's friends. */
WHERE GabrielID.ID = Friend.ID1 AND Highschooler.ID = Friend.ID2;

/* For every student who likes someone 2 or more grades younger than themselves,
return that student's name and grade, and the name and grade of the student
they like. */

/* Method 1 */
SELECT Admirer.name, Admirer.grade, Admiree.name, Admiree.grade
FROM (SELECT *
      FROM Likes L1, Highschooler H1
      WHERE L1.ID1 = H1.ID) AS Admirer, Highschooler Admiree
WHERE Admiree.ID = Admirer.ID2 AND Admirer.grade - Admiree.grade >= 2;

/* Method 2 (more verbose) */
SELECT admirer, admirerGrade, admiree, admireeGrade
FROM (SELECT Admirer.name AS admirer, Admirer.grade AS admirerGrade,
  Admiree.name AS admiree, Admiree.grade AS admireeGrade,
  Admirer.grade - Admiree.grade AS D
      FROM (SELECT *
            FROM Likes L1, Highschooler H1
            WHERE L1.ID1 = H1.ID) AS Admirer, Highschooler Admiree
      WHERE Admiree.ID = Admirer.ID2) AS gradeDifferences
WHERE D >= 2

/* For every pair of students who both like each other, return the name and
grade of both students. Include each pair only once, with the two names in
alphabetical order. */
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM
  Highschooler H1,
  (SELECT L1.ID1 AS ID1, L1.ID2 AS ID2
  FROM Likes L1, Likes L2
  WHERE L1.ID1 = L2.ID2 AND L1.ID2 = L2.ID1
  ) AS mutualLikes,
  Highschooler H2
WHERE H1.ID = mutualLikes.ID1 AND H2.ID = mutualLikes.ID2 AND H1.name < H2.name
ORDER BY H1.name;

/* Find all students who do not appear in the Likes table (as a student who likes
or is liked) and return their names and grades. Sort by grade, then by name
within each grade. */
SELECT name, grade
FROM Highschooler
WHERE ID NOT IN (SELECT ID1 FROM Likes UNION SELECT ID2 FROM Likes)
ORDER BY grade, name;

/* For every situation where student A likes student B, but we have no information
about whom B likes (that is, B does not appear as an ID1 in the Likes table),
return A and B's names and grades. */
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM
  Highschooler H1,
  (SELECT *
  FROM Likes
  WHERE ID2 IN (SELECT ID2 FROM Likes
                EXCEPT
                SELECT ID1 FROM Likes)
  ) AS OneWayLikes,
  Highschooler H2
WHERE H1.ID = OneWayLikes.ID1 AND H2.ID = OneWayLikes.ID2;

/* Find names and grades of students who only have friends in the same grade.
Return the result sorted by grade, then by name within each grade. */
SELECT name, grade
FROM Highschooler
WHERE ID NOT IN /* Hence IDs not in the relation below must only have same grade friends */
  /* This subquery finds all student IDs who have friends in different grade */
  (SELECT Friend.ID1
  FROM Highschooler H1, Friend, Highschooler H2
  WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2 AND H1.name < H2.name AND
    H1.grade <> H2.grade
  UNION
  SELECT Friend.ID2
  FROM Highschooler H1, Friend, Highschooler H2
  WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2 AND H1.name < H2.name AND
    H1.grade <> H2.grade)
ORDER BY grade, name

/* For each student A who likes a student B where the two are not friends, find
if they have a friend C in common (who can introduce them!). For all such trios,
return the name and grade of A, B, and C. */
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM
  (SELECT LikesNotFriends.ID1 AS AdmirerID, LikesNotFriends.ID2 AS AdmireeID,
  F2.ID1 AS mutFriendID
  FROM
    Friend F1,
    (SELECT * FROM Likes
    EXCEPT
    SELECT * FROM Friend
    ) AS LikesNotFriends,
    Friend F2
  WHERE F1.ID1 = LikesNotFriends.ID1 AND F2.ID2 = LikesNotFriends.ID2 AND
    F1.ID2 = F2.ID1 /* this condition selects rows where they have a common friend */
  ) AS trioIDs,
  Highschooler H1, Highschooler H2, Highschooler H3
WHERE H1.ID = AdmirerID AND H2.ID = AdmireeID AND H3.ID = mutFriendID;
