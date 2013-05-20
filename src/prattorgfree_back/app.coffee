http = require("http")
url = require("url")
director = require("director")
Sequelize = require("sequelize")
htmlencode = require("htmlencode")

admin_password = "12345"

htmlencode.EncodeType = "numerical"

sql = new Sequelize("prattorgfree", "postgres", "12345",
  host: "localhost"
  port: 5432
  dialect: "postgres",
  define:
    underscored: true
  logging: false
)

Messages = sql.define("messages", {
  message: 
    allowNull: false
    type: Sequelize.TEXT
    validate:
      notEmpty: true
  image: 
    defaultValue: ""
    allowNull: false
    type: Sequelize.TEXT
    validate:
      isUrl: true
  approved:
      allowNull: false
      type: Sequelize.BOOLEAN
      defaultValue: false
  }, {
    paranoid: false
    underscored: true
  }
)

submit_slander = () ->
  res = this.res
  res.writeHead(200,
    "Content-Type": "application/json"
    "charset": "utf8"
  )

  if (!this.req.body.message or !this.req.body.message?)
    return res.end(JSON.stringify({error: "invalid request, no slander message."}))

  # if an image exists, validate
  if (this.req.body.image and this.req.body.image?)
    if (!this.req.body.image.match("(http|https):\/\/i\.imgur\.com\/([a-zA-Z0-9]+)\.(jpg|jpeg|png|gif)"))
      return res.end(JSON.stringify({error: "invalid request, invalid imgur url."}))
  else
    this.req.body.image = ""

  # validation over, insert, return, ???, profit
  Messages.create(
    message: htmlencode.htmlEncode(this.req.body.message)
    image: this.req.body.image
  ).success(() ->
    res.end(JSON.stringify({success: "you've made simon sad. congratulations."}))
  ).error((e) ->
    res.end(JSON.stringify({error: "welp. there was a database error. you should try to submit your message again in a few minutes."}))
  )

retrieve_slander = () ->
  res = this.res
  res.writeHead(200,
    "Content-Type": "text/plain"
    "charset": "utf8"
  )

  sql.query("SELECT message, image FROM messages WHERE approved = true ORDER BY RANDOM() LIMIT 1").success((result) ->
    if (result.length > 0)
      res.end(JSON.stringify(
        message: result[0].message
        image: result[0].image
      ))
    else 
      res.end(JSON.stringify({error: "no more content."}))  
  ).error(() ->
    res.end(JSON.stringify({error: "no more content."}))
  )

retrieve_pending_slander = () ->
  res = this.res
  res.writeHead(200,
    "Content-Type": "text/plain"
    "charset": "utf8"
  )
  password = url.parse(this.req.url, true).query.password
  
  if !(password is admin_password)
    return res.end(JSON.stringify({error: "invalid password."}))

  # Now list 10 pending messages
  Messages.findAll(
    where: 
      approved: false
    limit: 10
  ).success((messages) ->
    res.end(JSON.stringify({messages: messages}))
  ).error(() ->
    res.end(JSON.stringify({error: "no more content."}))
  )

submit_pending_slander = () ->
  res = this.res
  res.writeHead(200,
    "Content-Type": "application/json"
    "charset": "utf8"
  )

  if !(this.req.body.password is admin_password)
    return res.end(JSON.stringify({error: "invalid password."}))

  if (!this.req.body.action or !this.req.body.action?)
    return res.end(JSON.stringify({error: "inalid request, select an action."}))

  # we need a number, and nothing else from the id
  if (!this.req.body.id.match("([0-9]+)"))
    return res.end(JSON.stringify({error: "invalid message id."}))    

  if (this.req.body.action == "accept")
    sql.query("UPDATE messages SET approved = true WHERE id = " + this.req.body.id).success(() ->
      return res.end(JSON.stringify({success: "accepted that message."}))
    ).error(() ->
      return res.end(JSON.stringify({error: "could not accept that message."}))
    )
  else if (this.req.body.action == "delete")
    sql.query("DELETE FROM messages WHERE id = " + this.req.body.id).success(() ->
      return res.end(JSON.stringify({success: "deleted that message."}))
    ).error(() ->
      return res.end(JSON.stringify({error: "could not delete that message."}))
    )
  else
    return res.end(JSON.stringify({error: "woah, you can't just make up new actions."}))    

router = new director.http.Router(
  '/back/submit':
    post: submit_slander
  '/back/retrieve':
    get: retrieve_slander
  '/back/admin':
    get: retrieve_pending_slander
    post: submit_pending_slander
)

server = http.createServer((req, res) ->
  req.chunks = [];
  req.on("data", (chunk) ->
    req.chunks.push(chunk.toString())
  );

  router.dispatch(req, res, (err) ->
    if (err)
      res.writeHead(404)
      res.end()
  )
)

# Start the server after syncing
Messages.sync().success(() ->
  server.listen(5666)
).failure((e)->
  console.log(e)
)