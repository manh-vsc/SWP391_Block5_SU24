-- Create the database if it does not exist
IF DB_ID('ECommerceStore') IS NULL
BEGIN
    CREATE DATABASE ECommerceStore;
END
GO

-- Use the database
USE ECommerceStore;
GO

-- Drop all foreign key constraints and tables if the database already exists
IF DB_ID('ECommerceStore') IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'';

    -- Build dynamic SQL to drop all foreign key constraints
    SELECT @sql += 'ALTER TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + 
                   ' DROP CONSTRAINT ' + QUOTENAME(CONSTRAINT_NAME) + ';'
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_TYPE = 'FOREIGN KEY';

    -- Execute the dynamic SQL to drop foreign key constraints
    EXEC sp_executesql @sql;

    -- Reset the SQL variable for dropping tables
    SET @sql = N'';

    -- Build dynamic SQL to drop all tables
    SELECT @sql += 'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ';'
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE';

    -- Execute the dynamic SQL to drop tables
    EXEC sp_executesql @sql;
END
GO

-- Use the database
USE ECommerceStore;
GO

CREATE TABLE Accounts(
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100) NOT NULL, 
    Hash TEXT NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    Email NVARCHAR(100) UNIQUE NULL,
    Address NVARCHAR(200) NULL,
    Role INT NOT NULL,
    Salt TEXT NOT NULL
);
GO

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL
);
GO

-- Create Brand table
CREATE TABLE Brand (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(100) NOT NULL
);
GO

-- Create Products table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(200) NOT NULL,
    Origin NVARCHAR(100) NULL,
    Material NVARCHAR(100) NULL,
    Price DECIMAL(18,2) NOT NULL,
    TotalQuantity INT NULL,
    CategoryID INT NULL,
    BrandID INT NULL,
    ImageID INT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Products_Brand FOREIGN KEY (BrandID) REFERENCES Brand(BrandID)
);
GO

-- Create ProductStockImport table
CREATE TABLE ProductStockImport (
    ImportID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    ImportDate DATETIME NOT NULL
);
GO

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NULL,
    OrderDate DATETIME NULL,
    Status NVARCHAR(50) NULL,
    CONSTRAINT FK_Orders_Accounts FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
GO

-- Create Stock table with Size as INT and Color as NVARCHAR
CREATE TABLE Stock (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    Size INT NOT NULL,
    Color NVARCHAR(50) NOT NULL,
    StockQuantity INT NOT NULL,
    ImportID INT NULL,
    CONSTRAINT FK_Stock_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- Create StockImportDetail table, referencing StockID instead of ProductID, Size, and Color
CREATE TABLE StockImportDetail (
    StockImportDetailID INT IDENTITY(1,1) PRIMARY KEY,
    StockID INT NOT NULL,
    ImportID INT NOT NULL,
    StockQuantity INT NOT NULL,
    CONSTRAINT FK_StockImportDetail_Stock FOREIGN KEY (StockID) REFERENCES Stock(StockID),
    CONSTRAINT FK_StockImportDetail_ProductStockImport FOREIGN KEY (ImportID) REFERENCES ProductStockImport(ImportID)
);
GO

-- Create Cart table, referencing StockID instead of ProductID, Size, and Color
CREATE TABLE Cart (
    cart_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    StockID INT NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(5,2) DEFAULT 0.00 NOT NULL,
    date_added DATETIME DEFAULT GETDATE() NOT NULL,
    CONSTRAINT FK_Cart_Accounts FOREIGN KEY (customer_id) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_Cart_Stock FOREIGN KEY (StockID) REFERENCES Stock(StockID)
);
GO

-- Create Discounts table, removing Size and Color
CREATE TABLE Discounts (
    discount_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    discount_amount DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_Discounts_Products FOREIGN KEY (product_id) REFERENCES Products(ProductID)
);
GO

-- Create Feedback table, referencing StockID instead of ProductID, Size, and Color
CREATE TABLE Feedback (
    feedback_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    StockID INT NOT NULL,
    rating INT NULL,
    comment TEXT NULL,
    created_at DATETIME DEFAULT GETDATE() NULL,
    CONSTRAINT FK_Feedback_Accounts FOREIGN KEY (customer_id) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_Feedback_Stock FOREIGN KEY (StockID) REFERENCES Stock(StockID)
);
GO

-- Create OrderDetails table, referencing StockID instead of ProductID, Size, and Color
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NULL,
    StockID INT NOT NULL,
    Quantity INT NOT NULL,
    SalePrice DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Stock FOREIGN KEY (StockID) REFERENCES Stock(StockID)
);
GO

-- Create ProductImages table with ImageURL
CREATE TABLE ProductImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    Color NVARCHAR(50) NOT NULL,
    ImageURL NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- Create Wishlist table, referencing StockID instead of ProductID
CREATE TABLE Wishlist (
    WishlistID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    StockID INT NOT NULL,
    DateAdded DATETIME DEFAULT GETDATE() NOT NULL,
    CONSTRAINT FK_Wishlist_Accounts FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_Wishlist_Stock FOREIGN KEY (StockID) REFERENCES Stock(StockID)
);
GO
USE ECommerceStore;
GO

-- Insert data into Accounts
INSERT INTO Accounts (Username, Hash, PhoneNumber, Email, Address, Role, Salt)
VALUES 
('john_doe', 'hashed_password1', '1234567890', 'john@example.com', '123 Elm Street', 1, 'salt1'),
('jane_doe', 'hashed_password2', '0987654321', 'jane@example.com', '456 Oak Avenue', 2, 'salt2');

-- Insert data into Categories
INSERT INTO Categories (CategoryName)
VALUES 
('Shoes'),
('Bags'),
('Clothing');

-- Insert data into Brand
INSERT INTO Brand (BrandName)
VALUES 
('Nike'),
('Adidas'),
('Puma');

-- Insert data into Products
INSERT INTO Products (ProductName, Origin, Material, Price, TotalQuantity, CategoryID, BrandID, ImageID)
VALUES 
('Air Max 2021', 'Vietnam', 'Leather', 150.00, 100, 1, 1, NULL),
('Ultraboost 21', 'Germany', 'Synthetic', 180.00, 200, 1, 2, NULL),
('Suede Classic', 'Vietnam', 'Suede', 120.00, 150, 1, 3, NULL);

-- Insert data into ProductStockImport
INSERT INTO ProductStockImport (AccountID, ImportDate)
VALUES 
(1, GETDATE()),
(2, GETDATE());

-- Insert data into Stock
INSERT INTO Stock (ProductID, Size, Color, StockQuantity, ImportID)
VALUES 
(1, 42, 'Red', 50, 1),
(1, 43, 'Blue', 50, 1),
(2, 42, 'White', 100, 2),
(3, 40, 'Black', 75, 2);

-- Insert data into StockImportDetail
INSERT INTO StockImportDetail (StockID, ImportID, StockQuantity)
VALUES 
(1, 1, 50),
(2, 1, 50),
(3, 2, 100),
(4, 2, 75);

-- Insert data into Orders
INSERT INTO Orders (AccountID, OrderDate, Status)
VALUES 
(1, GETDATE(), 'Pending'),
(2, GETDATE(), 'Shipped');

-- Insert data into Cart
INSERT INTO Cart (customer_id, StockID, quantity, discount, date_added)
VALUES 
(1, 1, 2, 10.00, GETDATE()),
(2, 3, 1, 5.00, GETDATE());

-- Insert data into Discounts
INSERT INTO Discounts (product_id, discount_amount)
VALUES 
(1, 15.00),
(2, 20.00);

-- Insert data into Feedback
INSERT INTO Feedback (customer_id, StockID, rating, comment, created_at)
VALUES 
(1, 1, 5, 'Great product!', GETDATE()),
(2, 3, 4, 'Comfortable and stylish.', GETDATE());

-- Insert data into OrderDetails
INSERT INTO OrderDetails (OrderID, StockID, Quantity, SalePrice)
VALUES 
(1, 1, 2, 140.00),
(2, 3, 1, 170.00);

-- Insert data into ProductImages
INSERT INTO ProductImages (ProductID, Color, ImageURL)
VALUES 
(1, 'Red', 'images/airmax_red.jpg'),
(1, 'Blue', 'images/airmax_blue.jpg'),
(2, 'White', 'images/ultraboost_white.jpg'),
(3, 'Black', 'images/suede_black.jpg');

-- Insert data into Wishlist
INSERT INTO Wishlist (AccountID, StockID, DateAdded)
VALUES 
(1, 2, GETDATE()),
(2, 3, GETDATE());
