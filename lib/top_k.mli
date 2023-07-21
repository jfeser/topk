module type Comparable = sig
  type t

  val compare : t -> t -> int
end

type 'a iter = ('a -> unit) -> unit

val top_k : (module Comparable with type t = 't) -> int -> 't iter -> 't iter
(** [top_k cmp k iter] returns the top [k] elements of [iter] according to
    [cmp]. *)

val top_k_distinct :
  (module Comparable with type t = 't) ->
  (module Hashtbl.HashedType with type t = 't) ->
  int ->
  't iter ->
  't iter
(** [top_k_distinct] is like [top_k] but it only returns distinct elements. *)
