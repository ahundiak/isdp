%{
#undef YYLMAX
#define YYLMAX 1024

#include <stdio.h>
#include <string.h>

#define NEEDHOST 1
#define NEEDUSER 2
#define NEEDPASS 3
#define EVERYTHING 4
#define EXIT 0

#ifndef FLEX_SCANNER
  #undef input
  #undef output
  #undef unput
  extern char *csp;
  #define input() (*csp ? (*csp++):0)
  #define unput(c) {*(--csp) = c;}
  #define output(c)
#else
  #undef YY_INPUT
  #define YY_INPUT(buf, result, max_size)\
 { extern char *csp; result = (*csp ? (buf[0] = *csp++, 1) : YY_NULL); }
#endif

extern int addrtype;
extern int yydone;
extern struct {
	char node[128];
	char user[32];
	char pass[768];
} conn;

%}
%START UNAME HNAME PASSW
H	[0-9A-Fa-f]+
D	[0-9]+
Node	[0-9A-Za-z_]
Any	[^\n]
Host	[^:\n]
User	[^.@\n]
%%

^{Node}+"."			{
				addrtype = 1;
				yytext[yyleng-1] = '\0';
				strcpy(conn.node, (char*)yytext);
				BEGIN UNAME;
				yydone = 0;
				return(NEEDUSER); }

^{D}"."{D}"."{D}"."{D}"."	{
				addrtype = 2;
				yytext[yyleng-1] = '\0';
				strcpy(conn.node, (char*)yytext);
				BEGIN UNAME;
				yydone = 0;
				return(NEEDUSER); }

^{D}"."{D}"."{D}"."{D}"\n"	{
				addrtype = 2;
				yytext[yyleng-1] = '\0';
				strcpy(conn.node, (char*)yytext);
				BEGIN UNAME;
				yydone = 0;
				return(NEEDUSER); }

^{H}"."{H}"-"{H}"-"{H}"-"{H}"-"{H}"-"{H}"." |
^{H}"-"{H}"-"{H}"-"{H}"-"{H}"-"{H}"."	 {
				addrtype = 0;
				yytext[yyleng-1] = '\0';
				strcpy(conn.node, (char*)yytext);
				BEGIN UNAME;
				yydone = 0;
				return(NEEDUSER); }

<UNAME>"\n"			{
				BEGIN 0;
				yydone = 1;
				return(NEEDUSER); }

<UNAME>{User}*"."		{
				yytext[yyleng-1] = '\0';
				strcpy(conn.user, (char*)yytext);
				BEGIN PASSW;
				yydone = 0;
				return(NEEDPASS); }

<UNAME>{User}*$			{
				strcpy(conn.user, (char*)yytext);
				BEGIN 0;
				yydone = 1;
				return(EVERYTHING); }

<PASSW>"\n"			{
				BEGIN 0;
				yydone = 1;
				return(NEEDPASS); }

<PASSW>{Any}*$			{
				strcpy(conn.pass, (char*)yytext);
				BEGIN 0;
				yydone = 1;
				return(EVERYTHING); }

^{User}+@			{
				addrtype = 3;
				yytext[yyleng-1] = '\0';
				strcpy(conn.user, (char*)yytext);
				BEGIN HNAME;
				yydone = 0;
				return(NEEDHOST); }

<HNAME>{D}"."{D}"."{D}"."{D}$   {
				addrtype = 4;
				strcpy(conn.node, yytext);
				BEGIN 0;
				yydone = 1;
				return(NEEDPASS); }

<HNAME>{D}"."{D}"."{D}"."{D}":" {
				addrtype = 4;
				yytext[yyleng-1] = '\0';
				strcpy(conn.node, yytext);
				BEGIN PASSW;
				yydone = 0;
				return(NEEDPASS); }

<HNAME>{Host}*$			{
				strcpy(conn.node, (char*)yytext);
				BEGIN 0;
				yydone = 1;
				return(NEEDPASS); }

<HNAME>{Host}*":"		{
				yytext[yyleng-1] = '\0';
                                strcpy(conn.node, (char*)yytext);
                                BEGIN PASSW;
                                yydone = 0;
                                return(NEEDPASS); }

