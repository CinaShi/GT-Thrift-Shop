 REST API Specification
# Version 1

## POST auth/login

Returns whether the user is a new user or not
### Resource URL

`http://ec2-34-196-222-211.compute-1.amazonaws.com/auth/login`

### Resource Information

* Response Format
	* boolean
* Requires Authentication
	* No
* Rate Limited
    * No

### Parameters
| Parameter               | Description |
| :---                    | :---        |
| `gtusername`<br/>*Required* | |

### Example Requests
* `http://ec2-34-196-222-211.compute-1.amazonaws.com/auth/login?gtusername=gburd1`

### Example Response
```
   True
   False
``` 

  

## GET user/image

Returns the url of the image

### Resource URL

`http://ec2-34-196-222-211.compute-1.amazonaws.com/user/image`

### Resource Information

* Response Format
	* JSON
* Requires Authentication
	* No
* Rate Limited
	* No

### Parameters
| Parameter               | Description |
| :---                    | :---        |
| imagedata               |             |

### Example Requests
* `自己想`

### Example Response
```json
{
	"imagename": "111.jpg",	
  "url":"暂时没想好“
}
```
## POST user/info

Update user info

### Resource URL

`http://ec2-34-196-222-211.compute-1.amazonaws.com/user/info`

### Resource Information

* Response Format
	* JSON
* Requires Authentication
	* No
* Rate Limited
	* No

### Parameters
| Parameter               | Description |
| :---                    | :---        |
| nickname                |             |
| email                   |             |
| avatarURL                |             |
| description                |             |

### Example Requests
* `http://ec2-34-196-222-211.compute-1.amazonaws.com/user/info?nickname=xiaofang&email=lalalu@gmail.com&avatarURL=111.jpg&description=suibia`

### Example Response
``` Integer
ない

```
## Error Codes & Responses

### HTTP Status Codes

| Code | Text | Description |
| :--- | :--- | :---        |
| 200  | OK   | Success!    |
| 400  | Bad Request | The request was invalid or cannot be otherwise served. An accompanying error message will explain further. |
| 404  | Not Found | The URI requested is invalid or the resource requested does not exist. |
| 500  | Internal Server Error | Something is broken and it's not your fault. |
| 503  | Service Unavailable | The service is up, but overloaded with requests. Try again later. |
