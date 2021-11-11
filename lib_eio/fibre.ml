open EffectHandlers

type _ eff += Fork : (unit -> 'a) -> 'a Promise.t eff

let fork ~sw ~exn_turn_off f =
  let f () =
    Switch.with_op sw @@ fun () ->
    try f ()
    with ex ->
      if exn_turn_off then Switch.turn_off sw ex;
      raise ex
  in
  perform (Fork f)

type _ eff += Fork_ignore : (unit -> unit) -> unit eff

let fork_ignore ~sw f =
  let f () =
    Switch.with_op sw @@ fun () ->
    try
      Cancel.protect_full @@ fun c ->
      let hook = Switch.add_cancel_hook sw (Cancel.cancel c) in
      Fun.protect f
        ~finally:(fun () -> Hook.remove hook)
    with ex ->
      Switch.turn_off sw ex
  in
  perform (Fork_ignore f)

let yield () =
  let c = ref Cancel.boot in
  Suspend.enter (fun fibre enqueue ->
      c := fibre.cancel;
      enqueue (Ok ())
    );
  Cancel.check !c

let both f g =
  Cancel.sub @@ fun cancel ->
  let f () =
    try f ()
    with ex -> Cancel.cancel cancel ex; raise ex
  in
  let x = perform (Fork f) in
  match g () with
  | () -> Promise.await x               (* [g] succeeds - just report [f]'s result *)
  | exception gex ->
    Cancel.cancel cancel gex;
    match Cancel.protect (fun () -> Promise.await_result x) with
    | Ok () | Error (Cancel.Cancelled _) -> raise gex    (* [g] fails, nothing to report for [f] *)
    | Error fex ->
      match gex with
      | Cancel.Cancelled _ -> raise fex                         (* [f] fails, nothing to report for [g] *)
      | _ -> raise (Multiple_exn.T [fex; gex])                  (* Both fail *)

let fork_sub_ignore ?on_release ~sw ~on_error f =
  let did_attach = ref false in
  fork_ignore ~sw (fun () ->
      try Switch.run (fun sw -> Option.iter (Switch.on_release sw) on_release; did_attach := true; f sw)
      with ex ->
        try on_error ex
        with ex2 ->
          Switch.turn_off sw ex;
          Switch.turn_off sw ex2
    );
  if not !did_attach then (
    Option.iter Cancel.protect on_release;
    Switch.check sw;
    assert false
  )
