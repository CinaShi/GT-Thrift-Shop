from flask import Flask, jsonify, request, abort, Blueprint
from flask.ext.mysql import MySQL
import json, codecs
import boto3
from werkzeug.utils import secure_filename
import datetime

config = json.load(codecs.open('config.json', encoding='utf-8'))
app = Flask(__name__)
mysql = MySQL()
client = boto3.client('s3')

app.config['MYSQL_DATABASE_USER'] = config['db_user']
app.config['MYSQL_DATABASE_PASSWORD'] = config['db_passwd']
app.config['MYSQL_DATABASE_DB'] = config['db_db']
app.config['MYSQL_DATABASE_HOST'] = config['db_host']
mysql.init_app(app)

transactions = Blueprint('transactions', __name__)


#author: Wen
@transactions.route('/transactions/get/<tranId>', methods=['GET'])
def get_transactions(tranId):
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT Transaction.buyerId, Product.userId, Transaction.pid, Transaction.time, Transaction.isRated FROM Transaction INNER JOIN Product WHERE Transaction.pid = Product.pid AND Transaction.tranId = '%s';"%tranId) 
	if cursor.rowcount == 1:
		result = cursor.fetchall()[0]
		temp = {}
		temp["buyerID"] = result[0]
		temp["sellerID"] = result[1]
		temp["pid"] = result[2]
		temp["postTime"] = result[3]
		temp["isRated"] = result[4]
		db.close()
		return jsonify({'transaction':temp})
	else :
		db.close()
		abort(400,"Unknown tranId")


#author: Wen
@transactions.route('/transactions/getAll/<uid>', methods=['GET'])
def get_all_transactions(uid):
	transList = []
	returnList = []
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT Transaction.buyerId, Product.userId, Transaction.pid, Transaction.isRated, Transaction.time, Transaction.tranId FROM Transaction INNER JOIN Product WHERE Transaction.pid = Product.pid AND (Product.userId = %s OR Transaction.buyerId = %s);",[uid, uid]) 
	if cursor.rowcount > 0:
		transList = cursor.fetchall()
		for trans in transList:
			temp = {}
			temp["buyerID"] = trans[0]
			temp["sellerID"] = trans[1]
			temp["pid"] = trans[2]
			temp["isRated"] = trans[3]
			temp["postTime"] = trans[4]
			temp["tranId"] = trans[5]
			returnList.append(temp)
		db.close()
		return jsonify({'transactions':returnList})
	else :
		db.close()
		abort(400,"Unknown userId")