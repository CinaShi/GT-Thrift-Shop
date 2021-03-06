from flask import Flask, jsonify, request, abort, Blueprint
from flaskext.mysql import MySQL
import json, codecs
import boto3
from werkzeug.utils import secure_filename
import datetime
import utils

config = json.load(codecs.open('config.json', encoding='utf-8'))
app = Flask(__name__)
mysql = MySQL()
client = boto3.client('s3')

app.config['MYSQL_DATABASE_USER'] = config['db_user']
app.config['MYSQL_DATABASE_PASSWORD'] = config['db_passwd']
app.config['MYSQL_DATABASE_DB'] = config['db_db']
app.config['MYSQL_DATABASE_HOST'] = config['db_host']
mysql.init_app(app)

favorites = Blueprint('favorites', __name__)


# author: Yichen, Wen
# authentication
@favorites.route('/favorites/all', methods=['POST'])
def get_favorites_pid():
	if not request.json or not 'userId' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	user_id = request.json['userId']
	token = request.json['token']
	if not utils.authenticateToken(user_id, token):
		abort(401)
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT pid FROM UserLike WHERE userId = '%s';" % user_id)
	if cursor.rowcount > 0:
		pid_list = [item[0] for item in cursor.fetchall()]
		db.close()
		return jsonify({'favoritePids':pid_list})
	else :
		db.close()
		abort(400,"Unknown userId")


# author: Wen
# authentication
@favorites.route('/favorites/new', methods=['POST'])
def add_favorites():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
	token = request.json['token']
	if not utils.authenticateToken(userId, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("insert into UserLike (userId,pid) values (%s,%s)",[userId,pid])
		db.commit()
		db.close()
		return "200"

	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"insert unsuccessful"}')


# author: Wen
# authentication
@favorites.route('/favorites/remove', methods=['POST'])
def remove_favorites():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
	token = request.json['token']
	if not utils.authenticateToken(userId, token):
		abort(401)
		
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("DELETE FROM UserLike WHERE userId = %s AND pid = %s", [userId, pid])
		db.commit()
		db.close()
		return "200"

	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"remove unsuccessful"}')