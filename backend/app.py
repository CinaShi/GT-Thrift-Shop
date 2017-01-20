from flask import Flask, jsonify
from flask import request, abort
from flask.ext.mysql import MySQL
import json,codecs
config = json.load(codecs.open('config.json', encoding='utf-8'))
app = Flask(__name__)
mysql = MySQL()

app.config['MYSQL_DATABASE_USER'] = config['db_user']
app.config['MYSQL_DATABASE_PASSWORD'] = config['db_passwd']
app.config['MYSQL_DATABASE_DB'] = config['db_db']
app.config['MYSQL_DATABASE_HOST'] = config['db_host']
mysql.init_app(app)
db = mysql.connect()
@app.route('/auth/login',methods=['POST'])
def auth_login():
    if not request.json or not 'gtusername' in request.json:
        abort(400)
    gtusername = request.json['gtusername']
    cursor = db.cursor()
    cursor.execute("select * from User WHERE gtusername = '%s'"%gtusername)
    if cursor.rowcount == 0:
        try:
            cursor.execute("insert into User (gtusername,AccountType) values (%s,%s)",[gtusername,0])
            newID = cursor.lastrowid
            db.commit()
            return json.dumps({'new':True,'userId':newID})
        except:
            db.rollback()
            abort(404)
    elif cursor.rowcount==1:
        results = cursor.fetchall()
        userid = results[0][0]
        return  json.dumps({'new':False,'userId':userid}) 

if __name__ == '__main__':
    app.run(host='0.0.0.0',port='80')
#app.run(debug=True)
