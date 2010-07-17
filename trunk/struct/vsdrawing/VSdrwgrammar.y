%{
/*
	I/STRUCT
*/
#include <string.h>
#include <ctype.h>
#include <values.h>
#include <math.h>
#include "msdef.h"
#include "UOMdef.h"
#include "gotextdef.h"
#include "EMSmsgdef.h"
#include "vsiomacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "macro.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vslngopproto.h"
#include "vsstrngproto.h"

extern int		yylineno ;
extern char		yytext[] ;

/*
 * Conflict with include file "stdlib.h"
 * extern int           abs();
 */

/*
 * Short cuts.
 */
#define IFXVERB		if( X && xData.verbose )
#define IFVERB		if( xData.verbose )
#define LOC		xData.overrides
#define DEF		inp->defaults
#define KWRD( t )	VSdrwKwFromTokType( (t) )
#define	INT( x )	VSdrwIntVal( (x) )
#define	IABS( x )	abs( VSdrwIntVal( (x) ) )
#define BOOL( x )	VSdrwBoolVal( (x) )
#define DBL( x )	VSdrwDblVal( (x) )
#define DABS( x )	fabs( VSdrwDblVal( (x) ) )
#define STR( x, b )	VSdrwStrVal( (x), (b) )
#define PRINTF		VSdrwPrintf

/*
 * Add an argument to yyerror().
 */
#define yyerror( s )	yyError( (s), &xData )

/*
 * Call yylex with two arguments : the file pointer to the log file
 * if in verbose mode else NULL, and the stack of input files.
 */
#define yylex()		yyLex(	xData.verbose ? xData.logFile : NULL, \
				&inp->inputFiles )

/*
 * Add local variables to yyparse(), so as not to declare them as globals.
 */
#define LOCALVARS	\
	VSdrwExecData	xData ;		/* Execution data		*/ \
	int		X = TRUE ;	/* Execute ? (TRUE/FALSE)	*/ \
	double		d ;		/* Double buffer		*/ \
	int		i ;		/* Integer buffer		*/ \
	VStktxt		s ;		/* String buffer		*/ \
	VSdrwText	*alreadyFilled = NULL ;				   \
					/* Points to already filled text*/ \
	VSdrwVertTxOffset						   \
			vo ;		/* Vertical offset for text	*/ \
	VSdrwHoriTxOffset						   \
			ho ;		/* Horizontal offset for text	*/ \
	VSexecRes	noEval ;	/* Unevaluated result		*/ \
	int		elmProcessed = FALSE ;				   \
					/* TRUE if element was processed*/ \
	VSdrwArgLst	*outputArgLst = NULL ;
					/* Arg list of output statement */

/*
 * Add arguments and local variables to yyparse.
 * Note that the additional '}' will have to be closed in the makefile since
 * there is no way to add a supplementary ;}' to yyparse() from this .y file.
 * Note : if `macInfo' is not NULL, then only the information contained in
 * the statements specifying which attributes must be reported to the drawing
 * will be returned; in this case `output' may be NULL and only
 * `inp->cfgFile' needs to be set.
 */
#define yyparse(void)	VSdrwParse( msg, inp, macInfo, output )	\
			long		*msg ;			\
			VSdrwInputData	*inp ;			\
			VSdrwMacInfo	**macInfo ;		\
			VSdrwOutputData	**output ; {		\
				LOCALVARS

/*----------------------------------------------------------------------------*/
%}
%union {
	VSdrwViewType	viewTp ;	/* Mask of view types		*/
	VSdrwCaseOf	caseOf ;	/* Type selections		*/
	VSdrwAnchorType	anchTp ;	/* Anchor point type		*/
	int		xqtFlg ;	/* Saves 'execute' flag		*/
	int		txjust ;	/* Text justification		*/
	int		txtpos ;	/* Text position		*/
	VSexecRes	result ;	/* Result of an operation	*/
	VSdrwTOKEN	tokVal ;	/* Token as read by Lex		*/
	VSdrwArgLst	*argLst;	/* Arg. list for function call	*/
	VSdrwText	format ;	/* Format of text		*/
	VStktxt		string ;	/* Character string		*/
}

%type <result>	exp		expounit	constant	arg
%type <argLst>	oarglist	arglist
%type <viewTp>	viewType	viewTypes
%type <caseOf>	outputType	elementType	symbolType	const
%type <string>	graphic
%type <xqtFlg>	viewSelection	config		when		whens
%type <format>	textseqs	textseq		textcmd
%type <txjust>	txjust
%type <txtpos>	txpos
%type <anchTp>	which_point
/*
 * Graphic output.
 */
%token <tokVal>	GROUTPUT	SYMBOL
/*
 * Symbology.
 */
%token <tokVal> COLOR		STYLE		WEIGHT		LEVEL
/*
 * Database update 
 */
%token <tokVal> UPDATE_DB	STATEMENT
/*
 * Additional display modifiers for graphics (symbol/text excluded)
 */
%token <tokVal>	FILLED_DISPLAY	HIDDEN_STYLE	SCALE	
/*
 * Text attributes (subkeywords of "SYMBOL" keyword).
 */
%token <tokVal>	SIZE		WIDTH		HEIGHT		JUST
%token <tokVal>	FONT		POSITION	FORMAT
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
%token <tokVal>	VS_INT		VS_DOUBLE	VS_STRING	UNIT
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
 * Keyword for global setting during execution.
 */
%token <tokVal>	VERBOSE		SILENT		SET		VW_CONE_ANGLE
%token <tokVal>	LOGFILE		INCLUDE
/*
 * Miscelanious.
 */
%token <tokVal>	VARIABLE	VS_FUNCTION	VS_ERROR	VS_NOT
%right <tokVal>	ASSIGN
%left <tokVal>	VS_OR
%left <tokVal>	VS_AND
%left <tokVal>	'='	VS_NE
%left <tokVal>	VS_LE	VS_GE	VS_LT	VS_GT
%left <tokVal>	'+'	'-'
%left <tokVal>	'*'	'/'
%nonassoc	VS_NOT	','
%right		VS_UMINUS
%left <tokVal>	VS_POW
%start program
%%
program	: {

        *msg = MSSUCC ;
        VSdrwInitVarTable() ;
        noEval.type = VS_string ;
        strcpy( noEval._sval, "(not evaluated)" ) ;

        /*
         * If we are only extracting the attributes to be
         * reported to the drawing then we are not "executing".
         */
        if( macInfo )	{ X = FALSE ; *macInfo = NULL ; }
        else		{ X = TRUE  ; }

        xData.action		= (void (*)()) VSdrwUndefinedAction ;
        xData.elmQuery		= (void (*)()) VSdrwUndefinedAction ;
        xData.verbose		= FALSE ;
        *xData.viewCriterion	= '\0' ;
        *xData.filter		= '\0' ;
        xData.txPosHelper	= VSundefTxPosHelper ;
        xData.lastGraphic	= NULL ;
        xData.symbOverrides	= 0 ;

        /*
         * Do not forget to init garbage list to NULL !
         */
        xData.garbageList	= NULL ;

        /*
         * Init local overrides to the input default values.
         */
        LOC.viewConeAngle	= DEF.viewConeAngle ;
        LOC.dpAttr 		= DEF.dpAttr ;
        LOC.elmDisplay		= DEF.elmDisplay ;
        LOC.elmLevel		= DEF.elmLevel ;

        /*
         * The log file for the verbose mode is stdout by
         * default unless it is redefined with a
         *	"set logfile <filename>"
         * statement.
         */
        xData.logFile = stdout ;

        /*
         * Flag element as not processed, the flag will be set
         * to TRUE when the element passes a type selection criterion.
         */
        elmProcessed = FALSE ;

	outputArgLst = NULL ;

      } configs {

        /*
         * Collect garbage.
         */
        VSdrwCollectGarbage( &xData ) ;

        if( !macInfo && xData.verbose ) {
          if( !elmProcessed ) {
            VSdrwElmNotProcessed( xData.logFile, inp ) ;
          }
          fprintf( xData.logFile, ">> End object %d, %d\n\n",
                   inp->elmId->osnum, inp->elmId->objid ); 
        }
        if( macInfo && xData.verbose ) {
          fprintf( xData.logFile, ">> End file %s\n",
                   inp->inputFiles.name[inp->inputFiles.iScanned] ) ;
        }
      }
      ;

header		: hactions
		;

hactions	: haction
		| hactions ';' haction
		| hactions error haction {
			IFVERB PRINTF( "!!! Missing `;'\n" ) ; YYABORT ;
		}
		;

haction		: /* Void : empty header action */
		| global_setting
		| assignment
		| include
		;

global_setting	: VERBOSE	{
		int	prevVal = xData.verbose ;

		xData.verbose = TRUE  ;

		if( prevVal ) break ;

		if( !macInfo ) {
			fprintf( xData.logFile,
			    "\n>> Object %d, %d - File %s\n",
			    inp->elmId->osnum, inp->elmId->objid,
			    inp->inputFiles.name[inp->inputFiles.iScanned] ) ;
		} else {
			fprintf( xData.logFile, "\n>> File %s\n",
			    inp->inputFiles.name[inp->inputFiles.iScanned] ) ;
		}
	}
	| SILENT	{ xData.verbose = FALSE ; }
	| SET VW_CONE_ANGLE exp {

	     if( !X ) break ;
	     d = DBL( &$3 ) ;
	     xData.overrides.viewConeAngle = d ;
	     IFVERB PRINTF( "*-* Setting view cone angle to %g degrees\n", d ) ;
	}
	| SET LOGFILE exp {
		/*
		 * Close previously opened log file if any (ie. if it is not 
		 * stdout). And set the new log file pointer.The log file will 
		 * not be closed in `yyparse' since a syntax error may cause
		 * to exit `yyparse' at anypoint, thus leaving the log file
		 * opened. Instead the log file is closed by the function which
		 * called `yyparse' with `VSdrwCloseLogFile()'.
		 */
		STR( &$3, s ) ;
		xData.logFile = VSdrwOpenLogFile( s ) ;
	}
	;

configs		: header config
		| configs header config
		;

config	: elementType ':' {

/* OUT ALAIN
	  xData.parsedElmType = $1.val ;
OUT ALAIN */
	  strcpy( xData.parsedElmDesc, $1.txt ) ;

	  if( macInfo ) {

	    (*(VSdrwElmQuery)xData.elmQuery)( VSdrwQueryFilter, inp, &xData ) ;

	  } else if( X ) {
/*ALAIN OUT
	    (*(VSdrwElmQuery)xData.elmQuery)( VSdrwQueryType, inp, &xData ) ;
ALAIN OUT*/
	  }

	  /*
	   * Store execution flag.
	   */
	  $2._ival = X ;
	  if( X ) {
	    /*
	     * Is type of input element corresponding to
	     * that for which we are parsing code ?
	     */

	    X = 0 != xData.parsedElmType ;

	    /*
	     * If type is OK, are we processing a const (a macro
	     * occurrence) ? If so is the macro definition of the input
	     * const the same as that specified for the code
	     * we are parsing ?
	     */
	    if( X && VS_gI_InAsbly == xData.parsedElmType ) {
	      X = VSmatchRE( xData.filter, inp->constDefName ) ;
	    }
	    if( X ) {
	      IFVERB {
	        if( VS_gI_InAsbly == xData.parsedElmType ) {
		  PRINTF( "*-* Element type '%s( %s )'\n",
		          xData.parsedElmDesc, inp->constDefName ) ;
		  PRINTF( "*-* View criterion : '%s'\n", xData.viewCriterion ) ;
	        } else {
	          PRINTF( "*-* Element type '%s'\n", xData.parsedElmDesc ) ;
	        }
	      }
	      /*
	       * Element accepted : find its view.
	       */
	      elmProcessed = TRUE ;
	      (*(VSdrwElmQuery)xData.elmQuery)( VSdrwQueryView, inp, &xData ) ;

	    }
	  } else if( macInfo ) {
	    if( !VSdrwAddMacInfo( macInfo, xData.filter ) ) {
	      YYABORT ;
	    }
	  }

	} '{' odrawinginfo directives '}' {

 	  /*
	   * Restore execution flag.
	   */
	  if( macInfo ) break ;
		  	
	  X = elmProcessed ? FALSE : $2._ival ;

        }
	;

odrawinginfo : /* Void */ {

	       if( !macInfo ) break ;

	       IFVERB {
		 if( !strcmp( xData.parsedElmDesc, "const" ) ) {
		   PRINTF( "!!! No '%s' statement for %s( '%s' )\n",
		       	   KWRD( EXTRACT ), xData.parsedElmDesc,
		       	   xData.filter ) ;
		 } else {
		   PRINTF( "!!! No '%s' statement for %s\n",
		       	   KWRD( EXTRACT ), xData.parsedElmDesc ) ;
		 }
	       }
	     }
	     | drawinginfo
	     ;

drawinginfo : EXTRACT AS VS_STRING {

	      if( macInfo ) {
	        if( strlen( $3._sval ) >= macro_MAX_CHAR ) {
		  IFVERB PRINTF( "!!! Macro names cannot exceed %d characters: <%s> truncated\n",
	                         macro_MAX_CHAR - 1, $3._sval ) ;
		  $3._sval[macro_MAX_CHAR-1] = '\0' ;
		}
		IFVERB PRINTF( "*-* Extract as '%s'\n", $3._sval ) ;
		if( !VSdrwAddMacDrwName( *macInfo, $3._sval ) ) {
	          YYABORT ;
		}
	      }

	    } owithattr ';'
	    ;

owithattr	: /* Void */
		| WITH attributes
		;

attributes	: attribute
		| attributes ',' attribute
		;

attribute	: VS_STRING {
		  if( macInfo ) {
		    IFVERB PRINTF( "\t > with '%s'\n", $1._sval ) ;
		    if( !VSdrwAddAttrToMacInfo(	*macInfo, $1._sval ) ) {
		      YYABORT ;
		    }
		  }
		}
		;

elementType	: ELMTYPE	{
			if( X || macInfo ) { 
				$$.tok = $1.type ;
				strcpy( $$.txt, $1._sval ) ;
				xData.elmQuery = $1.action.any ;
			}
/*ALAIN*/
			if( X ) {
	  		  strcpy( xData.parsedElmDesc, $1._sval ) ;
			  (*(VSdrwElmQuery)xData.elmQuery)(
			  			VSdrwQueryType, inp, &xData ) ;
			}
/*ALAIN*/
		}
		| const		{

			if( X ) { $$ = $1 ; }
		}
		;

const : CONST '(' DEFINITION	'=' VS_STRING ',' {

        if( X || macInfo ) {
          int	trunc ;

	  VSstrncpy( xData.filter, $5._sval, sizeof( GRname ), &trunc ) ;
	}
/*ALAIN*/
	$2._ival = X ;
	if( X ) {
	    strcpy( xData.parsedElmDesc, $1._sval ) ;
	    (*(VSdrwElmQuery)$1.action.any)( VSdrwQueryType, inp, &xData ) ;
	    X = 0 != xData.parsedElmType && VSmatchRE(
	    				xData.filter, inp->constDefName ) ;
	}
/*ALAIN*/
	*xData.viewCriterion = '\0' ;

      } view_criterion ')' {

	$$.tok = $1.type ;
	strcpy( $$.txt, $1._sval ) ;
	xData.elmQuery = $1.action.any ;
/*ALAIN*/
	X = $2._ival ;
/*ALAIN*/
      }
      ;

view_criterion	: VIEW_CRITERION '=' exp {

		  if( X ) {
		    int	trunc ;
		    VSstrncpy( xData.viewCriterion, $3._sval, sizeof( GRname ),
			       &trunc ) ;
		  }
		}
		| VIEW_CRITERIA	'=' view_pairs	{

		  if( X && !*xData.viewCriterion && xData.verbose ) {
		    if( VSmatchRE( xData.filter, inp->constDefName ) ) {
		      PRINTF( "!!! No view criterion found for '%s'\n",
			      inp->constDefName ) ;
		    }
		  }
		}
		;

view_pairs	: view_pair
		| view_pairs ',' view_pair
		;

view_pair	: VS_STRING '/' VS_STRING {

		  if( X && !*xData.viewCriterion ) {
		    if( VSmatchRE( $1._sval, inp->constDefName ) ) {

		      int	trunc ;
		      VSstrncpy( xData.viewCriterion, $3._sval,
				 sizeof( GRname ), &trunc ) ;
		    }
		  } 
		}
		;

directives	: viewSelection
		| directives viewSelection
		;

viewSelection	: viewTypes ':' {

		     VSdrwViewType vt ;

		     if( macInfo ) break ;

		     /* Memorize execution flag, and do not proceed with this
		      * action if execution has been turned off.
		      */
		     $2._ival = X ;
		     if( !X ) break ;

		     $$ = X ;
		     xData.parsedViewType = $1 ;

		     vt = inp->viewType ;

		     /* Go on executing if the view of the element is compatible
		      * with the one corresponding to this action.
		      */
		     X = ( (int) $1 & (int) vt ) != 0 ;
		     if( !X ) break ;

		     xData.parsedViewType = vt ;
		     IFVERB PRINTF( "*-* View %s\n", VSdrwVerbViewType( vt ) ) ;
		}
		  '{' actions '}' {
		     if( macInfo ) break ;
		     X = $2._ival ;
		}
		;

viewTypes	: viewType			{ if( X ) $$ = $1 ; }
		| viewTypes ',' viewType	{
			if( X ) $$ = (VSdrwViewType) (   (unsigned) $1
						       | (unsigned) $3 ) ;
		}
		;

viewType	: TOP		{ if( X ) $$ = VSfromTop 	; }
		| BOTTOM	{ if( X ) $$ = VSfromBottom	; } 
		| SIDE		{ if( X ) $$ = VSfromSide	; }
		| ENDON		{ if( X ) $$ = VSendOn		; }
		| UNKNOWN_VIEW	{ if( X ) $$ = VSunknownViewType; }
		| ANY_VIEW	{ if( X ) $$ = VSanyViewType    ; }
		| OTHER_VIEW	{ if( X ) $$ = $1.action.view   ; }
		;

actions		: action 
		| actions ';' action
		| actions error action {
			IFVERB PRINTF( "!!! Missing `;'\n" ) ;
			YYABORT ;
		}
		;

action		: /* Void : empty action */
		| anchor_point
		| anchor_curve
		| output	{ xData.symbOverrides = 0 ; /* Reset */ }
		| assignment
		| include
		| selection
		| global_setting
		;

anchor_point	: ANCHOR_POINT '(' exp ')' {
			if( X ) {
			  STR( &$3, s ) ;
			  VSdrwAnchorPoint( msg, inp, &xData, s,
						  VSdrwAnchorCtrOfBox ) ;
			  IFVERB VSdrwVerbAnchor( s, VSdrwAnchorCtrOfBox ) ;
			}
		}
		| ANCHOR_POINT '(' exp ',' which_point ')' {
			if( X ) {
			  STR( &$3, s ) ;
			  VSdrwAnchorPoint( msg, inp, &xData, s, $5 ) ;
			  IFVERB VSdrwVerbAnchor( s, $5 ) ;
			}
		}
		;

which_point	: CENTER	{ $$ = VSdrwAnchorCenter	; }
		| CTR_OF_GRV	{ $$ = VSdrwAnchorCtrOfGrv	; }
		| AVERAGE_POINT	{ $$ = VSdrwAnchorCtrOfBox	; }
		;

anchor_curve	: ANCHOR_CURVE '(' exp ')' {
			if( X ) {
				IFVERB {
					PRINTF( "*-* Anchor curve " ) ;
					VSdrwVerbValue( "%@\n", &$3 ) ;
				}
				VSdrwAnchorCurve( msg, inp, &xData, &$3 ) ;
			}
		}
		;

include		: INCLUDE VS_STRING ';' {

			/*
			 * "include" statement: divert Lex's input to
			 * the new file, stacking the one being read.
			 */
			if( !VSdrwPushInputFile( $2._sval,
						 xData.verbose,
						 &inp->inputFiles ) ) {
				YYABORT ;
			}
			/*
			 * The input stream will be set to the next file
			 * but the ';' ending the "include" statement
			 * will only be eaten up by Lex when we return
			 * from this file. This missing ';' will cause
			 * a syntax error in the new file; to prevent
			 * this we force a ';' into Lex's input buffer.
			 */
			VSdrwLexUnput( ';' ) ;
		}
		;

assignment	: VARIABLE ASSIGN expounit {
		    if( X ) {
		      VSdrwSetVarVal( $1._sval, &$3 ) ;
		      IFVERB VSdrwVerbVar( 1, $1._sval, &$3 ) ;
		    }
		}
		| VARIABLE error {
		    IFVERB PRINTF( "!!! Expected `:=', got `%s'\n", yytext ) ;
		    YYABORT ;
		} expounit 
		;

output		: graphic	{
			if( !X ) break ;

			VSdrwOutputGraphic( msg, inp, &xData, $1, FALSE,
					    outputArgLst, output ) ;

			VSdrwFreeArglist( outputArgLst ) ;
			outputArgLst = NULL ;

			IFVERB if( !(*msg & 1) )
				PRINTF( "!!! Construction of graphics failed\n" ) ;
			/*
			 * Reset local overrides to the input default values.
			 */
			LOC.dpAttr 		= DEF.dpAttr ;
			LOC.elmDisplay		= DEF.elmDisplay ;
			LOC.elmLevel		= DEF.elmLevel ;

		}
		| symbol	{
			if( !X ) break ;

			if(    xData.textFormat.curpos
			    && *xData.textFormat.buffer ) {
			    	VSdrwOutputGraphic( msg, inp, &xData, "symbol",
			    		TRUE, (VSdrwArgLst*) NULL, output ) ;

				IFVERB if( !(*msg & 1) )
				PRINTF( "!!! Construction of symbol failed\n" );
			} else {
				PRINTF( "!!! Empty text : not constructed\n" ) ;
			}
			VSdrwTxFree( &xData.textFormat ) ;
		}
		| database_update
		;

graphic		: outputType {
			strcpy( $$, $1.txt ) ;
			IFXVERB {
				VSdrwVerbOutput( $1.txt, outputArgLst, FALSE ) ;
			}
		}
		| outputType {
			strcpy( $$, $1.txt ) ;
			IFXVERB {
				$1.val = yylineno ;
				VSdrwVerbOutput( $1.txt, outputArgLst, TRUE ) ;
			}
		}
		  grsetup {
			IFXVERB PRINTF( "*-* End (%s at %d)\n", $1.txt,
					 $1.val ) ;
		}
		;

symbol		: symbolType {
			IFXVERB {
				$1.val = yylineno ;
				PRINTF( "*-* Output %s with\n", KWRD( $1.tok ));
			}
		}
		  txsetup {
			IFXVERB {
				PRINTF( "*-* End (%s at %d)\n", KWRD( $1.tok ),
					$1.val ) ;
			}
		}
		;

database_update	: UPDATE_DB '[' STATEMENT '=' exp ']' {
			if( X ) {
			  STR( &$5, s ) ;
			  IFVERB PRINTF( "*-* Database update '%s'\n", s ) ;
			  VSdrwUpdateDatabase( &xData, s ) ;
			}
		}
		;

outputType	: GROUTPUT	{
			if( X ) {
				$$.tok = $1.type ;
				strcpy( $$.txt, $1._sval ) ;
				xData.action = $1.action.any ;
				outputArgLst = NULL ;
			}
		}
		| GROUTPUT '(' oarglist ')' {
			if( X ) {
				$$.tok = $1.type ;
				strcpy( $$.txt, $1._sval ) ;
				xData.action = $1.action.any ;
				outputArgLst = $3 ;
			}
		}
		;

symbolType	: SYMBOL	{
			if( X ) { $$.tok = $1.type ; }
		}
		;

grsetup		: '[' {
			if( X ) {
				/*
				 * Init local overrides to the input default
				 * values.
				 */
				LOC.dpAttr 		= DEF.dpAttr ;
				LOC.elmDisplay		= DEF.elmDisplay ;
				LOC.elmLevel		= DEF.elmLevel ;
			}
		}
		  grattributes ']'
		;

grattributes	: grattribute
		| grattributes ',' grattribute
		;

txsetup		: '[' 	{
			if( X ) {
				/*
				 * Init local overrides to the input default
				 * values.
				 */
				LOC.textSymb		= DEF.textSymb ;
				LOC.elmDisplay		= DEF.elmDisplay ;
				LOC.elmLevel		= DEF.elmLevel ;
				LOC.textPos		= DEF.textPos ;
				VSdrwTxInit( &xData.textFormat ) ;
			}
		}
		   txattributes ']'
		;

txattributes	: txattribute
		| txattributes ',' txattribute
		;

grattribute	: color
		| style
		| weight
		| level
		| scale
		| offset
		| tag
		| hiddenStyle
		| FILLED_DISPLAY {
			if( X ) {
				LOC.dpAttr.filledDisplay = TRUE ;
			}
		}
		;

txattribute	: color
		| style
		| weight
		| level
		| font
		| format
		| just
		| size
		| width
		| height
		| position
		;

color		: COLOR '=' exp {
			int co ;

			if( !X ) break ;

			IFVERB VSdrwPrtItem( $1.type, -1, &$3 ) ;
			/*
			 * Handle case where color is specified by name.
			 */
			VScheckColor( &$3, &co ) ;
			switch( co ) {
			  case VS_K_DRW_INV_CLR_NUM :
			  IFVERB PRINTF( "!!! Invalid color number, using %d\n",
			          LOC.elmDisplay.color ) ;
			  break ;
			  case VS_K_DRW_INV_CLR_NAM :
			  IFVERB PRINTF( "!!! Invalid color name, using %d\n",
			                 LOC.elmDisplay.color ) ;
			  break ;
			  default : LOC.elmDisplay.color = co ;
			            xData.symbOverrides |= VSdrwColorOverriden ;
			            break ;
			}
		}
		;

style		: STYLE '=' exp {
			if( X ) {
			  int	st = INT( &$3 ) ;
			  IFVERB {
			    VSdrwPrtItem( $1.type, VS_int, &st ) ;
			  }

			  if( VScheckStyle( st ) ) {
			    LOC.elmDisplay.style = st ;
			    xData.symbOverrides |= VSdrwStyleOverriden ;
			  } else {
			    IFVERB PRINTF( "!!! Invalid style, using %d\n",
			                   LOC.elmDisplay.style ) ;
			  }
			} 
		}
		;

weight		: WEIGHT '=' exp {
			if( X ) {
			  int	wt = INT( &$3 ) ;

			  IFVERB {
			    VSdrwPrtItem( $1.type, VS_int, &wt ) ;
			  }
			  if( VScheckWeight( wt ) ) {
			    LOC.elmDisplay.weight = wt ;
			    xData.symbOverrides |= VSdrwWeightOverriden ;
			  } else {
			    IFVERB PRINTF( "!!! Invalid weight, using %d\n",
			                   LOC.elmDisplay.weight ) ;
			  }
			}
		}
		;

level		: LEVEL '=' exp {
			if( X ) {
			  int	lv = INT( &$3 ) ;

			  IFVERB {
			    VSdrwPrtItem( $1.type, VS_int, &lv ) ;
			  }
			  if( VScheckLayer( lv ) ) {
			    LOC.elmLevel = lv ;
			    xData.symbOverrides |= VSdrwLevelOverriden ;
			  } else {
			    IFVERB PRINTF( "!!! Invalid layer, using %d\n",
				           LOC.elmLevel ) ;
			  }
			}
		}
		;

scale		: SCALE '=' exp {
			if( X ) {
				d = DABS( &$3 ) ;

				if( 0 == d ) d = 1 ;
				LOC.dpAttr.scale = d ; 
				IFVERB {
					VSdrwPrtItem( $1.type, VS_double, &d ) ;
				}
			}
		}
		;

offset		: OFFSET '=' expounit {
			if( X ) {
				d = DBL( &$3 ) ;
				LOC.dpAttr.offset = d ; 
				IFVERB {
					VSdrwPrtItem( $1.type, VS_double, &d ) ;
				}
			}
		}
		;

tag		: TAG '=' exp { xData.tag = $3 ; }
		;

hiddenStyle	: HIDDEN_STYLE '=' exp {
			if( X ) {
				i = INT( &$3 ) ;

				IFVERB {
					VSdrwPrtItem( $1.type, VS_int, &i ) ;
				}
				if( VScheckStyle( i ) ) {
					LOC.dpAttr.hiddenStyle = i ;
				} else IFVERB
					PRINTF( "!!! Invalid hidden style, using %d\n",
						LOC.elmDisplay.style ) ;
			}
		}
		;

font		: FONT '=' exp {
			if( X ) {
				/*
				 * Find font.
				 */
				short	ftPos ;

				STR( &$3, s ) ;
				IFVERB {
					VSdrwPrtItem( $1.type, VS_string, s ) ;
				}
				VSretrieveFont( msg, s, &ftPos ) ;
				IFVERB if( EMS_I_Fail == *msg ) {
					PRINTF( "!!! Font %s not found, using default font\n",
						s ) ;
				}
				xData.overrides.textSymb.Active_font = ftPos ;
			}
		}
		;

format		: FORMAT {
			IFXVERB {
				$1._ival = yylineno ;
				VSdrwPrtItem( $1.type, VS_string, NULL ) ;
			}
		}
		  '=' '(' textseqs ')'	{
			if( X ) {
				xData.textFormat = $5 ;
				alreadyFilled	 = NULL ;
				IFVERB PRINTF( "*-* End (%s at %d)\n",
						KWRD( $1.type ), $1._ival ) ;
			}
		}
		;

textseqs	: textseq		{ if( X ) $$ = $1 ;	}
		| textseqs ',' 		{ alreadyFilled = &$1 ; }
		  textseq		{
			if( X ) {
				VSdrwTxMERGE( &$1, &$4, &$$ ) ;
				alreadyFilled = NULL ;
			}
		}
		;

textseq		: exp			{
			if( X ) {
				VSdrwTxINITSTRING( &$$, STR( &$1, s ) ) ;
				IFVERB {
					VSdrwIndent() ;
					fprintf( xData.logFile,
						 " > string = '%s'\n", s ) ;
				}
			}
		}
		| textcmd		{ if( X ) $$ = $1 ; }
		;

textcmd		: TXUP		'(' expounit ')'	{

			if( !X ) break ;
			VSdrwTxMOVE( &$$, 'v',   d = DABS( &$3 ) ) ;

			IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
		}
		| TXDOWN	'(' expounit ')'	{

			if( !X ) break ;
			d = DABS( &$3 ) ;
			VSdrwTxMOVE( &$$, 'v', - d ) ;
			IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
		}
		| TXLEFT	'(' expounit ')'	{

			if( !X ) break ;
			d = DABS( &$3 ) ;
			VSdrwTxMOVE( &$$, 'h', - d ) ;
			IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
		}
		| TXRIGHT	'(' expounit ')'	{

			if( !X ) break ;
			VSdrwTxMOVE( &$$, 'h', d =  DABS( &$3 ) ) ;
			IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
		}
		| TXSCALE	'(' exp ')'		{

			if( !X ) break ;
			VSdrwTxMOVE( &$$, 's', d =  DABS( &$3 ) ) ;
			IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
		}
		| TXFSTART	'(' exp  ')'		{

			if( X ) {
				VSdrwTxFSTART( &$$, i = IABS( &$3 ) ) ;
				IFVERB VSdrwPrtItem( $1.type, VS_int, &i ) ;
			}
		}
		| TXFEND				{
			if( X ) {
				VSdrwTxFEND( &$$ ) ;
				IFVERB VSdrwPrtItem( $1.type, VS_string, NULL );
			}
		}
		| TXMVTOFLD	'(' exp ',' exp ')'	{

			int	just,
				j ;

			if( !X ) break ;

			j = just = INT( &$5 ) ;
			
			if( !VScheckJustification( just ) ) {
				just = LEFT_BASE ;
			}
			VSdrwTxMVTOFLD( &$$,
					alreadyFilled,
					i = IABS( &$3 ),
					just,
					&LOC.textSymb,
					&LOC.elmDisplay ) ;
			IFVERB {
				if( j != just ) {
					PRINTF( "!!! Invalid justification: %d, defaulted to LEFT-BASE (just)\n", j, just ) ;
				}
				VSdrwPrtItem( $1.type, VS_int, &i ) ;
			}
		}
		| TXFONT	'(' exp  ')'		{
			if( X ) {
				short ftPos ;

				STR( &$3, s ) ;
				IFVERB VSdrwPrtItem( $1.type, VS_string, s ) ;

				VSretrieveFont( msg, s, &ftPos ) ;
				IFVERB if( EMS_I_Fail == *msg ) {
					PRINTF( "!!! Font %s not found, using default font\n",
						s ) ;
				}
				VSdrwTxCHGFONT( &$$, ftPos ) ;
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
			int	j ;

			if( !X ) break ;

			i = j = INT( &$3 ) ;
			if( !VScheckJustification( i ) ) j = LEFT_BASE ;

			LOC.textSymb.Active_just = j ;

			IFVERB {
				if( i != j ) {
					PRINTF( "!!! Invalid justification: %d, defaulted to LEFT-BASE (%d)\n", i, j ) ;
				}
				VSdrwPrtItem( $1.type, VS_string,
					      KWRD( VSdrwJustToTokNum( j ) ) ) ;
			}
		}
		;

size		: SIZE '=' expounit	{
			if( X ) {
				d = DABS( &$3 ) ;

				LOC.textSymb.Active_width =
				LOC.textSymb.Active_height= d ;

				IFVERB {
					VSdrwPrtItem( $1.type, VS_double, &d ) ;
				}
			}
		}
		;

width		: WIDTH '=' expounit	{
			if( X ) {
				d = DABS( &$3 ) ;

				LOC.textSymb.Active_width = d ;

				IFVERB {
					VSdrwPrtItem( $1.type, VS_double, &d ) ;
				}
			}
		}
		;

height		: HEIGHT '=' expounit	{
			if( X ) {
				d = DABS( &$3 ) ;

				LOC.textSymb.Active_height = d ;

				IFVERB {
					VSdrwPrtItem( $1.type, VS_double, &d ) ;
				}
			}
		}
		;

expounit	: exp		{ if( X ) $$ = $1 ; }
		| exp UNIT	{
			/*
			 * Convert user unit -> database (system) unit.
			 */
			if( X ) {
				char	unit[UOM_K_MAX_LEN] ;

				d = DBL( &$1 ) ;
				sprintf( unit, "%g %s", d, $2._sval ) ;
				VSunit2sys( msg,unit,GRIO_DISTANCE,&$$._dval);
				$$.type = VS_double ;
				IFVERB PRINTF( "*-* Unit conversion: %s -> %g\n",
					       unit, $$._dval ) ;
			}
		}
		;

position	: POSITION '=' '(' {
			IFXVERB {
				$1._ival = yylineno ;
				VSdrwPrtItem( $1.type, VS_string, NULL ) ;
			}
		}
		  locations ')' {
			IFXVERB PRINTF( "*-* End (%s at %d)\n",
					KWRD( $1.type ), $1._ival ) ;
		}
		;

locations	: location
		| locations ',' location
		;

location	: exp {
			VStxPosType	posType ;
			int		kwdType ;
			if( !X ) break ;

			i = INT( &$1 ) ;
			if( !VSgetTxPosType( i, &posType, &kwdType ) ) {
				IFVERB PRINTF( "!!! Invalid text position : %d, ignored\n", i ) ;
			}
			switch( posType ) {
				case VStxLoc :
					LOC.textPos.loc = (VSdrwTxLoc) i ;
					break ;
				case VStxDir :
					LOC.textPos.dir = (VSdrwTxDir) i ;
					break ;
				case VStxRev :
					LOC.textPos.rev = (VSdrwTxRev) 
						(   (unsigned) LOC.textPos.rev
						  | i ) ;
					break ;
			}
			IFVERB fprintf( xData.logFile, "\t > %s\n",
					KWRD( kwdType ) ) ;
		}
		| OFFSET '(' exp ',' expounit ')' {
			int	kwdType,
				offType ;
			
			if( !X ) break ;
			i = INT( &$3 ) ;

			if( !VSgetTxOffType( i, &offType, &kwdType ) ) {
				IFVERB PRINTF( "!!! Invalid text offset direction : %d, ignored\n", i ) ;
				break ;
			}
			d = DABS( &$5 ) ;
			switch( offType ) {
				case VSabove	 :
				case VSbelow	 :
				LOC.textPos.voff = (VSdrwVertTxOffset) offType ;
				LOC.textPos.voffVal = d ;
				break ;
				case VStoTheLeft :
				case VStoTheRight:
				LOC.textPos.hoff = (VSdrwHoriTxOffset) offType ;
				LOC.textPos.hoffVal = d ;
				break ;
			}
			IFVERB {
				fprintf( xData.logFile,
					 "\t > offset direction : %s\n",
					 KWRD( kwdType ) ) ;
				VSdrwPrtItem( $1.type, VS_double, &d ) ;
			}
		}
		| ABOVE '(' expounit ')'	{
			vo = VSabove ;
			goto VOFFSET ; /*NOTREACHED*/
		}
		| BELOW	'(' expounit ')'	{
			vo = VSbelow ;
			VOFFSET :
			if( X ) {
				LOC.textPos.voff	= vo ;
				LOC.textPos.voffVal	= d = DABS( &$3 ) ;
				IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
			}
		}
		| TOTHELEFT '(' expounit ')'	{
			ho = VStoTheLeft ;
			goto HOFFSET ; /*NOTREACHED*/
		}
		| TOTHERIGHT '(' expounit ')'	{
			ho = VStoTheRight ;
			HOFFSET :
			if( X ) {
				LOC.textPos.hoff	= ho ;
				LOC.textPos.hoffVal	= d = DABS( &$3 ) ;
				IFVERB VSdrwPrtItem( $1.type, VS_double, &d ) ;
			}
		}
		;

selection	: SELECT {
			IFXVERB {
				$1._ival = yylineno ;
				PRINTF( "*-* %s\n", KWRD( $1.type ) ) ;
			}
		  }
		  selectors END {
		  	IFXVERB {
				PRINTF( "*-* %s (%s at %d)\n", KWRD( $4.type ),
					 KWRD( $1.type ), $1._ival ) ;
			}
		  }
		;

selectors	: whens
		| whens {
			if( !macInfo ) {
				int	aWhenWasSatisfied = $1 ;

				$1 = X ;
				if( X ) {
					X = !aWhenWasSatisfied ;
				}
			}
		}
		  otherwise {
		  	if( macInfo ) break ;
		  	X = $1 ;
		}
		;

whens		: when		{ $$ = X ? $1 : FALSE ; }
		| whens {
			if( X ) {
				if( $1 ) {
					X = FALSE ;
				}
			}
		}
		  when	{
		  	if( macInfo ) break ;
		  	if( $1 ) X = TRUE ;
			$$ = $1 || $3 ;
		}
		;

when		: WHEN exp ':' {
			$3._ival = X ;
			$1._ival = FALSE ;
			if( X ) {
				int exec = BOOL( &$2 ) ;

				$1._ival = exec ;
				if( !exec ) {
					X  = FALSE ;
				}
				IFVERB {
					PRINTF( " ? %s : %s\n", KWRD( $1.type ),
						exec ? "TRUE" : "FALSE" ) ;
				}
			}
		} 
		  actions {
		  	if( macInfo ) break ;
			X = $3._ival ; $$ = $1._ival ; 	
		}
		;

otherwise	: OTHERWISE {
			IFXVERB {
				PRINTF( " + %s\n", KWRD( $1.type ) ) ;
			}
		}
		  ':' actions
		;

exp	: exp VS_LE  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VS_LT  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VS_GE  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VS_GT  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VS_NE  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp '='    exp {
		RELOP :
		if( X ) {
			VSrelOP( msg, $2._ival, &$1, &$3, &$$ ) ;
			IFVERB VSdrwVerbOp( $2.type, &$1, &$3, &$$ ) ;
		}
	}
	| exp VS_AND {
		$2._ival = X ;
		if( X ) {
			/*
			 * Do not evaluate second operand if first was FALSE.
			 */
			if( !BOOL( &$1 ) ) {
				X = FALSE ;
				$$.type = VS_int ; $$._ival = 0 ;
				IFVERB VSdrwVerbOp( VS_AND, &$1, &noEval, &$$ );
			}
		}
	} exp {
		if( macInfo ) break ;

		if( X ) {
			VSrelOP( msg, VS_and, &$1, &$4, &$$ ) ;
			IFVERB VSdrwVerbOp( VS_AND, &$1, &$4, &$$ ) ;
		}
		X = $2._ival ;
	}
	| exp VS_OR {
		$2._ival = X ;
		if( X ) {
			/*
			 * Do not evaluate second operand if first was TRUE.
			 */
			if( BOOL( &$1 ) ) {
				X = FALSE ;
				$$.type = VS_int ; $$._ival = 1 ;
				IFVERB VSdrwVerbOp( VS_OR, &$1, &noEval, &$$ );
			}
		}
	} exp {
		if( macInfo ) break ;
		if( X ) {
			VSrelOP( msg, VS_or, &$1, &$4, &$$ ) ;
			IFVERB VSdrwVerbOp( VS_OR, &$1, &$4, &$$ ) ;
		}
		X = $2._ival ;
	}
	| exp '+'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp '-'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp '*'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp '/'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp VS_POW exp {
		BINOP :
		if( X ) {
			VSbinOP( msg, $2._ival, &$1, &$3, &$$ ) ;
			IFVERB {
				VSdrwVerbOp( $2.type, &$1, &$3, &$$ ) ;
				if(    VS_div == $2._ival 
				    && fabs( $$._dval ) == MAXDOUBLE ) {
				    	PRINTF( "!!! Division by zero\n" ) ;
				}
			}
		}
	}
	| '-' exp %prec VS_UMINUS { goto UNROP ; /*NOTREACHED*/ }
	| VS_NOT exp     {
		UNROP :
		if( X ) {
			VSunrOP( msg, $1._ival, &$2, &$$ ) ;
			IFVERB VSdrwVerbOp( $1.type, &$2, NULL, &$$ ) ;
		}
	}
	| '(' exp ')'    { if( X ) $$ = $2 ; }
	| VS_FUNCTION '(' oarglist ')' {
		if( X ) {
			VSdrwExecFct( msg, inp, &xData, $1._sval, 
					$1.action.function, $3, &$$ ) ;
			VSdrwFreeArglist( $3 ) ;

		}
	}
	| VARIABLE	{
		if( X ) {
			VSdrwGetVarVal( $1._sval, &$$ ) ;
			IFVERB VSdrwVerbVar( 0, $1._sval, &$$ ) ;
		}
	}
	| VARIABLE '[' exp ']' {
		if( X ) {
			VSdrwGetAryVal( $1._sval, &$3, &$$ ) ;
		}
	}
	| constant	{ if( X ) $$ = $1 ; }
	;

arg		: exp	{ if( X ) $$ = $1 ; }
		;

oarglist	: /* Void */		{ if( X ) $$ = NULL ; }
		| arglist 		{ if( X ) $$ = $1   ; }
		;

arglist		: arg		  {
			if( X ) $$ = VSdrwAddArg( msg, &$1, NULL ) ;
		}
		| arglist ',' arg {
			if( X ) $$ = VSdrwAddArg( msg, &$3, $1   ) ;
		}
		;

constant	: VS_INT	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| VS_DOUBLE	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| VS_STRING	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| TXHEIGHT	{
			if( X ) {
				$$.type	= VS_double ;
				$$._dval= LOC.textSymb.Active_height ;
			}
		}
		| TXWIDTH	{
			if( X ) {
				$$.type	= VS_double ;
				$$._dval= LOC.textSymb.Active_width ;
			}
		}
		| txjust	{
			if( X ) {
				$$.type	= VS_int ;
				$$._ival= $1 ;
			}
		}
		| txpos	{
			if( X ) {
				$$.type	= VS_int ;
				$$._ival= $1 ;				
			}
		}
		;


txpos		: TOP		{ $$ = (int) VStop		; }
		| BOTTOM	{ $$ = (int) VSbottom		; }
		| RIGHT		{ $$ = (int) VSright		; }
		| LEFT		{ $$ = (int) VSleft		; }
		| AT1STEND	{ $$ = (int) VS1stEnd		; }
		| AT2NDEND	{ $$ = (int) VS2ndEnd		; }
		| CENTER	{ $$ = (int) VScenter		; }
		| MIDDLE	{ $$ = (int) VSmiddle		; }
		| INNERMOST	{ $$ = (int) VSinnermost	; }
		| HORIZONTAL	{ $$ = (int) VShoriz		; }
		| PARALLEL	{ $$ = (int) VSpara		; }
		| ORTHOGONAL	{ $$ = (int) VSortho		; }
		| NOTREVERSED	{ $$ = (int) VSnotReversed	; }
		| UPSIDEDOWN	{ $$ = (int) VSupsideDown	; }
		| RIGHTTOLEFT	{ $$ = (int) VSrightToLeft	; }
		;
	
%%
/*----------------------------------------------------------------------------*/
yyError( s, xData ) char *s ; VSdrwExecData *xData ; {

	if( xData->verbose ) {
		*s = toupper( *s ) ;
		PRINTF( "!!! %s\n", s ) ;
	}

	/*
	 * Collect garbage.
	 */
	VSdrwCollectGarbage( xData ) ;

	VSdrwResynchLex() ;

} /* yyError */
/*----------------------------------------------------------------------------*/
