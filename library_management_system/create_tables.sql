-- ============================================================
-- LIBRARY MANAGEMENT SYSTEM
-- PostgreSQL
-- 10 TABLES
-- ============================================================


-- ============================================================
-- CLEAN START
-- ============================================================

DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS borrowings CASCADE;
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS book_copies CASCADE;
DROP TABLE IF EXISTS book_authors CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
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
-- 2. CATEGORIES
-- ============================================================

CREATE TABLE categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);


-- ============================================================
-- 3. AUTHORS
-- ============================================================

CREATE TABLE authors (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


-- ============================================================
-- 4. BOOKS
-- ============================================================

CREATE TABLE books (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(30) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),

    FOREIGN KEY (category_id)
        REFERENCES categories(id)
);


-- ============================================================
-- 5. BOOK AUTHORS
-- ============================================================

CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,

    PRIMARY KEY (book_id, author_id),

    FOREIGN KEY (book_id)
        REFERENCES books(id)
        ON DELETE CASCADE,

    FOREIGN KEY (author_id)
        REFERENCES authors(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 6. BOOK COPIES
-- ============================================================

CREATE TABLE book_copies (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available',

    FOREIGN KEY (book_id)
        REFERENCES books(id),

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
-- 7. BORROWINGS
-- ============================================================

CREATE TABLE borrowings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrowed_at TIMESTAMP NOT NULL,
    due_at TIMESTAMP NOT NULL,
    returned_at TIMESTAMP,

    FOREIGN KEY (member_id)
        REFERENCES members(id),

    FOREIGN KEY (copy_id)
        REFERENCES book_copies(id),

    CHECK (due_at >= borrowed_at),

    CHECK (
        returned_at IS NULL
        OR returned_at >= borrowed_at
    )
);


-- ============================================================
-- 8. FINES
-- ============================================================

CREATE TABLE fines (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    borrowing_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    paid_at TIMESTAMP,

    FOREIGN KEY (borrowing_id)
        REFERENCES borrowings(id)
);


-- ============================================================
-- 9. SALES
-- ============================================================

CREATE TABLE sales (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    sold_at TIMESTAMP NOT NULL,

    FOREIGN KEY (member_id)
        REFERENCES members(id)
);


-- ============================================================
-- 10. SALE ITEMS
-- ============================================================

CREATE TABLE sale_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id INT NOT NULL,
    copy_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),

    FOREIGN KEY (sale_id)
        REFERENCES sales(id),

    FOREIGN KEY (copy_id)
        REFERENCES book_copies(id),

    UNIQUE (copy_id)
);


-- ============================================================
-- INDEXES
-- ============================================================

-- Books
CREATE INDEX idx_books_category_id
ON books(category_id);

CREATE INDEX idx_books_title
ON books(title);


-- Book Authors
CREATE INDEX idx_book_authors_author_id
ON book_authors(author_id);


-- Book Copies
CREATE INDEX idx_book_copies_book_status
ON book_copies(book_id, status);


-- Borrowings
CREATE INDEX idx_borrowings_member_returned
ON borrowings(member_id, returned_at);

CREATE INDEX idx_borrowings_copy_id
ON borrowings(copy_id);

CREATE INDEX idx_borrowings_due_at
ON borrowings(due_at);


-- Fines
CREATE INDEX idx_fines_unpaid
ON fines(borrowing_id)
WHERE paid_at IS NULL;


-- Sales
CREATE INDEX idx_sales_member_id
ON sales(member_id);


-- Sale Items
CREATE INDEX idx_sale_items_sale_id
ON sale_items(sale_id);