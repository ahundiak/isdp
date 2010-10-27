/* $Id: VDdrwkwtable.C,v 1.2 2001/01/19 21:09:49 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwkwtable.C
 *
 * Description:
 *	Keyword table and related functions
 *
 *	To add keywords:
 *		Add entry to table below
 *		If it has a non-null action,
 *			Add ISOFTYPE actions to an VDdrwisoftyp*.I files
 *			Add CALL actions to an VDdrwfcn*.C file
 *			Add protoype to v_drwproto.h
 *	GROUPUT keywords:
 *		Added by application process at call time
 *		Actions defined in VDdrwgroutpt.I file
 *		Protoype in v_drwproto.h
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwkwtable.C,v $
 *	Revision 1.2  2001/01/19 21:09:49  ramarao
 *	Merged from SP.
 *	
 * Revision 1.5  2000/11/06  16:30:16  pinnacle
 * Replaced: vds/vddraw/drw/VDdrwkwtable.C for:  by rchennup for Service Pack
 *
 * Revision 1.4  2000/11/03  23:33:08  pinnacle
 * Replaced: vds/vddraw/drw/VDdrwkwtable.C for:  by rchennup for Service Pack
 *
 * Revision 1.3  2000/07/24  22:04:44  pinnacle
 * Replaced: vds/vddraw/drw/VDdrwkwtable.C for:  by mdong for Service Pack
 *
 * Revision 1.2  2000/07/24  18:41:12  pinnacle
 * Replaced: vds/vddraw/drw/VDdrwkwtable.C for:  by mdong for Service Pack
 *
 * Revision 1.1  2000/07/21  02:28:56  pinnacle
 * Created: vds/vddraw/drw/VDdrwkwtable.C by mdong for Service Pack
 *
 * Revision 1.5  2000/03/15  20:41:44  pinnacle
 * (No comment)
 *
 * Revision 1.4  2000/02/17  15:58:04  pinnacle
 * Added Text related functions.
 *
 * Revision 1.3  2000/02/04  22:43:44  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by impd252 for vds
 *
 * Revision 1.2  2000/02/04  14:53:38  pinnacle
 * Added is_marking_hidden function. (Removed in next release)
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.12  1998/04/19  17:18:58  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by azuurhou for vds
 *
 * Revision 1.9  1998/02/10  21:41:06  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by v250_int for vds
 *
 * Revision 1.8  1997/12/16  19:56:58  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by impd for vds
 *
 * Revision 1.7  1997/11/19  08:44:00  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by rchennup for vds
 *
 * Revision 1.6  1997/10/29  20:53:36  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by rchennup for vds
 *
 * Revision 1.5  1997/10/28  16:09:32  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by rchennup for vds
 *
 * Revision 1.4  1997/10/28  08:47:24  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by vgnair for vds
 *
 * Revision 1.3  1997/09/24  17:27:34  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by mdong for vds
 *
 * Revision 1.2  1997/08/18  09:30:56  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by ksundar for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.11  1995/11/30  20:41:02  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by tlbriggs for vds.240
 *
 * Revision 1.10  1995/08/21  18:56:44  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by tlbriggs for vds.240
 *
 * Revision 1.9  1995/08/16  14:46:44  pinnacle
 * Replaced: vddraw/drw/VDdrwkwtable.C for:  by azuurhou for vds.240
 *
 * Revision 1.8  1995/06/22  00:29:12  pinnacle
 * Replaced: vddraw/drw/V*kw*.C for:  by tlbriggs for vds.240
 *
 * Revision 1.7  1995/05/11  19:12:30  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.6  1995/05/05  08:05:08  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.5  1995/03/31  10:52:22  pinnacle
 * Replace: by tlbriggs for OPE
 *
 *
 * History:
 *	3/15/95	    tlb	    Add new element types: all, macro
 *			    Add modifiers: hidden-color, hidden-weight, 
 *					hidden-level
 *			    Remove graphic outputs
 *			    Add SetProc's
 *
 *	3/20/95	     tlb    Add "cell" elementType, keyword 
 *			    Add keywords ZCLIP, ENVELOPE
 *			    Add VD_drwPrintValidKeywords
 *			    Use general error processing routines
 *
 *	5/2/95	     tlb    Add VD_compGetCompNames 
 *			    Add check for foreign keywords in 
 *				   VD_drwKwFromTokType, VD_drwPrintValidKeywords
 *
 *	5/9/95	     tlb    Add "sym" keyword
 *
 *	6/21/95	     tlb    Move VD_compGetCompNames to vdtbl/func/VDdrwcomp.C
 *			    Add VD_drwElmTypeKeyword
 *	08/12/95     adz    Add I/STRUCT Functions to List.
 *	08/15/95     adz    Delete ISOFTYPE( *_comp )
 *	08/19/95     tlb    Change free to _FREE, realloc to REALLOC
 *	11/20/95     tlb    Add nozzle component
 *	08/12/97     Sundar Add text-member(s) functions.
 *	09/24/97     az/md  Add information for Cable Components.
 *	10/27/97     vini   Add library. 
 *	02/04/00     RR     Added is_marking_hidden function.
 *	02/04/00     Adz    Moved is_marking_hidden function to loft.
 *      02/17/00     RR     Added Text related functions.
 *      03/15/00     Ming   For TR179901203. Added "structure" which covers
 *                          beam, stiffener and plate.
 *      07/20/00     Ming   Added "stage" which covers stage nodes.
 *      07/24/00     Ming   Added "Macro" which covers ACconst objects.
 *************************************************************************/

#include <string.h>
#include <stdlib.h>
#include "v_drw.h"
#include "VDdrwgrammar.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
#include "v_iomacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_ioproto.h"
#include "v_strngproto.h"

#define CALL( _FUNCTION_ )	(void (*)()) VD_drwFUNCTION##_FUNCTION_
#define OUTPUT( _OUTPUT_ )	(void (*)()) VD_drwOUTPUT##_OUTPUT_
#define ISOFTYPE( _TYPE_ )	(void (*)()) VD_drwISOFTYPE##_TYPE_

/*-LIST OF KEYWORDS-----------------------------------------------------------*/
/*
 * Keywords may be added before the end-of-list line.
 */
	static VD_drwKeyWord kwList[] = {
/*
  Keyword		  Corresponding Yacc token value	Action
  -------		  ------------------------------	------
*/
/*
 * Selection on element type.
 */
{ "equipment"			, ELMTYPE	, ISOFTYPE( equipment	) },
{ "compartment"			, ELMTYPE	, ISOFTYPE( compartment	) },
{ "struct-surf"			, ELMTYPE	, ISOFTYPE( struct_surf	) },
{ "split-surf"			, ELMTYPE	, ISOFTYPE( split_surf	) },
{ "bound-surf"			, ELMTYPE	, ISOFTYPE( bound_surf	) },
{ "split-volume"		, ELMTYPE	, ISOFTYPE( split_volume ) },
{ "limit-volume"		, ELMTYPE	, ISOFTYPE( limit_volume ) },
{ "profile-volume"		, ELMTYPE	, ISOFTYPE( profile_volume ) },
{ "section"			, ELMTYPE	, ISOFTYPE( section	) },
{ "inf-plane"			, ELMTYPE	, ISOFTYPE( inf_plane	) },
{ "plane-system"		, ELMTYPE	, ISOFTYPE( plane_system ) },
{ "perpendicular"		, ELMTYPE	, ISOFTYPE( perpendicular ) },
{ "stage"			, ELMTYPE	, ISOFTYPE( stage ) },
{ "Macro"			, ELMTYPE	, ISOFTYPE( Macro ) },
/*
 * selection of I/STRUCT objects.
 */
{ "beam"			, ELMTYPE	, ISOFTYPE( beam	) },
{ "stiffener"			, ELMTYPE	, ISOFTYPE( stiffener	) },
{ "plate"			, ELMTYPE	, ISOFTYPE( plate	) },
{ "joint"			, ELMTYPE	, ISOFTYPE( joint	) },
{ "structure"                   , ELMTYPE       , ISOFTYPE( structure   ) },
/*
 * selection of I/LOFT objects.
 */
{ "unwrap"			, ELMTYPE	, ISOFTYPE( unwrap	) },
{ "marking-line"		, ELMTYPE	, ISOFTYPE( marking	) },
{ "roll-line"			, ELMTYPE	, ISOFTYPE( roll	) },
{ "stock-line"			, ELMTYPE	, ISOFTYPE( stock	) },
{ "min-rec"			, ELMTYPE	, ISOFTYPE( min_rec	) },
{ "control-line"		, ELMTYPE       , ISOFTYPE( control     ) },
{ "water-line"			, ELMTYPE       , ISOFTYPE( water       ) },
{ "trace-line"			, ELMTYPE       , ISOFTYPE( trace        ) },
{ "butt-line"			, ELMTYPE       , ISOFTYPE( butt        ) },
{ "seam-line"			, ELMTYPE       , ISOFTYPE( seam        ) },
/*
 * selection of I/ROUTE objects.
 */
{ "pipe"			, ELMTYPE	, ISOFTYPE( pipe	) },
{ "hvac"			, ELMTYPE	, ISOFTYPE( hvac	) },
{ "rway"			, ELMTYPE	, ISOFTYPE( rway	) },
{ "nozzle"			, ELMTYPE	, ISOFTYPE( nozzle	) },
{ "r-equipment"			, ELMTYPE	, ISOFTYPE( r_equipment	) },
/*
 * Selection of I/CABLE objets.
 */
{ "cable"			, ELMTYPE	, ISOFTYPE( cable	) },
{ "guide"			, ELMTYPE	, ISOFTYPE( guide	) },
{ "terminal"			, ELMTYPE	, ISOFTYPE( terminal	) },
{ "connect-comp"		, ELMTYPE	, ISOFTYPE( connect_comp )},
{ "back-shell"			, ELMTYPE	, ISOFTYPE( back_shell	) },
/* 
 * for unit processing 
*/
{ "unit-processing"		, ELMTYPE	, ISOFTYPE( unit_process ) },
/*
 * selection of macros in general
 */
{ "all"				, ELMTYPE	, ISOFTYPE( all		) },
{ "cell"			, ELMTYPE	, ISOFTYPE( cell	) },
{ "sym"				, ELMTYPE	, ISOFTYPE( sym		) },
{ "macro"			, ELMTYPE	, ISOFTYPE( macro	) },
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
 * Graphic output
 */
{ "symbol"			, SYMBOL	, NULL			  },
/*
 * Modifiers to graphic or symbol output.
 */
{ "filled-display"		, FILLED_DISPLAY, NULL },
{ "color"			, COLOR		, NULL },
{ "style"			, STYLE		, NULL },
{ "weight"			, WEIGHT	, NULL },
{ "level"			, LEVEL		, NULL },
{ "hidden-color"		, HIDDEN_COLOR	, NULL },
{ "hidden-style"		, HIDDEN_STYLE	, NULL },
{ "hidden-weight"		, HIDDEN_WEIGHT	, NULL },
{ "hidden-level"		, HIDDEN_LEVEL	, NULL },
{ "scale"			, SCALE		, NULL },
{ "tag"				, TAG		, NULL },
/*
 * Keywords for symbol output.
 */
{ "format"			, FORMAT	, NULL },
{ "library"			, LIBRARY	, NULL },
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
{ "drawing-scale"	     , VD_FUNCTION, CALL( drawing_scale		    ) },
{ "attribute"		     , VD_FUNCTION, CALL( attribute		    ) },
{ "basename"		     , VD_FUNCTION, CALL( basename		    ) },
{ "text-member"              , VD_FUNCTION, CALL( text_member               ) },
{ "text-members"             , VD_FUNCTION, CALL( text_members              ) },
{ "get-text-font"            , VD_FUNCTION, CALL( get_text_font             ) },
{ "get-text-justification"   , VD_FUNCTION, CALL( get_text_justification    ) },
{ "get-text-width"           , VD_FUNCTION, CALL( get_text_width            ) },
{ "get-text-height"          , VD_FUNCTION, CALL( get_text_height           ) },
{ "get-text-num-char"        , VD_FUNCTION, CALL( get_text_num_char         ) },
{ "is-element-clipped"	     , VD_FUNCTION, CALL( is_element_clipped	    ) },
{ "view-direction"	     , VD_FUNCTION, CALL( view_direction	    ) },
{ "is-object-hidden"	     , VD_FUNCTION, CALL( is_object_hidden	    ) },
{ "intersect-curve-with-view", VD_FUNCTION, CALL( intersect_curve_with_view ) },
{ "nearest-end-point"	     , VD_FUNCTION, CALL( nearest_end_point	    ) },
{ "const-type"		     , VD_FUNCTION, CALL( const_type		    ) },
{ "get-input"		     , VD_FUNCTION, CALL( get_input		    ) },
{ "get-member"		     , VD_FUNCTION, CALL( get_member		    ) },
{ "get-owner"		     , VD_FUNCTION, CALL( get_owner		    ) },
{ "project-curve"	     , VD_FUNCTION, CALL( project_curve		    ) },
{ "query-database"	     , VD_FUNCTION, CALL( query_database	    ) },
{ "exec-ppl-func"	     , VD_FUNCTION, CALL( exec_ppl_func		    ) },
{ "exec-expression"	     , VD_FUNCTION, CALL( exec_expression	    ) },
{ "in-transp-level-A"	     , VD_FUNCTION, CALL( in_transp_level_A         ) },
{ "in-transp-level-B"	     , VD_FUNCTION, CALL( in_transp_level_B         ) },
{ "in-transp-level-C"	     , VD_FUNCTION, CALL( in_transp_level_C         ) },
{ "in-transp-level-D"	     , VD_FUNCTION, CALL( in_transp_level_D         ) },

#ifdef	NOT_IN_DEFAULT 

/*
 * I/STRUCT relative functions (add as dummies) to pass the parser.
 */

{ "flange-orientation"	     , VD_FUNCTION, CALL( dummy			    ) },
{ "web-orientation"	     , VD_FUNCTION, CALL( dummy			    ) },
{ "beam-orientation"	     , VD_FUNCTION, CALL( dummy			    ) },
{ "where-is"		     , VD_FUNCTION, CALL( dummy			    ) },
{ "first-welded-element"     , VD_FUNCTION, CALL( dummy			    ) },
{ "second-welded-element"    , VD_FUNCTION, CALL( dummy			    ) },
{ "is-a-beam"		     , VD_FUNCTION, CALL( dummy			    ) },
{ "is-a-plate"		     , VD_FUNCTION, CALL( dummy			    ) },
{ "is-a-stiffener"	     , VD_FUNCTION, CALL( dummy			    ) },

#endif 

/*
 * Character string-related functions.
 */
{ "catenate-strings"	     , VD_FUNCTION, CALL( catenate_strings	    ) },
{ "dup-string"		     , VD_FUNCTION, CALL( dup_string		    ) },
{ "string-length"	     , VD_FUNCTION, CALL( string_length		    ) },
{ "word-count"		     , VD_FUNCTION, CALL( word_count		    ) },
{ "get-word"		     , VD_FUNCTION, CALL( get_word		    ) },
{ "sub-string"		     , VD_FUNCTION, CALL( sub_string		    ) },
{ "substitute-string"	     , VD_FUNCTION, CALL( substitute_string	    ) },
{ "match-regexp"	     , VD_FUNCTION, CALL( match_regexp		    ) },
{ "format-number"	     , VD_FUNCTION, CALL( format_number		    ) },
{ "time"		     , VD_FUNCTION, CALL( time			    ) },
/*
 * Array functions.
 */
{ "size-of-array"	     , VD_FUNCTION, CALL( size_of_array		    ) },
/*
 * Aliases for "&", "|" and "!" logical operators respectively.
 */
{ "and"				, VD_AND	, NULL },
{ "or"				, VD_OR		, NULL },
{ "not"				, VD_NOT	, NULL },
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
{ "z-clipping"			, ZCLIP		, NULL },
{ "env-processing"		, ENVELOPE	, NULL },
{ "process-transp-level-A"	, PRC_TRANS_A	, NULL },
{ "process-transp-level-B"	, PRC_TRANS_B	, NULL },
{ "process-transp-level-C"	, PRC_TRANS_C	, NULL },
{ "process-transp-level-D"	, PRC_TRANS_D	, NULL },
{ "set-transp-level-A"		, SET_TRANS_A	, NULL },
{ "set-transp-level-B"		, SET_TRANS_B	, NULL },
{ "set-transp-level-C"		, SET_TRANS_C	, NULL },
{ "set-transp-level-D"		, SET_TRANS_D	, NULL },
/*
 * Keywords for extract statement.
 */
{ "extract"			, EXTRACT	, NULL },
{ "as"				, AS		, NULL },
{ "with"			, WITH		, NULL },
{ NULL				, 0		, NULL } /* End of list */
} ;
/*-DYNAMICALLY ADDED KEYWORDS BY OTHER APPLICATIONS---------------------------*/
static VD_drwKeyWord	*ForeignKwList = NULL ;
static unsigned short	ForeignKwCount = 0 ;
/*----------------------------------------------------------------------------*/
static int VD_kwCmp( KW1, KW2 )

const void	*KW1,
		*KW2 ; {

	return strcmp( ( (VD_drwKeyWord*) KW1 )->text,
		       ( (VD_drwKeyWord*) KW2 )->text ) ;

} /* VD_kwCmp */
/*----------------------------------------------------------------------------*/
int VD_drwKeyword( keyword, logfile, token )

const char	*keyword ;	/* IN : Keyword string			*/
FILE		*logfile ;	/* IN : File for verbose mode		*/
VD_drwTOKEN	*token ; {	/* OUT: Yacc token for input keyword	*/

	/*
	 * Translates input keyword to Yacc token.
	 */
	int			rc		= FALSE ;
	static int		maxKwds		= -1 ;
	VD_drwKeyWord		lookUp,
				*found ;

#ifdef vdsDEBUG
	printf( "-- In keyword <%s>\n", keyword ) ;
#endif

	if( -1 == maxKwds  ) {

		/*
		 * First time call : count keywords and alphabetically sort
		 * keyword list.
		 */
		VD_drwKeyWord	*kw ;
		for( maxKwds = 0, kw = kwList ; kw->text ; kw++ ) maxKwds++ ;

		qsort( (char *) kwList, (unsigned) maxKwds,
			sizeof *kw, VD_kwCmp ) ;
	}

	/*
	 * Do a binary search on keyword list, now supposed alphabetically
	 * sorted.
	 */
	lookUp.text = (char *) keyword ;
	found = (VD_drwKeyWord *) bsearch(	(char *) &lookUp,
						(char *) kwList,
						(unsigned) maxKwds,
						sizeof lookUp,
						VD_kwCmp ) ;
	if( !found ) {
		/*
		 * Try the keywords added by other applications if any...
		 */
		if( ForeignKwList ) {
			found = (VD_drwKeyWord *) bsearch(
						(char *) &lookUp,
						(char *) ForeignKwList,
						(unsigned) ForeignKwCount,
						sizeof lookUp,
						VD_kwCmp ) ;
		}
	}

	if( found ) {
		token->action.any = NULL ;
		switch( token->type = found->type ) {
			case VD_AND	: token->_ival = VD_and ; break ;
			case VD_OR	: token->_ival = VD_or  ; break ;
			case VD_NOT	: token->_ival = VD_not ; break ;
			default		: strcpy( token->_sval, found->text ) ;
					  token->action.any = found->action ;
			}
		rc = TRUE ;
		} 
	else {
		/*
		 * Is it a unit ?
		 */
		char	unit[UOM_K_MAX_LEN] ;
		double	val ;
		long	msg ;

		sprintf( unit, "%g %s", 1., keyword ) ;
		vd_$unit_to_system(	msg	= &msg,
					unit	= unit,
					p_value	= &val ) ;
		if( msg & 1 ) {
			rc = TRUE ;
			strcpy( token->_sval, keyword ) ;
			token->type = UNIT ;

		/*
  		 * Keyword not found
		 *	must check for verbose mode - 
		 *		silent mode used to add GROUTPUT keywords
		 */
		} else if (logfile)
			VD_drwSyntaxError (TRUE , "Unknown keyword: %s\n", 
								keyword ) ; 
	}

	return rc ;

} /* VD_drwKeyword */
/*----------------------------------------------------------------------------*/
/* VD_drwElmTypeKeyword
 *	Get information about ELMTYPE keywords
 *		Used by component functions in vdtbl/func/VDdrwcomp.C
 *	Returns status indicating whether it is an ELMTYPE keyword 
 */
int
VD_drwElmTypeKeyword ( 
	char		*keyword ,	/* IN : Keyword string		*/
	VD_drwTOKEN	*token  	/* OUT: Yacc token for input keyword */
	)
{
	int	found;

	/* verify component is a keyword */ 
	found = vd_$drwKeyword	(	keyword = keyword,
					logfile	= NULL,
					token	= token );
	return (found && token->type == ELMTYPE);
}
/*----------------------------------------------------------------------------*/
const char *VD_drwKwFromTokType( tokType ) register int tokType ; {

	/*
	 * Given a Yacc token type, returns the corresponding keyword.
	 * Returns a pointer to a static buffer.
	 */
	register VD_drwKeyWord	*lookup ;

	for( lookup = kwList ; lookup->text ; lookup++ ) 
		if( lookup->type == tokType ) 
			return (lookup->text) ;
	if( ForeignKwList )
	{
	  for( lookup = ForeignKwList ; lookup->text ; lookup++ ) 
		if( lookup->type == tokType ) 
		  return (lookup->text) ;
	}
	
	return "UNKNOWN" ;

} /* VD_drwKwFromTokType */
/*----------------------------------------------------------------------------*/
/* VD_drwPrintValidKeywords
 *  	Given a Yacc token type, print a list of valid keywords
 *	A list consists of one or more lines
 *	Each line is indented by 2 tabs and is no longer than 80 chars
 */
void 
VD_drwPrintValidKeywords( int tokType ) 
{
	register VD_drwKeyWord	*lookup ;
	int			cnt;		/* char in current line */
	int			len;		/* length of keyword */
	int			first;		/* true if first on line */
	FILE 			*logFile = VD_drwGetLogFile();

	SetProc (VD_drwPrintValidKeywords); Begin

	fputs ("\t\t", logFile );
	cnt = 16;
	first = TRUE;
	for( lookup = kwList ; lookup->text ; lookup++ ) {
		if( lookup->type == tokType ) {
			len = strlen (lookup->text);

			/* line ok */
			if (cnt + len + 2 <= 80 ) {
				if (first) 
					first = FALSE;
				else {
					fputs (", ", logFile);
					cnt  += 2;
					}
				}
			/* line too long - break */
			else  {
				fputs (",\n\t\t", logFile );
				cnt = 16;
				}
			/* add keyword */
			fputs (lookup->text, logFile);
			cnt += len;
			}
		}

	if( ForeignKwList )
	{
	  for( lookup = ForeignKwList ; lookup->text ; lookup++ ) {
		if( lookup->type == tokType ) {
			len = strlen (lookup->text);

			/* line ok */
			if (cnt + len + 2 <= 80 ) {
				if (first) 
					first = FALSE;
				else {
					fputs (", ", logFile);
					cnt  += 2;
					}
				}
			/* line too long - break */
			else  {
				fputs (",\n\t\t", logFile );
				cnt = 16;
				}
			/* add keyword */
			fputs (lookup->text, logFile);
			cnt += len;
			}
	  }
	}
	
	/* end current line */
	fputs ("\n", logFile);
	End
}
/*============================================================================*/
/*
 * API for other applications to plug their own functions into the Drawing
 * Extraction Language. The functions to be added should only be added once.
 */
int VD_drwAddFunctions( count, names, usages, addresses )
	int			count ;
	char			*names[] ;
	VD_drwUsrTokType	usages[] ;
	VD_drwAction		addresses[] ; 
{

	int		i ;
	int		j ;
	int		ok ;
	int		newCount, loc_count ;
	VD_drwKeyWord	*newList = NULL ;
	VD_drwTOKEN	token ;

        SetProc( VD_drwAddFunctions ); Begin

	/*
	 * Check that the new function names do not conflict with existing
	 * keywords...
	 */
	loc_count = 0;
	for( i = 0 ; i < count ; i++ ) {
		if( VD_drwKeyword( names[i], (FILE *) NULL, &token ) ) {
/*
			VD_drwParserError (FALSE, 
			 	"Keyword `%s' already exists in APFEL-STRUDEL\n"
				, names[i] ) ;
			VD_drwParserError (FALSE, 
				"\t-> Addition of keywords aborted.\n" );
			End
		 	return FALSE ;
*/
		}
		else    loc_count++;
	}

	if( !loc_count ) return TRUE;

	newCount = ForeignKwCount + loc_count ;

	if( !ForeignKwList ) {
		if( !( newList = _MALLOC( loc_count, VD_drwKeyWord ) ) ) {
			End
			return FALSE ;
			}
	} else {
		if( !( newList = _REALLOC( ForeignKwList, newCount, 
							VD_drwKeyWord ) )) {
			End
			return FALSE ;
			}
	}

	ok = TRUE ;
	loc_count = ForeignKwCount;

	for( i = ForeignKwCount, j = 0 ; i < ForeignKwCount+count ; ++i, j++ ) {

		if( VD_drwKeyword( names[j], (FILE *) NULL, &token ) ) continue;

		if( !( newList[loc_count].text = VD_strdup( names[j] ) ) ) {
			ok = FALSE ; break ;
		}

		switch( usages[j] ) {
		 case VD_drwVIEW		:
		   if(    addresses[j].view < VD_unknownViewType
		       || addresses[j].view % 2 != 0 ) {
		     VD_drwParserError (FALSE, 
			 	"The value for view type `%s' is invalid:\n",
			 	names[j] ) ;
		     VD_drwParserError (FALSE, 
		         	"It must be a power of 2 greater than %d.\n",
       			 	VD_unknownViewType ) ;
		     ok = FALSE ; break ;
		   }    
		   newList[loc_count].type = OTHER_VIEW  ;break ;
		 case VD_drwTYPE	: 
				newList[loc_count].type = ELMTYPE     ;break ;
		 case VD_drwFUNCTION	: 
				newList[loc_count].type = VD_FUNCTION ;break ;
		 case VD_drwOUTPUT	: 
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
			_FREE( newList ) ;
		} else {
			/*
			 * Shrink back array to its original size ...
			 */
			 ForeignKwList = _REALLOC( ForeignKwList,
			 			   ForeignKwCount,
			 			   VD_drwKeyWord ) ;
		}
	} else {
		ForeignKwCount	= newCount ;
		ForeignKwList	= newList ;
		qsort( (char *) ForeignKwList, (unsigned) ForeignKwCount,
			sizeof( VD_drwKeyWord ), VD_kwCmp ) ;
	}

#if 0
	printf( "Added %d keywords\n", ForeignKwCount ) ;
	for( i = 0 ; i < ForeignKwCount ; i++ ) {
		printf( "%d: <%s>\n", i, ForeignKwList[i].text ) ;
	}
#endif
	End
	return ok ;
	
} /* VD_drwAddFunctions */
/*----------------------------------------------------------------------------*/
void VD_drwRmFunctions( void ) {

        SetProc( VD_drwRmFunctions ); Begin

	if( ForeignKwList ) {
		int	i ;

		for( i = 0 ; i < ForeignKwCount ; i++ ) {
			_FREE( ForeignKwList[i].text ) ;
		}
		_FREE( ForeignKwList ) ;
		ForeignKwList = NULL ;
		ForeignKwCount= 0 ;
	}
	End

} /* VD_drwRmFunctions */
/*----------------------------------------------------------------------------*/

