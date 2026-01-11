-- 数据库表结构设计
-- 版本: 1.0.0
-- 描述: BiGuo应用数据库表结构
CREATE DATABASE IF NOT EXISTS biguo CHARACTER SET utf8mb4;
USE biguo;
-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码（注意：实际应用中应使用加密存储，如bcrypt）',
    nickname VARCHAR(50) COMMENT '昵称',
    email VARCHAR(100) COMMENT '邮箱',
    avatar VARCHAR(255) COMMENT '头像URL',
    role VARCHAR(20) DEFAULT 'user' COMMENT '角色（user/admin）',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态（active/inactive）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='用户表';

-- 创建内容库表
CREATE TABLE IF NOT EXISTS quiz_banks (
    id VARCHAR(36) PRIMARY KEY COMMENT '内容库ID',
    user_id VARCHAR(36) COMMENT '用户ID',
    name VARCHAR(100) NOT NULL COMMENT '内容库名称',
    description TEXT COMMENT '内容库描述',
    question_count INT DEFAULT 0 COMMENT '题目数量',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态（active/inactive）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT='内容库表';

-- 创建题目表
CREATE TABLE IF NOT EXISTS questions (
    id VARCHAR(36) PRIMARY KEY COMMENT '题目ID',
    bank_id VARCHAR(36) COMMENT '内容库ID',
    user_id VARCHAR(36) COMMENT '用户ID',
    content TEXT NOT NULL COMMENT '题目内容',
    type VARCHAR(20) NOT NULL COMMENT '题目类型（multiple_choice, true_false, fill_in_blank, short_answer）',
    difficulty VARCHAR(20) NOT NULL COMMENT '难度级别（easy, medium, hard）',
    explanation TEXT COMMENT '题目解析',
    reference_answer TEXT COMMENT '参考答案（用于简答题）',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (bank_id) REFERENCES quiz_banks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT='题目表';

-- 创建题目选项表
CREATE TABLE IF NOT EXISTS question_options (
    id VARCHAR(36) PRIMARY KEY COMMENT '选项ID',
    question_id VARCHAR(36) COMMENT '题目ID',
    content TEXT NOT NULL COMMENT '选项内容',
    is_correct BOOLEAN DEFAULT FALSE COMMENT '是否正确选项',
    option_order INT NOT NULL COMMENT '选项顺序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) COMMENT='题目选项表';

-- 创建用户答题记录表
CREATE TABLE IF NOT EXISTS user_answers (
    id VARCHAR(36) PRIMARY KEY COMMENT '答题记录ID',
    user_id VARCHAR(36) COMMENT '用户ID',
    question_id VARCHAR(36) COMMENT '题目ID',
    bank_id VARCHAR(36) COMMENT '内容库ID',
    user_answer TEXT NOT NULL COMMENT '用户答案',
    is_correct BOOLEAN DEFAULT FALSE COMMENT '是否正确',
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '答题时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (bank_id) REFERENCES quiz_banks(id) ON DELETE CASCADE
) COMMENT='用户答题记录表';

-- 创建用户收藏题目表
CREATE TABLE IF NOT EXISTS user_collections (
    id VARCHAR(36) PRIMARY KEY COMMENT '收藏记录ID',
    user_id VARCHAR(36) COMMENT '用户ID',
    question_id VARCHAR(36) COMMENT '题目ID',
    collection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, question_id)
) COMMENT='用户收藏题目表';

-- 创建学习记录表
CREATE TABLE IF NOT EXISTS study_records (
    id VARCHAR(36) PRIMARY KEY COMMENT '学习记录ID',
    user_id VARCHAR(36) COMMENT '用户ID',
    bank_id VARCHAR(36) COMMENT '内容库ID',
    study_date DATE DEFAULT CURRENT_DATE COMMENT '学习日期',
    study_duration INT DEFAULT 0 COMMENT '学习时长（分钟）',
    question_count INT DEFAULT 0 COMMENT '答题数量',
    correct_count INT DEFAULT 0 COMMENT '正确数量',
    accuracy DECIMAL(5,2) DEFAULT 0 COMMENT '正确率',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (bank_id) REFERENCES quiz_banks(id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, bank_id, study_date)
) COMMENT='学习记录表';

-- 创建AI解析表
CREATE TABLE IF NOT EXISTS ai_analyses (
    id VARCHAR(36) PRIMARY KEY COMMENT '解析ID',
    question_id VARCHAR(36) COMMENT '题目ID',
    user_id VARCHAR(36) COMMENT '用户ID',
    analysis_content TEXT NOT NULL COMMENT '解析内容',
    prompt TEXT COMMENT '提示词',
    is_saved BOOLEAN DEFAULT FALSE COMMENT '是否保存',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT='AI解析表';

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_quiz_banks_user_id ON quiz_banks(user_id);
CREATE INDEX IF NOT EXISTS idx_questions_bank_id ON questions(bank_id);
CREATE INDEX IF NOT EXISTS idx_questions_user_id ON questions(user_id);
CREATE INDEX IF NOT EXISTS idx_question_options_question_id ON question_options(question_id);
CREATE INDEX IF NOT EXISTS idx_user_answers_user_id ON user_answers(user_id);
CREATE INDEX IF NOT EXISTS idx_user_answers_question_id ON user_answers(question_id);
CREATE INDEX IF NOT EXISTS idx_user_collections_user_id ON user_collections(user_id);
CREATE INDEX IF NOT EXISTS idx_study_records_user_id ON study_records(user_id);
CREATE INDEX IF NOT EXISTS idx_study_records_bank_id ON study_records(bank_id);
CREATE INDEX IF NOT EXISTS idx_ai_analyses_question_id ON ai_analyses(question_id);
CREATE INDEX IF NOT EXISTS idx_ai_analyses_user_id ON ai_analyses(user_id);

-- 插入测试数据
INSERT INTO users (id, username, password, nickname, email) VALUES
('1', 'test', '123456', '测试用户', 'test@example.com');

INSERT INTO quiz_banks (id, user_id, name, description) VALUES
('1', '1', 'Flutter基础', 'Flutter开发基础知识点');

-- 插入测试题目
INSERT INTO questions (id, bank_id, user_id, content, type, difficulty) VALUES
('1', '1', '1', '以下哪个是Flutter的特点？', 'multiple_choice', 'medium'),
('2', '1', '1', 'Dart是Flutter使用的编程语言。', 'true_false', 'easy');

-- 插入题目选项
INSERT INTO question_options (id, question_id, content, is_correct, option_order) VALUES
('1', '1', '跨平台开发', true, 1),
('2', '1', '仅支持iOS', false, 2),
('3', '1', '仅支持Android', false, 3),
('4', '1', '需要原生代码开发', false, 4);

-- 更新内容库题目数量
UPDATE quiz_banks SET question_count = (SELECT COUNT(*) FROM questions WHERE bank_id = '1') WHERE id = '1';
