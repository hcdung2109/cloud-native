-- Tạo bảng users
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tạo index để tối ưu truy vấn
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Insert dữ liệu mẫu
INSERT INTO users (username, email, full_name, phone_number, active, created_at, updated_at) VALUES
('john_doe', 'john.doe@example.com', 'John Doe', '0123456789', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('jane_smith', 'jane.smith@example.com', 'Jane Smith', '0987654321', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('bob_wilson', 'bob.wilson@example.com', 'Bob Wilson', '0111222333', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('alice_brown', 'alice.brown@example.com', 'Alice Brown', '0444555666', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('charlie_davis', 'charlie.davis@example.com', 'Charlie Davis', NULL, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Xem dữ liệu đã insert
SELECT * FROM users;