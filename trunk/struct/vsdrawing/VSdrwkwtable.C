/* $Id: VSdrwkwtable.C,v 1.2 2001/01/16 22:18:55 ramarao Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        vsdrawing/VSdrwkwtable.C
 *
 * Description: Keywords table.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwkwtable.C,v $
 *      Revision 1.2  2001/01/16 22:18:55  ramarao
 *      *** empty log message ***
 *
 * Revision 1.2  2000/11/06  16:30:28  pinnacle
 * Replaced: struct/vsdrawing/VSdrwkwtable.C for:  by rchennup for Service Pack
 *
 * Revision 1.1  2000/11/03  23:30:04  pinnacle
 * Created: struct/vsdrawing/VSdrwkwtable.C by rchennup for Service Pack
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.5  1997/12/26  10:48:54  pinnacle
 * Replaced: vsdrawing/VSdrwkwtable.C for:  by rchennup for struct
 *
 * Revision 1.4  1997/11/19  10:18:38  pinnacle
 * Replaced: vsdrawing/VSdrwkwtable.C for:  by rchennup for struct
 *
 * Revision 1.3  1997/10/29  15:37:44  pinnacle
 * Replaced: vsdrawing/VSdrwkwtable.C for:  by rchennup for struct
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/29/97   Rama Rao     Header Creation & Add place macro
 *************************************************************************/

#include <string.h>
#include <stdlib.h>
#include "vsdrw.h"
#include "VSdrwgrammar.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

#define CALL( _FUNCTION_ )	(void (*)()) VSdrwFUNCTION##_FUNCTION_
#define OUTPUT( _OUTPUT_ )	(void (*)()) VSdrwOUTPUT##_OUTPUT_
#define ISOFTYPE( _TYPE_ )	(void (*)()) VSdrwISOFTYPE##_TYPE_
/*-LIST OF KEYWORDS-----------------------------------------------------------*/
/*
 * Keywords may be added before the end-of-list line.
 */
	static VSdrwKeyWord kwList[] = {
/*
  Keyword		  Corresponding Yacc token value	Action
  -------		  ------------------------------	------
*/
/*
 * Selection on element type.
 */
{ "beam"			, ELMTYPE	, ISOFTYPE( beam	) },
{ "stiffener"			, ELMTYPE	, ISOFTYPE( stiffener	) },
{ "plate"			, ELMTYPE	, ISOFTYPE( plate	) },
{ "joint"			, ELMTYPE	, ISOFTYPE( joint	) },
{ "const"			, CONST		, ISOFTYPE( const	) },
{ "definition"			, DEFINITION	, NULL			  },
/*
 * Selection on view type.
 */
{ "view-criterion"		, VIEW_CRITERION, NULL },
{ "view-criteria"		, VIEW_CRITERIA	, NULL },
{ "top"				, TOP		, NULL },
{ "bottom"			, BOTTOM	, NULL },
{ "side"			, SIDE		, NULL },
{ "end-on"			, ENDON		, NULL },
{ "unknown-view"		, UNKNOWN_VIEW	, NULL },
{ "any-view"			, ANY_VIEW	, NULL },
/*
 * Types of graphic outputs.
 */
{ "profile"			, GROUTPUT	, OUTPUT( profile	  ) },
{ "projection"			, GROUTPUT	, OUTPUT( projection	  ) },
{ "axis"			, GROUTPUT	, OUTPUT( axis 		  ) },
{ "contour"			, GROUTPUT	, OUTPUT( contour	  ) },
{ "edge"			, GROUTPUT	, OUTPUT( edge		  ) },
{ "intersection"		, GROUTPUT	, OUTPUT( intersection	  ) },
{ "weldline"			, GROUTPUT	, OUTPUT( weldline	  ) },
{ "member"			, GROUTPUT	, OUTPUT( member	  ) },
{ "placemacro"			, GROUTPUT	, OUTPUT( placemacro	  ) },
{ "set-joint-geom"	        , GROUTPUT      , OUTPUT( set_joint_geom  ) },
{ "symbol"			, SYMBOL	, NULL			    },
/*
 * Modifiers to graphic or symbol output.
 */
{ "filled-display"		, FILLED_DISPLAY, NULL },
{ "color"			, COLOR		, NULL },
{ "style"			, STYLE		, NULL },
{ "weight"			, WEIGHT	, NULL },
{ "level"			, LEVEL		, NULL },
{ "scale"			, SCALE		, NULL },
{ "hidden-style"		, HIDDEN_STYLE	, NULL },
{ "tag"				, TAG		, NULL },
/*
 * Keywords for symbol output.
 */
{ "format"			, FORMAT	, NULL },
{ "font"			, FONT		, NULL },
{ "justification"		, JUST		, NULL },
{ "size"			, SIZE		, NULL },
{ "height"			, HEIGHT	, NULL },
{ "width"			, WIDTH		, NULL },
{ "position"			, POSITION	, NULL },
{ "middle"			, MIDDLE	, NULL },
{ "center"			, CENTER	, NULL },
{ "left"			, LEFT		, NULL },
{ "right"			, RIGHT		, NULL },
{ "at-first-end"		, AT1STEND	, NULL },
{ "at-second-end"		, AT2NDEND	, NULL },
{ "above"			, ABOVE		, NULL },
{ "below"			, BELOW		, NULL },
{ "to-the-left"			, TOTHELEFT	, NULL },
{ "to-the-right"		, TOTHERIGHT	, NULL },
{ "offset"			, OFFSET	, NULL },
{ "horizontal"			, HORIZONTAL	, NULL },
{ "parallel"			, PARALLEL	, NULL },
{ "orthogonal"			, ORTHOGONAL	, NULL },
{ "not-reversed"		, NOTREVERSED	, NULL },
{ "upside-down"			, UPSIDEDOWN	, NULL },
{ "right-to-left"		, RIGHTTOLEFT	, NULL },
/*
 * Database update.
 */
{ "update-database"		, UPDATE_DB	, NULL },
{ "statement"			, STATEMENT	, NULL },
/*
 * Keywords of conditional structure.
 */
{ "select"			, SELECT	, NULL },
{ "when"			, WHEN		, NULL },
{ "otherwise"			, OTHERWISE	, NULL },
{ "end"				, END		, NULL },
/*
 * Functions.
 */
{ "drawing-scale"	     , VS_FUNCTION, CALL( drawing_scale		    ) },
{ "attribute"		     , VS_FUNCTION, CALL( attribute		    ) },
{ "text-member"	             , VS_FUNCTION, CALL( text_member 		    ) },
{ "text-members"	     , VS_FUNCTION, CALL( text_members 		    ) },
{ "basename"		     , VS_FUNCTION, CALL( basename		    ) },
{ "is-element-clipped"	     , VS_FUNCTION, CALL( is_element_clipped	    ) },
{ "profile-direction"	     , VS_FUNCTION, CALL( profile_direction	    ) },
{ "flange-orientation"       , VS_FUNCTION, CALL( flange_orientation        ) },
{ "web-orientation"          , VS_FUNCTION, CALL( web_orientation           ) },
{ "beam-orientation"	     , VS_FUNCTION, CALL( beam_orientation          ) },
{ "plate-direction"	     , VS_FUNCTION, CALL( plate_direction	    ) },
{ "where-is"		     , VS_FUNCTION, CALL( where_is		    ) },
{ "view-direction"	     , VS_FUNCTION, CALL( view_direction	    ) },
{ "is-plate-hidden"	     , VS_FUNCTION, CALL( is_plate_hidden	    ) },
{ "is-beam-hidden"	     , VS_FUNCTION, CALL( is_beam_hidden	    ) },
{ "first-welded-element"     , VS_FUNCTION, CALL( first_welded_element	    ) },
{ "second-welded-element"    , VS_FUNCTION, CALL( second_welded_element	    ) },
{ "intersect-curve-with-view", VS_FUNCTION, CALL( intersect_curve_with_view ) },
{ "nearest-end-point"	     , VS_FUNCTION, CALL( nearest_end_point	    ) },
{ "is-a-beam"		     , VS_FUNCTION, CALL( is_a_beam 		    ) },
{ "is-a-stiffener"	     , VS_FUNCTION, CALL( is_a_stiffener	    ) },
{ "is-a-plate"		     , VS_FUNCTION, CALL( is_a_plate		    ) },
{ "parallel-plates"	     , VS_FUNCTION, CALL( parallel_plates	    ) },
{ "const-type"		     , VS_FUNCTION, CALL( const_type		    ) },
{ "get-input"		     , VS_FUNCTION, CALL( get_input		    ) },
{ "get-member"		     , VS_FUNCTION, CALL( get_member		    ) },
{ "get-owner"		     , VS_FUNCTION, CALL( get_owner		    ) },
{ "project-curve"	     , VS_FUNCTION, CALL( project_curve		    ) },
{ "query-database"	     , VS_FUNCTION, CALL( query_database	    ) },
{ "exec-ppl-func"	     , VS_FUNCTION, CALL( exec_ppl_func		    ) },
{ "is-elem-connected"	     , VS_FUNCTION, CALL( is_elem_connected	    ) },
{ "is-same-object"	     , VS_FUNCTION, CALL( is_same_object	    ) },
{ "joint-geom"		     , VS_FUNCTION, CALL( joint_geom 	  	    ) },
{ "get-connection-geom"	     , VS_FUNCTION, CALL( get_conn_geom	  	    ) },
{ "get-element"	     	     , VS_FUNCTION, CALL( get_element		    ) },
/*
 * Character string-related functions.
 */
{ "catenate-strings"	     , VS_FUNCTION, CALL( catenate_strings	    ) },
{ "dup-string"		     , VS_FUNCTION, CALL( dup_string		    ) },
{ "string-length"	     , VS_FUNCTION, CALL( string_length		    ) },
{ "word-count"		     , VS_FUNCTION, CALL( word_count		    ) },
{ "get-word"		     , VS_FUNCTION, CALL( get_word		    ) },
{ "sub-string"		     , VS_FUNCTION, CALL( sub_string		    ) },
{ "substitute-string"	     , VS_FUNCTION, CALL( substitute_string	    ) },
{ "match-regexp"	     , VS_FUNCTION, CALL( match_regexp		    ) },
{ "format-number"	     , VS_FUNCTION, CALL( format_number		    ) },
{ "time"		     , VS_FUNCTION, CALL( time			    ) },
/*
 * Array functions.
 */
{ "size-of-array"	     , VS_FUNCTION, CALL( size_of_array		    ) },
/*
 * Aliases for "&", "|" and "!" logical operators respectively.
 */
{ "and"				, VS_AND	, NULL },
{ "or"				, VS_OR		, NULL },
{ "not"				, VS_NOT	, NULL },
/*
 * Text commands embedded in format.
 */
{ "UP"				, TXUP		, NULL },
{ "DOWN"			, TXDOWN	, NULL },
{ "LEFT"			, TXLEFT	, NULL },
{ "RIGHT"			, TXRIGHT	, NULL },
{ "SCALE"			, TXSCALE	, NULL },
{ "START-FIELD"			, TXFSTART	, NULL },
{ "END-FIELD"			, TXFEND	, NULL },
{ "MOVE-TO-FIELD"		, TXMVTOFLD	, NULL },
{ "HEIGHT"			, TXHEIGHT	, NULL },
{ "WIDTH"			, TXWIDTH	, NULL },
{ "FONT"			, TXFONT	, NULL },
/*
 * Text justification.
 */
{ "LEFT-BOTTOM"			, JLEFT_BOTTOM	, NULL },
{ "LEFT-BASE"			, JLEFT_BASE	, NULL },
{ "LEFT-CENTER"			, JLEFT_CENTER	, NULL },
{ "LEFT-CAP"			, JLEFT_CAP	, NULL },
{ "LEFT-TOP"			, JLEFT_TOP	, NULL },
{ "CENTER-BOTTOM"		, JCENTER_BOTTOM, NULL },
{ "CENTER-BASE"			, JCENTER_BASE	, NULL },
{ "CENTER-CENTER"		, JCENTER_CENTER, NULL },
{ "CENTER-CAP"			, JCENTER_CAP	, NULL },
{ "CENTER-TOP"			, JCENTER_TOP	, NULL },
{ "RIGHT-BOTTOM"		, JRIGHT_BOTTOM	, NULL },
{ "RIGHT-BASE"			, JRIGHT_BASE	, NULL },
{ "RIGHT-CENTER"		, JRIGHT_CENTER	, NULL },
{ "RIGHT-CAP"			, JRIGHT_CAP	, NULL },
{ "RIGHT-TOP"			, JRIGHT_TOP	, NULL },
/*
 * Anchor point.
 */
{ "anchor-point"		, ANCHOR_POINT	, NULL },
{ "average-point"		, AVERAGE_POINT	, NULL },
{ "center-of-gravity"		, CTR_OF_GRV	, NULL },
{ "innermost"			, INNERMOST	, NULL },
/*
 * Anchor curve.
 */
{ "anchor-curve"		, ANCHOR_CURVE	, NULL },
/*
 * Global settings during execution.
 */
{ "verbose"			, VERBOSE	, NULL },
{ "silent"			, SILENT	, NULL },
{ "set"				, SET		, NULL },
{ "view-cone-angle"		, VW_CONE_ANGLE , NULL },
{ "logfile"			, LOGFILE	, NULL },
{ "include"			, INCLUDE	, NULL },
/*
 * Keywords for extract statement.
 */
{ "extract"			, EXTRACT	, NULL },
{ "as"				, AS		, NULL },
{ "with"			, WITH		, NULL },
{ NULL				, 0		, NULL } /* End of list */
} ;
/*-DYNAMICALLY ADDED KEYWORDS BY OTHER APPLICATIONS---------------------------*/
static VSdrwKeyWord	*ForeignKwList = NULL ;
static unsigned short	ForeignKwCount = 0 ;
/*----------------------------------------------------------------------------*/
static int VSkwCmp( KW1, KW2 )

const void	*KW1,
		*KW2 ; {

	return strcmp( ( (VSdrwKeyWord*) KW1 )->text,
		       ( (VSdrwKeyWord*) KW2 )->text ) ;

} /* VSkwCmp */
/*----------------------------------------------------------------------------*/
int VSdrwKeyword( keyword, logfile, token )

const char	*keyword ;	/* IN : Keyword string			*/
FILE		*logfile ;	/* IN : File for verbose mode		*/
VSdrwTOKEN	*token ; {	/* OUT: Yacc token for input keyword	*/

	/*
	 * Translates input keyword to Yacc token.
	 */
	int			rc		= FALSE ;
	static int		maxKwds		= -1 ;
	VSdrwKeyWord		lookUp,
				*found ;

#ifdef vsDEBUG
	printf( "-- In keyword <%s>\n", keyword ) ;
#endif

	if( -1 == maxKwds  ) {

		/*
		 * First time call : count keywords and alphabetically sort
		 * keyword list.
		 */
		VSdrwKeyWord	*kw ;
		for( maxKwds = 0, kw = kwList ; kw->text ; kw++ ) maxKwds++ ;

		qsort( (char *) kwList, (unsigned) maxKwds,
			sizeof *kw, VSkwCmp ) ;
	}

	/*
	 * Do a binary search on keyword list, now supposed alphabetically
	 * sorted.
	 */
	lookUp.text = (char *) keyword ;
	found = (VSdrwKeyWord *) bsearch(	(char *) &lookUp,
						(char *) kwList,
						(unsigned) maxKwds,
						sizeof lookUp,
						VSkwCmp ) ;
	if( !found ) {
		/*
		 * Try the keywords added by other applications if any...
		 */
		if( ForeignKwList ) {
			found = (VSdrwKeyWord *) bsearch(
						(char *) &lookUp,
						(char *) ForeignKwList,
						(unsigned) ForeignKwCount,
						sizeof lookUp,
						VSkwCmp ) ;
		}
	}

	if( found ) {
		token->action.any = NULL ;
		switch( token->type = found->type ) {
			case VS_AND	: token->_ival = VS_and ; break ;
			case VS_OR	: token->_ival = VS_or  ; break ;
			case VS_NOT	: token->_ival = VS_not ; break ;
			default		: strcpy( token->_sval, found->text ) ;
					  token->action.any = found->action ;
		}
		rc = TRUE ;
	} else {
		/*
		 * Is it a unit ?
		 */
		char	unit[UOM_K_MAX_LEN] ;
		double	val ;
		long	msg ;

		sprintf( unit, "%g %s", 1., keyword ) ;
		vs$unit_to_system(	msg	= &msg,
					unit	= unit,
					p_value	= &val ) ;
		if( msg & 1 ) {
			rc = TRUE ;
			strcpy( token->_sval, keyword ) ;
			token->type = UNIT ;

		} else if( logfile ) {
			VSdrwPrintf( "!!! Unknown keyword <%s>\n", keyword ) ;
		}
	}

	return rc ;

} /* VSdrwKeyword */
/*----------------------------------------------------------------------------*/
const char *VSdrwKwFromTokType( tokType ) register int tokType ; {

	/*
	 * Given a Yacc token type, returns the corresponding keyword.
	 * Returns a pointer to a static buffer.
	 */
	register VSdrwKeyWord	*lookup ;
	char			*kw = "UNKNOWN" ;

	for( lookup = kwList ; lookup->text ; lookup++ ) {
		if( lookup->type == tokType ) {
			kw = lookup->text ; break ;
		}
	}
	return kw ;

} /* VSdrwKwFromTokType */
/*----------------------------------------------------------------------------*/
/*
 * API for other applications to plug their own functions into the Drawing
 * Extraction Language. The functions to be added should only be added once.
 */
int VSdrwAddFunctions( count, names, usages, addresses )

int		count ;
char		*names[] ;
VSdrwUsrTokType	usages[] ;
VSdrwAction	addresses[] ; {

	int		i ;
	int		j ;
	int		ok ;
	int		newCount, loc_count ;
	VSdrwKeyWord	*newList = NULL ;
	VSdrwTOKEN	token ;

	/*
	 * Check that the new function names do not conflict with existing
	 * keywords...
	 */

	loc_count = 0;
	for( i = 0 ; i < count ; i++ ) {
		if( VSdrwKeyword( names[i], (FILE *) NULL, &token ) ) {
/*
			fprintf( stderr,
			 "!!! Keyword `%s' already exists in APFEL-STRUDEL\n",
			 names[i] ) ;
			fprintf( stderr,
			 "!!! -> Addition of keyword aborted.\n" ) ;
		 	return FALSE ;
*/
		}
		else	loc_count++;
	}

	if( !loc_count ) return TRUE;

	newCount = ForeignKwCount + loc_count ;

	if( !ForeignKwList ) {
		if( !( newList = _MALLOC( loc_count, VSdrwKeyWord ) ) )
								return FALSE ;
	} else {
		unsigned	size = newCount * sizeof( VSdrwKeyWord ) ; 
		if( !( newList = realloc( ForeignKwList, size ) ) )
								return FALSE ;
	}

	ok = TRUE ;
	loc_count = ForeignKwCount;

	for( i = ForeignKwCount, j = 0 ; i < ForeignKwCount+count ; ++i, j++ ) {

		if( VSdrwKeyword( names[j], (FILE *) NULL, &token ) ) continue;

		if( !( newList[loc_count].text = VSstrdup( names[j] ) ) ) {
			ok = FALSE ; break ;
		}

		switch( usages[j] ) {
		 case VSdrwVIEW		:
		   if(    addresses[j].view < VSunknownViewType
		       || addresses[j].view % 2 != 0 ) {
		     fprintf( stderr,
			 "!!! The value for view type `%s' is invalid:\n",
			 names[j] ) ;
		     fprintf( stderr,
		         "!!! It must be a power of 2 greater than %d.\n",
       			 VSunknownViewType ) ;
		     ok = FALSE ; break ;
		   }    
		        newList[loc_count].type = OTHER_VIEW  ;break ;
		 case VSdrwTYPE		: 
			newList[loc_count].type = ELMTYPE     ;break ;
		 case VSdrwFUNCTION	: 
			newList[loc_count].type = VS_FUNCTION ;break ;
		 case VSdrwOUTPUT	: 
			newList[loc_count].type = GROUTPUT    ;break ;
		}

		newList[loc_count].action	= addresses[j].any ; 
		++loc_count;
	}
	if( !ok ) {
		/*
		 * I know I am not freeing the memory possibly allocated for
		 * a few of the 'newList[i].text'... But anyway we're almost
		 * over the edge memory-wise if we can no longer malloc...
		 */
		if( !ForeignKwList ) {
			free( newList ) ;
		} else {
			/*
			 * Shrink back array to its original size ...
			 */
			 ForeignKwList = realloc( ForeignKwList,
			 			    ForeignKwCount
			 			  * sizeof( VSdrwKeyWord ) ) ;
		}
	} else {
		ForeignKwCount	= newCount ;
		ForeignKwList	= newList ;
		qsort( (char *) ForeignKwList, (unsigned) ForeignKwCount,
			sizeof( VSdrwKeyWord ), VSkwCmp ) ;
	}

#if 0
	printf( "Added %d keywords\n", ForeignKwCount ) ;
	for( i = 0 ; i < ForeignKwCount ; i++ ) {
		printf( "%d: <%s>\n", i, ForeignKwList[i].text ) ;
	}
#endif
	return ok ;
	
} /* VSdrwAddFunctions */
/*----------------------------------------------------------------------------*/
void VSdrwRmFunctions( void ) {

	if( ForeignKwList ) {
		int	i ;

		for( i = 0 ; i < ForeignKwCount ; i++ ) {
			if( ForeignKwList[i].text )
				free( ForeignKwList[i].text ) ;
		}
		free( ForeignKwList ) ;
		ForeignKwList = NULL ;
		ForeignKwCount= 0 ;
	}

} /* VSdrwRmFunctions */
/*----------------------------------------------------------------------------*/

