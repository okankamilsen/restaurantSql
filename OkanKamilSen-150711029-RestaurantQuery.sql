CREATE VIEW menuItemIngredients_V AS
select distinct mi.menuItemID,mi.name menuItemName,mii.quantity,i.name ingredientsName,i.ingredientsID 
from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii,ORDER_MENU_ITEM omi	-- hangi ürünün içinde neler olduðunu gösterir.
where i.ingredientsID = mii.ingredientsID
and mii.menuItemID = mi.menuItemID
and omi.menuItemID=mi.menuItemID

select * from menuItemIngredients_V a
where a.menuItemID = 3

select * from ORDERTOTALPRICE_V

select * from MENU_ITEM mi, MENU m				-- hangi menüde neler olduðunu gösterir
where mi.menuID = m.menuID
and mi.menuID = 3

select mi.name, mi.price,omi.quantity from ORDERS o, ORDER_MENU_ITEM omi, MENU_ITEM mi  --orderý ve fiyatlarý gösterir
where o.orderID = omi.orderID
and omi.menuItemID = mi.menuItemID
and o.orderID = 20

select o.orderID,Sum(a.totalprice) totalPrice	-- total price
from ORDERS o,(select o.orderID,mi.name,mi.price,omi.quantity, omi.quantity*mi.price totalprice --hangi orderýn neler aldýðý ve fiyatlarý
		from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi
		where o.orderID=omi.orderID
		and mi.menuItemID = omi.menuItemID
		group by o.orderID,mi.name,mi.price,omi.quantity) a
where a.orderID = o.orderID
group by o.orderID

select * from ORDERS o	-- ödenmiþ masalarý gösterir.
where o.isPaid = 1

UPDATE ORDERS	--orderýn kaç para olduðunu hesaplar
SET totalPrice = b.total
from ORDERS o,(select o.orderID,sum(a.totalprice) total
				from ORDERS o,(select o.orderID ,mi.name,mi.price,omi.quantity, omi.quantity*mi.price totalprice --hangi orderýn neler aldýðý ve fiyatlarý
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
				from ORDERS o,(select o.orderID ,mi.name,mi.price,omi.quantity, omi.quantity*mi.price totalprice --hangi orderýn neler aldýðý ve fiyatlarý
								from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi
								where o.orderID=omi.orderID
								and mi.menuItemID = omi.menuItemID
								group by o.orderID,mi.name,mi.price,omi.quantity) a
				where o.orderID = a.orderID
				group by o.orderID) b
where o.orderID=b.orderID

select * from ORDERTOTALPRICE_V

CREATE PROCEDURE calculateDailyAmount			--günlük amount hesaplanýr input date
	@date date,					--****** bu input input yazmak zorunda deðiliz
	@totalDailyAmount decimal(7,2) OUTPUT 
AS
select @totalDailyAmount=sum(otpv.totalPrice)		-- ****** output parametresine deðer eþledik. -- ama number of students tek bir integer yani onu bi listeye eþitleyemezsin.
from ORDERTOTALPRICE_V otpv
where otpv.date = @date


declare @param1 decimal(7,2);  -- gün girilip deðer gösterilir.
declare @date date
SET @date = '2015-12-12'
exec calculateDailyAmount @date, @param1 OUTPUT; --**** 1 inputa atandý. diðerleri output
select @param1;

select * from ORDERS

select o.tableID,SUM(o.totalPrice) from ORDERS o
where o.tableID=3 group by o.tableID


select o.employeeID,e.fName,e.lName,sum(o.totalPrice) totalSales from ORDERS o,EMPLOYEE e --hangi garsonun ne kadar satýþ yaptýðý
where o.employeeID=e.employeeID
group by o.employeeID,e.fName,e.lName
order by totalSales desc

select omi.menuItemID,mi.name,sum(omi.quantity) totalSales				-- hangi üründen ne kadar satýlmýþ
from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi							-- en çok satýlandan en aza kadar sýralý
where o.orderID = omi.orderID
and mi.menuItemID = omi.menuItemID
group by omi.menuItemID,mi.name 
order by totalSales desc

select mi.name,sum(omi.quantity) ass from ORDER_MENU_ITEM omi,MENU_ITEM mi	--yukardakiyle ayný
where omi.menuItemID = mi.menuItemID
group by mi.name 
order by ass desc

CREATE VIEW usedIngredients_V AS
select i.ingredientsID,i.name,sum(a.quantity*b.ass) used				-- hangi malzemeden ne kadar kullanýlmýþ 
from INGREDIENT i,(select mi.menuItemID,mi.name menuItemName,mii.ingredientsID,mii.quantity,i.name ingredientsName
				from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	-- hangi ürünün içinde neler olduðunu gösterir.
				where i.ingredientsID = mii.ingredientsID
				and mii.menuItemID = mi.menuItemID) as a	
				,(select mi.menuItemID,mi.name,sum(omi.quantity) ass 
				from ORDER_MENU_ITEM omi,MENU_ITEM mi					--hangi üründen ne kadar satýlmýþ
				where omi.menuItemID = mi.menuItemID
				group by mi.name, mi.menuItemID) as b	
where a.menuItemID=b.menuItemID		
and i.ingredientsID=a.ingredientsID
group by i.ingredientsID,i.name
--order by used desc

select * from usedIngredients_V a
order by a.used desc


select mi.menuItemID,mi.name menuItemName,mii.ingredientsID,mii.quantity,i.name ingredientsName,i.cost*mii.quantity
				from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	-- hangi ürünün içinde neler olduðunu gösterir.
				where i.ingredientsID = mii.ingredientsID
				and mii.menuItemID = mi.menuItemID


select mi.menuItemID,mi.name,sum(i.cost*mii.quantity) cost			-- bir ürünün maliyeti
				from INGREDIENT i, MENU_ITEM mi,MENU_ITEM_INGREDIENTS mii	-- hangi ürünün içinde neler olduðunu gösterir.
				where i.ingredientsID = mii.ingredientsID
				and mii.menuItemID = mi.menuItemID
				group by mi.menuItemID,mi.name

CREATE VIEW menuItemProfitPriceCost_V AS
select distinct a.menuItemID,a.name,a.price,a.cost,a.price-a.cost profit				-- bir ürünün satýþ fiyatý karý maliyeti
 from MENU_ITEM mi,(select mi.menuItemID,mi.name,mi.price,sum(i.cost*mii.quantity) cost		--satýþ fiyatý maliyet hesaplanýr	
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

CREATE PROCEDURE performanceOfWaiter			--hangi garsonun ne kadar satýþ yaptýðý
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
exec performanceOfWaiter @waiterID, @param1 OUTPUT; --ýdsi 7 olan garsonun toplam satýþý
select @param1;

select omi.menuItemID,mi.name,sum(omi.quantity) totalSales				-- hangi üründen ne kadar satýlmýþ
from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi							-- en çok satýlandan en aza kadar sýralý
where o.orderID = omi.orderID
and mi.menuItemID = omi.menuItemID
and mi.menuItemID = 8
group by omi.menuItemID,mi.name 
order by totalSales desc

CREATE PROCEDURE performanceOfMenuItem			--bir üründen ne kadar satýlmýþ
	@productID int,					
	@totalSales int OUTPUT 
AS
select @totalSales=sum(omi.quantity)				-- hangi üründen ne kadar satýlmýþ
from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi							-- en çok satýlandan en aza kadar sýralý
where o.orderID = omi.orderID
and mi.menuItemID = @productID
and mi.menuItemID = omi.menuItemID


declare @param1 int;  
declare @productID int		--ürün idsi girilip ne kadar satýldýðý gözükür
SET @productID = 8
exec performanceOfMenuItem @productID, @param1 OUTPUT;
select @param1;

CREATE PROCEDURE addIngredients			--bir üründen ne kadar satýlmýþ
	@ingredientsID int,	
	@amount int,						
	@newValue int OUTPUT
AS
update INGREDIENT
set quantity=i.quantity+@amount,@newValue=i.quantity+@amount				-- hangi üründen ne kadar satýlmýþ
from INGREDIENT i							-- en çok satýlandan en aza kadar sýralý
where i.ingredientsID=@ingredientsID


declare @param1 int;  
declare @ingredientsID int		--ürün idsi girilip ne kadar satýldýðý gözükür
declare @amount int
SET @ingredientsID = 1
set @amount = 100
exec addIngredients @ingredientsID,@amount, @param1 OUTPUT;
select @param1;

select * from EMPLOYEE

CREATE PROCEDURE takeOrder			--sipariþ almak insertle menuitemordera giriliyo
	@orderMenuItemID int,
	@quantity int,	
	@menuItemID int,
	@orderID int
AS
insert into ORDER_MENU_ITEM(orderMenuItemID,quantity,menuItemID,orderID) 
values(@orderMenuItemID,@quantity,@menuItemID,@orderID);			--ordermenuýtem insert.


 
declare @orderMenuItemID int;			--73 idsine yeni order aldý her seferinde bu idyi 1 arttýr.
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

select omi.quantity,mi.name,mi.price,mi.price*omi.quantity total from ORDERS o,ORDER_MENU_ITEM omi,MENU_ITEM mi  --nelerin sipariþ edildiðini gösterir
where o.orderID=omi.orderID
and mi.menuItemID=omi.menuItemID
and o.orderID=1

select * from ORDERTOTALPRICE_V a		-- total price deðiþip deðiþmediði görülür
where a.orderID=1

select * from orderProfitPriceCost_V a
where a.orderID=1

select * from usedIngredients_V


CREATE TRIGGER calculateTotalTablePrice ON ORDER_MENU_ITEM
AFTER insert AS 
BEGIN--optional
Declare @addedPrice decimal(7,2);
select @addedPrice=i.quantity*mi.price from inserted i,MENU_ITEM mi	--quantity ve ürün fiyatý çarpýlýr ne kadar eklenceði bulunur
where mi.menuItemID=i.menuItemID
update ORDERS
set totalPrice=o.totalPrice+@addedPrice				-- hangi üründen ne kadar satýlmýþ
from ORDERS o,inserted i,MENU_ITEM mi							-- en çok satýlandan en aza kadar sýralý
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

Update INGREDIENT		--sipariþe bakar idsini alir kaç tane sipariþ edildiðine göre içerikleri stocktan düþer
set quantity=ing.quantity-a.quantity*omi.quantity
from INGREDIENT ing,menuItemIngredients_V a,inserted omi,ORDERS o
where a.menuItemID = @menuItemID--2
and omi.menuItemID=a.menuItemID
and o.orderID=omi.orderID
and omi.orderID=@orderID--21
and ing.ingredientsID=a.ingredientsID

END;



Update INGREDIENT		--sipariþe bakar idsini alir kaç tane sipariþ edildiðine göre içerikleri stocktan düþer
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

select a.menuItemID,a.menuItemName,a.ingredientsID,a.ingredientsName,a.quantity,omi.quantity,a.quantity*omi.quantity usedIngredient --hangi malzemeden ne kadar silinceðini gösterir
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

