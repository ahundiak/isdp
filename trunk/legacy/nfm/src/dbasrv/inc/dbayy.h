/* $Revision: 1.1 $ */
/*
------------------------------------------------------------------------

Name:								PARyy.h
Authors:							David Michal
Creation Date:							3/17/88
Abstract:
   this file contains the redefs of all of the global yy variables
   produced by YACC and LEX

Revision History:

	4-11-91 -- Converted for use with DBA by Tim A. Thompson

------------------------------------------------------------------------
*/

#ifndef _DBAYY_H
#define _DBAYY_H

#define yyleng		dba_par_yyleng
#define yytext		dba_par_yytext
#define yymorfg		dba_par_yymorfg
#define yysptr		dba_par_yysptr
#define yysbuf		dba_par_yysbuf
#define yytchar		dba_par_yytchar
#define yyin		dba_par_yyin
#define yyout		dba_par_yyout
#define yylineno	dba_par_yylineno
#define yyestate	dba_par_yyestate
#define yysvec		dba_par_yysvec
#define yybgin		dba_par_yybgin
#define yyvstop		dba_par_yyvstop
#define yycrank		dba_par_yycrank
#define yytop		dba_par_yytop
#define yymatch		dba_par_yymatch
#define yyextra		dba_par_yyextra
#define yylstate	dba_par_yylstate
#define yylsp		dba_par_yylsp
#define yyolsp		dba_par_yyolsp
#define yyfnd		dba_par_yyfnd
#define yyprevious	dba_par_yyprevious
#define yylook		dba_par_yylook
#define yyback		dba_par_yyback
#define yyinput		dba_par_yyinput
#define yyoutput	dba_par_yyoutput
#define yyunput		dba_par_yyunput
#define yyerror 	dba_par_yyerror
#define yyparse 	dba_par_yyparse
#define yylval  	dba_par_yylval
#define yyexca  	dba_par_yyexca
#define yyact   	dba_par_yyact
#define yypgo   	dba_par_yypgo
#define yyr1 		dba_par_yyr1
#define yyr2 		dba_par_yyr2
#define yychk 		dba_par_yychk
#define yydef 		dba_par_yydef
#define yylex 		dba_par_yylex
#define yychar		dba_par_yychar
#define yyerrflag	dba_par_yyerrflag
#define yyval		dba_par_yyval
#define yytabelem	dba_par_yytabelem
#define yypact		dba_par_yypact
#define yynewstate	dba_par_yynewstate
#define yynerrs		dba_par_yynerrs
#define yypv		dba_par_yypv
#define yys			dba_par_yys
#define yyv			dba_par_yyv
#define yytoktype	dba_par_yytoktype
#define yytoks		dba_par_yytoks
#define yyreds		dba_par_yyreds
#define yyerrlab	dba_par_yyerrlab
#define yytmp		dba_par_yytmp
#define yystate		dba_par_yystate
#define yyps		dba_par_yyps
#define yydebug		dba_par_yydebug

#endif
