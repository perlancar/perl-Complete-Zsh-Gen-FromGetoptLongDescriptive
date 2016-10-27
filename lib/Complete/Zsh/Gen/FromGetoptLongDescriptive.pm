package Complete::Zsh::Gen::FromGetoptLongDescriptive;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       gen_zsh_complete_from_getopt_long_descriptive_script
                       gen_zsh_complete_from_getopt_long_descriptive_spec
               );

$SPEC{gen_zsh_complete_from_getopt_long_descriptive_spec} = {
    v => 1.1,
    summary => 'From Getopt::Long::Descriptive spec, generate tab completion '.
        'script for the zsh shell',
    description => <<'_',

This routine generate zsh completion script for each short/long option, enabling
zsh to be aware of each option.

_
    args => {
        spec => {
            summary => 'Getopt::Long::Descriptive specification',
            schema => 'array*',
            req => 1,
            pos => 0,
        },
        cmdname => {
            summary => 'Command name to be completed',
            schema => 'str*',
            req => 1,
        },
        compname => {
            summary => 'Completer name, if there is a completer for option values',
            schema => 'str*',
        },
    },
    result => {
        schema => 'str*',
        summary => 'A script that can be put into $fpath/_$progname',
    },
};
sub gen_zsh_complete_from_getopt_long_descriptive_spec {
    my %args = @_;

    my $gldspec = $args{spec} or return [400, "Please specify 'spec'"];

    require Getopt::Long::Util;
    my $glspec = {};
    my $opt_desc = {};

    for my $i (0..$#{$gldspec}) {
        next if !$i; # first argument is program usage
        my $ospec = $gldspec->[$i];
        next unless @$ospec;
        my ($glospec, $desc) = @$ospec;
        my $parsed = Getopt::Long::Util::parse_getopt_long_opt_spec($glospec);
        $glspec->{$glospec} = sub {};
        for my $o (@{ $parsed->{opts} }) {
            $opt_desc->{$o} = $desc;
        }
    }

    require Complete::Zsh::Gen::FromGetoptLong;
    Complete::Zsh::Gen::FromGetoptLong::gen_zsh_complete_from_getopt_long_spec(
        spec => $glspec,
        opt_desc => $opt_desc,
        cmdname => $args{cmdname},
        compname => $args{compname},
    );
}

$SPEC{gen_zsh_complete_from_getopt_long_descriptive_script} = {
    v => 1.1,
    summary => 'Generate zsh completion script from Getopt::Long::Descriptive script',
    description => <<'_',

This routine generate zsh completion script for each short/long option, enabling
zsh to be aware of each option.

_
    args => {
        filename => {
            schema => 'filename*',
            req => 1,
            pos => 0,
            cmdline_aliases => {f=>{}},
        },
        cmdname => {
            summary => 'Command name to be completed, defaults to filename',
            schema => 'str*',
        },
        compname => {
            summary => 'Completer name',
            schema => 'str*',
        },
        skip_detect => {
            schema => ['bool', is=>1],
            cmdline_aliases => {D=>{}},
        },
    },
    result => {
        schema => 'str*',
        summary => 'A script that can be put into $fpath/_$progname',
    },
};
sub gen_zsh_complete_from_getopt_long_descriptive_script {
    my %args = @_;

    my $filename = $args{filename};
    return [404, "No such file or not a file: $filename"] unless -f $filename;

    require Getopt::Long::Descriptive::Dump;
    my $dump_res = Getopt::Long::Descriptive::Dump::dump_getopt_long_descriptive_script(
        filename => $filename,
        skip_detect => $args{skip_detect},
    );
    return $dump_res unless $dump_res->[0] == 200;

    my $cmdname = $args{cmdname};
    if (!$cmdname) {
        ($cmdname = $filename) =~ s!.+/!!;
    }
    my $compname = $args{compname};

    my $gldspec = $dump_res->[2];

    gen_zsh_complete_from_getopt_long_descriptive_spec(
        spec => $gldspec,
        cmdname => $cmdname,
        compname => $compname,
    );
}

1;
# ABSTRACT: Generate zsh completion script from Getopt::Long::Descriptive spec/script

=head1 SYNOPSIS


=head1 SEE ALSO
