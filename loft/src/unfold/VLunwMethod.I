/* $Id: VLunwMethod.I,v 1.1.1.1 2001/01/04 21:11:42 cvs Exp $  */
 
/*************************************************************************
 * I/LOFT
 *
 * File:        src/unfold/VLunwMethod.I
 *
 * Description: Generates Report file for unwrapped plates.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwMethod.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:42  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/06/29  18:25:46  pinnacle
# Replaced: src/unfold/VLunwMethod.I for:  by smpathak for loft
#
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      06/29/98   Sandeep      Header Creation
 *      06/29/98   Sandeep      File Modification for TR179800798
 *************************************************************************/
 
class implementation VLunwrapCmd;

#include "msdef.h"
#include "FI.h"
#include "AS_status.h"
#include "griodef.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "dpmacros.h"
#include "DIdef.h"
#include "nddef.h"
#include "madef.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "coparamac.h"
#include "igr.h"
#include "grmacros.h"
#include "OMtypes.h"
#include "ms.h"
#include "msmacros.h"
#include "vsmiscmacros.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsplatedef.h"
#include "bsvalues.h"
#include "vlglobals.h"
#include "vluserkey.h"
#include "DIprims.h"
#include "vlstructure.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vlunfold.h"
#include "vlquerydef.h"

#define MY_ERROR        530
#define IMMEDIATE       0

/*
#define DEBUG
*/

from NDnode import NDchg_state;
from NDmacro     import  ACreturn_foot;
from GRgraphics  import  GRcopy;
from GRcurve     import  GRendpts;
from GRcurve     import  GRmidpoint;
from NDnode      import  ASreturn_go;
from GRgencs     import  GRgetmatrix;
from GRgraphics  import  GRdelete; extern MAmulmx();
from NDnode      import  NDgive_structure;
from IGEgragad   import  DPinrot;
from GRvg   	 import  GRgetname;
from GRvg   	 import  GRchglevel;
from VLunwrap  	 import  create;
from NDnode  	 import  NDdelete;
from ACrg_collect import  ACadd_list_attribute;
from ci_macro import  init;

extern double sqrt();
extern  GRclassid       OPP_ACpretend_class_id;
extern  GRclassid       OPP_VLunwrap_class_id;
extern  GRclassid       OPP_VSplate_class_id;
extern  GRclassid       OPP_VSimgFeature_class_id;
extern  GRclassid       OPP_nci_macro_class_id;
extern GRclassid OPP_ACrg_collect_class_id;
extern char *strchr();
extern			GRdisplay_object(), VLgetMacrosAtStep();

/* find the longer edge of all surfaces */
VLfind_max_edge (surf,nb,modenv,len) 
struct GRobj_env	*surf;   /* I: list of surfaces 	*/
IGRint			nb;      /* I: number of surfaces	*/
struct GRmd_env		*modenv; /*I: Current env.	*/
IGRdouble		*len;    /*O: the longer edge.	*/
{
IGRlong			sts,loc_sts;
struct GRid		grEdge,*list=NULL;
IGRint			ii,ind;
IGRint			count,dim=4;
IGRdouble		temp;
struct GRobj_env        base_surf,cp_obj,grobj;
IGRpoint		stpt,enpt;

   *len = 0;
   for (ind=0;ind<nb;ind++) 
   {
     if (vs$is_ancestry_valid( object   = &surf[ind].obj_id,
                              classid = OPP_VSimgFeature_class_id )
                == TRUE) {           
     sts = om$send( msg  = message NDnode.ASreturn_go(
                                      &grobj.obj_id,
                                      &grobj.mod_env.md_env.matrix_type,
                                      grobj.mod_env.md_env.matrix ),
                         senderid = NULL_OBJID,
                         targetid = surf[ind].obj_id.objid,
                         targetos = surf[ind].obj_id.osnum ) ;
     if( !( 1 & sts ) ) return 0;
     grobj.mod_env.md_id.osnum = grobj.obj_id.osnum;
     }
     else grobj = surf[ind];
     if(
       (vs$is_ancestry_valid( object   = &grobj.obj_id,
                              classid = OPP_VSplate_class_id )
               == TRUE) ||
       (vs$is_ancestry_valid( object   = &grobj.obj_id,
                              classid = OPP_VSimgFeature_class_id )
                == TRUE)
       ) {
      /*
       * Get bottom side of plate.
       */
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_sts,
                                          VS_K_plBotSfPath,
                                          &base_surf.obj_id,
                                          &base_surf.mod_env.md_env.matrix_type,
                                          base_surf.mod_env.md_env.matrix),
                         senderid = NULL_OBJID,
                         targetid = grobj.obj_id.objid,
                         targetos = grobj.obj_id.osnum ) ;
        if( !( loc_sts & 1 & sts ) ) return 0;
       base_surf.mod_env.md_id.osnum = base_surf.obj_id.osnum;
       MAmulmx(&loc_sts,&dim,&dim,&dim,grobj.mod_env.md_env.matrix,
               base_surf.mod_env.md_env.matrix,base_surf.mod_env.md_env.matrix);
       if (!(loc_sts&1)) return 0;
       MAtypemx( &loc_sts, base_surf.mod_env.md_env.matrix,
                                     &base_surf.mod_env.md_env.matrix_type);
       if (!(loc_sts&1)) return 0;
     }
     else {
        base_surf = grobj;
      }

      if ((vs$is_ancestry_valid( object   = &grobj.obj_id,
                                classid = OPP_VSimgFeature_class_id )
                  == TRUE)) {
                   /* because there is probleme in images */
        sts = om$send(msg = message GRgraphics.GRcopy(
                                                &loc_sts,
                                                &base_surf.mod_env,
                                                modenv,
                                                &cp_obj.obj_id.objid ),
                                senderid = NULL_OBJID,
                                targetid = base_surf.obj_id.objid,
                                targetos = base_surf.obj_id.osnum );
        if( ! (sts&loc_sts&1)) return 0;
        cp_obj.obj_id.osnum = modenv->md_id.osnum;
        cp_obj.mod_env = *modenv;
     }
     else {
       cp_obj = base_surf;
     }
     sts = vs$get_surface_edges( msg         = &loc_sts,
                              sfId        = &cp_obj.obj_id,
                              sfEnv       = &cp_obj.mod_env,
                              edgeType    = VS_K_CONTOUR_EDGES,
                              edCount     = &count,
                              edList      = &list ) ;

  if( !( sts & 1 & loc_sts ) ) {
#ifdef DEBUG
    printf( "~~~~~~~~~~ERROR in vs$get_surface_edges\n" ) ;
#endif
    return 0;
  }
  for (ii=0; ii<count; ii++)
  {
    sts = vs$get_graphic_edge( msg    = &loc_sts,
                               edId   = &list[ii],
                               edEnv  = &cp_obj.mod_env,
                               copy   = FALSE,
                               copyEnv   = NULL,
                               grEdge = &grEdge) ;

    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in vs$get_graphic_edge\n" ) ;
#endif
    return 0;
    }
    sts = om$send( msg = message GRcurve.GRendpts(  
                                           &loc_sts,
                                           &cp_obj.mod_env.md_env.matrix_type,
                                           cp_obj.mod_env.md_env.matrix,
                                           stpt,enpt),
                          targetid = grEdge.objid,
                          targetos = grEdge.osnum,
                          senderid = NULL_OBJID);
     if (!(sts&loc_sts&1)) return 0;
     temp = (enpt[0]-stpt[0])*(enpt[0]-stpt[0])+
           (enpt[1]-stpt[1])*(enpt[1]-stpt[1])+
           (enpt[2]-stpt[2])*(enpt[2]-stpt[2]);
    if (*len < temp) *len = temp;
    }
    if (list) {free(list); list=NULL;}
  }
  *len = 1.3*sqrt((*len));
  return 1;
}

/* get surfaces */
method VLcontrol_surf (long *sts)
{
struct GRobj_env	*LocatedObjects;
struct GRid		tmp;
int			nb_obj,nb_supprim;
int			i,j;

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
    ex$message(msgnumb = VL_E_NoObjLoc,time=IMMEDIATE,seconds=IMMEDIATE);
    goto quit;
  }
  /* Verify the located objects aren't already in the list */
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &tmp);

    if( vs$is_ancestry_valid( object  = &LocatedObjects[i].obj_id, 
                              classid = OPP_VSplate_class_id) == TRUE )
    {
	IGRint		 numObjects=0; 
	struct GRobj_env plate_obj, *list_obj=NULL;

	plate_obj.obj_id  = tmp;
	plate_obj.mod_env = LocatedObjects[i].mod_env;

 	VLbrowseFctInTree( &plate_obj, VL_Q_TOP_SOURCE, NULL,
                     		VL_Q_DOWN_DIRECT,
                     		VLgetMacrosAtStep,
                     		&numObjects, 
				&list_obj );
  	VLfilterDef(numObjects,list_obj,&numObjects,"srf_unwrap");

	if( numObjects )
        {
          /* Unwrap is already done on the plate */
          gr$display_object ( object_id = &LocatedObjects[i].obj_id,
			      md_env    = &LocatedObjects[i].mod_env,
	     	              mode      = GRhe);

          LocatedObjects[i].obj_id.objid = NULL_OBJID;

          ex$message( 	field   = ERROR_FIELD,
		        in_buff = "Plate is already unwrapped" );

	  /* Hilight the unwrapped objects */
	  vs$bulk_display( dpmode  = GRhd,
			   count   = numObjects,
			   objenvs = list_obj );
          nb_supprim++;
          continue;
	}
    }

    for (j=0; j<me->nb_surf;j++)
    {
      if (me->surf[j].obj_id.objid == tmp.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }

  if( (nb_obj - nb_supprim) == 0 )
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc,time=IMMEDIATE,seconds=IMMEDIATE);
    goto quit;
  }

  if (nb_supprim)
    ex$message(msgnumb = VL_E_ObjInList,time=IMMEDIATE,seconds=IMMEDIATE);

  if(nb_obj - nb_supprim + me->nb_surf >
                                om$dimension_of( varray = me->surf)) {
    om$vla_set_dimension(varray = me->surf,size =
                                      nb_obj-nb_supprim+me->nb_surf);
  }

  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &LocatedObjects[i].obj_id);
    me->surf[i+me->nb_surf] = LocatedObjects[i];
  }
  me->nb_surf += nb_obj - nb_supprim;
quit :
  return OM_S_SUCCESS;
}

/* Create  reference and place Unwrap macro for each surface */ 
method VLgo_unwrap (long *sts)
{
int			i,jj;
struct  GRvg_construct  cst;
IGRdouble               accept_button[3],winMat[16];
IGRdouble		viewMat[16];
struct  GRobj_env       refID;
IGRlong			loc_msg;
struct GRid		win,MAC;
IGRlong 		loc_sts,status;
double 			vect[3],tmp,len=0;
int			i0,i1,i2,MAX_ROW;


  tmp = sqrt((double) me->nb_surf);
  MAX_ROW = tmp;
  if (tmp-MAX_ROW >= 0.5) MAX_ROW++;

  VLinitCnst(&cst);
  accept_button[0] = me->event1.event.button.x;
  accept_button[1] = me->event1.event.button.y;
  accept_button[2] = me->event1.event.button.z;
  win.objid = me->event1.event.button.objid;
  win.osnum = me->event1.event.button.osnum;
                                                 //create coordinate system
  status= VLcreWinRef(accept_button, win, (IGRboolean)TRUE, 
                       &cst, (IGRboolean)FALSE, winMat, &refID, &loc_msg );
  if (!(status&loc_msg&1)) {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_BadPlc,time=IMMEDIATE,seconds=IMMEDIATE);
    goto quit;
  }

  om$send(msg      = message NDnode.NDchg_state( (char)ND_SUP_ONLY,
						 (char)ND_SUP_ONLY ),
	  senderid = NULL_OBJID,
          targetid = refID.obj_id.objid,
          targetos = refID.obj_id.osnum   );


  status = om$send( msg      = message  IGEgragad.DPinrot(&loc_sts,viewMat ),
                         targetid = win.objid,
                         targetos = win.osnum );
  if (!(status&loc_sts&1)) {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_BadPlc,time=IMMEDIATE,seconds=IMMEDIATE);
    goto quit;
  }
  if (viewMat[0] != 0) {
    i0 = 0;
    if (viewMat[5] != 0) {i1 = 1;i2 = 2;}
    else {i1 = 2;i2 = 1;}
  }
  else {
    i0 = 1;
    i1 = 2;
    i2 = 0;
  }
  vect[i2] = accept_button[i2];
  if (me->nb_surf > 1) {
    if(!VLfind_max_edge (me->surf,me->nb_surf,&me->ModuleInfo,&len)) {
      me->ret = *sts = MY_ERROR;
      ex$message(msgnumb = VL_E_BadPlc,time=IMMEDIATE,seconds=IMMEDIATE);
      goto quit;
    }
  }

  for (i=0,jj=0;i<me->nb_surf;i++)
  {
    MAC.objid  = NULL_OBJID;
    MAC.osnum  = me->ModuleInfo.md_id.osnum;
    status = om$construct (classid = OPP_VLunwrap_class_id,
                           osnum   = MAC.osnum,
                           p_objid = &(MAC.objid));
    if (!(status&1)) {
      *sts = MY_ERROR;
      ex$message(msgnumb = VL_E_BadPlc,time=IMMEDIATE,seconds=IMMEDIATE);
      continue;
    }

    status = om$send(msg   = message VLunwrap.create ( 
                                           &loc_msg,
                                           &(me->surf[i]),
                                           &refID,
                                           me->options,
                                           &me->ModuleInfo),
                          targetid = MAC.objid,
                          targetos = MAC.osnum);
    if (!(status&loc_msg&1)) {
      *sts = MY_ERROR;
      ex$message(msgnumb = VL_E_BadPlc);
      om$send( msg = message  GRgraphics.GRdelete(&status,&(me->ModuleInfo) ),
                           targetid = refID.obj_id.objid,
                           targetos = refID.obj_id.osnum );
      om$send( msg = message  NDnode.NDdelete(&(me->ModuleInfo) ),
                           targetid = MAC.objid,
                           targetos = MAC.osnum );
      continue;
    }

    gr$display_object ( object_id = (struct GRid *)&(refID.obj_id),
                        md_env    = cst.env_info,
                        mode      = GRbd );


    if (i < me->nb_surf - 1) {     // compute new position for the next unwrap
      if (jj<MAX_ROW-1) {
        vect[i1] = accept_button[i1] + (jj+1)*len;
        vect[i0] = accept_button[i0];
        jj++;
      }
      else {
        accept_button[i0] += len;
        vect[i1] = accept_button[i1];
        vect[i0] = accept_button[i0];
        jj = 0;
      }
      status= VLcreWinRef(vect, win, (IGRboolean)TRUE, 
                           &cst, (IGRboolean)FALSE, winMat, &refID,&loc_msg );
      if (!(status&loc_msg&1)) {
        me->ret = *sts = MY_ERROR;
        ex$message(msgnumb = VL_E_BadPlc,time=IMMEDIATE,seconds=IMMEDIATE);
        goto quit;
      }

  	om$send(msg      = message NDnode.NDchg_state( (char)ND_SUP_ONLY,
						 (char)ND_SUP_ONLY ),
	        senderid = NULL_OBJID,
                targetid = refID.obj_id.objid,
                targetos = refID.obj_id.osnum   );

    }
  }
  me->nb_surf = 0;
quit :
  return OM_S_SUCCESS;
}

method save_all (long *sts)
{
char	tmp[50];
long	loc_msg;
int	i, j;
int     code;
long	status;

  *sts = MY_ERROR;
  
  FIg_get_text(me->status_display_form_ptr,G_FIBER_RATIO,tmp);
  sscanf(tmp,"%lf",&me->options[UNFOLD_ATT_IDX_FIB_RATIO]);
  om$send(msg = message VLunwrapCmd.VLmodGlobals
                             (&loc_msg,NAM_G_FIB,
                              me->options[UNFOLD_ATT_IDX_FIB_RATIO]),
                    targetid = my_id);

  FIg_get_state(me->status_display_form_ptr,G_UNW_SURF, &i);
  me->options[UNFOLD_ATT_IDX_SRFWANTED]=i;
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                             (&loc_msg,NAM_G_UNW_SURF,
                              me->options[UNFOLD_ATT_IDX_SRFWANTED]),
                    targetid = my_id);

  FIg_get_text(me->status_display_form_ptr,G_EXP_TYPE,tmp);
  if (!strcmp(tmp,"Global Expansion")) 
          me->options[UNFOLD_ATT_IDX_EXPTYPE] = GLOBAL_LW_RATIO;
  else if (!strcmp(tmp,"Expansion by Marking")) 
          me->options[UNFOLD_ATT_IDX_EXPTYPE] = BY_STIFFNERS;
    else if (!strcmp(tmp,"No Expansion")) 
          me->options[UNFOLD_ATT_IDX_EXPTYPE] = NO_EXPANSION;
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                             (&loc_msg,NAM_G_T_EXP,
                              me->options[UNFOLD_ATT_IDX_EXPTYPE]),
                    targetid = my_id);

  FIg_get_text(me->status_display_form_ptr,G_SIDE,tmp);
  if (!strcmp(tmp,"Base")) 
          me->options[UNFOLD_ATT_IDX_SIDE] = BASE_SIDE;
  else if (!strcmp(tmp,"Offset")) 
          me->options[UNFOLD_ATT_IDX_SIDE] = OFFSET_SIDE;
    else if (!strcmp(tmp,"Max Marking")) 
          me->options[UNFOLD_ATT_IDX_SIDE] = MAX_MARK;
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                             (&loc_msg,NAM_G_SIDE,
                              me->options[UNFOLD_ATT_IDX_SIDE]),
                    targetid = my_id);

  FIg_get_text(me->status_display_form_ptr,G_EXP_X_SCALE,tmp);
  sscanf(tmp,"%lf",&me->options[UNFOLD_ATT_IDX_X_EXPANSION]);
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                               (&loc_msg,NAM_G_X_EXP,
                                me->options[UNFOLD_ATT_IDX_X_EXPANSION]),
                      targetid = my_id);

  FIg_get_text(me->status_display_form_ptr,G_EXP_Y_SCALE,tmp);
  sscanf(tmp,"%lf",&me->options[UNFOLD_ATT_IDX_Y_EXPANSION]);
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                               (&loc_msg,NAM_G_Y_EXP,
                                me->options[UNFOLD_ATT_IDX_Y_EXPANSION]),
                      targetid = my_id);

  FIg_get_state(me->status_display_form_ptr,G_TESSELATION, &i);
  me->options[UNFOLD_ATT_IDX_TESSELATION] = i;
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                               (&loc_msg,NAM_G_TESS,
                                me->options[UNFOLD_ATT_IDX_TESSELATION]),
                      targetid = my_id);

  for (i=0;i<UNFOLD_NB_OPTLINE;i++)
  {
    if( i==UNFOLD_ATT_IDX_DISMIN )
    {
      FIg_get_state(me->status_display_form_ptr,G_DISMIN,&j );
      if( j ) me->optlines[UNFOLD_ATT_IDX_DISMIN] = 0;
      else    me->optlines[UNFOLD_ATT_IDX_DISMIN] = 1;
    }
    else if( i==UNFOLD_ATT_IDX_FAR )
    {
      FIg_get_state(me->status_display_form_ptr,G_FAR,&j );
      if( j ) me->optlines[UNFOLD_ATT_IDX_FAR] = 1;
      else    me->optlines[UNFOLD_ATT_IDX_FAR] = 0;
    }
    else
    FIfld_get_select(me->status_display_form_ptr,G_LINES,i,0,&me->optlines[i]);
  }
  VLencode ( me->optlines, UNFOLD_NB_OPTLINE, &code);
  me->options[UNFOLD_ATT_IDX_LINES] = code;
  om$send(msg = message VLunwrapCmd.VLmodGlobals
                               (&loc_msg,NAM_G_UNW_CODE,code),
                      targetid = my_id);

  FIg_get_state(me->status_display_form_ptr,G_WATONPLATE, &i);
  me->options[UNFOLD_ATT_IDX_WATONPLATE]=i;
  status = om$send(msg = message VLunwrapCmd.VLmodGlobals
                             (&loc_msg,NAM_G_WATONPLATE,
                              me->options[UNFOLD_ATT_IDX_WATONPLATE]),
                    targetid = my_id);
  *sts = MSSUCC;

  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
OMuword TEMP_cl;
int	suc,i;
long    l_msg,status;
char    type[50],*side;
struct GRobj_env GObj;
struct GRobj_env surf_obj;
int    dim = 4;


  if( form_ptr == NULL ) return( OM_E_INVARG );
  FIg_set_text(me->status_display_form_ptr,FI_MSG_FIELD," ");

  switch( gadget_label )
  {
    case FI_ACCEPT :
      status = om$send(msg = message VLunwrapCmd.save_all(&me->ret),
                    targetid = my_id);

      if (!(status&1)) me->ret=MY_ERROR;

      om$send ( msg = message CEO.erase_form_by_label
                                     ( STATUS_FORM, 0, &suc),
                    targetid = my_id);
      FIg_set_state_off(me->status_display_form_ptr,FI_ACCEPT);
      _put_response(resp = me->ret);
      break;
    case FI_CANCEL :
      om$send ( msg = message CEO.erase_form_by_label
                                        ( STATUS_FORM, 0, &suc),
                    targetid = my_id);
      FIg_set_state_off(me->status_display_form_ptr,FI_CANCEL);
      break;
    case G_EXP_TYPE :
      FIg_get_text(me->status_display_form_ptr,G_EXP_TYPE,type);
      if (strcmp(type,"No Expansion")) {
        FIg_display(me->status_display_form_ptr,G_EXP_X_SCALE);
        FIg_display(me->status_display_form_ptr,G_EXP_Y_SCALE);
        FIg_display(me->status_display_form_ptr,G_EXP_X_TEXT);
        FIg_display(me->status_display_form_ptr,G_EXP_Y_TEXT);
      }
      else {
        FIg_erase(me->status_display_form_ptr,G_EXP_X_SCALE);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_SCALE);
        FIg_erase(me->status_display_form_ptr,G_EXP_X_TEXT);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_TEXT);
      }
      break;

    case G_SIDE :
      FIg_get_text(me->status_display_form_ptr,G_SIDE,type);
        // Unhighlight old side and normal.
      dp$erase_hilite( msg = &status ) ;
      if (!strcmp(type,"Base") || !strcmp(type,"Offset")) {

        for (i=0;i<me->nb_surf;i++)
        {
          om$get_classid( osnum           = me->surf[i].obj_id.osnum  ,
                          objid           = me->surf[i].obj_id.objid  ,
                          p_classid       = &TEMP_cl      ) ;

          GObj = me->surf[i];
          if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                 subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
      
              status = om$send( msg  = message NDnode.ASreturn_go(
                                        &GObj.obj_id,
                                        &GObj.mod_env.md_env.matrix_type,
                                         GObj.mod_env.md_env.matrix ),
                        targetid = me->surf[i].obj_id.objid,
                        targetos = me->surf[i].obj_id.osnum );

              if (!(status&1)) continue;

              status = om$get_classid( osnum   = GObj.obj_id.osnum  ,
                                       objid   = GObj.obj_id.objid  ,
                                       p_classid   = &TEMP_cl);
          }
          if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
                              subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

            if (!strcmp(type,"Base")) side = VS_K_plBotSfPath;
            else                     side =  VS_K_plTopSfPath;
            status= om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        side,
                                        &surf_obj.obj_id,
                                        &surf_obj.mod_env.md_env.matrix_type,
                                        surf_obj.mod_env.md_env.matrix ),
                        targetid = GObj.obj_id.objid,
                        targetos = GObj.obj_id.osnum ) ;
             if (!(status&l_msg&1)) continue;

             if (GObj.mod_env.md_env.matrix_type != MAIDMX) {
               dim = 4;
               MAmulmx(&status,&dim,&dim,&dim,GObj.mod_env.md_env.matrix,
                       surf_obj.mod_env.md_env.matrix,
                       surf_obj.mod_env.md_env.matrix);
               MAtypemx( &status, surf_obj.mod_env.md_env.matrix,
                         &surf_obj.mod_env.md_env.matrix_type);
             }
           }
           else surf_obj = GObj;

           vs$bulk_display(count = 1,
                           dpmode = GRhdo,
                           objenvs = &surf_obj);
           VSdisplaySurfaceNormal(&status,&surf_obj,TRUE,&me->ActiveDisplay,
                                  GRhd);
        }
    }
    break;
  }
quit :
return OM_S_SUCCESS;
}

end implementation VLunwrapCmd;
