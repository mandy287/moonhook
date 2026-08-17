///|
fn usage() -> Unit {
  println(
    (
      #|MoonHook v\{@moonhook.version}
      #|
      #|用法：moonhook <命令>
      #|
      #|命令：
      #|  demo         运行通用 webhook 处理演示
      #|  inspect      输出 GitHub 风格请求解析结果
      #|  replay       演示去重与重放流程
      #|  github-demo  运行 GitHub 风格适配 demo
      #|
      #|选项：
      #|  -h, --help   显示帮助
      #|  -V, --version 显示版本
    ),
  )
}

///|
fn format_handlers(handlers : Array[String]) -> String {
  let out = StringBuilder()
  for index = 0; index < handlers.length(); index = index + 1 {
    if index > 0 {
      out.write_string(", ")
    }
    out.write_string(handlers[index])
  }
  out.to_string()
}

///|
fn print_report(report : @moonhook.DispatchReport) -> Unit {
  println("provider: \{report.provider}")
  println("event: \{report.event_name}")
  println("delivery: \{report.delivery_id}")
  println("duplicate: \{report.duplicate}")
  println("handlers: \{format_handlers(report.handlers)}")
  println("payload:")
  println(report.payload_preview)
}

///|
fn run_demo() -> Unit {
  let config = @moonhook.VerificationConfig::default()
  let routes = @moonhook.demo_routes()
  let seen : Map[String, Bool] = Map([])
  let request = @moonhook.sample_generic_request(config.secret)
  match @moonhook.handle_generic(routes, seen, request, config) {
    Err(error) => println(error.to_string())
    Ok(report) => print_report(report)
  }
}

///|
fn run_inspect() -> Unit {
  let config = @moonhook.VerificationConfig::default()
  let request = @moonhook.sample_github_request(config.secret)
  match @moonhook.parse_github_demo(request, config) {
    Err(error) => println(error.to_string())
    Ok(event) => {
      println("provider: \{event.provider}")
      println("event: \{event.event_name}")
      println("delivery: \{event.delivery_id}")
      println("timestamp: \{event.timestamp}")
      println("signature: \{event.signature}")
      println("payload:")
      println(event.payload.stringify(indent=2))
    }
  }
}

///|
fn run_replay() -> Unit {
  let config = @moonhook.VerificationConfig::default()
  let routes = @moonhook.demo_routes()
  let seen : Map[String, Bool] = Map([])
  let request = @moonhook.sample_generic_request(config.secret)
  for attempt in [1, 2] {
    println("attempt \{attempt}")
    match @moonhook.handle_generic(routes, seen, request, config) {
      Err(error) => println(error.to_string())
      Ok(report) => print_report(report)
    }
  }
}

///|
fn run_github_demo() -> Unit {
  let config = @moonhook.VerificationConfig::default()
  let routes = @moonhook.demo_routes()
  let seen : Map[String, Bool] = Map([])
  let request = @moonhook.sample_github_request(config.secret)
  match @moonhook.handle_github_demo(routes, seen, request, config) {
    Err(error) => println(error.to_string())
    Ok(report) => print_report(report)
  }
}

///|
fn main {
  let args : Array[String] = @env.args()
  if args.length() < 2 || args[1] == "-h" || args[1] == "--help" {
    usage()
    return
  }
  if args[1] == "-V" || args[1] == "--version" {
    println(@moonhook.version)
    return
  }
  match args[1] {
    "demo" => run_demo()
    "inspect" => run_inspect()
    "replay" => run_replay()
    "github-demo" => run_github_demo()
    _ => usage()
  }
}
