create database Courses_system;
create table students (
    national_code char(10) primary key ,
    student_no char(10) unique,
    name_en varchar(20),
    name_fa varchar(20),
    father_name varchar(20),
    birth_date varchar(20),
    mobile varchar(20),
    major varchar(10)
    );
# Query
create view students_pass_email(national_code, student_no, name_en, name_fa, father_name, birth_date, mobile, major, password, email) as(
select national_code, student_no, name_en, name_fa, father_name, birth_date, mobile, major, MD5(concat(national_code, UPPER(SUBSTR(SUBSTRING_INDEX(name_en,'-', 1), 1, 1)), LOWER(SUBSTR(SUBSTRING_INDEX(name_en,'-', -1), 2, 1)))) as password, concat(SUBSTR(SUBSTRING_INDEX(name_en,'-', 1), 1, 1), '.', SUBSTRING_INDEX(name_en,'-', -1), '@aut.ac.ir') as email
from students
);

create table faculty(
    national_code char(10) primary key ,
    professor_no char(5) unique,
    name_en varchar(20),
    name_fa varchar(20),
    father_name varchar(20),
    birth_date varchar(20),
    mobile varchar(20),
    department varchar(10),
    title varchar(20)
);

# query
create view faculty_pass_emails as (
select national_code, professor_no, name_en, name_fa, father_name, birth_date, mobile, department, title, MD5(concat(national_code, UPPER(SUBSTR(SUBSTRING_INDEX(name_en,'-', 1), 1, 1)), LOWER(SUBSTR(SUBSTRING_INDEX(name_en,'-', -1), 2, 1)))) as password, concat(SUBSTR(SUBSTRING_INDEX(name_en,'-', 1), 1, 1), '.', SUBSTRING_INDEX(name_en,'-', -1), '@aut.ac.ir') as email
from faculty
);

create table courses(
    course_id char(8) primary key ,
    course_name varchar(20),
    professor_no char(5) references faculty
);

create table classrooms(
    student_no char(10) references students,
    course_id char(8) references courses,
    primary key (student_no, course_id)
);

create table successful_logins(
    username varchar(20) primary key ,
    password varchar(40),
    national_code varchar(20) unique ,
    login_date date,
    isStudent bool
);
create table exam(
    course_id char(8) references courses,
    exam_name varchar(20),
    start_date datetime,
    end_date datetime,
    duration INTEGER,
    primary key (course_id, exam_name)
);

create table exam_question(
    exam_name varchar(20) references exam,
    course_id char(8) references exam,
    question_description varchar(20),
    choice1 varchar(20),
    choice2 varchar(20),
    choice3 varchar(20),
    choice4 varchar(20),
    correct_choice varchar(20),
    primary key (course_id, exam_name, question_description)
);
create table homework(
    hw_name varchar(20),
    course_id char(10) references courses,
    deadline DATE,
    primary key (hw_name, course_id)
);
create table hw_question(
    hw_name varchar(20),
    course_id char(10) references homework,
    description varchar(20),
    correct_answer varchar(20),
    primary key (hw_name, course_id, description)
);
create table exam_participants(
    course_id char(8),
    exam_name varchar(20),
    student_no char(10),
    primary key (course_id, exam_name, student_no)
);
create table exam_stud_answers(
    course_id char(8),
    exam_name varchar(20),
    student_no char(10),
    question_description varchar(20),
    answer varchar(20),
    score integer default 0,
    primary key (course_id, exam_name, student_no, question_description)
);
create table scores(
    exam_name varchar(20) references exam,
    course_id char(8) references exam,
    student_no char(10),
    score INTEGER,
    primary key (course_id, exam_name, student_no)
);
create table hw_stud_answers(
    hw_name varchar(20),
    course_id char(10) references homework,
    student_no char(10) references students,
    description varchar(20),
    answer varchar(20),
    upload_date datetime,
    score integer default 0,
    primary key (hw_name, course_id, student_no, description)
);
create table hw_grades(
    hw_name varchar(20),
    course_id char(10) references homework,
    student_no char(10) references students,
    grade integer,
    primary key (hw_name, course_id, student_no)
);
create function login(input_username varchar(20), input_password varchar(20), in_isStudent varchar(20))
returns varchar(20)
BEGIN
    DECLARE hashed_pass varchar(40);
    DECLARE  nat_code char(10) DEFAULT NULL;
    DECLARE input_isStudent bool;
    SET hashed_pass = MD5(input_password);
    IF(in_isStudent = 'student') THEN
        set input_isStudent = TRUE;
    end if;
    IF(in_isStudent = 'professor') THEN
        set input_isStudent = FALSE;
    end if;
    IF(input_isStudent) THEN
        IF input_username not in (
            select student_no
            from students
            where student_no=input_username
            ) THEN
            return 'USER NOT FOUND!';
        end if;
        select national_code
        into nat_code
        from students_pass_email
        where students_pass_email.student_no = input_username and students_pass_email.password = hashed_pass;
        end if;

    IF(!input_isStudent) THEN
        IF input_username not in (
            select professor_no
            from faculty
            where professor_no=input_username
            ) THEN
                return 'USER NOT FOUND!';
        end if;
        select national_code
        into nat_code
        from faculty_pass_emails
        where faculty_pass_emails.professor_no=input_username and faculty_pass_emails.password = hashed_pass;
    end if;
    IF(nat_code IS NULL) THEN
            return 'INCORRECT PASSWORD!';
    end if;
    insert into successful_logins values (input_username, input_password, nat_code, curdate(), input_isStudent);
    return 'LOGIN SUCCESSFUL!';
end;
create procedure logout(user_name varchar(20))
    BEGIN
        delete from successful_logins
        where successful_logins.username = user_name;
    end;
create procedure changePassword(input_username varchar(20), input_newPassword varchar(40))
BEGIN
    DECLARE nat_code char(10);
    DECLARE is_student bool;
    DECLARE hashed_pass varchar(40);
    SET hashed_pass = MD5(input_newPassword);
    IF(length(input_newPassword) < 8) THEN
        select 'PASSWORD IS TOO SHORT';
    end if;
    IF(length(input_newPassword) > 20) THEN
        select 'PASSWORD IS TOO LONG';
    end if;
    IF(!(input_newPassword REGEXP '[0-9]') or !(input_newPassword REGEXP '[A-Z]')) THEN
        select 'PASSWORD IS WEEK';
    end if;
    select national_code, isStudent
    into nat_code, is_student
    from successful_logins
    where successful_logins.username = input_username;
    IF(nat_code is NULL) THEN
        select 'THE USER HAS NOT LOGGED IN!';
    end if;
    IF(is_student) THEN
        update students_pass_email
            set students_pass_email.password = hashed_pass
            where students_pass_email.national_code = nat_code;
    end if;
    IF(!is_student) THEN
        update faculty_pass_emails
            set faculty_pass_emails.password = hashed_pass
            where faculty_pass_emails.national_code = nat_code;
    end if;
    select 'PASSWORD CHANGED SUCCESSFULLY!';
end;

create PROCEDURE viewCourses(input_username varchar(20))
BEGIN
    DECLARE nat_code char(10);
    DECLARE is_student bool;
    DECLARE stu_no char(10);
    DECLARE  prof_no char(5);
    select national_code, isStudent
    into nat_code, is_student
    from successful_logins
    where username = input_username;
    IF(is_student) THEN
        select student_no
        into stu_no
        from students
        where students.national_code=nat_code;
        select course_id
        from classrooms
        where classrooms.student_no=stu_no;
    end if;
    IF(!is_student) THEN
        select professor_no
        into prof_no
        from faculty
        where faculty.national_code=nat_code;
        select course_id
        from courses
        where courses.professor_no=prof_no;
    end if;
end;
create procedure viewCourseStudents(courseID char(10))
    BEGIN
        select student_no
        from classrooms
        where classrooms.course_id = courseID;
    end;
create procedure defineExam(username char(10), courseID char(8), examName varchar(20), startDate datetime, endDate datetime, exam_duration integer)
BEGIN
    IF(courseID not in (select course_id
        from courses
        where courses.professor_no = username)) THEN
        select 'Incorrect course_id!';
    end if;
    IF (courseID in (select course_id
        from courses
        where courses.professor_no = username)
        ) THEN
        insert into exam values (courseID, examName, startDate, endDate, exam_duration);
        select 'exam defined';
    end if;
end;
create procedure addQuestionToExam(username char(10), courseID char(8), examName varchar(20), quesDes varchar(20), ch1 varchar(20), ch2 varchar(20), ch3 varchar(20), ch4 varchar(20), correct varchar(20))
BEGIN
    IF(courseID not in (select course_id
        from courses
        where courses.professor_no = username)) THEN
        select 'Incorrect course_id!';
    end if;
    IF(courseID in (
        select course_id
        from courses
        where courses.professor_no = username
        )) THEN
        insert into exam_question values (examName, courseID, quesDes, ch1, ch2, ch3, ch4, correct);
        select 'Question added to exam';
    end if;
end;

create procedure defineHW(username char(10), courseID char(10), hwName varchar(20), hw_deadline datetime)
BEGIN
    IF(courseID not in (select course_id
        from courses
        where courses.professor_no = username)) THEN
        select 'Incorrect course_id!';
    end if;
    IF(courseID in (
        select course_id
        from courses
        where courses.professor_no = username
        ))THEN
        insert into homework values (hwName, courseID, hw_deadline);
        select 'Homework defined';
    end if;
end;
create procedure addQuestionToHW(username char(10), courseID char(10), hwName varchar(20), ques_des varchar(20), ques_ans varchar(20))
BEGIN
    IF(courseID not in (select course_id
        from courses
        where courses.professor_no = username)) THEN
        select 'Incorrect course_id!';
    end if;
    IF(courseID in (select course_id
        from courses
        where courses.professor_no = username
        ))THEN
        insert into hw_question values (hwName, courseID, ques_des, ques_ans);
        select 'Question added to homework';
    end if;
end;
create PROCEDURE viewExams(courseID char(10))
BEGIN
    select exam_name, start_date, end_date, duration
        from exam
            where course_id=courseID;
end;
create PROCEDURE viewHWs(courseID char(10))
BEGIN
    select hw_name, course_id, deadline
        from homework
            where course_id=courseID;
end;
create procedure participateInExam(courseID char(8), examName varchar(20), stu_no char(10))
BEGIN
    DECLARE endDate datetime default null;
    DECLARE startDate datetime default null;
    IF courseID not in (
        select course_id
        from classrooms
        where classrooms.student_no=stu_no
        ) THEN
        select 'This student does not have this course!';
    end if;
    select start_date, end_date
        into startDate, endDate
        from exam
        where exam_name=examName;
    IF endDate is NULL THEN
        select 'Exam not found!';
    end if;
    IF endDate < curdate() THEN
        select 'Exam is over!';
    end if;
    IF startDate > curdate() THEN
        select 'Exam has not started yet!';
    end if;
    IF stu_no in (
        select student_no
        from exam_participants
        where exam_participants.course_id = courseID and exam_participants.exam_name = examName
        ) THEN
        select 'The student has already entered the exam';
    end if;

    insert into exam_participants values (courseID, examName, stu_no);
    select 'exam started:';

end;
create procedure showQuestions(courseID char(8), examName varchar(20))
BEGIN
    select question_description
        from exam_question
            where exam_question.course_id = courseID and exam_question.exam_name = examName;
end;
create procedure answerExamQues(courseID char(8), examName varchar(20), stu_no char(10), quesDes varchar(20), quesAns varchar(20))
BEGIN
    DECLARE endDate datetime default null;
    select end_date
    into endDate
    from exam
    where exam_name=examName;
    IF endDate is NULL THEN
        select 'Exam not found!';
    end if;
    IF endDate < curdate() THEN
        select 'Exam is over!';
    end if;
    insert into exam_stud_answers values (courseID, examName, stu_no, quesDes, quesAns, 0);
    select 'answer submitted for this question';
end;
create procedure showHwQuestions(courseID char(8), hwName varchar(20))
BEGIN
    select description
        from hw_question
            where hw_question.course_id = courseID and hw_question.hw_name= hwName;
end;
create procedure answerHWQues(courseID char(10), hwName varchar(20), stu_no char(10), hwDes varchar(20), stu_ans varchar(20))
BEGIN
    DECLARE hw_deadline datetime;
    select deadline
    into hw_deadline
    from homework
    where homework.hw_name = hwName and homework.course_id = courseID;
    IF(hw_deadline < curdate()) THEN
        select 'Homework deadline is over!';
    end if;
    IF(hw_deadline > curdate()) and (stu_no, hwDes) in (
        select student_no, description
        from hw_stud_answers
        where student_no = stu_no and description = hwDes and course_id = courseID and hw_name = hwName
    ) THEN
        update hw_stud_answers
        set answer = stu_ans and upload_date=curdate()
        where student_no = stu_no and description = hwDes and course_id = courseID and hw_name = hwName;
        select 'answer updated!';
    end if;
    IF(hw_deadline > curdate()) and (stu_no, hwDes) not in(
        select student_no, description
        from hw_stud_answers
        where student_no = stu_no and description = hwDes and course_id = courseID and hw_name = hwName
        ) THEN
        insert into hw_stud_answers values (hwName, courseID, stu_no, hwDes, stu_ans, curdate(), 0);
        select 'answer submitted!';
    end if;
end;
create procedure showStudentsExamAnswers(courseId char(10), examName varchar(20))
BEGIN
    select student_no, question_description, answer
        from exam_stud_answers
            where course_id = courseId and exam_name = examName;
end;
create procedure showStudentsHWAnswers(courseID char(10), hwName varchar(20))
BEGIN
    select student_no, description, answer
        from hw_stud_answers
            where course_id = courseID and hw_name = hwName;
end;

create procedure gradingHomework(courseID char(10), hwName varchar(20))
BEGIN
    DECLARE hw_deadline datetime;
    select deadline
    into hw_deadline
    from homework
    where homework.course_id = courseID and homework.hw_name = hwName;
    IF(hw_deadline > curdate()) THEN
        select 'ُThe homework deadline has not yet ended!';
    end if;
    IF(hw_deadline < curdate()) THEN
        create view joined as (
        select hsa.hw_name, hsa.course_id, student_no, hsa.description, correct_answer, answer, score
        from hw_question join hw_stud_answers hsa on hw_question.description = hsa.description
        where hw_question.course_id = courseID and hsa.course_id = courseID and hw_question.hw_name=hwName and hsa.hw_name=hwName
                          );
        update joined
            set score = case when joined.correct_answer = joined.answer then 1
                end;
        select student_no, sum(score) as grade
        from joined
        group by student_no;
    end if;
end;
create trigger exam_scoring after update on exam
    for each row
    BEGIN
        IF(end_date = curdate()) THEN
            create view this_exam_questions as (
                select exam_name, course_id, question_description, correct_choice
                from exam_question
                where exam_question.course_id = new.course_id and exam_question.exam_name = new.exam_name
                                               );
            create view joined as(
                select exam_name, course_id, student_no, question_description, correct_choice, answer, score
                from exam_stud_answers ,this_exam_questions
                where exam_stud_answers.course_id = this_exam_questions.course_id and exam_stud_answers.exam_name = this_exam_questions.exam_name
                and exam_stud_answers.question_description=this_exam_questions.question_description
                                 );
                update joined
                    set score = case when correct_choice = answer then 1
                        end;
        end if;
    end;
