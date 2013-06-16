module Dkim_Filter_Keylist =

autoload xfm

let eol = Util.eol
let indent = Util.indent

(* For the control syntax of [key=value ..] we could split the key value *)
(* pairs into an array and generate a subtree control/N/KEY = VALUE      *)
let control = /(\[[^]#\n]*\]|[^[ \t][^ \t]*)/
let word = /[^:# \t\n]+/

let colon = Util.del_str ":"

let comment = Util.comment
let comment_or_eol = Util.comment_or_eol
let empty   = Util.empty

let record = [ seq "record" . indent .
               [ label "sender-pattern" . store word ] .
               colon .
               [ label "domain" . store word ] .
               colon .
               [ label "keyfile" . store word ] .
               eol
             ]

(* Define lens *)
let lns = (Util.empty | Util.comment | record)*

let filter = incl "/etc/dkim-filter.d/keys.conf"
              . Util.stdexcl

let xfm = transform lns filter

