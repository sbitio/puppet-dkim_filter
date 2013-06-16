module Dkim_Filter_Hostsnetslist =

autoload xfm

let eol = Util.eol
let indent = Util.indent

let control = /(\[[^]#\n]*\]|[^[ \t][^ \t]*)/

(* Original regex from http://blog.markhatton.co.uk/2011/03/15/regular-expressions-for-ip-addresses-cidr-ranges-and-hostnames/ *)
(* See: http://augeas.net/docs/references/lenses/files/rx-aug.html#Rx.ipv4 *)
(* TO-DO: make a prettier implementation with subregex *)
(* TO-DO: validate v6 regex *)
let ip_v4_regex = /(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/
let cidr_v4_regex = ip_v4_regex . /(\/([0-9]|[1-2][0-9]|3[0-2]))/
let ip_v6_regex = /((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:)))/
let cidr_v6_regex = ip_v6_regex . /(\/([0-9]|[0-9][0-9]|1[0-1][0-9]|12[0-8]))/
let hostname_regex = /(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])/
let allow_negation = /[!]?/
let combined_regex = allow_negation . (ip_v4_regex | cidr_v4_regex | ip_v6_regex | cidr_v6_regex | hostname_regex)

(*
let _ = print_endline "ip_v4_regex:"
let _ = print_regexp ip_v4_regex
let _ = print_endline ""
let _ = print_endline "cidr_v4_regex:"
let _ = print_regexp cidr_v4_regex
let _ = print_endline ""
let _ = print_endline "ip_v6_regex:"
let _ = print_regexp ip_v6_regex
let _ = print_endline ""
let _ = print_endline "cidr_v6_regex:"
let _ = print_regexp cidr_v6_regex
let _ = print_endline ""
let _ = print_endline "hostname_regex:"
let _ = print_regexp hostname_regex
let _ = print_endline ""
let _ = print_endline "combined_regex:"
let _ = print_regexp combined_regex
let _ = print_endline ""
let _ = print_endline "eol:"
let _ = print_regexp (lens_ctype eol)
let _ = print_endline ""
*)

let item = [ seq "record" . indent . store combined_regex ] . eol

(*

let hostname_regex = /(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])/
let hostname = store hostname_regex

let negation_regex = /[!]/
let item = store ip_or_cidr_addr . eol
let negation = [ store negation_regex ]
let item = [negation? . (hostname | ip_or_cidr_addr)] . Util.empty . eol
*)

(* Define lens *)
(* let lns = (Util.empty | Util.comment | item)* *)
let lns = (Util.empty | item)*

let filter = incl "/etc/dkim-filter.d/peers.conf"
              . incl "/etc/dkim-filter.d/external-ignore.conf"
              . Util.stdexcl

let xfm = transform lns filter

