fn main() {
  extern crate reqwest;
  use std::io;

  let endpoint = "https://api.github.com/repos/chaspy/favsearch/issues";
  let mut res = reqwest::get(endpoint).unwrap();
  res.copy_to(&mut io::stdout()).unwrap();
}
