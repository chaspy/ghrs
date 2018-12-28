fn main() {
  extern crate reqwest;
  use std::io;

  let endpoint = "https://api.github.com".to_string();
  let org = "chaspy";
  let repo = "favsearch";
  let url = endpoint + "/" + "repos" + "/" + org + "/" + repo + "/" + "issues";

  let mut res = reqwest::get(&*url).unwrap();
  res.copy_to(&mut io::stdout()).unwrap();
}
