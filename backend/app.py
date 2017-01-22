from flask import Flask, jsonify, request, abort
from flask.ext.mysql import MySQL
import json, codecs
import boto3
from werkzeug.utils import secure_filename


config = json.load(codecs.open('config.json', encoding='utf-8'))
app = Flask(__name__)
mysql = MySQL()
client = boto3.client('s3')

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

@app.route('/user/image/<username>', methods=['POST'])
def uploader(username):
    if 'file' not in request.files:
        abort(400)
    f = request.files['file']
    if f.filename == "":
        abort(400)
    filename = secure_filename(f.filename)
    client.upload_fileobj(f, 'gtthriftshop', username + "/" + filename)
    return "https://s3-us-west-2.amazonaws.com/gtthriftshop/" + username + "/" + filename + "\n"

@app.route('/user/info', methods=['POST'])
def add_user_info():
    if not request.json or not 'userId' in request.json or not 'nickname' in request.json or not 'email' in request.json or not 'avatarURL' in request.json or not 'description' in request.json:
        abort(400, '{"message":"Input parameter incorrect or missing"}')
    userId = request.json['userId']
    nickname = request.json['nickname']
    email = request.json['email']
    avatarURL = request.json['avatarURL']
    description = request.json['description']
    
    cursor = db.cursor()
    try:
        cursor.execute("insert into UserInfo (userId,nickname,email,avatarURL,description) values (%s,%s,%s,%s,%s)",[userId,nickname,email,avatarURL,description])
        db.commit()
        return 'success'
        db.close()
    except:
        db.rollback()
        abort(404, '{"message":"Insert unsuccessful"}')




if __name__ == '__main__':
    app.run(host='0.0.0.0',port='80')
#app.run(debug=True)
