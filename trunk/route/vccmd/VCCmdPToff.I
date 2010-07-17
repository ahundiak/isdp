
/* $Id: VCCmdPToff.I,v 1.2 2001/02/20 01:09:43 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPToff.I
 *
 * Description:
 *      Implementation file for place terminal command object
 *         (offset/orientation input)
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPToff.I,v $
 *  Revision 1.2  2001/02/20 01:09:43  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1998/12/22  17:02:14  pinnacle
# Replaced: vccmd/VCCmdPToff.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/26  20:11:34  pinnacle
# Replaced: vccmd/VCCmdPToff.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/07/14  22:52:58  pinnacle
# Replaced: vccmd/VCCmdPToff.I for:  by hverstee for cabling
#
# Revision 1.3  1997/05/07  14:18:00  pinnacle
# Replaced: vccmd/VCCmdPToff.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/03  18:13:34  pinnacle
# Replaced: vccmd/VCCmdPToff.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:17:02  pinnacle
# Created: vccmd/VCCmdPToff.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  4-98        KDD     Always use full matrix when creating new component.
 *  11-98       law     TR179801229 - Fix terminal rotate. 
 *  12-98       law     CR179802404 - terminal rotate is thru form. 
 *
 *************************************************************************/

class implementation VCCmdPT;

/*
#define MY_DEBUG
#define vdsDEBUG	1
*/

#include "VCCmdForm.h"
#include <math.h>
#include "VCdefine.h"
#include "VCmacros.h"
#include "VCproto.h"
#include "vc_param.h" /* CR179802404 */
#include "vrdbgmacros.h"
#include "VDmem.h"
#include "maidmx.h"

extern double     atof();

%safe
#include "VX_FIproto.h"
%endsafe

from	NDnode		import	NDgive_structure;
from	GRgencs		import	GRgetmatrix;
from	VRGeneric	import	VRGetMatrix;
from	ACncpx		import	ACgive_structure;
from	ACrg_collect	import	ACshow_data;



/**********************************************************/

method VCCmdPosition ( int * sts )
{
  IGRlong       		retmsg, status;
  IGRdouble			RefMatrix[16], InvRefMat[16], EventMat[16],
				Click_point[4]={0.0, 0.0, 0.0, 1.0},
				My_offset[4]={0.0, 0.0, 0.0, 1.0},
				Par_offset[4]={0.0, 0.0, 0.0, 1.0},
				One = {1.0}, Zero = {0.0},
				scale;

  IGRshort			I_four = 4, I_one= 1;
  int            		info, i;
  struct GRid    		ParId;
  struct ret_struct  		RefInfo;
  struct ret_struct  		ParamAttr;
  IGRint             		FootIndex = -1;
  IGRdouble rotcos, rotsin;


SetProc(VCCmdPT_VCCmdPosition ); Begin

  *sts = VC_RTC_ALLOK;

/* 4-98 KDD Always use full matrix
*
*  me->dValues[0] = me->event1.event.button.x;
*  me->dValues[1] = me->event1.event.button.y;
*  me->dValues[2] = me->event1.event.button.z;
*
*  me->nVal = 3;
*  me->nVCConn_type |= VC_TOFF_COORDS;
*/

__DBGpr_int("event1.response",me->event1.response);
  MAidmx (&retmsg, me->dValues);

  scale = One;
  if ( me->RefId.objid != NULL_OBJID) { 

     MAidmx (&retmsg, RefMatrix);

     ParamAttr.var.root_pm_st.value = One;

     if ( me->nVCConn_type & VC_TERM_CS ) { 
        __DBGpr_com("VC_TERM_CS");
	status= om$send( msg = message NDnode.NDgive_structure (&retmsg, 
					&RefInfo, &me->ModuleInfo),
                    targetid = me->RefId.objid,
                    targetos = me->RefId.osnum);

	if ( status & retmsg & 1) {
           for (i=0; i<16; i++) RefMatrix[i] = RefInfo.var.ref_st.t[i];
           __DBGpr_mat("RefMatrix",RefMatrix);
	}

	ParId = me->RefId;

     }
     else if ( me->nVCConn_type & VC_TERM_EQ) { 
        __DBGpr_com("VC_TERM_EQ");

        status = VDGetCsFromEq (&me->RefId, &ParId, &info);

        status = om$send( msg = message GRgencs.GRgetmatrix(&retmsg,RefMatrix),
                     targetid = ParId.objid,
                     targetos = ParId.osnum);

	ParId = me->RefId;
        __DBGpr_mat("RefMatrix",RefMatrix);

     }
     else if ( me->nVCConn_type & VC_TERM_RE) { 
        __DBGpr_com("VC_TERM_RE");
        status= om$send( msg = message VRGeneric.VRGetMatrix
                                            (&retmsg, 0, NULL, RefMatrix,
		                             &me->ModuleInfo),
                    targetid = me->RefId.objid,
                    targetos = me->RefId.osnum);

	ParId = me->RefId;
        /* CR179802404 - Rotation of terminals and connectors */
	status= 
	om$send( msg      = message ACncpx.ACgive_structure (
					 (int *) &retmsg,
					 (int *) &FootIndex, VC_N_PID_SCALE_DB,
					  &ParamAttr, &me->ModuleInfo),
		targetid = ParId.objid,
		targetos = ParId.osnum);
        __DBGpr_mat("RefMatrix",RefMatrix);

/*   Doesnt make sense to scale the offset when placing
	scale = ParamAttr.var.root_pm_st.value;
	__DBGpr_dbl( " PID scale ", scale );
*/
     }

     /*  New for tr179801229 - fix for place & rotate terminal */
     if(me->event1.response == RESET)
     {
	__DBGpr_com("No offset");
	me->event1.event.button.x = RefMatrix[3];
	me->event1.event.button.y = RefMatrix[7];
	me->event1.event.button.z = RefMatrix[11];
	__DBGpr_dbl("event.button.x",me->event1.event.button.x);
	__DBGpr_dbl("event.button.y",me->event1.event.button.y);
	__DBGpr_dbl("event.button.z",me->event1.event.button.z);
	me->event1.response = EX_DATA;
    }

    Click_point[0] = me->event1.event.button.x;
    Click_point[1] = me->event1.event.button.y;
    Click_point[2] = me->event1.event.button.z;

    __DBGpr_mat("Parent Matrix", RefMatrix);
    __DBGpr_vec("Click point", Click_point);
    __DBGpr_dbl("scale      ", scale);

/* translate the click point relative to my parent */ 

     VC_mat_invert( RefMatrix, InvRefMat);

     MAmulmx( &retmsg, &I_four, &I_four, &I_one, InvRefMat, 
						Click_point, My_offset);

     me->dValues[3 ]= My_offset[0] / scale;
     me->dValues[7 ]= My_offset[1] / scale;
     me->dValues[11]= My_offset[2] / scale;
    __DBGpr_mat("Offset Matrix", My_offset);
    __DBGpr_mat("dValues-offset", me->dValues);
  } 
  else { 
__DBGpr_com("No parent");

/* This will translate the terminal to the current mouse "clicked" position */

     me->dValues[3] = me->event1.event.button.x - 
					me->ModuleInfo.md_env.matrix[3];
     me->dValues[7] = me->event1.event.button.y - 
					me->ModuleInfo.md_env.matrix[7];
     me->dValues[11]= me->event1.event.button.z - 
					me->ModuleInfo.md_env.matrix[11];
     __DBGpr_mat("ModuleInfo matrix",me->ModuleInfo.md_env.matrix);
     __DBGpr_mat("dValues matrix",me->dValues);
  }
     /* CR179802404 - Hopefully, no conflicts here */
     __DBGpr_int("fetching rotation angle for ",my_id);
/***** debug printout of collection
     {
     IGRlong status=OM_S_SUCCESS, retmsg=MSFAIL;

     printf("sys_coll_id = %d %d\n", me->SysCId.objid, me->SysCId.osnum );

     status = om$send( msg      = message ACrg_collect.ACshow_data( &retmsg ),
                    senderid = NULL_OBJID,
                    targetid = me->SysCId.objid,
                    targetos = me->SysCId.osnum );
     as$status( action = RET_STATUS );

  }
******/
  {
  IGRint dumndx;
  struct ACrg_coll GetAttr;
  IGRdouble dang;
     status = om$send (msg = message VCAT.VCAT_get
                              (&retmsg, VC_SYSTEM, -1,VC_N_PID_ANGLE_DB,
                                    &dumndx, &GetAttr),
                      targetid = my_id);
     __DBGpr_int("objid for angle is ",my_id);
     dang = GetAttr.desc.value.att_exp * M_PI / 180.0;
     __DBGpr_dbl("angle fetched is", GetAttr.desc.value.att_exp);

     /* CR179802404-rotation values stored in me->dValues */ 
     me->dValues[0] = me->dValues[5] = cos(dang);
     me->dValues[4] = sin(dang);
     me->dValues[1] = -me->dValues[4];
  }

  __DBGpr_mat("me->dValues-angle ", me->dValues);
  /*  Reset temp angle */

  status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_PID_ANGLE_DB,
                                    AC_ATTRIB_DOUBLE, NULL, 0.0),
          targetid = my_id);
  status =
      om$send (msg = message VCAT.VCAT_sav (&retmsg),
          targetid = my_id);
/***** debug printout of collection
{
  IGRlong status=OM_S_SUCCESS, retmsg=MSFAIL;

  printf("sys_coll_id = %d %d\n", me->SysCId.objid, me->SysCId.osnum );

  status = om$send( msg      = message ACrg_collect.ACshow_data( &retmsg ),
                    senderid = NULL_OBJID,
                    targetid = me->SysCId.objid,
                    targetos = me->SysCId.osnum );
  as$status( action = RET_STATUS );

}
****/
  me->nVal = 16;
  me->nVCConn_type |= VC_TOFF_C_FULL;

End;
  return (OM_S_SUCCESS);
}

/**********************************************************/
/*** Disabled by removing from ".t" file *****/
method VCCmdRotate ( int * sts )
{
  IGRdouble dAngleXY;
  IGRint i;
  IGRlong retcode;

SetProc(VCCmdPT_VCCmdRotate ); Begin
  dAngleXY       = 0.0;
/*  me->dValues[3] = 0.0; */

  /* New for tr179801229 */
   __DBGpr_int("matrx size is", me->nVal);
  me->dValues[0] =
  me->dValues[5] =
  me->dValues[10] = 1.0;
  me->dValues[1] =
  me->dValues[2] =
  me->dValues[4] =
  me->dValues[6] =
  me->dValues[8] =
  me->dValues[9] = 0.0;

if(me->dValues[15] < 0.01) me->dValues[15] = 1.0;
  if (me->event1.response == EX_STRING)
  {
    IGRchar      szSTR[50];

    strcpy (szSTR, me->event1.event.keyin);

/*    dAngleXY = VC_DEG_RAD(atof(szSTR)) + M_PI; */
    dAngleXY = VC_DEG_RAD(atof(szSTR)) ;

#ifdef MY_DEBUG
printf("angle in rad is %lf\n",dAngleXY);
#endif
  }
  /* Below modified for tr179801229 */
  else 
  if (me->event1.response == EX_VALUE)
/*    dAngleXY = VC_DEG_RAD(me->event1.event.value) + M_PI; */
    dAngleXY = VC_DEG_RAD(me->event1.event.value);
  else
  if (me->event1.response == GRm_ANGLE)
    dAngleXY = VC_DEG_RAD(me->event1.event.value);
/*    dAngleXY = VC_DEG_RAD(me->event1.event.value) + M_PI; */
  else
  if (me->event1.response == EX_DATA)
  {
    IGRdouble dx, dy;
    /* Modified for tr179801229 */
    dx      = me->event1.event.button.x - me->dValues[3];
    dy      = me->event1.event.button.y - me->dValues[7];

    if (!((dx == 0) && (dy == 0)))
    {
      dAngleXY = atan2 (dy, dx);
    }
  }

  if (dAngleXY != 0.0)
  {
    /*    normalize angles     */
    while (dAngleXY > (M_PI))
      dAngleXY -= M_PI*2.0;
    /* New for TR179801229 */
    me->dValues[0] = cos(dAngleXY);
    me->dValues[4] = sin(dAngleXY);
    me->dValues[1] = -sin(dAngleXY);
    me->dValues[5] = cos(dAngleXY);
    me->nVal = 16;

__DBGpr_mat("me->dValues ", me->dValues);
#ifdef MY_DEBUG
    printf ("ANGLESET %f  in DEG %f\n",dAngleXY, VC_RAD_DEG(dAngleXY));
#endif

    me->nVCConn_type = me->nVCConn_type  & (~VC_TOFF_COORDS);
    me->nVCConn_type |= VC_TOFF_C_ANG;
  }

  *sts = me->ret = VC_RTC_ALLOK;

#ifdef MY_DEBUG
printf("leaving rotate\n");
#endif
  return (OM_S_SUCCESS);
}

/**********************************************************/

/* KDD 4-98 
method VCNoOffset (int *sts) 
{
	IGRlong		retmsg;

SetProc(VCCmdPT_VCNoOffset); Begin

  MAidmx (&retmsg, me->dValues);

  me->nVal = 16;
  me->nVCConn_type |= VC_TOFF_C_FULL;
 
End;
  return (OM_S_SUCCESS);
}
*/

end implementation VCCmdPT;

