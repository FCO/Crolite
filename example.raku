use Crolite;

get -> $a {
  content "text/plain", "worked"
}

delete -> "something", Int $var {
  content "application/json", %( :$var )
}
