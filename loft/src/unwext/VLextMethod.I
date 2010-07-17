/* $Id: VLextMethod.I,v 1.3 2001/06/27 20:29:19 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLextMethod.I
 *
 * Description: Unwrap Command Object implementations.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLextMethod.I,v $
 *      Revision 1.3  2001/06/27 20:29:19  ramarao
 *      Fixed TR# 5371.
 *
 *      Revision 1.2  2001/02/20 01:07:14  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:43  cvs
 *      Initial import to CVS
 *
# Revision 1.8  2000/03/20  22:36:34  pinnacle
# Replaced: src/unwext/VLextMethod.I for:  by impd252 for loft
#
# Revision 1.7  2000/02/24  16:49:50  pinnacle
# Replaced VLextMethod.I for TR179901140 by jpulapar
#
# Revision 1.6  2000/02/22  16:58:34  pinnacle
# (No comment)
#
# Revision 1.5  1999/06/01  16:28:38  pinnacle
# (No comment)
#
# Revision 1.4  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.2  1998/07/14  13:44:22  pinnacle
# Replaced: src/unwext/VLextMethod.I for:  by smpathak for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.5  1998/04/23  05:40:16  pinnacle
# Replaced: src/unwext/VLextMethod.I for:  by smpathak for loft
#
# Revision 1.4  1998/04/21  00:03:24  pinnacle
# Replaced: src/unwext/VLextMethod.I for:  by yzhu for loft
#
# Revision 1.3  1998/02/26  11:16:56  pinnacle
# Replaced: src/unwext/VLextMethod.I for:  by rchennup for loft
#
# Revision 1.2  1998/01/22  19:56:04  pinnacle
# Replaced: src/unwext/VLextMethod.I for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:28:42  pinnacle
# Created: src/unwext/VLextMethod.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *      04/23/98   Sandeep      Modification for Form Interface
 *      07/14/98   Sandeep      TR179800636
 *      02/04/98   Manoj        TR179802382 Multiple plates in ref files
 *      03/17/99   Manoj        TR179900169 Added checks for stopping of unwraps
 *      04/09/99   ah           Rama Rao SP08 Fixes
 *	02/24/00   Jayadev      TR179901140 Multiple unwraps for same plate
 *************************************************************************/

class implementation VLunwextCmd;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "madef.h"
#include "coparamac.h"
#include "asmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "FI.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"
#include "vlmsg.h"
#include "vlquerydef.h"
#include "vlglobals.h"
#include "vlunwext.h"
#include "vldbgmacros.h"
#include "griomacros.h"
#include "griodef.h"
#define UNWRAP_DEBUG // TR #179900169

from IGEgragad   import  DPinrot;
from GRgraphics  import  GRdelete;
from NDnode      import  ASreturn_go, NDchg_state, NDdelete;
from NDmacro     import  ACreturn_foot;
from ACcpx	 import  find_macro;
from expression  import  NDgive_value;

from ACmacro_defn import ACgive_feet_desc;

extern GRclassid OPP_VSplate_class_id, OPP_ACpretend_class_id;
//changes for TR #179802382 :starts 
extern GRclassid OPP_ACpretendin_class_id;
//changes for TR #179802382 :ends 
extern VLgetMacrosAtStep();
extern IGRdouble sqrt(); //TR #1798002382

#define MY_ERROR        530
#define IMMEDIATE       0

/*
#define DEBUG
*/

/* get surfaces */
method VLcontrol_surf (long *sts)
{
struct GRobj_env	*LocatedObjects;
struct GRid		dummy, tmp;
OM_S_OBJID		exp_obj;
int			nb_obj,nb_supprim;
int			i,j,k, obj_count=0, *del_list=NULL;
long			msg, loc_sts;
IGRboolean		multiUnwrap;
IGRchar         	file_name[DI_PATH_MAX], exp_name[DI_PATH_MAX];

  multiUnwrap    = FALSE;
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

  VDSget_filename(file_name);
  sprintf(exp_name, "%s:IGENOD:UCM_UNWRAP", file_name );

  loc_sts = di$translate(  objname = exp_name,
			   osnum   = me->ModuleInfo.md_id.osnum,
			   p_objid = &exp_obj );
  if( loc_sts == DIR_S_SUCCESS)
  {
      IGRdouble unw_opt;
      loc_sts = om$send ( msg = message expression.NDgive_value ( &unw_opt ),
			  targetid = exp_obj,
			  targetos = me->ModuleInfo.md_id.osnum );
      if( unw_opt == 1.0 ) multiUnwrap = TRUE;
  }

  // Verify the located objects aren't already in the list
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   = me->ModuleInfo.md_id.osnum ,
                    as_grid = &tmp);

    if( vs$is_ancestry_valid( object  = &LocatedObjects[i].obj_id, 
                              classid = OPP_VSplate_class_id) == TRUE )
    {
	IGRint		 numObjects=0, feet_num=0; 
	struct GRid      macro_def;
	struct myfeet    *feet_desc=NULL;
	struct GRobj_env plate_obj, *list_obj=NULL;

	plate_obj.obj_id  = tmp;
	plate_obj.mod_env = LocatedObjects[i].mod_env;
        //printf(" Plate %d %d \n",LocatedObjects[i].obj_id.objid,LocatedObjects[i].obj_id.osnum); //debug
 	VLbrowseFctInTree( &plate_obj, VL_Q_TOP_SOURCE, NULL,
                     		VL_Q_DOWN_DIRECT,
                     		VLgetMacrosAtStep,
                     		&numObjects, 
				&list_obj );
  	VLfilterDef(numObjects,list_obj,&numObjects,"VLunwObj");

	if( numObjects )   del_list = _MALLOC( numObjects, IGRint );

             //If all del_list[i]  is set to 1  
             // in the following "for" loop, the located objects
             // has to be unwraped.
             //If even a single object is not set to one,
	     // the objects has been already unwrapped. 
             
	for( j=0; j<numObjects; ++j )
	{
	    del_list[j] = 0;
	    loc_sts = om$send( msg = message ACcpx.find_macro( &macro_def ),
			targetid = list_obj[j].obj_id.objid,
			targetos = list_obj[j].obj_id.osnum   );
	    if( !(loc_sts&1) )
	    {
	       del_list[j] = 1;
               printf(" Continuing at %d \n", __LINE__); //debug
 printf("Object %d %d already unwrapped \n",LocatedObjects[i].obj_id.objid,LocatedObjects[i].obj_id.osnum); //debug
	       continue;
	    }

    	    loc_sts = om$send (msg = message ACmacro_defn.ACgive_feet_desc
                                 ( &feet_num, &feet_desc ),
                  	targetid = macro_def.objid,
                  	targetos = macro_def.osnum);
	    if( !(loc_sts&1) )
	    {
	       del_list[j] = 1;
#ifdef UNWRAP_DEBUG
               printf(" Continuing at %d \n",__LINE__); //debug
 printf("Object %d %d already unwrapped \n",LocatedObjects[i].obj_id.objid,LocatedObjects[i].obj_id.osnum); //debug
#endif
	       continue;
	    }

	    for( k=0; k<3; ++k )  // Unwrap Object feet = 3
	    {
		loc_sts = om$send( msg = message NDmacro.ACreturn_foot( &msg,
				feet_desc[k].name, &dummy, NULL, NULL ),
			targetid = list_obj[j].obj_id.objid,
                        targetos = list_obj[j].obj_id.osnum   );
		if( !(loc_sts&msg&1) ) 
		{
		   del_list[j] = 1;
#ifdef UNWRAP_DEBUG
                   printf(" Breaking at %d \n",__LINE__); //debug
#endif
		   break;
		}
	    }
	}

        obj_count = numObjects;

	for( j=0; j<numObjects; ++j )
	{
	   if( del_list[j] )
	   {
	       vs$bulk_delete( objenvs = &list_obj[j] );
	       VLswapObjEnv( list_obj, j, --obj_count );
	   }
	}
	numObjects = obj_count;


	if( numObjects && !multiUnwrap ) 
        {
          // Unwrap is already done on the plate
#ifdef UNWRAP_DEBUG
 printf("Object %d %d already unwrapped \n",LocatedObjects[i].obj_id.objid,LocatedObjects[i].obj_id.osnum); //debug
#endif
          gr$display_object ( object_id = &LocatedObjects[i].obj_id,
			      md_env    = &LocatedObjects[i].mod_env,
	     	              mode      = GRhe);

          LocatedObjects[i].obj_id.objid = NULL_OBJID;

          ex$message( 	field   = ERROR_FIELD,
		        in_buff = "Plate is already unwrapped" );

	  // Hilight the unwrapped objects
	  vs$bulk_display( dpmode  = GRhd,
			   count   = numObjects,
			   objenvs = list_obj );
          nb_supprim++;
          continue;
	}
	_FREE( del_list );
    } /* if it is a plate */
    // Source object was being compared previously - TR179901140
    for (j=0; j<me->nb_surf;j++)
    {
      //if (me->surf[j].obj_id.objid == tmp.objid)
      if (me->surf[j].obj_id.objid == LocatedObjects[i].obj_id.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;// it is already here
        nb_supprim++;
        break;
      }
    }
  }

  if( (nb_obj - nb_supprim) == 0 )
  {
    me->ret = *sts = MY_ERROR;
//    ex$message(msgnumb = VL_E_NoObjLoc,time=IMMEDIATE,seconds=IMMEDIATE);
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
//changes for TR #179802382 :starts 
	if (vs$is_ancestry_valid( object = &LocatedObjects[i].obj_id,
                                classid = OPP_ACpretendin_class_id )){
	      struct GRobj_env tmp;
              long status = om$send( msg  = message NDnode.ASreturn_go(
                                        &tmp.obj_id,
                                        &tmp.mod_env.md_env.matrix_type,
                                         tmp.mod_env.md_env.matrix ),
			senderid  = NULL_OBJID,
                        targetid = LocatedObjects[i].obj_id.objid,
                        targetos = LocatedObjects[i].obj_id.osnum );
              //printf("an ACpretendin object \n");//debug
      if (!vs$is_ancestry_valid( object = &tmp.obj_id,
                                classid = OPP_VSplate_class_id )){
		//printf( " It was not a plate \n"); //debug
		continue;
	} else {
         LocatedObjects[i].obj_id 		= tmp.obj_id;
	 LocatedObjects[i].mod_env.md_env	= tmp.mod_env.md_env;
	}
      } 
//changes for TR #179802382 :ends 

	//printf(" Located obj id = %d \n",LocatedObjects[i].obj_id.objid); //debug
	//printf(" Located obj os = %d \n",LocatedObjects[i].obj_id.osnum); //debug
    me->surf[me->nb_surf++] = LocatedObjects[i];
  }

quit :
  _FREE( del_list );
  return OM_S_SUCCESS;
}/*VLcontrol_surf*/ 
/* check view if it is top view */
IGRlong VLisWinTop (
IGRlong                 *rc,      /*O   MSSUCC or MSFAIL */
struct GRid             winObj,   /*I   a win ID to get the axis */
struct GRvg_construct   *cst     /*I   the cst */
)
{
        IGRint          	i;
	struct GRobj_env        refGRid;
        IGRlong         MSsts;
        IGRdouble       viewMat[16];
        IGRmatrix       idMx ;
        IGRboolean      found = TRUE;

	SetProc ( VLisWinTop ); Begin 
        refGRid.obj_id.objid = NULL_OBJID;
        refGRid.obj_id.osnum = cst->env_info->md_id.osnum;

        MSsts = om$send( msg      = message  IGEgragad.DPinrot(rc,viewMat ),
                         senderid = NULL_OBJID,
                         targetid = winObj.objid,
                         targetos = winObj.osnum );
        if( !(*rc&MSsts&1) ) {
                __DBGpr_com("error in IGEgragad.DPinrot");
                goto wrapup;
        }
        __DBGpr_mat(" view matrix ", viewMat);


        MAidmx( rc, idMx );
        __DBGpr_mat(" idMx matrix ", idMx);

        for( i=0; i<16 && found; ++i){
        	__DBGpr_int(" i", i);
                  if( (idMx[i] - viewMat[i]) > 0.01 ){
                            found = FALSE ;
                            break;
                  }
        }
        __DBGpr_int(" found", found);
        if( !found ){
                   printf("Please Select Top View for Extract Unwrap\n");
                   UI_status("Must Select Top View");
                   goto wrapup;
        }

        cst->geometry = NULL;

        *rc = MSSUCC;
        End
        return(MSSUCC);

wrapup:
        cst->geometry = NULL;
        *rc = MSFAIL;
        End
        return(MSFAIL);
}/* VLisWinTop*/ 


/* Create  reference and place Unwrap macro for each surface */ 
method VLgo_unwrap (long *sts)
{
int			i,jj,i0,i1,i2,MAX_ROW;
IGRlong			loc_msg, loc_sts, status;
IGRdouble               accept_button[3],winMat[16], viewMat[16], 
			vect[3],tmp,len=0;
struct GRid		win,MAC;
struct  GRobj_env       refID;
struct  GRvg_construct  cst;

  tmp = sqrt((double) me->nb_surf);
  MAX_ROW = tmp;
  //printf(" Number of surfs = tmp = %lf \n", tmp); //debug
  //printf(" surf0 id = %d \n", me->surf[0].obj_id.objid); //debug
  //printf(" surf0 os = %d \n", me->surf[0].obj_id.osnum); //debug

  if (tmp-MAX_ROW >= 0.5) MAX_ROW++;
  VLinitCnst(&cst);
  accept_button[0] = me->event1.event.button.x;
  accept_button[1] = me->event1.event.button.y;
  accept_button[2] = 0.0 ;
  //accept_button[2] = me->event1.event.button.z;
  win.objid = me->event1.event.button.objid;
  win.osnum = me->event1.event.button.osnum;

  /* check if the view, only top view can be used : TR179800257*/
  status= VLisWinTop( &loc_msg, win, &cst );
  if (!(status&loc_msg&1)) {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_BadPlc,time=IMMEDIATE,seconds=IMMEDIATE);
    goto quit;
  }
 
 
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
     //printf(" quitting  at line %d\n", __LINE__);//debug	
      goto quit;
    }
  }

  for (i=0,jj=0;i<me->nb_surf;i++)
  {
    MAC.objid  = NULL_OBJID;
    MAC.osnum  = me->ModuleInfo.md_id.osnum;

    if( me->setup_file[0] == '\0' ) strcpy( me->setup_file, "unwrap_setup");

    status = vl$place_unwrap_extract( msg        =  &loc_msg,
                                      plate      =  &me->surf[i],
                                      md_env     =  &me->ModuleInfo,
                                      cs_obj     =  refID.obj_id,
                                      options    =  me->options,
                                      setup_file =  me->setup_file,
				      unw_obj    =  &MAC 		);
    if (!(status&loc_msg&1)) {
      *sts = MY_ERROR;
      ex$message(msgnumb = VL_E_BadPlc);
      om$send( msg = message  NDnode.NDdelete(&(me->ModuleInfo) ),
                           targetid = MAC.objid,
                           targetos = MAC.osnum );

    }

    om$send( msg = message  GRgraphics.GRdelete(&status,&(me->ModuleInfo) ),
                           targetid = refID.obj_id.objid,
                           targetos = refID.obj_id.osnum );

    refID.obj_id.objid = NULL_OBJID;

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
        //printf(" quitting  at line %d\n", __LINE__);//debug	
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

  if( refID.obj_id.objid != NULL_OBJID )
  {
     om$send( msg = message  GRgraphics.GRdelete(&status,&(me->ModuleInfo) ),
                          targetid = refID.obj_id.objid,
                          targetos = refID.obj_id.osnum );
  }

  return OM_S_SUCCESS;
}/*VLgo_unwrap*/ 

method save_all (long *sts)
{
char	tmp[50];
int	i, code;
long	loc_msg, status;
FILE    *setup_file=NULL;

  *sts = MY_ERROR;

  FIg_get_text(me->status_display_form_ptr,G_FIBER_RATIO,tmp);
  sscanf(tmp,"%lf",&me->options[UNFOLD_ATT_IDX_FIB_RATIO]);
  om$send(msg = message VLunwextCmd.VLmodGlobals
                             (&loc_msg,NAM_G_FIB,
                              me->options[UNFOLD_ATT_IDX_FIB_RATIO]),
                    targetid = my_id);

  FIg_get_state(me->status_display_form_ptr,G_UNW_SURF, &i);
  me->options[UNFOLD_ATT_IDX_SRFWANTED]=i;
  status = om$send(msg = message VLunwextCmd.VLmodGlobals
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
  status = om$send(msg = message VLunwextCmd.VLmodGlobals
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
  else if (!strcmp(tmp,"Base-Flip"))
          me->options[UNFOLD_ATT_IDX_SIDE] = BASE_FLIP;
  else if (!strcmp(tmp,"Offset-Flip"))
          me->options[UNFOLD_ATT_IDX_SIDE] = OFFSET_FLIP;

  status = om$send(msg = message VLunwextCmd.VLmodGlobals
                             (&loc_msg,NAM_G_SIDE,
                              me->options[UNFOLD_ATT_IDX_SIDE]),
                    targetid = my_id);

  FIg_get_text(me->status_display_form_ptr,G_EXP_X_SCALE,tmp);
  sscanf(tmp,"%lf",&me->options[UNFOLD_ATT_IDX_X_EXPANSION]);
  status = om$send(msg = message VLunwextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_X_EXP,
                                me->options[UNFOLD_ATT_IDX_X_EXPANSION]),
                      targetid = my_id);

  FIg_get_text(me->status_display_form_ptr,G_EXP_Y_SCALE,tmp);
  sscanf(tmp,"%lf",&me->options[UNFOLD_ATT_IDX_Y_EXPANSION]);
  status = om$send(msg = message VLunwextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_Y_EXP,
                                me->options[UNFOLD_ATT_IDX_Y_EXPANSION]),
                      targetid = my_id);

  FIg_get_state(me->status_display_form_ptr,G_TESSELATION, &i);
  me->options[UNFOLD_ATT_IDX_TESSELATION] = i;
  status = om$send(msg = message VLunwextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_TESS,
                                me->options[UNFOLD_ATT_IDX_TESSELATION]),
                      targetid = my_id);

  for (i=0;i<UNWEXT_NB_OPT;i++)
  {
    if( i<UNWEXT_ATT_IDX_PARENT )
     	FIfld_get_select(me->status_display_form_ptr, G_LINES,
				i, 0, &me->optlines[i]);
    else
       FIfld_get_select(me->status_display_form_ptr, G_PRCOPT,
                        i-UNWEXT_ATT_IDX_PARENT, 0, &me->optlines[i]);
  }

  VLencode ( me->optlines, UNWEXT_NB_OPT, &code);
  me->options[UNFOLD_ATT_IDX_LINES] = code;
  om$send(msg = message VLunwextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_UNW_CODE,code),
                      targetid = my_id);

  FIg_get_state(me->status_display_form_ptr,G_WATONPLATE, &i);
  me->options[UNFOLD_ATT_IDX_WATONPLATE]=i;
  status = om$send(msg = message VLunwextCmd.VLmodGlobals
                             (&loc_msg,NAM_G_WATONPLATE,
                              me->options[UNFOLD_ATT_IDX_WATONPLATE]),
                    targetid = my_id);

  FIg_get_text(me->status_display_form_ptr, 16,tmp);
  if( setup_file = VLunwOpenSetupFilex( tmp, NULL ) )
  {
     strcpy( me->setup_file, tmp );
     fclose( setup_file );
     setup_file = NULL;
  }
  else if( !strlen(tmp) ) strcpy( me->setup_file, tmp );
  else
  {
     FIg_set_text(me->status_display_form_ptr, FI_MSG_FIELD, 
		  "Invalid Setup File");
     *sts = MY_ERROR;
     return OM_E_INVARG;
  }

  *sts = MSSUCC;

  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
OMuword TEMP_cl;
int	suc,i,db_type;
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
      status = om$send(msg = message VLunwextCmd.save_all(&me->ret),
                    targetid = my_id);

      if (!(status&1)) me->ret=MY_ERROR;
      else
      {
        om$send ( msg = message CEO.erase_form_by_label
                                     ( STATUS_FORM, 0, &suc),
                    targetid = my_id);
      }
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
        if (strcmp(type,"Global Expansion")== 0) {
          FIg_erase(me->status_display_form_ptr,G_EXP_X_UNIT_mm);
          FIg_erase(me->status_display_form_ptr,G_EXP_Y_UNIT_mm);
          FIg_erase(me->status_display_form_ptr,G_EXP_X_UNIT_in);
          FIg_erase(me->status_display_form_ptr,G_EXP_Y_UNIT_in);
          FIg_display(me->status_display_form_ptr,G_EXP_X_PCENT);
          FIg_display(me->status_display_form_ptr,G_EXP_Y_PCENT);
        }
        else {
          status = co$unit_database_type( osnum   = me->ModuleInfo.md_id.osnum ,
                                          db_type = &db_type );
          if (!(status&1)) goto quit;
          if ( db_type == GRIO_UNITS_ARE_ENGLISH ) {
             FIg_erase(me->status_display_form_ptr,G_EXP_X_PCENT);
             FIg_erase(me->status_display_form_ptr,G_EXP_Y_PCENT);
             FIg_erase(me->status_display_form_ptr,G_EXP_X_UNIT_mm);
             FIg_erase(me->status_display_form_ptr,G_EXP_Y_UNIT_mm);
             FIg_display(me->status_display_form_ptr,G_EXP_X_UNIT_in);
             FIg_display(me->status_display_form_ptr,G_EXP_Y_UNIT_in);
          }
          else {
             FIg_erase(me->status_display_form_ptr,G_EXP_X_PCENT);
             FIg_erase(me->status_display_form_ptr,G_EXP_Y_PCENT);
             FIg_erase(me->status_display_form_ptr,G_EXP_X_UNIT_in);
             FIg_erase(me->status_display_form_ptr,G_EXP_Y_UNIT_in);
             FIg_display(me->status_display_form_ptr,G_EXP_X_UNIT_mm);
             FIg_display(me->status_display_form_ptr,G_EXP_Y_UNIT_mm);
          }
        }
      }
      else {
        FIg_erase(me->status_display_form_ptr,G_EXP_X_SCALE);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_SCALE);
        FIg_erase(me->status_display_form_ptr,G_EXP_X_TEXT);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_TEXT);
        FIg_erase(me->status_display_form_ptr,G_EXP_X_PCENT);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_PCENT);
        FIg_erase(me->status_display_form_ptr,G_EXP_X_UNIT_in);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_UNIT_in);
        FIg_erase(me->status_display_form_ptr,G_EXP_X_UNIT_mm);
        FIg_erase(me->status_display_form_ptr,G_EXP_Y_UNIT_mm);
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
           } // If it is a plate.
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

end implementation VLunwextCmd;
