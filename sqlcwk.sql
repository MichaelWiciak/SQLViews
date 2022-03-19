DROP VIEW IF EXISTS vCustomerPerEmployee;
DROP VIEW IF EXISTS v10WorstSellingGenres ;
DROP VIEW IF EXISTS vBestSellingGenreAlbum ;
DROP VIEW IF EXISTS v10BestSellingArtists;
DROP VIEW IF EXISTS vTopCustomerEachGenre;


CREATE VIEW vCustomerPerEmployee  AS 

SELECT employees.LastName, employees.FirstName, EmployeeId, COUNT(employees.EmployeeId = customers.SupportRepId) AS TotalCustomer
FROM employees
LEFT JOIN customers
ON employees.EmployeeId = customers.SupportRepId
GROUP BY EmployeeID;

CREATE VIEW v10WorstSellingGenres  AS

SELECT GenreName1 as Genre, IFNULL(Sum(Quantity1),0) As Sales
FROM 
(SELECT genres.genreId As GenreID1, genres.Name AS GenreName1, Count(genres.genreId = tracks.genreid) As COUNTTRACK1
FROM genres
LEFT JOIN tracks on genres.genreId = tracks.genreid
Group By GenreID1) 

LEFT JOIN 

(SELECT tracks.TrackId as TrackID2, GenreID as GENREID2, Count(tracks.TrackId=invoice_items.TrackID) AS Quantity1
FROM tracks
INNER JOIN invoice_items 
ON tracks.TrackId=invoice_items.TrackID
Group BY tracks.TrackId)

ON GenreID1=GENREID2
Group By Genre 
Order By Sales
Limit 10;


CREATE VIEW vBestSellingGenreAlbum  AS

Select Genre as Genre, Album, artists.name as Artist,  Max(Q1) as Sales
FROM (
SELECT albums.albumID, genres.genreID, genres.Name as Genre, albums.title as Album, albums.artistID as NameA, tracks.trackid, Count(invoice_items.quantity) as Q1
FROM genres, tracks, albums, invoice_items
WHERE albums.albumID = tracks.albumID and tracks.genreID=genres.genreID 
and tracks.trackId=invoice_items.trackID
Group by albums.albumID, genres.genreID)
INNER JOIN artists
ON NameA=artists.artistid
Group by Genre;



CREATE VIEW v10BestSellingArtists AS

SELECT Artist, COUNTOFALBUMS as TotalAlbum, TotalTrackSales
FROM
(SELECT Artist, Sum(Quantity1) As TotalTrackSales
FROM 
(SELECT tracks.TrackId as TrackID2, tracks.albumId as AlbumID1, Count(tracks.TrackId=invoice_items.TrackID) AS Quantity1
FROM tracks
INNER JOIN invoice_items 
ON tracks.TrackId=invoice_items.TrackID
Group BY tracks.TrackId)
INNER JOIN
(SELECT artists.name as Artist, albums.albumID as AlbumID2
FROM artists
INNER JOIN albums
ON artists.artistid=albums.artistid)
ON AlbumID1=AlbumID2
GROUP BY Artist)
INNER JOIN
(SELECT artists.name as Artist1, Count(artists.artistid=albums.artistid) AS COUNTOFALBUMS
FROM artists
INNER JOIN albums
ON artists.artistid=albums.artistid
GROUP BY ARTIST1)
ON Artist=Artist1
order by TotalTrackSales desc
Limit 10;


CREATE VIEW vTopCustomerEachGenre AS

SELECT Genre, TopSpender, Max(TotalSpending) as TotalSpending
FROM(
SELECT GENRENAME1 as Genre, CUSTOMERNAME as TopSpender, SUM(TOTAL) as TotalSpending
FROM (SELECT tracks.TrackID as TRACKID1, genres.name as GENRENAME1
FROM Genres
LEFT JOIN tracks
ON tracks.genreID = genres.genreID)
INNER JOIN (SELECT customers.FirstName||' '||customers.LastName as CUSTOMERNAME, invoice_items.TrackId AS TRACKIDPERTRACK, invoice_items.UnitPrice * invoice_items.Quantity As Total 
FROM invoices, invoice_items, customers
WHERE invoices.invoiceID = invoice_items.invoiceId AND invoices.CustomerID=customers.CustomerID)
ON TRACKID1=TRACKIDPERTRACK
GROUP BY GENRENAME1, CustomerName
ORDER BY CustomerName ASC
)
GROUP BY GENRE;


