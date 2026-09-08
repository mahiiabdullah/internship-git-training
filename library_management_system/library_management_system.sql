-- ============================================================
-- LIBRARY MANAGEMENT SYSTEM
-- PostgreSQL
--
-- Team:
-- 1. Shajid
-- 2. Munzir
-- 3. Minhaj
-- 4. Fahim
-- 5. Onim
-- 6. Arka
-- 7. Mahi
-- ============================================================


-- ============================================================
-- CLEAN START
-- ============================================================

DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS borrowings CASCADE;
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS purchases CASCADE;
DROP TABLE IF EXISTS book_copies CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS members CASCADE;


-- ============================================================
-- 1. MEMBERS
-- ============================================================

CREATE TABLE members (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20)
);


-- ============================================================
-- 2. BOOKS
-- ============================================================

CREATE TABLE books (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(30) UNIQUE NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);


-- ============================================================
-- 3. BOOK COPIES
-- ============================================================

CREATE TABLE book_copies (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available',

    FOREIGN KEY (book_id) REFERENCES books(id),

    CHECK (status IN ('available', 'borrowed', 'lost'))
);


-- ============================================================
-- 4. BORROWINGS
-- ============================================================

CREATE TABLE borrowings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE,

    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (copy_id) REFERENCES book_copies(id)
);


-- ============================================================
-- 5. RESERVATIONS
-- ============================================================

CREATE TABLE reservations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reserved_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',

    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (book_id) REFERENCES books(id),

    CHECK (status IN ('active', 'fulfilled', 'cancelled'))
);


-- ============================================================
-- 6. FINES
-- ============================================================

CREATE TABLE fines (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    borrowing_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    paid_at DATE,

    FOREIGN KEY (borrowing_id) REFERENCES borrowings(id)
);


-- ============================================================
-- 7. SALES
-- ============================================================

CREATE TABLE sales (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    sold_at DATE NOT NULL,

    FOREIGN KEY (member_id) REFERENCES members(id)
);


-- ============================================================
-- 8. SALE ITEMS
-- ============================================================

CREATE TABLE sale_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),

    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);


-- ============================================================
-- 9. SUPPLIERS
-- ============================================================

CREATE TABLE suppliers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150)
);


-- ============================================================
-- 10. PURCHASES
-- ============================================================

CREATE TABLE purchases (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    purchased_at DATE NOT NULL,

    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_books_title
ON books(title);

CREATE INDEX idx_books_author
ON books(author);

CREATE INDEX idx_book_copies_book_id
ON book_copies(book_id);

CREATE INDEX idx_borrowings_member_id
ON borrowings(member_id);

CREATE INDEX idx_borrowings_copy_id
ON borrowings(copy_id);

CREATE INDEX idx_borrowings_due_at
ON borrowings(due_at);

CREATE INDEX idx_reservations_member_id
ON reservations(member_id);

CREATE INDEX idx_reservations_book_id
ON reservations(book_id);

CREATE INDEX idx_sales_member_id
ON sales(member_id);

CREATE INDEX idx_sale_items_sale_id
ON sale_items(sale_id);

CREATE INDEX idx_sale_items_book_id
ON sale_items(book_id);

CREATE INDEX idx_purchases_supplier_id
ON purchases(supplier_id);

CREATE INDEX idx_purchases_book_id
ON purchases(book_id);


-- ============================================================
-- INITIAL MEMBERS
-- ============================================================

INSERT INTO members (id, name, email, phone)
VALUES
(1, 'Shajid', 'shajid@example.com', '01700000001'),
(2, 'Munzir', 'munzir@example.com', '01700000002'),
(3, 'Minhaj', 'minhaj@example.com', '01700000003'),
(4, 'Fahim', 'fahim@example.com', '01700000004'),
(5, 'Onim', 'onim@example.com', '01700000005'),
(6, 'Arka', 'arka@example.com', '01700000006'),
(7, 'Mahi', 'mahi@example.com', '01700000007');


-- ============================================================
-- SAMPLE BOOKS
-- ============================================================

INSERT INTO books (title, isbn, author, category, price)
VALUES
('Clean Code', '9780132350884', 'Robert C. Martin', 'Programming', 800),
('Database System Concepts', '9780073523323', 'Abraham Silberschatz', 'Database', 1200),
('Computer Networks', '9780132126953', 'Andrew Tanenbaum', 'Networking', 1000),
('Operating System Concepts', '9781119456339', 'Abraham Silberschatz', 'Operating System', 1100),
('Introduction to Algorithms', '9780262046305', 'Thomas H. Cormen', 'Algorithms', 1500);


-- ============================================================
-- SAMPLE BOOK COPIES
-- ============================================================

INSERT INTO book_copies (book_id, status)
VALUES
(1, 'available'),
(1, 'available'),
(1, 'available'),
(2, 'available'),
(2, 'available'),
(3, 'available'),
(3, 'available'),
(4, 'available'),
(5, 'available');


-- ============================================================
-- SAMPLE SUPPLIER
-- ============================================================

INSERT INTO suppliers (name, phone, email)
VALUES
('Tech Books BD', '01800000000', 'techbooks@example.com'),
('Academic Books BD', '01900000000', 'academic@example.com');


-- ============================================================
-- SAMPLE PURCHASES
-- ============================================================

INSERT INTO purchases (
    supplier_id,
    book_id,
    quantity,
    unit_price,
    purchased_at
)
VALUES
(1, 1, 10, 600, CURRENT_DATE),
(1, 2, 5, 900, CURRENT_DATE),
(2, 3, 8, 750, CURRENT_DATE);


-- ============================================================
-- BORROW BOOK
-- ============================================================

BEGIN;

INSERT INTO borrowings (
    member_id,
    copy_id,
    borrowed_at,
    due_at
)
VALUES (
    1,
    1,
    CURRENT_DATE,
    CURRENT_DATE + 14
);

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 1;

COMMIT;


-- ============================================================
-- RETURN BOOK
-- ============================================================

BEGIN;

UPDATE borrowings
SET returned_at = CURRENT_DATE
WHERE id = 1;

UPDATE book_copies
SET status = 'available'
WHERE id = 1;

COMMIT;


-- ============================================================
-- RESERVE BOOK
-- ============================================================

INSERT INTO reservations (
    member_id,
    book_id,
    reserved_at,
    status
)
VALUES (
    2,
    1,
    CURRENT_DATE,
    'active'
);


-- ============================================================
-- CREATE FINE
-- ============================================================

INSERT INTO fines (
    borrowing_id,
    amount
)
VALUES (
    1,
    100
);


-- ============================================================
-- PAY FINE
-- ============================================================

UPDATE fines
SET paid_at = CURRENT_DATE
WHERE id = 1;


-- ============================================================
-- SELL BOOK
-- ============================================================

BEGIN;

INSERT INTO sales (
    member_id,
    total_amount,
    sold_at
)
VALUES (
    3,
    1600,
    CURRENT_DATE
);

INSERT INTO sale_items (
    sale_id,
    book_id,
    quantity,
    unit_price
)
VALUES
(1, 1, 2, 800);

COMMIT;


-- ============================================================
-- BASIC SELECT QUERIES
-- ============================================================

-- All members

SELECT *
FROM members;


-- All books

SELECT *
FROM books;


-- All available copies

SELECT *
FROM book_copies
WHERE status = 'available';


-- Search book by title

SELECT *
FROM books
WHERE title ILIKE '%code%';


-- Search book by author

SELECT *
FROM books
WHERE author ILIKE '%martin%';


-- Books by category

SELECT *
FROM books
WHERE category = 'Programming';


-- ============================================================
-- JOIN QUERIES
-- ============================================================

-- Show borrowing history

SELECT
    m.name AS member,
    b.title AS book,
    br.borrowed_at,
    br.due_at,
    br.returned_at
FROM borrowings br
JOIN members m
    ON br.member_id = m.id
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id;


-- Show current borrowed books

SELECT
    m.name AS member,
    b.title AS book,
    br.borrowed_at,
    br.due_at
FROM borrowings br
JOIN members m
    ON br.member_id = m.id
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id
WHERE br.returned_at IS NULL;


-- Show available books

SELECT
    b.id,
    b.title,
    b.author,
    bc.id AS copy_id
FROM books b
JOIN book_copies bc
    ON b.id = bc.book_id
WHERE bc.status = 'available';


-- ============================================================
-- OVERDUE
-- ============================================================

SELECT
    m.name AS member,
    b.title AS book,
    br.due_at
FROM borrowings br
JOIN members m
    ON br.member_id = m.id
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id
WHERE br.returned_at IS NULL
AND br.due_at < CURRENT_DATE;


-- ============================================================
-- RESERVATIONS
-- ============================================================

SELECT
    m.name AS member,
    b.title AS book,
    r.reserved_at,
    r.status
FROM reservations r
JOIN members m
    ON r.member_id = m.id
JOIN books b
    ON r.book_id = b.id;


-- Active reservations

SELECT
    m.name AS member,
    b.title AS book
FROM reservations r
JOIN members m
    ON r.member_id = m.id
JOIN books b
    ON r.book_id = b.id
WHERE r.status = 'active';


-- ============================================================
-- FINES
-- ============================================================

-- Unpaid fines

SELECT
    m.name AS member,
    b.title AS book,
    f.amount
FROM fines f
JOIN borrowings br
    ON f.borrowing_id = br.id
JOIN members m
    ON br.member_id = m.id
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id
WHERE f.paid_at IS NULL;


-- Total unpaid fine

SELECT
    SUM(amount) AS total_unpaid_fine
FROM fines
WHERE paid_at IS NULL;


-- ============================================================
-- SALES
-- ============================================================

-- All sales

SELECT *
FROM sales;


-- Sales with member names

SELECT
    s.id,
    m.name AS member,
    s.total_amount,
    s.sold_at
FROM sales s
LEFT JOIN members m
    ON s.member_id = m.id;


-- Sale details

SELECT
    s.id AS sale_id,
    m.name AS member,
    b.title AS book,
    si.quantity,
    si.unit_price,
    si.quantity * si.unit_price AS subtotal
FROM sale_items si
JOIN sales s
    ON si.sale_id = s.id
LEFT JOIN members m
    ON s.member_id = m.id
JOIN books b
    ON si.book_id = b.id;


-- Total sales

SELECT
    SUM(total_amount) AS total_sales
FROM sales;


-- Sales by member

SELECT
    m.name,
    SUM(s.total_amount) AS total_spent
FROM sales s
JOIN members m
    ON s.member_id = m.id
GROUP BY m.id, m.name
ORDER BY total_spent DESC;


-- ============================================================
-- PURCHASES
-- ============================================================

SELECT
    p.id,
    s.name AS supplier,
    b.title AS book,
    p.quantity,
    p.unit_price,
    p.quantity * p.unit_price AS total_cost,
    p.purchased_at
FROM purchases p
JOIN suppliers s
    ON p.supplier_id = s.id
JOIN books b
    ON p.book_id = b.id;


-- Total purchase cost

SELECT
    SUM(quantity * unit_price) AS total_purchase_cost
FROM purchases;


-- ============================================================
-- AGGREGATE QUERIES
-- ============================================================

-- Number of copies for each book

SELECT
    b.title,
    COUNT(bc.id) AS total_copies
FROM books b
LEFT JOIN book_copies bc
    ON b.id = bc.book_id
GROUP BY b.id, b.title;


-- Available copies for each book

SELECT
    b.title,
    COUNT(bc.id) AS available_copies
FROM books b
LEFT JOIN book_copies bc
    ON b.id = bc.book_id
    AND bc.status = 'available'
GROUP BY b.id, b.title;


-- Most borrowed books

SELECT
    b.title,
    COUNT(*) AS borrow_count
FROM borrowings br
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id
GROUP BY b.id, b.title
ORDER BY borrow_count DESC;


-- Members with most borrowings

SELECT
    m.name,
    COUNT(br.id) AS borrow_count
FROM members m
JOIN borrowings br
    ON m.id = br.member_id
GROUP BY m.id, m.name
ORDER BY borrow_count DESC;


-- ============================================================
-- SUBQUERY
-- ============================================================

-- Books more expensive than average book price

SELECT
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);


-- ============================================================
-- INDEX TEST
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM books
WHERE title = 'Clean Code';


-- ============================================================
-- ROLLBACK PRACTICE
-- ============================================================

-- Run separately when practicing transactions.

BEGIN;

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 2;

ROLLBACK;


-- Check after rollback

SELECT *
FROM book_copies
WHERE id = 2;