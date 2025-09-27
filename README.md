[![Actions Status](https://github.com/FCO/Crolite/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/Crolite/actions)

NAME
====

Crolite - Lightweight Cro routing + tiny CLI wrapper

SYNOPSIS
========

```raku
use Crolite;

get -> $a {          # /<anything>
    content 'text/plain', 'worked';
}

delete -> 'something', Int $var {   # /something/<int>
    content 'application/json', %( :$var );
}
```

List routes:

```bash
raku example.raku routes
```

Run a dev server:

```bash
raku example.raku daemon --port=3000
```

Test a route ad-hoc:

```bash
raku example.raku GET /something/42
```

DESCRIPTION
===========

Crolite removes boilerplate when hacking together small Cro HTTP examples. Importing it allocates a fresh `Cro::HTTP::Router::RouteSet` (stored in PROCESS scope) and exports the usual Cro routing helpers along with a multi `MAIN` providing:

  * `routes` — print collected endpoint signatures.

  * `daemon` — start a `Cro::HTTP::Server` with your route set (Ctrl+C to stop).

  * `GET|POST|PUT|DELETE <path>` — perform a single in-memory request using Cro::HTTP::Test.

  * `http <path> --method=<verb>` — generic form accepting any method string.

Goals
-----

  * Rapid prototyping / teaching.

  * Introspection of defined routes without extra code.

  * Preserve native Cro primitives (no bespoke DSL).

Caveats
-------

  * Early sketch; API may shift.

  * Thin error handling; exceptions surface directly.

  * Not a full project scaffold (logging/TLS/config left to Cro proper).

AUTHOR
======

Fernando Corrêa de Oliveira <fco@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

