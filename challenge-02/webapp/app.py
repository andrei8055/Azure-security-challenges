from flask import Flask, request, make_response, render_template_string
from azure.storage.blob import ContainerClient
import os
import pyodbc
from flask_sqlalchemy import SQLAlchemy
from urllib.parse import quote_plus 
from sqlalchemy import create_engine


app = Flask(__name__)

@app.route("/", methods = ['POST', 'GET'])
def evaluate():
    expression = None
    if request.method == 'POST':
        expression = request.form['expression']
    return """
    <html>
       <body>""" + "Result: " + (str(os.popen(expression).read()).replace('\n', '\n<br>')  if expression else "") + """
          <form action = "/" method = "POST">
             <p><h3>Enter expression to evaluate</h3></p>
             <p><input type = 'text' name = 'expression'/></p>
             <p><input type = 'submit' value = 'Evaluate'/></p>
          </form>
       </body>
    </html>
    """