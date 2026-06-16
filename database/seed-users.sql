-- =============================================================
-- FleetOps User Seed Data
-- Run against: auth_db
-- Users match README.md demo credentials exactly
-- Passwords are BCrypt-hashed (cost factor 10)
-- =============================================================
-- Schema creation is handled by Flyway migrations (V1__init_auth_schema.sql)

INSERT INTO users (username, email, password_hash, role, created_at) VALUES

-- Admin
-- Password: Admin@123
('admin1',   'admin1@fleetops.com',   '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KbB3i', 'ADMIN',   NOW()),

-- Managers
-- Password: Manager@123
('manager1', 'manager1@fleetops.com', '$2a$10$TwBCnKB2QkpP0VmpICRKNOaIWdI9X5YK3T3S7iT2CqCkrME0mJ7Cy', 'MANAGER', NOW()),

-- Drivers (13 drivers to match vehicle seed assignments)
-- Password: Driver@123
('driver1',  'driver1@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver2',  'driver2@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver3',  'driver3@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver4',  'driver4@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver5',  'driver5@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver6',  'driver6@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver7',  'driver7@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver8',  'driver8@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver9',  'driver9@fleetops.com',  '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver10', 'driver10@fleetops.com', '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver11', 'driver11@fleetops.com', '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver12', 'driver12@fleetops.com', '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW()),
('driver13', 'driver13@fleetops.com', '$2a$10$e9cIqFkJpRTsf1KoULLk4O4eXz0dFJULxU3VvY2Wg4D0JU9Z1Qb3m', 'DRIVER',  NOW());
