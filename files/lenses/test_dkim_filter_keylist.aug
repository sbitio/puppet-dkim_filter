module Test_Dkim_Filter_Keylist = 

  let conf = "# a comment
#another comment
*@example.org:example.org:/etc/dkim-keys/selector
*@example.com:example.com:/etc/dkim-keys/selector2

#one more comment
*@example.net:example.net:/etc/dkim-keys/selector
"

  test Dkim_Filter_Keylist.lns get conf =
    { "#comment" = "a comment" }
    { "#comment" = "another comment" }
    { "1"
      { "sender-pattern" = "*@example.org" }
      { "domain" = "example.org"}
      { "keyfile" = "/etc/dkim-keys/selector"}
    }
    { "2"
      { "sender-pattern" = "*@example.com" }
      { "domain" = "example.com"}
      { "keyfile" = "/etc/dkim-keys/selector2"}
    }
    {}
    { "#comment" = "one more comment" }
    { "3"
      { "sender-pattern" = "*@example.net" }
      { "domain" = "example.net"}
      { "keyfile" = "/etc/dkim-keys/selector"}
    }