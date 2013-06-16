module Dkim_Filter_Conf =

autoload xfm

let eol = Util.eol
let indent = Util.indent

(* For the control syntax of [key=value ..] we could split the key value *)
(* pairs into an array and generate a subtree control/N/KEY = VALUE      *)
let control = /(\[[^]#\n]*\]|[^[ \t][^ \t]*)/
let word = /[^# \t\n]+/

let comment = Util.comment
let comment_or_eol = Util.comment_or_eol
let empty   = Util.empty

let record = [ seq "record" . indent .
               [ label "key" . store word ] .
               Util.del_ws_tab .
               [ label "value" . store word ] .
               comment_or_eol
             ]

(* Define lens *)
let lns = (Util.empty | Util.comment | record)*

let filter = incl "/etc/dkim-filter.conf"
              . Util.stdexcl

let xfm = transform lns filter

