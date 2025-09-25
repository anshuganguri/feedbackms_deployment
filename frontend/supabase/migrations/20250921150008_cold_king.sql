-- Feedback Management System Database Schema

-- Create database
CREATE DATABASE IF NOT EXISTS feedback_db;
USE feedback_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('CUSTOMER', 'ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Feedback table
CREATE TABLE IF NOT EXISTS feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    service_or_product VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_feedback_user_id ON feedback(user_id);
CREATE INDEX idx_feedback_rating ON feedback(rating);
CREATE INDEX idx_feedback_service ON feedback(service_or_product);
CREATE INDEX idx_feedback_timestamp ON feedback(timestamp);

-- Insert sample admin user
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@feedback.com', '$2a$10$dXJ3SW6G7P0lHgiheyoHxbVy7sIBMODtVg5Fhb8qO1OZXL0zJ8kGC', 'ADMIN');

-- Insert sample customer users
INSERT INTO users (name, email, password, role) VALUES 
('John Doe', 'john@example.com', '$2a$10$dXJ3SW6G7P0lHgiheyoHxbVy7sIBMODtVg5Fhb8qO1OZXL0zJ8kGC', 'CUSTOMER'),
('Jane Smith', 'jane@example.com', '$2a$10$dXJ3SW6G7P0lHgiheyoHxbVy7sIBMODtVg5Fhb8qO1OZXL0zJ8kGC', 'CUSTOMER');

-- Insert sample feedback data
INSERT INTO feedback (user_id, rating, comment, service_or_product) VALUES 
(2, 5, 'Excellent service! Food arrived hot and on time.', 'Swiggy'),
(2, 4, 'Good banking experience, but could improve customer service.', 'SBI'),
(3, 3, 'Average experience. Delivery was delayed.', 'Zomato'),
(3, 5, 'Outstanding service and user-friendly interface.', 'Amazon'),
(2, 2, 'Poor experience. Food was cold when delivered.', 'Zomato'),
(3, 4, 'Good service overall. Quick loan approval process.', 'ICICI');