CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS disciplines (
    id SERIAL PRIMARY KEY,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    semester INT NOT NULL CHECK (semester BETWEEN 1 AND 8),
    department_id INT REFERENCES departments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    student_card VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS student_courses (
    id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(id) ON DELETE CASCADE,
    discipline_id INT REFERENCES disciplines(id) ON DELETE CASCADE
);

-- Тестові дані (Кафедри)
INSERT INTO departments (name, code) VALUES
('Кафедра безпеки інформаційних технологій', 'БІТ'),
('Кафедра програмного забезпечення', 'ПЗ'),
('Кафедра штучного інтелекту', 'ШІ'),
('Кафедра теоретичної та прикладної математики', 'ТПМ'),
('Кафедра інформаційних систем та мереж', 'ІСМ');

-- Генерація 50 записів дисциплін
INSERT INTO disciplines (course_code, title, credits, semester, department_id)
SELECT
    CASE (i % 5)
        WHEN 0 THEN 'SEC-' || (100 + i)
        WHEN 1 THEN 'SWE-' || (100 + i)
        WHEN 2 THEN 'AI-' || (100 + i)
        WHEN 3 THEN 'MATH-' || (100 + i)
        ELSE 'NET-' || (100 + i)
    END,
    'Навчальна дисципліна №' || i,
    ((i % 4) + 3),
    ((i % 8) + 1),
    ((i % 5) + 1)
FROM generate_series(1, 50) AS i;