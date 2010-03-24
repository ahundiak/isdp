
/YYSTYPE yylval, yyval/ {
i\
YYSTYPE yylval;
d
}
/ global variables used by the parser/,\|/\*$| {
s/\/\*$/\/\*/
t nob
H
:nob
d
 }
/register YYSTYPE \*yypvt/ {
p
i\
/*
g
p
i\
YYSTYPE yyval;
d
}
