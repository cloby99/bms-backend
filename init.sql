DROP SCHEMA IF EXISTS firstschema CASCADE;
CREATE SCHEMA firstschema;

CREATE TABLE IF NOT EXISTS bookstore (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),
    genre VARCHAR(255),
    language VARCHAR(255),
    availability BOOLEAN
);

INSERT INTO bookstore (title, author, genre, language, availability) VALUES
('To Kill a Mockingbird', 'Harper Lee', 'Southern Gothic', 'English', TRUE),
('1984', 'George Orwell', 'Dystopian', 'English', FALSE),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Tragedy', 'English', TRUE),
('War and Peace', 'Leo Tolstoy', 'Historical Fiction', 'Russian', TRUE),
('The Catcher in the Rye', 'J.D. Salinger', 'Realistic Fiction', 'English', FALSE);
