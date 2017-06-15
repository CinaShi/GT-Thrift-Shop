from flask import Flask, jsonify, request, abort
from flask.ext.mysql import MySQL
import json, codecs
import boto3
from werkzeug.utils import secure_filename
import datetime, random, string, hmac, hashlib
from products import products
from user import user
from favorites import favorites
from transactions import transactions
import utils

config = json.load(codecs.open('config.json', encoding='utf-8'))
application = app = Flask(__name__)
mysql = MySQL()
client = boto3.client('s3')

app.config['MYSQL_DATABASE_USER'] = config['db_user']
app.config['MYSQL_DATABASE_PASSWORD'] = config['db_passwd']
app.config['MYSQL_DATABASE_DB'] = config['db_db']
app.config['MYSQL_DATABASE_HOST'] = config['db_host']
mysql.init_app(app)

app.register_blueprint(products)
app.register_blueprint(user)
app.register_blueprint(favorites)
app.register_blueprint(transactions)


# author: Yang, Wen
@app.route('/auth/login', methods=['POST'])
def auth_login():
	if not request.json or not 'gtusername' in request.json or not 'hash' in request.json:
		abort(400)
	gtusername = request.json['gtusername']
	providedHash = request.json['hash']
	timeStamp = str(datetime.datetime.utcnow().date()) + "-" + str(datetime.datetime.utcnow().hour)
	generatedHash = hmac.new(key="jdteam199",msg=gtusername+"gtthriftshop2017"+timeStamp, digestmod=hashlib.sha256).hexdigest()
	if not hmac.compare_digest(str(providedHash), str(generatedHash)):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("select * from User WHERE gtusername = '%s'"%gtusername)
	if cursor.rowcount == 0:
		try:
			cursor.execute("insert into User (gtusername,AccountType) values (%s,%s)",[gtusername,0])
			newID = cursor.lastrowid
			tokenCursor = db.cursor()
			token = generate_token()
			tokenCursor.execute("REPLACE INTO APITokens (userId, tokens, timeStamp) VALUES (%s, %s, %s);",[newID, token, datetime.datetime.now()])
			db.commit()
			db.close()
			return json.dumps({'new':True,'userId':newID, 'token':token})
		except:
			db.rollback()
			db.close()
			abort(404)
	elif cursor.rowcount==1:
		results = cursor.fetchall()
		userid = results[0][0]
		tokenCursor = db.cursor()
		token = generate_token()
		tokenCursor.execute("REPLACE INTO APITokens (userId, tokens, timeStamp) VALUES (%s, %s, %s);",[userid, token, datetime.datetime.now()])
		db.commit()
		db.close()
		return json.dumps({'new':False, 'userId':userid, 'token':token})

def generate_token():
	return ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(64))


# author: Wen
# authentication
@app.route('/tags', methods=['POST'])
def get_tags():
	if not request.json or not 'userId' in request.json or not 'token' in request.json:
		abort(400)
	userId = request.json['userId']
	token = request.json['token']
	if not utils.authenticateToken(userId, token):
		abort(401)

	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT tag FROM Tag;")
	tagList = []
	if cursor.rowcount > 0:
		tagList = [tag[0] for tag in cursor.fetchall()]
		db.close()
		return jsonify({'tags':tagList})
	else:
		db.close()
		abort(400,"Fetch tag error")


if __name__ == '__main__':
	app.run(host='0.0.0.0',port='80')
	#app.debug = True
	#app.run(port=8888)
