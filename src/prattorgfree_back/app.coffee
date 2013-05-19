http = require("http")
director = require("director")

used_get = () ->
  this.res.writeHead(404,
    "Content-Type": "text/plain"
    "charset": "utf8"
  )
  this.res.end("invalid request")

submit_slander = () ->
  this.res.writeHead(200,
    "Content-Type": "application/json"
    "charset": "utf8"
  )

  if (!this.req.body)
    this.res.end(JSON.stringify({error: "error"}))
    return
  this.res.end(JSON.stringify(this.req.body))

router = new director.http.Router(
  '/submit':
    get: used_get
    post: submit_slander
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

server.listen(5666)