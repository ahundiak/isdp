/* $Id: v_drw.h,v 1.2 2001/01/08 18:56:22 art Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	include / v_drw.h
 *
 * Description:
 *	Data structures for drawing process and parser
 *
 * Dependencies:
 *	v_drwdef.h
 *
 * History:
 *	3/15/95		tlb		Add hidden symbology to 
 *						VD_drwConstructData 
 *					Define hidden symb. override flags
 *	3/21/95		tlb		
 *					Add processFlags to VD_drwExecData, 
 *						and VD_drwInputData 
 *					Add enum VD_e_drwProcessFlags 
 *
 *	3/28/95		adz		Add refSetName to VD_drwInputData
 *
 * 	3/31/95		tlb		Add VD_drwQueryGraType to 
 *						VD_drwElmQueryItem 
 *	7/25/95		tlb		Move VD_drwArgLst to v_slc.h
 *	8/15/95		adz		Add notDefined type (VD_e_drwViewType)
 *      5/20/98         Ming            Add applicationFlag to VD_drwInputData
 *                                      and define VD_K_DRW_VISUAL, 
 *					VD_K_DRW_VOLUMECUT, VD_K_DRW_SYMBOLOGY
 *
 *      1/04/01          ah             See comments in v_drwcmd.h
 *************************************************************************/

#ifndef v_drw_include
#	define v_drw_include

#ifndef _STDIO_H
#	include <stdio.h>
#endif
#ifndef _SYS_PARAM_H
#	include <sys/param.h>		/* For	'MAXPATHLEN'	*/
#endif
#ifndef v_slc_include
#	include "v_slc.h"
#endif
#ifndef grdpbdef_include
#	include "grdpbdef.h"
#endif
#ifndef grdpb_include
#	include "grdpb.h"
#endif

#ifdef X11
#include "standards.h"
#endif

/*
 * How element is seen (ORable masks so as to select upon several views at the
 * same time). Note: VD_anyViewType is 0xFFFFFFFF (we have to use the decimal
 * notation because of a bug in opp).
 */
enum VD_e_drwViewType	{	VD_notDefinedType	= 0,
				VD_fromTop		= 1,
				VD_fromBottom		= 2,
				VD_fromSide		= 4,
				VD_endOn		= 8,
				VD_unknownViewType	= 16,
				VD_anyViewType		= 4294967295
} ;
typedef enum VD_e_drwViewType VD_drwViewType ;

/*
 * Position of text with respect to drawn element when element is vertical
 * with respect to the axes of the drawing sheet.
 */
enum VD_e_drwVertTxOffset	{	VD_above		= 300,
					VD_vcenter		= 310,
					VD_below		= 320
} ;
typedef enum VD_e_drwVertTxOffset VD_drwVertTxOffset ;

/*
 * Position of text with respect to drawn element when element is horizontal
 * with respect to the axes of the drawing sheet.
 */
enum VD_e_drwHoriTxOffset	{	VD_toTheLeft	= 400,
					VD_hcenter	= 410,
					VD_toTheRight	= 420
} ;
typedef enum VD_e_drwHoriTxOffset VD_drwHoriTxOffset ;

/*
 * Direction of text with respect to drawn element.
 * VD_para	: parallel to element.
 * VD_ortho	: orthogonal to element.
 * VD_horiz	: along horizontal axis of the drawing sheet.
 */
enum VD_e_drwTxDir		{
					VD_horiz	= 100,
					VD_para  = 110,
					VD_ortho = 120
} ;
typedef enum VD_e_drwTxDir VD_drwTxDir ;

/*
 * Text location with respect to the drawn element.
 * VD_middle	: center of closed curve/midpoint of open curve.
 * VD_center	: center of curve.
 * VD_innermost	: at innermost point of curve.
 * VD_left	: to the left of curve.
 * VD_right	: to the right of curve.
 * VD_top	: on top of curve.
 * VD_bottom	: on bottom of curve.
 * VD_1stEnd	: at first  end point of curve.
 * VD_2ndEnd	: at second end point of curve.
 * NOTE: the "first" end point of the curve is either the uppermost or the
 * leftmost end point, depending upon the direction of the curve, likewise
 * the second end point will either be the lowermost or the rightmost one.
 */
enum VD_e_drwTxLoc		{	VD_middle	= 200,
					VD_center	= 210,
					VD_innermost	= 220,
					VD_left		= 230,
					VD_right	= 240,
					VD_top		= 250,
					VD_bottom	= 260,
					VD_1stEnd	= 270,
					VD_2ndEnd	= 280
} ;
typedef enum VD_e_drwTxLoc VD_drwTxLoc ;

/*
 * How text should be wriiten on the drawing sheet :
 *
 * not-reversed	upside-down	right-to-left	upside-down + right-to-left
 * xxxxxxx	x		xxxxxxx		      x
 * x		x		      x		      x
 * xxxx		xxxx		   xxxx		   xxxx
 * x		x		      x		      x
 * x		xxxxxxx		      x		xxxxxxx
 */
enum VD_e_drwTxRev {
		VD_notReversed	= 0,
		VD_upsideDown	= 1,
		VD_rightToLeft   = 2
} ;

typedef enum VD_e_drwTxRev VD_drwTxRev ;

struct VD_s_drwTxPosition {
	double			voffVal,
				hoffVal ;
	VD_drwTxLoc		loc ;
	VD_drwVertTxOffset	voff ;
	VD_drwHoriTxOffset	hoff ;
	VD_drwTxDir		dir ;
	VD_drwTxRev		rev ;
} ;
typedef struct VD_s_drwTxPosition VD_drwTxPosition ;

/*
 * Display attribute to put to the drawn element.
 * scale	: scale factor where applicable.
 * offset	: offset of axis from beam along profile direction, where
 *		  applicable.
 * filledDisplay: filled display where applicable (closed curves).
 * hiddenStyle	: style desired for hidden lines.
 *			field retained for compatibility with existing code
 *			in future all hidden symbology in VD_drwConstructData 
 */
struct VD_s_drwDspAttr {
	double			scale,
				offset ;
	int			filledDisplay,
				hiddenStyle ;	/* TEMPORARILY retained 
							for compatibility */
} ;
typedef struct VD_s_drwDspAttr VD_drwDspAttr ;

/*
 * Construction data
 */
struct VD_s_drwConstructData {
	double			viewConeAngle ;
	struct GRdpb_text_symb	textSymb ;
	VD_drwDspAttr		dpAttr ;
	VD_drwTxPosition	textPos ;
	struct IGRdisplay	elmDisplay ;	/* visible line symbology */
	struct IGRdisplay	hdnDisplay ;	/* hidden line symbology */
	short			elmLevel ;	/* visible line level */	
	short			hdnLevel ;	/* hidden line level */
} ;
typedef	struct VD_s_drwConstructData VD_drwConstructData ;

/*
 * List of elements which have been selected to be drawn on the drawing sheet.
 */
struct VD_s_drwGroup {
	int		elmCount ;
	struct GRid	*elmList ;
} ;
typedef struct VD_s_drwGroup VD_drwGroup ;

/*
 * Drawing information.
 * drwEnv	: mod. env. of file of drawing sheet.
 * drwLbsys	: extents and axes of drawing sheet.
 * drwPlane	: plane of drawing sheet to project elements.
 * viewPlane	: plane selected in model for creation of drawing view.
 * viewVector	: vector in model representing where eye points to.
 */
struct VD_s_drwInfo {
	struct GRmd_env		*drwEnv ;
	struct IGRlbsys		*drwLbsys ;
	struct IGRplane		*drwPlane ;
	struct IGRplane		*viewPlane ;
	double			*viewVector ;
} ;
typedef struct VD_s_drwInfo VD_drwInfo ;

/*
 * Structure to handle file inclusions (when a setup file includes other files).
 * iScanned	: index in stack of currently scanned file (-1 if stack is
 *		  empty).
 * stream	: stack of opened file streams
 * name		: stack of names of opened files.
 * lineno	: #of scanned line where file was interrupted.
 *
 * For total storage :	(Used for batch processing).
 * =================
 * files	: Total number of files related to the input files.
 * nFiles	: #of files found.
 * storage	: flag indication to store or not, default FALSE. 
 */
#ifndef MAXPATHLEN
#	define MAXPATHLEN 1024	/* #defined in /usr/include/sys/param.h */
#endif
#define VD_K_DRW_MAXINFILES	10		/* Maximum nested dept	*/
#define VD_K_DRW_MAXSTORAGE	30		/* Maximum allowed files*/
#define VD_K_DRW_MAXFILESTR	150		/* buffer size		*/
#define VD_K_DRW_VISUAL         1               /* Visualization        */
#define VD_K_DRW_VOLUMECUT      2               /* Volume-cut           */
#define VD_K_DRW_SYMBOLOGY      3               /* Symbology            */

struct VD_s_drwInputFiles {
	char	name[VD_K_DRW_MAXINFILES][MAXPATHLEN] ;
	FILE	*stream[VD_K_DRW_MAXINFILES] ;
	int	lineno[VD_K_DRW_MAXINFILES] ;
	int	iScanned ;
	char	files[VD_K_DRW_MAXSTORAGE][VD_K_DRW_MAXFILESTR] ;
	int	nFiles ;
	int	storage ;
} ;
typedef struct VD_s_drwInputFiles VD_drwInputFiles ;

/*
 * Data input to configuration interpreter.
 * defaults	: defaults parameters for construction
 * processFlags : global flags used to control processing of objects 
 * applicationFlag  : flag for visualization, volume-cut, or symbology
 * elmId	: id of element being drawn
 * elmEnv	: mod. env. of element being drawn.
 * drwInfo	: info about drawing.
 * toBeDrawn	: list of all elements which have been selected for this sheet.
 * viewType	: type of the view.
 * inputFiles	: stack of input files (to handle file inclusion).
 * constDefName	: name of macro definition (for extraction of macro occurrences).
 */
struct VD_s_drwInputData {
	VD_drwConstructData	defaults ;
	int			processFlags;
        short			applicationFlag;
	GRname			refSetName;
	struct GRid		*elmId ;
	struct GRmd_env		*elmEnv ;
	VD_drwInfo		drwInfo ;
	VD_drwGroup		toBeDrawn ;
	VD_drwViewType		viewType ;
	VD_drwInputFiles	inputFiles ;
	GRname			constDefName ;
	void			*appData ;
} ;
	
typedef	struct VD_s_drwInputData VD_drwInputData ;

/*
 * How to position the text on the drawing sheet.
 * VD_useAnchorPoint	: use the anchor point provided.
 * VD_useAnchorCurve	: use the anchor curve provided.
 * VD_useFirstCurve	: use the first of the curves representing the
 *			  extracted element on the drawing sheet.
 * VD_useAllCurves	: use all curves representing the extracted element
 *			  on the drawing sheet.
 */
enum VD_e_drwTxPosHelper {
	VD_undefTxPosHelper,
	VD_useAnchorPoint,
	VD_useAnchorCurve,
	VD_useFirstCurve,
	VD_useAllCurves
} ;
typedef enum VD_e_drwTxPosHelper VD_drwTxPosHelper ;

/*
 * Which point to use as the anchor point :
 * VD_drwAnchorCenter	: center of the graphic object.
 * VD_drwAnchorCtrOfGrv	: center of gravity of the graphic object.
 * VD_drwAnchorCtrOfBox	: center of range box of the graphic object.
 */
enum VD_e_drwAnchorType {
	VD_drwAnchorCenter,
	VD_drwAnchorCtrOfGrv,
	VD_drwAnchorCtrOfBox
} ;
typedef enum VD_e_drwAnchorType VD_drwAnchorType ;

/*
 * Support structure for text string of graphic text.
 * buffer	: points to an allocated character array.
 * bufsiz	: number of characters allocated in `buffer'.
 * curpos	: points to next available position in `buffer'.
 */
struct VD_s_drwText {
	char		*buffer ;
	unsigned long	bufsiz,
			curpos ;
} ;
typedef struct VD_s_drwText VD_drwText ;

struct VD_s_drwGarbage {
	struct GRobj_env	temporary ;
	struct VD_s_drwGarbage	*next ;
} ;
typedef struct VD_s_drwGarbage VD_drwGarbage ;

/*
 * Data output by the interpreter.
 * count	: number of constructed elements.
 * list		: ids of constructed elements.
 */
struct VD_s_drwGraphicGroup {
	int		count ;
	struct GRid	*list ;
} ;
typedef struct VD_s_drwGraphicGroup VD_drwGraphicGroup ;

struct VD_s_drwOutputData {

	VD_drwGraphicGroup		set ;
	VD_execRes			tag ;
	int				isText ;
	struct VD_s_drwOutputData	*next ;
} ;
typedef struct VD_s_drwOutputData VD_drwOutputData ;

enum VD_e_drwElmQueryItem {
	VD_drwQueryType   = 1,
	VD_drwQueryView   = 2,
	VD_drwQueryFilter = 4,
	VD_drwQueryGraType  = 8
} ;
typedef enum VD_e_drwElmQueryItem VD_drwElmQueryItem ;

/*
 * Bits flagging the symbology items which the user has set manually in
 * the APFEL-STUDEL file, thus overriding the defaults. Note that if, say,
 * the default weight was 1 and the used as set "weight = 1", the bit
 * `VD_drwWeightOverriden' will be set anyhow.
 */
enum VD_e_drwSymbologyOverrides {
	VD_drwColorOverriden 	= 1,
	VD_drwWeightOverriden	= 2,
	VD_drwStyleOverriden 	= 4,
	VD_drwLevelOverriden 	= 8,
	VD_drwHdnColorOverriden = 16,
	VD_drwHdnWeightOverriden= 32,
	VD_drwHdnStyleOverriden = 64,
	VD_drwHdnLevelOverriden = 128
} ;

/*
 * Bits flagging the global processing of objects which the user has 
 * set manually in the APFEL-STUDEL file, thus overriding the defaults. 
 */
enum VD_e_drwProcessFlags {
	VD_drwZClipActive 	= 1,
	VD_drwCheckEnvelopes	= 2
};

/*
 * Data set during interpretation of configuration file.
 * logFile	 : file pointer to log file.
 * processFlags  : global flags used to control processing of objects 
 * overrides	 : overrides of construction defaults of `VD_drwInputData'
 * symbOverrides : flags the manually overriden symbology items.
 * verbose	 : verbose flag (TRUE/FALSE)
 * elmQuery	 : action associated with an element keyword (type/view).
 * action	 : action associated with a keyword.
 * tag		 : tag associated with an output.
 * lastGraphic	 : last graphic group constructed.
 * parsedElmType : type of the element for which interpreter is run.
 * parsedElmDesc : lexical token corresponding to element type.
 * parsedViewType: type of view.
 * txPosHelper	 : where to position text in graphic group
 * anchorPoint	 : anchor point for text (optional).
 * anchorCurve	 : anchor curve for text (optional).
 * textFormat	 : format for text (including possible text commands).
 * filter        : string with regular expression (UNIX shell style) used
 *		   to filter out elements or group them together. It is
 *		   checked against the macro definition name.
 * viewCriterion : name of foot to get view (for macro occurrences).
 * garbageList	 : temporary objects to get rid of at end of execution.
 */
struct VD_s_drwExecData {
	FILE			*logFile ;
	int			processFlags;
	VD_drwConstructData	overrides ;
	unsigned long		symbOverrides ;
	int			verbose ;
	VD_drwText		library ; /* added to take cell library */
	void			(*elmQuery)() ;
		/*
	 	 * 'elmQuery' is in fact 
	 	 * void (*elmQuery)(	unsigned long		mask,
	 	 *			VD_drwInputData		*inp,
	 	 *			struct VD_s_drwExecData	*xData )
	 	 * But due to OPP bugs a lot of type mismatch arise if we do so.
	 	 */
	void			(*action)() ;
	VD_execRes		tag ;
	VD_drwGraphicGroup	*lastGraphic ;
	unsigned long		parsedElmType ;
	VD_drwViewType		parsedViewType ;
	VD_drwTxPosHelper	txPosHelper ;
	IGRpoint		anchorPoint ;
	struct GRobj_env	anchorCurve ;
	VD_drwText		textFormat ;
	VD_tktxt		parsedElmDesc ;
	GRname			filter,
				viewCriterion ;
	VD_drwGarbage		*garbageList ;
	int			selectMask;	/* fo unit process */
} ;
typedef	struct VD_s_drwExecData VD_drwExecData ;

struct VD_s_drwCaseOf	{
	int		tok ;
	long		val ;
	VD_tktxt	txt ;
} ;

typedef struct VD_s_drwCaseOf VD_drwCaseOf ;

/*
 * Error codes return by functions.
 */
enum VD_e_XFrc {	xfUNKFCN,	/* Unknown function		*/
			xfINVARG,	/* Invalid argument		*/
			xfARGCOUNT,	/* Wrong count of arguments	*/
			xfFAILURE,	/* Evaluation failure		*/
			xfSUCCESS } ;	/* Successful evaluation	*/

typedef enum VD_e_XFrc VD_xfRC ;

/*
 * Actions associated to a token.
 */
typedef void (*VD_drwElmQuery)		__((
					unsigned long		mask,
					VD_drwInputData		*inp,
					struct VD_s_drwExecData	*xData )) ;

typedef VD_xfRC (*VD_drwFunction)		__((	
					const VD_drwInputData 	*inp,
					VD_drwExecData 		*xData,
					const char 		*function,
					const VD_drwArgLst	*argl,
					int			argc,
					VD_execRes		*result )) ;

typedef VD_xfRC (*VD_drwOutput)		__((
					VD_drwInputData		*inp,
					VD_drwExecData		*xData,
					const char		*output,
					const VD_drwArgLst	*argl,
					int			argc,
					VD_drwGraphicGroup	*groutput )) ;

enum VD_e_drwUsrTokType {
	VD_drwVIEW,
	VD_drwTYPE,
	VD_drwFUNCTION,
	VD_drwOUTPUT
} ;
typedef enum VD_e_drwUsrTokType  VD_drwUsrTokType ;

union VD_u_drwAction {
	void			(*any)() ;
	long			(*undefined) __(( void )) ;
	VD_drwElmQuery		elmQuery ;		/* typFinder */
	VD_drwFunction		function ;
	VD_drwOutput		output ;
	unsigned long		view ;
} ;
typedef union VD_u_drwAction VD_drwAction ;

/*
 * Languange keyword.
 */
struct VD_s_drwKeyWord {
	char	*text ;
	int	type ;
	void	(*action)() ;
} ;
typedef struct VD_s_drwKeyWord VD_drwKeyWord ;

/*
 * Yacc token
 */
struct VD_s_drwToken {
	int		type ;
	VD_allTypes	v ;
	VD_drwAction	action ;
} ;
typedef struct VD_s_drwToken VD_drwTOKEN ;

struct VD_s_BlkJustPnts {
	IGRpoint	BotLeft,
			BotMid,
			BotRight,
			RightMid,
			TopRight,
			TopMid,
			TopLeft,
			LeftMid,
			Center ;
} ;
typedef struct VD_s_BlkJustPnts VD_blkJustPnts ;

enum VD_e_DirectionType {
				VD_horizontal,
				VD_vertical
} ;
typedef enum VD_e_DirectionType VD_directionType ;

enum VD_e_txPosType	{
	VD_txLoc,
	VD_txDir,
	VD_txRev
} ;

typedef enum VD_e_txPosType VD_txPosType ;

/* -----------------------------------------------
 * Bypasses a Forte 6.0 compile problem
 */
#ifndef   v_drwcmd_include
#include "v_drwcmd.h"
#endif

#define VDyydrwCONST const

#endif
