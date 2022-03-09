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

@app.route('/files', methods = ['POST', 'GET'])
def files():
    container = ContainerClient.from_connection_string(conn_str="AZURE_CTF_CONNECTION_STRING", container_name="AZURE_CTF_CONTAINER_NAME")
    blob_list = container.list_blobs()
    blobs = ""
    for blob in blob_list:
        blobs += blob.name + '</br>'
    return """
    <html>
       <body>""" + "Files in storage container:</br>" + (str(blobs)) + """
       </body>
    </html>
    """