request = require("request")
async   = require("async")
fs      = require("fs")
cheerio = require("cheerio")

#ninghao = (@courseUrl) ->
#  @courseName = 'ninghao.net'
#  @href = []
#  @content = ''
#  return
#
#
#ninghao::getCourseUrl = (cb) ->
#  self = @
#  request.get self.courseUrl, (err, res, body) ->
#    if err
#      console.log "get course url error"
#      return console.log err
#
#    $ = cheerio.load(body)
#    if $(".course-info h1").length is 0
#      return console.log "没有找到课程名，使用默认课程名 #{self.courseName}"
#    else
#      self.courseName = $(".course-info h1").text()
#      console.log "找到课程名 #{self.courseName}"
#
#    link = $("tr > td a")
#    linkLen = link.length
#    console.log "查找到得课程列表： #{linkLen}"
#    unless linkLen
#      return console.log "奇怪怎么没有找到课程列表？"
#
#    link.each (idx, element) ->
#      self.href.push($(element).attr("href"))
#
#    unless self.href.length
#      return console.log "奇怪，应该不会出现这情况吧, @href 为空？"
#
#    console.log "### 获取课程列表 end ###"
#    unless fs.existsSync(self.courseName)
#      fs.mkdirSync(self.courseName)
#
#    cb()
#
#
#ninghao::getHref = () ->
#  self = @
#  async.eachSeries self.href, (item, callback) ->
#
#    request.get 'http://ninghao.net' + item, (err, res, body) ->
#      if err
#        console.log "get href error: #{item}"
#        return console.log err
#
#      $ = cheerio.load(body)
#      $title = $("#sidebar section div.box strong a")
#      $pTag = $(".tab-content section .view-content > div p")
#      if $title.length is 0
#        return console.log "get href no title:#{item}"
#
#      if $pTag.length is 0
#        return console.log "get href no content: #{item}"
#
#      self.content += $title.text() + '\n\n'
#      for p, i in $pTag
#        self.content += $(p).text() + '\n'
#        if i == $pTag.length - 1
#          self.content += '\n\n'
#
#
#
#      console.log self.content
#      console.log '\n\n'
#      console.log "### href text get ok #{item} ###"
#
#      callback()
#
#  ,(eachErr) ->
#    if eachErr
#      return console.log eachErr
#
#    write = fs.createWriteStream(self.courseName + '/' + self.courseName + ".txt")
#    write.write self.content
#    console.log "#{self.courseName} abstract get ok"

#]

class DownCourse
  constructor: (@courseUrl) ->
    @courseName = 'ninghao'
    @href = []
    @content = ''

  getCourseList: (cb) ->
    self = @

    request.get self.courseUrl, (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load(body)
      if $(".course-info h1").length is 0
        cb("没有找到课程名，使用默认课程名 #{self.courseName}")
      else
        self.courseName = $(".course-info h1").text()
        console.log "找到课程名 #{self.courseName}"

      link = $("tr > td a")
      linkLen = link.length
      console.log "查找到得课程列表： #{linkLen}"
      unless linkLen
        return cb("奇怪怎么没有找到课程列表？")

      link.each (idx, element) ->
        self.href.push($(element).attr("href"))

      unless self.href.length
        return cb("奇怪，应该不会出现这情况吧, @href 为空？")

      console.log "### 获取课程列表 end ###"
      unless fs.existsSync(self.courseName)
        fs.mkdirSync(self.courseName)

      cb()


  getAbstract:(cb) ->
    self = @
    async.eachSeries self.href, (item, callback) ->

      request.get 'http://ninghao.net' + item, (err, res, body) ->
        return cb("get href error: #{item}") if err

        $ = cheerio.load(body)
        $title = $("#sidebar section div.box strong a")
        $pTag = $(".tab-content section .view-content > div p")
        if $title.length is 0
          return callback("get href no title:#{item}")

        if $pTag.length is 0
          return callback("get href no content: #{item}")

        self.content += $title.text() + '\n\n'
        for p, i in $pTag
          self.content += $(p).text() + '\n'
          if i == $pTag.length - 1
            self.content += '\n\n'



        console.log self.content
        console.log '\n\n'
        console.log "### href text get ok #{item} ###"

        callback()

    ,(eachErr) ->
      return cb(eachErr) if eachErr
      write = fs.createWriteStream(self.courseName + '/' + self.courseName + ".txt")
      write.write self.content
      console.log "### #{self.courseName} all do ###"
      cb()




#down = new DownCourse('http://ninghao.net/course/2000')
#async.series [
#  (cb) ->
#    down.getCourseList(cb)
#
#  (cb) ->
#    down.getAbstract(cb)
#  ]




class GetCourse
  constructor: (@starUrl = 'http://ninghao.net/course') ->

  getCourseUrl: (cb) ->
    request.get @starUrl, (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load(body)
      courseArr = $(".course-list .span4 > a")

      return cb("getCourseUrl没有发现链接") if not courseArr.length

      cb(null, courseArr)

  tryDown: (courseArr, cb) ->
    async.eachSeries courseArr, (item, callback) ->
      url = 'http://ninghao.net' + item.attribs.href
      console.log "tryDown url =>", url
      down = new DownCourse(url)

      down.getCourseList (err) ->
        return callback(err) if err
        down.getAbstract (err2) ->
          return callback(err2) if err2

          callback()

    ,(eachErr) ->
      return cb(eachErr) if eachErr

      console.log "### all page do ###"



class checkPage extends GetCourse
  constructor: (@startUrl = 'http://ninghao.net/course') ->
    @nextUrl = []
    @nextUrl.push(@startUrl)

    super


  getPageUrl: (cb) ->
    self = @

    request.get @startUrl, (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load(body)
      nextUrl = $("li.next a").attr('href')
      if nextUrl
        nextUrl = 'http://ninghao.net' + nextUrl
        self.nextUrl.push(nextUrl)
        self.startUrl = nextUrl
        self.getPageUrl(cb)
      else
        cb()










async.auto
  getPage:(cb) ->
    page = new checkPage('http://ninghao.net/course?page=1')
    page.getPageUrl (err) ->
      return cb(err) if err

      cb(null, page.nextUrl)

  downUrlList:['getPage', (cb, result) ->
    console.log "downUrlList here"
    urlArr = result.getPage

    async.eachSeries urlArr, (item, callback) ->
      down = new GetCourse(item)
      down.getCourseUrl (err1, courseArr) ->
        return callback(err1) if err1
        down.tryDown courseArr, (err2) ->
          return callback(err2) if err2

          callback()

    ,(eachErr) ->
      return cb(eachErr) if eachErr

      cb()

  ]

,(autoErr) ->
    return console.log autoErr if autoErr

    console.log "all page do"













#down = new GetCourse()
#down.getCourseUrl (err, courseArr) ->
#  return console.log err if err
#
#  down.tryDown courseArr, (err2) ->
#    if err2
#      return console.log err2






