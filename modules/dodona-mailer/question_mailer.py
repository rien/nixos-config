#!/usr/bin/env python3

# Script to fetch unanswered questions from Dodona and send an email.
# This script is meant to be run periodically.
# It will keep track of the questions it has already seen in a file called "mails_seen.json".

import os
import sys
import email
import datetime
import json
import requests

CONFIG_FILE = "~/.config/dodona-mailer/config.json"
CONFIG = json.load(open(os.path.expanduser(CONFIG_FILE)))

FROM_EMAIL = CONFIG["from"]
TO_EMAIL = CONFIG["to"]
DODONA_API_KEY = CONFIG["dodona_api_key"]
MAILDIR = CONFIG["maildir"]

DODONA_HEADERS = {'Authorization': DODONA_API_KEY}
QUESTION_CONTEXT = 3


def fetch_questions():
    r = requests.get(f"https://dodona.ugent.be/questions.json?question_state=unanswered", headers=DODONA_HEADERS)
    return r.json()


def fetch_submission(submission_id):
    submission = requests.get(f"https://dodona.ugent.be/submissions/{submission_id}.json", headers=DODONA_HEADERS).json()
    submission['exercise'] = requests.get(submission['exercise'], headers=DODONA_HEADERS).json()
    return submission


def render_mail(question):
    submission_id = question["submission_id"]
    # parse date with datetime
    question_time = datetime.datetime.fromisoformat(question["created_at"])
    submission = fetch_submission(submission_id)
    exercise_name = submission["exercise"]["name"]
    course_id = question["course_id"]
    text = question["annotation_text"]
    line_nr = question["line_nr"]
    if line_nr:
        line_nr = int(line_nr)
        lines = [(i + 1, l) for (i , l) in enumerate(submission["code"].splitlines())]

        context = "Vraag op regel " + str(line_nr + 1) + ":\n"
        # before
        for (num, line) in lines[line_nr - QUESTION_CONTEXT:line_nr]:
            context += f"{num:3d} | {line}\n"
        context += f"{line_nr + 1:3d} | {lines[line_nr][1]}\n"
        # after
        for (num, line) in lines[line_nr + 1:line_nr + QUESTION_CONTEXT + 1]:
            context += f"{num:3d} | {line}\n"

        body = context + "\n" + text
    else:
        body = text

    author = question["user"]["name"]
    course_questions_url = f"https://dodona.ugent.be/course/{course_id}/questions"
    question_url = f"https://dodona.ugent.be/submissions/{submission_id}"
    return f"""\
From: {author} <{FROM_EMAIL}>
To: {TO_EMAIL}
Date: {email.utils.format_datetime(question_time)}
Subject: Vraag over {exercise_name}

{body}

Naar deze oplossing: {question_url}
Alle vragen: {course_questions_url}     
    """


def main(argv: [str]):
    questions = fetch_questions()
    for question in questions:
        question_file = os.path.join(MAILDIR, str(question["id"]))
        if not os.path.exists(question_file):
            with open(question_file, "w") as f:
                mail = render_mail(question)
                print("------------------------------------------------------------------")
                print(mail)
                f.write(mail)
                print("------------------------------------------------------------------")


if __name__ == '__main__':
    main(sys.argv)
