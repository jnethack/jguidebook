use strict;
use warnings;

my (@src);
my %ts;
my @close = ();
my @mode = ('init', '');

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

        if($mode[0] eq 'init'){
            if(/^\\begin\{document\}/){
                shift @mode;
            }
            next;
        }

        if($mode[0] eq 'tabular'){
            if(/^\\end\{tabular\}/){
                print $f "</table>\n";
                shift @mode;
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

        if($mode[0] eq 'table'){
            if(/^\\caption\[\]\{(.+)\}/){
                my $text = $1;
                printf $f "<caption>%s</caption>\n", $text;
                next;
            }
            if(/^\\end\{tabular\}/ || /^\\end\{longtable\}/){
                print $f "</table>\n";
                shift @mode;
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

        if($mode[0] eq 'pre'){
            if(/^\\end\{verbatim\}/){
                print $f "</pre>\n";
                shift @mode;
                next;
            }
            s@&@&amp;@g;
            s@<@&lt;@g;
            s@>@&gt;@g;
            print $f "$_\n";
            next;
        }

        if($_ eq ''){
            if($mode[0] eq 'p'){
                print $f "</p>\n";
                shift @mode;
            }
            if($mode[0] eq 'dl'){
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
            if($mode[0] eq 'itemize'){
                print $f "<li>\n";
                push @close, '</li>';
            } else {
                printf $f "<dt>%s</dt><dd>\n", $text;
                push @close, '</dd>';
            }
            next;
        }
        if(/^\\blist/){
            if($mode[0] eq 'p'){
                print $f "</p>\n";
                shift @mode;
            }
            unshift @mode, 'dl';
            print $f "<dl>\n";
            @close = ();
            next;
        }
        if(/^\\elist/){
            shift @mode;
            putpop($f);
            print $f "</dl>\n";
            next;
        }
        if(/^\\begin\{verbatim\}/){
            if($mode[0] eq 'p'){
                print $f "</p>\n";
                shift @mode;
            }
            print $f "<pre>\n";
            unshift @mode, 'pre';
            next;
        }
        if(/^\\begin\{center\}/){
            if($mode[0] eq 'p'){
                print $f "</p>\n";
                shift @mode;
            }
            print $f "<div style='align:center'>\n";
            unshift @mode, 'center';
            next;
        }
        if(/^\\end\{center\}/){
            print $f "</div>\n";
            shift @mode;
            next;
        }
        if(/^\\begin\{tabular\}/){
            print $f "<table>\n";
            unshift @mode, 'tabular';
            next;
        }
        if(/^\\begin\{longtable\}/){
            print $f "<table>\n";
            unshift @mode, 'table';
            next;
        }
        if(/^\\begin\{itemize\}/){
            print $f "<ul>\n";
            unshift @mode, 'itemize';
            next;
        }
        if(/^\\end\{itemize\}/){
            putpop($f);
            print $f "</ul>\n";
            shift @mode;
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

        s@&@&amp;@g;
        s@<@&lt;@g;
        s@>@&gt;@g;

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

if($mode[0] eq ''){
        print $f "<p>\n";
    unshift @mode, 'p';
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

    s@&@&amp;@g;
    s@<@&lt;@g;
    s@>@&gt;@g;

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
