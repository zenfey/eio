(lang dune 3.7)
(name eio)
(formatting disabled)
(generate_opam_files true)
(source (github ocaml-multicore/eio))
(license ISC)
(authors "Anil Madhavapeddy" "Thomas Leonard")
(maintainers "anil@recoil.org")
(documentation "https://ocaml-multicore.github.io/eio/")
(package
 (name eio)
 (synopsis "Effect-based direct-style IO API for OCaml")
 (description "An effect-based IO API for multicore OCaml with fibers.")
 (conflicts
  (ocaml-base-compiler (< 5.0.0~beta1))
  (ocaml-variants (< 5.0.0~beta1))
  (ocaml-system (< 5.0.0~beta1))
  (seq (< 0.3)))
 (depends
  (ocaml (>= 5.0.0))
  (bigstringaf (>= 0.9.0))
  (cstruct (>= 6.0.1))
  lwt-dllist
  (optint (>= 0.1.0))
  (psq (>= 0.2.0))
  (fmt (>= 0.8.9))
  (hmap (>= 0.8.1))
  (crowbar (and (>= 0.2) :with-test))
  (mtime (>= 2.0.0))
  (mdx (and (>= 2.2.0) :with-test))
  (alcotest (and (>= 1.4.0) :with-test))
  (dscheck (and (>= 0.1.0) :with-test))))
(package
 (name eio_linux)
 (synopsis "Eio implementation for Linux using io-uring")
 (description "An Eio implementation for Linux using io-uring.")
 (allow_empty)  ; Work-around for dune bug #6938
 (depends
  (alcotest (and (>= 1.4.0) :with-test))
  (eio (= :version))
  (mdx (and (>= 2.2.0) :with-test))
  (logs (>= 0.7.0))
  (fmt (>= 0.8.9))
  (cmdliner (and (>= 1.1.0) :with-test))
  (uring (>= 0.5))))
(package
 (name eio_posix)
 (synopsis "Eio implementation for POSIX systems")
 (description "An Eio implementation for most Unix-like platforms")
 (depends
  (eio (= :version))
  (iomux (>= 0.2))
  (mdx (and (>= 2.2.0) :with-test))
  (fmt (>= 0.8.9))))
(package
 (name eio_luv)
 (synopsis "Eio implementation using luv (libuv)")
 (description "An Eio implementation for most platforms, using luv.")
 (depends
  (eio (= :version))
  (luv (>= 0.5.11))
  (luv_unix (>= 0.5.0))
  (mdx (and (>= 2.2.0) :with-test))
  (fmt (>= 0.8.9))))
(package
 (name eio_main)
 (synopsis "Effect-based direct-style IO mainloop for OCaml")
 (description "Selects an appropriate Eio backend for the current platform.")
 (depopts eio_luv)
 (depends
  (mdx (and (>= 2.2.0) :with-test))
  (eio_linux (and (= :version) (= :os "linux")))
  (eio_posix (and (= :version) (<> :os "windows")))
  (eio_luv (and (= :version) (or (= :os "windows") :with-test)))))
(using mdx 0.2)
