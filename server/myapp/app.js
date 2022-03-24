var createError = require('http-errors');
var express = require('express');
var path = require('path');
require("dotenv").config();
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const http = require('http');
var indexRouter = require('./routes');
var app = express();
const server = http.createServer(app);
const mongoose = require("./databases/db.js");
const cors = require('cors');
// view engine setup


mongoose.connect();
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.use('/', indexRouter);

app.use(cors({ origin: 'http://localhost:4200' }));
// catch 404 and forward to error handler
app.use(function(req, res, next) {
  res.json('verify your route').status(500);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});


server.listen(process.env.PORT || 3000, () => {
  console.log(`Server running on port ${3000}`);
});