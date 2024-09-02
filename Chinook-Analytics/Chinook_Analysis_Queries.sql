--1. Customer Segmentation
--Which customers generate the highest revenue? = High-Value Customers
select  top 5 c.FirstName+' '+ c.LastName 'FullName', sum(inv.total) as TotalRevenue
from customer c
inner join Invoice inv on c.CustomerId = inv.CustomerId
group by c.FirstName, c.LastName, inv.InvoiceId
order by TotalRevenue desc

--Customer Segmentation by Country
--Total Revenue and number of customer in each country
select c.Country ,  count(distinct c.customerid) as NumberOfCustomers, sum(inv.total) as TotalRevenue
from customer c
join Invoice inv on c.CustomerId = inv.CustomerId
group by c.Country
order by TotalRevenue desc


-- 2. Music Sales Analysis
-- Total sales per each genre
select g.name , sum(inl.UnitPrice*inl.Quantity)  as 'SalesPerGenre'
from genre g 
join track t on t.GenreId = g.GenreId
join InvoiceLine inl on t.TrackId = inl.TrackId
group by g.name
order by SalesPerGenre desc


-- SO WHICH GENREs OF MUSIC IS MOST SOLD IN USA'n. 1'?
select top 5 g.name, sum(il.quantity) as TotalSold
from genre g
join track t on t.genreid=g.genreid
join InvoiceLine il on t.TrackId=il.TrackId
join Invoice i on i.InvoiceId=il.InvoiceId
join Customer c on i.CustomerId=c.CustomerId
where c.Country='USA'
group by g.name
order by TotalSold desc
-- Understanding Customer Preferences = Expand Genre Offerings = Partnership and Sponsorship Opportunities


--And in canda?
select top 5 g.name, sum(il.quantity) as TotalSold
from genre g
join track t on t.genreid=g.genreid
join InvoiceLine il on t.TrackId=il.TrackId
join Invoice i on i.InvoiceId=il.InvoiceId
join Customer c on i.CustomerId=c.CustomerId
where c.Country='Canada'
group by g.name
order by TotalSold desc
-- it's (rock and latin) in both counteries, better to compose and produce more of them


-------------------------------------------------------------------------------------------------

--2. Employee Performance
--employee count based on their title
SELECT Title, COUNT(*) AS NumberOfEmployees
FROM Employee
GROUP BY Title
ORDER BY NumberOfEmployees DESC;

--Total Sales by Employees(Sales Support Agents)
select e.FirstName, e.LastName, e.HireDate,COUNT(distinct c.customerid) AS NumberOfCustomers, sum(i.Total) AS TotalSales 
from employee e
join Customer c on e.EmployeeId=c.SupportRepId
join Invoice i on i.CustomerId=c.CustomerId
group by e.FirstName, e.LastName, e.HireDate
order by totalSales desc
-- is this your expected total sales? according to your threshold
-- Recognition and Incentives, Training and Mentorship


-- Total sales LAST 2 MONTHs
WITH LastMonthInvoices AS (
    SELECT InvoiceId, CustomerId, InvoiceDate
    FROM Invoice
    WHERE InvoiceDate >= DATEADD(MONTH, -2, '2024/08/01') AND InvoiceDate < '2024/08/01'
)

SELECT e.FirstName, e.LastName, SUM(il.UnitPrice * il.Quantity) AS TotalSales
FROM LastMonthInvoices i
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
GROUP BY e.FirstName, e.LastName
ORDER BY TotalSales desc
-- despite Jan is the best seller overall
-- she was the worst of the 3 sellers with a big difference the last 2 months

--------------------------------------------------------------------------------------------------

-- 3. Tracks and Artists Analysis

---top 10 in sells have which Song_length_minutes
select top 10
t.Name,
(t.Milliseconds/60000.0) as Song_length_minutes,
SUM(il.UnitPrice * il.Quantity) as TotalRevenue
from Track t
join InvoiceLine il on t.TrackId=il.TrackId
group by t.Name, t.Milliseconds
order by TotalRevenue desc

-- Not sold Tracks
select  t.trackid, t.name, count(inl.trackid) as 'sales_count'  from track t
left join  invoiceline inl on inl.TrackId = t.TrackId
group by t.trackid , t.Name
having  count(inl.trackid) =0
order by t.name 

-- sales of each artist
SELECT ar.Name AS 'Artist', SUM(inl.UnitPrice * inl.Quantity) AS 'Sales Per Artist'
FROM Artist ar
JOIN  Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON t.AlbumId = al.AlbumId
JOIN  InvoiceLine inl ON inl.TrackId = t.TrackId
JOIN Invoice inv ON inl.InvoiceId = inv.InvoiceId
GROUP BY ar.Name
ORDER BY 'Sales Per Artist' DESC;


--each artist is in how many playlists and how many unique tracks are there? 
-- artist popularity based on playlist inclusion and the variety of their music used in playlists.
SELECT 
  ar.name AS Artist,
  COUNT(DISTINCT pt.TrackId) AS number_of_playlists,
  COUNT(DISTINCT t.AlbumId) AS unique_tracks
FROM artist ar
JOIN album al ON ar.ArtistId=al.ArtistId
JOIN track t ON t.AlbumId=al.AlbumId
JOIN PlaylistTrack pt ON t.TrackId=pt.TrackId
GROUP BY  ar.name
ORDER BY number_of_playlists DESC, unique_tracks DESC

-- How many tracks have been purchased vs not purchased?
with all_purchased_tracks as(
	select t.TrackId as AllTracks, il.TrackId as PurchasedTracks, a.Name
	from Artist a
	join Album al on al.ArtistId=a.ArtistId
	join Track t on al.AlbumId=t.AlbumId
	left join InvoiceLine il on t.TrackId=il.TrackId
)
select count(distinct AllTracks) as TotalTracks,
count(distinct PurchasedTracks) as PurchasedTracks,
count(distinct AllTracks) - count(distinct PurchasedTracks) as NotPurchasedTracks,
  ROUND(CAST(COUNT(DISTINCT PurchasedTracks) AS FLOAT)/COUNT(DISTINCT AllTracks), 3)
    AS perc_purchased,
  ROUND(CAST(COUNT(DISTINCT AllTracks) - COUNT(DISTINCT PurchasedTracks) 
    AS FLOAT)/COUNT(DISTINCT AllTracks), 3)
    AS perc_not_purchased
from all_purchased_tracks


-- Sales trend Over Years
select YEAR (invoicedate) as 'year', sum(total) as 'total_sales' from Invoice
group by YEAR (invoicedate)
order by YEAR (invoicedate)

