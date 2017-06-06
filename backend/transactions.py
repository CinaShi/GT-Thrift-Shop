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
@transactions.route('/transactions/get', methods=['POST'])
def get_transactions():

	if not request.json or not 'tranId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	tranId = request.json['tranId']

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

		buyerCur = db.cursor()
		buyerCur.execute("SELECT nickname FROM UserInfo WHERE userId = '%s';"%result[0])
		buyerName = buyerCur.fetchall()[0][0]
		temp["buyerName"] = buyerName

		sellerCur = db.cursor()
		sellerCur.execute("SELECT nickname FROM UserInfo WHERE userId = '%s';"%result[1])
		sellerName = sellerCur.fetchall()[0][0]
		temp["sellerName"] = sellerName

		db.close()
		return jsonify({'transaction':temp})
	else :
		db.close()
		abort(400,"Unknown tranId")


#author: Wen
@transactions.route('/transactions/getAll', methods=['POST'])
def get_all_transactions():
	transList = []
	returnList = []
	
	if not request.json or not 'userId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT Transaction.buyerId, Product.userId, Transaction.pid, Transaction.isRated, Transaction.time, Transaction.tranId FROM Transaction INNER JOIN Product WHERE Transaction.pid = Product.pid AND (Product.userId = %s OR Transaction.buyerId = %s);",[userId, userId]) 
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

			buyerCur = db.cursor()
			buyerCur.execute("SELECT nickname FROM UserInfo WHERE userId = '%s';"%trans[0])
			buyerName = buyerCur.fetchall()[0][0]
			temp["buyerName"] = buyerName

			sellerCur = db.cursor()
			sellerCur.execute("SELECT nickname FROM UserInfo WHERE userId = '%s';"%trans[1])
			sellerName = sellerCur.fetchall()[0][0]
			temp["sellerName"] = sellerName

			returnList.append(temp)
		db.close()
		return jsonify({'transactions':returnList})
	else :
		db.close()
		abort(400,"Unknown userId")