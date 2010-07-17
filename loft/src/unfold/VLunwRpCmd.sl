/* $Id: VLunwRpCmd.sl,v 1.2 2001/02/20 01:06:43 build Exp $  */
 
/*************************************************************************
 * I/LOFT
 *
 * File:        src/unfold/VLunwRpCmd.sl
 *
 * Description: Generates Report file for unwrapped plates.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwRpCmd.sl,v $
 *      Revision 1.2  2001/02/20 01:06:43  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:42  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/11/12  18:46:12  pinnacle
# tr179801954
#
# Revision 1.2  1998/06/25  20:31:02  pinnacle
# Replaced: src/unfold/VLunwRpCmd.sl for:  by smpathak for loft
#
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      06/25/98   Sandeep      Header Creation
 *      06/25/98   Sandeep      File Modification for TR179801037
 *      11/10/98   Sandeep      File Modification for TR179801954
 *************************************************************************/
 


command_string	VLC_M_UNW_RP, 0, VLUnRp
command_table	"vl.cmd"
class		VLunwRpCmd
super_class	VLlocateCmd
product_name	"$LOFT"

start_state	ASCII

specification

#include <stdio.h>
#include "msdef.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "macro.h"
#include "griodef.h"
#include "gr.h"
#include "growner.h"
#include "VDSpathdef.h"
#include "DItypedef.h"
#include "vlunfold.h"

#define MY_ERROR        530

instance
{
int				nb_unw;
variable struct GRobj_env	unw_obj[1];
FILE				*ff;
}

implementation

#include        <stdio.h>
#include        <string.h>
#include        <math.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include	"gr.h"
#include        "msdef.h"
#include        "dpmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "godef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "FI.h"
#include        "ACattrib.h"
#include        "msmacros.h"
#include        "vsmiscmacros.h"
#include	"coparamac.h"
#include	"vlmsg.h"
#include        "VDSpathdef.h"
#include        "VDSudp_mac.h"
#include        "OMmacros.h"
#include        "OMprimitives.h"
#include 	"igrdp.h"
#include 	"fontdef.h"
#include 	"font.h"
#include        "fontmacros.h"
#include        "cotxmacros.h"
#include        "vsplatedef.h"
#include 	"vlunfold.h"
#include        "VDobj.h"
#include        "VDchn.h"
#include        "vlgrmacros.h"
#include        "vlgrdef.h"
#include 	"vldbgmacros.h"

from NDmacro import ACgive_structure;
from NDmacro import ACreturn_foot;
from GRtext import  GRgettxattr;
from ACcpx import   ACfind_exp_temp_obj;
from GRgraphics import   GRgetname;
from NDnode import   ASreturn_go;

#define	MY_ERROR 530

extern GRclassid  OPP_ACpretend_class_id;

/******************************************************************************/
state_table

#include        "vscmddef.h"
#include	"vlmsg.h"
#include	"msdef.h"
#include	"griodef.h"
#include 	"vlunfold.h"
#define	MY_ERROR 530

state ASCII
        message_key             VL_S_REPORT_F_PLATE
        prompt_key              VL_P_FILENAME
        filter			get_event

        on EX_STRING		do control_file_name
                                on RETURN_CODE = MY_ERROR    state .
                                                             state FIRST_UNWRAP
        
state FIRST_UNWRAP
	prompt_key		VL_P_UNWRAP
	accept_key		VL_M_ACC_NT_UNW
	locate_eligible		"VLunwObj"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state ASCII
        on EX_DATA or EX_OBJID	do VLcontrol_unw (&me->ret)	
                                     on RETURN_CODE = MY_ERROR  state .
                                do VLchaine_locate
								state UNWRAP
/******************************************************************************/
state UNWRAP
	prompt_key		VL_P_UNWRAPMO
	accept_key		VL_M_ACC_NT_UNW
	locate_eligible		"VLunwrap"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_RJT_MOVEON					state GENERATE
	on EX_BACK_UP						state ASCII
        on EX_DATA or EX_OBJID	do VLcontrol_unw (&me->ret)	
                                     on RETURN_CODE = MY_ERROR  state .
                                do VLchaine_locate
								state .

state GENERATE
        prompt                  " "
        execute                 VLreportPlate
                                on RETURN_CODE = MY_ERROR       state .

        on ELSE                                                 state ASCII

at init do my_cob_init

/* get file name  */
action control_file_name
{
  status = 1;
  me->ff = fopen(me->event1.event.keyin,"w");
  if (me->ff == NULL) *sts = MY_ERROR;
  goto quit;
}

/* get unwrap */
action VLcontrol_unw (long *sts)
{
struct GRobj_env        *LocatedObjects;
int                     nb_obj,nb_supprim;
int                     i,j;

  status = 1; // to avoid warning messages during compilation
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc,time=0,seconds=0);
    goto quit;
  }
  /* Verify the located objects aren't already in the list */
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    for (j=0; j<me->nb_unw;j++)
    {
      if (me->unw_obj[j].obj_id.objid == LocatedObjects[i].obj_id.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }

  if (nb_supprim)
    ex$message(msgnumb = VL_E_ObjInList,time=0,seconds=0);

  if(nb_obj - nb_supprim + me->nb_unw >
                                om$dimension_of( varray = me->unw_obj)) {
    om$vla_set_dimension(varray = me->unw_obj,size =
                                      nb_obj-nb_supprim+me->nb_unw);
  }

  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    me->unw_obj[i+me->nb_unw] = LocatedObjects[i];
  }
  me->nb_unw += nb_obj - nb_supprim;
  goto quit;// to avoid warning messages during compilation
}

/******************************************************************************/
/****  Modified  for TR179801037   ****/

action VLreportPlate {
  long                  loc_msg,msg;
  int                   loc_sts;
  int                   i,k=0,j;
  struct  GRobj_env     plate1;
  struct  GRid          parent,geom,ngeom;
  OMuword               obj_cl,acpretend_cl;
  IGRchar               name[DI_PATH_MAX];
  struct ret_struct     attrVal;
  IGRdouble             len=0.0,wid=0.0;
  OMuword               TEMP_cl;
 
 
  SetProc( VLreportPlate ); Begin
 
  *sts = MY_ERROR;
  if (!me->ff) goto wrapup;
 
  om$get_classid(  classname = "ACpretendin",  p_classid = &acpretend_cl);
  fprintf(me->ff,"                ============================= \n");
  fprintf(me->ff,"                SAMPLE FLATTENED PLATE REPORT \n");
  fprintf(me->ff,"                ============================= \n");
  fprintf(me->ff,"\n");
  fprintf(me->ff,"\n");
  fprintf(me->ff,"Plate name   Length\t  Width\t\t  Thickness\t  Material\t  Grade\n");
  fprintf(me->ff,"--------------------------------------------------------------------------------\n");
  __DBGpr_int(" the no of objects ",me->nb_unw);
  for (i=0;i<me->nb_unw;i++)
  {
    //  vdobj$Print( objOE = &(me->unw_obj[i]));
 
      vdchn$Get(il_objOE  = &(me->unw_obj[i]) ,
                ic_IDX    = VDCHN_IDX_FATHER,
                ir_objIDX = 1,
                or_objID  = & parent);
      __DBGpr_obj(" The parent is ",parent);
 
      om$get_classid( osnum           = parent.osnum  ,
                      objid           = parent.objid  ,
                      p_classid       = &TEMP_cl      ) ;
 
      if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
 
         status = om$send( msg  = message NDnode.ASreturn_go(
                                     &(plate1.obj_id),
                                     &(plate1.mod_env.md_env.matrix_type),
                                     plate1.mod_env.md_env.matrix ),
                        targetid = parent.objid,
                        targetos = parent.osnum );
       }else{
          status = om$send( msg  = message NDnode.ASreturn_go(
                                     &(plate1.obj_id),
                                     &(plate1.mod_env.md_env.matrix_type),
                                     plate1.mod_env.md_env.matrix ),
                        targetid = parent.objid,
                        targetos = parent.osnum );
          plate1.obj_id.objid = parent.objid ;
       }
       //  vdobj$Print( objOE = &(plate1));
 
        /* Get the Plate's name */
        status = om$send ( msg = message GRgraphics.GRgetname ( &loc_msg, name),
                        targetid = plate1.obj_id.objid,
                        targetos = plate1.obj_id.osnum );
        __DBGpr_str(" The name is ",name);
 
        if (!(status & 0x00000001 & loc_msg))
                strcpy( name, "Unamed");
        else   
          di$split ( pathname = name,
                     name = name);
        __DBGpr_str(" 11 The name is ",name);
        fprintf(me->ff,"%s          ",name);
 
        vdchn$Get(il_objOE  = &(me->unw_obj[i]) ,
                ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
                ir_objIDX = 0,
                or_objID  = & geom);
        __DBGpr_obj(" The Geom  is ",geom);

	/****  Modified  for TR179801954   ****/

	vdchn$Get(il_objID  = &(geom) ,
                ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
                ir_objIDX = 0,
                or_objID  = &ngeom);
        __DBGpr_obj("New .. The Geom  is ",ngeom);
 
        status = vl$minrect( curve   = &(ngeom),
                             environ = &(me->ModuleInfo),
                             length  = &len,
                             width   = &wid,
                             msg     = &loc_msg );
 
        fprintf(me->ff," %g\t%g\t ",len,wid);
 
 
        status = om$send( msg    = message NDmacro.ACgive_structure(
                                        &loc_sts,
                                        &j,
                                        VS_K_plThcknsAttr,
                                        &attrVal,
                                        &(me->ModuleInfo) ),
                       targetid = plate1.obj_id.objid,
                       targetos = plate1.obj_id.osnum ) ;
 
        __DBGpr_dbl(" the thickness is ",attrVal.var.root_pm_st.value);
        fprintf(me->ff," %lf\t ",fabs(attrVal.var.root_pm_st.value));
 
        status = om$send( msg    = message NDmacro.ACgive_structure(
                                        &loc_sts,
                                        &j,
                                        VS_K_prMatTypAttr,
                                        &attrVal,
                                        &(me->ModuleInfo) ),
                       targetid = plate1.obj_id.objid,
                       targetos = plate1.obj_id.osnum ) ;
 
        if (!(status & 0x00000001 & loc_sts))
          goto wrapup;
        fprintf(me->ff," %s\t ", attrVal.var.text_st.text_string);
 
        status = om$send( msg    = message NDmacro.ACgive_structure(
                                        &loc_sts,
                                        &j,
                                        VS_K_prMatGrdAttr,
                                        &attrVal,
                                        &(me->ModuleInfo) ),
                       targetid = plate1.obj_id.objid,
                       targetos = plate1.obj_id.osnum ) ;
 
        if (!(status & 0x00000001 & loc_sts))
          goto wrapup;
        fprintf(me->ff," %s\n", attrVal.var.text_st.text_string);
 
 
  }
  if (me->ff) fclose(me->ff);
  me->nb_unw = 0;
 
 
  *sts = MSSUCC;
wrapup :
  if (me->ff) fclose(me->ff);
  goto quit; End;

}
/******************************************************************************/
action VLchaine_locate
{
IGRlong msg;
IGRlong size = sizeof(struct GRevent) - sizeof(long)*2;

    status = ex$putque(msg = &msg,byte=&size,response=(IGRint *)&me->ret,
                       buffer = (IGRchar *) &me->event1.event);
    if (!(status&msg&1)) {
      printf("Pbs In Queue\n");
      me->ret = MY_ERROR;
      goto quit;
    }
}

action my_cob_init
{

   status = 1;       // to avoid warning messages during compilation
   me->nb_unw= 0;
   me->ff = NULL;
   goto quit;            // to avoid warning messages during compilation
}
