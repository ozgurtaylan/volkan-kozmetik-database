--------------------------------------------------------
--STORED PROCEDURE TO INCREMENT PRODUCT AMOUNT
Create Procedure sp_addProductAmount
@productID int,
@amountToAdd int
As
Begin
	Update p
	Set p.stockAmount = p.stockAmount+@amountToAdd
	From Product p
	Where p.productID=@productID
End
--------------------------------------------------------
--STORED PROCEDURE TO DECREMENT PRODUCT AMOUNT
Create Procedure sp_removeProductAmount
@productID int,
@amountToRemove int
As
Begin
	Declare @stock int = (Select p.stockAmount From Product p Where p.productID=@productID)
	If(@amountToRemove < @stock)
	Begin
		Update p
		Set p.stockAmount = p.stockAmount-@amountToRemove
		From Product p
		Where p.productID=@productID
	End
	Else
	Begin
		Update p
		Set p.stockAmount = 0
		From Product p
		Where p.productID=@productID
	End
End
--------------------------------------------------------
--STORED PROCEDURE TO ADD NEW PRODUCT
Create Procedure sp_addNewProduct
@category int,
@name nvarchar(50),
@price decimal(5, 2)
As
Begin
	Insert into Product(categoryID, productName, price)
	Values(@category, @name, @price)
End
--------------------------------------------------------
--STORED PROCEDURE TO ADD INTO CUSTOMER SHOPPING CART
Create Procedure sp_addIntoCustomerShoppingCart
@customerID int,
@productID int,
@amount int
As
Begin
	If(@productID in (Select productID From Product) and @amount <= (Select stockAmount From Product Where productID=@productID))
	Begin
		If (@productID not in (Select productID From CustomerShoppingCart Where customerID=@customerID))
		Begin
			Insert into CustomerShoppingCart
			Values(@customerID, @productID, @amount)
		End
		Else
		Begin
			Update CustomerShoppingCart
			Set amount=amount+@amount
			Where customerID=@customerID
		End
	End
End
--------------------------------------------------------
--STORED PROCEDURE TO ADD NEW CUSTOMER ORDER
Create Procedure sp_addNewCustomerOrder
@customerID int
As
Begin
	Insert into CustomerOrder(customerID, isCheckoutComplete)
	Values(@customerID, 0)

	Declare @orderID int = SCOPE_IDENTITY()

	Insert into CustomerProductOfOrder
	Select @orderID, csc.productID, csc.amount
	From CustomerShoppingCart csc
	Where csc.customerID=@customerID

	Delete From CustomerShoppingCart Where customerID=@customerID

End
--------------------------------------------------------
--STORED PROCEDURE TO ADD INTO COMPANY SHOPPING CART
Create Procedure sp_addIntoCompanyShoppingCart
@companyID int,
@productID int,
@amount int
As
Begin
	If(@productID in (Select productID From Product) and @amount <= (Select stockAmount From Product Where productID=@productID))
	Begin
		If (@productID not in (Select productID From CompanyShoppingCart Where companyID=@companyID))
		Begin
			Insert into CompanyShoppingCart
			Values(@companyID, @productID, @amount)
		End
		Else
		Begin
			
			Update CompanyShoppingCart
			Set amount=amount+@amount
			Where companyID=@companyID
		End
	End
End
--------------------------------------------------------
--STORED PROCEDURE TO ADD NEW COMPANY ORDER
Create Procedure sp_addNewCompanyOrder
@companyID int
As
Begin
	Insert into CompanyOrder(companyID, isCheckoutComplete)
	Values(@companyID, 0)

	Declare @orderID int = SCOPE_IDENTITY()

	Insert into CompanyProductOfOrder
	Select @orderID, csc.productID, csc.amount
	From CompanyShoppingCart csc
	Where csc.companyID=@companyID

	Delete From CompanyShoppingCart Where companyID=@companyID

End


Select * from CompanyOrder
Select * from CompanyProductOfOrder cpo

exec sp_addNewCompanyOrder 6

Select * from CompanyOrder
Select * from CompanyProductOfOrder cpo
--------------------------------------------------------
--STORED PROCEDURE TO APPROVE CUSTOMER ORDER
Create Procedure sp_approveCustomerOrder
@orderID int
As
Begin
	Update co
	Set co.isCheckoutComplete=1
	From CustomerOrder co
	Where co.orderID=@orderID

	Insert into CustomerBill(orderID, totalPrice)
	Select @orderID, sum(dt.cost)
	From
	(Select cpo.amount * p.price as cost
	From CustomerProductOfOrder cpo inner join Product p on cpo.productID=p.productID
	Where cpo.orderID=@orderID) as dt
End
--------------------------------------------------------
--STORED PROCEDURE TO APPROVE COMPANY ORDER
Create Procedure sp_approveCompanyOrder
@orderID int
As
Begin
	Update co
	Set co.isCheckoutComplete=1
	From CompanyOrder co
	Where co.orderID=@orderID

	Insert into CompanyBill(orderID, totalPrice)
	Select @orderID, sum(dt.cost)
	From
	(Select cpo.amount * p.price as cost
	From CompanyProductOfOrder cpo inner join Product p on cpo.productID=p.productID
	Where cpo.orderID=@orderID) as dt
End
--------------------------------------------------------
--STORED PROCEDURE TO REGISTER NEW CUSTOMER
Create Procedure sp_registerNewCustomer
@fName nvarchar(30),
@lName nvarchar(20),
@phoneNumber nvarchar(12),
@email nvarchar(50),
@birthdate smalldatetime,
@city nvarchar(50),
@postalcode int
As
Begin
	Insert into Customer(fName, lName, phoneNumber, email, birthDate)
	Values(@fName, @lName, @phoneNumber, @email, @birthdate)

	Declare @customerID int = SCOPE_IDENTITY()

	Insert into Address
	Values(@customerID, @city, @postalcode)
End
--------------------------------------------------------
--STORED PROCEDURE TO REGISTER NEW COMPANY
Create Procedure sp_registerNewCompany
@taxNo bigint,
@name nvarchar(50),
@taxOffice nvarchar(50),
@address nvarchar(50)
As
Begin
	Insert into Company(taxNo, companyName, taxOffice, address)
	Values(@taxNo, @name, @taxOffice, @address)
End
--------------------------------------------------------
--STORED PROCEDURE TO CREATE NEW CATEGORY
Create Procedure sp_createNewCategory
@name nvarchar(50)
As
Begin
	Insert into Category(categoryName)
	Values(@name)
End
--------------------------------------------------------
--STORED PROCEDURE TO SHIP ORDER TO CUSTOMER
Create Procedure sp_shipToCustomer
@orderID int
As
Begin
	Insert into CustomerShipment(orderID, cost)
	Select @orderID, sum(cpo.amount)*(RAND()*(10-5)+5)
	From CustomerProductOfOrder cpo inner join CustomerOrder co on cpo.orderID=co.orderID
	Where co.isCheckoutComplete=1 and cpo.orderID=@orderID
End
--------------------------------------------------------
--STORED PROCEDURE TO SHIP ORDER TO COMPANY
Create Procedure sp_shipToCompany
@orderID int
As
Begin
	Insert into CompanyShipment(orderID, cost)
	Select @orderID, sum(cpo.amount)*(RAND()*(10-5)+5)
	From CompanyProductOfOrder cpo inner join CompanyOrder co on cpo.orderID=co.orderID
	Where co.isCheckoutComplete=1 and cpo.orderID=@orderID
End
-----------------------------------------------------
--Trigger to Auto Decrement Stock when an order is placed by Customer
Create Trigger sp_autoDecrementStockAfterCustomerOrder
On CustomerProductOfOrder
After Insert
As
Begin

	Update p
	Set p.stockAmount=p.stockAmount-i.amount
	From Product p inner join inserted i on p.productID=i.productID

End
---------------------------------------------------------------
--Trigger to Auto Decrement Stock when an order is placed by Company
Create Trigger sp_autoDecrementStockAfterCompanyOrder
On CompanyProductOfOrder
After Insert
As
Begin

	Update p
	Set p.stockAmount=p.stockAmount-i.amount
	From Product p inner join inserted i on p.productID=i.productID

End