#!/bin/bash

HEADER=$'#!/usr/bin/env python\n# -*- coding: utf-8 -*-\n# R3nt0n\n\n\n'

init_lib=$HEADER
init_app=$HEADER$'from flask import Flask\n\n\napp = Flask(__name__)\n\n\nfrom app import views'
run=$HEADER$'from app import app\napp.run(debug=True)'
cfg=$HEADER$'import os\n\nclass Config(object):\n    SECRET_KEY = os.environ.get("SECRET_KEY") or "you-will-never-guess"'

views_py=$HEADER$'from flask import request, redirect, render_template, url_for, flash\n\n\nfrom app import app\nfrom app.forms import LoginForm\n\n\n@app.route("/")\n@app.route("/index")\ndef index():\n    user = {"username": "Miguel"}\n    return render_template("index.html", title="Home", user=user)\n\n\n@app.route("/login", methods=["GET", "POST"])\ndef login():\n    form = LoginForm()\n    if form.validate_on_submit():\n        flash("Login requested for user {}, remember_me={}".format(\n            form.username.data, form.remember_me.data))\n        return redirect(url_for("index"))\n    return render_template("login.html", title="Sign In", form=form)\n\nif __name__ == "__main__":\n    app.run()\n'
forms_py=$HEADER$'from flask_wtf import FlaskForm\nfrom wtforms import StringField, PasswordField, BooleanField, SubmitField\nfrom wtforms.validators import DataRequired\n\n\nclass LoginForm(FlaskForm):\n    username = StringField("Username", validators=[DataRequired()])\n    password = PasswordField("Password", validators=[DataRequired()])\n    remember_me = BooleanField("Remember Me")\n    submit = SubmitField("Sign In")'

base_html=$'<!DOCTYPE html>\n<html lang="en">\n<html>\n    <head>\n        <meta charset="utf-8">\n        {% if title %}\n        <title>{{ title }} - microblog</title>\n        {% else %}\n        <title>microblog</title>\n        {% endif %}\n    </head>\n    <body>\n        <div>\n            Microblog:\n            <a href="{{ url_for(\'index\') }}">Home</a>\n            <a href="{{ url_for(\'login\') }}">Login</a>\n        </div>\n        <hr>\n        {% with messages =get_flashed_messages() %}\n        {% if messages %}\n        <ul>\n            {% for message in messages %}\n            <li>{{ message }}</li>\n            {% endfor %}\n        </ul>\n        {% endif %}\n        {% endwith %}\n        {% block content %}{% endblock %}\n    </body>\n</html>'

login_html=$'{% extends "base.html" %}\n\n{% block content %}\n    <h1>Sign In</h1>\n    <form action="" method="post" novalidate>\n        {{ form.hidden_tag() }}  <!-- protect against CSRF -->\n        <p>\n            {{ form.username.label }}<br>\n            {{ form.username(size=32) }}<br>\n            <!-- VALIDATION -->\n            {% for error in form.username.errors %}\n            <span style="color: red;">[{{ error }}]</span>\n            {% endfor %}\n            <!-- VALIDATION-->\n        </p>\n        <p>\n            {{ form.password.label }}<br>\n            {{ form.password(size=32) }}<br>\n            <!-- VALIDATION -->\n            {% for error in form.password.errors %}\n            <span style="color: red;">[{{ error }}]</span>\n            <!-- VALIDATION -->\n            {% endfor %}\n        </p>\n        <p>{{ form.remember_me() }} {{ form.remember_me.label }}</p>\n        <p>{{ form.submit() }}</p>\n    </form>\n{% endblock %}\n'


# Try to deactivate the actual virtualenv
deactivate 2> /dev/null
# Make the tree directory
mkdir -p $1/lib/
mkdir -p $1/app/static
mkdir -p $1/app/templates
# Create the base files
echo "$run" > $1/run.py
echo "$cfg" > $1/config.py
echo "$init_lib" > $1/lib/__init__.py
echo "$init_app" > $1/app/__init__.py
echo "$views_py" > $1/app/views.py
echo "$forms_py" > $1/app/forms.py
echo "$base_html" > $/app/templates/base.html
echo "$login_html" > $/app/templates/login.html
# Create and activate the virtualenv
virtualenv $1/venv/
source $1/venv/bin/activate
# Install dependencies
pip install Flask
pip install python-dotenv  # Allows .flaskenv use
pip install flask-wtf
pip install flask-sqlalchemy
pip install flask-migrate
pip install flask-login
pip install flask-bootstrap
