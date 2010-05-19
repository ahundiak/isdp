/* $Id: VDcvg2.h,v 1.2 2001/09/14 19:53:42 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsvg.h
 *
 * Description:	Scalable Vector Graphics
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcvg2.h,v $
 *      Revision 1.2  2001/09/14 19:53:42  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/09/14 13:47:40  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/10 15:31:54  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  2000/04/28  19:16:54  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:02:42  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/18  16:01:30  pinnacle
 * sms
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/18/00  ah      Creation
 * 01/09/01  ah      sp merge
 ***************************************************************************/
#ifndef VDcvg_include
#define VDcvg_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------
 * CVG Structures
 */
typedef struct 
{
  TVDxmlFileInfo xml;
  IGRdouble linearTol,arcTol; 
 
  // Handy to have global translate
  struct 
  {
    IGRdouble x,y,z;
  } trn;

} TVDcvgFileInfo;

/* ------------------------------------
 * Structures for applications
 */
typedef struct
{
  IGRint    flag;
  IGRchar   type;
  IGRdouble endx,endy;
  IGRdouble midx,midy;
  IGRdouble cenx,ceny;
  IGRdouble radius,bulge,inc_angle;
} TVDcvgVertex;

typedef struct 
{
  IGRint       flag;

  // For parametric curves
  IGRchar      type[32];
  IGRdouble    radius;
  IGRpoint     center;
  IGRpoint     major;
  IGRpoint     minor;
  
  IGRint       i;
  IGRint       maxVertex;
  IGRint       numVertexes;
  TVDcvgVertex *vertexes;
} TVDcvgCurve;

typedef struct 
{
  IGRdouble x,y,z;
  IGRint    flag;
} TVDcvgPoint;

typedef struct 
{
  IGRdouble x1,y1,z1;
  IGRdouble x2,y2,z2;
  
  IGRint  flag;
} TVDcvgRange;

typedef struct
{
  IGRchar value[256];
  
  IGRchar x1[32],y1[32];
  IGRchar x2[32],y2[32];
  
  IGRchar angle [32];
  IGRchar height[32],width[32];
  IGRchar font[32];
  IGRchar just[32];

  IGRint  flag;
  
} TVDcvgText;

// For controlling output
#define VDCVG_VERTEX_TYPE_MOVE_TO 'M'
#define VDCVG_VERTEX_TYPE_LINE_TO 'L'

/* ----------------------------------------------------
 * CVG Protos
 */
extern IGRstat VDcvgWritePathVertex   __((TVDcvgFileInfo *info, IGRchar cmd, IGRdouble *pt));

extern IGRstat VDcvgWritePathGeometry __((TVDcvgFileInfo *info, 
					  IGRint          nth, 
					  TGRbsp_curve   *bsp));

extern IGRstat VDcvgWritePathObject   __((TVDcvgFileInfo *info, 
					  IGRint          nth,
					  TGRobj_env     *pathOE));
#if 0
extern IGRstat VDcvgWritePathSym      __((TVDcvgFileInfo *info,
					  TVDgeomSym     *sym));
#endif
extern IGRstat VDcvgWriteTextObject   __((TVDcvgFileInfo *info, 
					  TGRobj_env     *textOE));

extern IGRstat VDcvgWriteObject       __((TVDcvgFileInfo *info, 
					  TGRobj_env     *objOE));

extern IGRstat VDcvgWritePathBeg      __((TVDcvgFileInfo *info));
extern IGRstat VDcvgWritePathEnd      __((TVDcvgFileInfo *info));

extern IGRstat VDcvgWritePoint2D      __((TVDcvgFileInfo *info, IGRdouble *pt));
extern IGRstat VDcvgWritePoint3D      __((TVDcvgFileInfo *info, IGRdouble *pt));

/* ----------------------------------------------------------
 * Geometry Stuff
 */
extern IGRstat VDcvgGetListOfPoints __((TGRbsp_curve *bsp, IGRint n, IGRdouble *pts));
extern IGRstat VDcvgArePtsLinear    __((IGRint n, IGRdouble *pts, IGRdouble tol));
extern IGRstat VDcvgArePtsArc       __((IGRint n, IGRdouble *pts, IGRdouble tol));


extern IGRstat VDcvgGetCrvInfo  __((TGRbsp_curve *bsp,            /* I - Curve geometry */
				    IGRint        flag,           /* I - 0=linear,1=arc */
				    IGRdouble     tol,            /* I - Tolerance      */
				    IGRint        numPts,         /* I - Number of points(max 50) */
				    IGRint        begKnotIndex,   /* I - Index of where to start  */
				    IGRint       *endKnotIndex)); /* O - Where it ended */

extern IGRstat VDcvgGetArcCenterRadius __((TGRbsp_curve *bsp, 
					   IGRpoint cen, 
					   IGRdouble *radius));

extern IGRstat VDcvgGet2DRotateAngle   __((IGRdouble mat[16], IGRdouble *angle));

typedef struct IGRestx TGRestx;

extern IGRstat VDcvgGetTextInfo  __((TGRobj_env *a_textOE, 
				     TGRid      *a_textID, 
				     IGRchar    *a_textBuf, 
				     IGRint      a_textLen,
				     TGRestx    *a_textAttr));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif








