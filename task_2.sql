-- Task 2: Library Management System Database
-- Comprehensive SQL operations for library book lending and member management

-- ================================
-- 1. DATABASE SCHEMA SETUP
-- ================================

-- Drop existing tables for clean setup
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS library_branches;

-- Create library branches table
CREATE TABLE library_branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    opening_hours VARCHAR(100),
    manager_name VARCHAR(100),
    established_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create staff table
CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE NOT NULL,
    branch_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id)
);

-- Create members table
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    date_of_birth DATE,
    registration_date DATE DEFAULT (CURRENT_DATE),
    membership_type ENUM('Student', 'Adult', 'Senior', 'Child') DEFAULT 'Adult',
    membership_expiry DATE,
    library_card_number VARCHAR(20) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    branch_id INT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id),
    INDEX idx_member_card (library_card_number),
    INDEX idx_member_branch (branch_id)
);

-- Create genres table
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Create authors table
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create books table
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher VARCHAR(100),
    publication_year YEAR,
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    genre_id INT,
    shelf_location VARCHAR(20),
    added_date DATE DEFAULT (CURRENT_DATE),
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id),
    INDEX idx_book_isbn (isbn),
    INDEX idx_book_genre (genre_id),
    INDEX idx_book_title (title)
);

-- Create book_authors junction table (many-to-many)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Create book copies table
CREATE TABLE book_copies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    condition_status ENUM('Excellent', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'Good',
    acquisition_date DATE DEFAULT (CURRENT_DATE),
    cost DECIMAL(8,2),
    is_available BOOLEAN DEFAULT TRUE,
    location_details VARCHAR(100),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id),
    INDEX idx_copy_book (book_id),
    INDEX idx_copy_branch (branch_id),
    INDEX idx_copy_barcode (barcode)
);

-- Create loans table
CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    staff_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    renewal_count INT DEFAULT 0,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    notes TEXT,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    INDEX idx_loan_member (member_id),
    INDEX idx_loan_copy (copy_id),
    INDEX idx_loan_due_date (due_date),
    INDEX idx_loan_status (status)
);

-- Create reservations table
CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE DEFAULT (CURRENT_DATE),
    expiry_date DATE,
    status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Active',
    priority_level INT DEFAULT 1,
    notification_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    INDEX idx_reservation_member (member_id),
    INDEX idx_reservation_book (book_id),
    INDEX idx_reservation_status (status)
);

-- Create fines table
CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    loan_id INT,
    fine_type ENUM('Overdue', 'Damage', 'Lost Book', 'Late Return') DEFAULT 'Overdue',
    amount DECIMAL(8,2) NOT NULL,
    issue_date DATE DEFAULT (CURRENT_DATE),
    due_date DATE,
    paid_date DATE NULL,
    status ENUM('Pending', 'Paid', 'Waived', 'Partial') DEFAULT 'Pending',
    description TEXT,
    staff_id INT,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    INDEX idx_fine_member (member_id),
    INDEX idx_fine_status (status)
);

-- ================================
-- 2. SAMPLE DATA INSERTION
-- ================================

-- Insert library branches
INSERT INTO library_branches (branch_name, address, phone, email, opening_hours, manager_name, established_date) VALUES
('Central Library', '123 Main Street, Downtown', '555-0001', 'central@library.org', 'Mon-Sat: 8AM-8PM, Sun: 10AM-6PM', 'Sarah Johnson', '1985-03-15'),
('North Branch', '456 Oak Avenue, North District', '555-0002', 'north@library.org', 'Mon-Fri: 9AM-7PM, Sat: 9AM-5PM', 'Michael Brown', '1995-08-22'),
('South Branch', '789 Pine Road, South District', '555-0003', 'south@library.org', 'Mon-Fri: 10AM-6PM, Sat: 10AM-4PM', 'Lisa Davis', '2001-11-10'),
('East Branch', '321 Elm Street, East Side', '555-0004', 'east@library.org', 'Tue-Sat: 9AM-7PM, Sun: 12PM-5PM', 'David Wilson', '2008-06-05');

-- Insert staff
INSERT INTO staff (first_name, last_name, email, phone, position, salary, hire_date, branch_id) VALUES
('Sarah', 'Johnson', 'sarah.johnson@library.org', '555-1001', 'Head Librarian', 65000.00, '2010-01-15', 1),
('Michael', 'Brown', 'michael.brown@library.org', '555-1002', 'Branch Manager', 58000.00, '2012-03-20', 2),
('Lisa', 'Davis', 'lisa.davis@library.org', '555-1003', 'Branch Manager', 58000.00, '2015-09-10', 3),
('David', 'Wilson', 'david.wilson@library.org', '555-1004', 'Branch Manager', 58000.00, '2018-02-14', 4),
('Emily', 'Garcia', 'emily.garcia@library.org', '555-1005', 'Librarian', 45000.00, '2019-06-01', 1),
('Robert', 'Miller', 'robert.miller@library.org', '555-1006', 'Assistant Librarian', 38000.00, '2020-08-15', 1),
('Jennifer', 'Taylor', 'jennifer.taylor@library.org', '555-1007', 'Librarian', 45000.00, '2021-01-10', 2),
('James', 'Anderson', 'james.anderson@library.org', '555-1008', 'Technical Support', 42000.00, '2021-11-05', 1);

-- Insert genres
INSERT INTO genres (genre_name, description) VALUES
('Fiction', 'Imaginative or invented stories and novels'),
('Non-Fiction', 'Factual books about real events, people, or subjects'),
('Science Fiction', 'Fiction dealing with futuristic concepts and advanced technology'),
('Mystery', 'Fiction dealing with puzzling crimes or unexplained events'),
('Biography', 'Account of someone\'s life written by someone else'),
('History', 'Books about past events and civilizations'),
('Romance', 'Fiction dealing with romantic relationships'),
('Fantasy', 'Fiction involving magical or supernatural elements'),
('Children', 'Books specifically written for children'),
('Young Adult', 'Fiction targeted at teenage readers'),
('Self-Help', 'Books designed to help readers improve their lives'),
('Science', 'Books about scientific subjects and discoveries');

-- Insert authors
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography) VALUES
('George', 'Orwell', '1903-06-25', 'British', 'English novelist and journalist, famous for 1984 and Animal Farm'),
('Jane', 'Austen', '1775-12-16', 'British', 'English novelist known for her social commentary'),
('Stephen', 'King', '1947-09-21', 'American', 'American author of horror, supernatural fiction, suspense, and fantasy novels'),
('Agatha', 'Christie', '1890-09-15', 'British', 'English writer known for detective novels'),
('J.K.', 'Rowling', '1965-07-31', 'British', 'British author, best known for the Harry Potter series'),
('Ernest', 'Hemingway', '1899-07-21', 'American', 'American novelist and journalist'),
('Maya', 'Angelou', '1928-04-04', 'American', 'American poet, memoirist, and civil rights activist'),
('Isaac', 'Asimov', '1920-01-02', 'American', 'American writer and professor of biochemistry, known for science fiction'),
('Virginia', 'Woolf', '1882-01-25', 'British', 'English writer and modernist'),
('Mark', 'Twain', '1835-11-30', 'American', 'American writer and humorist');

-- Insert books
INSERT INTO books (title, isbn, publisher, publication_year, pages, genre_id, shelf_location, description) VALUES
('1984', '978-0452284234', 'Plume', 1949, 328, 1, 'A-101', 'Dystopian social science fiction novel'),
('Animal Farm', '978-0451526342', 'Signet Classics', 1945, 112, 1, 'A-102', 'Allegorical novella about farm animals'),
('Pride and Prejudice', '978-0486284736', 'Dover Publications', 1813, 272, 1, 'A-201', 'Romantic novel about manners and marriage'),
('The Shining', '978-0307743657', 'Anchor', 1977, 688, 1, 'B-301', 'Horror novel about a haunted hotel'),
('Murder on the Orient Express', '978-0062693662', 'William Morrow', 1934, 256, 4, 'C-101', 'Detective novel featuring Hercule Poirot'),
('Harry Potter and the Philosopher\'s Stone', '978-0747532699', 'Bloomsbury', 1997, 223, 8, 'D-101', 'First book in the Harry Potter series'),
('The Old Man and the Sea', '978-0684801223', 'Scribner', 1952, 127, 1, 'E-101', 'Novella about an aging fisherman'),
('I Know Why the Caged Bird Sings', '978-0345514400', 'Ballantine Books', 1969, 289, 5, 'F-101', 'Autobiographical work'),
('Foundation', '978-0553293357', 'Spectra', 1951, 244, 3, 'G-101', 'Science fiction novel about psychohistory'),
('To the Lighthouse', '978-0156907392', 'Mariner Books', 1927, 209, 1, 'H-101', 'Modernist novel'),
('The Adventures of Tom Sawyer', '978-0486400778', 'Dover Publications', 1876, 216, 9, 'I-101', 'Children\'s adventure novel'),
('A Brief History of Time', '978-0553380163', 'Bantam', 1988, 256, 12, 'J-101', 'Popular science book about cosmology');

-- Insert book-author relationships
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), (2, 1), (3, 2), (4, 3), (5, 4), (6, 5), (7, 6), (8, 7), (9, 8), (10, 9), (11, 10);

-- Insert members
INSERT INTO members (first_name, last_name, email, phone, address, date_of_birth, membership_type, membership_expiry, library_card_number, branch_id) VALUES
('John', 'Smith', 'john.smith@email.com', '555-2001', '123 Elm Street', '1985-03-15', 'Adult', '2025-03-15', 'LIB001234', 1),
('Emma', 'Johnson', 'emma.johnson@email.com', '555-2002', '456 Oak Avenue', '1992-07-22', 'Adult', '2025-07-22', 'LIB001235', 1),
('Michael', 'Davis', 'michael.davis@email.com', '555-2003', '789 Pine Road', '2005-11-08', 'Student', '2024-11-08', 'LIB001236', 2),
('Sarah', 'Wilson', 'sarah.wilson@email.com', '555-2004', '321 Maple Drive', '1978-01-30', 'Adult', '2025-01-30', 'LIB001237', 2),
('David', 'Brown', 'david.brown@email.com', '555-2005', '654 Cedar Lane', '1965-09-12', 'Senior', '2025-09-12', 'LIB001238', 3),
('Lisa', 'Garcia', 'lisa.garcia@email.com', '555-2006', '987 Birch Street', '1990-05-18', 'Adult', '2025-05-18', 'LIB001239', 3),
('Robert', 'Miller', 'robert.miller@email.com', '555-2007', '147 Willow Court', '2010-12-03', 'Child', '2025-12-03', 'LIB001240', 4),
('Emily', 'Taylor', 'emily.taylor@email.com', '555-2008', '258 Spruce Avenue', '2002-04-25', 'Student', '2024-04-25', 'LIB001241', 4);

-- Insert book copies
INSERT INTO book_copies (book_id, branch_id, barcode, condition_status, cost) VALUES
-- Central Library copies
(1, 1, 'BC001001', 'Excellent', 15.99), (1, 1, 'BC001002', 'Good', 15.99),
(2, 1, 'BC002001', 'Good', 12.99), (3, 1, 'BC003001', 'Excellent', 14.99),
(4, 1, 'BC004001', 'Good', 18.99), (5, 1, 'BC005001', 'Excellent', 16.99),
(6, 1, 'BC006001', 'Good', 22.99), (6, 1, 'BC006002', 'Good', 22.99),
-- North Branch copies
(1, 2, 'BC001003', 'Good', 15.99), (3, 2, 'BC003002', 'Good', 14.99),
(4, 2, 'BC004002', 'Excellent', 18.99), (7, 2, 'BC007001', 'Good', 13.99),
(8, 2, 'BC008001', 'Excellent', 17.99), (9, 2, 'BC009001', 'Good', 19.99),
-- South Branch copies
(2, 3, 'BC002002', 'Good', 12.99), (5, 3, 'BC005002', 'Good', 16.99),
(6, 3, 'BC006003', 'Excellent', 22.99), (10, 3, 'BC010001', 'Good', 15.99),
(11, 3, 'BC011001', 'Good', 14.99), (12, 3, 'BC012001', 'Excellent', 21.99),
-- East Branch copies
(1, 4, 'BC001004', 'Good', 15.99), (3, 4, 'BC003003', 'Good', 14.99),
(7, 4, 'BC007002', 'Excellent', 13.99), (9, 4, 'BC009002', 'Good', 19.99);

-- Insert loans
INSERT INTO loans (member_id, copy_id, staff_id, loan_date, due_date, return_date, status) VALUES
(1, 1, 1, '2024-07-01', '2024-07-15', '2024-07-14', 'Returned'),
(2, 3, 1, '2024-07-05', '2024-07-19', '2024-07-18', 'Returned'),
(3, 9, 2, '2024-07-10', '2024-07-24', NULL, 'Active'),
(4, 11, 2, '2024-07-12', '2024-07-26', NULL, 'Active'),
(5, 15, 3, '2024-07-08', '2024-07-22', NULL, 'Overdue'),
(6, 17, 3, '2024-07-15', '2024-07-29', NULL, 'Active'),
(1, 7, 1, '2024-07-20', '2024-08-03', NULL, 'Active'),
(2, 13, 1, '2024-07-18', '2024-08-01', NULL, 'Active');

-- Insert reservations
INSERT INTO reservations (member_id, book_id, reservation_date, expiry_date, status) VALUES
(7, 6, '2024-07-25', '2024-08-08', 'Active'),
(8, 1, '2024-07-26', '2024-08-09', 'Active'),
(1, 4, '2024-07-20', '2024-08-03', 'Active');

-- Insert fines
INSERT INTO fines (member_id, loan_id, fine_type, amount, issue_date, due_date, status, staff_id) VALUES
(5, 5, 'Overdue', 2.50, '2024-07-23', '2024-08-06', 'Pending', 3),
(1, 1, 'Late Return', 0.50, '2024-07-15', '2024-07-29', 'Paid', 1);

-- ================================
-- 3. BASIC LIBRARY QUERIES
-- ================================

-- View all available books with author information
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    g.genre_name,
    b.publication_year,
    b.isbn,
    COUNT(bc.copy_id) as total_copies,
    SUM(CASE WHEN bc.is_available = TRUE THEN 1 ELSE 0 END) as available_copies
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
INNER JOIN genres g ON b.genre_id = g.genre_id
INNER JOIN book_copies bc ON b.book_id = bc.book_id
WHERE b.is_available = TRUE
GROUP BY b.book_id, b.title, a.first_name, a.last_name, g.genre_name, b.publication_year, b.isbn
ORDER BY b.title;

-- Active members with their current loans
SELECT 
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    m.library_card_number,
    m.membership_type,
    b.title as book_title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as days_overdue,
    l.status,
    lb.branch_name
FROM members m
INNER JOIN loans l ON m.member_id = l.member_id
INNER JOIN book_copies bc ON l.copy_id = bc.copy_id
INNER JOIN books b ON bc.book_id = b.book_id
INNER JOIN library_branches lb ON bc.branch_id = lb.branch_id
WHERE l.status IN ('Active', 'Overdue')
AND m.is_active = TRUE
ORDER BY l.due_date;

-- Overdue books report
SELECT 
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    m.phone,
    m.email,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as days_overdue,
    lb.branch_name
FROM loans l
INNER JOIN members m ON l.member_id = m.member_id
INNER JOIN book_copies bc ON l.copy_id = bc.copy_id
INNER JOIN books b ON bc.book_id = b.book_id
INNER JOIN library_branches lb ON bc.branch_id = lb.branch_id
WHERE l.status = 'Overdue' OR (l.status = 'Active' AND l.due_date < CURDATE())
ORDER BY days_overdue DESC;

-- ================================
-- 4. ADVANCED LIBRARY ANALYTICS
-- ================================

-- Most popular books by loan frequency
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    g.genre_name,
    COUNT(l.loan_id) as total_loans,
    COUNT(DISTINCT l.member_id) as unique_borrowers,
    ROUND(AVG(DATEDIFF(COALESCE(l.return_date, CURDATE()), l.loan_date)), 1) as avg_loan_duration
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
INNER JOIN genres g ON b.genre_id = g.genre_id
INNER JOIN book_copies bc ON b.book_id = bc.book_id
INNER JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY b.book_id, b.title, a.first_name, a.last_name, g.genre_name
HAVING total_loans > 0
ORDER BY total_loans DESC, unique_borrowers DESC;

-- Member activity analysis
SELECT 
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    m.membership_type,
    m.registration_date,
    DATEDIFF(CURDATE(), m.registration_date) as days_as_member,
    COUNT(l.loan_id) as total_loans,
    COUNT(CASE WHEN l.status = 'Returned' THEN 1 END) as returned_books,
    COUNT(CASE WHEN l.status IN ('Active', 'Overdue') THEN 1 END) as current_loans,
    COALESCE(SUM(f.amount), 0) as total_fines,
    COALESCE(SUM(CASE WHEN f.status = 'Pending' THEN f.amount ELSE 0 END), 0) as pending_fines,
    MAX(l.loan_date) as last_activity_date,
    lb.branch_name as home_branch
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON m.member_id = f.member_id
INNER JOIN library_branches lb ON m.branch_id = lb.branch_id
WHERE m.is_active = TRUE
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type, m.registration_date, lb.branch_name
ORDER BY total_loans DESC;

-- Branch performance comparison
SELECT 
    lb.branch_name,
    COUNT(DISTINCT m.member_id) as total_members,
    COUNT(DISTINCT bc.copy_id) as total_books,
    COUNT(l.loan_id) as total_loans,
    COUNT(CASE WHEN l.status = 'Overdue' OR (l.status = 'Active' AND l.due_date < CURDATE()) THEN 1 END) as overdue_loans,
    ROUND(COUNT(l.loan_id) / COUNT(DISTINCT bc.copy_id), 2) as loans_per_book,
    COALESCE(SUM(f.amount), 0) as total_fines_issued,
    COUNT(DISTINCT s.staff_id) as staff_count
FROM library_branches lb
LEFT JOIN members m ON lb.branch_id = m.branch_id AND m.is_active = TRUE
LEFT JOIN book_copies bc ON lb.branch_id = bc.branch_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
LEFT JOIN staff s ON lb.branch_id = s.branch_id AND s.is_active = TRUE
WHERE lb.is_active = TRUE
GROUP BY lb.branch_id, lb.branch_name
ORDER BY total_loans DESC;

-- Genre popularity analysis
SELECT 
    g.genre_name,
    COUNT(DISTINCT b.book_id) as books_in_genre,
    COUNT(bc.copy_id) as total_copies,
    COUNT(l.loan_id) as total_loans,
    ROUND(COUNT(l.loan_id) / COUNT(DISTINCT b.book_id), 2) as avg_loans_per_book,
    COUNT(r.reservation_id) as total_reservations,
    ROUND(COUNT(l.loan_id) / COUNT(bc.copy_id) * 100, 2) as utilization_rate
FROM genres g
LEFT JOIN books b ON g.genre_id = b.genre_id AND b.is_available = TRUE
LEFT JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
LEFT JOIN reservations r ON b.book_id = r.book_id
GROUP BY g.genre_id, g.genre_name
HAVING books_in_genre > 0
ORDER BY total_loans DESC;

-- ================================
-- 5. FINANCIAL ANALYSIS
-- ================================

-- Fine collection analysis
SELECT 
    DATE_FORMAT(f.issue_date, '%Y-%m') as month_year,
    COUNT(f.fine_id) as total_fines_issued,
    SUM(f.amount) as total_fine_amount,
    SUM(CASE WHEN f.status = 'Paid' THEN f.amount ELSE 0 END) as amount_collected,
    SUM(CASE WHEN f.status = 'Pending' THEN f.amount ELSE 0 END) as amount_pending,
    ROUND(SUM(CASE WHEN f.status = 'Paid' THEN f.amount ELSE 0 END) / SUM(f.amount) * 100, 2) as collection_rate
FROM fines f
GROUP BY DATE_FORMAT(f.issue_date, '%Y-%m')
ORDER BY month_year DESC;

-- Book acquisition cost analysis
SELECT 
    g.genre_name,
    COUNT(bc.copy_id) as total_copies,
    SUM(bc.cost) as total_acquisition_cost,
    AVG(bc.cost) as avg_cost_per_book,
    COUNT(l.loan_id) as total_loans,
    CASE 
        WHEN COUNT(l.loan_id) > 0 THEN ROUND(SUM(bc.cost) / COUNT(l.loan_id), 2)
        ELSE NULL 
    END as cost_per_loan
FROM genres g
INNER JOIN books b ON g.genre_id = b.genre_id
INNER JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY g.genre_id, g.genre_name
ORDER BY total_acquisition_cost DESC;

-- ================================
-- 6. OPERATIONAL REPORTS
-- ================================

-- Daily circulation report
SELECT 
    l.loan_date,
    lb.branch_name,
    COUNT(l.loan_id) as books_loaned,
    COUNT(CASE WHEN l.return_date = l.loan_date THEN 1 END) as books_returned_same_day,
    COUNT(DISTINCT l.member_id) as unique_borrowers,
    CONCAT(s.first_name, ' ', s.last_name) as staff_member
FROM loans l
INNER JOIN book_copies bc ON l.copy_id = bc.copy_id
INNER JOIN library_branches lb ON bc.branch_id = lb.branch

