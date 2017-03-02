from flask import Flask, jsonify, request, abort
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

## Sprint 1

@app.route('/auth/login',methods=['POST'])
def auth_login():
	if not request.json or not 'gtusername' in request.json:
		abort(400)
	gtusername = request.json['gtusername']
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("select * from User WHERE gtusername = '%s'"%gtusername)
	if cursor.rowcount == 0:
		try:
			cursor.execute("insert into User (gtusername,AccountType) values (%s,%s)",[gtusername,0])
			newID = cursor.lastrowid
			db.commit()
			db.close()
			return json.dumps({'new':True,'userId':newID})
		except:
			db.rollback()
			db.close()
			abort(404)
	elif cursor.rowcount==1:
		results = cursor.fetchall()
		userid = results[0][0]
		db.close()
		return  json.dumps({'new':False,'userId':userid}) 


@app.route('/user/image/<username>', methods=['POST'])
def uploader(username):
	if 'file' not in request.files:
		abort(400)
	f = request.files['file']
	if f.filename == "":
		abort(400)
	filename = secure_filename(f.filename)
	client.upload_fileobj(f, 'gtthriftshopusers', username + "/" + filename)
	return "https://s3-us-west-2.amazonaws.com/gtthriftshopusers/" + username + "/" + filename


@app.route('/user/info', methods=['POST'])
def add_user_info():
	if not request.json or not 'userId' in request.json or not 'nickname' in request.json or not 'email' in request.json or not 'avatarURL' in request.json or not 'description' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	nickname = request.json['nickname']
	email = request.json['email']
	avatarURL = request.json['avatarURL']
	description = request.json['description']
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("insert into UserInfo (userId,nickname,email,avatarURL,description) values (%s,%s,%s,%s,%s)",[userId,nickname,email,avatarURL,description])
		db.commit()
		db.close()
		return 'Insert User Info Success'

	except:
	   db.rollback()
	   db.close()
	   abort(400, '{"message":"insert unsuccessful"}')

## Sprint 2

@app.route('/products', methods=['GET'])
def get_all_products():
	
	productsList = []

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM Product WHERE isSold = 0 ORDER BY postTime;")
	if cursor.rowcount > 0:
		productList = cursor.fetchall()
		for pRow in productList:
			userId = pRow[0]
			pid = pRow[1]
			pName = pRow[2]
			pPrice = pRow[3]
			pInfo = pRow[4]
			postTime = pRow[5]
			usedTime = pRow[6]
			imageCur = db.cursor()
			imageCur.execute("SELECT imageURL FROM ProductImage WHERE pid = '%d';"%pid)
			imageList = []
			if imageCur.rowcount > 0:
				imageR = imageCur.fetchall()
				for i in imageR:
					imageList.append(i[0])
			currentProduct = {}
			currentProduct['userId'] = userId
			currentProduct['pid'] = pid
			currentProduct['pName'] = pName
			currentProduct['pPrice'] = pPrice
			currentProduct['pInfo'] = pInfo
			currentProduct['postTime'] = postTime
			currentProduct['usedTime'] = usedTime
			currentProduct['images'] = imageList
			productsList.append(currentProduct)
	db.close()
	return jsonify({'products':productsList})


@app.route('/products/tags/<tag>', methods=['GET'])
def get_tag_pid(tag):
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT tid FROM Tag WHERE tag = '%s';"%tag)
	pidList = []
	if cursor.rowcount == 1:
		tid = cursor.fetchall()[0]
		pidCur = db.cursor()
		pidCur.execute("SELECT pid FROM ProductTag WHERE tid = '%d';"%tid)
		if pidCur.rowcount > 0:
			pidList = [item[0] for item in pidCur.fetchall()]
		db.close()
		return jsonify({'pids':pidList})
	else:
		db.close()
		abort(400,"Incorrect Tag")


@app.route('/products/details/<pid>', methods=['POST'])
def get_tag_details(pid):
	if not request.json or not 'userId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	tidList = []
	tagList = []

	userId = request.json['userId']	

	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT tid FROM ProductTag WHERE pid = '%s';"%pid)
	if cursor.rowcount > 0:
		tidList = cursor.fetchall()
		for tid in tidList:
			tidCur = db.cursor()
			tidCur.execute("SELECT tag from Tag WHERE tid = '%s';"%tid)
			if tidCur.rowcount > 0:
				tagList = tidCur.fetchall()[0]

			else:
				continue
	favCur = db.cursor()
	favCur.execute("SELECT * FROM UserLike WHERE userId = %s AND pid = %s",[userId, pid])
	if favCur.rowcount == 1:
		isFavorite = True
	else: 
		isFavorite = False
	db.close()
	return jsonify({'tagList':tagList, 'isFavorite':isFavorite})


@app.route('/favorites/all/<userId>', methods=['GET'])
def get_favorites_pid(userId):

	pidList = []
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT pid FROM UserLike WHERE userId = '%s';"%userId) 
	if cursor.rowcount > 0:
		pidList = [item[0] for item in cursor.fetchall()]
		db.close()
		return jsonify({'favoritePids':pidList})
	else :
		db.close()
		abort(400,"Unknown userId")


@app.route('/favorites/new', methods=['POST'])
def add_favorites():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
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


@app.route('/favorites/remove', methods=['POST'])
def remove_favorites():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
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

## Sprint 3
#author: Yichen
@app.route('/products/image/<userId>', methods=['POST'])
def product_uploader(userId):
	return None
	# if 'file' not in request.files:
	# 	abort(400)
	# f = request.files['file']
	# if f.filename == "":
	# 	abort(400)
	# filename = secure_filename(f.filename)
	# client.upload_fileobj(f, 'gtthriftshopusers', userId + "/" + filename)
	# return "https://s3-us-west-2.amazonaws.com/gtthriftshopproducts/" + userId + "/" + filename

@app.route('/products/add/allInfo', methods=['POST'])
def add_product():
	if not request.json or not 'userId' in request.json or not 'pName' in request.json or not 'pPrice' in request.json or not 'pInfo' in request.json or not 'imageURL' in request.json or not 'tid' in request.json or not 'usedTime' in request.json: 
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pName = request.json['pName']
	pPrice = request.json['pPrice']
	pInfo = request.json['pInfo']
	imageURL = request.json['imageURL']
	usedTime = request.json['usedTime']
	tid = request.json['tid']
	isSold = 0
	postTime = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("INSERT INTO Product(userId,pName,pPrice,pInfo,postTime,usedTime,isSold) values (%s,%s,%s,%s,%s,%s,%s)",[userId,pName,pPrice,pInfo,postTime,usedTime,isSold])
		pid = cursor.lastrowid
		cursor.execute("INSERT INTO ProductImage(pid,imageURL) values(%s,%s)", [pid,imageURL])
		cursor.execute("INSERT INTO ProductTag(pid,tid) values(%s,%s)",[pid,tid])
		db.commit()
		db.close()
		return "Success"
	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"Product info added unsuccessful"}')



#author: Yichen
@app.route('/products/update/isSold', methods=['POST'])
def update_isSold():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
	isSold = 1
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT isSold FROM Product WHERE pid = %s AND isSold = %s",[pid, 0])
	if cursor.rowcount == 1:
		try:
			cursor.execute("UPDATE Product SET isSold = '%s' WHERE pid = %s", [isSold,pid])
			cursor.execute("INSERT INTO Transaction(pid,buyerId) values (%s,%s)",[pid, userId])
			newTranId = cursor.lastrowid
			db.commit()
			db.close()
			return("Success") 
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"product sold is unsuccessful"}')
	else:
		db.close()
		abort(400,"Product not found or item has been sold already")


#author: Yang
@app.route('/products/add/interest', methods=['POST'])
def add_interest():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("INSERT INTO InterestList(pid,interestUId) values (%s,%s)",[pid,userId])
		db.commit()
		db.close()
		return("success")
	except:
	    db.rollback()
	    db.close()
	    abort(400, '{"message":"add interest user unsuccessful"}')

#Wen
@app.route('/transactions/getAll/<uid>', methods=['GET'])
def get_all_transactions(uid):
	transList = []
	returnList = []
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT Transaction.buyerId, Product.userId, Transaction.pid FROM Transaction INNER JOIN Product WHERE Transaction.pid = Product.pid AND (Product.userId = %s OR Transaction.buyerId = %s);",[uid, uid]) 
	if cursor.rowcount > 0:
		transList = cursor.fetchall()
		for trans in transList:
			temp = {}
			temp["buyerID"] = trans[0]
			temp["sellerID"] = trans[1]
			temp["pid"] = trans[2]
			returnList.append(temp)
		db.close()
		return jsonify({'transactions':returnList})
	else :
		db.close()
		abort(400,"Unknown userId")

#Wen
@app.route('/products/getAllPost/<uid>', methods=['GET'])
def get_all_post(uid):
	pidList = []
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT pid FROM Product WHERE userId = '%s';"%uid) 
	if cursor.rowcount > 0:
		pidList = [item[0] for item in cursor.fetchall()]
		db.close()
		return jsonify({'PostPids':pidList})
	else :
		db.close()
		abort(400,"Unknown userId")

#Wen
@app.route('/products/interest/<pid>', methods=['GET'])
def get_product_interests(pid):
	uidList = []
	
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT interestUid FROM InterestList WHERE pid = '%s';"%pid) 
	if cursor.rowcount > 0:
		uidList = [item[0] for item in cursor.fetchall()]
		db.close()
		return jsonify({'interestUids':uidList})
	else :
		db.close()
		abort(400,"Unknown userId")

#author Yang
@app.route('/user/rate/get/<uid>', methods=['GET'])
def get_user_rate(uid):
	db = mysql.connect()
	cursor = db.cursor()

	cursor.execute("SELECT userRate FROM UserRate WHERE userId = '%s';"%uid)
	if cursor.rowcount >0:
		rateRow = cursor.fetchall()[0]
		return str(rateRow[0])
	else:
		return ("-1")
	db.close()

#author Yang
@app.route('/user/rate/update', methods=['POST'])
def update_user_rate():
	if not request.json or not 'userId' in request.json or not 'rate' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	rate = int(request.json['rate'])

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT userRate,rateCount from UserRate WHERE userId ='%s';"%userId)
	if cursor.rowcount > 0:

		rateRow = cursor.fetchall()[0]
		prevRate = float(rateRow[0])
		prevCount = int(rateRow[1])
		newRate = (float(prevRate*prevCount + rate))/(prevCount+1)
		newCount = prevCount +1
		try:
			cursor.execute("UPDATE UserRate SET userRate = '%s', rateCount = '%s' WHERE userId = '%s';",[newRate,newCount,userId])
			db.commit()
			db.close()
			return ("success")
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


#author: Yichen
@app.route('/user/comment/get/<uid>', methods=['GET'])
def get_user_comment(uid):
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT ccontent FROM UserComment WHERE userId = '%s';"%uid)
	if cursor.rowcount > 0:
		rateRow = cursor.fetchall()[0]
		db.close()
		return "comment:'" + str(rateRow[0]) + "'"
	else:
		db.close()
		abort(400,"No comment provided for this user")
		

#author: Yichen
@app.route('/user/comment/update', methods=['POST'])
def update_user_comment():
	if not request.json or not 'userId' in request.json or not 'ccontent' in request.json or not 'commentatorId' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	ccontent = request.json['ccontent']
	commentatorId = request.json['commentatorId']
	db = mysql.connect()
	cursor = db.cursor()
	try:
		cursor.execute("INSERT INTO UserComment(userId,ccontent,commentatorId) values (%s,%s,%s)",[userId,ccontent,commentatorId])
		newId = cursor.lastrowid
		db.commit()
		db.close()
		return("success")
	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"insert new comment unsuccessful"}')



if __name__ == '__main__':
	app.run(host='0.0.0.0',port='80')
	#app.run()
