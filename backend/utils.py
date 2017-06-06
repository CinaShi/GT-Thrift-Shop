from flask import Flask, jsonify, request, abort
from flask.ext.mysql import MySQL
import json, codecs
import datetime

config = json.load(codecs.open('config.json', encoding='utf-8'))
app = Flask(__name__)
mysql = MySQL()

app.config['MYSQL_DATABASE_USER'] = config['db_user']
app.config['MYSQL_DATABASE_PASSWORD'] = config['db_passwd']
app.config['MYSQL_DATABASE_DB'] = config['db_db']
app.config['MYSQL_DATABASE_HOST'] = config['db_host']
mysql.init_app(app)


## abort 401 Unauthenticated
def authenticateToken(userId, token):
	TIMELIMIT = datetime.timedelta(minutes=30)
	db = mysql.connect()
	cursor = db.cursor()
	cursor.execute("SELECT timeStamp FROM APITokens WHERE userId = %s AND tokens = %s;", [userId, token])
	if cursor.rowcount == 0:
		db.close()
		return False
	elif cursor.rowcount == 1:
		timeStamp = cursor.fetchall()[0][0]
		delta = datetime.datetime.now() - timeStamp
		if delta > TIMELIMIT:
			return False
		else:
			tokenCursor = db.cursor()
			try:
				tokenCursor.execute("UPDATE APITokens SET timeStamp = %s WHERE userId = %s;",[datetime.datetime.now(), userId])
				db.commit()
				db.close()
				return True
			except:
				db.rollback()
				db.close()
				return False

