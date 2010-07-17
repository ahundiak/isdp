/* $Id: vsdrwproto.h,v 1.5 2001/03/08 22:54:34 ramarao Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        include/prototypes/ vsdrwproto.h
 *
 * Description: Prototype declarations.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsdrwproto.h,v $
 *      Revision 1.5  2001/03/08 22:54:34  ramarao
 *      Added "declivity" Keyword in VISUAL and STRUDEL.
 *
 *      Revision 1.4  2001/02/15 23:35:02  ramarao
 *      Implemented CR# 4038.
 *
 *      Revision 1.3  2001/01/31 17:47:50  ramarao
 *      Implemented CR# 4564.
 *
 *      Revision 1.2  2001/01/16 22:22:51  ramarao
 *      *** empty log message ***
 *
 * Revision 1.2  2000/10/14  18:48:54  pinnacle
 * Replaced: struct/include/prototypes/vsdrwproto.h for:  by rchennup for Service Pack
 *
 * Revision 1.1  2000/07/19  16:01:26  pinnacle
 * Created: struct/include/prototypes/vsdrwproto.h by rchennup for Service Pack
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.5  1997/12/26  10:57:06  pinnacle
 * Replaced: include/prototypes/vsdrwproto.h for:  by rchennup for struct
 *
 * Revision 1.4  1997/11/19  10:10:16  pinnacle
 * Replaced: include/prototypes/vsdrwproto.h for:  by rchennup for struct
 *
 * Revision 1.3  1997/10/29  15:40:42  pinnacle
 * Replaced: include/prototypes/vsdrwproto.h for:  by rchennup for struct
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/29/97   Rama Rao     Header Creation & Add place macro
 *************************************************************************/

#ifndef vsdrwproto_include
#	define vsdrwproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsdrw_include
#	include "vsdrw.h"
#endif
#ifndef fontdef_include
#	include "fontdef.h"
#endif
#ifndef font_include
#	include "font.h"
#endif

extern long
VSdrwOutputGraphic	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				const char		*output,
				int			text,
				const VSdrwArgLst	*arglist,
				VSdrwOutputData		**outdata )) ;

extern int
VSdrwAddMacInfo		__((	VSdrwMacInfo	**info,
				const char	*macDefName )) ;

extern int
VSdrwAddMacDrwName	__((	VSdrwMacInfo	*info,
				const char	*drwMacName )) ;

extern int
VSdrwAddAttrToMacInfo	__((	VSdrwMacInfo	*info,
				const char	*attrName )) ;

extern int
VSdrwGetExtractionInfo	__((	long		*msg,
				VSdrwMacInfo	**xinfo )) ;

extern int
VSdrwCstSymbol		__((	long			*msg,
				const VSdrwInputData	*inp,
				VSdrwExecData		*xData,
				const VSdrwGraphicGroup	*outpgr,
				VSdrwGraphicGroup	*outptx )) ;

extern int
VSformatNumber		__((	const char		*format,
				double			value,
				char			output[],
				int			size,
				FILE			*errFile )) ;

extern int
VSdrwParse		__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwMacInfo		**macInfo,
				VSdrwOutputData		**output )) ;

extern int
VSyydrwLex		__((	FILE			*errFile,
				VSdrwInputFiles		*inputFiles )) ;

extern int
VSdrwKeyword		__((	const char		*keyword,
				FILE			*logfile,
				VSdrwTOKEN		*token )) ;

extern int
VScheckStyle		__((	int			style )) ;

extern int
VScheckWeight		__((	int			weight )) ;

extern int
VScheckColor		__((	const VSexecRes		*color,
				int			*colorNumber )) ;

extern int
VScheckLayer		__((	int			layer )) ;

extern int
VSgetTxOffType		__((	int			location,
				int			*offsetType,
				int			*keyword )) ;

extern int
VSgetTxPosType		__((	int			position,
				int			*posType,
				int			*keyword )) ;

extern int
VScheckJustification	__((	int			justification )) ;

extern int
VSdrwJustToTokNum	__((	int			justification )) ;

extern int
VSdrwIsElementClipped	__((	long			*msg,
				const VSdrwInputData	*inp,
				const VSdrwExecData	*xData,
				int			*isClipped )) ;

extern int
VSdrwIsPlateClipped	__((	long			*msg,
				const struct GRid	*plateId,
				const struct GRmd_env	*plateEnv,
				const struct IGRplane	*clippingPlane,
				int			*isClipped )) ;

extern int
VSdrwIsBeamClipped	__((	long			*msg,
				const struct GRid	*beamId,
				const struct GRmd_env	*beamEnv,
				const struct IGRplane	*clippingPlane,
				int			*isClipped )) ;

extern int
VSdrwIsJointClipped	__((	long			*msg,
				const struct GRid	*jointId,
				const struct GRmd_env	*jointEnv,
				const struct IGRplane	*clippingPlane,
				int			*isClipped )) ;

extern int
VSdrwIsPlateHidden	__((	long			*msg,
				const VSdrwInputData	*inp,
				const VSdrwExecData	*xData,
				int			*hidden )) ;

extern int
VSdrwIsBeamHidden	__((	long			*msg,
				const VSdrwInputData	*inp,
				const VSdrwExecData	*xData,
				int			*hidden )) ;

extern int
VSdrwArePlatesParallel	__((	long			*msg,
				const struct GRobj_env	*plate1,
				const struct GRobj_env	*plate2,
				int			*parallel )) ;

extern int
VSretrieveFont		__((	long			*msg,
				const char		*fontName,
				short			*fontPos )) ;

extern int
VSgetFontInfo		__((	long			*msg,
				short			virtFontNo,
				struct vfont_entry	*fontInfo )) ;

extern int
VSdrwExecFct		__((	long			*msg,
				const VSdrwInputData	*inp,
				VSdrwExecData		*xData,
				const char		*function,
				const VSdrwFunction	address,
				const VSdrwArgLst	*arglist,
				VSexecRes		*result )) ;

extern int
VSdrwAnchorCurve	__((	long			*msg,
				const VSdrwInputData	*inp,
				VSdrwExecData		*xData,
				VSexecRes		*curve )) ;

extern int
VSdrwAnchorPoint	__((	long			*msg,
				const VSdrwInputData	*inp,
				VSdrwExecData		*xData,
				const char		*member,
				VSdrwAnchorType		whichPoint )) ;

extern int
VSdrwAddGarbage		__((	long			*msg,
				VSdrwExecData		*xData,
				const struct GRobj_env	*temporary )) ;

extern int
VSdrwIsNewExtraction	__((	void )) ;


extern void
VSdrwFreeExtractMacInfo	__((	VSdrwMacInfo		*info )) ;

extern void
VSsetDrwConfigInput	__((	FILE			*file,
				int			lineno )) ;

extern int
VSyydrwWrap		__((	int			verbose ,
				VSdrwInputFiles		*inputs )) ;

extern void
VSdrwResynchLex		__((	void )) ;

extern void
VSdrwLexUnput		__((	int			character )) ;

extern void
VSdrwTxInit		__((	VSdrwText		*t )) ; 

extern void
VSdrwTxFree		__((	VSdrwText		*t )) ;

extern void
VSdrwTxMOVE		__((	VSdrwText		*t,
				char			mvdir,
				double			mvvalue )) ;

extern void
VSdrwTxFSTART		__((	VSdrwText		*t,
				int			fieldno )) ;

extern void
VSdrwTxFEND		__((	VSdrwText		*t )) ;

extern void
VSdrwTxMVTOFLD		__((	VSdrwText		*t,
				VSdrwText		*text,
				short			fieldno,
				char			justification,
				struct GRdpb_text_symb	*txSymb,
				struct IGRdisplay	*display )) ;

extern void
VSdrwTxCHGFONT		__((	VSdrwText		*t,
				short			fontno )) ;

extern void
VSdrwTxINITSTRING	__((	VSdrwText		*t,
				const char		*string )) ;

extern void
VSdrwTxMERGE		__((	const VSdrwText		*toMerge1,
				const VSdrwText		*toMerge2,
				VSdrwText		*merged )) ;

extern void
VSgetFontMgr		__((	 struct GRid		*fontMgr )) ;

extern void
VSdrwPrintf		__((	const char		*format,
				... )) ;

extern void
VSdrwIndent		__((	void )) ;

extern void
VSdrwPrtItem		__((	int			tokType,
				int			valType,
				const void		*value )) ;

extern void
VSdrwVerbValue		__((	const char		*format,
				const VSexecRes		*value )) ;

extern void
VSdrwVerbArgLst		__((	const VSdrwArgLst	*arglist )) ;

extern void
VSdrwVerbFcnCall	__((	const char		*function,
				const VSdrwArgLst	*arglist )) ;

extern void
VSdrwVerbOutput		__((	const char		*output,
				const VSdrwArgLst	*arglist,
				int			hasSetup )) ;

extern void
VSdrwVerbVar		__((	int			flag,
				const char		*varName,
				const VSexecRes		*varValue )) ;

extern void
VSdrwVerbOp		__((	int			operation,
				const VSexecRes		*operand1,
				const VSexecRes		*operand2,
				const VSexecRes		*result )) ;

extern void
VSdrwVerbAnchor		__((	const char		*member,
				VSdrwAnchorType		whichPoint )) ;

extern void
VSdrwInitVarTable	__((	void )) ;

extern void
VSdrwGetVarVal		__((	const char		*varName,
				VSexecRes		*varValue )) ;

extern void
VSdrwSetVarVal		__((	const char		*varName,
				const VSexecRes		*varValue )) ;

extern VSexecRes
*VSdrwAryMalloc		__(( unsigned countOfElements )) ;

extern void
VSdrwFreeMemoryForArrays	__(( void )) ;

extern void
VSdrwGetAryVal		__((	const char		*n,
				const VSexecRes		*index,
				VSexecRes		*val )) ;

extern void
VSdrwCloseLogFile	__((	void )) ;

extern void
VSdrwElmNotProcessed	__((	FILE			*logFile,
				const VSdrwInputData	*inp )) ;

extern void
VSdrwCollectGarbage	__((	VSdrwExecData		*xData )) ;

extern void
VSdrwSetExtractionFlg	__((	int			new )) ;

extern const char
*VSdrwKwFromTokType	__((	int			tokType )) ;

extern const char
*VSdrwVerbViewType	__((	VSdrwViewType		vt )) ;

extern double
VSdrwDblVal		__((	const VSexecRes		*result )) ;

extern int
VSdrwIntVal		__((	const VSexecRes		*result )) ;

extern int
VSdrwBoolVal		__((	const VSexecRes		*result )) ;

extern char
*VSdrwStrVal		__((	const VSexecRes		*result,
				char			*string )) ;

extern FILE
*VSdrwOpenLogFile	__((	const char		*filename )) ;

extern long
VSdrwFindPointOfViewPlaneOnAxis
			__((	long			*msg,
				const struct GRid	*axisId,
				const struct GRmd_env 	*axisEnv,
				const struct IGRplane 	*viewPlane,
				IGRpoint		pt,
				double			*pm )) ;

extern long
VSdrwGetViewTypeFromBeam
			__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData )) ;

extern long
VSdrwGetViewTypeFromPlate
			__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData )) ;

extern long
VSdrwGetViewTypeFromJoint
			__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData )) ;

extern long
VSdrwGetViewTypeFromConst
			__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData )) ;

extern int
VSdrwConstType		__((	long			*msg,
				const struct GRid	*constId,
				VSdrwExecData		*xData,
				GRname			constType )) ;

extern long
VSdrwCstBeamAxis	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				char			*option,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwCstBeamProf	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwPlateBottomSide	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwPlateContour	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				char			*option,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwCstPlateVwIntersection
			__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwJoint		__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwCstConstMember	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				const char		*member,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSdrwCstPartProj	__((	long			*msg,
				VSdrwInputData		*inp,
				VSdrwExecData		*xData,
				VSdrwGraphicGroup	*outp )) ;

extern long
VSfindProfileX		__((	long			*msg,
				const VSdrwInputData	*inp,
				const VSdrwExecData	*xData,
				int			*profileDir,
				char			profileDirASCII[3] )) ;

extern long
VSfindPlateX		__((	long			*msg,
				const VSdrwInputData	*inp,
				const VSdrwExecData	*xData,
				int			*profileDir,
				char			profileDirASCII[3] )) ;

extern long
VSdrwGetFacesOfPart	__((	long			*msg,
				struct GRid		*partId,
				struct GRmd_env		*partEnv,
				int			*countOfFaces,
				struct GRid		**listOfFaces )) ;

extern long
VSdrwFindPartFacesNotOrthoToViewVect
			__((	long			*msg,
				IGRvector		viewVector,
				int			countOfFaces,
				struct GRid		listOfFaces[],
				struct GRmd_env		*envOfFaces,
				int			*count,
				struct GRid		**list )) ;

extern long
VSdrwIsPtHiddenBySf	__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				IGRpoint		point,
				IGRvector		viewVector,
				int			*hidden )) ;

extern long
VSdrwSfToWireFrame	__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				struct GRvg_construct	*cst,
				int			*wfCount,
				struct GRid		**wfList )) ;
extern long
VSdrwObjectToWireFrame	__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				struct GRvg_construct	*cst,
				int			*wfCount,
				struct GRid		**wfList )) ;

extern long
VSdrwIsEdgeHiddenByFaces
			__((	long			*msg,
				struct GRid		*edgeId,
				struct GRmd_env		*edgeEnv,
				int			faceEdge,
				IGRvector		viewVector,
				struct GRmd_env		*fcEnv,
				int			countOfFaces,
				struct GRid		listOfFaces[],
				int			*hidden )) ;

extern long
VSdrwProjectWireframeWithHiddenParts
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
				OMuword 		*pjClassid )) ;

extern long
VSdrwProjectSolidWithHiddenLines
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
				struct GRid		*list[] )) ;

extern long
VSdrwProjectSurfaceWithHiddenLines
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
				struct GRid		*list[] )) ;

extern long
VSdrwProjectCurveWithHiddenParts
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
				OMuword 		*cvClassid )) ;

extern long
VSdrwRmCoveredCurves	__((	long			*msg,
				unsigned char		hiddenStyle,
				unsigned char		visibleStyle,
				int			inCvCount,
				struct GRid		inCvList[],
				struct GRmd_env		*cvEnv,
				int			*outCvCount,
				struct GRid		**outCvList )) ;

extern long
VSdrwMakeSfContourCompCurve
			__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env		*surfaceEnv,
				struct GRmd_env		*compCvEnv,
				struct GRid		*compCvId )) ;

extern long
VSdrwIsPlateOrthogonalToPlate
			__((	long			*msg,
				struct GRid		*plId0,
				struct GRmd_env 	*plEnv0,
				struct GRid		*plId1,
				struct GRmd_env 	*plEnv1,
				int			*orthogonal )) ;

extern long
VSdrwIsPlateHiddenByPlate
			__((	long			*msg,
				struct GRid		*plId0,
				struct GRmd_env 	*plEnv0,
				struct GRid		*plId1,
				struct GRmd_env 	*plEnv1,
				IGRvector		viewVector,
				int			*hidden )) ;

extern long
VSdrwIsCurveParallelToVwPlane
			__((	long			*msg,
				struct GRid		*curveId,
				struct GRmd_env 	*curveEnv,
				struct IGRplane 	*viewPlane,
				int			*parallel )) ;

extern long
VSdrwRmEqualPoints	__((	long			*msg,
				int			inElmCount,
				struct GRid		inElmList[],
				struct GRmd_env		*elmEnv,
				int			*outElmCount,
				struct GRid		**outElmList )) ;

extern long
VSdrwExecConfig		__((	long			*msg,
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
				void			*appData,
				VSdrwOutputData		**output )) ;

extern VSdrwArgLst
*VSdrwAddArg		__((	long			*msg,
				const VSexecRes		*arg,
				VSdrwArgLst		*arglist )) ;

extern void
VSdrwFreeArglist	__((	VSdrwArgLst		*arglist )) ;

extern void
VSdrwInitStackOfInputFiles
			__((	VSdrwInputFiles		*inputs )) ;

extern void
VSdrwCloseInputFiles	__((	VSdrwInputFiles		*inputs )) ;

extern int
VSdrwPopInputFile	__((	int			verbose,
				VSdrwInputFiles		*inputs )) ;

extern int
VSdrwPushInputFile	__((	const char		*infile,
				int			verbose,
				VSdrwInputFiles		*inputs )) ;

extern VSdirectionType
VSgetDirType		__((	IGRvector		dirVector )) ;

extern long
VSfindDirOfCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRvector		direction,
				int			*noDir )) ;

extern long
VSfindDirOfSetOfCurvesInXYPlane
			__((	long			*msg,
				int			cvCount,
				struct IGRbsp_curve	*cvGeoms[],
				IGRvector		setDir,
				int			*noDir )) ;

extern long
VSfindXMostCurve	__((	long			*msg,
				VSdrwTxLoc		loc,
				int			cvCount,
				struct IGRbsp_curve	*cvGeoms[],
				int			*index )) ;

extern long
VSfindCenterOfSetOfCurvesInXYPlane
			__((	long			*msg,
				int			cvCount,
				struct IGRbsp_curve	*cvGeoms[],
				IGRpoint		center )) ;

extern long
VSfindBoxOfCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRvector		direction,
				IGRpoint		bx[4] )) ;

extern void
VSgetJustPntsOfBlk	__((	IGRpoint		block[4],
				IGRvector		direction,
				VSblkJustPnts		*justPnts )) ;

extern long
VSfindEndPtsCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				VSdirectionType		cvDir,
				IGRpoint		endPt1,
				IGRpoint		endPt2,
				IGRvector		endTn1,
				IGRvector		endTn2,
				int			*swapped )) ;

extern long
VSfindMidPtCvInXYPlane	__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRpoint		midPt,
				IGRvector		midTn )) ;

extern long
VSdrwGetCardinalPoint	__((	long			*msg,
				struct GRid		*bmId,
				struct GRmd_env 	*bmEnv,
				double			pm,
				IGRpoint		cardPnt )) ;

extern long
VSdrwGetOffsetedAxisAlongXdirection
			__((	long			*msg,
				struct GRid		*bmId,
				struct GRmd_env 	*bmEnv,
				struct GRvg_construct	*cst,
				struct GRid		*offAxis )) ;

extern long
VSfindTheMostInteriorPointToACurve
			__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRpoint		point )) ;

extern long
VSfindDirectionToGoOutsideCurve
			__((	long			*msg,
				struct IGRbsp_curve	*cvGeom,
				IGRpoint		ptOnCv,
				IGRvector		direction )) ;

extern void
VSdrwUpdateDatabase	__((	const VSdrwExecData	*xData,
				const char		*statement )) ;

extern int
VSdrwAddFunctions 	__((	int		count,
				char		*names[],
				VSdrwUsrTokType	usages[],
				VSdrwAction	addresses[] )) ;

extern void
VSdrwRmFunctions	__((	void )) ;

#ifndef vsdrwapi_include
#	include "vsdrwapi.h"
#endif

DECLARE_FUNCTION( VS, basename			)
DECLARE_FUNCTION( VS, attribute			)
DECLARE_FUNCTION( VS, text_member		)
DECLARE_FUNCTION( VS, text_members		)
DECLARE_FUNCTION( VS, profile_direction		)
DECLARE_FUNCTION( VS, web_orientation		)
DECLARE_FUNCTION( VS, flange_orientation	)
DECLARE_FUNCTION( VS, beam_orientation 		)
DECLARE_FUNCTION( VS, plate_direction		)
DECLARE_FUNCTION( VS, where_is			)
DECLARE_FUNCTION( VS, view_direction		)
DECLARE_FUNCTION( VS, is_plate_hidden		)
DECLARE_FUNCTION( VS, is_beam_hidden		)
DECLARE_FUNCTION( VS, is_mark_hidden            )
DECLARE_FUNCTION( VS, first_welded_element	)
DECLARE_FUNCTION( VS, second_welded_element	)
DECLARE_FUNCTION( VS, is_a_beam			)
DECLARE_FUNCTION( VS, is_a_stiffener		)
DECLARE_FUNCTION( VS, is_a_plate		)
DECLARE_FUNCTION( VS, parallel_plates		)
DECLARE_FUNCTION( VS, is_element_clipped	)
DECLARE_FUNCTION( VS, drawing_scale		)
DECLARE_FUNCTION( VS, const_type		)
DECLARE_FUNCTION( VS, get_input			)
DECLARE_FUNCTION( VS, get_member		)
DECLARE_FUNCTION( VS, get_owner			)
DECLARE_FUNCTION( VS, project_curve		)
DECLARE_FUNCTION( VS, intersect_curve_with_view	)
DECLARE_FUNCTION( VS, nearest_end_point		)
DECLARE_FUNCTION( VS, string_length		)
DECLARE_FUNCTION( VS, catenate_strings		)
DECLARE_FUNCTION( VS, dup_string		)
DECLARE_FUNCTION( VS, word_count		)
DECLARE_FUNCTION( VS, get_word			)
DECLARE_FUNCTION( VS, sub_string		)
DECLARE_FUNCTION( VS, match_regexp		)
DECLARE_FUNCTION( VS, substitute_string		)
DECLARE_FUNCTION( VS, format_number		)
DECLARE_FUNCTION( VS, time			)
DECLARE_FUNCTION( VS, query_database		)
DECLARE_FUNCTION( VS, size_of_array		)
DECLARE_FUNCTION( VS, exec_ppl_func		)
DECLARE_FUNCTION( VS, is_elem_connected		)
DECLARE_FUNCTION( VS, is_same_object		)
DECLARE_FUNCTION( VS, get_element  		)
DECLARE_FUNCTION( VS, joint_geom		)
DECLARE_FUNCTION( VS, get_conn_geom		)
DECLARE_FUNCTION( VS, int_holes_to_delete	)
DECLARE_FUNCTION( VS, declivity                 )

DECLARE_OUTPUT( VS, intersection	)
DECLARE_OUTPUT( VS, profile		)
DECLARE_OUTPUT( VS, projection		)
DECLARE_OUTPUT( VS, axis		)
DECLARE_OUTPUT( VS, member		)
DECLARE_OUTPUT( VS, contour		)
DECLARE_OUTPUT( VS, edge		)
DECLARE_OUTPUT( VS, weldline		)
DECLARE_OUTPUT( VS, placemacro		)
DECLARE_OUTPUT( VS, set_joint_geom	)

DECLARE_ISOFTYPE( VS, beam		)
DECLARE_ISOFTYPE( VS, stiffener		)
DECLARE_ISOFTYPE( VS, plate		)
DECLARE_ISOFTYPE( VS, joint		)
DECLARE_ISOFTYPE( VS, const		)
DECLARE_ISOFTYPE( VS, userBlock		)

extern long
VSdrwUndefinedAction		__(( void )) ;

extern VSdrwOutputData
*VSdrwNewOutputData		__(( VSdrwOutputData	**head )) ;

extern void
VSdrwFreeOutputData		__(( VSdrwOutputData	**head )) ;

#endif /* vsdrwproto_include */

