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
-- INITIAL CATEGORIES
-- ============================================================

INSERT INTO categories (name)
VALUES
('Programming'),
('Database'),
('Networking'),
('Operating System'),
('Algorithms');


-- ============================================================
-- INITIAL AUTHORS
-- ============================================================

INSERT INTO authors (name)
VALUES
('Robert C. Martin'),
('Abraham Silberschatz'),
('Andrew Tanenbaum'),
('Thomas H. Cormen');


-- ============================================================
-- SAMPLE BOOKS
-- ============================================================

INSERT INTO books (
    title,
    isbn,
    category_id,
    price
)
VALUES
(
    'Clean Code',
    '9780132350884',
    1,
    800
),
(
    'Database System Concepts',
    '9780073523323',
    2,
    1200
),
(
    'Computer Networks',
    '9780132126953',
    3,
    1000
),
(
    'Operating System Concepts',
    '9781119456339',
    4,
    1100
),
(
    'Introduction to Algorithms',
    '9780262046305',
    5,
    1500
);


-- ============================================================
-- BOOK-AUTHOR RELATIONSHIPS
-- ============================================================

INSERT INTO book_authors (book_id, author_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 2),
(5, 4);


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
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '14 days'
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
SET returned_at = CURRENT_TIMESTAMP
WHERE id = 1
AND returned_at IS NULL;

UPDATE book_copies
SET status = 'available'
WHERE id = 1;

COMMIT;


-- ============================================================
-- SAMPLE LATE RETURN + FINE
-- ============================================================

-- Create old borrowing for demonstration

INSERT INTO borrowings (
    member_id,
    copy_id,
    borrowed_at,
    due_at,
    returned_at
)
VALUES (
    2,
    3,
    CURRENT_TIMESTAMP - INTERVAL '30 days',
    CURRENT_TIMESTAMP - INTERVAL '16 days',
    CURRENT_TIMESTAMP
);


-- Create fine because book was returned late

INSERT INTO fines (
    borrowing_id,
    amount
)
VALUES (
    2,
    100
);


-- ============================================================
-- PAY FINE
-- ============================================================

UPDATE fines
SET paid_at = CURRENT_TIMESTAMP
WHERE id = 1;


-- ============================================================
-- SELL BOOK COPY
-- ============================================================

-- BEGIN;

-- -- Create sale
-- INSERT INTO sales (
--     member_id,
--     total_amount,
--     sold_at
-- )
-- VALUES (
--     3,
--     800,
--     CURRENT_TIMESTAMP
-- );

-- -- Add exact physical copy to sale
-- INSERT INTO sale_items (
--     sale_id,
--     copy_id,
--     unit_price
-- )
-- VALUES (
--     1,
--     2,
--     800
-- );

-- -- Mark copy as sold
-- UPDATE book_copies
-- SET status = 'sold'
-- WHERE id = 2;

-- COMMIT;


-- ============================================================
-- BASIC QUERIES
-- ============================================================


-- All members

SELECT *
FROM members;


-- All categories

SELECT *
FROM categories;


-- All authors

SELECT *
FROM authors;


-- All books

SELECT *
FROM books;


-- All book copies

SELECT *
FROM book_copies;


-- Available copies

SELECT *
FROM book_copies
WHERE status = 'available';


-- Borrowed copies

SELECT *
FROM book_copies
WHERE status = 'borrowed';


-- Sold copies

SELECT *
FROM book_copies
WHERE status = 'sold';


-- Lost copies

SELECT *
FROM book_copies
WHERE status = 'lost';


-- ============================================================
-- BOOK SEARCH
-- ============================================================


-- Search book by title

SELECT *
FROM books
WHERE title ILIKE '%code%';


-- Search book by author

SELECT
    b.title,
    a.name AS author
FROM books b
JOIN book_authors ba
    ON b.id = ba.book_id
JOIN authors a
    ON ba.author_id = a.id
WHERE a.name ILIKE '%martin%';


-- Books by category

SELECT
    b.title,
    c.name AS category
FROM books b
JOIN categories c
    ON b.category_id = c.id
WHERE c.name = 'Programming';


-- ============================================================
-- BOOK + AUTHOR + CATEGORY INFORMATION
-- ============================================================

SELECT
    b.title,
    STRING_AGG(a.name, ', ') AS authors,
    c.name AS category,
    b.price
FROM books b
JOIN book_authors ba
    ON b.id = ba.book_id
JOIN authors a
    ON ba.author_id = a.id
JOIN categories c
    ON b.category_id = c.id
GROUP BY
    b.id,
    b.title,
    c.name,
    b.price
ORDER BY b.id;


-- ============================================================
-- BOOK + COPY INFORMATION
-- ============================================================

SELECT
    b.title,
    bc.id AS copy_id,
    bc.status
FROM books b
JOIN book_copies bc
    ON b.id = bc.book_id
ORDER BY b.id, bc.id;


-- ============================================================
-- BORROWING HISTORY
-- ============================================================

SELECT
    m.name AS member,
    b.title AS book,
    bc.id AS copy_id,
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


-- ============================================================
-- CURRENT BORROWED BOOKS
-- ============================================================

SELECT
    m.name AS member,
    b.title AS book,
    bc.id AS copy_id,
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


-- ============================================================
-- OVERDUE BOOKS
-- ============================================================

SELECT
    m.name AS member,
    b.title AS book,
    bc.id AS copy_id,
    br.due_at
FROM borrowings br
JOIN members m
    ON br.member_id = m.id
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id
WHERE br.returned_at IS NULL
AND br.due_at < CURRENT_TIMESTAMP;


-- ============================================================
-- FINES
-- ============================================================


-- All fines

SELECT
    f.id,
    m.name AS member,
    b.title AS book,
    f.amount,
    f.paid_at
FROM fines f
JOIN borrowings br
    ON f.borrowing_id = br.id
JOIN members m
    ON br.member_id = m.id
JOIN book_copies bc
    ON br.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id;


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
    COALESCE(SUM(amount), 0) AS total_unpaid_fine
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


-- Detailed sales

SELECT
    s.id AS sale_id,
    m.name AS member,
    b.title AS book,
    si.copy_id,
    si.unit_price,
    s.sold_at
FROM sale_items si
JOIN sales s
    ON si.sale_id = s.id
LEFT JOIN members m
    ON s.member_id = m.id
JOIN book_copies bc
    ON si.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id;


-- Sold book copies

SELECT
    b.title,
    bc.id AS copy_id,
    s.sold_at,
    m.name AS buyer
FROM sale_items si
JOIN book_copies bc
    ON si.copy_id = bc.id
JOIN books b
    ON bc.book_id = b.id
JOIN sales s
    ON si.sale_id = s.id
LEFT JOIN members m
    ON s.member_id = m.id
WHERE bc.status = 'sold';


-- Total sales

SELECT
    COALESCE(SUM(total_amount), 0) AS total_sales
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
-- AGGREGATE QUERIES
-- ============================================================


-- Total copies for each book

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


-- Sold copies for each book

SELECT
    b.title,
    COUNT(bc.id) AS sold_copies
FROM books b
LEFT JOIN book_copies bc
    ON b.id = bc.book_id
    AND bc.status = 'sold'
GROUP BY b.id, b.title;


-- ============================================================
-- MOST BORROWED BOOKS
-- ============================================================

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


-- ============================================================
-- MEMBERS WITH MOST BORROWINGS
-- ============================================================

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

-- Books more expensive than average price

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
-- TRANSACTION + ROLLBACK
-- ============================================================

-- Without Rollback

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 3;

SELECT *
FROM book_copies
WHERE id = 3;

UPDATE book_copies
SET status = 'available'
WHERE id = 3;


-- With Rollback
BEGIN;

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 3;

ROLLBACK;

SELECT *
FROM book_copies
WHERE id = 3;

-- ============================================================
-- DUMMY DATA FOR 3 QUESTIONS
-- ============================================================

-- Q1: Active borrowed copy
INSERT INTO borrowings (
    member_id,
    copy_id,
    borrowed_at,
    due_at
)
VALUES (
    1,
    3,
    CURRENT_TIMESTAMP - INTERVAL '2 days',
    CURRENT_TIMESTAMP + INTERVAL '12 days'
);

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 3;


-- Q1: Lost copy
INSERT INTO borrowings (
    member_id,
    copy_id,
    borrowed_at,
    due_at
)
VALUES (
    2,
    6,
    CURRENT_TIMESTAMP - INTERVAL '20 days',
    CURRENT_TIMESTAMP - INTERVAL '6 days'
);

UPDATE book_copies
SET status = 'lost'
WHERE id = 6;


-- Q1: Another active borrowed copy
INSERT INTO borrowings (
    member_id,
    copy_id,
    borrowed_at,
    due_at
)
VALUES (
    3,
    8,
    CURRENT_TIMESTAMP - INTERVAL '3 days',
    CURRENT_TIMESTAMP + INTERVAL '11 days'
);

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 8;


-- Q2: Unpaid fine for borrowing ID 2
INSERT INTO fines (
    borrowing_id,
    amount
)
VALUES (
    2,
    100.00
);


-- ============================================================
-- Q3: Member purchase
-- ============================================================

-- Create sale
WITH new_sale AS (
    INSERT INTO sales (
        member_id,
        total_amount,
        sold_at
    )
    VALUES (
        3,
        1200.00,
        CURRENT_TIMESTAMP
    )
    RETURNING id
)
INSERT INTO sale_items (
    sale_id,
    copy_id,
    unit_price
)
SELECT
    id,
    4,
    1200.00
FROM new_sale;

-- Mark physical copy as sold
UPDATE book_copies
SET status = 'sold'
WHERE id = 4;


-- ============================================================
-- CHECK DATA
-- ============================================================

SELECT * FROM borrowings;

SELECT * FROM fines;

SELECT * FROM sales;

SELECT * FROM sale_items;

SELECT * FROM book_copies;

-- Q1 — Active Borrowings and Lost Books
SELECT
    m.name AS member_name,
    m.phone,
    b.title,
    bc.status,
    br.borrowed_at
FROM members m
JOIN borrowings br ON m.id = br.member_id
JOIN book_copies bc ON br.copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE bc.status IN ('borrowed', 'lost')
  AND br.returned_at IS NULL
ORDER BY m.id, br.borrowed_at;

-- Q2 — Unpaid Fines Report
SELECT
    m.name AS member_name,
    m.email,
    b.title,
    f.amount AS fine_amount,
    br.due_at
FROM members m
JOIN borrowings br ON m.id = br.member_id
JOIN fines f ON br.id = f.borrowing_id
JOIN book_copies bc ON br.copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE f.paid_at IS NULL
ORDER BY m.id;

-- Q3 — Member Purchase History
SELECT
    m.name AS member_name,
    b.title,
    si.copy_id,
    si.unit_price,
    s.sold_at
FROM sales s
JOIN members m ON s.member_id = m.id
JOIN sale_items si ON s.id = si.sale_id
JOIN book_copies bc ON si.copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE s.member_id IS NOT NULL
ORDER BY s.sold_at;