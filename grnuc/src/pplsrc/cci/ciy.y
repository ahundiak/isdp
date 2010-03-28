/*
 * grammar for ci, command interpreter
 * in yacc format
 *
 * Etienne   BEEKER
 * Dominique GARDELLA
 */

%{
#define YYDEBUG 1
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include <ctype.h>
#include <string.h>
/*-MACROS---------------------------------------------------------------------*/
/* -- Severe failure ( not syntax ).
   -- */
#define IFFAIL( e )	if( (e) == EMPTY )
/*-EXTERNALS------------------------------------------------------------------*/
extern PCItype	TYPbasic(), STRend(), ENMend(), *pTYPbasic()	;
extern PCIlist	*LSTcat()					;
extern OPERATOR	OPinfo[]					;
extern char	*LABname()					;
extern void	NODreset(), REGreset(), NODinit(), CTXdefault()	;
extern unsigned VARsizeof(), TYPsizoef()			;
/*----------------------------------------------------------------------------*/
/* -- Default type for function arguments, functions and externals.
   -- */
#define DEFAULT		TYPbasic( CI_INT )
#define YYMAXDEPTH	1500
/*----------------------------------------------------------------------------*/
%}

%union {
	double		dvl	; /* double constant		*/
	int		ivl	; /* integer constant		*/
	unsigned	uvl	; /* unsigned constant		*/
	PCItype		typ	; /* type descriptor		*/
	PCIop		opr	; /* operator descriptor	*/
	PCIident	idf	; /* identifier			*/
	PCIstring	str	; /* character string constant  */
	PCIlist		*lst	; /* argument list		*/
	PCItype		*pty	; /*				*/
	char		cvl	; /* character constant		*/
}

/* -- Respect order and numbering of operator tokens! Range is [0-155].
      They are used as array inices in `OPinfo' defined in `cil.l'.
   -- */
%token <opr>	_PLUS	0 	_MINUS	1 	_MUL	2 	_DIV	3
%token <opr>	_ASSIGN	4	_EQUAL	5	_DIFF	6	_STRSUP	7
%token <opr>	_SUPEQU	8	_STRINF	9	_INFEQU	10	_NOT	11
%token <opr>	_ANDAND	12	_OROR	13	_AND	14	_OR	15
%token <opr>	_XOR	16	_MOD	17	_IND	18	_ADDR	19
%token <opr>	_COMMA	20	_ARROW	21	_DOT	22	_OPP	23
%token <opr>	_CMPL	24	_BRA	25	_KET	26	_BREAK	27
%token <opr>	_EXIT	28	_RETURN	29	_CONTINUE 30
%token <opr>	_ATSIGN 31	_BCKQUO 32	_PSCASG 33	_DBLCLN	34
%token <opr>	_RANGE	35	_DBLCRT	36	_INFSUP 37	_DBLPCT	38
%token <opr>	_DBLQMK	39	_DBLATS 40	_UNRNAM 41	_MLTNAM	42
%token <opr>	_PLSNAM	43	_LSHIFT 44	_RSHIFT	45	_LPAR	46
%token <ivl>	_GOTO	_ELSE	_EXTERN
%token <idf>	IDENT	_WHILE	_DO	_FOR	_IF	_SWITCH	_MESSAGE
%token <str>	STRING
%token <ivl>	INTEGER _STRUCT	_UNION	_ENUM
%token <cvl>	CHAR
%token <dvl>	DOUBLE
%token <typ>	BASICTYPE	TYPENAME
%token 		_COLON	_SEMICOL	_CASE	_RPAR	_LBRACE	_TYPEINIT
%token		_RBRACE	_TYPEDEF	_PUSH	_OPERATOR	_IMPLICIT
%token <ivl>	_TO	_SEND	_DOCMD	_DOKEY	_SIZEOF _DEFAULT

%right	_ASSIGN	_PSCASG
%left	_OROR
%left	_ANDAND
%left	_OR
%left	_XOR
%left	_AND
%left	_EQUAL	_DIFF	_DBLPCT	_DBLCLN
%left	_STRSUP _SUPEQU	_STRINF	_INFEQU
%left	_LSHIFT	_RSHIFT
%left	_PLUS	_MINUS	_DBLATS	_DBLQMK	_PLSNAM
%left	_MUL	_DIV	_MOD	_DBLCRT	_INFSUP	 _MLTNAM
%right	UMINUS
%right	_INCOP	_SIZEOF
%left	_BRA	_LPAR	_DOT	_ARROW	_RANGE

%type <lst>	eltlst	arglst	message	element
%type <ivl>	cstval	primary	exp	eltdcl
%type <ivl>	cstexp	 	expret
%type <ivl> 	strtyp	expfor	strhdr	prlpar	enmhdr
%type <typ>	basic	strdcl	enmdcl	typhdr	typcast	inityp
%type <idf>	ifstat 		condif	fcnhdr	ref
%type <opr>	usropr
%start cifile
%%

%{
	int		yy__fcn, Par, IDtype	;
	PCItype		typ			;
/* --	Context of currently parsed declaration.
   -- */
        PCIcontext	yy__dcl			;
	PCIpointer	ptr			;
/* --	Identifier of currently parsed declaration.
   -- */
	PCIident	yy__idt			;
	PCInode		yy__nod			;
	Uchar 		yy__mod[100]		;
/* --	Flag allowing to not flag an external as `not used' when it is
	redeclared. This flag is set in MKdcl().
   -- */
	int		yy__xused		;

%}
/* -- A ci file is a non empty set of definitions.
   --
   -- */
cifile	: { if( !YYinit() ) YYABORT ; }
	  program 
	;

/* -- A program is a collection of external definitions.
   -- */
program	: extdef
	| program extdef
	;

/* -- An external definition is a data or function declaration.
   -- */
extdef	: fcndcl
	| datadef
	| oprdcl
	| inidcl
	;

deflist	: datadef
	| deflist datadef
	;

datadef	: typhdr declist	_SEMICOL
	| _EXTERN			 { yy__dcl.sto = cxEXTRN ; }
	  typhdr declist	_SEMICOL { yy__dcl.sto = cxSTATC ; }
	| _EXTERN			 { yy__dcl.sto = cxEXTRN ;
					   yy__dcl.typ = DEFAULT ; }
	  declist		_SEMICOL { yy__dcl.sto = cxSTATC ; }
	| strdcl		_SEMICOL
	| enmdcl		_SEMICOL
	| typedcl		_SEMICOL { yy__dcl.loc = yy__fcn == EMPTY ?
							cxGLOBL : cxLOCAL ; }
	;

odatadcl : /* Void */
	 | datadcl
	 ;

datadcl	: typhdr declist		_SEMICOL
	| datadcl typhdr declist	_SEMICOL
	;

/* -- Enumerated data type generation.
   -- */
enmdcl	: enmhdr _LBRACE enmlst ocomma _RBRACE { $$ = ENMend() ; }
	| _ENUM IDENT			  {
		if( !ENMfind( $2, &$$ ) ) {
			ERRsyn( "undefined enum", $2 ) ; YYABORT ;
		}
	  }
        ;

enmlst	: enmelt
	| enmlst _COMMA enmelt
	;

enmelt	: IDENT			{ if( !mkENMval( $1, NULL ) ) YYABORT ; }
	| IDENT _ASSIGN cstexp	{ if( !mkENMval( $1, &$3  ) ) YYABORT ; }
	;

enmhdr	: _ENUM		{ IFFAIL( $$ = mkENM( NULL ) ) YYABORT ; }
	| _ENUM IDENT	{ IFFAIL( $$ = mkENM( $2   ) ) YYABORT ; }
	;

ocomma	: _COMMA
	| /* Void */
	;

/* -- A declaration list has the form : <item>, <item>, <item>, ...
   -- */
declist : eltdcl			{
		if( yy__dcl.loc != cxFIELD && yy__dcl.loc != cxTYPDF )
			if( !yy__xused ) PCIusd( $1 ).stat = VAR_NOT_USED ;
		goto modreset ;
	  }
	| declist _COMMA eltdcl	{
		if( yy__dcl.loc != cxFIELD && yy__dcl.loc != cxTYPDF )
			PCIusd( $3 ).stat = VAR_NOT_USED ;
		 modreset :
			yy__dcl.typ.Dim	= 0 		;
			yy__dcl.typ.Ptr	= 0 		;
			yy__dcl.typ.Rpt	= 0		;
			yy__dcl.typ.Fpt	= FALSE   	;
			yy__dcl.typ.Spc	= NULL		;
			yy__dcl.ref	= FALSE		;
			yy__dcl.use	= cxNORML 	;
	  }
	;
	
/* -- Type header : <basic_type>, struct ..., <id>.
   -- */
basic	: BASICTYPE			{
		if( !BSCreduce( &$1, NULL, NULL, &$$ ) ) YYABORT ; }
	| BASICTYPE TYPENAME		{ goto REDUCE2 ; }
	| TYPENAME  BASICTYPE		{ goto REDUCE2 ; }
	| BASICTYPE BASICTYPE		{      REDUCE2 :
		if( !BSCreduce( &$1, &$2 , NULL, &$$ ) ) YYABORT ; }
	| BASICTYPE BASICTYPE TYPENAME	{ goto REDUCE3 ; }
	| BASICTYPE TYPENAME  BASICTYPE	{ goto REDUCE3 ; }
	| TYPENAME  BASICTYPE BASICTYPE	{ goto REDUCE3 ; }
	| BASICTYPE BASICTYPE BASICTYPE	{      REDUCE3 :
		if( !BSCreduce( &$1, &$2 , &$3 , &$$ ) ) YYABORT ; }
	;

typhdr	: basic		{ yy__dcl.typ = $1 ; if( !YYlegal( &yy__dcl ) ) YYABORT ; }
	| TYPENAME 	{ yy__dcl.typ = $1 ; }
	| strdcl	{ yy__dcl.typ = $1 ; }
	| enmdcl	{ yy__dcl.typ = $1 ; }
	;

/* -- Type modifier in declaration:
		*...*<id>, <id>(), <id>[], (<id>)
   -- and all combinations thereof.
*/
/*
   -- NOTE: The following actions handle such exotic junk as :
				int ***(**f)() ;
   -- (a pointer to a pointer to a function returning an int *** value!)
   -- As parsing goes on "**" is saved as Ptr = 2, if '(' and ')' are  met it is
   -- supposed that it might be for a function pointer (Par=1), when '()' is met
   -- Ptr is saved  in Rpt, and Ptr reset to zero  to start  counting the 3 *'s.
   -- Finally, Ptr and Rpt are swapped, Rpt will  contain 3 (  meaning that this
   -- fuss is about a function returning an int ***) and Ptr 2, having the same
   -- meaning as for an ordinary variable.
   -- */
eltdcl	: typmod	{ goto elt ; }
	| _AND typmod	{
		if(    yy__dcl.loc != cxTIARG
		    && yy__dcl.loc != cxOPARG
		    && yy__dcl.loc != cxFNARG ) {
		    ERRsyn( "reference declaration for arguments only", NULL ) ;
		    YYABORT ;
		} else yy__dcl.ref = TRUE ;
		elt :
		if( !TYPderived( yy__mod ) ) YYABORT ;
		Par = yy__dcl.typ.Rpt ;
		if( Par ) { /* TRICKY. Pointer to function : swap Rpt and Ptr */
			yy__dcl.typ.Rpt = yy__dcl.typ.Ptr ;
			yy__dcl.typ.Ptr = Par		;
		} Par = 0 ;
		yy__xused = FALSE ;
		IFFAIL( $$ = MKdcl( &yy__dcl, yy__idt ) ) YYABORT ;
	  }
/* -- This rule is the source of a shift/reduce conflict with:
			label : IDENT _COLON ;
   -- */
	| IDENT _COLON cstexp {
		 IFFAIL( $$ = mkSTRbitfield( &yy__dcl, $1 ) ) YYABORT ; }
	|       _COLON cstexp {
		 IFFAIL( $$ = mkSTRbitfield( &yy__dcl, "" ) ) YYABORT ; }
	;

typmod	: IDENT				{
		yy__mod[0] = 0 ;
		strcpy( yy__idt, $1 )	; }
	| _MUL typmod			{
		yy__mod[++yy__mod[0]] = _MUL ;
		yy__dcl.typ.Ptr++	;
	}
/* SI VARIABLE "EXTERN" mettre dim infinie... */
	| typmod _BRA _KET		{
		if( yy__dcl.sto == cxEXTRN ) {
			yy__dcl.typ.Dim = MAXDIM ;
		} else if(    yy__dcl.loc == cxTIARG
		           || yy__dcl.loc == cxOPARG
		           || yy__dcl.loc == cxFNARG ) {
				yy__dcl.typ.Ptr++	;
		} else ERRsyn( "array has no size", yy__idt ) ;
		/* RM yy__dcl.typ.Ptr++	; RM if ok */
	  }
	| typmod _BRA cstexp _KET	{
		yy__mod[++yy__mod[0]] = _BRA ;
		if( !yy__dcl.typ.Dim ) {
	   	  if( !TYPisdim( (int) ( yy__dcl.typ.Dim = $3 ) ) ) YYABORT ;
		} else {
		  yy__dcl.typ.Dim *= $3 ;
		  WNGsyn( "multi-dimensional converted to one dimensional",
			  yy__idt ) ;
		  /* Swallow them for now.
		  ERRsyn( "multi-dimensional arrays not supported", NULL ) ;
		  YYABORT ;
	          */
		}
	  }
	| typmod _LPAR _RPAR
	   {				  
		yy__mod[++yy__mod[0]] = _LPAR ;

/* --		Function or pointer to function ( Par == 1 ).
   -- */
		if( Par == 1 ) {
/* --			Temporary save of function pointer indirection...
   -- */
			yy__dcl.typ.Rpt	= yy__dcl.typ.Ptr ;
			yy__dcl.typ.Ptr	= 0		;
			yy__dcl.typ.Fpt	= FCNPTR	;
		} else {
			yy__dcl.use	= cxFUNCT	;
			yy__dcl.typ.Fpt	= FCNDCL	;
		}
	   }
	| _LPAR typmod _RPAR {
/* --		This may announce a pointer to function ...
   -- */
		if( yy__dcl.typ.Ptr ) Par = 1 ;
	   }
	;

/* -- Constant expression generator.
   -- */
cstexp	: cstexp _PLUS		cstexp	{ $$ = $1 +  $3			; }
	| cstexp _MINUS		cstexp	{ $$ = $1 -  $3			; }
	| cstexp _MUL		cstexp	{ $$ = $1 *  $3			; }
	| cstexp _DIV		cstexp	{ $$ = $3 ?  $1 / $3 : INFINITE	; }
	| cstexp _MOD		cstexp	{ $$ = $3 ?  $1 % $3 : INFINITE	; }
	| cstexp _OROR  	cstexp	{ $$ = $1 || $3			; }
	| cstexp _ANDAND	cstexp	{ $$ = $1 && $3			; }
	| cstexp _OR  		cstexp	{ $$ = $1 |  $3			; }
	| cstexp _AND		cstexp	{ $$ = $1 &  $3			; }
	| cstexp _XOR		cstexp	{ $$ = $1 ^  $3			; }
	| cstexp _LSHIFT	cstexp	{ $$ = $1 << $3			; }
	| cstexp _RSHIFT	cstexp	{ $$ = $1 >> $3			; }	
	| _MINUS cstexp %prec UMINUS	{ $$ = -$2			; }
	| _NOT   cstexp %prec UMINUS	{ $$ = !$2			; }
	| _CMPL  cstexp %prec UMINUS	{ $$ = ~$<uvl>2			; }
	| _LPAR  cstexp _RPAR		{ $$ = $2			; }
	| DOUBLE			{ $$ = (int) $1			; }
	| INTEGER
	| CHAR				{ $$ = (int) $1			; }
	| _SIZEOF primary		{ if( !FAOflush( &$2 ) ) YYABORT;
					  $$ = (int) VARsizeof( $2  )	;
					  PCIgen = TRUE 		; }
	| _SIZEOF _LPAR typcast _RPAR %prec _SIZEOF
					{ $$ = (int) TYPsizeof( &$3 )	;
					  PCIgen = TRUE			; }

	| IDENT				{
		IFFAIL( ENMfindV( $1, &$$ ) ) {
			ERRsyn( "invalid constant", $1 ) ; YYABORT ;
		}
	  }
	;

/* -- Structure/union declaration : struct { <fields> }
   --                            or struct <tag> { <fields> }.
   -- */
strdcl	: strhdr _LBRACE	{
				$<ivl>2		= yy__dcl.loc	;
				yy__dcl.loc	= cxFIELD	;
		  }
			datadcl _RBRACE	{
		  		$$		= STRend( $1 )	;		
				yy__dcl.loc	= $<ivl>2	;
		  }
		| strtyp IDENT	{/* RM if OK 
		  		if( !STRfind( $2, &$$ ) ) {
		  		   ERRsyn( "undefined union/structure", $2 ) ;
				   YYABORT ;
		  		} end RM */
				if( !STRcreate( $1, $2, &$$ ) ) YYABORT ;
		  }
		;

strhdr	: strtyp	{ IFFAIL( $$ = mkSTR( NULL, $1 ) ) YYABORT ; }
	| strtyp IDENT	{ IFFAIL( $$ = mkSTR( $2  , $1 ) ) YYABORT ; }
	;

strtyp	: _STRUCT
	| _UNION
	;

/* -- Type definition.
   -- */
typedcl	: _TYPEDEF { yy__dcl.loc = cxTYPDF ; } typhdr declist
	| _IMPLICIT typhdr STRING {
		if( !mkIMP( $3, &$2 ) ) YYABORT ;
	}
	;

/* -- Pointer-to generator definition : <id>, *...* <id>.
   -- */
ref	: IDENT	_LPAR oidlist _RPAR { strcpy( $$, $1 ) ; yy__dcl.typ.Ptr = 0 ; }
	| _MUL ref		    { strcpy( $$, $2 ) ; yy__dcl.typ.Ptr++   ; }
	;

/* -- Function  definition :  <type> <name>() { <code> }. Default  for <type> is
      "int".
   -- */
fcndcl	: fcnhdr { yy__dcl.loc = cxFNARG ; } odatadcl {
		if( !UFNbegin() ) YYABORT	;
		yy__dcl.loc = cxLOCAL		;
	  } body {
		if( !UFNend( PCIvar( yy__fcn ) ) ) YYABORT ;
		yy__fcn		= EMPTY		;
		yy__dcl.loc	= cxGLOBL	;
	  }
	; 

fcnhdr	: typhdr ref 			{
		IFFAIL( PCIfcn = yy__fcn = mkUFN( yy__dcl.typ, $2 ) ) YYABORT ;
	  }
	| IDENT _LPAR oidlist _RPAR	{
		yy__dcl.typ = DEFAULT ;
		IFFAIL( PCIfcn = yy__fcn = mkUFN( yy__dcl.typ, $1 ) ) YYABORT ;
	  }
	;

/* -- Operator overload.
   -- */
oprhdr	: typhdr _OPERATOR usropr	{
		if( !mkUOP( &$1, $3.code ) ) YYABORT ;
	  }
	;

oprdcl	: oprhdr _LPAR { yy__dcl.loc = cxOPARG ; } datadcl _RPAR {
			if( !UOPbegin() ) YYABORT ;
			yy__dcl.loc = cxLOCAL	  ;
	  } body {
			if( !UOPend() ) YYABORT	;
			yy__dcl.loc = cxGLOBL	;
	  }
	;

/* -- Overloadable operators.
   -- */
usropr	: _PLUS		| _MINUS	| _MUL		| _DIV
	| _STRSUP	| _SUPEQU	| _STRINF	| _INFEQU
	| _ANDAND	| _OROR		| _AND		| _OR
	| _NOT		| _CMPL		| _LSHIFT	| _RSHIFT
	| _XOR		| _MOD		| _ATSIGN	| _BCKQUO
	| _PSCASG	| _DBLCLN	| _RANGE	| _DBLCRT
	| _INFSUP	| _DBLPCT	| _DBLQMK	| _DBLATS
	| _UNRNAM	| _MLTNAM	| _PLSNAM
	| _BRA _KET	{ $$ = $1 ; }
	;

/* -- Typeinit.
   -- */
inityp	: TYPENAME	{ $$ = $1 ; }
	| BASICTYPE	{
		if( !BSCreduce( &$1, NULL, NULL, &$$ ) ) YYABORT ;
	  }
	;

inihdr	: _TYPEINIT inityp	{ if( !mkTYI( &$2 ) ) YYABORT ; }
	;

inidcl	: inihdr _LPAR { yy__dcl.loc = cxTIARG ; } odatadcl _RPAR {
		if( !TYIbegin() ) YYABORT	;
		yy__dcl.loc = cxLOCAL		;
	  } body 	{
		if( !TYIend() ) YYABORT ;
		yy__dcl.loc = cxGLOBL	;
	  }
	;

/* -- Declaration of formal arguments : empty or list of identifiers.
   -- */
oidlist	: /* Void */
	| idlist
	;

idlist	: IDENT			{ if( !UFNaddarg( $1 ) ) YYABORT ; }
	| idlist _COMMA IDENT	{ if( !UFNaddarg( $3 ) ) YYABORT ; }
        ;

/* -- Function/typeinit/operator body : declaration then statements. This is the
      source of 2 shift/reduce conflicts with "CI_TYPE".
   -- */
body	: _LBRACE
	  	deflist		/* RM if OK { yy__dcl.loc = cxGLOBL ; }*/
	  	ostats		
	  _RBRACE		{ yy__dcl.loc = cxGLOBL ; }
	| block
	;

block	: _LBRACE ostats _RBRACE
	;

ostats	: /* Void */
	| stats
	;

stats	: statement
	| stats statement
	;

statement	: block
		| whilestat
		| dowhilestat
		| forstat
		| docmd
		| dokey
		| ifstat
		| switchstat
		| label statement
		| instruction _SEMICOL	{ REGreset() ; }
		| error _SEMICOL
		;

instruction	: /* Void */
		| exp		 { if( !FAOflush( NULL ) ) YYABORT ; ENDexp() ;}
		| _GOTO IDENT 	 { if( !INSjmp($2, US_LAB, jmpGOTO) ) YYABORT ;}
		| _BREAK	 { if( !gen( $1.instr, 1, PCInlab ) ) YYABORT ;}
		| _CONTINUE	 { if( !gen( $1.instr, 1, PCInlab ) ) YYABORT ;}
		| _EXIT		 { if( !gen( $1.instr, 0 )          ) YYABORT ;}
		| _RETURN expret { if( !cireturn( yy__fcn, &$1, $2 ) ) YYABORT ;}
		| _PUSH arglst	 { NODinit() ;
				   if( !INSpush( $2 ) )		      YYABORT ;
				   ENDexp() ;
				 }
		;

expret	: /* Void */	{ $$ = EMPTY 	; 		}
	| exp		{ ENDexp()	; $$ = $1 ;	}
	;

arglst	: /* Void */	{ if( !mkLST( &$$, -1 ) ) YYABORT ; }
	| exp		{ if( !FAOflush( &$1 )	) YYABORT ;
			  if( !mkLST( &$$, $1 ) ) YYABORT ; }
	| eltlst
	;

eltlst	: element _COMMA element   {
		yy__nod.type			= BINARY ;
		yy__nod.info.operator.symbol	= $2	 ;
		if( !( ( $$ = LSTcat( $1, $3 ) ) && mkNOD( &yy__nod ) ) ) YYABORT ;
	  }
	| eltlst _COMMA element   {
		yy__nod.type			= BINARY ;
		yy__nod.info.operator.symbol	= $2	 ;
		if( !( ( $$ = LSTcat( $1, $3 ) ) && mkNOD( &yy__nod ) ) ) YYABORT ;
	  }
	;

element	: exp			{ if( !FAOflush( &$1 )	) YYABORT 	;
				  if( !mkLST( &$$, $1 )	) YYABORT 	; }
	| _MESSAGE message	{ $$ = $2				; }    	
	;

message	: IDENT _DOT IDENT _LPAR arglst _RPAR
	   {
		if( !cimessage( &$$, $1, $3, $5 ) ) YYABORT ;
	   }
	;

exp 	: _SEND message _TO { IDtype = iTARGET ; } primary
	     {
	        IDtype = iNORMAL ;
		if( !cisend( &$$, $2, $5 ) ) YYABORT ;
	     }
	| exp _PLUS 	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _MINUS	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _MUL	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DIV	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _MOD	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _ANDAND	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _OROR	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _EQUAL	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DIFF	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _STRSUP	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _SUPEQU	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _STRINF	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _INFEQU	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _AND	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _OR	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _XOR	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _LSHIFT	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _RSHIFT	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _PSCASG	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DBLCLN	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _RANGE	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DBLCRT	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _INFSUP	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DBLPCT	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DBLQMK	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _DBLATS	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _MLTNAM	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _PLSNAM	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { goto bop ; }
	| exp _ASSIGN	{ if( !FAOflush( &$1 ) ) YYABORT ; } exp { 
			  bop :
			   if( !(    FAOflush( &$4 )
				  && OPbin( &$$, $1, &$2, $4 ) ) ) YYABORT ;
			}
	| primary
	;

primary    : _MUL	primary %prec UMINUS { goto unrop ; }
	   | _AND	primary %prec UMINUS { goto unrop ; }
	   | _NOT	primary %prec UMINUS { goto unrop ; }
	   | _MINUS	primary %prec UMINUS { goto unrop ; }
	   | _ATSIGN	primary %prec UMINUS { goto unrop ; }
	   | _BCKQUO	primary %prec UMINUS { goto unrop ; }
	   | _UNRNAM	primary %prec UMINUS { goto unrop ; }
	   | _CMPL	primary %prec UMINUS {
		unrop :
		if( !(    FAOflush( &$2 )
                       && OPunr( &$$, &$1, $2 ) ) )		YYABORT ;
	     }
           | _SIZEOF primary				{
		IDtype = iNORMAL	;
		if( !( 	  FAOflush( &$2 )
		       && PPLsizeofV( &$$, $2 ) ) )		YYABORT ;
		PCIgen = TRUE ;
	     }
	   | _LPAR typcast _RPAR primary %prec _INCOP {
		FAOflush( &$4 ) ;
		if( !(    FAOflush( &$4 )
		       && cicast( &$$, &$2, $4 ) ) )		YYABORT ; 
	     }
           | _SIZEOF _LPAR typcast _RPAR %prec _SIZEOF {
		if( !PPLsizeofT( &$$, &$3 ) )			YYABORT ;
		PCIgen = TRUE ;
	     }
	   | primary _BRA { if( !FAOflush( &$1 ) ) YYABORT ; } exp _KET {
		if( !(    FAOflush( &$4 )
                       && AOPbrk( &$$, $1, &$2, $4 ) ) )	YYABORT ;
	     }
	   | prlpar arglst _RPAR			{
                NODinit() ;
		if( !AOPfun( &$$, $1, $2 ) )			YYABORT ;
	     }
	   | _MESSAGE _LPAR arglst _RPAR		{
                NODinit() ;
		if( !AOPfun( &$$, mkSYS( $1 ), $3 ) )		YYABORT ;
	     }
	   | primary _DOT IDENT				{
	        if( !FAOdot( &$$, $1, &$2, $3 ) )		YYABORT ;
	     }
	   | primary _ARROW IDENT			{
	        if( !FAOarw( &$$, $1, &$2, $3 ) )		YYABORT ;
	     }
	   | IDENT					{
                NODinit() ;
		if( !PPLident( &yy__dcl, &$$, $1, IDtype ) )	YYABORT ;
	     }
	   | cstval					{
	        NODinit()		     	  ;
	        yy__nod.type		= OPERAND ;
	        yy__nod.info.operand	= $$ = $1 ;
		if( !mkNOD( &yy__nod ) )				YYABORT	;
	     }
           | _LPAR exp _RPAR				{
	        $$ = $2 ;
	     }
	   ;
 
prlpar	: primary _LPAR		{
		 $$ = $1 ; if( !FAOflush( &$1 ) )		YYABORT ;
	  }
/* -- This is the source of shift/reduce conflicts (redundant with the
      preceeding rule but necessary do have a default type (int)).
   -- */
	| IDENT _LPAR		{
		NODinit() ;
		if( !PPLident( &yy__dcl, &$$, $1, iFUNCTN ) )	YYABORT ;
      	  }
	| inityp _CMPL _LPAR	{
		NODinit() ;
		IFFAIL( $$ = TYIfindthis( &$1 ) )		YYABORT ;
	        yy__nod.type		= OPERAND 	;
	        yy__nod.info.operand	= $$		;
		if( !mkNOD( &yy__nod ) )				YYABORT	;
	  }
	;

typcast	: basic
	| TYPENAME
	| strdcl
	| typcast _MUL	{ $$ = $1 ; $$.Ptr++ ; }
	;

expfor	: /* Void */	{ IFFAIL( $$ = mkCSTint( 1 ) ) YYABORT	; }
	| exp		{ ENDexp() ; $$ = $1			; }
	;

label	: IDENT 	_COLON { IFFAIL( mkLAB($1, US_LAB, PCInins) ) YYABORT ;}
	| _CASE cstexp	_COLON { if( !SWcase( $2 ) )		      YYABORT ;}
	| _DEFAULT	_COLON { if( !SWdefc()     )		      YYABORT ;}
	;

/* -- The index of the out-nesting switch is stored in $1.
   -- */
switchstat: _SWITCH _LPAR exp _RPAR 	{
		ENDexp() ; REGreset() ;
		IFFAIL( $<ivl>1 = SWbegin( &$3, $<idf>2, $<idf>4 ) ) YYABORT ;
	    }
	    statement			{
	    	if( !SWend( $3, $<ivl>1, $<idf>2, $<idf>4 ) ) YYABORT ;
	    }
	  ;

/* -- WHILE loop :
	while( <WH_STR:> `test' <if not `test' goto WH_END> ) {
			`body'
			<goto WH_STR>
	}
	<WH_END:>
  -- */
whilestat : _WHILE _LPAR     {
		IFFAIL( mkLAB( LABname( $1 ), WH_STR, PCInins ) ) YYABORT ;
	    }
	    exp _RPAR	     {
	     	ENDexp()	;
		REGreset()	;
		if( !INSjmp( LABname( $<idf>2 ), WH_END, $4 ) ) YYABORT ;
	    }
	    statement	     {
		if( !(    INSjmp( $1, WH_STR, jmpGOTO )
		       && mkLAB($<idf>2, WH_END, PCInins) != EMPTY ) ) YYABORT ;
	    }
	  ;

/* -- DO loop :
	do {
		<DO_STR:>
		<DO_CNT:>  ==> Note that the 3 label names are stored in $1.
		<DO_END:>
			`body'
	} while( `test' <if not `test' goto DO_END> <goto DO_STR> ) ;
	<DO_END:>
   -- */

dowhilestat : _DO			{
	         IFFAIL( mkLAB( LABname( $1 )     , DO_STR, PCInins ) ) YYABORT;
	         IFFAIL( mkLAB( LABname( &$1[10] ), DO_CNT, EMPTY   ) ) YYABORT;
	         IFFAIL( mkLAB( LABname( &$1[20] ), DO_END, EMPTY   ) ) YYABORT;
	      }
	       statement _WHILE _LPAR	{
	          IFFAIL( mkLAB( &$1[10], DO_CNT, PCInins ) ) YYABORT ;
	      }
	       exp _RPAR _SEMICOL	{
	     	  ENDexp() 	;
		  REGreset()	;
	          if( !(    INSjmp( &$1[20], DO_END, $7      )
	                 && INSjmp( $1     , DO_STR, jmpGOTO ) ) ) YYABORT ;
	          IFFAIL( mkLAB( &$1[20], DO_END, PCInins ) )	   YYABORT ;
		}
	     ;

/* -- FOR loop :
 	for( `init' ;
 	     <FR_TST:> `test' <if not `test' goto FR_END> <goto FR_STR> ;
 	     <FR_EXP:> `expression' <goto FR_TST> ) {
			<FR_STR:>
				`body'
				<goto FR_EXP>
	}
	<FR_END:>
   -- */ 

forstat : _FOR _LPAR instruction _SEMICOL	{
	     IFFAIL( mkLAB( LABname( $1 ), FR_TST, PCInins ) ) YYABORT ;
	     REGreset() ;
	  }
	  expfor _SEMICOL		   	{
	     if( !(    INSjmp( LABname( $<idf>7 ), FR_END, $6     )
	            && INSjmp( LABname( $<idf>4 ), FR_STR, jmpGOTO) ) ) YYABORT;
	     IFFAIL( mkLAB( LABname( $<idf>2 ), FR_EXP, PCInins )     ) YYABORT;
	     REGreset() ;
	  }
	  instruction _RPAR			{
	     if( !INSjmp( $<idf>1, FR_TST, jmpGOTO ) )   YYABORT ;
	     IFFAIL( mkLAB( $<idf>4, FR_STR, PCInins ) ) YYABORT ;
	     REGreset() ;
	  }
	  statement				{
	     if( !INSjmp( $<idf>2, FR_EXP, jmpGOTO ) )   YYABORT ;
	     IFFAIL( mkLAB( $<idf>7, FR_END, PCInins ) ) YYABORT ;
	  }
	;

docmd	: _DOCMD _LPAR exp _RPAR	{ ENDexp()			;
		  			  if( !CMDbegin( $3 ) ) YYABORT	; }
	  		statement
		 			{ if( !CMDend()	      ) YYABORT	; }
	;

dokey	: _DOKEY _LPAR exp _RPAR	{ ENDexp()			;
		  			  if( !KEYbegin( $3 ) ) YYABORT	; }
	  		statement
		 			{ if( !CMDend()	      ) YYABORT	; }
	;

/* -- IF statement :
1)	if( `test' <if not `test' goto IF_ELS> ) {
		`body'
		<goto IF_END>
	}
	<IF_END:>

2)	if( `test' <if not `test' goto IF_ELS> ) {
		`body'
		<goto IF_END>
		<IF_ELS:>
	} else {
		`body'
	}
	<IF_END:>
   -- */

condif	: _IF _LPAR exp _RPAR	{
		ENDexp() ;
		if( isconst( $3 ) )
			WNGsyn( "constant in conditional context", NULL ) ;
		if( !INSjmp( LABname( $$ ), IF_ELS, $3 ) ) YYABORT ;
	  }
	;

ifstat	: condif statement { IFFAIL( mkLAB( $1, IF_END, PCInins ) ) YYABORT ; }
	| condif statement {
		PCIident lab ;
		strcpy( lab, $1 ) ;
		if( !INSjmp( LABname( $1 ), IF_END, jmpGOTO ) )	YYABORT	 ;
		IFFAIL( mkLAB( lab, IF_ELS, PCInins ) )		YYABORT	 ;
	  }
	  _ELSE statement  { IFFAIL( mkLAB( $1, IF_END, PCInins ) ) YYABORT ; }
	;


cstval	: STRING  { typ = TYPbasic( CI_STRING ) ; ptr.Str = &$1 ; goto cst ; }
	| INTEGER { typ = TYPbasic( CI_INT    ) ; ptr.Int = &$1 ; goto cst ; }
	| CHAR	  { typ = TYPbasic( CI_CHAR   ) ; ptr.Chr = &$1 ; goto cst ; }
	| DOUBLE  { typ = TYPbasic( CI_DOUBLE ) ; ptr.Dbl = &$1 ;
			 cst : IFFAIL( $$ = mkCST( &typ, ptr ) ) YYABORT ;   }
	;
%%
/*----------------------------------------------------------------------------*/
int yywrap() { return 1 ; }
/*----------------------------------------------------------------------------*/
int YYinit() {

			int rc = TRUE ; PCIcontext info ;

  CTXdefault( (PCItype *) NULL, &yy__dcl )	;
  yy__fcn	= EMPTY				;
  IDtype	= iNORMAL			;

/* -- Creates variable "~dummy": it MUST be variable number 0.This is to protect
      the 1st variable from being an external. Also creates a dummy variable of
      type "void".
   -- */
  CTXdefault( pTYPbasic( CI_INT ), &info ) ;

  if( MKdcl( &info, "~dummy" ) != 0 ) {
  	rc = cibugchk( "YYinit", "`~dummy' is not variable # 0" ) ;
  } else PCIusd( 0 ).stat = VAR_USED ;

  info.typ.Num = CI_VOID ;
  info.use     = cxFUNCT ;
  IFFAIL( PCIvoid = MKdcl( &info, "~void" ) ) {
  	rc = cibugchk( "YYinit", "cannot create `~void'" ) ;
  } else PCIusd( PCIvoid ).stat = VAR_USED ;
#if DEBUG
	printf( "YYinit : PCIvar(0) = <%s> %d\n", PCIvar( 0 ), PCIusd( 0 ).stat ) ;
#endif
  return rc ;

} /* YYinit */
/*----------------------------------------------------------------------------*/
void yyerror( s ) char *s ; { ERRsyn( s, NULL ) ; NODreset() ; }
/*----------------------------------------------------------------------------*/
int YYlegal( c )	PCIcontext *c ; {

				int rc = TRUE ;

   if( c->typ.Def == BASIC ) {
	if(    c->typ.Num == CI_INTEGER || c->typ.Num == CI_NUMERIC
	    && !( c->loc == cxTIARG || c->loc == cxOPARG )           )
	  rc = ERRsyn( "types `integer'/`numeric' not allowed here", NULL ) ;
       else if( TYPvoid( &c->typ ) ) {
	switch( c->loc ) {
		case cxTIARG :
       		case cxFNARG : rc = ERRsyn( "void type for argument", NULL ) ;
       			       break ;
       		case cxOPARG : rc = ERRsyn( "void type for operand" , NULL ) ;
       			       break ;
	}
     }
   }
  return rc ;
}
/*----------------------------------------------------------------------------*/

int ENDexp()

{ void FAOreset() ;

	FAOreset()		;
	return NODcheck()	;
}
/*----------------------------------------------------------------------------*/
