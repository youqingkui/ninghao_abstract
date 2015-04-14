// Generated by CoffeeScript 1.8.0
(function() {
  var async, cheerio, down, fs, ninghao, request;

  request = require("request");

  async = require("async");

  fs = require("fs");

  cheerio = require("cheerio");

  ninghao = function(courseUrl) {
    this.courseUrl = courseUrl;
    this.courseName = 'ninghao.net';
    this.href = [];
    this.content = '';
  };

  ninghao.prototype.getCourseUrl = function(cb) {
    var self;
    self = this;
    return request.get(self.courseUrl, function(err, res, body) {
      var $, link, linkLen;
      if (err) {
        console.log("get course url error");
        return console.log(err);
      }
      $ = cheerio.load(body);
      if ($(".course-info h1").length === 0) {
        return console.log("没有找到课程名，使用默认课程名 " + self.courseName);
      } else {
        self.courseName = $(".course-info h1").text();
        console.log("找到课程名 " + self.courseName);
      }
      link = $("tr > td a");
      linkLen = link.length;
      console.log("查找到得课程列表： " + linkLen);
      if (!linkLen) {
        return console.log("奇怪怎么没有找到课程列表？");
      }
      link.each(function(idx, element) {
        return self.href.push($(element).attr("href"));
      });
      if (!self.href.length) {
        return console.log("奇怪，应该不会出现这情况吧, @href 为空？");
      }
      console.log("### 获取课程列表 end ###");
      if (!fs.existsSync(self.courseName)) {
        fs.mkdirSync(self.courseName);
      }
      return cb();
    });
  };

  ninghao.prototype.getHref = function() {
    var self;
    self = this;
    return async.eachSeries(self.href, function(item, callback) {
      return request.get('http://ninghao.net' + item, function(err, res, body) {
        var $, $pTag, $title, i, p, _i, _len;
        if (err) {
          console.log("get href error: " + item);
          return console.log(err);
        }
        $ = cheerio.load(body);
        $title = $("#sidebar section div.box strong a");
        $pTag = $(".tab-content section .view-content > div p");
        if ($title.length === 0) {
          return console.log("get href no title:" + item);
        }
        if ($pTag.length === 0) {
          return console.log("get href no content: " + item);
        }
        self.content += $title.text() + '\n\n';
        for (i = _i = 0, _len = $pTag.length; _i < _len; i = ++_i) {
          p = $pTag[i];
          self.content += $(p).text() + '\n';
          if (i === $pTag.length - 1) {
            self.content += '\n\n';
          }
        }
        console.log(self.content);
        console.log('\n\n');
        console.log("### href text get ok " + item + " ###");
        return callback();
      });
    }, function(eachErr) {
      var write;
      if (eachErr) {
        return console.log(eachErr);
      }
      write = fs.createWriteStream(self.courseName + '/' + self.courseName + ".txt");
      write.write(self.content);
      return console.log("" + self.courseName + " abstract get ok");
    });
  };

  down = new ninghao('http://ninghao.net/course/2034');

  async.series([
    function(cb) {
      return down.getCourseUrl(cb);
    }, function(cb) {
      return down.getHref();
    }
  ]);

}).call(this);

//# sourceMappingURL=app.js.map
