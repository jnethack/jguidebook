use strict;
use warnings;

my (@src);
my $mode = 'init';
my %ts;
my @close = ();

{
    open my $f, '<:encoding(UTF-8)', 'jGuidebook.360.tex';
    while(<$f>){
        if(!/^%/){
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
table {
border: solid 1px #000000; border-collapse: collapse;
}
</style>
<link rel="Stylesheet" href="nhr.css" type="text/css">
</head>
<body>
EOF
   ;
    
    while($#src >= 0){
        $_ = shift @src;

        if($mode eq 'init'){
            if(/^\\begin\{document\}/){
                $mode = '';
            }
            next;
        }

        if($mode eq 'tabular'){
            if(/^\\end\{tabular\}/){
                print $f "</table>\n";
                $mode = '';
                next;
            }
            my (@l) = split /&/;
            print $f '<tr>';
            for(@l){
                printf $f '<td><pre>%s</pre></td>', strip($_);
            }
            print $f "</tr>\n";
            next;
        }

        if($mode eq 'table'){
            if(/^\\caption\[\]\{(.+)\}/){
                my $text = $1;
                printf $f "<caption>%s</caption>\n", $text;
                next;
            }
            if(/^\\end\{tabular\}/ || /^\\end\{longtable\}/){
                print $f "</table>\n";
                $mode = '';
                next;
            }
            if(/^\\hline/){
                next;
            }
            if(/^\\endhead/){
                next;
            }
            my (@l) = split / &/;
            print $f '<tr>';
            for(@l){
                printf $f '<td>%s</td>', strip($_);
            }
            print $f "</tr>\n";
            next;
        }

        if($mode eq 'pre'){
            if(/^\\end\{verbatim\}/){
                print $f "</pre>\n";
                $mode = '';
                next;
            }
            print $f "$_\n";
            next;
        }

        if($_ eq ''){
            if($mode eq 'p'){
                print $f "</p>\n";
                $mode = '';
            }
            if($mode eq 'dl'){
                print $f "<br/>\n";
            }
            next;
        }
        if(/^\\title\{(.+)/){
            # 構造決め撃ち
            my $text = $1;
            $text .= shift @src;
            $text =~ s/\\large//gi;
            $text =~ s@\{\\it ([^}]+)\\/\}@<span class='italic'>$1</span>@g;
            $text =~ s@\\\\@<br/>@g;
            $text =~ s@\}$@@g;
            printf $f "<h1 style='text-align:center'>%s</h1>\n", $text;
            next;
        }
        if(/^\\author\{(.+)/){
            # 構造決め撃ち
            my $text = $1;
            $text .= shift @src;
            $text =~ s@\\\\@<br/>@g;
            $text =~ s@\}$@@g;
            printf $f "<div style='text-align:center'>%s</div>\n", $text;
            next;
        }
        if(/^\\date\{(.+)\}/){
            my $text = $1;
            printf $f "<div style='text-align:center'>%s</div>\n", $text;
            next;
        }
        if(/^\\section.?\{(.+)\}/){
            my $h = strip($1);
            printf $f "<h1>%s</h1>\n", $h;
            next;
        }
        if(/^\\subsection.?\{(.+)\}/){
            my $h = strip($1);
            printf $f "<h2>%s</h2>\n", $h;
            next;
        }
        if(/^\\subsubsection.?\{(.+)\}/){
            my $h = strip($1);
            printf $f "<h3>%s</h3>\n", $h;
            next;
        }
        if(/^\\item\[(.*)\]/){
            my $text = strip($1);
            $text =~ s/\"//g;
            $text =~ s/\~//g;
            putpop($f);
            if($mode eq 'itemize'){
                print $f "<li>\n";
                push @close, '</li>';
            } else {
                printf $f "<dt>%s</dt><dd>\n", $text;
                push @close, '</dd>';
            }
            next;
        }
        if(/^\\blist/){
            $mode = 'dl';
            print $f "<dl>\n";
            @close = ();
            next;
        }
        if(/^\\elist/){
            $mode = '';
            putpop($f);
            print $f "</dl>\n";
            next;
        }
        if(/^\\begin\{verbatim\}/){
            print $f "<pre>\n";
            $mode = 'pre';
            next;
        }
        if(/^\\begin\{center\}/){
            print $f "<div style='align:center'>\n";
            next;
        }
        if(/^\\end\{center\}/){
            print $f "</div>\n";
            next;
        }
        if(/^\\begin\{tabular\}/){
            print $f "<table>\n";
            $mode = 'tabular';
            next;
        }
        if(/^\\begin\{longtable\}/){
            print $f "<table>\n";
            $mode = 'table';
            next;
        }
        if(/^\\begin\{itemize\}/){
            print $f "<ul>\n";
            $mode = 'itemize';
            next;
        }
        if(/^\\end\{itemize\}/){
            $mode = '';
            putpop($f);
            print $f "</ul>\n";
            $mode = '';
            next;
        }
        if(/^\\special\{html:(.+)\}\}/){
            print $f $1 . "\n";
            next;
        }
        if(/^\./){
            next;
        }
        if(/^\\clearpage/){
            next;
        }
        if(/^\\maketitle/){
            next;
        }
        if(/^\\medskip/){
            next;
        }
        if(/^\\newlength/){
            next;
        }
        if(/^\\settowidth/){
            next;
        }
        if(/^\\newcommand/){
            next;
        }
        if(/^\\addtolength/){
            next;
        }
        if(/^\\small/){
            next;
        }
        if(/^\\endhead/){
            next;
        }
        if(/^\\begin\{sloppypar\}/){
            next;
        }
        if(/^\\end\{sloppypar\}/){
            next;
        }
        if(/^\\end\{document\}/){
            next;
        }
        if(/^\{\\catcode/){
            next;
        }
        if($_ eq '{'){
            next;
        }
        if($_ eq '}'){
            next;
        }

        s@<@&lt;@g;

        s@^\\numbox\{([-0-9]+)\}@<span class='tt'>$1</span>@g;

        s@\\\"\{(.)\}@&$1uml;@g; #"
        s@---@&mdash;@g;

        s@\{\\it ([^}]+)\\/\}@<span class='italic'>$1</span>@g;
        s@\{\\it ([^}]+)}@<span class='italic'>$1</span>@g;
        s@\{\\tt ?([^}]+)\\/\}@<span class='tt'>$1</span>@g;
        s@\{\\tt ?([^}]+)\}@<span class='tt'>$1</span>@g;

        s@\\\\$@<br/>@g;

        s@\\verb(.)(.+?)\g1@$2@g;
        s@\\nd @@g;

        s@\\/ @ @g;
        s@\\(.)@$1@g;

        s@`@'@g;

if($mode eq ''){
        print $f "<p>\n";
    $mode = 'p';
}

s@\$\\backslash\$@\\@g;

print $f $_ . "\n";
    }
    
    print $f <<EOF
</body>
</html>
EOF
;
    close $f;
}

sub putpop {
    my $f = shift;
    my $c;
    while ($c = pop @close){
        print $f $c . "\n";
    }
}


sub strip {
    $_ = shift;
    s@\\tb\{([^}]+)\}@$1@g;
    s@\\bb\{([^}]+)\}@$1@g;
    s@\\ib\{([^}]+)\}@$1@g;

    s@\{\\bb ([^}]+)\}@$1@g;
    s@\{\\rm ([^}]+)\}@$1@g;
    s@\{\\tt ([^}]+)\}@$1@g;

    s@\\verb(.)(.+?)\g1@$2@g;

    s@\\\^\{\}@^@g;
    s@\\\^\{([^}]+)\}@^$1@g;
    s@\\@@g;
    return $_;
}
