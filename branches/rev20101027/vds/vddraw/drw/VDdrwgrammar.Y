%{
/*
	I/VDS	Copy.
*/
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

extern int		yylineno ;
extern char		yytext[] ;

extern int		abs() ;

/*
 * Short cuts.
 */
#define IFXVERB		if( X && xData.verbose )
#define IFVERB		if( xData.verbose )
#define LOC		xData.overrides
#define DEF		inp->defaults
#define KWRD( t )	VD_drwKwFromTokType( (t) )
#define	INT( x )	VD_drwIntVal( (x) )
#define	IABS( x )	abs( VD_drwIntVal( (x) ) )
#define BOOL( x )	VD_drwBoolVal( (x) )
#define DBL( x )	VD_drwDblVal( (x) )
#define DABS( x )	fabs( VD_drwDblVal( (x) ) )
#define STR( x, b )	VD_drwStrVal( (x), (b) )
#define PRINTF		VD_drwPrintf

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
	VD_drwExecData	xData ;		/* Execution data		*/ \
	int		X = TRUE ;	/* Execute ? (TRUE/FALSE)	*/ \
	double		d ;		/* Double buffer		*/ \
	int		i ;		/* Integer buffer		*/ \
	VD_tktxt		s ;		/* String buffer		*/ \
	VD_drwText	*alreadyFilled = NULL ;				   \
					/* Points to already filled text*/ \
	VD_drwVertTxOffset						   \
			vo ;		/* Vertical offset for text	*/ \
	VD_drwHoriTxOffset						   \
			ho ;		/* Horizontal offset for text	*/ \
	VD_execRes	noEval ;	/* Unevaluated result		*/ \
	int		elmProcessed = FALSE ;				   \
					/* TRUE if element was processed*/ \
	VD_drwArgLst	*outputArgLst = NULL ;
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
#define yyparse()	VD_drwParse( msg, inp, macInfo, output )	\
			long		*msg ;			\
			VD_drwInputData	*inp ;			\
			VD_drwMacInfo	**macInfo ;		\
			VD_drwOutputData	**output ; {		\
				LOCALVARS

/*----------------------------------------------------------------------------*/
%}
%union {
	VD_drwViewType	viewTp ;	/* Mask of view types		*/
	VD_drwCaseOf	caseOf ;	/* Type selections		*/
	VD_drwAnchorType	anchTp ;	/* Anchor point type		*/
	int		xqtFlg ;	/* Saves 'execute' flag		*/
	int		txjust ;	/* Text justification		*/
	int		txtpos ;	/* Text position		*/
	VD_execRes	result ;	/* Result of an operation	*/
	VD_drwTOKEN	tokVal ;	/* Token as read by Lex		*/
	VD_drwArgLst	*argLst;	/* Arg. list for function call	*/
	VD_drwText	format ;	/* Format of text		*/
	VD_tktxt		string ;	/* Character string		*/
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
%type <tokVal>	lvalue
/*
 * Graphic output.
 */
%token <tokVal>	GROUTPUT	SYMBOL
/*
 * Symbology.
 */
%token <tokVal> COLOR		STYLE		WEIGHT		LEVEL
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
 */
%token <tokVal>	SIDE		ENDON		UNKNOWN_VIEW	ANY_VIEW
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
 * Keyword for global setting during execution.
 */
%token <tokVal>	VERBOSE		SILENT		SET		VW_CONE_ANGLE
%token <tokVal>	LOGFILE		INCLUDE
/*
 * Miscelanious.
 */
%token <tokVal>	VARIABLE	VD_FUNCTION	VD_ERROR	VD_NOT
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
%start program
%%
program	: {

        *msg = MSSUCC ;
        VD_drwInitVarTable() ;
        noEval.type = VD_string ;
        strcpy( noEval._sval, "(not evaluated)" ) ;

        /*
         * If we are only extracting the attributes to be
         * reported to the drawing then we are not "executing".
         */
        if( macInfo )	{ X = FALSE ; *macInfo = NULL ; }
        else		{ X = TRUE  ; }

        xData.action		= (void (*)()) VD_drwUndefinedAction ;
        xData.verbose		= FALSE ;
        *xData.viewCriterion	= '\0' ;
        *xData.parsedDefName	= '\0' ;
        xData.txPosHelper	= VD_undefTxPosHelper ;
        xData.lastGraphic	= NULL ;

        /*
         * Do not forget to init garbage list to NULL !
         */
        xData.garbageList	= NULL ;
	/* init select mask. */
	xData.selectMask	= 0;
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
        VD_drwCollectGarbage( &xData ) ;

        if( !macInfo && xData.verbose ) {
          if( !elmProcessed ) {
            VD_drwElmNotProcessed( xData.logFile, inp ) ;
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
		IFVERB PRINTF(	"*-* Setting view cone angle to %g degrees\n",
				d ) ;
	}
	| SET LOGFILE exp {
		/*
		 * Close previously opened log file if any (ie. if it is not 
		 * stdout). And set the new log file pointer.The log file will 
		 * not be closed in `yyparse' since a syntax error may cause
		 * to exit `yyparse' at anypoint, thus leaving the log file
		 * opened. Instead the log file is closed by the function which
		 * called `yyparse' with `VD_drwCloseLogFile()'.
		 */
		STR( &$3, s ) ;
		xData.logFile = VD_drwOpenLogFile( s ) ;
	}
	;

configs		: header config
		| configs header config
		;

config	: elementType ':' {

	  xData.parsedElmType = $1.val ;
	  strcpy( xData.parsedElmDesc, $1.txt ) ;

	  if( macInfo ) {
	    ((VD_drwElmTypeFinder) xData.action)(
			NULL, NULL, xData.parsedElmDesc, xData.verbose,
			NULL, xData.parsedDefName, NULL ) ;
	  } else if( X ) {
	    ((VD_drwElmTypeFinder) xData.action)(
			inp->elmId, inp->elmEnv, xData.parsedElmDesc,
			xData.verbose, inp->constDefName,
			xData.parsedDefName, &xData.parsedElmType ) ;
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

	    X = xData.parsedElmType != 0 ;

	    /*
	     * If type is OK, are we processing a const (a macro
	     * occurrence) ? If so is the macro definition of the input
	     * const the same as that specified for the code
	     * we are parsing ?
	     */
	    if( X && xData.parsedElmType == VD_gI_InAsbly ) {
	      X = VD_matchRE( xData.parsedDefName, inp->constDefName ) ;
	    }
	    if( X ) {
	      IFVERB {
	        if( xData.parsedElmType == VD_gI_InAsbly ) {
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
	      VD_drwGetViewTypeFromElement( msg, inp, &xData ) ;
	    }
	  } else if( macInfo ) {
	    if( !VD_drwAddMacInfo( macInfo, xData.parsedDefName ) ) {
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
		       	   xData.parsedDefName ) ;
		 } else {
		   PRINTF( "!!! No '%s' statement for %s\n",
		       	   KWRD( EXTRACT ), xData.parsedElmDesc ) ;
		 }
	       }
	     }
	     | drawinginfo
	     ;

drawinginfo : EXTRACT AS VD_STRING {

	      if( macInfo ) {
	        if( strlen( $3._sval ) >= macro_MAX_CHAR ) {
		  IFVERB PRINTF( "!!! Macro names cannot exceed %d characters: <%s> truncated\n",
	                         macro_MAX_CHAR - 1, $3._sval ) ;
		  $3._sval[macro_MAX_CHAR-1] = '\0' ;
		}
		IFVERB PRINTF( "*-* Extract as '%s'\n", $3._sval ) ;
		if( !VD_drwAddMacDrwName( *macInfo, $3._sval ) ) {
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

attribute	: VD_STRING {
		  if( macInfo ) {
		    IFVERB PRINTF( "\t > with '%s'\n", $1._sval ) ;
		    if( !VD_drwAddAttrToMacInfo(	*macInfo, $1._sval ) ) {
		      YYABORT ;
		    }
		  }
		}
		;

elementType	: ELMTYPE	{
			if( X || macInfo ) { 
				$$.tok = $1.type ;
				strcpy( $$.txt, $1._sval ) ;
				xData.action = $1.action.any ;
			}
		}
		| const		{

			if( X ) { $$ = $1 ; }
		}
		;

const : CONST '(' DEFINITION	'=' VD_STRING ',' {

        if( X || macInfo ) {
          int	trunc ;

	  VD_strncpy( xData.parsedDefName, $5._sval, sizeof( GRname ), &trunc ) ;
	}
	*xData.viewCriterion = '\0' ;

      } view_criterion ')' {

	$$.tok = $1.type ;
	strcpy( $$.txt, $1._sval ) ;
	xData.action = $1.action.any ;

      }
      ;

view_criterion	: VIEW_CRITERION '=' VD_STRING	{

		  if( X ) {
		    int	trunc ;
		    VD_strncpy( xData.viewCriterion, $3._sval, sizeof( GRname ),
			       &trunc ) ;
		  }
		}
		| VIEW_CRITERIA	'=' view_pairs	{

		  if( X && !*xData.viewCriterion && xData.verbose ) {
		    if( VD_matchRE( xData.parsedDefName, inp->constDefName ) ) {
		      PRINTF( "!!! No view criterion found for '%s'\n",
			      inp->constDefName ) ;
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

		      int	trunc ;
		      VD_strncpy( xData.viewCriterion, $3._sval,
				 sizeof( GRname ), &trunc ) ;
		    }
		  } 
		}
		;

directives	: viewSelection
		| directives viewSelection
		;

viewSelection	: viewTypes ':' {

		     VD_drwViewType vt ;

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
		     IFVERB PRINTF( "*-* View %s\n", VD_drwVerbViewType( vt ) ) ;
		}
		  '{' actions '}' {
		     if( macInfo ) break ;
		     X = $2._ival ;
		}
		;

viewTypes	: viewType			{ if( X ) $$ = $1 ; }
		| viewTypes ',' viewType	{
			if( X ) $$ = (VD_drwViewType) (   (unsigned) $1
						       | (unsigned) $3 ) ;
		}
		;

viewType	: TOP		{ if( X ) $$ = VD_fromTop 	; }
		| BOTTOM	{ if( X ) $$ = VD_fromBottom	; } 
		| SIDE		{ if( X ) $$ = VD_fromSide	; }
		| ENDON		{ if( X ) $$ = VD_endOn		; }
		| UNKNOWN_VIEW	{ if( X ) $$ = VD_unknownViewType; }
		| ANY_VIEW	{ if( X ) $$ = VD_anyViewType ;	  }
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
		| output
		| assignment
		| include
		| selection
		| global_setting
		;

anchor_point	: ANCHOR_POINT '(' exp ')' {
			if( X ) {
			  STR( &$3, s ) ;
			  VD_drwAnchorPoint( msg, inp, &xData, s,
						  VD_drwAnchorCtrOfBox ) ;
			  IFVERB VD_drwVerbAnchor( s, VD_drwAnchorCtrOfBox ) ;
			}
		}
		| ANCHOR_POINT '(' exp ',' which_point ')' {
			if( X ) {
			  STR( &$3, s ) ;
			  VD_drwAnchorPoint( msg, inp, &xData, s, $5 ) ;
			  IFVERB VD_drwVerbAnchor( s, $5 ) ;
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
					PRINTF( "*-* Anchor curve " ) ;
					VD_drwVerbValue( "%@\n", &$3 ) ;
				}
				VD_drwAnchorCurve( msg, inp, &xData, &$3 ) ;
			}
		}
		;

include		: INCLUDE VD_STRING ';' {

			/*
			 * "include" statement: divert Lex's input to
			 * the new file, stacking the one being read.
			 */
			if( !VD_drwPushInputFile( $2._sval,
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
			VD_drwLexUnput( ';' ) ;
		}
		;

lvalue		: VARIABLE
		| VARIABLE '['exp ']' ; 

assignment	: lvalue ASSIGN expounit {
		    if( X ) {
		      VD_drwSetVarVal( $1._sval, &$3 ) ;
		      IFVERB VD_drwVerbVar( 1, $1._sval, &$3 ) ;
		    }
		}
		| lvalue error {
		    IFVERB PRINTF( "!!! Expected `:=', got `%s'\n", yytext ) ;
		    YYABORT ;
		} expounit 
		;

output		: graphic	{
			if( !X ) break ;

			VD_drwOutputGraphic( msg, inp, &xData, $1, FALSE,
					    outputArgLst, output ) ;

			VD_drwFreeArglist( outputArgLst ) ;
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
			    	VD_drwOutputGraphic( msg, inp, &xData, "symbol",
			    		TRUE, (VD_drwArgLst*) NULL, output ) ;

				IFVERB if( !(*msg & 1) )
				PRINTF( "!!! Construction of symbol failed\n" );
			} else {
				PRINTF( "!!! Empty text : not constructed\n" ) ;
			}
			VD_drwTxFree( &xData.textFormat ) ;
		}
		;

graphic		: outputType {
			strcpy( $$, $1.txt ) ;
			IFXVERB {
				VD_drwVerbOutput( $1.txt, outputArgLst, FALSE ) ;
			}
		}
		| outputType {
			strcpy( $$, $1.txt ) ;
			IFXVERB {
				$1.val = yylineno ;
				VD_drwVerbOutput( $1.txt, outputArgLst, TRUE ) ;
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
				VD_drwTxInit( &xData.textFormat ) ;
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

			IFVERB VD_drwPrtItem( $1.type, -1, &$3 ) ;
			/*
			 * Handle case where color is specified by name.
			 */
			VD_checkColor( &$3, &co ) ;
			switch( co ) {
				case VD_K_DRW_INV_CLR_NUM :
				IFVERB
				PRINTF( "!!! Invalid color number, using %d\n",
					 LOC.elmDisplay.color ) ;
				break ;
				case VD_K_DRW_INV_CLR_NAM :
				IFVERB
				PRINTF( "!!! Invalid color name, using %d\n",
					 LOC.elmDisplay.color ) ;
				break ;
				default : LOC.elmDisplay.color = co ;
			}
		}
		;

style		: STYLE '=' exp {
			if( X ) {
				int	st = INT( &$3 ) ;
				IFVERB {
					VD_drwPrtItem( $1.type, VD_int, &st ) ;
				}

				if( VD_checkStyle( st ) ) {
					LOC.elmDisplay.style = st ;
				} else IFVERB
					PRINTF( "!!! Invalid style, using %d\n",
						LOC.elmDisplay.style ) ;
			} 
		}
		;

weight		: WEIGHT '=' exp {
			if( X ) {
				int	wt = INT( &$3 ) ;

				IFVERB {
					VD_drwPrtItem( $1.type, VD_int, &wt ) ;
				}
				if( VD_checkWeight( wt ) ) {
					LOC.elmDisplay.weight = wt ;
				} else IFVERB
					PRINTF( "!!! Invalid weight, using %d\n",
						LOC.elmDisplay.weight ) ;
			}
		}
		;

level		: LEVEL '=' exp {
			if( X ) {
				int	lv = INT( &$3 ) ;

				IFVERB {
					VD_drwPrtItem( $1.type, VD_int, &lv ) ;
				}
				if( VD_checkLayer( lv ) ) {
					LOC.elmLevel = lv ;
				} else IFVERB
					PRINTF( "!!! Invalid layer, using %d\n",
						LOC.elmLevel ) ;
			}
		}
		;

scale		: SCALE '=' exp {
			if( X ) {
				d = DABS( &$3 ) ;

				if( d == 0 ) d = 1 ;
				LOC.dpAttr.scale = d ; 
				IFVERB {
					VD_drwPrtItem( $1.type, VD_double, &d ) ;
				}
			}
		}
		;

offset		: OFFSET '=' expounit {
			if( X ) {
				d = DBL( &$3 ) ;
				LOC.dpAttr.offset = d ; 
				IFVERB {
					VD_drwPrtItem( $1.type, VD_double, &d ) ;
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
					VD_drwPrtItem( $1.type, VD_int, &i ) ;
				}
				if( VD_checkStyle( i ) ) {
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
					VD_drwPrtItem( $1.type, VD_string, s ) ;
				}
				VD_retrieveFont( msg, s, &ftPos ) ;
				IFVERB if( *msg == EMS_I_Fail ) {
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
				VD_drwPrtItem( $1.type, VD_string, NULL ) ;
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
				VD_drwTxMERGE( &$1, &$4, &$$ ) ;
				alreadyFilled = NULL ;
			}
		}
		;

textseq		: exp			{
			if( X ) {
				VD_drwTxINITSTRING( &$$, STR( &$1, s ) ) ;
				IFVERB {
					VD_drwIndent() ;
					fprintf( xData.logFile,
						 " > string = '%s'\n", s ) ;
				}
			}
		}
		| textcmd		{ if( X ) $$ = $1 ; }
		;

textcmd		: TXUP		'(' expounit ')'	{

			if( !X ) break ;
			VD_drwTxMOVE( &$$, 'v',   d = DABS( &$3 ) ) ;

			IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
		}
		| TXDOWN	'(' expounit ')'	{

			if( !X ) break ;
			d = DABS( &$3 ) ;
			VD_drwTxMOVE( &$$, 'v', - d ) ;
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
		}
		| TXLEFT	'(' expounit ')'	{

			if( !X ) break ;
			d = DABS( &$3 ) ;
			VD_drwTxMOVE( &$$, 'h', - d ) ;
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
		}
		| TXRIGHT	'(' expounit ')'	{

			if( !X ) break ;
			VD_drwTxMOVE( &$$, 'h', d =  DABS( &$3 ) ) ;
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
		}
		| TXSCALE	'(' exp ')'		{

			if( !X ) break ;
			VD_drwTxMOVE( &$$, 's', d =  DABS( &$3 ) ) ;
			IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
		}
		| TXFSTART	'(' exp  ')'		{

			if( X ) {
				VD_drwTxFSTART( &$$, i = IABS( &$3 ) ) ;
				IFVERB VD_drwPrtItem( $1.type, VD_int, &i ) ;
			}
		}
		| TXFEND				{
			if( X ) {
				VD_drwTxFEND( &$$ ) ;
				IFVERB VD_drwPrtItem( $1.type, VD_string, NULL );
			}
		}
		| TXMVTOFLD	'(' exp ',' exp ')'	{

			int	just,
				j ;

			if( !X ) break ;

			j = just = INT( &$5 ) ;
			
			if( !VD_checkJustification( just ) ) {
				just = LEFT_BASE ;
			}
			VD_drwTxMVTOFLD( &$$,
					alreadyFilled,
					i = IABS( &$3 ),
					just,
					&LOC.textSymb,
					&LOC.elmDisplay ) ;
			IFVERB {
				if( j != just ) {
					PRINTF( "!!! Invalid justification: %d, defaulted to LEFT-BASE (just)\n", j, just ) ;
				}
				VD_drwPrtItem( $1.type, VD_int, &i ) ;
			}
		}
		| TXFONT	'(' exp  ')'		{
			if( X ) {
				short ftPos ;

				STR( &$3, s ) ;
				IFVERB VD_drwPrtItem( $1.type, VD_string, s ) ;

				VD_retrieveFont( msg, s, &ftPos ) ;
				IFVERB if( *msg == EMS_I_Fail ) {
					PRINTF( "!!! Font %s not found, using default font\n",
						s ) ;
				}
				VD_drwTxCHGFONT( &$$, ftPos ) ;
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
			if( !VD_checkJustification( i ) ) j = LEFT_BASE ;

			LOC.textSymb.Active_just = j ;

			IFVERB {
				if( i != j ) {
					PRINTF( "!!! Invalid justification: %d, defaulted to LEFT-BASE (%d)\n", i, j ) ;
				}
				VD_drwPrtItem( $1.type, VD_string,
					      KWRD( VD_drwJustToTokNum( j ) ) ) ;
			}
		}
		;

size		: SIZE '=' expounit	{
			if( X ) {
				d = DABS( &$3 ) ;

				LOC.textSymb.Active_width =
				LOC.textSymb.Active_height= d ;

				IFVERB {
					VD_drwPrtItem( $1.type, VD_double, &d ) ;
				}
			}
		}
		;

width		: WIDTH '=' expounit	{
			if( X ) {
				d = DABS( &$3 ) ;

				LOC.textSymb.Active_width = d ;

				IFVERB {
					VD_drwPrtItem( $1.type, VD_double, &d ) ;
				}
			}
		}
		;

height		: HEIGHT '=' expounit	{
			if( X ) {
				d = DABS( &$3 ) ;

				LOC.textSymb.Active_height = d ;

				IFVERB {
					VD_drwPrtItem( $1.type, VD_double, &d ) ;
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
				vd_$unit_to_system(
						msg	= msg,
						unit	= unit,
						p_value	= &$$._dval ) ;
				$$.type = VD_double ;
				IFVERB PRINTF( "*-* Unit conversion: %s -> %g\n",
					       unit, $$._dval ) ;
			}
		}
		;

position	: POSITION '=' '(' {
			IFXVERB {
				$1._ival = yylineno ;
				VD_drwPrtItem( $1.type, VD_string, NULL ) ;
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
			VD_txPosType	posType ;
			int		kwdType ;
			if( !X ) break ;

			i = INT( &$1 ) ;
			if( !VD_getTxPosType( i, &posType, &kwdType ) ) {
				IFVERB PRINTF( "!!! Invalid text position : %d, ignored\n", i ) ;
			}
			switch( posType ) {
				case VD_txLoc :
					LOC.textPos.loc = (VD_drwTxLoc) i ;
					break ;
				case VD_txDir :
					LOC.textPos.dir = (VD_drwTxDir) i ;
					break ;
				case VD_txRev :
					LOC.textPos.rev = (VD_drwTxRev) 
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

			if( !VD_getTxOffType( i, &offType, &kwdType ) ) {
				IFVERB PRINTF( "!!! Invalid text offset direction : %d, ignored\n", i ) ;
				break ;
			}
			d = DABS( &$5 ) ;
			switch( offType ) {
				case VD_above	 :
				case VD_below	 :
				LOC.textPos.voff = (VD_drwVertTxOffset) offType ;
				LOC.textPos.voffVal = d ;
				break ;
				case VD_toTheLeft :
				case VD_toTheRight:
				LOC.textPos.hoff = (VD_drwHoriTxOffset) offType ;
				LOC.textPos.hoffVal = d ;
				break ;
			}
			IFVERB {
				fprintf( xData.logFile,
					 "\t > offset direction : %s\n",
					 KWRD( kwdType ) ) ;
				VD_drwPrtItem( $1.type, VD_double, &d ) ;
			}
		}
		| ABOVE '(' expounit ')'	{
			vo = VD_above ;
			goto VOFFSET ; /*NOTREACHED*/
		}
		| BELOW	'(' expounit ')'	{
			vo = VD_below ;
			VOFFSET :
			if( X ) {
				LOC.textPos.voff	= vo ;
				LOC.textPos.voffVal	= d = DABS( &$3 ) ;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
			}
		}
		| TOTHELEFT '(' expounit ')'	{
			ho = VD_toTheLeft ;
			goto HOFFSET ; /*NOTREACHED*/
		}
		| TOTHERIGHT '(' expounit ')'	{
			ho = VD_toTheRight ;
			HOFFSET :
			if( X ) {
				LOC.textPos.hoff	= ho ;
				LOC.textPos.hoffVal	= d = DABS( &$3 ) ;
				IFVERB VD_drwPrtItem( $1.type, VD_double, &d ) ;
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

exp	: exp VD_LE  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VD_LT  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VD_GE  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VD_GT  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp VD_NE  exp { goto RELOP ; /*NOTREACHED*/ }
	| exp '='    exp {
		RELOP :
		if( X ) {
			VD_relOP( msg, $2._ival, &$1, &$3, &$$ ) ;
			IFVERB VD_drwVerbOp( $2.type, &$1, &$3, &$$ ) ;
		}
	}
	| exp VD_AND {
		$2._ival = X ;
		if( X ) {
			/*
			 * Do not evaluate second operand if first was FALSE.
			 */
			if( !BOOL( &$1 ) ) {
				X = FALSE ;
				$$.type = VD_int ; $$._ival = 0 ;
				IFVERB VD_drwVerbOp( VD_AND, &$1, &noEval, &$$ );
			}
		}
	} exp {
		if( macInfo ) break ;

		if( X ) {
			VD_relOP( msg, VD_and, &$1, &$4, &$$ ) ;
			IFVERB VD_drwVerbOp( VD_AND, &$1, &$4, &$$ ) ;
		}
		X = $2._ival ;
	}
	| exp VD_OR {
		$2._ival = X ;
		if( X ) {
			/*
			 * Do not evaluate second operand if first was TRUE.
			 */
			if( BOOL( &$1 ) ) {
				X = FALSE ;
				$$.type = VD_int ; $$._ival = 1 ;
				IFVERB VD_drwVerbOp( VD_OR, &$1, &noEval, &$$ );
			}
		}
	} exp {
		if( macInfo ) break ;
		if( X ) {
			VD_relOP( msg, VD_or, &$1, &$4, &$$ ) ;
			IFVERB VD_drwVerbOp( VD_OR, &$1, &$4, &$$ ) ;
		}
		X = $2._ival ;
	}
	| exp '+'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp '-'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp '*'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp '/'    exp { goto BINOP ; /*NOTREACHED*/ }
	| exp VD_POW exp {
		BINOP :
		if( X ) {
			VD_binOP( msg, $2._ival, &$1, &$3, &$$ ) ;
			IFVERB {
				VD_drwVerbOp( $2.type, &$1, &$3, &$$ ) ;
				if(    $2._ival == VD_div
				    && fabs( $$._dval ) == MAXDOUBLE ) {
				    	PRINTF( "!!! Division by zero\n" ) ;
				}
			}
		}
	}
	| '-' exp %prec VD_UMINUS { goto UNROP ; /*NOTREACHED*/ }
	| VD_NOT exp     {
		UNROP :
		if( X ) {
			VD_unrOP( msg, $1._ival, &$2, &$$ ) ;
			IFVERB VD_drwVerbOp( $1.type, &$2, NULL, &$$ ) ;
		}
	}
	| '(' exp ')'    { if( X ) $$ = $2 ; }
	| VD_FUNCTION '(' oarglist ')' {
		if( X ) {
			VD_drwExecFct( msg, inp, &xData, $1._sval, 
					$1.action.function, $3, &$$ ) ;
			VD_drwFreeArglist( $3 ) ;

		}
	}
	| VARIABLE	{
		if( X ) {
			VD_drwGetVarVal( $1._sval, &$$ ) ;
			IFVERB VD_drwVerbVar( 0, $1._sval, &$$ ) ;
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
			if( X ) $$ = VD_drwAddArg( msg, &$1, NULL ) ;
		}
		| arglist ',' arg {
			if( X ) $$ = VD_drwAddArg( msg, &$3, $1   ) ;
		}
		;

constant	: VD_INT	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| VD_DOUBLE	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| VD_STRING	{ if( X ) { $$.type = $1.type; $$.v = $1.v ; } }
		| TXHEIGHT	{
			if( X ) {
				$$.type	= VD_double ;
				$$._dval= LOC.textSymb.Active_height ;
			}
		}
		| TXWIDTH	{
			if( X ) {
				$$.type	= VD_double ;
				$$._dval= LOC.textSymb.Active_width ;
			}
		}
		| txjust	{
			if( X ) {
				$$.type	= VD_int ;
				$$._ival= $1 ;
			}
		}
		| txpos	{
			if( X ) {
				$$.type	= VD_int ;
				$$._ival= $1 ;				
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
yyError( s, xData ) char *s ; VD_drwExecData *xData ; {

	if( xData->verbose ) {
		*s = toupper( *s ) ;
		PRINTF( "!!! %s\n", s ) ;
	}

	/*
	 * Collect garbage.
	 */
	VD_drwCollectGarbage( xData ) ;

	VD_drwResynchLex() ;

} /* yyError */
/*----------------------------------------------------------------------------*/
