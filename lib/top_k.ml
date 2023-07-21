let compare = `Shadowed_stdlib_compare
let value_exn = function Some x -> x | None -> failwith "value_exn"

module type Comparable = sig
  type t

  val compare : t -> t -> int
end

module Option_comparable (Cmp : Comparable) :
  Comparable with type t = Cmp.t option = struct
  type t = Cmp.t option

  let compare x y =
    match (x, y) with
    | None, None -> 0
    | None, Some _ -> 1
    | Some _, None -> -1
    | Some x, Some y -> Cmp.compare x y
end

let top_k (type t) (module Cmp : Comparable with type t = t) k l f =
  let module H = Binary_heap.Make (Option_comparable (Cmp)) in
  assert (k >= 0);
  if k > 0 then (
    let mins = H.create ~dummy:None k in
    l (fun x ->
        if H.length mins < k then H.add mins (Some x)
        else
          let c = Cmp.compare (value_exn @@ H.minimum mins) x in
          if c < 0 || (c = 0 && Random.bool ()) then (
            ignore (H.pop_minimum mins : t option);
            H.add mins (Some x)));
    H.iter (fun x -> f (value_exn x)) mins)

let top_k_distinct (type t) (module Cmp : Comparable with type t = t)
    (module Hash : Hashtbl.HashedType with type t = t) k l f =
  let module H = Binary_heap.Make (Option_comparable (Cmp)) in
  let module HS = Hashtbl.Make (Hash) in
  assert (k >= 0);
  if k > 0 then (
    let best = H.create ~dummy:None k in
    let contents = HS.create k in
    let add x =
      H.add best (Some x);
      HS.add contents x ()
    in
    l (fun x ->
        if not (HS.mem contents x) then
          if H.length best < k then add x
          else
            let min_val = value_exn @@ H.minimum best in
            let c = Cmp.compare min_val x in
            if c < 0 || (c = 0 && Random.bool ()) then (
              ignore (H.pop_minimum best : _ option);
              HS.remove contents min_val;
              add x));
    H.iter (fun x -> f (value_exn x)) best)
