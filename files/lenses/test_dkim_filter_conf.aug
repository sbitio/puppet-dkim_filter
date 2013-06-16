module Test_dkim_filter_conf = 

  let conf = "# a comment
#another comment
key1 value1
key2    value2 #inline comment

#one more comment
key3            value3
"

  test Dkim_Filter_Conf.lns get conf =
    { "#comment" = "a comment" }
    { "#comment" = "another comment" }
    { "1"
      { "key" = "key1" }
      { "value" = "value1"}
    }
    { "2"
      { "key" = "key2" }
      { "value" = "value2"}
      { "#comment" = "inline comment" }
    }
    {}
    { "#comment" = "one more comment" }
    { "3"
      { "key" = "key3" }
      { "value" = "value3"}
    }