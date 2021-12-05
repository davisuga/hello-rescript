open Express
open Cleaner

let app = expressCjs()
let port = 8081

let _ = app->listenWithCallback(port, _ => {
  Js.Console.log(`Listening on http://localhost:${port->Belt.Int.toString}`)
})

app->use(jsonMiddleware())
app->get("/", (_req, res) => {
  let _ = res->status(200)->json({"cleaner": whoWillCleanTheSandbox(Js.Date.make())})
})

let getSas = x => x["sas"]
