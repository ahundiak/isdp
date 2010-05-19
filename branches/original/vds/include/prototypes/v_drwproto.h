/* $Id: v_drwproto.h,v 1.9 2001/09/19 14:18:44 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include/prototypes / v_drwproto.h
 *
 * Description:
 *	Prototypes for drawing process, declarations for parser
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: v_drwproto.h,v $
 *      Revision 1.9  2001/09/19 14:18:44  ramarao
 *      Implemented CR# 5546.
 *
 *      Revision 1.7  2001/09/04 14:32:13  ramarao
 *      Fixed TR# 5534.
 *
 *      Revision 1.6  2001/05/31 14:37:42  ramarao
 *      Fixed TR# 5270.
 *
 *      Revision 1.5  2001/03/17 00:01:16  ramarao
 *      Fixed CR# 4467
 *
 *      Revision 1.4  2001/03/08 22:53:51  ramarao
 *      Added "declivity" Keyword in VISUAL and STRUDEL.
 *
 *      Revision 1.3  2001/01/31 17:44:15  ramarao
 *      Implemented CR# 4564.
 *
 *      Revision 1.2  2001/01/10 16:35:41  art
 *      sp merge
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	3/15/95		tlb	Add isoftype all, macro,
 *				Add new graphic outputs,
 *				Remove special Struct, route outputs
 *				Add prototypes: VD_drwSet*,VD_drwPrintSymbology
 *	03/28/95	tlb	Add error routines, parser support functions
 *				GraType routines
 *	04/03/95	adz	Changed VD_drwExecConfig argument list.
 *	05/09/95	tlb	Added parser debug, support for "sym" keyword
 *	07/25/95	tlb	Added new verbose functions, prefix call-back
 *	08/16/95	adz	Add declarations for NEW output functions.
 *	08/21/95	tlb	Add new print functions for unit conversions
 *	11/21/95	tlb	Add keyword "nozzle"
 *	08/12/97	Sundar	Add text_member(s) functions.
 *	09/24/97	ad/mg	Add Cable entrees to list.
 *      06/03/98        Ming    TR179800595. Add entree volume_mem.
 *      02/17/00        RR      Added Text related functions.
 *      03/15/00        Ming    For TR179901203. Added "structure" which covers
 *                              beam, stiffener and plate.
 *	05/16/00	RR	Added get_upper_text and get_lower_text
 *	07/20/00        Ming    Added "stage" which covers stage nodes
 *	07/24/00        Ming    Added "Macro" which covers ACconst objects.
 *      01/10/01        ah      sp merge, added Log
 *************************************************************************/

#ifndef v_drwproto_include
#	define v_drwproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef v_drw_include
#	include "v_drw.h"
#endif
#ifndef fontdef_include
#	include "fontdef.h"
#endif
#ifndef font_include
#	include "font.h"
#endif

extern long
VD_drwOutputGraphic	__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				const char		*output,
				int			text,
				const VD_drwArgLst	*arglist,
				VD_drwOutputData	**outdata ));

extern int
VD_drwAddMacInfo	__((	VD_drwMacInfo		**info,
				const char		*macDefName ));

extern int
VD_drwAddMacDrwName	__((	VD_drwMacInfo		*info,
				const char		*drwMacName ));

extern int
VD_drwAddAttrToMacInfo	__((	VD_drwMacInfo		*info,
				const char		*attrName ));

extern int
VD_drwGetExtractionInfo	__((	long			*msg,
				const char		*setup,
				VD_drwMacInfo		**xinfo ));

extern int
VD_drwCstSymbol		__((	long			*msg,
				const VD_drwInputData	*inp,
				VD_drwExecData		*xData,
				const VD_drwGraphicGroup *outpgr,
				VD_drwGraphicGroup	*outptx ));

extern int
VD_formatNumber		__((	const char		*format,
				double			value,
				char			output[],
				int			size,
				FILE			*errFile ));

extern int
VD_drwParse		__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwMacInfo		**macInfo,
				VD_drwOutputData	**output ));

extern int
VD_yydrwLex		__((	FILE			*errFile,
				VD_drwInputFiles	*inputFiles ));

extern void
VD_drwPrintSymbology	__(( 	char			*desc,
				VD_drwExecData		xData	));
extern void
VD_drwResetSymbology	__(( 	VD_drwExecData 		*xData,
				VD_drwConstructData	*defaults ));

extern void
VD_drwSetColor		__(( 	int			tok_type,
				const VD_execRes 	*value,
				VD_drwExecData		*xData ));
extern void
VD_drwSetStyle		__(( 	int			tok_type,
				int			value,
				VD_drwExecData		*xData ));
extern void
VD_drwSetWeight		__(( 	int			tok_type,
				int			value,
				VD_drwExecData		*xData	));
extern void
VD_drwSetLevel		__(( 	int			tok_type,
				int			value,
				VD_drwExecData		*xData 	));

extern int
VD_checkStyle		__((	int			style ));

extern int
VD_checkWeight		__((	int			weight ));

extern int
VD_checkColor		__((	const VD_execRes	*color,
				int			*colorNumber ));

extern int
VD_checkLayer		__((	int			layer ));

extern int
VD_getTxOffType		__((	int			location,
				int			*offsetType,
				int			*keyword ));

extern int
VD_getTxPosType		__((	int			position,
				int			*posType,
				int			*keyword ));

extern int
VD_checkJustification	__((	int			justification ));

extern int
VD_drwJustToTokNum	__((	int			justification ));

extern int
VD_drwIsElementClipped	__((	long			*msg,
				const VD_drwInputData	*inp,
				const VD_drwExecData	*xData,
				int			*isClipped ));

extern int
VD_retrieveFont		__((	long			*msg,
				const char		*fontName,
				short			*fontPos ));

extern int
VD_getFontInfo		__((	long			*msg,
				short			virtFontNo,
				struct vfont_entry	*fontInfo ));

extern int
VD_drwExecFct		__((	long			*msg,
				const VD_drwInputData	*inp,
				VD_drwExecData		*xData,
				const char		*function,
				const VD_drwFunction	address,
				const VD_drwArgLst	*arglist,
				VD_execRes		*result ));

extern int
VD_drwAnchorCurve	__((	long			*msg,
				const VD_drwInputData	*inp,
				VD_drwExecData		*xData,
				VD_execRes		*curve ));

extern int
VD_drwAnchorPoint	__((	long			*msg,
				const VD_drwInputData	*inp,
				VD_drwExecData		*xData,
				const char		*member,
				VD_drwAnchorType	whichPoint ));

extern int
VD_drwAddGarbage	__((	long			*msg,
				VD_drwExecData		*xData,
				const struct GRobj_env	*temporary ));

extern int
VD_drwIsNewExtraction	__((	void ));


extern void
VD_drwFreeExtractMacInfo
			__((	VD_drwMacInfo		*info ));

extern void
VD_setDrwConfigInput	__((	FILE			*file,
				int			lineno ));

extern int
VD_yydrwWrap		__((	int			verbose,
				VD_drwInputFiles	*inputs ));

extern void
VD_drwResynchLex	__((	void ));

extern void
VD_drwLexUnput		__((	int			character ));

extern void
VD_drwTxInit		__((	VD_drwText		*t ));

extern void
VD_drwTxFree		__((	VD_drwText		*t ));

extern void
VD_drwTxMOVE		__((	VD_drwText		*t,
				char			mvdir,
				double			mvvalue ));

extern void
VD_drwTxFSTART		__((	VD_drwText		*t,
				int			fieldno ));

extern void
VD_drwTxFEND		__((	VD_drwText		*t ));

extern void
VD_drwTxMVTOFLD		__((	VD_drwText		*t,
				VD_drwText		*text,
				short			fieldno,
				char			justification,
				struct GRdpb_text_symb	*txSymb,
				struct IGRdisplay	*display ));

extern void
VD_drwTxCHGFONT		__((	VD_drwText		*t,
				short			fontno ));

extern void
VD_drwTxINITSTRING	__((	VD_drwText		*t,
				const char		*string ));

extern void
VD_drwTxMERGE		__((	const VD_drwText	*toMerge1,
				const VD_drwText	*toMerge2,
				VD_drwText		*merged ));

extern void
VD_getFontMgr		__((	struct GRid		*fontMgr ));

extern void
VD_drwSetLinePrefix 	__((	void (*foo) () 	));

extern void
VD_drwPrintLinePrefix 	__((	void ));

extern void
VD_drwPrintf		__((	const char		*format,
				... ));

extern void
VD_drwPrintLogFile	__((	const char		*format,
				... ));

extern void
VD_drwPrintMsg		__((	const char		*prefix,
				const char		*format,
				... ));
extern void
VD_drwParserTrace	__(( 	const 	char 		*format,
 				... ));

extern void
VD_drwParserDebug	__(( 	const 	char 		*format,
 				... ));

extern void
VD_drwParserWarn	__(( 	int			verbose,
				const char		*format,
				... ));
extern void
VD_drwParserError	__(( 	int			verbose,
				const char		*format,
				... ));
extern void
VD_drwSyntaxError	__(( 	int			verbose,
				const char		*format,
				... ));
extern void
VD_drwIndent		__((	void ));

extern void
VD_drwPrtItem		__((	int			tokType,
				int			valType,
				const void		*value ));

extern void
VD_drwVerbValue		__((	const char		*format,
				const VD_execRes	*value ));

extern void
VD_drwVerbValType	__((  	const char 	*fmt,
				const VD_execRes *val	));
extern char *
VD_drwVerbType		__((  	const VD_execRes *val	));

extern void
VD_drwVerbConv		__(( 	const VD_execRes	*arg,
				const VD_execRes	*res ));

extern void
VD_drwVerbAttr 		__(( 	struct GRobj_env	obj,
				VD_execRes		*attr,
				VD_execRes		*res	));
extern void
VD_drwVerbArgLst	__((	const VD_drwArgLst	*arglist ));

extern void
VD_drwVerbFcnCall	__((	const char		*function,
				const VD_drwArgLst	*arglist ));

extern void
VD_drwVerbUnitConv	__(( 	const char		*unit,
		   		const VD_drwArgLst	*argl,
		     		const VD_execRes	*res ));

extern void
VD_drwVerbUnitConst	__(( 	const char		*unit,
		     		const VD_execRes	*arg,
		     		const VD_execRes	*res ));

extern void
VD_drwVerbOutput	__((	const char		*output,
				const VD_drwArgLst	*arglist,
				int			hasSetup ));

extern void
VD_drwVerbVar		__((	int			flag,
				const char		*varName,
				const VD_execRes	*varValue ));

extern void
VD_drwVerbOp		__((	int			operation,
				const VD_execRes	*operand1,
				const VD_execRes	*operand2,
				const VD_execRes	*result ));

extern void
VD_drwVerbAnchor	__((	const char		*member,
				VD_drwAnchorType	whichPoint ));

extern void
VD_drwInitVarTable	__((	void ));

extern void
VD_drwGetVarVal		__((	const char		*varName,
				VD_execRes		*varValue ));

extern void
VD_drwSetVarVal		__((	const char		*varName,
				const VD_execRes	*varValue ));

extern VD_execRes
*VD_drwAryMalloc	__(( unsigned countOfElements ));

extern void
VD_drwFreeMemoryForArrays
			__(( void ));

extern void
VD_drwGetAryVal		__((	const char		*n,
				const VD_execRes	*index,
				VD_execRes		*val ));

extern void
VD_drwCloseLogFile	__((	void ));

extern void
VD_drwElmNotProcessed	__((	FILE			*logFile,
				const VD_drwInputData	*inp ));

extern void
VD_drwCollectGarbage	__((	VD_drwExecData		*xData ));

extern void
VD_drwSetExtractionFlg	__((	int			new ));

extern const char
*VD_drwKwFromTokType	__((	int			tokType ));

extern void
VD_drwPrintValidKeywords
			__((  	int 			tokType ));

extern const char
*VD_drwVerbViewType	__((	VD_drwViewType		vt ));

extern double
VD_drwDblVal		__((	const VD_execRes	*result ));

extern int
VD_drwIntVal		__((	const VD_execRes	*result ));

extern int
VD_drwBoolVal		__((	const VD_execRes	*result ));

extern char
*VD_drwStrVal		__((	const VD_execRes	*result,
				char			*string ));

extern FILE
*VD_drwOpenLogFile	__((	const char		*filename ));

extern long
VD_drwFindPointOfViewPlaneOnAxis
			__((	long			*msg,
				const struct GRid	*axisId,
				const struct GRmd_env 	*axisEnv,
				const struct IGRplane 	*viewPlane,
				IGRpoint		pt,
				double			*pm ));

extern long
VD_drwGetViewTypeFromConst
			__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData ));

extern int
VD_drwConstType		__((	long			*msg,
				const struct GRid	*constId,
				VD_drwExecData		*xData,
				GRname			constType ));

extern long
VD_drwCstConstVisEdges	__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				VD_drwGraphicGroup	*outp,
				int			processType ));

extern long
VD_drwCstConstMemEdges	__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				VD_tktxt		member,
				VD_drwGraphicGroup	*outp,
				int			processType ));

extern long
VD_drwCstConstCenterLine __((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				VD_drwGraphicGroup	*outp,
				int			processType ));

extern long
VD_drwCstConstMember	__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				const char		*member,
				VD_drwGraphicGroup	*outp ));

extern long
VD_drwCstConstVisual	__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				VD_drwGraphicGroup	*outp ));

extern long
VD_drwCstPartProj	__((	long			*msg,
				VD_drwInputData		*inp,
				VD_drwExecData		*xData,
				VD_drwGraphicGroup	*outp ));

extern long
VD_findProfileX		__((	long			*msg,
				const VD_drwInputData	*inp,
				const VD_drwExecData	*xData,
				int			*profileDir,
				char			profileDirASCII[3] ));

extern long
VD_drwGetFacesOfPart	__((	long			*msg,
				struct GRid		*partId,
				struct GRmd_env		*partEnv,
				int			*countOfFaces,
				struct GRid		**listOfFaces ));

extern long
VD_drwFindPartFacesNotOrthoToViewVect
			__((	long			*msg,
				IGRvector		viewVector,
				int			countOfFaces,
				struct GRid		listOfFaces[],
				struct GRmd_env		*envOfFaces,
				int			*count,
				struct GRid		**list ));

extern long
VD_drwIsPtHiddenBySf	__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				IGRpoint		point,
				IGRvector		viewVector,
				int			*hidden ));

extern long
VD_drwSfToWireFrame	__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				struct GRvg_construct	*cst,
				int			*wfCount,
				struct GRid		**wfList ));

extern long
VD_drwIsEdgeHiddenByFaces
			__((	long			*msg,
				struct GRid		*edgeId,
				struct GRmd_env		*edgeEnv,
				int			faceEdge,
				IGRvector		viewVector,
				struct GRmd_env		*fcEnv,
				int			countOfFaces,
				struct GRid		listOfFaces[],
				int			*hidden ));

extern long
VD_drwProjectWireframeWithHiddenParts
			__((	long			*msg,
				struct GRid		*wfId,
				struct GRmd_env 	*wfEnv,
				int			nbSolSurf,
				struct GRobj_env	*solSurfObj,
				struct GRvg_construct	*cst,
				struct IGRdisplay	*dspVis,
				struct IGRdisplay	*dspHid,
				struct IGRplane 	*drwPlane,
				IGRvector		viewVector,
				struct GRid		*pjCv,
				OMuword 		*pjClassid ));

extern long
VD_drwProjectSolidWithHiddenLines
			__((	long			*msg,
				struct GRid		*solId,
				struct GRmd_env 	*solEnv,
				int			elmCount,
				struct GRobj_env	elmList[],
				IGRvector		viewVector,
				struct IGRplane 	*drwPlane,
				struct IGRdisplay	*dspHid,
				struct IGRdisplay	*dspVis,
				struct GRvg_construct	*cst,
				int			*count,
				struct GRid		*list[] ));

extern long
VD_drwProjectSurfaceWithHiddenLines
			__((	long			*msg,
				struct GRid		*sfId,
				struct GRmd_env 	*sfEnv,
				int			elmCount,
				struct GRobj_env	elmList[],
				IGRvector		viewVector,
				struct IGRplane 	*drwPlane,
				struct IGRdisplay	*dspHid,
				struct IGRdisplay	*dspVis,
				struct GRvg_construct	*cst,
				int			*count,
				struct GRid		*list[] ));

extern long
VD_drwProjectCurveWithHiddenParts
			__((	long			*msg,
				struct GRid		*cvId,
				struct GRmd_env 	*cvEnv,
				int			nb_part,
				double			*part_pt_s,
				double			*part_pt_e,
				double			*part_pm_s,
				double			*part_pm_e,
				struct GRvg_construct	*cst,
				struct IGRdisplay	*dspVis,
				struct IGRdisplay	*dspHid,
				struct IGRplane 	*drwPlane,
				IGRvector		viewVector,
				struct GRid		*cvHid,
				OMuword 		*cvClassid ));

extern long
VD_drwRmCoveredCurves	__((	long			*msg,
				unsigned char		hiddenStyle,
				unsigned char		visibleStyle,
				int			inCvCount,
				struct GRid		inCvList[],
				struct GRmd_env		*cvEnv,
				int			*outCvCount,
				struct GRid		**outCvList ));

extern long
VD_drwMakeSfContourCompCurve
			__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				struct GRmd_env		*compCvEnv,
				struct GRid		*compCvId ));

extern long
VD_drwIsCurveParallelToVwPlane
			__((	long			*msg,
				struct GRid		*curveId,
				struct GRmd_env 	*curveEnv,
				struct IGRplane 	*viewPlane,
				int			*parallel ));

extern long
VD_drwRmEqualPoints	__((	long			*msg,
				int			inElmCount,
				struct GRid		inElmList[],
				struct GRmd_env		*elmEnv,
				int			*outElmCount,
				struct GRid		**outElmList ));

extern long
VD_drwExecConfig	__((	long			*msg,
				const struct GRid	*elmId,
				const struct GRmd_env	*elmEnv,
				const struct IGRplane	*drwPlane,
				const struct IGRplane	*viewPlane,
				const IGRvector		viewVect,
				const struct GRmd_env	*drwEnv,
				const struct IGRlbsys	*drwLbsys,
				int			selCount,
				const struct GRid	selList[],
				const char		*filename,
				const char		*set_name,
				void			*appData,
				const char              *elm_type,
				VD_drwOutputData	**output ));

extern int
VD_drwKeyword		__(( 	const char		*keyword,
				FILE			*logfile,
				VD_drwTOKEN		*token ));

extern VD_drwArgLst
*VD_drwAddArg		__((	long			*msg,
				const VD_execRes	*arg,
				VD_drwArgLst		*arglist ));

extern void
VD_drwFreeArglist	__((	VD_drwArgLst		*arglist ));

extern char *
VD_drwGetInputFileName 	__(( ));

extern void
VD_drwInitStackOfInputFiles
			__((	VD_drwInputFiles	*inputs ));

extern void
VD_drwCloseInputFiles	__((	VD_drwInputFiles	*inputs ));

extern int
VD_drwPopInputFile	__((	int			verbose,
				VD_drwInputFiles	*inputs ));

extern int
VD_drwPushInputFile	__((	const char		*infile,
				int			verbose,
				VD_drwInputFiles	*inputs ));
extern FILE *
VD_drwGetLogFile	__(( 					));

extern VD_directionType
VD_getDirType		__((	IGRvector		dirVector ));

extern long
VD_findDirOfCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRvector		direction,
				int			*noDir ));

extern long
VD_findDirOfSetOfCurvesInXYPlane
			__((	long			*msg,
				int			cvCount,
				struct IGRbsp_curve	*cvGeoms[],
				IGRvector		setDir,
				int			*noDir ));

extern long
VD_findXMostCurve	__((	long			*msg,
				VD_drwTxLoc		loc,
				int			cvCount,
				struct IGRbsp_curve	*cvGeoms[],
				int			*index ));

extern long
VD_findCenterOfSetOfCurvesInXYPlane
			__((	long			*msg,
				int			cvCount,
				struct IGRbsp_curve	*cvGeoms[],
				IGRpoint		center ));

extern long
VD_findBoxOfCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRvector		direction,
				IGRpoint		bx[4] ));

extern void
VD_getJustPntsOfBlk	__((	IGRpoint		block[4],
				IGRvector		direction,
				VD_blkJustPnts		*justPnts ));

extern long
VD_findEndPtsCvInXYPlane
			__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				VD_directionType	cvDir,
				IGRpoint		endPt1,
				IGRpoint		endPt2,
				IGRvector		endTn1,
				IGRvector		endTn2,
				int			*swapped ));

extern long
VD_findMidPtCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRpoint		midPt,
				IGRvector		midTn ));

extern long
VD_drwGetCardinalPoint	__((	long			*msg,
				struct GRid		*bmId,
				struct GRmd_env 	*bmEnv,
				double			pm,
				IGRpoint		cardPnt ));

extern long
VD_drwGetOffsetedAxisAlongXdirection
			__((	long			*msg,
				struct GRid		*bmId,
				struct GRmd_env 	*bmEnv,
				struct GRvg_construct	*cst,
				struct GRid		*offAxis ));

extern long
VD_findTheMostInteriorPointToACurve
			__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRpoint		point ));

extern long
VD_findDirectionToGoOutsideCurve
			__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRpoint		ptOnCv,
				IGRvector		direction ));

extern void
VD_drwUpdateDatabase	__((	const VD_drwExecData	*xData,
				const char		*statement ));

extern int
VD_drwAddFunctions 	__((	int			count,
				char			*names[],
				VD_drwUsrTokType	usages[],
				VD_drwAction		addresses[] ));

extern void
VD_drwRmFunctions	__((	void ));

extern void
VD_drwInitParser 	__(( 	VD_drwExecData 		*xData,
				VD_drwInputData		*inp,
				VD_drwMacInfo		**macInfo,
    				int		   	*elmProcessed,
				int			*Xflag	));

extern void
VD_drwEndParser 	__(( 	VD_drwExecData 		*xData,
				VD_drwInputData		*inp,
				VD_drwMacInfo		**macInfo,
    				int		   	elmProcessed    ));

extern int
VD_drwProcessType 	__(( 	VD_drwExecData 		*xData,
				VD_drwInputData		*inp,
				VD_drwMacInfo		**macInfo,
    				int		   	*elmProcessed,
				int			Xflag	));
extern int
VD_drwProcessGraType 	__(( 	VD_drwExecData 		*xData,
				VD_drwInputData		*inp,
				VD_drwMacInfo		**macInfo,
    				int		   	*elmProcessed,
				int			Xflag	));
	/* WATCH OUT - cannot use X as variable name
	 *  it is defined in $GNUC/include/revieweledef.h
 	 */

extern void
VD_drwPrintParserFlags	__((	VD_drwExecData		*xData,
				VD_drwMacInfo		**macInfo,
    				int		   	elmProcessed,
				int			Xflag	));
extern void
VD_drwPrintParserLocFlags	__((	VD_drwExecData	*xData,
				VD_drwInputData		*inp	));

extern void
VD_drwGetMacroType	__(( 	VD_drwInputData		*inp,
				VD_drwExecData		*xData 	));

extern void
VD_drwGetGRhdrType 	__(( 	VD_drwInputData		*inp,
				VD_drwExecData		*xData 	));

extern void
VD_drwGetConstType 	__(( 	VD_drwInputData		*inp,
				VD_drwExecData		*xData 	));

extern void
VD_drwGetMacroGraType 	__(( 	VD_drwInputData		*inp,
				VD_drwExecData		*xData 	));

extern void
VD_drwGetGRhdrGraType 	__(( 	VD_drwInputData		*inp,
				VD_drwExecData		*xData 	));

extern void
VD_drwNoGraType 	__(( 	VD_drwInputData		*inp,
				VD_drwExecData		*xData 	));

extern int
VD_drwGetGRhdrInfo 	__((	struct GRid  		*elmId,
                        	char    		*name,
                        	int     		isMacroName	));
extern int
VD_drwGetACcpxInfo 	__((	struct GRid  		*elmId,
                        	char    		*name,
                        	int     		isMacroName	));

extern int
VD_drwGetSectInfo 	__((	struct GRid  		*elmId,
                        	char    		*name,
                        	int     		isMacroName	));



#ifndef v_drwapi_include
#	include "v_drwapi.h"
#endif

DECLARE_FUNCTION( VD, dummy	)
DECLARE_FUNCTION( VD, query_database	)
DECLARE_FUNCTION( VD, size_of_array	)
DECLARE_FUNCTION( VD, string_length	)
DECLARE_FUNCTION( VD, catenate_strings	)
DECLARE_FUNCTION( VD, dup_string	)
DECLARE_FUNCTION( VD, word_count	)
DECLARE_FUNCTION( VD, get_word		)
DECLARE_FUNCTION( VD, sub_string	)
DECLARE_FUNCTION( VD, match_regexp	)
DECLARE_FUNCTION( VD, substitute_string	)
DECLARE_FUNCTION( VD, format_number	)
DECLARE_FUNCTION( VD, time		)
DECLARE_FUNCTION( VD, basename		)
DECLARE_FUNCTION( VD, text_member       )
DECLARE_FUNCTION( VD, text_members      )
DECLARE_FUNCTION( VD, get_text_font     )
DECLARE_FUNCTION( VD, get_text_justification )
DECLARE_FUNCTION( VD, get_text_width    )
DECLARE_FUNCTION( VD, get_text_height   )
DECLARE_FUNCTION( VD, get_text_num_char )
DECLARE_FUNCTION( VD, attribute		)
DECLARE_FUNCTION( VD, view_direction	)
DECLARE_FUNCTION( VD, is_object_hidden	)
DECLARE_FUNCTION( VD, is_element_clipped	)
DECLARE_FUNCTION( VD, drawing_scale	)
DECLARE_FUNCTION( VD, const_type	)
DECLARE_FUNCTION( VD, get_input		)
DECLARE_FUNCTION( VD, get_member	)
DECLARE_FUNCTION( VD, get_owner		)
DECLARE_FUNCTION( VD, project_curve	)
DECLARE_FUNCTION( VD, intersect_curve_with_view	)
DECLARE_FUNCTION( VD, nearest_end_point	)
DECLARE_FUNCTION( VD, profile_direction )
DECLARE_FUNCTION( VD, plate_direction	)
DECLARE_FUNCTION( VD, is_plate_hidden	)
DECLARE_FUNCTION( VD, is_beam_hidden	)
DECLARE_FUNCTION( VD, is_mark_hidden    )
DECLARE_FUNCTION( VD, parallel_plates	)
DECLARE_FUNCTION( VD, is_marking_hidden	)
DECLARE_FUNCTION( VD, exec_ppl_func	)
DECLARE_FUNCTION( VD, exec_expression	)
DECLARE_FUNCTION( VD, dyn_select	)
DECLARE_FUNCTION( VD, get_objid		)
DECLARE_FUNCTION( VD, get_osnum		)
DECLARE_FUNCTION( VD, get_macro		)
DECLARE_FUNCTION( VD, get_curfile	)
DECLARE_FUNCTION( VD, get_objfile	)
DECLARE_FUNCTION( VD, get_dyntable	)
DECLARE_FUNCTION( VD, get_upper_text 	)
DECLARE_FUNCTION( VD, get_lower_text    )
DECLARE_FUNCTION( VD, int_holes_to_delete )
DECLARE_FUNCTION( VD, declivity         )
DECLARE_FUNCTION( VD, set_object_trans  )

DECLARE_OUTPUT( VD, intersection	)
DECLARE_OUTPUT( VD, weldline		)
DECLARE_OUTPUT( VD, profile		)
DECLARE_OUTPUT( VD, projection		)
DECLARE_OUTPUT( VD, axis		)
DECLARE_OUTPUT( VD, axis_A		)
DECLARE_OUTPUT( VD, axis_B		)
DECLARE_OUTPUT( VD, contour		)
DECLARE_OUTPUT( VD, edge		)
DECLARE_OUTPUT( VD, volume_cut		)
DECLARE_OUTPUT( VD, volume_mem		)
DECLARE_OUTPUT( VD, symbology		)
DECLARE_OUTPUT( VD, placemacro		)

DECLARE_OUTPUT( VD, cog			)
DECLARE_OUTPUT( VD, edges_A		)
DECLARE_OUTPUT( VD, edges_B		)
DECLARE_OUTPUT( VD, edges_C		)
DECLARE_OUTPUT( VD, env_edges_A		)
DECLARE_OUTPUT( VD, env_edges_B		)
DECLARE_OUTPUT( VD, env_edges_C		)
DECLARE_OUTPUT( VD, member_A		)
DECLARE_OUTPUT( VD, member_B		)
DECLARE_OUTPUT( VD, member_C		)
DECLARE_OUTPUT( VD, centerline		)
DECLARE_OUTPUT( VD, centerline_A	)
DECLARE_OUTPUT( VD, centerline_B	)

DECLARE_ISOFTYPE( VD, equipment		)
DECLARE_ISOFTYPE( VD, compartment	)
DECLARE_ISOFTYPE( VD, struct_surf	)
DECLARE_ISOFTYPE( VD, split_surf	)
DECLARE_ISOFTYPE( VD, bound_surf	)
DECLARE_ISOFTYPE( VD, split_volume	)
DECLARE_ISOFTYPE( VD, limit_volume	)
DECLARE_ISOFTYPE( VD, profile_volume	)
DECLARE_ISOFTYPE( VD, section		)
DECLARE_ISOFTYPE( VD, inf_plane		)
DECLARE_ISOFTYPE( VD, plane_system	)
DECLARE_ISOFTYPE( VD, perpendicular	)
DECLARE_ISOFTYPE( VD, all        	)
DECLARE_ISOFTYPE( VD, macro        	)
DECLARE_ISOFTYPE( VD, cell		)
DECLARE_ISOFTYPE( VD, sym		)
DECLARE_ISOFTYPE( VD, const		)
DECLARE_ISOFTYPE( VD, cable             )
DECLARE_ISOFTYPE( VD, terminal          )
DECLARE_ISOFTYPE( VD, guide             )
DECLARE_ISOFTYPE( VD, connect_comp      )
DECLARE_ISOFTYPE( VD, back_shell        )
DECLARE_ISOFTYPE( VD, stage        	)
DECLARE_ISOFTYPE( VD, Macro        	)

/*
 * Declare I/STRUCT external functions
 */

DECLARE_ISOFTYPE( VD, beam		)
DECLARE_ISOFTYPE( VD, stiffener		)
DECLARE_ISOFTYPE( VD, plate		)
DECLARE_ISOFTYPE( VD, joint		)
DECLARE_ISOFTYPE( VD, structure         )

/*
 * Declare I/LOFT external functions
 */

DECLARE_ISOFTYPE( VD, unwrap		)
DECLARE_ISOFTYPE( VD, marking		)
DECLARE_ISOFTYPE( VD, roll		)
DECLARE_ISOFTYPE( VD, butt		)
DECLARE_ISOFTYPE( VD, seam		)
DECLARE_ISOFTYPE( VD, water		)
DECLARE_ISOFTYPE( VD, trace		)
DECLARE_ISOFTYPE( VD, control		)
DECLARE_ISOFTYPE( VD, stock		)
DECLARE_ISOFTYPE( VD, min_rec		)
DECLARE_OUTPUT  ( VD, unwrap_contour	)
DECLARE_OUTPUT  ( VD, map		)
DECLARE_OUTPUT  ( VD, mapsource		)
DECLARE_OUTPUT  ( VD, stocklines	)
DECLARE_OUTPUT  ( VD, delete_cut        )
DECLARE_FUNCTION( VD, is_ns_fs_mark     )
DECLARE_FUNCTION( VD, get_knuckle_angle )
DECLARE_OUTPUT  ( VD, extend_contour    )
DECLARE_OUTPUT  ( VD, dimension_lines   )
DECLARE_FUNCTION( VD, get_curve_length  )
DECLARE_FUNCTION( VD, is_partial_bevel  )

/* 
 *unit-processing 
*/
DECLARE_ISOFTYPE( VD, unit_process	)
DECLARE_FUNCTION( VD, in_transp_level_A )
DECLARE_FUNCTION( VD, in_transp_level_B )
DECLARE_FUNCTION( VD, in_transp_level_C )
DECLARE_FUNCTION( VD, in_transp_level_D )
DECLARE_FUNCTION( VD, in_transp_level_E )
/*
 * Declare I/ROUTE external functions.
 */
DECLARE_ISOFTYPE( VD, pipe		)
DECLARE_ISOFTYPE( VD, hvac		)
DECLARE_ISOFTYPE( VD, rway		)
DECLARE_ISOFTYPE( VD, nozzle		)
DECLARE_ISOFTYPE( VD, r_equipment	)



extern long
VD_drwUndefinedAction		__(( void ));

extern VD_drwOutputData
*VD_drwNewOutputData		__(( VD_drwOutputData	**head ));

extern void
VD_drwFreeOutputData		__(( VD_drwOutputData	**head ));

#endif /* v_drwproto_include */
