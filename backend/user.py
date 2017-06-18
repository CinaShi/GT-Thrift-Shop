from flask import Flask, jsonify, request, abort, Blueprint
from flask.ext.mysql import MySQL
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

user = Blueprint('user', __name__)


# author: Wen
# authentication
@user.route('/user/image', methods=['POST'])
def uploader(username):
	if not request.files or not request.form or 'file' not in request.files or 'json' not in request.form:
		abort(400)

	f = request.files['file']
	if f.filename == "":
		abort(400)

	jsonStr = request.form["json"]
	jsonDic = json.loads(jsonStr)
	if not 'userId' in jsonDic or not 'token' in jsonDic:
		abort(400, '{"message":"Missing parameters in json file"}')

	userId = jsonDic['userId']
	token = jsonDic['token']
	if not utils.authenticateToken(userId, token):
		abort(401)

	filename = secure_filename(f.filename)
	client.upload_fileobj(f, 'gtthriftshopusers', userId + "/" + filename)
	return "https://s3-us-west-2.amazonaws.com/gtthriftshopusers/" + userId + "/" + filename


# author: Yichen, Wen
# authentication
@user.route('/user/info', methods=['POST'])
def add_user_info():
	if not request.json or not 'userId' in request.json or not 'nickname' in request.json or not 'email' in request.json or not 'avatarURL' in request.json or not 'description' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	user_id = request.json['userId']
	nickname = request.json['nickname']
	email = request.json['email']
	avatar_url = request.json['avatarURL']
	description = request.json['description']
	token = request.json['token']
	if not utils.authenticateToken(user_id, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("insert into UserInfo (userId,nickname,email,avatarURL,description) values (%s,%s,%s,%s,%s)", [user_id, nickname, email, avatar_url, description])
		db.commit()
		db.close()
		return 'Insert User Info Success'

	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"insert unsuccessful"}')


# author: Yang, Wen
# authentication
@user.route('/user/rate/get', methods=['POST'])
def get_user_rate():
	if not request.json or not 'userId' in request.json or not 'token' in request.json:
		abort(400)
	userId = request.json['userId']
	token = request.json['token']
	if not utils.authenticateToken(userId, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT userRate FROM UserRate WHERE userId = '%s';"%userId)

	if cursor.rowcount >0:
		rateRow = cursor.fetchall()[0]
		db.close()
		return jsonify({'rate': rateRow[0]})
	else:
		db.close()
		return jsonify({'rate': -1})


# author: Wen
# authentication
@user.route('/user/cr/update', methods=['POST'])
def update_user_rate_comment():
	if not request.json or not 'userId' in request.json or not 'rate' in request.json or not 'ccontent' in request.json or not 'commentatorId' in request.json or not 'tranId' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = int(request.json['userId'])
	rate = int(request.json['rate'])	
	ccontent = request.json['ccontent']
	commentatorId = int(request.json['commentatorId'])
	tranId = request.json['tranId']
	token = request.json['token']
	postTime = datetime.datetime.now()
	if not utils.authenticateToken(userId, token):
		abort(401)

	db = mysql.connect()
	cursor2 = db.cursor()
	cursor2.execute("SELECT userId FROM UserComment WHERE tranId = %s;" % tranId)
	if cursor2.rowcount > 0:
		try:
			cursor2.execute("DELETE FROM UserComment WHERE tranId = %s;" % tranId)
			db.commit()
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"update comment unsuccessful"}')
	try:
		cursor2.execute("INSERT INTO UserComment(userId,ccontent,commentatorId,tranId,postTime,rate) values (%s,%s,%s,%s,%s,%s)", [userId, ccontent, commentatorId, tranId, postTime, rate])
		newId = cursor2.lastrowid
		db.commit()
		
	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"insert new comment unsuccessful"}')
	cursor2.close()

	tranCur = db.cursor()
	try:
		tranCur.execute("UPDATE Transaction SET isRated = '%s' WHERE tranId = %s;",[1,tranId])
		db.commit()
	except:
		db.rollback()
		db.close()
		abort(400,'{"message":"update transction fail"}')

	cursor = db.cursor()
	cursor.execute("SELECT userRate,rateCount from UserRate WHERE userId =%s;"%userId)
	if cursor.rowcount > 0:

		rateRow = cursor.fetchall()[0]
		prevRate = float(rateRow[0])
		prevCount = int(rateRow[1])
		newRate = (float(prevRate*prevCount + rate))/(prevCount+1)
		newCount = prevCount +1
		try:
			cursor.execute("UPDATE UserRate SET userRate = '%s', rateCount = '%s' WHERE userId = %s;", [newRate, newCount, userId])
			db.commit()
			db.close()
			return 'Success'
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"update rate unsuccessful"}')
	else:
		try:
			cursor.execute("INSERT INTO UserRate(userId,userRate,rateCount) values (%s,%s,%s)", [userId, rate, 1])
			db.commit()
			return 'Success'
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"insert rate unsuccessful"}')
	
	cursor.close()
	

# author: Yang, Wen
# authentication
@user.route('/user/rate/update', methods=['POST'])
def update_user_rate():
	if not request.json or not 'userId' in request.json or not 'rate' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	rate = int(request.json['rate'])
	token = request.json['token']
	if not utils.authenticateToken(userId, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT userRate,rateCount from UserRate WHERE userId ='%s';" % userId)
	if cursor.rowcount > 0:

		rateRow = cursor.fetchall()[0]
		prevRate = float(rateRow[0])
		prevCount = int(rateRow[1])
		newRate = (float(prevRate*prevCount + rate))/(prevCount+1)
		newCount = prevCount +1
		try:
			cursor.execute("UPDATE UserRate SET userRate = '%s', rateCount = '%s' WHERE userId = '%s';", [newRate, newCount, userId])
			db.commit()
			db.close()
			return 'Success'
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"update rate unsuccessful"}')
	else:
		try:
			cursor.execute("INSERT INTO UserRate(userId,userRate,rateCount) values (%s,%s,%s)",[userId,rate,1])
			db.commit()
			db.close()
			return("success")
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"update rate unsuccessful"}')


# author: Yichen, Wen
# authentication
@user.route('/user/comment/get', methods=['POST'])
def get_user_comment():
	if not request.json or not 'userId' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	user_id = request.json['userId']
	token = request.json['token']
	if not utils.authenticateToken(user_id, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	
	cursor.execute("SELECT UserComment.ccontent, UserComment.tranId, Transaction.pid, Transaction.buyerId, UserComment.postTime,UserComment.rate FROM UserComment INNER JOIN Transaction WHERE Transaction.tranId = UserComment.tranId AND UserComment.userId = '%s';" % user_id)
	comment_list = []
	if cursor.rowcount > 0:
		for comment in cursor.fetchall():
			temp = {}
			temp["commentContent"] = comment[0]
			temp["tranId"] = comment[1]
			temp["pid"] = comment[2]
			temp["buyerId"] = comment[3]
			buyer_cursor = db.cursor()
			buyer_cursor.execute("SELECT nickname FROM UserInfo WHERE userId = '%s';" % comment[3])
			buyer_name = buyer_cursor.fetchall()[0][0]
			temp["buyerName"] = buyer_name
			temp["postTime"] = comment[4]
			temp["rate"] = comment[5]
			comment_list.append(temp)
		db.close()
		return jsonify({'comments': comment_list})
	else:
		db.close()
		abort(400, "No comment provided for this user")


# author: Yichen, Wen
# authentication
@user.route('/user/comment/update', methods=['POST'])
def update_user_comment():
	if not request.json or not 'userId' in request.json or not 'ccontent' in request.json or not 'commentatorId' in request.json or not 'tranId' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	user_id = request.json['userId']
	c_content = request.json['ccontent']
	commentator_id = request.json['commentatorId']
	transaction_id = request.json['tranId']
	token = request.json['token']
	if not utils.authenticateToken(user_id, token):
		abort(401)

	post_time = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("INSERT INTO UserComment(userId,ccontent,commentatorId,tranId,postTime) values (%s,%s,%s,%s,%s)", [user_id, c_content, commentator_id, transaction_id, post_time])
		new_id = cursor.lastrowid
		db.commit()
		db.close()
		return 'Success'
	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"insert new comment unsuccessful"}')


# author: Wen
# authentication
@user.route('/user/info/get', methods=['POST'])
def get_user_info():
	if not request.json or not 'userId' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	token = request.json['token']
	if not utils.authenticateToken(userId, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	info = {}
	cursor.execute("SELECT nickname, email, avatarURL, description FROM UserInfo WHERE userId = '%s';"%userId)
	if cursor.rowcount > 0:
		row = cursor.fetchall()[0]
		info["nickname"] = row[0]
		info["email"] = row[1]
		info["avatarURL"] = row[2]
		info["description"] = row[3]
	else:
		db.close()
		abort(400,"This user has invalid user info")

	cursor = db.cursor()
	cursor.execute("SELECT userRate FROM UserRate WHERE userId = '%s';"%userId)
	if cursor.rowcount > 0:
		row = cursor.fetchall()[0]
		info["rate"] = float(row[0])
	else:
		info["rate"] = float("-1")
		#db.close()
		#abort(400,"This user has invalid user rate")

	db.close()
	return jsonify({'userInfo':info})


# author: Yichen, Wen
# Sprint: 6
# authentication
@user.route('/user/info/update', methods=['POST'])
def update_user_info():
	if not request.json or not 'userId' in request.json or not 'nickname' in request.json or not 'email' in request.json or not 'avatarURL' in request.json or not 'description' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	user_id = request.json['userId']
	nickname = request.json['nickname']
	email = request.json['email']
	avatar_url = request.json['avatarURL']
	description = request.json['description']
	token = request.json['token']
	if not utils.authenticateToken(user_id, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM UserInfo WHERE userId = '%s'" % user_id)
	if cursor.rowcount == 1:
		cursor.execute("UPDATE UserInfo SET nickname = %s,email = %s,avatarURL = %s, description = %s WHERE userId = %s", [nickname, email, avatar_url, description, user_id])
		db.commit()
		db.close()
		return 'Success'
	else:
		db.rollback()
		db.close()
		abort(400, 'fail')


# author: Yichen, Wen
# authentication
@user.route('/user/getAvatarURL', methods=['POST'])
def get_user_avatarURL():
	if not request.json or not 'userId' in request.json or not 'token' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	user_id = request.json['userId']
	token = request.json['token']
	if not utils.authenticateToken(user_id, token):
		abort(401)
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT avatarURL FROM UserInfo WHERE userId = '%s';" % user_id)
	if cursor.rowcount == 1:
		result = [item[0] for item in cursor.fetchall()]
		str_result = ''.join(map(str, result))
		db.close()
		return jsonify({'avatarURL': str_result})
	else:
		db.close()
		abort(400, "no user exists")