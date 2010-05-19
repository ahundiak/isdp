/* $Id: VSdrw.h,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/include/VSdrw.h
 *
 * Description:
 *		Support I/STRUCT functionalities in I/VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdrw.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/08/16  14:49:26  pinnacle
 * Created: vddraw/include/VSdrw.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/13/95	adz		creation date
 *
 ***************************************************************************/

#ifndef VSdrw_include
#	define VSdrw_include

#ifndef _STDIO_H
#	include <stdio.h>
#endif
#ifndef _SYS_PARAM_H
#	include <sys/param.h>		/* For	'MAXPATHLEN'	*/
#endif
#ifndef VSslc_include
#       include "VSslc.h"
#endif
#ifndef grdpbdef_include
#	include "grdpbdef.h"
#endif
#ifndef grdpb_include
#	include "grdpb.h"
#endif

/*
 * How element is seen (ORable masks so as to select upon several views at the
 * same time). Note: VSanyViewType is 0xFFFFFFFF (we have to use the decimal
 * notation because of a bug in opp).
 */
enum VS_e_drwViewType	{	VSfromTop		= 1,
				VSfromBottom		= 2,
				VSfromSide		= 4,
				VSendOn			= 8,
				VSunknownViewType	= 16,
				VSanyViewType		= 4294967295
} ;
typedef enum VS_e_drwViewType VSdrwViewType ;

/*
 * Position of text with respect to drawn element when element is vertical
 * with respect to the axes of the drawing sheet.
 */
enum VS_e_drwVertTxOffset	{	VSabove		= 300,
					VSvcenter	= 310,
					VSbelow		= 320
} ;
typedef enum VS_e_drwVertTxOffset VSdrwVertTxOffset ;

/*
 * Position of text with respect to drawn element when element is horizontal
 * with respect to the axes of the drawing sheet.
 */
enum VS_e_drwHoriTxOffset	{	VStoTheLeft	= 400,
					VShcenter	= 410,
					VStoTheRight	= 420
} ;
typedef enum VS_e_drwHoriTxOffset VSdrwHoriTxOffset ;

/*
 * Direction of text with respect to drawn element.
 * VSpara	: parallel to element.
 * VSortho	: orthogonal to element.
 * VShoriz	: along horizontal axis of the drawing sheet.
 */
enum VS_e_drwTxDir		{
					VShoriz	= 100,
					VSpara  = 110,
					VSortho = 120
} ;
typedef enum VS_e_drwTxDir VSdrwTxDir ;

/*
 * Text location with respect to the drawn element.
 * VSmiddle	: center of closed curve/midpoint of open curve.
 * VScenter	: center of curve.
 * VSinnermost	: at innermost point of curve.
 * VSleft	: to the left of curve.
 * VSright	: to the right of curve.
 * VStop	: on top of curve.
 * VSbottom	: on bottom of curve.
 * VS1stEnd	: at first  end point of curve.
 * VS2ndEnd	: at second end point of curve.
 * NOTE: the "first" end point of the curve is either the uppermost or the
 * leftmost end point, depending upon the direction of the curve, likewise
 * the second end point will either be the lowermost or the rightmost one.
 */
enum VS_e_drwTxLoc		{	VSmiddle	= 200,
					VScenter	= 210,
					VSinnermost	= 220,
					VSleft		= 230,
					VSright		= 240,
					VStop		= 250,
					VSbottom	= 260,
					VS1stEnd	= 270,
					VS2ndEnd	= 280
} ;
typedef enum VS_e_drwTxLoc VSdrwTxLoc ;

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
enum VS_e_drwTxRev {
		VSnotReversed	= 0,
		VSupsideDown	= 1,
		VSrightToLeft   = 2
} ;

typedef enum VS_e_drwTxRev VSdrwTxRev ;

struct VS_s_drwTxPosition {
	double			voffVal,
				hoffVal ;
	VSdrwTxLoc		loc ;
	VSdrwVertTxOffset	voff ;
	VSdrwHoriTxOffset	hoff ;
	VSdrwTxDir		dir ;
	VSdrwTxRev		rev ;
} ;
typedef struct VS_s_drwTxPosition VSdrwTxPosition ;

/*
 * Display attribute to put to the drawn element.
 * scale	: scale factor where applicable.
 * offset	: offset of axis from beam along profile direction, where
 *		  applicable.
 * filledDisplay: filled display where applicable (closed curves).
 * hiddenStyle	: style desired for hiddel lines.
 */
struct VS_s_drwDspAttr {
	double			scale,
				offset ;
	int			filledDisplay,
				hiddenStyle ;
} ;
typedef struct VS_s_drwDspAttr VSdrwDspAttr ;

struct VS_s_drwConstructData {
	double			viewConeAngle ;
	struct GRdpb_text_symb	textSymb ;
	VSdrwDspAttr		dpAttr ;


	VSdrwTxPosition		textPos ;
	struct IGRdisplay	elmDisplay ;
	short			elmLevel ;
} ;
typedef	struct VS_s_drwConstructData VSdrwConstructData ;

/*
 * List of elements which have been selected to be drawn on the drawing sheet.
 */
struct VS_s_drwGroup {
	int		elmCount ;
	struct GRid	*elmList ;
} ;
typedef struct VS_s_drwGroup VSdrwGroup ;

/*
 * Drawing information.
 * drwEnv	: mod. env. of file of drawing sheet.
 * drwLbsys	: extents and axes of drawing sheet.
 * drwPlane	: plane of drawing sheet to project elements.
 * viewPlane	: plane selected in model for creation of drawing view.
 * viewVector	: vector in model representing where eye points to.
 */
struct VS_s_drwInfo {
	struct GRmd_env		*drwEnv ;
	struct IGRlbsys		*drwLbsys ;
	struct IGRplane		*drwPlane ;
	struct IGRplane		*viewPlane ;
	double			*viewVector ;
} ;
typedef struct VS_s_drwInfo VSdrwInfo ;

/*
 * Structure to handle file inclusions (when a setup file includes other files).
 * iScanned	: index in stack of currently scanned file (-1 if stack is
 *		  empty).
 * stream	: stack of opened file streams
 * name		: stack of names of opened files.
 * lineno	: #of scanned line where file was interrupted.
 */
#ifndef MAXPATHLEN
#	define MAXPATHLEN 1024	/* #defined in /usr/include/sys/param.h */
#endif
#define VS_K_DRW_MAXINFILES	10

struct VS_s_drwInputFiles {
	char	name[VS_K_DRW_MAXINFILES][MAXPATHLEN] ;
	FILE	*stream[VS_K_DRW_MAXINFILES] ;
	int	lineno[VS_K_DRW_MAXINFILES] ;
	int	iScanned ;
} ;
typedef struct VS_s_drwInputFiles VSdrwInputFiles ;

/*
 * Data input to configuration interpreter.
 * defaults	: defaults parameters for construction
 * elmId	: id of element being drawn
 * elmEnv	: mod. env. of element being drawn.
 * drwInfo	: info about drawing.
 * toBeDrawn	: list of all elements which have been selected for this sheet.
 * viewType	: type of the view.
 * inputFiles	: stack of input files (to handle file inclusion).
 * constDefName	: name of macro definition (for extraction of macro occurrences).
 */
struct VS_s_drwInputData {

	VSdrwConstructData	defaults ;
	struct GRid		*elmId ;
	struct GRmd_env		*elmEnv ;
	VSdrwInfo		drwInfo ;
	VSdrwGroup		toBeDrawn ;
	VSdrwViewType		viewType ;
	VSdrwInputFiles		inputFiles ;
	GRname			constDefName ;
	void			*appData ;
} ;
	
typedef	struct VS_s_drwInputData VSdrwInputData ;

/*
 * How to position the text on the drawing sheet.
 * VSuseAnchorPoint	: use the anchor point provided.
 * VSuseAnchorCurve	: use the anchor curve provided.
 * VSuseFirstCurve	: use the first of the curves representing the
 *			  extracted element on the drawing sheet.
 * VSuseAllCurves	: use all curves representing the extracted element
 *			  on the drawing sheet.
 */
enum VS_e_drwTxPosHelper {
	VSundefTxPosHelper,
	VSuseAnchorPoint,
	VSuseAnchorCurve,
	VSuseFirstCurve,
	VSuseAllCurves
} ;
typedef enum VS_e_drwTxPosHelper VSdrwTxPosHelper ;

/*
 * Which point to use as the anchor point :
 * VSdrwAnchorCenter	: center of the graphic object.
 * VSdrwAnchorCtrOfGrv	: center of gravity of the graphic object.
 * VSdrwAnchorCtrOfBox	: center of range box of the graphic object.
 */
enum VS_e_drwAnchorType {
	VSdrwAnchorCenter,
	VSdrwAnchorCtrOfGrv,
	VSdrwAnchorCtrOfBox
} ;
typedef enum VS_e_drwAnchorType VSdrwAnchorType ;

/*
 * Support structure for text string of graphic text.
 * buffer	: points to an allocated character array.
 * bufsiz	: number of characters allocated in `buffer'.
 * curpos	: points to next available position in `buffer'.
 */
struct VS_s_drwText {
	char		*buffer ;
	unsigned	bufsiz,
			curpos ;
} ;
typedef struct VS_s_drwText VSdrwText ;

struct VS_s_drwGarbage {
	struct GRobj_env	temporary ;
	struct VS_s_drwGarbage	*next ;
} ;
typedef struct VS_s_drwGarbage VSdrwGarbage ;

/*
 * Data output by the interpreter.
 * count	: number of constructed elements.
 * list		: ids of constructed elements.
 */
struct VS_s_drwGraphicGroup {
	int		count ;
	struct GRid	*list ;
} ;
typedef struct VS_s_drwGraphicGroup VSdrwGraphicGroup ;

struct VS_s_drwOutputData {

	VSdrwGraphicGroup		set ;
	VSexecRes			tag ;
	int				isText ;
	struct VS_s_drwOutputData	*next ;
} ;
typedef struct VS_s_drwOutputData VSdrwOutputData ;

enum VS_e_drwElmQueryItem {
	VSdrwQueryType   = 1,
	VSdrwQueryView   = 2,
	VSdrwQueryFilter = 4
} ;
typedef enum VS_e_drwElmQueryItem VSdrwElmQueryItem ;

/*
 * Bits flagging the symbology items which the user has set manually in
 * the APFEL-STUDEL file, thus overriding the defaults. Note that if, say,
 * the default weight was 1 and the used as set "weight = 1", the bit
 * `VSdrwWeightOverriden' will be set anyhow.
 */
enum VS_e_drwSymbologyOverrides {
	VSdrwColorOverriden = 1,
	VSdrwWeightOverriden= 2,
	VSdrwStyleOverriden = 4,
	VSdrwLevelOverriden = 8
} ;

/*
 * Data set during interpretation of configuration file.
 * logFile	 : file pointer to log file.
 * overrides	 : overrides of construction defaults of `VSdrwInputData'
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
struct VS_s_drwExecData {
	FILE			*logFile ;
	VSdrwConstructData	overrides ;
	unsigned long		symbOverrides ;
	int			verbose ;
	/*
	 * 'elmQuery' is in fact 
	 * void (*elmQuery)(	unsigned long		mask,
	 *			VSdrwInputData		*inp,
	 *			struct VS_s_drwExecData	*xData )
	 * But due to OPP bugs a lot of type mismatch arise if we do so.
	 */
	void			(*elmQuery)() ;
	void			(*action)() ;
	VSexecRes		tag ;
	VSdrwGraphicGroup	*lastGraphic ;
	unsigned long		parsedElmType ;
	VSdrwViewType		parsedViewType ;
	VSdrwTxPosHelper	txPosHelper ;
	IGRpoint		anchorPoint ;
	struct GRobj_env	anchorCurve ;
	VSdrwText		textFormat ;
	VStktxt			parsedElmDesc ;
	GRname			filter,
				viewCriterion ;
	VSdrwGarbage		*garbageList ;
} ;
typedef	struct VS_s_drwExecData VSdrwExecData ;

struct VS_s_drwCaseOf	{
	int	tok ;
	long	val ;
	VStktxt	txt ;
} ;
typedef struct VS_s_drwCaseOf VSdrwCaseOf ;

/*
 * List of arguments of a function.
 */
struct VS_s_drwArgLst {
	VSexecRes		arg ;
	struct VS_s_drwArgLst	*next ;
} ;
typedef struct VS_s_drwArgLst VSdrwArgLst ;

#ifdef	NOT_NEEDED 

/*
 * Error codes return by functions.
 */
enum VS_e_XFrc {	xfUNKFCN,	/* Unknown function		*/
			xfINVARG,	/* Invalid argument		*/
			xfARGCOUNT,	/* Wrong count of arguments	*/
			xfFAILURE,	/* Evaluation failure		*/
			xfSUCCESS } ;	/* Successful evaluation	*/

typedef enum VS_e_XFrc VSxfRC ;

/*
 * Actions associated to a token.
 */
typedef void (*VSdrwElmQuery)		__((
					unsigned long		mask,
					VSdrwInputData		*inp,
					struct VS_s_drwExecData	*xData )) ;

typedef VSxfRC (*VSdrwFunction)		__((	
					const VSdrwInputData 	*inp,
					VSdrwExecData 		*xData,
					const char 		*function,
					const VSdrwArgLst	*argl,
					int			argc,
					VSexecRes		*result )) ;

typedef VSxfRC (*VSdrwOutput)		__((
					VSdrwInputData		*inp,
					VSdrwExecData		*xData,
					const char		*output,
					const VSdrwArgLst	*argl,
					int			argc,
					VSdrwGraphicGroup	*groutput )) ;


enum VS_e_drwUsrTokType {
	VSdrwVIEW,
	VSdrwTYPE,
	VSdrwFUNCTION,
	VSdrwOUTPUT
} ;
typedef enum VS_e_drwUsrTokType  VSdrwUsrTokType ;

union VS_u_drwAction {
	void			(*any)() ;
	long			(*undefined) __(( void )) ;
	VSdrwElmQuery		elmQuery ;
	VSdrwFunction		function ;
	VSdrwOutput		output ;
	unsigned long		view ;
} ;
typedef union VS_u_drwAction VSdrwAction ;

/*
 * Languange keyword.
 */
struct VS_s_drwKeyWord {
	char	*text ;
	int	type ;
	void	(*action)() ;
} ;
typedef struct VS_s_drwKeyWord VSdrwKeyWord ;

/*
 * Yacc token
 */
struct VS_s_drwToken {
	int		type ;
	VSallTypes	v ;
	VSdrwAction	action ;
} ;
typedef struct VS_s_drwToken VSdrwTOKEN ;

#endif /* NOT_NEEDED */

struct VS_s_BlkJustPnts {
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
typedef struct VS_s_BlkJustPnts VSblkJustPnts ;

enum VS_e_DirectionType {
				VShorizontal,
				VSvertical
} ;
typedef enum VS_e_DirectionType VSdirectionType ;

enum VS_e_txPosType	{
	VStxLoc,
	VStxDir,
	VStxRev
} ;

typedef enum VS_e_txPosType VStxPosType ;

struct VSdrw_s_AttrList {
	char			*attrName ;
	struct VSdrw_s_AttrList	*next ;
} ;
typedef struct VSdrw_s_AttrList VSdrwAttrList ;

struct VSdrw_s_MacInfo {
	
	/*
	 * May be a regular expression.
	 */
	char			*macDefName ;

	/*
	 * Name of macro which will represent the above on the drawing sheet.
	 */
	char			*drwMacName ;

	/*
	 * Attributes to report from model to drawing for macro.
	 */
	VSdrwAttrList		*attrList ;

	struct VSdrw_s_MacInfo	*next ;
} ;

typedef struct VSdrw_s_MacInfo VSdrwMacInfo ;

#endif
