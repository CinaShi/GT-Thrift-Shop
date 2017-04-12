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

products = Blueprint('products', __name__)

#author: Yang
@products.route('/products', methods=['GET'])
def get_all_products():
	
	productsList = []

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT * FROM Product ORDER BY postTime;")
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
			isSold = pRow[7]
			imageCur = db.cursor()
			imageCur.execute("SELECT imageURL FROM ProductImage WHERE pid = '%d';"%pid)
			imageList = []
			if imageCur.rowcount > 0:
				imageR = imageCur.fetchall()
				for i in imageR:
					imageList.append(i[0])
			userCur = db.cursor()
			userCur.execute("SELECT nickname FROM UserInfo WHERE userId = '%d';"%userId)
			if userCur.rowcount >0:
				nickname = userCur.fetchall()[0][0]
			currentProduct = {}
			currentProduct['nickname'] = nickname
			currentProduct['userId'] = userId
			currentProduct['pid'] = pid
			currentProduct['pName'] = pName
			currentProduct['pPrice'] = pPrice
			currentProduct['pInfo'] = pInfo
			currentProduct['postTime'] = postTime
			currentProduct['usedTime'] = usedTime
			currentProduct['images'] = imageList
			currentProduct['isSold'] = isSold
			productsList.append(currentProduct)
	db.close()
	return jsonify({'products':productsList})


@products.route('/products/tags/<tag>', methods=['GET'])
def get_tag_pid(tag):
	db = mysql.connect()
	cursor = db.cursor()
	tag = tag.replace('_',' ')
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


@products.route('/products/details/<pid>', methods=['POST'])
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


#author: Wen
@products.route('/products/add/images/<pid>', methods=['POST'])
def product_uploader(pid):
	fileList = request.files.getlist('files')
	if len(fileList) == 0:
		abort(400)
	db = mysql.connect()
	cursor = db.cursor()
	addressList = []
	for file in fileList:
		filename = secure_filename(file.filename)
		client.upload_fileobj(file, 'gtthriftshopproducts', pid + "/" + filename)
		imageURL = "https://s3-us-west-2.amazonaws.com/gtthriftshopproducts/" + pid + "/" + filename
		addressList.append(imageURL)
		try:
			cursor.execute("INSERT INTO ProductImage(pid,imageURL) values(%s,%s)", [pid,imageURL])
		except:
			db.rollback()
			db.close()
			abort(400, '{"message":"upload unsuccessful"}')
	db.commit()
	db.close()
	return jsonify({'photoUrls':addressList})

#author: Yichen
@products.route('/products/add/allInfo', methods=['POST'])
def add_product():
	if not request.json or not 'userId' in request.json or not 'pName' in request.json or not 'pPrice' in request.json or not 'pInfo' in request.json or not 'tag' in request.json or not 'usedTime' in request.json: 
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pName = request.json['pName']
	pPrice = request.json['pPrice']
	pInfo = request.json['pInfo']
	usedTime = request.json['usedTime']
	tag = request.json['tag']
	isSold = 0
	postTime = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT tid FROM Tag WHERE tag = '%s'"%tag)
	tid = [item[0] for item in cursor.fetchall()]
	try:
		cursor.execute("INSERT INTO Product(userId,pName,pPrice,pInfo,postTime,usedTime,isSold) values (%s,%s,%s,%s,%s,%s,%s)",[userId,pName,pPrice,pInfo,postTime,usedTime,isSold])
		pid = cursor.lastrowid
		cursor.execute("INSERT INTO ProductTag(pid,tid) values(%s,%s)",[pid,tid])
		db.commit()
		db.close()
		return jsonify({'pid':pid})
	except:
		db.rollback()
		db.close()
		abort(400, '{"message":"Product info added unsuccessful"}')


#author: Yichen
@products.route('/products/update/isSold', methods=['POST'])
def update_isSold():
	if not request.json or not 'userId' in request.json or not 'pid' in request.json:
		abort(400, '{"message":"Input parameter incorrect or missing"}')
	userId = request.json['userId']
	pid = request.json['pid']
	isSold = 1
	postTime = datetime.datetime.now()
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT isSold FROM Product WHERE pid = %s AND isSold = %s",[pid, 0])
	if cursor.rowcount == 1:
		try:
			cursor.execute("UPDATE Product SET isSold = '%s' WHERE pid = %s", [isSold,pid])
			cursor.execute("INSERT INTO Transaction(pid,buyerId,time) values (%s,%s,%s)",[pid, userId, postTime])
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
@products.route('/products/add/interest', methods=['POST'])
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

#author: Yichen
@products.route('/products/getInterest/<userId>', methods=['GET'])
def get_interest(userId):
	pidList1 = []
	pidList2 = []
	result = []
	db = mysql.connect()
	userCur = db.cursor()
	userCur.execute("SELECT nickname FROM UserInfo WHERE userId = '%s';"%userId)
	if userCur.rowcount >0:
		nickname = userCur.fetchall()[0][0]

	cursor = db.cursor()
	
	cursor.execute("SELECT pid FROM Product WHERE userId = '%s';"%userId)
	if cursor.rowcount > 0:
		pidList1 = [item[0] for item in cursor.fetchall()]
		for pid in pidList1:
			p1Cur = db.cursor()
			p1Cur.execute("SELECT interestUId FROM InterestList WHERE pid = '%s';"%pid)
			result = [item[0] for item in p1Cur.fetchall()]
	
	cursor.execute("SELECT pid FROM InterestList WHERE interestUId = '%s';"%userId)
	if cursor.rowcount > 0:
		pidList2 = cursor.fetchall()
		for pid in pidList2:
			p2Cur = db.cursor()
			p2Cur.execute("SELECT userId from Product WHERE pid = '%s';"%pid)
			userRow = p2Cur.fetchall()[0]
			userList = int(userRow[0])
			result.append(userList)
	result = sorted(set(result))
	db.close()
	return jsonify({'Interest':result,'nickname':nickname})



@products.route('/products/getAllPost/<uid>', methods=['GET'])
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


#author: Wen
@products.route('/products/interest/<pid>', methods=['GET'])
def get_product_interests(pid):
	uidList = []
	
	db = mysql.connect()
	cursor = db.cursor()
	returnList = []
	cursor.execute("SELECT interestUid FROM InterestList WHERE pid = '%s';"%pid) 
	if cursor.rowcount > 0:
		uidList = [item[0] for item in cursor.fetchall()]
		for uid in uidList:
			temp = {}
			userCur = db.cursor()
			userCur.execute("SELECT nickname,avatarURL FROM UserInfo WHERE userId = '%s';"%uid)
			intereP = userCur.fetchall()[0]
			nickname = intereP[0]
			temp['userId'] = uid
			temp['avatarURL'] = intereP[1]
			temp['nickname'] = nickname
			returnList.append(temp)
		db.close()
		return jsonify({'interestList':returnList})
	else :
		db.close()
		abort(400,"Unknown pid")