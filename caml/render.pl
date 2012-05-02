#!/usr/bin/perl

use utf8;
use strict;
use warnings;

use FindBin;
use Text::Caml;
use File::Slurp;
use File::Spec;
use Data::Dumper;

my $base_title = 'Brno Perl Mongers';
my $pages_conf = {
	'index' => {
		title => $base_title,
		main_page => 1,              # only base title
		menu_pos => 1,
		menu_path => './',
		menu_title => 'Aktuálně',
	},
	'brno-pm' => {
		title => 'Brno PM',
		menu_pos => 2,
	},
	'projekty' => {
		title => 'Projekty',
		menu_pos => 3,
	},
	'lide' => {
		title => 'Lidé',
		menu_pos => 4,
	},
	'kontakt' => {
		title => 'Kontakt',
		menu_pos => 5,
	},
};


sub render_menu_html {
	my ( $menu_conf, $page_base_name ) = @_;
	
	my $html = '';
	foreach my $mconf ( @$menu_conf ) {
		my $active_html = ( $mconf->{base_name} eq $page_base_name.'.html' )
			? ' class="active"'
			: ''
		;
		$html .= '<li' . $active_html . '><a href="' . $mconf->{path} . '">' . $mconf->{title}  . '</a></li>';
	}
	return $html;
}


sub prepare_menu_conf {
	my ( $pages_conf ) = @_;

	# Prepare menu configuration.
	my $menu_conf = [];
	my @menu_sorted_keys = 
		sort { $pages_conf->{$a}{menu_pos} <=> $pages_conf->{$b}{menu_pos} } 
		grep { exists $pages_conf->{$_}{menu_pos} }
		keys %$pages_conf;
	;
	foreach my $page_base_name ( @menu_sorted_keys ) {
		my $pconf = $pages_conf->{ $page_base_name };
		push @$menu_conf, {
			base_name => $page_base_name,
			path => $pconf->{menu_path} || $page_base_name.'.html',
			title => $pconf->{menu_title} || $pconf->{title},
		}
	}
	return $menu_conf;
}

my $menu_conf = prepare_menu_conf( $pages_conf );
#print Dumper( $menu_conf ); # debug


binmode STDOUT, ':utf8';

my $out_dir = File::Spec->catdir( $FindBin::RealBin, '../static' );
my $template_dir = File::Spec->catdir( $FindBin::RealBin, 'template' );
my $view = Text::Caml->new( templates_path => $template_dir );

my $title_suffix = ' - ' . $base_title;
foreach my $page_base_name ( keys %$pages_conf ) {
	my $pconf = $pages_conf->{ $page_base_name };
	my $title = $pconf->{title};
	$title .= $title_suffix unless $pconf->{main_page};
	
	print "Rendering $page_base_name\n";
	print "  title: '$title'\n";
	my $main_html = $view->render_file($page_base_name.'.tpl');
	my $html = $view->render_file( 'inc/html.tpl', { 
		head_title => $title,
		main_html => $main_html,
		menu_items_html => render_menu_html( $menu_conf, $page_base_name ),
	} );
	#print " html: '$html'\n"; exit; # debug
	
	my $out_fpath = File::Spec->catfile( $out_dir, $page_base_name.'.html' );
	print "  output file path: '$out_fpath'\n";
	File::Slurp::write_file( $out_fpath, { binmode => ':utf8' }, $html );
	print "  done\n";
}

