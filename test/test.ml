let print_ints iter = iter (fun x -> Printf.printf "%d " x)
let iter_of_list l k = List.iter k l

let%expect_test "" =
  print_ints
    (Top_k.top_k
       (module Int)
       3
       (iter_of_list [ 0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ]));
  [%expect {| 8 9 10 |}]

let%expect_test "" =
  print_ints
    (Top_k.top_k_distinct
       (module Int)
       (module struct
         type t = int

         let hash = Hashtbl.hash
         let equal = ( = )
       end)
       3
       (iter_of_list [ 6; 1; 2; 3; 1; 5; 6 ]));
  [%expect
    {|
      3 6 5 |}]
