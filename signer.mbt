///|
fn hash_message(secret : String, timestamp : Int, body : String) -> Int {
  let hasher = Hasher(seed=17)
  hasher.combine_string(secret)
  hasher.combine_string(":")
  hasher.combine_int(timestamp)
  hasher.combine_string(":")
  hasher.combine_string(body)
  hasher.finalize()
}

///|
pub fn sign_demo(secret : String, timestamp : Int, body : String) -> String {
  "mh1:\{hash_message(secret, timestamp, body)}"
}

///|
pub fn verify_demo_signature(
  secret : String,
  timestamp : Int,
  body : String,
  signature : String,
) -> Bool {
  sign_demo(secret, timestamp, body) == signature
}
