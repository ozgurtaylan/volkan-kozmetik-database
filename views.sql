-- Ýstanbuldan verilen sipraiþlerin ortalama tutarý
CREATE VIEW avgOrderPrice_Istanbul
as
select avg(cb.totalPrice) as averageCost
from Customer c inner join Address a on c.customerID = a.customerID inner join CustomerOrder co on c.customerID=co.customerID
inner join CustomerProductOfOrder cpo on cpo.orderID=co.orderID inner join CustomerBill cb on cb.orderID=cpo.orderID
where a.city = 'Ýstanbul'


-- En çok satýn alýnan ürün
CREATE VIEW mostOrderedProduct
as
select TOP 1 p.productID,p.productName , p.price, sum(cpo.amount) as TotalAmount
from Product p inner join CustomerProductOfOrder cpo on p.productID=cpo.productID
group by p.productID,p.productName , p.price
order by TotalAmount DESC


--Hangi þehirden kaç sipariþ verilmiþ.
CREATE VIEW orderCountByCity
as
select a.city , count(*) as totalOrderCity
from Customer c inner join Address a on c.customerID= a.customerID inner join CustomerOrder co on c.customerID=co.customerID inner join CompanyProductOfOrder cpo on co.orderID = cpo.orderID
inner join CustomerBill cb on cb.orderID = cpo.orderID inner join CustomerShipment cs on cs.orderID=cb.orderID
group by a.city



-- Hangi kategoriden kaç sipariþ verilmiþ.
CREATE VIEW orderCountByCategory
as
select  c.categoryName  , sum(cpo.amount) as TotalCategorOrderAmont
from Product p inner join Category c on p.categoryID = c.categoryID 
inner join CustomerProductOfOrder cpo on cpo.productID = p.productID
group by c.categoryName



-- En çok para harcayan ilk 3 þirket
CREATE VIEW mostPurchasedCompany
as
select top 3  c.companyID , c.companyName, sum(cb.totalPrice) as totalAmountMoney
from Company c inner join CompanyOrder co on c.companyID=co.companyID inner join
CompanyProductOfOrder cpo on cpo.orderID=co.orderID inner join CompanyBill cb on cb.orderID = cpo.orderID
group by  c.companyID , c.companyName
order by totalAmountMoney DESC


