CREATE VIEW menuItemIngredients_V AS
select distinct mi.menuItemID,mi.name menuItemName,mii.quantity,i.name ingredientsName,i.ingredientsID 
from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii,ORDER_MENU_ITEM omi	-- hangi �r�n�n i�inde neler oldu�unu g�sterir.
where i.ingredientsID = mii.ingredientsID
and mii.menuItemID = mi.menuItemID
and omi.menuItemID=mi.menuItemID

select * from menuItemIngredients_V a
where a.menuItemID = 3

select * from ORDERTOTALPRICE_V

select * from MENU_ITEM mi, MENU m				-- hangi men�de neler oldu�unu g�sterir
where mi.menuID = m.menuID
and mi.menuID = 3

select mi.name, mi.price,omi.quantity from ORDERS o, ORDER_MENU_ITEM omi, MENU_ITEM mi  --order� ve fiyatlar� g�sterir
where o.orderID = omi.orderID
and omi.menuItemID = mi.menuItemID
and o.orderID = 20

select o.orderID,Sum(a.totalprice) totalPrice	-- total price
from ORDERS o,(select o.orderID,mi.name,mi.price,omi.quantity, omi.quantity*mi.price totalprice --hangi order�n neler ald��� ve fiyatlar�
		from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi
		where o.orderID=omi.orderID
		and mi.menuItemID = omi.menuItemID
		group by o.orderID,mi.name,mi.price,omi.quantity) a
where a.orderID = o.orderID
group by o.orderID

select * from ORDERS o	-- �denmi� masalar� g�sterir.
where o.isPaid = 1

UPDATE ORDERS	--order�n ka� para oldu�unu hesaplar
SET totalPrice = b.total
from ORDERS o,(select o.orderID,sum(a.totalprice) total
				from ORDERS o,(select o.orderID ,mi.name,mi.price,omi.quantity, omi.quantity*mi.price totalprice --hangi order�n neler ald��� ve fiyatlar�
								from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi
								where o.orderID=omi.orderID
								and mi.menuItemID = omi.menuItemID
								group by o.orderID,mi.name,mi.price,omi.quantity) a
				where o.orderID = a.orderID
				group by o.orderID) b
where o.orderID=b.orderID

CREATE VIEW ORDERTOTALPRICE_V AS	--view for order total price
select o.*
from ORDERS o,(select o.orderID,sum(a.totalprice) total
				from ORDERS o,(select o.orderID ,mi.name,mi.price,omi.quantity, omi.quantity*mi.price totalprice --hangi order�n neler ald��� ve fiyatlar�
								from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi
								where o.orderID=omi.orderID
								and mi.menuItemID = omi.menuItemID
								group by o.orderID,mi.name,mi.price,omi.quantity) a
				where o.orderID = a.orderID
				group by o.orderID) b
where o.orderID=b.orderID

select * from ORDERTOTALPRICE_V

CREATE PROCEDURE calculateDailyAmount			--g�nl�k amount hesaplan�r input date
	@date date,					--****** bu input input yazmak zorunda de�iliz
	@totalDailyAmount decimal(7,2) OUTPUT 
AS
select @totalDailyAmount=sum(otpv.totalPrice)		-- ****** output parametresine de�er e�ledik. -- ama number of students tek bir integer yani onu bi listeye e�itleyemezsin.
from ORDERTOTALPRICE_V otpv
where otpv.date = @date


declare @param1 decimal(7,2);  -- g�n girilip de�er g�sterilir.
declare @date date
SET @date = '2015-12-12'
exec calculateDailyAmount @date, @param1 OUTPUT; --**** 1 inputa atand�. di�erleri output
select @param1;

select * from ORDERS

select o.tableID,SUM(o.totalPrice) from ORDERS o
where o.tableID=3 group by o.tableID


select o.employeeID,e.fName,e.lName,sum(o.totalPrice) totalSales from ORDERS o,EMPLOYEE e --hangi garsonun ne kadar sat�� yapt���
where o.employeeID=e.employeeID
group by o.employeeID,e.fName,e.lName
order by totalSales desc

select omi.menuItemID,mi.name,sum(omi.quantity) totalSales				-- hangi �r�nden ne kadar sat�lm��
from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi							-- en �ok sat�landan en aza kadar s�ral�
where o.orderID = omi.orderID
and mi.menuItemID = omi.menuItemID
group by omi.menuItemID,mi.name 
order by totalSales desc

select mi.name,sum(omi.quantity) ass from ORDER_MENU_ITEM omi,MENU_ITEM mi	--yukardakiyle ayn�
where omi.menuItemID = mi.menuItemID
group by mi.name 
order by ass desc

CREATE VIEW usedIngredients_V AS
select i.ingredientsID,i.name,sum(a.quantity*b.ass) used				-- hangi malzemeden ne kadar kullan�lm�� 
from INGREDIENT i,(select mi.menuItemID,mi.name menuItemName,mii.ingredientsID,mii.quantity,i.name ingredientsName
				from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	-- hangi �r�n�n i�inde neler oldu�unu g�sterir.
				where i.ingredientsID = mii.ingredientsID
				and mii.menuItemID = mi.menuItemID) as a	
				,(select mi.menuItemID,mi.name,sum(omi.quantity) ass 
				from ORDER_MENU_ITEM omi,MENU_ITEM mi					--hangi �r�nden ne kadar sat�lm��
				where omi.menuItemID = mi.menuItemID
				group by mi.name, mi.menuItemID) as b	
where a.menuItemID=b.menuItemID		
and i.ingredientsID=a.ingredientsID
group by i.ingredientsID,i.name
--order by used desc

select * from usedIngredients_V a
order by a.used desc


select mi.menuItemID,mi.name menuItemName,mii.ingredientsID,mii.quantity,i.name ingredientsName,i.cost*mii.quantity
				from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	-- hangi �r�n�n i�inde neler oldu�unu g�sterir.
				where i.ingredientsID = mii.ingredientsID
				and mii.menuItemID = mi.menuItemID


select mi.menuItemID,mi.name,sum(i.cost*mii.quantity) cost			-- bir �r�n�n maliyeti
				from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	-- hangi �r�n�n i�inde neler oldu�unu g�sterir.
				where i.ingredientsID = mii.ingredientsID
				and mii.menuItemID = mi.menuItemID
				group by mi.menuItemID,mi.name

CREATE VIEW menuItemProfitPriceCost_V AS
select distinct a.menuItemID,a.name,a.price,a.cost,a.price-a.cost profit				-- bir �r�n�n sat�� fiyat� kar� maliyeti
 from MENU_ITEM mi,(select mi.menuItemID,mi.name,mi.price,sum(i.cost*mii.quantity) cost		--sat�� fiyat� maliyet hesaplan�r	
					from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	
					where i.ingredientsID = mii.ingredientsID
					and mii.menuItemID = mi.menuItemID
					group by mi.menuItemID,mi.name,mi.price) a

select * from menuItemProfitPriceCost_V
order by menuItemID

CREATE VIEW orderProfitPriceCost_V AS
select o.orderID,o.totalPrice,sum(omi.quantity*mippc.cost) orderCost,sum(omi.quantity*mippc.profit) orderProfit --orderid , cost ,profit ,price
from ORDERS o,ORDER_MENU_ITEM omi,menuItemProfitPriceCost_V mippc
where o.orderID=omi.orderID
and omi.menuItemID = mippc.menuItemID
group by o.orderID,o.totalPrice

select * from orderProfitPriceCost_V

CREATE PROCEDURE performanceOfWaiter			--hangi garsonun ne kadar sat�� yapt���
	@waiterID int,				
	@totalSales decimal(7,2) OUTPUT 
AS
select @totalSales=sum(o.totalPrice) 
from ORDERS o,EMPLOYEE e 
where o.employeeID=e.employeeID
and e.employeeID=@waiterID


declare @param1 decimal(7,2);  
declare @waiterID int
SET @waiterID = 8
exec performanceOfWaiter @waiterID, @param1 OUTPUT; --�dsi 7 olan garsonun toplam sat���
select @param1;

select omi.menuItemID,mi.name,sum(omi.quantity) totalSales				-- hangi �r�nden ne kadar sat�lm��
from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi							-- en �ok sat�landan en aza kadar s�ral�
where o.orderID = omi.orderID
and mi.menuItemID = omi.menuItemID
and mi.menuItemID = 8
group by omi.menuItemID,mi.name 
order by totalSales desc

CREATE PROCEDURE performanceOfMenuItem			--bir �r�nden ne kadar sat�lm��
	@productID int,					
	@totalSales int OUTPUT 
AS
select @totalSales=sum(omi.quantity)				-- hangi �r�nden ne kadar sat�lm��
from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi							-- en �ok sat�landan en aza kadar s�ral�
where o.orderID = omi.orderID
and mi.menuItemID = @productID
and mi.menuItemID = omi.menuItemID


declare @param1 int;  
declare @productID int		--�r�n idsi girilip ne kadar sat�ld��� g�z�k�r
SET @productID = 8
exec performanceOfMenuItem @productID, @param1 OUTPUT;
select @param1;

CREATE PROCEDURE addIngredients			--bir �r�nden ne kadar sat�lm��
	@ingredientsID int,	
	@amount int,						
	@newValue int OUTPUT
AS
update INGREDIENT
set quantity=i.quantity+@amount,@newValue=i.quantity+@amount				-- hangi �r�nden ne kadar sat�lm��
from INGREDIENT i							-- en �ok sat�landan en aza kadar s�ral�
where i.ingredientsID=@ingredientsID


declare @param1 int;  
declare @ingredientsID int		--�r�n idsi girilip ne kadar sat�ld��� g�z�k�r
declare @amount int
SET @ingredientsID = 1
set @amount = 100
exec addIngredients @ingredientsID,@amount, @param1 OUTPUT;
select @param1;

select * from EMPLOYEE

CREATE PROCEDURE takeOrder			--sipari� almak insertle menuitemordera giriliyo
	@orderMenuItemID int,
	@quantity int,	
	@menuItemID int,
	@orderID int
AS
insert into ORDER_MENU_ITEM(orderMenuItemID,quantity,menuItemID,orderID) 
values(@orderMenuItemID,@quantity,@menuItemID,@orderID);			--ordermenu�tem insert.


 
declare @orderMenuItemID int;			--73 idsine yeni order ald� her seferinde bu idyi 1 artt�r.
declare @quantity int	
declare @menuItemID int
declare @orderID int
SET @orderMenuItemID=84;
SET @quantity=1	
SET @menuItemID=5
SET @orderID=1
exec takeOrder @orderMenuItemID,@quantity, @menuItemID, @orderID;

select * from menuItemIngredients_V a
where a.menuItemID=1

select * from INGREDIENT				

select omi.quantity,mi.name,mi.price,mi.price*omi.quantity total from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi  --nelerin sipari� edildi�ini g�sterir
where o.orderID=omi.orderID
and mi.menuItemID=omi.menuItemID
and o.orderID=1

select * from ORDERTOTALPRICE_V a		-- total price de�i�ip de�i�medi�i g�r�l�r
where a.orderID=1

select * from orderProfitPriceCost_V a
where a.orderID=1

select * from usedIngredients_V


CREATE TRIGGER calculateTotalTablePrice ON ORDER_MENU_ITEM
AFTER insert AS 
BEGIN--optional
Declare @addedPrice decimal(7,2);
select @addedPrice=i.quantity*mi.price from inserted i,MENU_ITEM mi	--quantity ve �r�n fiyat� �arp�l�r ne kadar eklence�i bulunur
where mi.menuItemID=i.menuItemID
update ORDERS
set totalPrice=o.totalPrice+@addedPrice				-- hangi �r�nden ne kadar sat�lm��
from ORDERS o,inserted i,MENU_ITEM mi							-- en �ok sat�landan en aza kadar s�ral�
where o.orderID=i.orderID
and mi.menuItemID=i.menuItemID

END;

select * from ORDER_MENU_ITEM omi,MENU_ITEM mi
where omi.menuItemID=mi.menuItemID

CREATE TRIGGER calculateStock ON ORDER_MENU_ITEM
AFTER insert AS 
BEGIN--optional
declare @orderID int;
Declare @menuItemID int;

select @orderID=i.orderID,@menuItemID=i.menuItemID from inserted i

Update INGREDIENT		--sipari�e bakar idsini alir ka� tane sipari� edildi�ine g�re i�erikleri stocktan d��er
set quantity=ing.quantity-a.quantity*omi.quantity
from INGREDIENT ing,menuItemIngredients_V a,inserted omi,ORDERS o
where a.menuItemID = @menuItemID--2
and omi.menuItemID=a.menuItemID
and o.orderID=omi.orderID
and omi.orderID=@orderID--21
and ing.ingredientsID=a.ingredientsID

END;



Update INGREDIENT		--sipari�e bakar idsini alir ka� tane sipari� edildi�ine g�re i�erikleri stocktan d��er
set quantity=ing.quantity-a.quantity*omi.quantity
from INGREDIENT ing,menuItemIngredients_V a,ORDER_MENU_ITEM omi,ORDERS o
where a.menuItemID = 2
and omi.menuItemID=a.menuItemID
and o.orderID=omi.orderID
and omi.orderID=21
and ing.ingredientsID=a.ingredientsID

select ing.ingredientsID,ing.name,a.quantity,omi.quantity,a.quantity*omi.quantity usedIngredient,ing.quantity from INGREDIENT ing,menuItemIngredients_V a,ORDER_MENU_ITEM omi
where ing.ingredientsID=a.ingredientsID
and a.menuItemID=omi.menuItemID
and omi.menuItemID=2
and omi.orderID=21

select a.menuItemID,a.menuItemName,a.ingredientsID,a.ingredientsName,a.quantity,omi.quantity,a.quantity*omi.quantity usedIngredient --hangi malzemeden ne kadar silince�ini g�sterir
from menuItemIngredients_V a,ORDER_MENU_ITEM omi,ORDERS o
where a.menuItemID = 2
and omi.menuItemID=a.menuItemID
and o.orderID=omi.orderID
and omi.orderID=21

select * from ORDERS o,ORDER_MENU_ITEM omi
where o.orderID=omi.orderID
and omi.orderID=21

select * from ORDER_MENU_ITEM omi,ORDERS o
where omi.menuItemID = 2
and o.orderID = omi.orderID


create nonclustered index IX_MENU_ITEM_NAME on MENU_ITEM(name)

create nonclustered index IX_INGREDIENTS_NAME on INGREDIENT(name)


ALTER TABLE EMPLOYEE	--check constrains
ADD CONSTRAINT salary CHECK (salary< 10001)

insert into EMPLOYEE(employeeID,fName,lName,birthDate,salary,category,managerID,inventoryID,gender) --insert yapmaz
values(16,'Ahmet','Mehmet','1900-01-01',100000,'Waiter',2,NULL,'M');

insert into MENU(menu_date,menuDetail) 
values('2015-12-12','deneme');


select * from EMPLOYEE

select * from RESTAURANT_TABLE rt

select * from MENU

select * from MENU_ITEM

select * from MENU_ITEM_INGREDIENTS

select * from EMPLOYEE

select * from RESTAURANT_TABLE

select * from INGREDIENT

select * from INVENTORY

select * from ORDER_MENU_ITEM

