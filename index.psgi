use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::App::URLMap;
use Plack::Middleware::AutoRefresh;
use Plack::App::File;

use AnyEvent::Filesys::Notify;

### Watch file changes in caml and render new static
my $notifier = AnyEvent::Filesys::Notify->new(
	dirs     => [ qw( caml/ ) ],
	interval => 2.0,             # Optional depending on underlying watcher
	filter   => sub { shift !~ /\.(pod)$/ },
	cb       => sub {
		my (@events) = @_;
		for my $event (@events){
			print "Template changed: ".$event->path."\n";
		}

		`perl caml/render.pl`; # render new static
	},
	parse_events => 1,  # Improves efficiency on certain platforms
);

### Run server with reloading
builder {
	enable 'Plack::Middleware::AutoRefresh',
			   dirs => [ qw/static/ ];
	mount "/" => Plack::App::File->new(root => "static/");
}