nodemailer = require('nodemailer')
smtpTransport = require('nodemailer-smtp-transport')
transport = nodemailer.createTransport smtpTransport
  host: 'smtp.exmail.qq.com'
  port: 465
  secure: true
  auth:
    user: process.env.EMAIL_NAME
    pass: process.env.EMAIL_PWD

mailOptions =
  from:'yuankui@mykar.com'
  to:'youqingkui@qq.com'
  subject:'hi'
  text:'hello'
  attachments:
    filename:'app.js'
    path:'app.js'

transport.sendMail mailOptions, (err, info) ->
  return console.log err if err

  console.log info
