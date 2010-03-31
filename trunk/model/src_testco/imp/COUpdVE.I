class implementation COUpdVE;

/**************************************************************************

DESCRIPTION : 

 This is the command object for Update Visible Edges functionality

 CR Update Visible Edges

HISTORY 

 16/7/97 Creation  Sp.Balamurugan and T.Ashok kumar 
 
 28/11/97 Added delete method -Ashok

 17/12/87 Modified for TR# 119702197 -Ashok 
**************************************************************************/

#include <stdio.h>
#include "FI.h"
#include <stdlib.h>
#include <string.h>
#include <alloca.h>
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"
#include "grmessage.h"
#include "grmacros.h"
#include "lcmacros.h"
#include "griomacros.h"
#include "grerr.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "ECcmd.h"
#include "grmsg.h"
#include "ECmsg.h"
#include "emserr.h"
#include "omac.h"
#include "VEcheform.h"
#include "veerr.h"
#include "vemsg.h"
#include "vewinmacros.h"
#include "vedpbmacros.h"
#include "bs.h"
#include "bsparameters.h"
#include "hsdef.h"
#include "comndef.h"

#define TRUE 1
#define FALSE 0

/* imports */

from GRgraphics import  GRdelete,GRdisplay;
from NDnode     import NDdisconnect;
from GRvg       import GRchgprops;
from VEgragad   import VEprocess, VEsubmit_batch;
from GRgrset	import GSobject_add;

/* externs */

extern OMuword OPP_GRdrawview_class_id;
extern OMuword OPP_GRgrset_class_id;
extern OMuword OPP_GRsvset_class_id;
extern OMuword OPP_GRgraphics_class_id;
extern OMuword OPP_GRowner_class_id;
extern OMuword OPP_GRfcset_class_id;
extern OMuword OPP_GRdvattach_class_id;
extern OMuword OPP_GRreffile_class_id;
extern VEprocess_fence();

%safe
static IGRint state,disp,mflg,fenflg;
static struct GRid view,visid,refid,my_fence_id;
static struct GRmd_env mod,ved_env;
%endsafe

/*
 * This is for reference.
 *
 * Sequence for locating different elements.
 * 1. locate the drawing view to make its locatability off. 
 * 2. locate the solid on which we have run create visible edges. 
 * 3. locate the outdated visible edges (ie the edges to be deleted)
      Use only Elements clipped inside fence from pocket menu.
 */

method init(int type; char *str_ptr)
{
    IGRint status;
    /*
    * Initialise my parent stuff
    */
    fenflg=0;
     status = om$send(msg = message super_cmd.init(type, str_ptr),
               mode = OM_e_wrt_message,
               targetid = my_id);
     state = 0;
     disp = 0;
    return(OM_S_SUCCESS);
} /* init */


method wakeup(int pos)
{
    IGRint status;
    ex$message(msgnumb = EM_M_UpdVE);
    status = om$send( msg = message super_cmd.wakeup(pos),
                      mode = OM_e_wrt_message,
                     targetid = my_id);
    return(OM_S_SUCCESS);
}/* wakeup */

method delete(int f_defer_flag)
{
 IGRlong msg;
 IGRint sts = OM_S_SUCCESS;
 enum GRdpmode  mode;
 IGRshort set,property; 

 if(mflg == 1)
	{
   property = GRIS_LOCATABLE;
        set=1;

        sts = om$send( msg = message GRvg.GRchgprops(&msg,&set,&property),
                        senderid = my_id,
                        targetid = view.objid,
                        targetos = view.osnum);
        mode = GRheo;
        sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid = view.objid,
                     targetos = view.osnum);
	mflg = 0;
	}
return(OM_S_SUCCESS);
}
 
method execute(int *response; char *response_data; int pos)
{
    /* general variables declaration */	
   IGRlong msg,rc;
   IGRint status, sts=OM_S_SUCCESS,i,k,flag=0;
   IGRchar  locate_prompt[100], accept_prompt[52], relocate_prompt[52];
   IGRchar  gslocate_spec_prompt[52];
   IGRlong  locate_mask, accept_mask,gslocate_spec_mask;
   IGRlong  object_was_located, display_flag;
   struct GRlc_locate  attributes;
   OM_S_CLASSLIST  rtree_classes,elig_classes;
   OMuword  rclass, eliclass[2], accept_classid[2],classid;
   struct GRid my_GRid,tmpid,disid;
   IGRlong size;
   struct GRmd_env module_env;
   enum GRdpmode  mode;
   IGRshort set;
   IGRshort property;
   IGRint inp = 0 ,mesg,batch_mode,env_properties;
   OMuint num_vedgs,num_chans,num_dchans ,num_dvobjs,num_robjs;
   OM_S_OBJECT_LINKAGE       *f_ids , *c_id,*d_id , *r_id,*ref_ids;
   IGRuint num_objects,j,num_cobjs,num_dobjs, num_dvs,num_refs;
   OM_S_CHANSELECT to_cmpnt_chansel,to_sets ,to_dv,to_ref;
   IGRlong  stat;
   unsigned short properties;
   int respons;
   IGRchar command_key[30];
  
/* select the drawing view to make its locatability off */

do
 {
/* state is being intialised in init method */
   switch(state)
	{
      case 0:
   display_flag = ALL_WINDOWS | ELEM_HILIGHT| NO_PROJ_ACCEPT_POINT | 
		  ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | 
		   LC_ERASE_ALL | LC_ACCEPT_CURSOR;
   locate_mask = GRm_DATA|GRm_OBJID| GRm_TEXT_VALUE;
   accept_mask = GRm_DATA|GRm_OBJID | GRm_TEXT_VALUE;
   strcpy(locate_prompt,"Locate Drawing  View ");
   strcpy(accept_prompt,"Accept/Reject");
   strcpy(relocate_prompt,"Drawing View Not Found");
 
   attributes.properties = LC_LC_ONLY | LC_DP_INVIS|LC_NEW_MOD|
			   LC_PLANAR_NON_PLANAR|LC_RW;
 
   attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_OWNER | LC_FLEX_COMP | 
                             LC_RIGID_COMP; 
 
   strcpy(attributes.classes, "GRdrawview");
 
   elig_classes.w_count = 1;
   elig_classes.w_flags = OM_CLST_subclass;
   eliclass[0] = OPP_GRdrawview_class_id;
   elig_classes.p_classes = eliclass;
   rtree_classes.w_count = 1;
   rtree_classes.w_flags = OM_CLST_subclass;
   rclass = OPP_GRdrawview_class_id;
   rtree_classes.p_classes = &rclass;
   accept_classid[0] = OPP_GRdrawview_class_id;
   size = sizeof(struct GRevent);
   status = lc$locate(rc = &object_was_located,
                event1 = &me->locate_event,
                event2 = &me->acc_event,
                eventsize = &size,
                mask1 = locate_mask,
                mask2 = accept_mask,
                display_flag = display_flag,
                response = response,
                response_data = response_data,
                locate_prompt = locate_prompt,
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt,
                attributes = &attributes,
                stack = &me->locate_stack,
                rtree_classes = &rtree_classes,
                eligible_classes = &elig_classes);

	ex$message(msgnumb = EMS_P_ClearPromptField)
       ex$message(msgnumb = EMS_S_ClearStatusField)
   if (object_was_located)
   {
	switch(me->acc_event.response)
         {
           case EX_DATA:
       view.objid = me->acc_event.located_object[0].located_obj.objid;
       view.osnum = me->acc_event.located_object[0].located_obj.osnum;

	/* the variable view which is assigned is used later */

	status = gr$get_module_env(buffer = &mod);
	mode = GRheo;/* erase the highlighte display */
        sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid = view.objid,
                     targetos = view.osnum);
	/* Make the display on of the solid which is made off while running 
	   create visible edges */
	
	/* get the chanel object i.e the ref object */ 
	
	status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_dv);

        status = om$get_channel_count( objid = view.objid,
                                        osnum = view.osnum,
                                        p_chanselect = &to_dv,
                                        count = &num_dvs);

         r_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_dvs);

          status = om$get_channel_objects(objid = view.objid,
                                          osnum =view.osnum,
                                          p_chanselect = &to_dv,
                                          list = r_id,
                                          size = num_dvs,
                                          count = &num_dvobjs);
          for(i=0;i<num_dvs;i++)
                {
             status = om$get_classid(osnum = r_id[i].osnum,
                                     objid = r_id[i].S_objid,
                                     p_classid = &classid);
        if(classid == OPP_GRdvattach_class_id)
	{
         status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_ref);

        status = om$get_channel_count( objid = r_id[i].S_objid,
                                       osnum = r_id[i].osnum,
                                        p_chanselect = &to_ref,
                                        count = &num_refs);

         ref_ids = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_refs);

          status = om$get_channel_objects(objid = r_id[i].S_objid,
                                          osnum = r_id[i].osnum,
                                          p_chanselect = &to_ref,
                                          list = ref_ids,
                                          size = num_refs,
                                          count = &num_robjs);
          for(j=0;j<num_refs;j++)
          {
             status = om$get_classid(osnum = ref_ids[j].osnum,
                                     objid = ref_ids[j].S_objid,
                                        p_classid = &classid);
	  disid.objid = ref_ids[j].S_objid;
	  disid.osnum =  ref_ids[j].osnum;
	if(classid == OPP_GRreffile_class_id)

        {
	/* get the geometric properties of the object and set the disp flag*/

	sts =gr$get_properties(object_id=&disid,
				properties_mask = &properties);

	if (properties & GRIS_DISPLAYABLE) disp = 1;
	else
	{
        property = GRIS_DISPLAYABLE;
        set=1;

        sts = om$send( msg = message GRvg.GRchgprops(&msg,&set,&property),
                        senderid = my_id,
                        targetid = ref_ids[j].S_objid,
                        targetos = ref_ids[j].osnum);

                refid.objid =  ref_ids[j].S_objid;
                refid.osnum = ref_ids[j].osnum;
		mode = GRbd;
                sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid =ref_ids[j].S_objid,
                     targetos =ref_ids[j].osnum);
	}
        }
       }
     }
    }	
   state = 1;
   break;
 case EX_BACK_UP:
	state = 0;
	break;
   }
 }
    else
     if ( *response == CLEAR_STACK ||
          *response == EX_BACK_UP)
     {
	state =0;
         return(OM_S_SUCCESS);
     }
    else
         if (*response == EX_CMD_KEY)
         {
	 return(OM_S_SUCCESS);
         }
     else
        if (*response == TERMINATE)
           {
	   return(OM_S_SUCCESS);
           }
	else goto wrapup;
	break ;

	/* Locate the solid object to run create visible edges*/

	case 1:
   display_flag = ALL_WINDOWS | ELEM_HILIGHT| NO_PROJ_ACCEPT_POINT |
                  ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                   LC_ERASE_ALL | LC_ACCEPT_CURSOR;
   locate_mask = GRm_DATA|GRm_OBJID| GRm_TEXT_VALUE;
   accept_mask = GRm_DATA|GRm_OBJID | GRm_TEXT_VALUE;

   strcpy(locate_prompt,"Identify Solid/Surface to update");
   strcpy(accept_prompt,"Accept/Reject");
   strcpy(relocate_prompt,"Element Not Found");

   attributes.properties = LC_LC_ONLY | LC_DP_INVIS|LC_NEW_MOD|
                            LC_PLANAR_NON_PLANAR|LC_RW;

   attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_OWNER | LC_FLEX_COMP |
                              LC_REF_OBJECTS| LC_RIGID_COMP;

   strcpy(attributes.classes, "GRgraphics");

   elig_classes.w_count = 1;
   elig_classes.w_flags = OM_CLST_subclass;
   eliclass[0] = OPP_GRgraphics_class_id;
   elig_classes.p_classes = eliclass;
   rtree_classes.w_count = 1;
   rtree_classes.w_flags = OM_CLST_subclass;
   rclass = OPP_GRgraphics_class_id;
   rtree_classes.p_classes = &rclass;
   accept_classid[0] = OPP_GRgraphics_class_id;
   size = sizeof(struct GRevent);
   status = lc$locate(rc = &object_was_located,
                event1 = &me->locate_event,
                event2 = &me->acc_event,
                eventsize = &size,
                mask1 = locate_mask,
                mask2 = accept_mask,
                display_flag = display_flag,
                response = response,
                response_data = response_data,
                locate_prompt = locate_prompt,
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt,
                attributes = &attributes,
                stack = &me->locate_stack,
                rtree_classes = &rtree_classes,
                eligible_classes = &elig_classes);
	ex$message(msgnumb = EMS_P_ClearPromptField)
       ex$message(msgnumb = EMS_S_ClearStatusField)

   if (object_was_located)
   {
	switch(me->acc_event.response)
        {
          case EX_DATA:
       visid.objid = me->acc_event.located_object[0].located_obj.objid;
       visid.osnum = me->acc_event.located_object[0].located_obj.osnum;
       ved_env = me->acc_event.located_object[0].module_info;

	/* turn off the locatability of the drawing view by using the varaible
           view which was assigned previously */

        property = GRIS_LOCATABLE;
        set=0;

        sts = om$send( msg = message GRvg.GRchgprops(&msg,&set,&property),
                        senderid = my_id,
                        targetid = view.objid,
                        targetos = view.osnum);
        mode = GRheo;
        sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid = view.objid,
                     targetos = view.osnum);

        state =2;	
        break;
   
   case EX_BACK_UP:
	state = 1;
	break;
	}
    }
    else
     if ( *response == CLEAR_STACK ||
          *response == EX_BACK_UP)
     {
	state = 0;
         return(OM_S_SUCCESS);
     }
    else
         if (*response == EX_CMD_KEY)
         {
            return(OM_S_SUCCESS);
         }
     else
        if (*response == TERMINATE)
           {
              return(OM_S_SUCCESS);
           }
     else goto wrapup;
    break;
	
	/* Locate the outdated visible edges thru Elments Clipped Inside Fence             in the pocket menu */  


	case 2 :
	my_fence_id.objid = NULL_OBJID;
	 status = om$make_chanselect( channame = "CEO_LOCATE.located_graphics",
                                p_chanselect = &me->located_chansel);

   display_flag =  ALL_WINDOWS | ELEM_HILIGHT | LC_ACCEPT_CURSOR ;
   locate_mask = GRm_OBJID | GRm_DATA | GRm_TEXT_VALUE;
   accept_mask =  GRm_DATA |GRm_OBJID | GRm_TEXT_VALUE; 
   gslocate_spec_mask =  GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE;

   strcpy(locate_prompt,"Identify outdated edges[elements clipped inside fence]");
   strcpy(accept_prompt,"Accept/Reject");
   strcpy(relocate_prompt,"Element(s) Not Found");
   strcpy(gslocate_spec_prompt,"Accept With the Group/Reject"); 

   attributes.properties = DELETE_LC_PROPS | LC_RW;

   attributes.owner_action =  DELETE_LC_OWNER | LC_DELETE_CMD|LC_REF_OBJECTS;

    strcpy(attributes.classes, "GRgraphics");

   elig_classes.w_count = 1;
   elig_classes.w_flags = OM_CLST_subclass;
   eliclass[0] = OPP_GRgraphics_class_id;
   elig_classes.p_classes = eliclass;

   rtree_classes.w_count = 1;
   rtree_classes.w_flags = OM_CLST_subclass;
   rclass = OPP_GRgraphics_class_id;
   rtree_classes.p_classes = &rclass;

   accept_classid[0] = OPP_GRgraphics_class_id;

   size = sizeof(struct GRevent);

   status = gr$gsget_fence(msg = &msg , fence_id = &my_fence_id);

        if(my_fence_id.objid ==NULL_OBJID && fenflg!=1)
	{
        ex$message( justification =2,
                        msgnumb = GR_F_NoActFncDfn  );
	fenflg = 1;
   
	}
   status = gr$gslocate(msg = &msg,
                event1 = &me->locate_event,
                event2 = &me->acc_event,
		locate_event = &me->sp_event,
                eventsize = &size,
                mask1 = locate_mask,
                mask2 = accept_mask,
		input1_mask = gslocate_spec_mask,
                display_flag = display_flag,
                response = response,
                response_data = response_data,
                locate_prompt = locate_prompt,
                acc_prompt = accept_prompt,
		input1_prompt = gslocate_spec_prompt,
                relocate_prompt = relocate_prompt,
                attributes = &attributes,
		num_inputs = 0,
		locate_state = &inp,
                stack = &me->locate_stack,
                rtree_classes = &rtree_classes,
                eligible_classes = &elig_classes,
		senderid = my_id,
                senderos = OM_Gw_current_OS,
		p_chanselect = &me->located_chansel);

	if(*response == EX_RJT_MOVEON) 
	{
	 /* code added for TR# 119702197 Ashok */ 

	 if(my_fence_id.objid !=NULL_OBJID)
	  {
           size = strlen( me->gragad_name ) + 1;
           respons = EX_STRING;

           ex$putque( msg = &msg,
                      response = &respons,
                      byte = &size,
                      buffer = me->gragad_name );

           strcpy( command_key, "GRSlEClInF" );
           size = strlen( command_key ) + 1;
           respons = EX_CMD_KEY;

           ex$putque( msg = &msg,
                      response = &respons,
                      byte = &size,
                      buffer =  command_key );
	  }
	else
	  ex$message( justification =2,
                        msgnumb = GR_F_NoActFncDfn  );	  
	}
    if(*response == EX_OBJID || *response == EX_STRING|| *response == EX_DATA)
              {

	/* get the channel objects that are located using gslocate */
	
	status = gr$gspost_processing ( msg = &stat,
                         p_chanselect = &me->located_chansel);
      /*the above macro is used to get the required clipping of the elements */

	status = om$get_channel_count( objid = my_id,
                                        p_chanselect = &me->located_chansel,
		                        count = &num_chans);

	 c_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_chans);

          status = om$get_channel_objects(objid = my_id,
                                          p_chanselect = &me->located_chansel,
                                          list = c_id,
                                          size = num_chans,
                                          count = &num_cobjs);
		for(k=0;k<num_chans;k++)
	        {

             status = om$get_classid(osnum = c_id[k].osnum,
                                     objid = c_id[k].S_objid,
                                     p_classid = &classid);
            if(classid == OPP_GRfcset_class_id)
            {
	status = om$make_chanselect(channame = "GRgrset.to_sets",
                                    p_chanselect = &to_sets);
	flag = 1;/*  set flag for elements clipped inside fence */
		goto start;
	    }
	
	    if((classid == OPP_GRgrset_class_id)&&(flag==1))
		{/* for elements clipped inside fence */
	status = om$make_chanselect(channame = "GRfcset.clip_overlap",
                                    p_chanselect = &to_sets);
	goto start;
		}
	else { /* for elements inside fence */
		status = om$make_chanselect(channame = "GRgrset.to_sets",
                                    p_chanselect = &to_sets);
	start:

	status = om$get_channel_count( objid = c_id[k].S_objid,
					osnum = c_id[k].osnum,
                                        p_chanselect = &to_sets,
                                        count = &num_dchans);

         d_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_dchans);

          status = om$get_channel_objects(objid = c_id[k].S_objid,
					  osnum = c_id[k].osnum,
                                          p_chanselect = &to_sets,
                                          list = d_id,
                                          size = num_dchans,
                                          count = &num_dobjs);
	  for(i=0;i<num_dchans;i++)
		{
             status = om$get_classid(osnum = d_id[i].osnum,
                                     objid = d_id[i].S_objid,
                                     p_classid = &classid);

	 if(classid == OPP_GRsvset_class_id)
            {
	 status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_cmpnt_chansel);

	status = om$get_channel_count( objid = d_id[i].S_objid,
				       osnum = d_id[i].osnum, 
                                        p_chanselect = &to_cmpnt_chansel,
                                        count = &num_vedgs);

         f_ids = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_vedgs);

          status = om$get_channel_objects(objid = d_id[i].S_objid,
					  osnum = d_id[i].osnum,
                                          p_chanselect = &to_cmpnt_chansel,
                                          list = f_ids,
                                          size = num_vedgs,
                                          count = &num_objects);
          for(j=0;j<num_vedgs;j++)
          {
             status = om$get_classid(osnum = f_ids[j].osnum,
                                     objid = f_ids[j].S_objid,
                                     p_classid = &classid);	
	
	if(om$is_ancestry_valid(subclassid = classid,
                               superclassname = "GRgraphics") == OM_S_SUCCESS)
            {
		status = gr$get_module_env(buffer = &module_env);

	if(om$is_ancestry_valid(subclassid = classid,
                               superclassname = "DMdim")==OM_S_SUCCESS)continue;

	   if(f_ids[j].S_objid==my_fence_id.objid) continue;


	  	/* disconnect the channel connection */

              status = om$send(msg = message NDnode.NDdisconnect(0, NULL),
                               targetid =f_ids[j].S_objid,
                               targetos =f_ids[j].osnum);

              mode = GRbehe;/* erase the highlighted */   
              om$send(msg = message GRgraphics.GRdisplay(&msg,
	                &module_env.md_env.matrix_type,
                                    module_env.md_env.matrix,&mode,
                                         &module_env.md_id),
                      targetid = f_ids[j].S_objid,
                      targetos = f_ids[j].osnum);
	
		/* delete the object */

              status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                                                 &module_env), 
             		          targetid =f_ids[j].S_objid,
                      		  targetos =f_ids[j].osnum);
		}
             }
          }
	}
     }
    }
	/* turn on the locatablity which was previously made off */
	property = GRIS_LOCATABLE;
          set = 1;
        mode = GRhdo;
        sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid = view.objid,
                     targetos = view.osnum);

        sts = om$send( msg = message GRvg.GRchgprops(&msg,&set,&property),
                        senderid = my_id,
                        targetid = view.objid,
                        targetos = view.osnum);

        mode = GRheo;
        sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid = view.objid,
                     targetos = view.osnum);

		env_properties = 0;
		tmpid.objid = my_id;
		tmpid.osnum = OM_Gw_current_OS;

	sts = gr$gsempty ( msg = &msg,
			   senderid = my_id,
			   senderos = OM_Gw_current_OS,
			   p_chanselect = &me->located_chansel);

	/* add the solid object which was located to the located_chansel */

	sts = GRgsadd_object(&msg,&visid,&ved_env,
                             &env_properties,&tmpid,&me->located_chansel);

	/* Create Visible Edges Code Starts here */

	me->mytype = 0;	
	
	 BSxtractpar( &rc, BSTOLCHRDHT, &me->cht );

        sts = om$send( targetid = my_id,
                      msg = message VEedgescmds.read_or_set_dpb_data(&mesg,0));

        if ( me->mytype == 0 )

           me->hs_vhl_flags |= HS_VHL_HIDING;
        else
           me->hs_vhl_flags &= ~HS_VHL_HIDING;
	
	if (me->hs_vhl_flags & HS_VHL_CLIP_TO_FENCE );
	else
	 me->hs_vhl_flags^=HS_VHL_CLIP_TO_FENCE ;

	  VEprocess_fence(my_id);

	   me->gragad.objid = me->locate_event.event.button.objid;
	   me->gragad.osnum = me->locate_event.event.button.osnum;

	batch_mode = 0;
	my_GRid.objid =my_id;
        my_GRid.osnum = OM_Gw_current_OS;

        if ( batch_mode )
           {
           /* running HVHL in batch */
           sts = om$send( msg=message VEgragad.VEprocess( &mesg,
                                                           &my_GRid,
                                                           &me->located_chansel,
                                                           batch_mode,
                                                           FALSE ),
                           targetid = me->gragad.objid,
                           targetos = me->gragad.osnum );

              OM_ERRCHK( sts, "VEedgescmds: VEgragad.VEprocess send failed" );
           }
        else if ( ((me->hs_vhl_flags & HS_VHL_RESOLUTION) == HS_VHL_HIGH_RES) ||                    (me->mytype == 1) )
           {
           /* running high resolution VHL or Create Projected Edges */

     sts=om$send( msg = message VEedgescmds.get_background_confirmation(&msg),                    targetid = my_id );

           if ( msg != OM_S_SUCCESS )

              return( OM_S_SUCCESS ); 

           ve$make_win_ve( msg = (IGRlong *)&mesg,
                           win_id = me->gragad.objid,
                           win_os = me->gragad.osnum );

           /* clear the prompt field */
           ex$message( field = PROMPT_FIELD, in_buff = " " );

           if ( (me->ve_vhl_flags & VE_VHL_BATCH_MODE) == 0 )
              {
              /* send interactive VEprocess message to the VEgragad */
              sts = om$send( msg=message VEgragad.VEprocess( &mesg,
                                                           &my_GRid,
                                                           &me->located_chansel,
                                                           batch_mode,
                                                           FALSE ),
                              targetid = me->gragad.objid,
                              targetos = me->gragad.osnum );
	OM_ERRCHK( sts, "VEedgescmds: VEgragad.VEprocess send failed" );
              }
           else
              {
              /* send VEsubmit_batch message to the VEgragad so that it */
              /* will submit a background job                           */
              sts = om$send( msg = message VEgragad.VEsubmit_batch( &mesg,
                                                            &my_GRid,
							   &me->located_chansel,
                                                            me->results_name,
                                                            me->server,
                                                            me->user_name,
                                                            me->password,
                                                          me->start_time ),
                              targetid = me->gragad.objid,
                              targetos = me->gragad.osnum );

          OM_ERRCHK( sts, "VEedgescmds: VEgragad.VEsubmit_batch send failed" );

              }

           }  /* end: if (high resolution) */
        else
	{
           /* running low or medium resolution VHL */
           HSlvhl_collect_elements( &my_GRid, &me->gragad, &me->located_chansel,
                                    me->hs_vhl_flags & HS_VHL_RESOLUTION,
                                    me->hidden_line_display,
                                    me->hs_vhl_flags & HS_VHL_TEXT_COPY,
                                    me->hs_vhl_flags & HS_VHL_RESULTS_DIM,
                                    me->hs_vhl_flags & HS_VHL_PROCESS_WIREFRAME,
                                    me->hs_vhl_flags & HS_VHL_CLIP_TO_FENCE,
                                    FALSE,  /* output soos */
                                    me->visible_level,
                                    me->hidden_level,
                                    me->text_level,
                                    FALSE, /* delete user symb. overrides */
                                    me->hs_vhl_flags & HS_VHL_REF_DISPLAY_OFF,
                                    FALSE );
           }	
	/* make the solid displayble/non_diplayable based on the flag disp
           which was set by getting the properties initially */

	if(disp)set=1;
	else set=0;
	property = GRIS_DISPLAYABLE;


        sts = om$send( msg = message GRvg.GRchgprops(&msg,&set,&property),
                        senderid = my_id,
                        targetid = refid.objid,
                        targetos = refid.osnum);

             /* Deleting the fence after creating the CVE, code added fori
             TR# 119702197 -Ashok */

	status = gr$gsget_fence(msg = &msg , fence_id = &my_fence_id);

	if(my_fence_id.objid !=NULL_OBJID)
	{
	status = om$send(msg = message NDnode.NDdisconnect(0, NULL),
                               targetid =my_fence_id.objid,
                               targetos =my_fence_id.osnum);

          om$send(msg = message GRgraphics.GRdisplay(&msg,
                        &module_env.md_env.matrix_type,
                                    module_env.md_env.matrix,&mode,
                                         &module_env.md_id),
                      targetid =my_fence_id.objid,
                      targetos = my_fence_id.osnum);

          status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                                             &module_env),
                                targetid =my_fence_id.objid,
                                targetos =my_fence_id.osnum);
         }

	sts = dp$update( msg = &msg,
                         osnum = me->gragad.osnum,
                         objid = me->gragad.objid);

	fenflg = 0;

	ex$message(msgnumb = EMS_P_ClearPromptField)
       ex$message(msgnumb = EMS_I_ClearStatusField)
	ex$message( field =KEYIN_FIELD, in_buff = " " );
	ex$clear_event_queue();
	state = 0;
   }
   else
     if(*response==CLEAR_STACK || *response==TERMINATE || *response==EX_BACK_UP)
     {
	 property = GRIS_LOCATABLE;
        set=1;

        sts = om$send( msg = message GRvg.GRchgprops(&msg,&set,&property),
                        senderid = my_id,
                        targetid = view.objid,
                        targetos = view.osnum);
        mode = GRheo;
        sts= om$send(msg=message GRgraphics.GRdisplay(&msg,
                                        &mod.md_env.matrix_type,
                                        mod.md_env.matrix,&mode,
                                        &mod.md_id),
                     targetid = view.objid,
                     targetos = view.osnum);

	 state = 1;
         return(OM_S_SUCCESS);
     }
     else
         if (*response == EX_CMD_KEY)
         {
	  mflg =1;
         return(OM_S_SUCCESS);
         }
    else { 
	 goto wrapup;
	}
    break;
	default:
	 sts = OM_S_SUCCESS;
	 goto wrapup;
        }
  }while(TRUE);
wrapup:
   return(OM_S_SUCCESS);
}/* execute */
end implementation COUpdVE;
