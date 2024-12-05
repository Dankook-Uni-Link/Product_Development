CREATE TABLE IF NOT EXISTS survey (
    id INT AUTO_INCREMENT PRIMARY KEY,
    survey_title VARCHAR(255),
    survey_description TEXT,
    total_questions INT,
    reward VARCHAR(50),
    target_number INT,
    winning_number INT,
    price VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    survey_id INT,
    question TEXT,
    question_type VARCHAR(50),
    FOREIGN KEY (survey_id) REFERENCES survey(id)
);

CREATE TABLE IF NOT EXISTS options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT,
    option_text VARCHAR(255),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);
