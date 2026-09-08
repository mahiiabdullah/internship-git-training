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

INSERT INTO books (
    title,
    isbn,
    author,
    category,
    price
)
VALUES
(
    'Clean Code',
    '9780132350884',
    'Robert C. Martin',
    'Programming',
    800
),
(
    'Database System Concepts',
    '9780073523323',
    'Abraham Silberschatz',
    'Database',
    1200
),
(
    'Computer Networks',
    '9780132126953',
    'Andrew Tanenbaum',
    'Networking',
    1000
),
(
    'Operating System Concepts',
    '9781119456339',
    'Abraham Silberschatz',
    'Operating System',
    1100
),
(
    'Introduction to Algorithms',
    '9780262046305',
    'Thomas H. Cormen',
    'Algorithms',
    1500
);


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
-- SAMPLE LATE RETURN + FINE
-- ============================================================

-- Create an old borrowing for demonstration

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
    CURRENT_DATE - 30,
    CURRENT_DATE - 16,
    CURRENT_DATE
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
SET paid_at = CURRENT_DATE
WHERE id = 1;


-- ============================================================
-- SELL BOOK COPY
-- ============================================================

BEGIN;

-- Create sale

INSERT INTO sales (
    member_id,
    total_amount,
    sold_at
)
VALUES (
    3,
    800,
    CURRENT_DATE
);

-- Add exact physical copy to sale

INSERT INTO sale_items (
    sale_id,
    copy_id,
    unit_price
)
VALUES (
    1,
    2,
    800
);

-- Mark copy as sold

UPDATE book_copies
SET status = 'sold'
WHERE id = 2;

COMMIT;


-- ============================================================
-- BASIC QUERIES
-- ============================================================

-- All members

SELECT *
FROM members;


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
-- BOOK + COPY INFORMATION
-- ============================================================

SELECT
    b.title,
    b.author,
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
AND br.due_at < CURRENT_DATE;


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

BEGIN;

UPDATE book_copies
SET status = 'borrowed'
WHERE id = 3;

ROLLBACK;


-- Check rollback

SELECT *
FROM book_copies
WHERE id = 3;