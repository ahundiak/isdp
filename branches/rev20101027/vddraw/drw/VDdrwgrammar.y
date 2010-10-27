%{
/* $Id: VDdrwgrammar.y,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwgrammar.y
 *
 * Description:
 *	Parser for drawing production
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwgrammar.y,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  1998/05/11  20:28:20  pinnacle
 * Replaced: vddraw/drw/VDdrwgrammar.y for:  by mdong for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/04/19  13:40:06  pinnacle
 * Replaced: vddraw/drw/VDdrwgrammar.y for:  by impd for vds
 *
 * Revision 1.3  1998/04/18  19:03:36  pinnacle
 * Replaced: vddraw/drw/VDdrwgrammar.y for:  by azuurhou for vds
 *
 * Revision 1.2  1997/10/28  08:49:50  pinnacle
 * Replaced: vddraw/drw/VDdrwgrammar.y for:  by vgnair for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	3/15/95		tlb
 *		Add rules for: hidden symbology, qualified elementType
 *			Remove goto's, hidden_style rule
 *
 *	3/20/95		tlb
 *		Add error productions
 *		Add VPRINTF, fix GROUTPUT messages
 *		Now set symbology defaults in parser
 *		Cleanup error processing: error, warning, trace rotuines
 *		Add z-clip, envelope  rules
 *		Consolidate global_setting, include, assigment rules
 *		Move rule bodies to functions - InitParser, EndParser
 *		Consolidate configs, header, haction(s) rules
 *		Rename global_setting -> setting
 *
 *	5/1/95		tlb
 *		Syntax warnings only print during preprocessing with verbose
 *		Grammar changed to support better error processing
 *	5/9/95		tlb
 *		Change InitParser call, PRINTF macro
 *	7/25/95		tlb
 *		Add verbose to binOP, relOP, unrOp
 *	8/15/95		adz
 *		Add ViewType checking for structural elements.
 *	10/27/97	vini
 *		Add library . 
 *      05/11/98        Ming
 *              TR179800593
 *
 *************************************************************************/

#include <string.h>
#include <ctype.h>
#include <values.h>
#include <math.h>
#include "msdef.h"
#include "UOMdef.h"
#include "gotextdef.h"
#include "EMSmsgdef.h"
#include "v_iomacros.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "macro.h"
#include "v_globalmsg.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_lngopproto.h"
#include "v_strngproto.h"

/*
 * WARN is defined somewhere is EMS
 */
#undef WARN

extern int		yylineno;
extern char		yytext[];

/*
 * Conflict with include file "stdlib.h"
 * extern int		abs();
 */

/*
 * Debugging conditional/flags
 */
#ifdef GRAMMAR
#	define YYDEBUG 1
	extern yydebug = 1;		/* enable parser debugging */
#endif

/*---------------------------- Defines -------------------------------------*/
/*
 * Short cuts.
 */
#define IFMVERB		if( macInfo && xData.verbose )
#define IFXVERB		if( X && xData.verbose )
#define IFVERB		if( xData.verbose )
#define VERB		xData.verbose
#define LOC		xData.overrides
#define DEF		inp->defaults
#define KWRD( t )	VD_drwKwFromTokType( (t) )
#define	INT( x )	VD_drwIntVal( (x) )
#define	IABS( x )	abs( VD_drwIntVal( (x) ) )
#define BOOL( x )	VD_drwBoolVal( (x) )
#define DBL( x )	VD_drwDblVal( (x) )
#define DABS( x )	fabs( VD_drwDblVal( (x) ) )
#define STR( x, b )	VD_drwStrVal( (x), (b) )
#define FILE_NAME	inp->inputFiles.name[inp->inputFiles.iScanned]


/*-----------------------------------------
 * Messages
 *	ABORT		Parser error message, cleanup, abort immediately
 *	S_ERR		Syntax error, abort if executing (X == TRUE),
 *								always print msg
 *	S_WARN		Syntax warning, print warning if verbose and !X
 *				Do not use with yacc keyword "error"
 *	WARN		Print warning, continue processing, always print
 *	TRACE		Print trace message to logfile if verbose
 *	LOG_PRINT	Print message to logfile w lineno
 *	PRINTF		Print message direct to log file
 */
#define LOG_PRINT		VD_drwPrintf
#define PRINTF			VD_drwPrintLogFile

#define TRACE(s)		VD_drwParserTrace("%s\n", (s) )
#define TRACE1(f,a)		VD_drwParserTrace((f) , (a) )
#define TRACE2(f,a1,a2)		VD_drwParserTrace((f), (a1), (a2) )
#define TRACE3(f,a1,a2,a3)  	VD_drwParserTrace((f), (a1), (a2), (a3) )

#define S_WARN(s)	IFMVERB {VD_drwPrintMsg("!!! Warning", "%s\n", (s) );}
#define S_WARN1(f, s)	IFMVERB {VD_drwPrintMsg("!!! Warning", (f), (s) ); }

#define WARN( a )		VD_drwParserWarn (VERB, "%s\n", (a) )
#define WARN1(f, a )		VD_drwParserWarn (VERB, (f), (a) )
#define WARN2(f, a1, a2 )	VD_drwParserWarn (VERB, (f), (a1), (a2))
#define WARN3(f, a1, a2, a3 ) 	VD_drwParserWarn (VERB, (f), (a1), (a2), (a3))

#define S_ERR(s)	{VD_drwSyntaxError (VERB, "%s\n", (s)); E_CLEANUP}
#define S_ERR1(f,s)	{VD_drwSyntaxError (VERB, (f), (s)); E_CLEANUP}
#define S_ERR2(f,s1,s2)	{VD_drwSyntaxError (VERB, (f), (s1), (s2)); E_CLEANUP}

#define ERR_KWRD(m,s,t)	{S_ERR2("Invalid %s keyword: %s\n", (m), (s)); 	\
			 PRINTF ("\t    Valid %s keywords:\n", (m));	\
			 VD_drwPrintValidKeywords ((t)); }

#define ABORT(s)	{VD_drwParserError(VERB, "%s - aborting\n", (s)); \
			 VD_drwEndParser (&xData, inp, macInfo, elmProcessed);\
			 return yynerrs; }

/*
 * Generic syntax error message
 *	ignore generic "syntax error" message
 */
#define yyerror( s )	S_ERR("")


/*
 * Error cleanup
 *	reset lex, clear look ahead, abort if executing
 */
#define E_CLEANUP	VD_drwResynchLex(); yyclearin; \
			if (X) ABORT("Syntax error while executing")

/*-------------------------------------------
 * Call yylex with two arguments : the file pointer to the log file
 * if in verbose mode else NULL, and the stack of input files.
 */
#define yylex()		yyLex(	xData.verbose ? xData.logFile : NULL, \
				&inp->inputFiles )

/*
 * Add local variables to yyparse(), so as not to declare them as globals.
 *	Initailized to stop uninitialized warnings from compiler
 *
 *	elmProcessed
 *		Elements flagged as not processed. The flag is set
 *		to TRUE when the element passes a type selection criterion.
 */
#define LOCALVARS							\
    VD_drwExecData xData ;		/* Execution data */		\
    int		   X 			/* Execute ? (TRUE/FALSE) */	\
				= TRUE;					\
    int		   configX; 		/* saved execute flag for element */\
    int		   VerbInit	= FALSE;/* set to TRUE after 1st verbose */\
    double	   d ;			/* Double buffer */		\
    int		   i ;			/* Integer buffer */		\
    VD_tktxt	   s ;			/* String buffer */		\
    VD_drwText	   *alreadyFilled	/* Points to already filled text*/ \
				= NULL;					\
    VD_execRes	   noEval ;		/* Unevaluated result */	\
    int		   elmProcessed ;	/* TRUE if element was processed*/ \
    VD_drwArgLst   *outputArgLst 	/* Arg list of output statement */ \
				= NULL;

/*
 * Add arguments and local variables to yyparse.
 * Note that the additional '}' will have to be closed in the makefile since
 * there is no way to add a supplementary ;}' to yyparse() from this .y file.
 * Note : if `macInfo' is not NULL, then only the information contained in
 * the statements specifying which attributes must be reported to the drawing
 * will be returned; in this case `output' may be NULL and only
 * `inp->cfgFile' needs to be set.
 */
#define yyparse(void)						\
	VD_drwParse( msg, inp, macInfo, output )		\
			long			*msg ;		\
			VD_drwInputData		*inp ;		\
			VD_drwMacInfo		**macInfo ;	\
			VD_drwOutputData	**output ;	\
{								\
	LOCALVARS

/*-------------------------------------------------------------------------*/
/*-------------------------- Rule and Token Types -------------------------*/
%}
%union {
	VD_drwViewType	viewTp ;	/* Mask of view types		*/
	VD_drwCaseOf	caseOf ;	/* Type selections		*/
	VD_drwAnchorType anchTp ;	/* Anchor point type		*/
	int		xqtFlg ;	/* Saves 'execute' flag		*/
	int		txjust ;	/* Text justification		*/
	int		txtpos ;	/* Text position		*/
	VD_execRes	result ;	/* Result of an operation	*/
	VD_drwTOKEN	tokVal ;	/* Token as read by Lex		*/
	int		tokType;	/* Token type */
	VD_drwArgLst	*argLst;	/* Arg. list for function call	*/
	VD_drwText	format ;	/* Format of text		*/
	VD_tktxt	string ;	/* Character string		*/
}

%type <result>	exp		expounit	constant	arg
%type <argLst>	oarglist	arglist
%type <viewTp>	viewType	viewTypes
%type <caseOf>	outputType	elementType	symbolType	const
%type <string>	graphic
%type <xqtFlg>	viewSelection	selection	when		whens
%type <format>	textseqs	textseq		textcmd
%type <txjust>	txjust
%type <txtpos>	txpos
%type <anchTp>	which_point
%type <tokType> setting		local_settings
%type <tokType> hdr_setting	hdr_settings
%type <tokType> action_list
/*
 * Graphic output.
 */
%token <tokVal>	GROUTPUT	SYMBOL
/*
 * Symbology.
 */
%token <tokVal> COLOR		STYLE		WEIGHT		LEVEL
%token <tokVal> HIDDEN_COLOR	HIDDEN_STYLE	HIDDEN_WEIGHT	HIDDEN_LEVEL
/*
 * Database update
 */
%token <tokVal> UPDATE_DB	STATEMENT
/*
 * Additional display modifiers for graphics (symbol/text excluded)
 */
%token <tokVal>	FILLED_DISPLAY	SCALE
/*
 * Text attributes (subkeywords of "SYMBOL" keyword).
 */
%token <tokVal>	SIZE		WIDTH		HEIGHT		JUST
%token <tokVal>	FONT		POSITION	FORMAT
%token <tokVal>	LIBRARY		
/*
 * Possible values of "POSITION" keyword (may be combined).
 */
%token <tokVal>	MIDDLE		CENTER		TOP		BOTTOM
%token <tokVal>	LEFT		RIGHT		AT1STEND	AT2NDEND
%token <tokVal>	TOTHELEFT	TOTHERIGHT	ABOVE		BELOW
%token <tokVal>	OFFSET		HORIZONTAL	PARALLEL	ORTHOGONAL
%token <tokVal>	NOTREVERSED	RIGHTTOLEFT	UPSIDEDOWN	TAG
/*
 * Keywords for the anchor-point statement.
 */
%token <tokVal>	ANCHOR_POINT	CTR_OF_GRV	AVERAGE_POINT	INNERMOST
/*
 * Keywords for the anchor-curve statement.
 */
%token <tokVal>	ANCHOR_CURVE
/*
 * Keywords for conditional structure.
 */
%token <tokVal>	SELECT		WHEN		OTHERWISE	END
/*
 * View types (TOP and BOTTOM -text subkeywords- are also view types)
 * OTHER_VIEW is for applications to add their view types.
 */
%token <tokVal>	SIDE		ENDON		UNKNOWN_VIEW	ANY_VIEW
%token <tokVal>	OTHER_VIEW
/*
 * Element types.
 */
%token <tokVal>	ELMTYPE		CONST
/*
 * Definition name and view criterion for CONST.
 */
%token <tokVal>	VIEW_CRITERION	VIEW_CRITERIA	DEFINITION
/*
 * "extract" statement.
 */
%token <tokVal> EXTRACT AS WITH
/*
 * Separators and delimiters.
 */
%token <tokVal>	';'		':'		'('		')'
%token <tokVal>	'{'		'}'		'['		']'
/*
 * Constants.
 */
%token <tokVal>	VD_INT		VD_DOUBLE	VD_STRING	UNIT
/*
 * Subkeywords for "FORMAT" keyword.
 */
%token <tokVal>	TXUP		TXDOWN		TXLEFT		TXRIGHT
%token <tokVal>	TXFSTART	TXFEND		TXSCALE		TXFONT
%token <tokVal>	TXMVTOFLD
/*
 * "TXHEIGHT" and "TXWIDTH" are the current text height and width and are
 * global constants.
 */
%token <tokVal>	TXHEIGHT	TXWIDTH
/*
 * Justification points for text, are constants too.
 */
%token <tokVal> JLEFT_BOTTOM	JLEFT_BASE	JLEFT_CENTER	JLEFT_CAP
%token <tokVal> JLEFT_TOP	JCENTER_BOTTOM	JCENTER_BASE	JCENTER_CENTER
%token <tokVal> JCENTER_CAP	JCENTER_TOP	JRIGHT_BOTTOM	JRIGHT_BASE
%token <tokVal> JRIGHT_CENTER	JRIGHT_CAP	JRIGHT_TOP
/*
 * Keywords for settings during execution.
 */
%token <tokVal>	VERBOSE		SILENT		SET		VW_CONE_ANGLE
%token <tokVal>	LOGFILE		INCLUDE
/*
 * Keywords for header during execution.
 */
%token <tokVal>	ZCLIP		ENVELOPE
/*
 * Misc.
 */
%token <tokVal>	VARIABLE	VD_FUNCTION	VD_NOT
%token <tokVal>	UNKNOWN_KWRD 	BAD_CHAR
%token <tokVal> PRC_TRANS_A	PRC_TRANS_B	PRC_TRANS_C	PRC_TRANS_D
%token <tokVal> SET_TRANS_A	SET_TRANS_B	SET_TRANS_C	SET_TRANS_D
%right <tokVal>	ASSIGN
%left <tokVal>	VD_OR
%left <tokVal>	VD_AND
%left <tokVal>	'='	VD_NE
%left <tokVal>	VD_LE	VD_GE	VD_LT	VD_GT
%left <tokVal>	'+'	'-'
%left <tokVal>	'*'	'/'
%nonassoc	VD_NOT	','
%right		VD_UMINUS
%left <tokVal>	VD_POW
%start init
/*-------------------------------------------------------------------------*/
/*---------------------------- Grammar -------------------------------------*/
%%
init		: {  /* Initialize local variables */
			noEval.type = VD_string;
			strcpy( noEval._sval, "(not evaluated)");
			outputArgLst = NULL;
			alreadyFilled = NULL;
			*msg = MSSUCC;
			VD_drwInitVarTable();
			VD_drwSetLinePrefix (VD_drwPrintLinePrefix); 

			/* Initialize data structures */
			VD_drwInitParser (&xData, inp, macInfo, 
							&elmProcessed, &X);
			xData.library.bufsiz=0;
			if( X ){
			  if( ! xData.parsedElmType ){
			    VD_drwEndParser(&xData,inp,macInfo,elmProcessed);
			    return yynerrs;
			  }
			}
		}
		program {
			VD_drwEndParser (&xData, inp, macInfo, elmProcessed);
			/* return number of syntax errors */
			return yynerrs;
		}
		;

program 	: header
		| header body
		| header body local_settings
		| header body local_settings ';'
		| error		
			{ ABORT ("cannot recover from syntax errors ");}
		;

header		: selection
		| hdr_settings selection
		| hdr_settings ';' selection
		;

hdr_settings	: ';'					{$$ = -1;}
		| hdr_setting
		| hdr_settings ';' hdr_setting		{$$ = $3;}
		| hdr_settings ';' ';'			{$$ = -1;} 
		| hdr_settings	
				{ if ($1 != -1)
				      S_WARN1 ("Missing `;' after %s keyword\n",
								KWRD($1));}
	  	  hdr_setting				{$$ = $3;}
		;

hdr_setting	: setting
		| ZCLIP		{ $$ = $1.type;
				xData.processFlags |= VD_drwZClipActive;}

		| ENVELOPE 	{ $$ = $1.type;
				xData.processFlags |= VD_drwCheckEnvelopes;}
		;

body		: section
		| body section
		;

section		: selection
		| local_settings selection
		| local_settings ';' selection
		;

local_settings	: ';'					{$$ = -1;}
		| setting
		| local_settings ';' setting		{$$ = $3;}
		| local_settings ';' ';'		{$$ = -1;}
		| local_settings	
				{ if ($1 != -1)
				      S_WARN1 ("Missing `;' after %s keyword\n",
								KWRD($1));}
	  	  setting				{$$ = $3;}
			
		;
setting		: VERBOSE {
			$$ = $1.type;

			/* ignore if verbose already  enabled */
			if( xData.verbose ) break;

			xData.verbose = TRUE ;
			if ( macInfo) {
				/* write file name */
				if (!VerbInit)
					PRINTF ("\n>> File %s\n", FILE_NAME);
				else 
					LOG_PRINT (" ^^^ verbose on:  %s\n", 
								FILE_NAME);
				}
			else {
				/* write object id and file name */
				if (!VerbInit)
					PRINTF("\n>> Object %d, %d - File %s\n",
					   inp->elmId->osnum, inp->elmId->objid,
					   FILE_NAME);
				else 
					LOG_PRINT (" ^^^ verbose: Object %d, %d - File %s\n",
					   inp->elmId->osnum, inp->elmId->objid,
					   FILE_NAME);
				}
			VerbInit++;
		}
		| SILENT {
			$$ = $1.type;
			/* ignore if already silent */
			if( !xData.verbose ) break;
			xData.verbose = FALSE ;
			LOG_PRINT (" ^^^ verbose off\n\t.....\n");
		}
		| SET VW_CONE_ANGLE exp {
			$$ = $1.type;
			if( !X ) break;
			d = DBL( &$3);
			xData.overrides.viewConeAngle = d;
			IFVERB
			    TRACE1("Setting view cone angle to %g degrees\n",d);
		}
		| SET LOGFILE exp {
			/*
			 * Close previously opened log file if any (ie. if it
			 * is not  stdout). And set the new log file pointer.
			 * The log file will not be closed in `yyparse' since
			 * a syntax error may cause to exit `yyparse' at
			 * any point, thus leaving the log file opened.
			 * Instead the log file is closed by the function which
			 * called `yyparse' with `VD_drwCloseLogFile()'.
			 */
			$$ = $1.type;
			STR( &$3, s);
			xData.logFile = VD_drwOpenLogFile( s);
		}
		| INCLUDE VD_STRING {

			$$ = $1.type;
			/*
			 * "include" statement: divert Lex's input to
			 * the new file, stacking the one being read.
			 */
			if( !VD_drwPushInputFile( $2._sval,
						 xData.verbose,
						 &inp->inputFiles ) ) {
				S_ERR1 ("Include file not found: %s\n",
								$2._sval);
			}
			/*
			 * The input stream will be set to the next file
			 * but the ';' ending the "include" statement
			 * will only be eaten up by Lex when we return
			 * from this file. This missing ';' will cause
			 * a syntax error in the new file; to prevent
			 * this we force a ';' into Lex's input buffer.
			 */
			VD_drwLexUnput( ';');
		}
		| VARIABLE ASSIGN expounit {
			$$ = $1.type;
			if( X ) {
				VD_drwSetVarVal( $1._sval, &$3);
				IFVERB VD_drwVerbVar( 1, $1._sval, &$3);
				}
		}
		| VARIABLE error {
			S_ERR ("Missing assignment operator `:='");
		} expounit
			{ $$ = $1.type; }
		| PRC_TRANS_A {
			$$ = $1.type;
			if( X ) {
			  xData.selectMask = VD_K_drwLevel_1;
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Global Transparent Level A\n");
			}
		}
		| PRC_TRANS_B {
			$$ = $1.type;
			if( X ) {
			  xData.selectMask = VD_K_drwLevel_2;
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Global Transparent Level B\n");
			}
		}
		| PRC_TRANS_C {
			$$ = $1.type;
			if( X ) {
			  xData.selectMask = VD_K_drwLevel_3;
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Global Transparent Level C\n");
			}
		}
		| PRC_TRANS_D {
			$$ = $1.type;
			if( X ) {
			  xData.selectMask = VD_K_drwLevel_4;
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Global Transparent Level D\n");
			}
		}
		| SET_TRANS_A {
			$$ = $1.type;
			if( X ) {
			  VD_drwSetTransMode( msg,inp,&xData,VD_K_drwLevel_1 );
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Set Object Transparent Level A\n");
			}
		}
		| SET_TRANS_B {
			$$ = $1.type;
			if( X ) {
			  VD_drwSetTransMode( msg,inp,&xData,VD_K_drwLevel_2 );
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Set Object Transparent Level B\n");
			}
		}
		| SET_TRANS_C {
			$$ = $1.type;
			if( X ) {
			  VD_drwSetTransMode( msg,inp,&xData,VD_K_drwLevel_3 );
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Set Object Transparent Level C\n");
			}
		}
		| SET_TRANS_D {
			$$ = $1.type;
			if( X ) {
			  VD_drwSetTransMode( msg,inp,&xData,VD_K_drwLevel_4 );
			  if( !xData.verbose ) break;
			  LOG_PRINT (" *-* Set Object Transparent Level D\n");
			}
		}
		| UNKNOWN_KWRD
			{S_ERR1("Unknown setting keyword: %s\n", $1._sval );}

		;

selection	: elementType '{' selection_body '}' 
			{/* RULE ADDED by AD */
			/* Restore execution flag.  */
			if( macInfo ) break;
			X = elmProcessed ? FALSE : configX;
			}
		;

/* RULE ADDED by AD */
			/*
			 * info_direct <- odrawinginfo directives  ADDED by AD.
			 */
selection_body	: /* empty */			/* TR179800593 */
                | odrawinginfo directives
		| odrawinginfo actions
	/*	| odrawinginfo actions ';' */ 
		| odrawinginfo directives error
		| odrawinginfo actions error
		;
/* RULE ADDED by AD */

odrawinginfo	: /* Void */ {
			if ( macInfo && VERB )
				TRACE1("Element type: %s\n",
							xData.parsedElmDesc);
		}

/* ADDED BY Ad */
		| WITH  { 
			IFMVERB {
				TRACE1("Element type: %s\n",
							xData.parsedElmDesc);
				TRACE( "Extract with attributes");
				}
			}
		  attributes {
			if( macInfo )
				if( !VD_drwAddMacDrwName (*macInfo, "dummy"))
					ABORT("Cannot allocate memory");
				}
/* END ADDED BY Ad */

		| drawinginfo
		;

drawinginfo	: EXTRACT AS VD_STRING {
			if( macInfo ) {
			    if( strlen( $3._sval ) >= macro_MAX_CHAR ) {
		 		WARN2 ("Macro names cannot exceed %d characters: <%s> truncated\n",
	                         macro_MAX_CHAR - 1, $3._sval ) ;
					$3._sval[macro_MAX_CHAR-1] = '\0';
				}
			    IFVERB {
				TRACE1("Element type: %s\n",
							xData.parsedElmDesc);
			      	TRACE1 ("Extract as '%s'\n", $3._sval);
				}
			    if( !VD_drwAddMacDrwName( *macInfo, $3._sval ) )
				ABORT("Cannot allocate memory");
			    }
		} owithattr ';'
		;

owithattr	: /* Void */
		| WITH attributes
		;

attributes	: attribute
		| attributes ',' attribute
		;

attribute	: VD_STRING {
			if( macInfo ) {
				IFVERB LOG_PRINT("\t > with '%s'\n", $1._sval);
				if (!VD_drwAddAttrToMacInfo(*macInfo,$1._sval))
					ABORT("Cannot allocate memory");
				}
		}
		;

elementType	: ELMTYPE ':' {
			if( X || macInfo ) {
				$$.tok = $1.type;
				/* Save element type keyword in ElmDesc */
				strcpy( xData.parsedElmDesc, $1._sval);
				xData.elmQuery = $1.action.any;
				}

#ifdef	AAA
			if( X ) {
				/* Save element type as parseredElemDesc */
				strcpy( xData.parsedElmDesc, $1._sval);
				/* Get constDefName and parsedElmType */
				(*(VD_drwElmQuery)xData.elmQuery)(
						VD_drwQueryType, inp, &xData);
				}
#endif

			/* Save execution flag on YACC stack
			 *	If object does not match the elementType filter,
			 *	X will be set to FALSE, i.e. all directives
			 *	and actions for this element type will not
			 *	execute.
			 */
			configX = X;
			X = VD_drwProcessType (&xData, inp, macInfo,
							&elmProcessed, X);
			if (X == -1) ABORT("Cannot allocate memory");
		}

/* New rule - Ted */
		| ELMTYPE '(' VD_STRING ')' ':'{

			if( X || macInfo ) {
				$$.tok = $1.type;
				/* Save element type keyword in ElmDesc */
				strcpy( xData.parsedElmDesc, $1._sval);
				xData.elmQuery = $1.action.any;
				}
#ifdef	AAA
			if( X ) {
				/* Save element type as parseredElemDesc */
				strcpy( xData.parsedElmDesc, $1._sval);

				/* Get constDefName and parsedElmType */
			 	(*(VD_drwElmQuery)xData.elmQuery)(
						VD_drwQueryType, inp, &xData);
				}
#endif

			/* Save execution flag on YACC stack
			 *	If object does not match the elementType filter,
			 *	X will be set to FALSE, i.e. all directives
			 *	and actions for this element type will not
			 *	execute.
			 */
			configX = X;
			X = VD_drwProcessType (&xData, inp, macInfo,
							&elmProcessed, X);
			if (X == -1) ABORT("Cannot allocate memory");

			/* Check graphics name */
			if (X) {
				/* Set filter name for graphics */
				strcpy (xData.filter, $3._sval);

				X = VD_drwProcessGraType (&xData, inp, macInfo,
							&elmProcessed, X);
				}
		}
		| const	':'	{
			if( X )  $$ = $1 ;
			/* Save element type keyword in ElmDesc */
			strcpy( xData.parsedElmDesc, $1.txt);

			/* Save execution flag on YACC stack
			 *	If object does not match the elementType filter,
			 *	X will be set to FALSE, i.e. all directives
			 *	and actions for this element type will not
			 *	execute.
			 */
			configX = X;
			X = VD_drwProcessType (&xData, inp, macInfo,
							&elmProcessed, X);
			if (X == -1) ABORT("Cannot allocate memory");
		}

		| UNKNOWN_KWRD ':'
			{ strcpy( xData.parsedElmDesc, "invalid");
			ERR_KWRD("element type", $1._sval, ELMTYPE); }

		| UNKNOWN_KWRD  '(' VD_STRING ')' ':'
			{ strcpy( xData.parsedElmDesc, "invalid");
			ERR_KWRD("element type", $1._sval, ELMTYPE); }
		;

const		: CONST '(' DEFINITION	'=' VD_STRING ',' {
			if( X || macInfo ) {
				int	trunc;
				VD_strncpy (xData.filter, $5._sval,
						sizeof( GRname ), &trunc);
				}
			/*ALAIN*/
			$2._ival = X;
			if( X ) {
				strcpy( xData.parsedElmDesc, $1._sval);
#ifdef	AAA
				(*(VD_drwElmQuery)$1.action.any)
						( VD_drwQueryType, inp, &xData);
#endif

				X = 0 != xData.parsedElmType &&
				   VD_matchRE(xData.filter, inp->constDefName);
				}
			/*ALAIN*/
			*xData.viewCriterion = '\0';

		} view_criterion ')' {
			$$.tok = $1.type;
			strcpy( $$.txt, $1._sval);
			xData.elmQuery = $1.action.any;

			/*ALAIN*/
			X = $2._ival;
			/*ALAIN*/
		}
		;

view_criterion	: VIEW_CRITERION '=' exp {
		  if( X ) {
		   	int	trunc;
		  	VD_strncpy( xData.viewCriterion, $3._sval,
						sizeof( GRname ), &trunc);
			}
		}
		| VIEW_CRITERIA	'=' view_pairs	{

		  if( X && !*xData.viewCriterion && xData.verbose ) {
		    if( VD_matchRE( xData.filter, inp->constDefName ) ) {
			WARN1 ("No view criterion found for '%s'\n",
						inp->constDefName);
		    }
		  }
		}
		;

view_pairs	: view_pair
		| view_pairs ',' view_pair
		;

view_pair	: VD_STRING '/' VD_STRING {

		  if( X && !*xData.viewCriterion ) {
		    if( VD_matchRE( $1._sval, inp->constDefName ) ) {

			int	trunc;
			VD_strncpy( xData.viewCriterion, $3._sval,
				 sizeof( GRname ), &trunc);
		    }
		  }
		}
		;

directives	: viewSelection
		| directives viewSelection
		;

viewSelection	: viewTypes ':' {

			VD_drwViewType vt;

			if( macInfo ) break;

			/* Memorize execution flag, and do not proceed with this
			* action if execution has been turned off.
			*/
			$2._ival = X;
			if( !X ) break;

			$$ = X;
			xData.parsedViewType = $1;

			/*
			 * Check if we have the view type of the object.
			 * If not get the value.
			 */
			vt = inp->viewType;
			if( vt == VD_notDefinedType ){
				(*(VD_drwElmQuery)xData.elmQuery)(
						VD_drwQueryView, inp, &xData );
				vt = inp->viewType;
			}

			/* Go on executing if the view of the element is
		         * compatible with the one corresponding
	                 * to this action.
			 */
			X = ( (int) $1 & (int) vt ) != 0;
			if( !X ) break;

			xData.parsedViewType = vt;
			IFVERB
				TRACE1( "View %s\n", VD_drwVerbViewType( vt ));

		} '{' actions '}' {
			if( macInfo ) break;
			X = $2._ival;
		}
		;

viewTypes	: viewType			{ if( X ) $$ = $1 ; }
		| viewTypes ',' viewType	{
			if( X ) $$ = (VD_drwViewType) (   (unsigned) $1
							| (unsigned) $3);
		}
		;

viewType	: TOP		{ if( X ) $$ = VD_fromTop	; }
		| BOTTOM	{ if( X ) $$ = VD_fromBottom	; }
		| SIDE		{ if( X ) $$ = VD_fromSide	; }
		| ENDON		{ if( X ) $$ = VD_endOn		; }
		| UNKNOWN_VIEW	{ if( X ) $$ = VD_unknownViewType; }
		| ANY_VIEW	{ if( X ) $$ = VD_anyViewType    ; }
		| OTHER_VIEW	{ if( X ) $$ = $1.action.view   ; }
		;

actions		: action_list
		| action_list ';'
		;

action_list	: ';'				{$$ = -1;}
		| action			{$$ = 1;}
		| action_list ';' action	{$$ = 1;}
		| action_list ';' ';'		{$$ = -1;}
		| action_list 		
				{ if ($1 != -1)
					S_WARN ("Missing `;' after action"); }
		  action	{$$ = 1;}
		;

action		: anchor_point			
		| anchor_curve		
		| output		{ xData.symbOverrides = 0 ; /* Reset */}
		| selection
		| setting
		;

anchor_point	: ANCHOR_POINT '(' exp ')' {
			if( X ) {
			  STR( &$3, s);
			  VD_drwAnchorPoint( msg, inp, &xData, s,
						  VD_drwAnchorCtrOfBox);
			  IFVERB VD_drwVerbAnchor( s, VD_drwAnchorCtrOfBox);
			}
		}
		| ANCHOR_POINT '(' exp ',' which_point ')' {
			if( X ) {
			  STR( &$3, s);
			  VD_drwAnchorPoint( msg, inp, &xData, s, $5);
			  IFVERB VD_drwVerbAnchor( s, $5);
			}
		}
		;

which_point	: CENTER	{ $$ = VD_drwAnchorCenter	; }
		| CTR_OF_GRV	{ $$ = VD_drwAnchorCtrOfGrv	; }
		| AVERAGE_POINT	{ $$ = VD_drwAnchorCtrOfBox	; }
		;

anchor_curve	: ANCHOR_CURVE '(' exp ')' {
			if( X ) {
				IFVERB {
					TRACE( "Anchor curve ");
					VD_drwVerbValue( "%@\n", &$3);
				}
				VD_drwAnchorCurve( msg, inp, &xData, &$3);
			}
		}
		;


output		: graphic	{

#		    ifndef PARSER_ONLY
			if( !X ) break;

			/* print Output symbology */
#			ifdef PARSER_SYMB
			VD_drwPrintSymbology ("Output", xData);
#			endif

			VD_drwOutputGraphic( msg, inp, &xData, $1, FALSE,
					    outputArgLst, output);
			if( !(*msg & 1) )
				WARN1 ("Construction of graphics failed: %s\n",
							xData.parsedElmDesc);
			VD_drwFreeArglist( outputArgLst);
			outputArgLst = NULL;

			/* Reset local overrides to the input defaults */
			VD_drwResetSymbology ( &xData, &(DEF));
#		    endif

		}
		| symbol	{

#		    ifndef PARSER_ONLY
			if( !X ) break;

			if( xData.textFormat.curpos &&
						*xData.textFormat.buffer) {
				VD_drwOutputGraphic( msg, inp, &xData, "symbol",
					TRUE, (VD_drwArgLst*) NULL, output);
				if( !(*msg & 1) )
					WARN ("Construction of symbol failed");
			} else {
				WARN ("Empty text : symbol not constructed");
			}
			VD_drwTxFree( &xData.textFormat);
#		    endif
		}
		| database_update
		| UNKNOWN_KWRD '[' { 
			ERR_KWRD("output", $1._sval, GROUTPUT );
			}
		  err_body 
			{IFXVERB TRACE( "End (Invalid output keyword)\n"); }
		;

graphic		: outputType {
			strcpy( $$, $1.txt);
			IFXVERB
				VD_drwVerbOutput( $1.txt, outputArgLst, FALSE);
		}
		| outputType '[' {
			/* Reset local overrides to the input defaults */
			 if( X ) VD_drwResetSymbology ( &xData, &(DEF));

			strcpy( $$, $1.txt);
			IFXVERB {
				$1.val = yylineno;
				VD_drwVerbOutput( $1.txt, outputArgLst, TRUE);
				}
			} 
		  gr_body 
			{IFXVERB TRACE2( "End (%s at %d)\n", $1.txt, $1.val);}

		;

symbol		: symbolType '[' {
			if( X ) {
				IFVERB {
					$1.val = yylineno;
					TRACE1 ("Output %s with\n", 
								KWRD( $1.tok ));
					}
				/* Init local overrides to the input default */
				LOC.textSymb		= DEF.textSymb;
				LOC.textPos		= DEF.textPos;
				VD_drwResetSymbology ( &xData, &(DEF));
				VD_drwTxInit( &xData.textFormat);
				}
			}
		  txt_body {
			IFXVERB TRACE2 ("End (%s at %d)\n",
							KWRD($1.tok), $1.val);
			}
		;

database_update	: UPDATE_DB '[' STATEMENT '=' exp ']' {
			if( X ) {
			 	STR( &$5, s);
				IFVERB TRACE1( "Database update '%s'\n", s);
			  	VD_drwUpdateDatabase( &xData, s);
				}
		}
		;

outputType	: GROUTPUT	{
			if( X ) {
				$$.tok = $1.type;
				strcpy( $$.txt, $1._sval);
				xData.action = $1.action.any;
				outputArgLst = NULL;
			}
		}
		| GROUTPUT '(' oarglist ')' {
			if( X ) {
				IFVERB TRACE1 ("GROUTPUT+args: %s \n",$1._sval);
				$$.tok = $1.type;
				strcpy( $$.txt, $1._sval);
				xData.action = $1.action.any;
				outputArgLst = $3;
			}
		}
		;

symbolType	: SYMBOL	{
			if( X ) { $$.tok = $1.type;
				IFVERB TRACE ( "SYMBOL ...");
			}
		}
		;

err_body 	: err_attrs ']'
		| err_attrs ',' ']'
			{S_WARN ("Extra ',' after last attribute");}
		| err_attrs error ']'
		;


gr_body 	: gr_attrs ']'
		| gr_attrs ',' ']'
			{S_WARN ("Extra ',' after last graphic attribute");}
		| gr_attrs error ']'
		;


txt_body		: txt_attrs ']'
		| txt_attrs ',' ']'
			{S_WARN ("Extra ',' after last textual attribute");}
		| txt_attrs error ']'
		;

err_attrs	: err_attr
		| err_attrs ',' err_attr
		| err_attrs
			{S_WARN ("Missing `,' after attribute");}
		  err_attr
		;

gr_attrs	: gr_attr
		| gr_attrs ',' gr_attr
		| gr_attrs
			{S_WARN ("Missing `,' after graphical attribute");}
		  gr_attr
		;

txt_attrs	: txt_attr
		| txt_attrs ',' txt_attr
		| txt_attrs
			{S_WARN ("Missing `,' after textual attribute");}
		  txt_attr
		;

gr_attr		: /* empty */                   /* TR179800593 */
		| symb_attr
		| scale
		| offset
		| tag
		| FILLED_DISPLAY 
			{ if( X ) LOC.dpAttr.filledDisplay = TRUE; }
		;

txt_attr	: symb_attr
		| font
		| library
		| format
		| just
		| size
		| width
		| height
		| position
		;

err_attr	: symb_attr
		| font
		| library
		| format
		| just
		| size
		| width
		| height
		| position
		| scale
		| offset
		| tag
		| FILLED_DISPLAY 
			{ if( X ) LOC.dpAttr.filledDisplay = TRUE;}
		;

symb_attr	: color
		| style
		| weight
		| level
		| UNKNOWN_KWRD 	{ S_ERR1 ("Unknown attribute: %s\n", $1._sval);}
		;

color		: COLOR '=' exp {
			if( !X ) break;
			VD_drwSetColor ($1.type, &$3, &xData);
		}
		| HIDDEN_COLOR '=' exp {
			if( !X ) break;
			VD_drwSetColor ($1.type, &$3, &xData);
		}
		;

style		: STYLE '=' exp {
			if( !X ) break;
			VD_drwSetStyle ($1.type, INT(&$3), &xData);

		}
		| HIDDEN_STYLE '=' exp {
			if( !X ) break;
			VD_drwSetStyle ($1.type, INT(&$3), &xData);
		}
		;

weight		: WEIGHT '=' exp {
			if( !X ) break;
			VD_drwSetWeight ($1.type, INT(&$3), &xData);
		}
		| HIDDEN_WEIGHT '=' exp {
			if( !X ) break;
			VD_drwSetWeight ($1.type, INT(&$3), &xData);
		}
		;

level		: LEVEL '=' exp {
			if( !X ) break;
			VD_drwSetLevel ($1.type, INT(&$3), &xData);
		}
		| HIDDEN_LEVEL '=' exp {
			if( !X ) break;
			VD_drwSetLevel ($1.type, INT(&$3), &xData);
		}
		;


scale		: SCALE '=' exp {
			if( X ) {
			    d = DABS( &$3);

				if( 0 == d ) d = 1;
				LOC.dpAttr.scale = d;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		;

offset		: OFFSET '=' expounit {
			if( X ) {
					d = DBL( &$3);
				LOC.dpAttr.offset = d;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		;

tag		: TAG '=' exp { xData.tag = $3 ; }
		;

font		: FONT '=' exp {
			if( X ) {
				/*
				 * Find font.
				 */
				short	ftPos;

				STR( &$3, s);
				IFVERB {
					VD_drwPrtItem( $1.type, VD_string, s);
				}
				VD_retrieveFont( msg, s, &ftPos);
				if( VERB && EMS_I_Fail == *msg ) {
				    WARN1 (
				       "Font %s not found, using default font\n"
					,s);
				}
				xData.overrides.textSymb.Active_font = ftPos;
			}
		}
		;

library         : LIBRARY {
                        IFXVERB {
                                $1._ival = yylineno;
                                VD_drwPrtItem( $1.type, VD_string, NULL);
                        }
                }
                  '=' '(' textseqs ')'  {
                        if( X ) {
                                xData.library = $5;
                                alreadyFilled    = NULL;
                                IFVERB TRACE2 ("End (%s at %d)\n",
                                                KWRD( $1.type ), $1._ival);
                        }
                }
                ;

format		: FORMAT {
			IFXVERB {
				$1._ival = yylineno;
				VD_drwPrtItem( $1.type, VD_string, NULL);
			}
		}
		  '=' '(' textseqs ')'	{
			if( X ) {
				xData.textFormat = $5;
				alreadyFilled	 = NULL;
				IFVERB TRACE2 ("End (%s at %d)\n",
						KWRD( $1.type ), $1._ival);
			}
		}
		;

textseqs	: textseq		{ if( X ) $$ = $1 ;	}
		| textseqs ','		{ alreadyFilled = &$1 ; }
		  textseq	{
			if (!X) break;
			VD_drwTxMERGE( &$1, &$4, &$$);
			alreadyFilled = NULL;
		}
		;

textseq		: exp			{
			if( X ) {
				VD_drwTxINITSTRING( &$$, STR( &$1, s ));
				IFVERB {
					VD_drwIndent();
					PRINTF (" > string = '%s'\n", s);
				}
			}
		}
		| textcmd		{ if( X ) $$ = $1 ; }
		;

textcmd		: TXUP		'(' expounit ')'	{

			if( !X ) break;
			VD_drwTxMOVE( &$$, 'v',   d = DABS( &$3 ));

			IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
		}
		| TXDOWN	'(' expounit ')'	{
			if( !X ) break;
			d = DABS( &$3);
			VD_drwTxMOVE( &$$, 'v', - d);
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
		}
		| TXLEFT	'(' expounit ')'	{
			if( !X ) break;
			d = DABS( &$3);
			VD_drwTxMOVE( &$$, 'h', - d);
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
		}
		| TXRIGHT	'(' expounit ')'	{
			if( !X ) break;
			VD_drwTxMOVE( &$$, 'h', d =  DABS( &$3 ));
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
		}
		| TXSCALE	'(' exp ')'		{
			if( !X ) break;
			VD_drwTxMOVE( &$$, 's', d =  DABS( &$3 ));
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
		}
		| TXFSTART	'(' exp  ')'		{
			if( !X ) break;
			VD_drwTxFSTART( &$$, i = IABS( &$3 ));
			IFVERB VD_drwPrtItem( $1.type, VD_int, &i);
		}
		| TXFEND				{
			if( !X ) break;
			VD_drwTxFEND( &$$);
			IFVERB VD_drwPrtItem( $1.type, VD_string, NULL);
		}
		| TXMVTOFLD	'(' exp ',' exp ')'	{

			int	just,
				j;

			if( !X ) break;

			j = just = INT( &$5);

			if( !VD_checkJustification( just ) ) {
				just = LEFT_BASE;
			}
			VD_drwTxMVTOFLD( &$$,
					alreadyFilled,
					i = IABS( &$3 ),
					just,
					&LOC.textSymb,
					&LOC.elmDisplay);
			IFVERB {
				if( j != just ) {
				   WARN2 ("Invalid justification: %d, defaulted to LEFT-BASE (just)\n"
								,j, just);
				}
				VD_drwPrtItem( $1.type, VD_int, &i);
			}
		}
		| TXFONT	'(' exp  ')'		{
			if( X ) {
				short ftPos;

				STR( &$3, s);
				IFVERB VD_drwPrtItem( $1.type, VD_string, s);

				VD_retrieveFont( msg, s, &ftPos);
				if( EMS_I_Fail == *msg ) {
					WARN1 ("Font %s not found, using default font\n", s);
				}
				VD_drwTxCHGFONT( &$$, ftPos);
			}
		}
		;

txjust		: JLEFT_BOTTOM		{ $$ = LEFT_BOTTOM	; }
		| JLEFT_BASE		{ $$ = LEFT_BASE	; }
		| JLEFT_CENTER		{ $$ = LEFT_CENTER	; }
		| JLEFT_CAP		{ $$ = LEFT_CAP		; }
		| JLEFT_TOP		{ $$ = LEFT_TOP		; }
		| JCENTER_BOTTOM	{ $$ = CENTER_BOTTOM	; }
		| JCENTER_BASE		{ $$ = CENTER_BASE	; }
		| JCENTER_CENTER	{ $$ = CENTER_CENTER	; }
		| JCENTER_CAP		{ $$ = CENTER_CAP	; }
		| JCENTER_TOP		{ $$ = CENTER_TOP	; }
		| JRIGHT_BOTTOM		{ $$ = RIGHT_BOTTOM	; }
		| JRIGHT_BASE		{ $$ = RIGHT_BASE	; }
		| JRIGHT_CENTER		{ $$ = RIGHT_CENTER	; }
		| JRIGHT_CAP		{ $$ = RIGHT_CAP	; }
		| JRIGHT_TOP		{ $$ = RIGHT_TOP	; }
		;

just		: JUST '=' exp		{
			int	j;

			if( !X ) break;

			i = j = INT( &$3);
			if( !VD_checkJustification( i ) ) j = LEFT_BASE;

			LOC.textSymb.Active_just = j;

			IFVERB {
				if( i != j ) {
					WARN2 ("Invalid justification: %d, defaulted to LEFT-BASE (%d)\n"
									, i, j);
				}
				VD_drwPrtItem( $1.type, VD_string,
						KWRD( VD_drwJustToTokNum( j ) ));
			}
		}
		;

size		: SIZE '=' expounit	{
			if( X ) {
				d = DABS( &$3);

				LOC.textSymb.Active_width =
				LOC.textSymb.Active_height= d;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		;

width		: WIDTH '=' expounit	{
			if( X ) {
				d = DABS( &$3);

				LOC.textSymb.Active_width = d;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		;

height		: HEIGHT '=' expounit	{
			if( X ) {
				d = DABS( &$3);

				LOC.textSymb.Active_height = d;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		;

expounit	: exp		{ if( X ) $$ = $1 ; }
		| exp UNIT	{
			/*
			 * Convert user unit -> database (system) unit.
			 */
			if( X ) {
				char	unit[UOM_K_MAX_LEN];

				d = DBL( &$1);
				sprintf( unit, "%g %s", d, $2._sval);
				VD_unit2sys(msg,unit,GRIO_DISTANCE, &$$._dval);
				$$.type = VD_double;
				IFVERB TRACE2 ("Unit conversion: %s -> %g\n",
								unit, $$._dval);
			}
		}
		;

position	: POSITION '=' '(' {
			IFXVERB {
				$1._ival = yylineno;
				VD_drwPrtItem( $1.type, VD_string, NULL);
			}
		}
		  locations ')' {
			IFXVERB TRACE2 ("End (%s at %d)\n",
						KWRD( $1.type ), $1._ival);
		}
		;

locations	: location
		| locations ',' location
		;

location	: exp {
			VD_txPosType	posType;
			int		kwdType;
			if( !X ) break;

			i = INT( &$1);
			if( !VD_getTxPosType( i, &posType, &kwdType ) ) {
				IFVERB TRACE1(
				    "Invalid text position : %d, ignored\n", i);
			}
			switch( posType ) {
				case VD_txLoc :
					LOC.textPos.loc = (VD_drwTxLoc) i;
					break;
				case VD_txDir :
					LOC.textPos.dir = (VD_drwTxDir) i;
					break;
				case VD_txRev :
					LOC.textPos.rev = (VD_drwTxRev)
						(   (unsigned) LOC.textPos.rev
						  | i);
					break;
			}
			IFVERB PRINTF ("\t > %s\n", KWRD( kwdType ));
		}
		| OFFSET '(' exp ',' expounit ')' {
			int	kwdType,
				offType;

			if( !X ) break;
			i = INT( &$3);

			if( !VD_getTxOffType( i, &offType, &kwdType ) ) {
				WARN1 ("Invalid text offset direction : %d, ignored\n", i);
				break;
			}
			d = DABS( &$5);
			switch( offType ) {
				case VD_above	 :
				case VD_below	 :
				LOC.textPos.voff = (VD_drwVertTxOffset) offType;
				LOC.textPos.voffVal = d;
				break;
				case VD_toTheLeft :
				case VD_toTheRight:
				LOC.textPos.hoff = (VD_drwHoriTxOffset) offType;
				LOC.textPos.hoffVal = d;
				break;
			}
			IFVERB {
				PRINTF ("\t > offset direction : %s\n",
					 KWRD( kwdType ));
				VD_drwPrtItem( $1.type, VD_double, &d);
			}
		}
		| ABOVE '(' expounit ')'	{
			if( X ) {
				LOC.textPos.voff	= VD_above;
				LOC.textPos.voffVal	= d = DABS( &$3);
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		| BELOW	'(' expounit ')'	{
			if( X ) {
				LOC.textPos.voff	= VD_below;
				LOC.textPos.voffVal	= d = DABS( &$3);
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		| TOTHELEFT '(' expounit ')'	{
			if( X ) {
				LOC.textPos.hoff	= VD_toTheLeft;
				LOC.textPos.hoffVal	= d = DABS( &$3);
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
				}
		}
		| TOTHERIGHT '(' expounit ')'	{
			if( X ) {
				LOC.textPos.hoff	= VD_toTheRight;
				LOC.textPos.hoffVal	= d = DABS( &$3);
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d);
			}
		}
		;

selection	: SELECT {
			IFXVERB {
				$1._ival = yylineno;
				TRACE ( KWRD( $1.type ));
			}

		} selectors END {
			IFXVERB TRACE3 ( "%s (%s at %d)\n", KWRD( $4.type ),
					 KWRD( $1.type ), $1._ival);
		}
		;

selectors	: whens
		| whens {
			if( !macInfo ) {
				int	aWhenWasSatisfied = $1;

				$1 = X;
				if( X ) {
					X = !aWhenWasSatisfied;
				}
			}
		} otherwise {
			if( macInfo ) break;
			X = $1;
		}
		;

whens		: when			{ $$ = X ? $1 : FALSE ; }
		| whens {
			if( X &&  $1 )
				X = FALSE;
		} when	{
			if( macInfo ) break;
			if( $1 ) X = TRUE;
			$$ = $1 || $3;
		}
		;

when		: WHEN exp ':' {
			$3._ival = X;
			$1._ival = FALSE;
			if( X ) {
				int exec = BOOL( &$2);

				$1._ival = exec;
				if( !exec )
					X  = FALSE;
				IFVERB LOG_PRINT(" ? %s : %s\n", KWRD( $1.type ),
						exec ? "TRUE" : "FALSE");
				}
		} actions {
				if( macInfo ) break;
			X = $3._ival ; $$ = $1._ival;
		}
		;

otherwise	: OTHERWISE {
			IFXVERB
				LOG_PRINT(" + %s\n", KWRD( $1.type ));

		} ':' actions
		;

exp	: exp VD_LE  exp {
		if( X ) VD_relOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp VD_LT  exp {
		if( X ) VD_relOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp VD_GE  exp {
		if( X ) VD_relOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp VD_GT  exp {
		if( X ) VD_relOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp VD_NE  exp {
		if( X ) VD_relOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp '='    exp {
		if( X ) VD_relOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp VD_AND {
		$2._ival = X;
		if( X ) {
			/*
			 * Do not evaluate second operand if first was FALSE.
			 */
			if( !BOOL( &$1 ) ) {
				X = FALSE;
				$$.type = VD_int ; $$._ival = 0;
				IFVERB VD_drwVerbOp( VD_AND, &$1, &noEval, &$$);
			}
		}
	} exp {
		if( macInfo ) break;

		if( X ) VD_relOP( msg, VERB, VD_and, &$1, &$4, &$$);
		X = $2._ival;
	}
	| exp VD_OR {
		$2._ival = X;
		if( X ) {
			/*
			 * Do not evaluate second operand if first was TRUE.
			 */
			if( BOOL( &$1 ) ) {
				X = FALSE;
				$$.type = VD_int ; $$._ival = 1;
				IFVERB VD_drwVerbOp( VD_OR, &$1, &noEval, &$$);
			}
		}
	} exp {
		if( macInfo ) break;
		if( X ) VD_relOP( msg, VERB, VD_or, &$1, &$4, &$$);
		X = $2._ival;
	}
	| exp '+'    exp {
		if( X ) VD_binOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp '-'    exp {
		if( X ) VD_binOP( msg, VERB,$2._ival, &$1, &$3, &$$);
	}
	| exp '*'    exp {
		if( X ) VD_binOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp '/'    exp {
		if( X ) VD_binOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| exp VD_POW exp {
		if( X ) VD_binOP( msg, VERB, $2._ival, &$1, &$3, &$$);
	}
	| '-' exp %prec VD_UMINUS {
		if( X ) VD_unrOP( msg, VERB, $1._ival, &$2, &$$);
	}
	| VD_NOT exp {
		if( X ) VD_unrOP( msg, VERB, $1._ival, &$2, &$$);
	}
	| '(' exp ')'    { if( X ) $$ = $2 ; }

	| VD_FUNCTION '(' oarglist ')' {
		if( X ) {
			VD_drwExecFct( msg, inp, &xData, $1._sval,
					$1.action.function, $3, &$$);
			VD_drwFreeArglist( $3);

		}
	}
	| VARIABLE	{
		if( X ) {
			VD_drwGetVarVal( $1._sval, &$$);
			IFVERB VD_drwVerbVar( 0, $1._sval, &$$);
		}
	}
	| VARIABLE '[' exp ']' {
		if( X ) {
			VD_drwGetAryVal( $1._sval, &$3, &$$);
		}
	}
	| constant	{ if( X ) $$ = $1 ; }
	;

arg		: exp	{ if( X ) $$ = $1 ; }
		;

oarglist	: /* Void */		{ if( X ) $$ = NULL ; }
		| arglist		{ if( X ) $$ = $1   ; }
		;

arglist		: arg		  {
			if( X ) $$ = VD_drwAddArg( msg, &$1, NULL);
		}
		| arglist ',' arg {
			if( X ) $$ = VD_drwAddArg( msg, &$3, $1  );
		}
		;

constant	: VD_INT	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| VD_DOUBLE	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| VD_STRING	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| TXHEIGHT	{
			if( X ) {
				$$.type	= VD_double;
				$$._dval= LOC.textSymb.Active_height;
			}
		}
		| TXWIDTH	{
			if( X ) {
				$$.type	= VD_double;
				$$._dval= LOC.textSymb.Active_width;
			}
		}
		| txjust	{
			if( X ) {
				$$.type	= VD_int;
				$$._ival= $1;
			}
		}
		| txpos	{
			if( X ) {
				$$.type	= VD_int;
				$$._ival= $1;
			}
		}
		;


txpos		: TOP		{ $$ = (int) VD_top		; }
		| BOTTOM	{ $$ = (int) VD_bottom		; }
		| RIGHT		{ $$ = (int) VD_right		; }
		| LEFT		{ $$ = (int) VD_left		; }
		| AT1STEND	{ $$ = (int) VD_1stEnd		; }
		| AT2NDEND	{ $$ = (int) VD_2ndEnd		; }
		| CENTER	{ $$ = (int) VD_center		; }
		| MIDDLE	{ $$ = (int) VD_middle		; }
		| INNERMOST	{ $$ = (int) VD_innermost	; }
		| HORIZONTAL	{ $$ = (int) VD_horiz		; }
		| PARALLEL	{ $$ = (int) VD_para		; }
		| ORTHOGONAL	{ $$ = (int) VD_ortho		; }
		| NOTREVERSED	{ $$ = (int) VD_notReversed	; }
		| UPSIDEDOWN	{ $$ = (int) VD_upsideDown	; }
		| RIGHTTOLEFT	{ $$ = (int) VD_rightToLeft	; }
		;

%%
/*----------------------------------------------------------------------------*/
