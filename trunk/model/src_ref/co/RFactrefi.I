class implementation RFactref;
#include <alloca.h>
#include "stdio.h"
#include "FI.h"
#include "stdlib.h"
#include "string.h"
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "madef.h"
#include "msdef.h"
#include "griomacros.h"
#include "refdef.h"
#include "ref.h"
#include "refmacros.h"
#include "referr.h"
#include "grerr.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msmacros.h"
#include "ECcmd.h"
#include "grmsg.h"
#include "ECmsg.h"

#include "assemdef.h"
#include "assem.h"

#include "EMdtmacros.h"

/** Friend Functions **/
from GRgraphics import GRdisplay;
from GRreffile import GRgetosnum,GRgetenvironment,GRchgcolor,GRgetsymb;
from GRreffile import GRchgrfprops;
from EMdescribe import EMget_memb;
from EMSdatplnmgr import EMactivate, EMget_info;

/** Helper functions **/
extern rfDisplaySaveBtn();
extern rfDefineCursor();

/** Helper Variables **/
extern OMuword OPP_EMinstance_class_id;
extern OMuword OPP_GRdrawview_class_id;
extern OMuword OPP_GRdvattach_class_id;
extern OMuword OPP_GRreffile_class_id;
method init(int type; char *string_ptr)
{
    int status;

    me->rfhead.objid = NULL_OBJID; 
    me->form_finished = FALSE;
    me->form_displayed = FALSE;

    status =
    om$send(msg = message super_cmd.init(type, string_ptr),
            targetid = my_id,
            mode = OM_e_wrt_message);

    return(OM_S_SUCCESS);
}


method wakeup(int pos)
{
    int status;

    ex$message(field = MESSAGE_FIELD,
              msgnumb = EM_M_ActAsmPart);

    status = om$send(mode = OM_e_wrt_message,
                     msg = message super_cmd.wakeup(pos),
                     targetid = my_id);
    return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
   IGRlong msg;
   IGRint status;
   struct IGRdisplay rfdisp;


   IGRchar  locate_prompt[52], accept_prompt[52], relocate_prompt[52];
   IGRlong  locate_mask, accept_mask;
   IGRlong  object_was_located, display_flag;
   struct GRlc_locate  attributes;
   OM_S_CLASSLIST  rtree_classes,elig_classes;
   OMuword  rclass[3], eliclass[3], accept_classid[3];
   IGRlong size;
   IGRboolean aflag = 0;

   /** Check if any reference files are attached **/
   /** Intentional block to set scope **/

   {
       int num_ref = 0;
       gr$review_ref_files(msg = &msg,
                           output_file = NULL,
                           num_found = &num_ref);
       if (num_ref == 0)
       {
          ex$message(field = ERROR_FIELD,
                     msgnumb = GR_E_NoRefFl,
                     time = 2);
          ex$message(field = ERROR_FIELD,
                     msgnumb = EMS_I_ClearStatusField);
          *response = TERMINATE;
          return(OM_S_SUCCESS);
       }
   }

   if(aflag = pwIsActivationOn())
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
     *response = TERMINATE;
     return (OM_S_SUCCESS);
    } 

   /** LOCATE FILE **/
 
   display_flag = ALL_WINDOWS | ELEM_HILIGHT;
   locate_mask = GRm_DATA|GRm_BACK_UP|
                 GRm_RESET;
   accept_mask = GRm_DATA|GRm_BACK_UP;
   

   strcpy(locate_prompt,"Locate Assembly Part");
   strcpy(accept_prompt,"Accept/Reject");
   strcpy(relocate_prompt,"Assembly Part Not Found");
 
   attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
 
   attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                        LC_REF_HEADER | LC_NO_REF_OBJECTS | LC_HANDLES; 
 
  // Strcpy(attributes.classes, "GRreffile");
 
   elig_classes.w_count = 3;
   elig_classes.w_flags = OM_CLST_subclass;
   eliclass[0] = OPP_EMinstance_class_id;
   eliclass[1] = OPP_GRreffile_class_id;
   eliclass[2] = OPP_GRdrawview_class_id;

   elig_classes.p_classes = eliclass;
 
   rtree_classes.w_count = 3;
   rtree_classes.w_flags = OM_CLST_subclass;
   rclass[0]  = OPP_EMinstance_class_id ;
   rclass[1] =  OPP_GRreffile_class_id;
   rclass[2] =  OPP_GRdrawview_class_id;
   rtree_classes.p_classes = rclass;

   accept_classid[0] = OPP_EMinstance_class_id;
   accept_classid[1] =   OPP_GRreffile_class_id;
   accept_classid[2] =   OPP_GRdrawview_class_id;

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

   if (*response == EX_DATA)
   {
       struct GRid part_id;
       EMmemb memb; 
       IGRuint                   i,j;
       OMuint                    num_cmpnts,num_cmpnts1;
       IGRuint                   num_objects,num_objects1;
       OM_S_CHANSELECT           to_owners,to_cmpnt_chansel;
       OMuword                   classid;
       OM_S_OBJECT_LINKAGE       *f_ids,*f_ids1;
       

       status = dp$erase_hilite(msg = &msg);

       status = om$get_classid(osnum = me->acc_event.located_object[0].located_obj.osnum,     
                                     objid = me->acc_event.located_object[0].located_obj.objid,   
                                     p_classid = &classid);
      
       /* We allow the locate of GRdarwview created by Create Drawing   ***
       ** View,GRreffile created by Attach Reference files , EMinstance ***
       ** created by Place Part/Create Part.                            ***
       ** - Added for RFA enhancements  - Sp.Balamurugan                **/


       if(classid == OPP_EMinstance_class_id)
       { 
        part_id.objid = me->acc_event.located_object[0].located_obj.objid;
        part_id.osnum = me->acc_event.located_object[0].located_obj.osnum;

        om$send (msg = message EMdescribe.EMget_memb(&msg,
                                                   "reffile",
                                                   EM_GRAPHIC,
                                                   0,
                                                   &memb),
               senderid = NULL_OBJID,
               targetid = part_id.objid,
               targetos = part_id.osnum);

        me->rfhead.objid = memb.id.objid;
        me->rfhead.osnum = memb.id.osnum;
       }

       else if(classid == OPP_GRreffile_class_id)
       {
        me->rfhead.objid  = me->acc_event.located_object[0].located_obj.objid;
        me->rfhead.osnum  = me->acc_event.located_object[0].located_obj.osnum;
       }

       else if(classid == OPP_GRdrawview_class_id)
       {   
        status = om$make_chanselect(channame = "GRcmpowner.to_components",  
                                    p_chanselect = &to_cmpnt_chansel);



        status = om$get_channel_count(osnum=me->acc_event.located_object[0].located_obj.osnum,       
                                        objid =me->acc_event.located_object[0].located_obj.objid,      
                                        p_chanselect = &to_cmpnt_chansel,    
                                        count = &num_cmpnts); 



        f_ids = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) * 
                                        num_cmpnts);


        status = om$get_channel_objects(objid = me->acc_event.located_object[0].located_obj.objid,
                                        osnum = me->acc_event.located_object[0].located_obj.osnum,
                                        p_chanselect = &to_cmpnt_chansel,
                                        list = f_ids,
                                        size = num_cmpnts,
                                        count = &num_objects);

        for(i=0;i<num_cmpnts;i++)
        {
         status = om$get_classid(osnum = f_ids[i].osnum,   
                                 objid = f_ids[i].S_objid,   
                                 p_classid = &classid);
 
         if(classid == OPP_GRdvattach_class_id)
         {
          status = om$get_channel_count(osnum = f_ids[i].osnum,
                                        objid = f_ids[i].S_objid,
                                        p_chanselect = &to_cmpnt_chansel,
                                        count = &num_cmpnts1);

          f_ids1 = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                         num_cmpnts1);


          status = om$get_channel_objects(objid = f_ids[i].S_objid,
                                          osnum = f_ids[i].osnum,
                                          p_chanselect = &to_cmpnt_chansel,
                                          list = f_ids1,
                                          size = num_cmpnts1,
                                          count = &num_objects1);
          for(j=0;j<num_cmpnts1;j++)
          {
           status = om$get_classid(osnum = f_ids1[j].osnum,
                                   objid = f_ids1[j].S_objid,
                                   p_classid = &classid);

           if(classid == OPP_GRreffile_class_id)
           { 
            me->rfhead.objid  = f_ids1[j].S_objid;
            me->rfhead.osnum = f_ids1[j].osnum;
            break; 
           }
          }
          break;
         }          
        }
       } 

       UpdateActParams(me->rfhead);

       /** get the ref. files symbology and the update the form **/
       gr$get_active_display(buffer = &rfdisp);
       gr$put_active_display(buffer = &rfdisp);
       gr$get_active_layer(buffer = &rfdisp);
       gr$put_active_layer(buffer = &rfdisp);

       *response = TERMINATE;
       return(1);
   }
   else
     if ( *response == CLEAR_STACK ||
          *response == EX_BACK_UP)
     {
         return(1);
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
wrapup:
   return(OM_S_SUCCESS);
}

int UpdateActParams(struct GRid rfhead)
{
   int status;
   IGRlong msg;
   IGRmatrix matrix;
   short mtx_type;
   struct GRid cur_mod;
   enum GRdpmode mode;
   struct GRid *ref_ids = NULL;
   int num_ref = 0,i;
   IGRchar **ref_names = NULL;
   GRspacenum osn;
   unsigned short color;

   gr$review_ref_files(msg = &msg,
                       output_file = NULL,
                       ref_grids = &ref_ids,
                       ref_names = &ref_names,
                       num_found = &num_ref);

   status = ex$get_cur_mod(id = &cur_mod.objid,
                           osnum = &cur_mod.osnum );
   mtx_type = MAIDMX;
   MAidmx ( &msg, matrix );

   for (i=0;i<num_ref;i++)
   {
      if (ref_ids[i].objid == rfhead.objid)
      {
           IGRulong props = GROVERRIDE_SYMBOLOGY;
           IGRshort flag = 0;
           status = om$send(msg = message GRreffile.GRchgrfprops(&msg,
                                                           &flag,
                                                           &props),
                            senderid = NULL_OBJID,
                            targetid = ref_ids[i].objid,
                            targetos = ref_ids[i].osnum);

           mode = GRbd;
           om$send(msg = message GRgraphics.GRdisplay(&msg,&mtx_type,
                                                     matrix , &mode,
                                                     &cur_mod ),
                   senderid = NULL_OBJID,
                   targetid = rfhead.objid,
                   targetos = rfhead.osnum);

           /** Activate the Save buton **/
           rfDisplaySaveBtn(TRUE);

           /** Activate the cursor **/
           rfDefineCursor();

           /** Update the global variables **/
           status = pwActivateReferenceFile(ref_names[i], &osn);

           /* Activate the active datum (if any) in the activated os. */
           ActivateRefDatum(ref_ids[i]);

           /** Do not break , turn all other reference file to gray
           break; **/
       }
       else
       {
           /** Change color to gray **/
            color = DEACTIVE_COLOR;
            status = om$send(msg = message GRreffile.GRchgcolor(&msg,
                                                           (IGRuint *)NULL,
                                                           &color),
                              senderid = NULL_OBJID,
                              targetid = ref_ids[i].objid,
                              targetos = ref_ids[i].osnum);
           mode = GRbd;
           om$send(msg = message GRgraphics.GRdisplay(&msg,&mtx_type,
                                                     matrix , &mode,
                                                     &cur_mod ),
                   senderid = NULL_OBJID,
                   targetid = ref_ids[i].objid,
                   targetos = ref_ids[i].osnum);

       }
   }
 
   if (ref_names)
   {
     int ii;
     for(ii=0; ii<num_ref;ii++)
           if (ref_names[ii]) free(ref_names[ii]);
     free(ref_names);
   }
   if (ref_ids) free(ref_ids);
  
   return(OM_S_SUCCESS);
}
                    

method  rfform_notification(int f_label;int g_label;double value;Form fp)
{
  /* Functionality removed */
  return(OM_S_SUCCESS);
} 

int ActivateRefDatum(struct GRid ref_id)
{
   GRspacenum osn;
   OM_S_OBJID active_id;
   struct GRid mgr_id;
   IGRlong loc_msg;
   IGRmatrix matrix;
   short mtx_type;
   struct GRid cur_mod;
   enum GRdpmode mode;
   IGRint status;

   status = ex$get_cur_mod(id = &cur_mod.objid,
                           osnum = &cur_mod.osnum );
   mtx_type = MAIDMX;
   MAidmx ( &loc_msg, matrix );

   if (ref_id.objid != NULL_OBJID)
   {
     status = om$send(msg = message GRreffile.GRgetosnum(&loc_msg, &osn),
                      senderid = NULL_OBJID,
                      targetid = ref_id.objid,
                      targetos = ref_id.osnum);
   }
   else
   {
     /* NULL OBJID for GRreffile - so set the masters active datum plane*/
     osn = EX_active_OS_num;
   }

   ems$get_datum_plane_mgr(msg = &loc_msg,
                           osnum = &osn,
                           mgrid = &mgr_id.objid,
                           mgros = &mgr_id.osnum);

   status = om$send(msg = message EMSdatplnmgr.EMget_info(&loc_msg, NULL,
                                                 NULL, NULL,
                                                 &active_id,
                                                 NULL),
                    senderid = NULL_OBJID,
                    targetid = mgr_id.objid,
                    targetos = mgr_id.osnum);

   if (active_id != NULL_OBJID)
   {
      status = om$send(msg = message EMSdatplnmgr.EMactivate(&loc_msg,
                                              NULL,
                                              &active_id,
                                              NULL),
                       senderid = NULL_OBJID,
                       targetid = mgr_id.objid,
                       targetos = mgr_id.osnum);

      mode = GRbd;
      status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,&mtx_type,
                                                 matrix , &mode,
                                                 &cur_mod ),
                       senderid = NULL_OBJID,
                       targetid = active_id,
                       targetos = mgr_id.osnum);
   }

   return(1);
}

end implementation RFactref;
