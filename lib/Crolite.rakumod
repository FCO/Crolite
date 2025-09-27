my %*SUB-MAIN-OPTS =
  :named-anywhere,             # allow named variables at any location
  :bundling,                   # allow bundling of named arguments
  :coerce-allomorphs-to(Int),  # coerce allomorphic arguments to given type
  :allow-no,                   # allow --no-foo as alternative to --/foo
  :numeric-suffix-as-value,    # allow -j2 as alternative to --j=2
;

my $CRO-ROUTE-SET;
class Crolite {
	use Cro;
	my proto MAIN(|) is export {
		$CRO-ROUTE-SET.definition-complete();
		my @before = $CRO-ROUTE-SET.before;
		my @after  = $CRO-ROUTE-SET.after;
		if @before || @after {
		    Cro.compose(|@before, $CRO-ROUTE-SET, |@after, :for-connection);
		}
		{*}
	}

	my multi MAIN("routes") {
		use Cro::HTTP::RouterUtils;
		my $endpoints = endpoints $CRO-ROUTE-SET;
		.gist.say for $endpoints.values
	}

	my multi MAIN("daemon", Str :$host = "0.0.0.0", UInt :$port = 10000) {
		use Cro::HTTP::Server;
		my Cro::Service $server = Cro::HTTP::Server.new:
			:$host,
			:$port,
			:application($*CRO-ROUTE-SET),
		;
		$server.start;
		say "Running server on http://{$host}:{$port}";
		react whenever signal(SIGINT) { $server.stop; exit }
	}

	my multi MAIN("GET",    |c) { MAIN "http", :method<get>,    |c }
	my multi MAIN("PUT",    |c) { MAIN "http", :method<put>,    |c }
	my multi MAIN("POST",   |c) { MAIN "http", :method<post>,   |c }
	my multi MAIN("DELETE", |c) { MAIN "http", :method<delete>, |c }

	my multi MAIN("http", Str $path, Str :$method ="get") {
		use Cro::HTTP::Test;
		test-service $CRO-ROUTE-SET, {
			with $*CRO-HTTP-TEST-CONTEXT -> $ctx {
				my $resp = await $ctx.client.request: $method.uc, $path;
				say await $resp.body
			}
		}
	}
}

sub EXPORT(--> Map()) {
	use Cro::HTTP::Router;
	PROCESS::<$CRO-ROUTE-SET> = $CRO-ROUTE-SET = Cro::HTTP::Router::RouteSet.new;
	do {
		use Cro::HTTP::Router;
		Cro::HTTP::Router::EXPORT::ALL::
	},
	do {
		use Cro::HTTP::RouterUtils;
		'&route'     => &route,
		'&endpoints' => &endpoints,
	}
}

=begin pod

=head1 NAME

Crolite - Lightweight Cro routing + tiny CLI wrapper

=head1 SYNOPSIS

=begin code :lang<raku>
use Crolite;

get -> $a {          # /<anything>
    content 'text/plain', 'worked';
}

delete -> 'something', Int $var {   # /something/<int>
    content 'application/json', %( :$var );
}
=end code

List routes:

=begin code :lang<bash>
raku example.raku routes
=end code

Run a dev server:

=begin code :lang<bash>
raku example.raku daemon --port=3000
=end code

Test a route ad-hoc:

=begin code :lang<bash>
raku example.raku GET /something/42
=end code

=head1 DESCRIPTION

Crolite removes boilerplate when hacking together small Cro HTTP examples. Importing it allocates a fresh `Cro::HTTP::Router::RouteSet` (stored in PROCESS scope) and exports the usual Cro routing helpers along with a multi `MAIN` providing:

=item C<routes> — print collected endpoint signatures.

=item C<daemon> — start a `Cro::HTTP::Server` with your route set (Ctrl+C to stop).

=item C<GET|POST|PUT|DELETE <path>> — perform a single in-memory request using Cro::HTTP::Test.

=item C<http <path> --method=<verb>> — generic form accepting any method string.

=head2 Goals

=item Rapid prototyping / teaching.

=item Introspection of defined routes without extra code.

=item Preserve native Cro primitives (no bespoke DSL).

=head2 Caveats

=item Early sketch; API may shift.

=item Thin error handling; exceptions surface directly.

=item Not a full project scaffold (logging/TLS/config left to Cro proper).

=head1 AUTHOR

Fernando Corrêa de Oliveira <fco@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
