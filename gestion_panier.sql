-- =====================================================
--  GESTION DE PANIER - database for HeidiSQL (MySQL / MariaDB)



-- 1. Create the database and use it
CREATE DATABASE IF NOT EXISTS gestion_panier;
USE gestion_panier;

-- 2. Delete old tables if they exist (so you can run the script again)
DROP TABLE  payment;
DROP TABLE  cart;
DROP TABLE product;
DROP TABLE user;

-- 3. Create the 4 tables
CREATE TABLE user (
    id_user  INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL
);

CREATE TABLE product (
    id_product INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    price      DECIMAL(10,2) NOT NULL
);

-- cart = association ADD TO CART (one line per user + product)
CREATE TABLE cart (
    id_user    INT NOT NULL,
    id_product INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_user, id_product),
    FOREIGN KEY (id_user)    REFERENCES user(id_user),
    FOREIGN KEY (id_product) REFERENCES product(id_product)
);

-- association MAKE: each payment belongs to one user
CREATE TABLE payment (
    id_payment   INT AUTO_INCREMENT PRIMARY KEY,
    amount       DECIMAL(10,2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_user      INT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES user(id_user)
);

-- 4. Add some test data
INSERT INTO user (username, password) VALUES
    ('client1', '1234'),
    ('client2', '1234');

INSERT INTO product (name, price) VALUES
    ('Mouse',           45),
    ('Keyboard',        80),
    ('USB flash drive', 25),
    ('Headphones',     120),
    ('Laptop bag',      90);

INSERT INTO cart (id_user, id_product, quantity) VALUES
    (1, 1, 2),     
    (1, 4, 1);   

INSERT INTO payment (amount, id_user) VALUES
    (205, 2);    


-- Login: returns one line if username and password are correct
SELECT * FROM user WHERE username = 'client1' AND password = '1234';

-- Show products sorted by price (add DESC for the biggest first)
SELECT * FROM product ORDER BY price;

-- Show products sorted by name
SELECT * FROM product ORDER BY name;

-- Add a product to the cart (client 1, product 2, quantity 3)
-- If the product is already in the cart, the quantity is increased
INSERT INTO cart (id_user, id_product, quantity) VALUES (1, 2, 3)
ON DUPLICATE KEY UPDATE quantity = quantity + 3;

-- Show the cart of client 1 (with the total of each line)
SELECT product.id_product, product.name, product.price, cart.quantity,
       product.price * cart.quantity AS line_total
FROM cart
JOIN product ON product.id_product = cart.id_product
WHERE cart.id_user = 1;

-- Total of the cart of client 1
SELECT SUM(product.price * cart.quantity) AS total
FROM cart
JOIN product ON product.id_product = cart.id_product
WHERE cart.id_user = 1;

-- Remove one product from the cart of client 1 (change the product id)
DELETE FROM cart WHERE id_user = 1 AND id_product = 1;

-- Pay: step 1 - save the payment (amount = total of the cart)
INSERT INTO payment (id_user, amount)
SELECT 1, SUM(product.price * cart.quantity)
FROM cart
JOIN product ON product.id_product = cart.id_product
WHERE cart.id_user = 1;

-- Pay: step 2 - empty the cart of client 1
DELETE FROM cart WHERE id_user = 1;

-- See all payments with the name of the user
SELECT payment.id_payment, user.username, payment.amount, payment.payment_date
FROM payment
JOIN user ON user.id_user = payment.id_user;
