/* $Id: VSpsi.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        include/VSpsi.h
 *
 * Description: For plane - surface intersections
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSpsi.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1998/03/01  14:55:32  pinnacle
 * TR179701791
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/01/98  ah      Created, TR179701791 - Problems with Shell expansion
 *
 ***************************************************************************/

#ifndef VSpsi_include
#define VSpsi_include 

#define VS_PSI_CRV_MAX 10

typedef struct {

  TGRmd_env md_env;

  TGRvg_construct  cst;
  TGRdisplay       dis;
  IGRstat          msg;

  struct {
    TGRobj_env obj;
    IGRdouble point [3];
    IGRdouble normal[3];
    TGRplane  geom;

    IGRdouble scale;
    IGRdouble poles[12],u_knots[12],v_knots[12];

    TGRbsp_surface bsp;
  
    IGRboolean in_range;
  } plane;

  struct {
    IGRboolean world;
    GRrange    geom;
  } range;

  TGRobj_env srfObj;

  struct {
    IGRint     i;
    IGRint     cnt;
    TGRid     *ids;
    TGRobj_env obj;
    TGRbsp_curve *bsps[VS_PSI_CRV_MAX];
  } crv;

  FILE *file;

} VSpsiInfo;

IGRstat VSpsiInitInfo     (VSpsiInfo *info);
IGRstat VSpsiCreatePlane  (VSpsiInfo *info, IGRdouble x);
IGRstat VSpsiCreateLineStr(VSpsiInfo *info, IGRdouble *pts);
IGRstat VSpsiProcessCurve (VSpsiInfo *info);
 
IGRstat VSpsiExpandShell(
  TGRobj_env *srfObj,
  IGRdouble   xBeg,
  IGRdouble   xInc,
  IGRint      xCnt
);

#endif






