import mysql.connector
from mysql.connector import Error


def login(role, cursor):
    print('Enter username: ')
    username = input()
    print('Enter password: ')
    password = input()
    log_func = 'SELECT login(%s, %s, %s)'
    cursor.execute(log_func, (username, password, role))
    result = cursor.fetchall()
    if result[0][0] != 'LOGIN SUCCESSFUL!':
        login_ok = 0
    else:
        login_ok = 1

    print(result[0][0])
    return username, login_ok


def change_password(username, cursor):
    print('Enter new password: ')
    new_pass = input()
    args = [username, new_pass]
    # change_pass_func = 'SELECT changePassword(%s, %s)'
    # cursor.execute(change_pass_func, (username, new_pass))
    # result = cursor.fetchall()
    cursor.callproc('changePassword', args)
    for res in cursor.stored_results():
        results = res.fetchall()
    for r in results:
        print(r)
    connection.commit()


def display_courses(username, cursor):
    args = [username]
    cursor.callproc('viewCourses', args)
    for result in cursor.stored_results():
        courses = result.fetchall()
    for c in courses:
        print(c)


def logout(username, cursor):
    args = [username]
    cursor.callproc('logout', args)
    print('LOGOUT SUCCESSFUL!')
    connection.commit()
    login_ok = 0
    return login_ok


def listOfExams(cursor):
    print('Enter course id ')
    course_id = input()
    args = [course_id]
    cursor.callproc('viewExams', args)
    for result in cursor.stored_results():
        exams = result.fetchall()
    for ex in exams:
        print(ex)


def participateInExam(username, cursor):
    print('Enter course_id: ')
    course_id = input()
    print('Enter exam name: ')
    exam_name = input()
    args = [course_id, exam_name, username]
    cursor.callproc('participateInExam', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c[0])
    connection.commit()

    args2 = [course_id, exam_name]
    cursor.callproc('showQuestions', args2)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c[0])
        print('Enter your answer: ')
        ans = input()
        args3 = [course_id, exam_name, username, c[0], ans]
        cursor.callproc('answerExamQues', args3)
        for r in cursor.stored_results():
            rs = r.fetchall()
        for t in rs:
            print(t[0])
    connection.commit()


def listOfHws(cursor):
    print('Enter course id ')
    course_id = input()
    args = [course_id]
    cursor.callproc('viewHWs', args)
    for result in cursor.stored_results():
        hws = result.fetchall()
    for hw in hws:
        print(hw)


def upload_Hw(username, cursor):
    print('Enter course_id: ')
    course_id = input()
    print('Enter homework name: ')
    hw_name = input()
    args = [course_id, hw_name]
    cursor.callproc('showHwQuestions', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c[0])
        print('Enter your answer: ')
        ans = input()
        args3 = [course_id, hw_name, username, c[0], ans]
        cursor.callproc('answerHWQues', args3)
        for r in cursor.stored_results():
            rs = r.fetchall()
        for t in rs:
            print(t[0])
    connection.commit()


def show_menu_student(username, cursor, login_ok):
    while login_ok == 1:
        print('choose action: ')
        print(
            '1) change password 2) display courses 3) logout 4) list of exams 5) list of homework 6) participate in exam 7) upload homework')
        ac = int(input())
        if ac == 1:
            change_password(username, cursor)
        if ac == 2:
            display_courses(username, cursor)
        if ac == 3:
            login_ok = logout(username, cursor)
        if ac == 4:
            listOfExams(cursor)
        if ac == 5:
            listOfHws(cursor)
        if ac == 6:
            participateInExam(username, cursor)
        if ac == 7:
            upload_Hw(username, cursor)


def listOfStudents(cursor):
    print('Enter course id: ')
    course_id = input()
    args = [course_id]
    cursor.callproc('viewCourseStudents', args)
    for result in cursor.stored_results():
        students = result.fetchall()
    for c in students:
        print(c)


def defineExam(username, cursor):
    print('Enter course id: ')
    course_id = input()
    print('Enter exam name: ')
    exam_name = input()
    print('Enter start date: ')
    start_date = input()
    print('Enter end date: ')
    end_date = input()
    print('Enter duration: ')
    duration = input()
    args = [username, course_id, exam_name, start_date, end_date, duration]
    cursor.callproc('defineExam', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c[0])
    connection.commit()
    print('Enter number of questions: ')
    num = int(input())
    for i in range(num):
        print('Enter question description ')
        description = input()
        print('Enter choice 1')
        ch1 = input()
        print('Enter choice 2')
        ch2 = input()
        print('Enter choice 3')
        ch3 = input()
        print('Enter choice 4')
        ch4 = input()
        print('Enter correct choice')
        correct = input()
        args2 = [username, course_id, exam_name, description, ch1, ch2, ch3, ch4, correct]
        cursor.callproc('addQuestionToExam', args2)
        for result in cursor.stored_results():
            results = result.fetchall()
        for c in results:
            print(c[0])
        connection.commit()


def defineHW(username, cursor):
    print('Enter course id: ')
    course_id = input()
    print('Enter homework name: ')
    hw_name = input()
    print('Enter deadline: ')
    deadline = input()
    args = [username, course_id, hw_name, deadline]
    cursor.callproc('defineHW', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c[0])
    connection.commit()
    print('Enter number of questions: ')
    num = int(input())
    for i in range(num):
        print('Enter question description ')
        description = input()
        print('Enter correct answer ')
        answer = input()
        args2 = [username, course_id, hw_name, description, answer]
        cursor.callproc('addQuestionToHW', args2)
        for result in cursor.stored_results():
            results = result.fetchall()
        for c in results:
            print(c[0])
        connection.commit()


def displayExamAns(cursor):
    print('Enter course id: ')
    course_id = input()
    print('Enter exam name: ')
    exam_name = input()
    args = [course_id, exam_name]
    cursor.callproc('showStudentsExamAnswers', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c)
    connection.commit()


def displayHWAns(cursor):
    print('Enter course id: ')
    course_id = input()
    print('Enter homework name: ')
    hw_name = input()
    args = [course_id, hw_name]
    cursor.callproc('showStudentsHWAnswers', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c)
    connection.commit()


def gradeHW(cursor):
    print('Enter course id: ')
    course_id = input()
    print('Enter homework name: ')
    hw_name = input()
    args = [course_id, hw_name]
    cursor.callproc('gradingHomework', args)
    for result in cursor.stored_results():
        results = result.fetchall()
    for c in results:
        print(c)
    connection.commit()


def show_menu_professor(username, cursor, login_ok):
    while login_ok == 1:
        print('choose action: ')
        print(
            '1) change password 2) display courses 3) logout 4) list of students 5) list of exams 6) list of homework 7) define exam 8) define homework 9) display exam answers 10) display homework answers 11) grade homework')
        ac = int(input())
        if ac == 1:
            change_password(username, cursor)
        if ac == 2:
            display_courses(username, cursor)
        if ac == 3:
            login_ok = logout(username, cursor)
        if ac == 4:
            listOfStudents(cursor)
        if ac == 5:
            listOfExams(cursor)
        if ac == 6:
            listOfHws(cursor)
        if ac == 7:
            defineExam(username, cursor)
        if ac == 8:
            defineHW(username, cursor)
        if ac == 9:
            displayExamAns(cursor)
        if ac == 10:
            displayHWAns(cursor)
        if ac == 11:
            gradeHW(cursor)


try:
    connection = mysql.connector.connect(host='localhost',
                                         database='courses_system',
                                         user='root',
                                         password='1234')
    if connection.is_connected():
        print("Connected to MYSQL")
        cursor = connection.cursor()
        print("Welcome to Courses System. Please choose your role: student/professor")
        role = input()
        username, login_ok = login(role, cursor)
        connection.commit()
        while login_ok == 0:
            print("Login failed. enter again: student/professor")
            role = input()
            username, login_ok = login(role, cursor)
        if role == 'student':
            show_menu_student(username, cursor, login_ok)
        if role == 'professor':
            show_menu_professor(username, cursor, login_ok)

except mysql.connector.Error as error:
    print("Failed to execute stored procedure: {}".format(error))
