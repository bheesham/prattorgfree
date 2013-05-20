http = require("http")
url = require("url")
director = require("director")
Sequelize = require("sequelize")

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
    return this.res.end(JSON.stringify({error: "invalid request, no slander message."}))

  # if an image exists, validate
  if (this.req.body.image and this.req.body.image? and !this.req.body.image.match("/(http|https):\/\/i\.imgur\.com\/([a-z0-9]+)\.(jpg|jpeg|png|gif)/i"))
    return this.res.end(JSON.stringify({error: "invalid request, invalid imgur url."}))
  else
    this.req.body.image = ""

  # validation over, insert, return, ???, profit
  Messages.create(
    message: this.req.body.message
    image: this.req.body.image
  ).success(() ->
    res.end(JSON.stringify({success: "you've made simon sad. congratulations."}))
  ).error((e) ->
    res.end(JSON.stringify({error: "welp. there was a database error. you should try to submit your message again in a few minutes."}))
  )

retrieve_slander = () ->
  res = this.res
  this.res.writeHead(200,
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
      res.end(JSON.stringify(
        error: "no more content."
      ))  
  ).error((e) ->
    res.end(JSON.stringify(
      error: "no more content."
    ))
  )

router = new director.http.Router(
  '/submit':
    post: submit_slander
)

router.get(/\/retrieve/, retrieve_slander)

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