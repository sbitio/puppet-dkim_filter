module Test_Dkim_Filter_Hostsnetslist = 

(* TO-DO: add validations for mor cases*)
  let conf = "127.0.0.1
127.0.0.1/32

localhost
localhost.localdomain
192.168.1.90
192.168.1.0/24
!127.0.0.1/32
"

  test Dkim_Filter_Hostsnetslist.lns get conf =
    { "1" = "127.0.0.1" }
    { "2" = "127.0.0.1/32" }
    {}
    { "3" = "localhost" }
    { "4" = "localhost.localdomain" }
    { "5" = "192.168.1.90" }
    { "6" = "192.168.1.0/24"}
    { "7" = "!127.0.0.1/32" }