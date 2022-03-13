from flask import Flask, request, make_response, render_template_string
from azure.storage.blob import ContainerClient
import os
import pyodbc
from flask_sqlalchemy import SQLAlchemy
from urllib.parse import quote_plus 
from sqlalchemy import create_engine
from urllib.parse import urlparse
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobClient, BlobServiceClient

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
    account_url = "https://0xpwnstorageacc.blob.core.windows.net"
    container_name = "images"

    creds = DefaultAzureCredential()

    blob_service_client = BlobServiceClient(account_url=account_url, credential=creds)
    container_client = blob_service_client.get_container_client(container_name)
    blobs_list = container_client.list_blobs()
    output = ""
    for blob in blobs_list:
      output = output + blob.name + '\n'
    return output