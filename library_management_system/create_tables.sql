-- ============================================================
-- LIBRARY MANAGEMENT SYSTEM
-- PostgreSQL
-- 7 TABLES
-- ============================================================


-- ============================================================
-- CLEAN START
-- ============================================================

DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS borrowings CASCADE;
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS book_copies CASCADE;
DROP TABLE IF EXISTS books CASCADE;
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
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0)
);


-- ============================================================
-- 3. BOOK COPIES
-- ============================================================

CREATE TABLE book_copies (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available',

    FOREIGN KEY (book_id) REFERENCES books(id),

    CHECK (
        status IN (
            'available',
            'borrowed',
            'lost',
            'sold'
        )
    )
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
-- 5. FINES
-- ============================================================

CREATE TABLE fines (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    borrowing_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    paid_at DATE,

    FOREIGN KEY (borrowing_id) REFERENCES borrowings(id)
);


-- ============================================================
-- 6. SALES
-- ============================================================

CREATE TABLE sales (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    sold_at DATE NOT NULL,

    FOREIGN KEY (member_id) REFERENCES members(id)
);


-- ============================================================
-- 7. SALE ITEMS
-- ============================================================

CREATE TABLE sale_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id INT NOT NULL,
    copy_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),

    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (copy_id) REFERENCES book_copies(id),

    UNIQUE (copy_id)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_books_title
ON books(title);

CREATE INDEX idx_books_author
ON books(author);

CREATE INDEX idx_books_category
ON books(category);

CREATE INDEX idx_book_copies_book_id
ON book_copies(book_id);

CREATE INDEX idx_book_copies_status
ON book_copies(status);

CREATE INDEX idx_borrowings_member_id
ON borrowings(member_id);

CREATE INDEX idx_borrowings_copy_id
ON borrowings(copy_id);

CREATE INDEX idx_borrowings_due_at
ON borrowings(due_at);

CREATE INDEX idx_fines_borrowing_id
ON fines(borrowing_id);

CREATE INDEX idx_sales_member_id
ON sales(member_id);

CREATE INDEX idx_sale_items_sale_id
ON sale_items(sale_id);