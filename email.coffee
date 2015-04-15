nodemailer = require('nodemailer')
smtpTransport = require('nodemailer-smtp-transport')
transport = nodemailer.createTransport
  service: 'QQex'
  auth:
    user: process.env.EMAIL_NAME
    pass: process.env.EMAIL_PWD

mailOptions =
  from:'yuankui@mykar.com'
  to:'youqingkui_3@kindle.cn'
  subject:'hi'
  text:'hello'
  attachments:
    filename:'sass教程.txt'
    path:'app.js'

transport.sendMail mailOptions, (err, info) ->
  return console.log err if err

  console.log info
