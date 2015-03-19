requires 'perl', '5.008005';
requires 'Text::Caml', 0;
requires 'File::Slurp', 0;
requires 'File::Spec', 0;

on 'develop' => sub {
	requires 'Plack', '0.9910';
	requires 'Plack::App::URLMap', 0,
	requires 'Plack::Builder', 0,
	requires 'Plack::App::File', 0,
	requires 'Plack::Middleware::AutoRefresh', 0,
	requires 'Twiggy', 0,
	requires 'AnyEvent::Filesys::Notify', 0,
};
