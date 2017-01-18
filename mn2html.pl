use strict;
use warnings;

my (@src);
my $mode = '';
my %ts;
my @close = ();

{
    open my $f, '<:encoding(UTF-8)', 'jGuidebook.360.mn';
    while(<$f>){
	if(!/^\.\\\"/){
	    chomp;
	    push @src, $_;
	}
    }
    close $f;
}

{
    open my $f, '>:encoding(UTF-8)', 'docs/jguidebook.html';
    print $f <<EOF
<html>
<head>
<style type="text/css">

pre {
  padding: 0;
  margin: 0;
}
dt {
  color: #ffffcc;
}
</style>
<link rel="Stylesheet" href="nhr.css" type="text/css">
</head>
<body>
EOF
   ;
    
    while($#src >= 0){
	$_ = shift @src;
	if(/^\.pg/){
	    putpop($f);
	    print $f "<p>\n";
	    push @close, '</p>';
	    next;
	}
	if(/^\.mt/){
	    my $text = shift @src;
	    $text .= "<br/>";
	    $text .= shift @src;
	    putpop($f);
	    printf $f "<h1 style='text-align:center'>%s</h1>\n", $text;
	    next;
	}
	if(/^\.hu/){
	    my $text = shift @src;
	    putpop($f);
	    printf $f "<h1>%s</h1>\n", $text;
	    next;
	}
	if(/^\.hn (\d)/){
	    my $h = $1;
	    my $text = shift @src;
	    putpop($f);
	    printf $f "<h%d>%s</h%d>\n", $h, $text, $h;
	    next;
	}
	if(/^\.lp (.*)/){
	    my $text = $1;
	    $text =~ s/\"//g;
	    putpop($f);
	    printf $f "<dl><dt>%s</dt><dd>\n", $text;
	    push @close, '</dd></dl>';
	    next;
	}
	if(/^\.PS/){
	    print $f "<dl>\n";
	    next;
	}
	if(/^\.PL (.*)/){
	    my $text = $1;
	    $text =~ s/\"//g;
	    putpop($f);
	    printf $f "<dt>%s</dt><dd>\n", $text;
	    push @close, '</dd>';
	    next;
	}
	if(/^\.PE/){
	    putpop($f);
	    print $f "</dl>\n";
	    next;
	}
	if(/^\.op (.*)/){
	    my $text = $1;
	    $text =~ s/\"//g;
	    printf $f "<tt>%s</tt>", $text;
	    next;
	}
	if(/^\.TS/){
	    $ts{cmd} = shift @src;
	    $ts{attr} = shift @src;
	    print $f "<table>\n";
	    $mode = 'table';
	    next;
	}
	if(/^\.TE/){
	    print $f "</table>\n";
	    $mode = '';
	    next;
	}
	if(/^\.si/){
	    $mode = 'ul';
	    next;
	}
	if(/^\.ei/){
	    $mode = '';
	    next;
	}
	if(/^\./){
	    next;
	}
	if($mode eq 'ul'){
	    printf $f "<li>%s</li>\n", $_;
	    next;
	} 
	if($mode eq 'table'){
	    my (@col) = split /\t/;
	    my $cols = join('</pre></td><td><pre>', @col);
	    printf $f "<tr><td><pre>%s</pre></td></tr>\n", $cols;
	    next;
	}
	s@\\fB@<span class='bold'>@g;
	s@\\fI@<span class='italic'>@g;
	s@\\fP@</span>@g;
	print $f $_ . "\n";
    }
    
    print $f <<EOF
</body>
</html>
EOF
;
    close $f;
}

sub putpop(){
    my $f = shift;
    my $c;
    while ($c = pop @close){
	print $f $c . "\n";
    }
}
