class implementation VLstfBenCmd;

#include	<stdio.h>
#include	<math.h>
#include	"vlprototype.h"
#include	"msdef.h"
#include	"AS_status.h"
#include	"griodef.h"
#include	"vlmsg.h"
#include	"expmacros.h"
#include	"expression.h"
#include	"DIdef.h"
#include	"DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "DImacros.h"
#include	"nddef.h"
#include	"coparamac.h"
#include	"igr.h"
#include	"grmacros.h"
#include	"OMtypes.h"
#include	"ms.h"
#include	"msmacros.h"
#include	"bsvalues.h"
#include	"VDSpathdef.h"
#include	"VDSudp_mac.h"
#include	"dp.h"

#include	"vsmiscmacros.h"
#include	"vsedgedef.h"
#include	"vsedgemacros.h"
#include	"vsplatedef.h"

#include	"vlglobals.h"
#include	"vlstifbend.h"
#include	"vluserkey.h"
#include	"vlmiscmacros.h"

from	VSstfBeam	import  VSgetSupports;
from	GRcurve		import  GRendpts;
from	NDnode		import  NDchg_state;
from	IGEgragad	import  DPinrot;
from	GRgraphics	import  GRdelete;
from	GRgraphics	import  GRgetname;

extern	GRclassid	OPP_VLstifBend_class_id;
extern                  ASget_as_owner();
#define MY_ERROR        530
#define IMMEDIATE       0
#define RIGHT           543


/* find the longer axis of all stiffners */
VLfind_longer_stiff (stiff,nb,len)
struct GRobj_env        *stiff; /*I : list of stiffners		*/
IGRint                  nb;     /*I : number of stiffners	*/
IGRdouble               *len;   /*O : Obtained Length		*/
{
IGRlong                 msg,sts,loc_sts;
int			count,i;
VSsuppList		supports;
IGRpoint		startpt,endpt;
double			tmp;

  msg = 0;
  *len = 0;
  for (i=0;i<nb;i++)
  {
                              // get stiffner axis
      sts = om$send ( msg =  message VSstfBeam.VSgetSupports (
                                                &loc_sts,
                                                &(stiff[i].mod_env),
                                                &count,
                                                supports),
                      targetid        = stiff[i].obj_id.objid,
                      targetos        = stiff[i].obj_id.osnum,
                      senderid        = NULL_OBJID );
      if (!(sts&loc_sts&1)) {
        goto quit;
      }
      sts = om$send ( msg =  message GRcurve.GRendpts (
                                        &loc_sts,
                                        &supports[1].mod_env.md_env.matrix_type,
                                        supports[1].mod_env.md_env.matrix,
                                        startpt,endpt),
                      targetid        = supports[1].obj_id.objid,
                      targetos        = supports[1].obj_id.osnum,
                      senderid        = NULL_OBJID );
      if (!(sts&loc_sts&1)) {
        goto quit;
      }
                        // get length
      tmp = (endpt[0] - startpt[0])*(endpt[0] - startpt[0]) +
                 (endpt[1] - startpt[1])*(endpt[1] - startpt[1]) +
                 (endpt[2] - startpt[2])*(endpt[2] - startpt[2]);
      if (*len < tmp) *len = tmp;
  }
  *len = 1.3*sqrt(*len);
  msg = 1;
quit :
  return msg;
}

/* get stiffners */
method VLcontrol_stiff (long *sts)
{
struct GRobj_env	*LocatedObjects;
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
    for (j=0; j<me->nb_stiff;j++)
    {
      if (me->stiff[j].obj_id.objid == LocatedObjects[i].obj_id.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }

  if (nb_supprim)
    ex$message(msgnumb = VL_E_ObjInList,time=IMMEDIATE,seconds=IMMEDIATE);
  if(nb_obj - nb_supprim + me->nb_stiff >
                                om$dimension_of( varray = me->stiff)) {
    om$vla_set_dimension(varray = me->stiff,size =
                                      nb_obj-nb_supprim+me->nb_stiff);
  }
  
  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    me->stiff[i+me->nb_stiff] = LocatedObjects[i];
  }
  me->nb_stiff += nb_obj - nb_supprim;

quit :
  return OM_S_SUCCESS;
}

/* ************************************************************************** */
/* Create coordinate system and place <stifBend> macro for each stiffener     */
/* ************************************************************************** */
method VLinverse (IGRlong	*sts)
{
		IGRdouble	accept_button[4], winMat[20], viewMat[16];
		IGRlong		status;
		IGRint		i, jj, max_row, i0, i1, i2;
	struct	GRvg_construct  cst;
	struct	GRid		win, tpl_id[MACRO_SB_VFEET];
	struct	GRobj_env	refID;
		IGRdouble 	vect[4], tmp, len=0;
        enum    GRdpmode        dpmode=GRbd;
        struct  GRid		mac;
                char            name[DI_PATH_MAX],word[DI_PATH_MAX];

	/* Initialize */
  	tmp = sqrt ((IGRdouble) me->nb_stiff);
  	max_row = tmp;
  	if (tmp - max_row >= 0.5) max_row++;

  	VLinitCnst(&cst);
  	accept_button[0] = me->event1.event.button.x;
  	accept_button[1] = me->event1.event.button.y;
  	accept_button[2] = me->event1.event.button.z;
  	win.objid = me->event1.event.button.objid;
  	win.osnum = me->event1.event.button.osnum;

	/* Create the next coordinate system */
      	status = VLcreWinRef ( accept_button, win, TRUE, &cst, FALSE, winMat,
			       &refID, sts );
      	if (!(status&(*sts)&1)) {
       		me->ret = *sts = MY_ERROR;
       		ex$message (msgnumb = VL_E_BadPlc);
       		goto quit;
      	}

	/* Set coordinate system state to support only */
        status = om$send ( msg = message NDnode.NDchg_state
					( ND_SUP_ONLY, ND_SUP_ONLY ),
			   targetid = refID.obj_id.objid,
			   targetos = refID.obj_id.osnum   );
        as$status ( msg    = "NDnode.NDchg_state",
                    test   = (!(status & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = quit );

	/* Get view matrix */
  	status = om$send ( msg = message IGEgragad.DPinrot ( sts, viewMat),
                           targetid = win.objid,
                           targetos = win.osnum );
  	if (!(status&(*sts)&1)) {
    		me->ret = *sts = MY_ERROR;
    		ex$message (msgnumb = VL_E_BadPlc);
    		goto quit;
  	}

  	if (viewMat[0] != 0.0) {
    		i0 = 0;
    		if (viewMat[5] != 0.0)	{ i1 = 1; i2 = 2; }
    		else 			{ i1 = 2; i2 = 1; }
  	}
  	else { i0 = 1; i1 = 2; i2 = 0; }
  	vect[i2] = accept_button[i2];

	/* Find the maximum length of the stiffeners */
  	if (me->nb_stiff > 1) {
    		if(!VLfind_longer_stiff ( me->stiff, me->nb_stiff, &len) ) {
      			me->ret = *sts = MY_ERROR;
      			ex$message (msgnumb = VL_E_BadPlc);
      			goto quit;
    		}
  	}

	/* Set fix templates */
        if (me->web == RIGHT) tpl_id[IDX_SBT_SIDX] = me->webR;
        else tpl_id[IDX_SBT_SIDX] = me->webL;

  	for (i=0,jj=0;i<me->nb_stiff;i++) {

		/* Set coordinate system template */
  		tpl_id[IDX_SBT_CSYS] = refID.obj_id;

		/* Make source of located stiffener */
  		as$make_source ( go_grid = me->stiff[i].obj_id,
                    		 mod_env = &me->stiff[i].mod_env,
                    		 as_os   = me->Current.md_id.osnum ,
                    		 as_grid = &tpl_id[IDX_SBT_BSRF] );

		/* Construct, place, name & change state of a VLstifBend */
		status =
		vl$placeLoftMacro ( msg		= sts,
				    classid	= OPP_VLstifBend_class_id,
				    MacName	= MACRO_STFBEND,
				    number	= MACRO_SB_FTEMP,
				    template	= tpl_id,
				    Env		= &me->Current,
				    MatchKey	= STIFF_BEND_KEY,
				    CobName	= "VLstfBenCmd",
				    mode	= OM_e_wrt_parent,
				    MatchId	= &tpl_id[IDX_SBT_BSRF],
				    CommonName	= STFBEND_NAME,
				    CobMyId	= my_id,
                                    occ_id      = &mac );
                if (!(status & 0x00000001 & (*sts)) || mac.objid == NULL_OBJID){
                     om$send( msg      = message GRgraphics.GRdelete
                                              ( sts, &me->Current),
                               targetid = refID.obj_id.objid,
                               targetos = refID.obj_id.osnum);
                }
                else {
                  status = om$send(msg = message GRgraphics.GRgetname( sts,
                                                                     name ),
                       targetid = mac.objid,
                       targetos = mac.osnum ) ;
                  if (status&1&(*sts)) 
                    sprintf(word,"cs%s",&name[strlen(name)-2]);
                  else
                    sprintf(word,"cs%d",i);
                
                  status = om$send(msg = message VLstfBenCmd.VLsetSymbNameDisp(
                                                sts,
                                                word,
                                                STIFF_BEND_KEY,
                                                &tpl_id[IDX_SBT_BSRF],
                                                refID.obj_id,
                                                &dpmode),
                        targetid = my_id );
                  if(!(status & *sts & 1))
                    ex$message(msgnumb = VL_E_BadChgName);
                }

		/* compute new position for the next placement */
		if (i < me->nb_stiff-1) {
			if (jj<max_row-1) {
				vect[i1] = accept_button[i1] + (jj+1)*len;
				vect[i0] = accept_button[i0];
				jj++;
			}
			else {	accept_button[i0] += len;
				vect[i1] = accept_button[i1];
				vect[i0] = accept_button[i0];
				jj = 0;
			}

			/* Create the next coordinate system */
      			status = VLcreWinRef ( vect, win, TRUE, &cst, FALSE,
					       winMat, &refID, sts );
      			if (!(status&(*sts)&1)) {
        			me->ret = *sts = MY_ERROR;
        			ex$message (msgnumb = VL_E_BadPlc);
        			goto quit;
			}

			/* Set coordinate system state to support only */
       		 	status = om$send ( msg = message NDnode.NDchg_state
						( ND_SUP_ONLY, ND_SUP_ONLY ),
					   targetid = refID.obj_id.objid,
					   targetos = refID.obj_id.osnum   );
		        as$status ( msg    = "NDnode.NDchg_state",
		                    test   = (!(status & 0x00000001)),
		                    action = GOTO_VALUE,
		                    value  = quit );
    		}
  	}

  	me->nb_stiff = 0;
quit :
  	return OM_S_SUCCESS;
}

end implementation VLstfBenCmd;
