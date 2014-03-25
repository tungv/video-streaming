demo-bookstore
==============

Demo to show how to combine angular, express, mongodb in a single web application.

Get started
===========

1. if you clone the source from github, you need to `npm install` and `bower install`.
   You also need to run `npm install -g coffee-script` to have `coffee` executable cmd
2. setup your mongodb and make sure the `config/default.yaml` is correct.
   You only need an empty db, on the first run, data will be automatically inserted
3. compiled js files are included; however, it doesn't take you so long to run `coffee -c ./app/scripts`
4. so does the .less file, just run `lessc ./app/styles/bookstore.less ./app/styles/bookstore.css`
5. add host to simulate cross domain situation:
   ```
   127.0.0.1 api.test.com
   ```
6. now you can start the app with `coffee server.coffee` and go to `http://localhost:3000/`.
   It will consume the api from `http://api.test.com:3000/api/`
   (only support modern browsers because I don't have that much time)

Things that done
================
1. Set up database with data from pageResources/price.json file
2. Must-have page’s features:
  - User registration
  - User login/logout (**with both hashed and non-hashed passwords**)
  - Get book list (login require)
  - Get single book (login require)
  - Update book data (login require)
  - Delete book (login require)
3. Nice to have features:
  - Search book
  - Sort book
  - Paging book list

API endpoints
-------------
#### Non-authenticating end-points
Methods | url               | note
--------|-------------------|----------
POST    | /api/login        | returns current user info
POST    | /api/users        | create new user

#### Authenticating end-points
Methods | url               | note
--------|-------------------|----------
GET     | /api/users        | ?count=true to get count
GET     | /api/users/:id    | 
PUT     | /api/users/:id    |
DELETE  | /api/users/:id    |
GET     | /api/books        | ?count=true to get count; ?search=query to filter books by name and desc
POST    | /api/books        | must have unique id on body (I didn't generate auto-increment id)
GET     | /api/books/:id    |
PUT     | /api/books/:id    |
DELETE  | /api/books/:id    |

#### Request Headers
name            | note
----------------|-----------------------------
X-AUTH-USERNAME | authenticating email
X-AUTH-TOKEN    | md5'ed or plain-text password
X-AUTH-HASHED   | indicates that password was hashed if set to true

Things that aren't done
=======================
1. CORS support for IE (I'm not sure if it works)
2. Authorization, any logged user can change others' information
3. Strictly validations
4. mocha testing

