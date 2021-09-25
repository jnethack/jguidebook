use strict;
use warnings;
use utf8;

binmode(STDIN);
binmode(STDOUT);

my $mode = '';

while(<>){
    if($mode eq 'table'){
        if(/^%TABLE_END/){
            $mode = '';
        }
        print;
        next;
    }
    if(/^\n/ || /^ / || /^[{}]\n/){
        print;
        next;
    }
    if(/^%TABLE_START/){
        $mode = 'table';
        print;
        next;
    }
    if(
        /^\\title/ ||
        /^\\Large/ ||
        /^\\author/ ||
        /^\\date/ ||
        /^\\section/ ||
        /^\\subsection/ ||
        /^\\subsubsection/ ||
        /^\\caption/ ||
        /^\\numbox/ ||
        /^\\verb/ ||
        /^\\nd/ ||
        /^%@/
       ){
        next;
    }
    if(/^\\item\[\\bb\{(.+)\}\]/){
        my $word = $1;
        if($word =~ /^[A-Z]+$/){
            print;
        }
        next;
    }
    if(/^\\/){
        # 先頭行のdocumentstyle用
        s/\{jarticle}/\{article\}/;
        print;
        next;
    }
    if(/^\{\\begin/){
        print;
        next;
    }
    if(/^%/){
        s/^%//g;
        print;
        next;
    }
}
