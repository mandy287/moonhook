///|
fn normalize_header_name(name : StringView) -> String {
  let out = StringBuilder(size_hint=name.iter().count())
  for ch in name.iter() {
    out.write_char(ch.to_ascii_lowercase())
  }
  out.to_string()
}

///|
fn parse_request_line(
  line : StringView,
) -> Result[(String, String), MoonHookError] {
  let parts = line.to_owned().split(" ").to_array()
  if parts.length() < 2 {
    return Err({ stage: "http", message: "invalid request line" })
  }
  Ok((parts[0].to_owned(), parts[1].to_owned()))
}

///|
pub fn parse_http_request(raw : String) -> Result[HttpRequest, MoonHookError] {
  let (head, body) = match raw.split_once("\r\n\r\n") {
    Some(parts) => parts
    None =>
      return Err({ stage: "http", message: "request missing header terminator" })
  }
  let lines = head.to_owned().split("\r\n").to_array()
  if lines.is_empty() {
    return Err({ stage: "http", message: "request missing request line" })
  }
  let (verb, path) = match parse_request_line(lines[0]) {
    Ok(parts) => parts
    Err(error) => return Err(error)
  }
  let headers : Map[String, String] = Map([])
  for line in lines[1:] {
    match line.split_once(":") {
      Some((name, value)) =>
        headers[normalize_header_name(name)] = value.trim().to_owned()
      None => ()
    }
  }
  Ok({ verb, path, headers, body: body.to_owned() })
}
