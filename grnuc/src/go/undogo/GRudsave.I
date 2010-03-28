/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        GRudsave
Synopsis
        method GRudsave (long *msg; struct GRid *add_id; 
                        struct GRmd_env *add_mod)

        msg             - return status
        add_id          - GRid of object being manipulated
        add_mod         - module of object being manipulated

        This is the latest version as of 1/1/98
Description
        This method saves the object being manipulated on a 
        channel off of the undo object, after deleting any objects
        previously placed on that channel.  If the object is a graphic
        set, it is placed on the GRundo.to_grset channel; otherwise
        it is placed on the GRcmpowner.to_components channel.
        The locatable and displayable bits of the object being
        manipulated are turned off.  If undo is turned off, the object
        is deleted immediately.

Notes
        Initially undo supports only "undelete"

History
        mrm     09/05/86    Creation
                10/14/86    OM 4.0 conversion
                09/23/87    Channel changes
                06/23/89    don't count on me->can_undo; check channel count
                07/24/89    ignore empty channel
        jhw     01/10/90    special check for reference file objects
      anand     09/10/97    Enhancements to delete command defining rules for
                            EMS objects with dependencies. 

Bugs
        Fence delete of reference file objects will result in an undisplayable
        /unlocatable reference file attachment but the clipping polygon will be
        unchanged.
        
*/
class implementation GRundo;

#include <OMerrordef.h>
#include "grimport.h"
#include "grgsmacros.h"
#include "godef.h"
#include "madef.h"
#include "DImacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "alloca.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include "grmacros.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include <stdlib.h>
#include "nddef.h"

/*
*/

#define  FI_YES     100
#define  FI_NO      200 


from GRgraphics  import GRdelete;
from GRconnector import GRflexconn;
from GRvg        import GRchgprops;
from NDnode      import NDget_objects;
from GRgraphics  import GRdisplay, GRgetprops;
from GRvg        import GRgetsymb, GRchglevel; 

extern GRclassid OPP_GR3dorthpoly_class_id;
extern GRclassid OPP_GR3dpolygon_class_id;
extern GRclassid OPP_GRgrset_class_id, OPP_GRfcset_class_id;
extern GRclassid OPP_GRsvset_class_id;
extern GRclassid OPP_EMScnstr_class_id,OPP_EMSidentity_class_id;
extern GRclassid OPP_EMSpointer_class_id;
extern GRclassid OPP_DMroot_class_id,OPP_DMsrc_class_id;
extern GRclassid OPP_EMSdatpln_class_id;
extern GRclassid OPP_EMSdimdtm_class_id;

OM_S_OBJID undo_objid;
OMuword    undo_osnum;

IGRint delete_warn_notify(form_label, gadget_label, value, form_ptr )
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{

 switch(gadget_label)
 {
  case FI_YES:
       {
        long stat;
        int  rsp = EX_FORM_FINISHED;
        ex$putque(msg = &stat, response = &rsp);
        FIf_erase(form_ptr);
       }
   break;
  case FI_NO:
       {
        long stat;
        int  rsp = EX_RJT_MOVEON;
        ex$putque(msg = &stat, response = &rsp);
        FIf_erase(form_ptr);
       }
   break;
 }
return(1);
}


method GRudsave (long *msg; struct GRid *add_id; struct GRmd_env *add_mod)

{
    int              is_grset;       /* what is being dealt with? */
    long             sts;            /* return code */
    long             owners_index;   /* index to connect at */
    long             graphics_index; /* index to connect at */
    long             flex_flag;      /* connect with override */
    short unsigned   properties;     /* flag for chprops */
    IGRboolean          set;            /* flag for chprops */
    struct GRid         myGRid;         /* id & os */
    OMuint              object_count;   /* number of objs on undel channel */
    OM_S_CHANSELECT     owners_chan;    /* channel from object */
    OM_S_CHANSELECT     grset_chan;     /* channel to graphic set */
    OM_S_CHANSELECT     comp_chan;      /* channel to simple objects */
    OM_S_CHANSELECT     poly_chan;      /* channel to clippoly */
    OMuword             add_classid;    /* classid for added object */

    
    IGRint              no_warn_flag = FALSE;
    char                *env_flag=NULL;

    void get_dependents();

    /*
     *  check to see what has been received
     */

    sts = OM_S_SUCCESS;
    is_grset = 0;
    *msg = OM_S_SUCCESS;

    undo_objid = my_id;
    undo_osnum = add_id->osnum;
    

    sts = gr$gsis_graphics_set (msg = msg,
                                object_id = add_id);
    is_grset = *msg & 1;

#ifdef DEBUG
    printf ("GRudsave: undelete is %s\n", (me->undo_on) ? "on" : "off");
    printf ("GRudsave: received a %s\n",
                            (is_grset) ? "graphic set" : "single object");
    printf ("GRudsave: add_id = %d, %d\n", add_id->osnum, add_id->objid);
#endif

//if(!is_grset)
//start of warning

env_flag = getenv("NO_WARN_DELETE");
if(env_flag)
{
 if((strcmp(env_flag,"1")==0))
   no_warn_flag = 1;
}

if(!(no_warn_flag==TRUE))
{
 OM_p_OBJECT_LINKAGE list, list2;
 IGRint              i_c;
 struct GRid              *out_objs=NULL;
 struct GRmd_env     disp_env;
 IGRboolean          aflag = 0;
 struct GRid         *list1 = NULL;
 enum GRdpmode       disp_mode;
 IGRchar             *fp1=NULL;
 IGRlong             msgl;
 struct GRevent      cr_event;
 int                 response;
 char                response_data[1024];
 IGRint              form_flag = 0;
 IGRint              cmp = 1,num_depnts=0;

  gr$get_module_env(buffer = &disp_env);
  aflag = pwIsActivationOn(); 

 if(is_grset)
 {
    OM_S_CHANSELECT     comp_chan, toset_chan;
    OMuint              cmp_count, set_count;

    om$make_chanselect (channame = "GRgrset.to_sets",
                               p_chanselect = &toset_chan);
    om$make_chanselect (channame = "GRcmpowner.to_components",
                               p_chanselect = &comp_chan);
    sts = om$get_channel_count(osnum = add_id->osnum,
                         objid = add_id->objid,
                         p_chanselect = &toset_chan,
                         count = &set_count); 
   if(sts & 1)
   {
        IGRint        size, ii;

        size = sizeof (OM_S_OBJECT_LINKAGE) * set_count;
        list = (OM_S_OBJECT_LINKAGE *)alloca(size);

        om$get_channel_objects(osnum = add_id->osnum,
                                     objid = add_id->objid,
                                     p_chanselect = &toset_chan,
                                     list = list,
                                     size = set_count,
                                     count = &set_count);
       for ( ii=0; ii < set_count; ii++ )
       {

        sts = om$get_channel_count(osnum = list[ii].osnum,
                                objid = list[ii].S_objid,
                                p_chanselect = &comp_chan,
                                count = &cmp_count);
        if(sts & 1)
        {
            size = sizeof (OM_S_OBJECT_LINKAGE) * cmp_count;
            list2 = (OM_S_OBJECT_LINKAGE *)alloca(size);

            om$get_channel_objects(osnum = list[ii].osnum,
                                     objid = list[ii].S_objid,
                                     p_chanselect = &comp_chan,
                                     list = list2,
                                     size = cmp_count,
                                     count = &cmp_count); 
            cmp = cmp_count;

        }
      }
   }
 }
 else
 {
   IGRint size;
            size             = sizeof (OM_S_OBJECT_LINKAGE); 
            list2            = (OM_S_OBJECT_LINKAGE *)alloca(size);
            list2[0].S_objid = add_id->objid;
            list2[0].osnum   = add_id->osnum;

 }

 for(i_c=0;i_c<cmp;i_c++)
  {
  get_dependents(&list2[i_c],&out_objs,&num_depnts); 
 
    if(num_depnts)
    {
     IGRint count;

          list1 = (struct GRid *) malloc(num_depnts * sizeof(struct GRid));

          for ( count=0; count < num_depnts; count++ )
          {
            list1[count].objid = out_objs[count].objid;
            list1[count].osnum = out_objs[count].osnum;
          }

          for ( count=0; count < num_depnts; count++ )
          {
            struct GRsymbology  symb; 
            IGRint              size, nret;
            IGRshort            active_level;
            IGRshort            props, tmp_props, action;
            IGRint              set_props = 0;
            GRclassid           classid;

            om$get_classid(objid = list1[count].objid,
                            osnum = list1[count].osnum,
                            p_classid = &classid);

            if(!((om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMScnstr_class_id) == OM_S_SUCCESS)||
            (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_DMroot_class_id) == OM_S_SUCCESS)||
            (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSdimdtm_class_id) == OM_S_SUCCESS)||
            (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSpointer_class_id) == OM_S_SUCCESS)||
            (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_DMsrc_class_id) == OM_S_SUCCESS)||
            (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSidentity_class_id) == OM_S_SUCCESS)))
               {
                    form_flag++;
               }
             else
               continue;

            // get symbology of object and check its level whether ON/OFF
            om$send(msg = message GRvg.GRgetsymb(&msgl, &symb),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
                

            size = sizeof( IGRshort );

            gr$get_active_level ( msg = &msgl,
                                   sizbuf = &size,
                                   nret = &nret,
                                   buffer = (IGRchar *)&active_level);

           if(symb.level != active_level)
            {
               om$send(msg = message GRvg.GRchglevel(&msgl, &active_level),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
            }
              
           // get the GRIS_DISPLAYABLE bit of child_id and set if unset
            om$send(msg = message GRgraphics.GRgetprops(&msgl,
                                 &props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);

            if(!(props & GRIS_DISPLAYABLE))
             {
              action = 1;// set
              tmp_props = GRIS_DISPLAYABLE;
              om$send(msg = message GRvg.GRchgprops(&msgl, &action,
                                 &tmp_props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum); 
              set_props = 1;

             } 


            disp_mode = GRhd;
            sts = om$send (mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay(msg,
                                        aflag? &disp_env.md_env.matrix_type:
                                                 &add_mod->md_env.matrix_type,
                                        aflag? disp_env.md_env.matrix:
                                                 add_mod->md_env.matrix,
                                                 &disp_mode,
                                        aflag? &disp_env.md_id:
                                                 &add_mod->md_id),
                              senderid = my_id,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);
           if(symb.level != active_level)
            {
               om$send(msg = message GRvg.GRchglevel(&msgl, &symb.level),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
            }
           if(set_props)
            {
              action = 0;// reset
              tmp_props = GRIS_DISPLAYABLE;
              om$send(msg = message GRvg.GRchgprops(&msgl, &action,
                                 &tmp_props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum); 
            } 
 
          }//for chd_count
    if(list1)
      free(list1);
      free(out_objs);  
     }// NDget_objects

   }// IS_GRSET


  if(form_flag)
   {
         if (fp1==NULL)
         FIf_new(100, "GRdelete", delete_warn_notify, &fp1);

        if(fp1!=NULL) FIf_display(fp1);
        co$getevent( msg = &msgl,
                                   event_mask = GRm_FORM_FINISHED,
                                   response   = &response,
                                   response_data = response_data,
                                   event = &cr_event ); 
    if( cr_event.response != EX_FORM_FINISHED )
     {
      int count,i,sts2,stat=1;
      DIint name_count = 0;
      IGRchar class_name[30];
      extern IGRint COpre_undelete_name();


      for(i_c=0;i_c<cmp;i_c++)
      {
         /* Fix for TR# 119800116  starts here */
 
         /* does the object have a name ? */
         sts2 = di$start_untrans( osnum   = list2[i_c].osnum,
                                 objid   = list2[i_c].S_objid,
                                 ptr     = &name_count );
 
         if (sts2 == DIR_S_SUCCESS)
         {
           sts2 = COpre_undelete_name( name_count,
                                    list2[i_c].S_objid,
                                    list2[i_c].osnum);
         }
 
        sts2 = di$update_dir_form();
 
        /* Fix for TR# 119800116  ends here */

        get_dependents(&list2[i_c],&out_objs,&num_depnts);

        if(num_depnts)
         {
          list1 = (struct GRid *) malloc(num_depnts * sizeof(struct GRid));
          for ( count=0; count < num_depnts; count++ )
          {
            list1[count].objid = out_objs[count].objid;
            list1[count].osnum = out_objs[count].osnum;
          }
          for(count=0; count<num_depnts; count++)
          {
            struct GRsymbology  symb; 
            IGRint              size, nret;
            IGRshort            active_level;
            IGRshort            props, tmp_props, action;
            IGRint              set_props = 0;

            // get symbology of object and check its level whether ON/OFF
            om$send(msg = message GRvg.GRgetsymb(&msgl, &symb),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
                

            size = sizeof( IGRshort );

            gr$get_active_level ( msg = &msgl,
                                   sizbuf = &size,
                                   nret = &nret,
                                   buffer = (IGRchar *)&active_level);

           if(symb.level != active_level)
            {
               om$send(msg = message GRvg.GRchglevel(&msgl, &active_level),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
            }
              
           // get the GRIS_DISPLAYABLE bit of child_id and set if unset
            om$send(msg = message GRgraphics.GRgetprops(&msgl,
                                 &props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);

            if(!(props & GRIS_DISPLAYABLE))
             {
              action = 1;// set 
              tmp_props = GRIS_DISPLAYABLE;
              om$send(msg = message GRvg.GRchgprops(&msgl, &action,
                                 &tmp_props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum); 
              set_props = 1;

             } 


            disp_mode = GRhe;
            sts = om$send (mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay(msg,
                                            aflag? &disp_env.md_env.matrix_type:
                                                 &add_mod->md_env.matrix_type,
                                            aflag? disp_env.md_env.matrix:
                                                 add_mod->md_env.matrix,
                                                 &disp_mode,
                                            aflag? &disp_env.md_id:
                                                 &add_mod->md_id), 
                              senderid = my_id,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);
           if(symb.level != active_level)
            {
               om$send(msg = message GRvg.GRchglevel(&msgl, &symb.level),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
            }
           if(set_props)
            {
              action = 0;// reset
              tmp_props = GRIS_DISPLAYABLE;
              om$send(msg = message GRvg.GRchgprops(&msgl, &action,
                                 &tmp_props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum); 
            } 
            disp_mode = GRbd;
            sts = om$send (mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay(msg,
                                            aflag? &disp_env.md_env.matrix_type:
                                                 &add_mod->md_env.matrix_type,
                                            aflag? disp_env.md_env.matrix:
                                                 add_mod->md_env.matrix,
                                                 &disp_mode,
                                            aflag? &disp_env.md_id:
                                                 &add_mod->md_id), 
                              senderid = my_id,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);
 
          }//count
      if(list1)
        free(list1);
       }//sts


     }// cmp

          
          for(i=0;i<cmp;i++)
          {
          disp_mode = GRbd;
          sts = om$send (mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay(msg,
                                        aflag? &disp_env.md_env.matrix_type:
                                                 &add_mod->md_env.matrix_type,
                                        aflag? disp_env.md_env.matrix:
                                                 add_mod->md_env.matrix,
                                                 &disp_mode,
                                        aflag? &disp_env.md_id:
                                                 &add_mod->md_id),
                          senderid = my_id,
                          targetid = list2[i].S_objid,
                          targetos = list2[i].osnum);
          }
          if(fp1!=NULL) FIf_erase(fp1); 
          goto finish; 
    }
   else
    {
     int count,i;
     for(i_c=0;i_c<cmp;i_c++)
     {
       get_dependents(&list2[i_c],&out_objs,&num_depnts);
   
       if(num_depnts)
        {
          list1 = (struct GRid *) malloc(num_depnts * sizeof(struct GRid));
          for ( count=0; count < num_depnts; count++ )
          {
            list1[count].objid = out_objs[count].objid;
            list1[count].osnum = out_objs[count].osnum;
          }
          for(count=0; count<num_depnts; count++)
          {
            struct GRsymbology  symb; 
            IGRint              size, nret;
            IGRshort            active_level;
            IGRshort            props, tmp_props, action;
            IGRint              set_props = 0;

            // get symbology of object and check its level whether ON/OFF
            om$send(msg = message GRvg.GRgetsymb(&msgl, &symb),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
                

            size = sizeof( IGRshort );

            gr$get_active_level ( msg = &msgl,
                                   sizbuf = &size,
                                   nret = &nret,
                                   buffer = (IGRchar *)&active_level);

           if(symb.level != active_level)
            {
               om$send(msg = message GRvg.GRchglevel(&msgl, &active_level),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
            }
              
           // get the GRIS_DISPLAYABLE bit of child_id and set if unset
            om$send(msg = message GRgraphics.GRgetprops(&msgl,
                                 &props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);

            if(!(props & GRIS_DISPLAYABLE))
             {
              action = 1;// set 
              tmp_props = GRIS_DISPLAYABLE;
              om$send(msg = message GRvg.GRchgprops(&msgl, &action,
                                 &tmp_props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum); 
              set_props = 1;

             } 


            disp_mode = GRhe;
            sts = om$send (mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay(msg,
                                            aflag? &disp_env.md_env.matrix_type:
                                                 &add_mod->md_env.matrix_type,
                                            aflag? disp_env.md_env.matrix:
                                                 add_mod->md_env.matrix,
                                                 &disp_mode,
                                            aflag? &disp_env.md_id:
                                                 &add_mod->md_id),
                              senderid = my_id,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum);
           if(symb.level != active_level)
            {
               om$send(msg = message GRvg.GRchglevel(&msgl, &symb.level),
                             senderid = my_id,
                             targetid = list1[count].objid,
                             targetos = list1[count].osnum); 
            }
           if(set_props)
            {
              action = 0;// reset
              tmp_props = GRIS_DISPLAYABLE;
              om$send(msg = message GRvg.GRchgprops(&msgl, &action,
                                 &tmp_props),
                              senderid = NULL_OBJID,
                              targetid = list1[count].objid,
                              targetos = list1[count].osnum); 
            } 
 
          }
         if(list1)
           free(list1);
         }//sts

      }//cmp
          for(i=0;i<cmp;i++)
          {
          disp_mode = GRbe;
          sts = om$send (mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay(msg,
                                        aflag? &disp_env.md_env.matrix_type:
                                                 &add_mod->md_env.matrix_type,
                                        aflag? disp_env.md_env.matrix:
                                                 add_mod->md_env.matrix,
                                                 &disp_mode,
                                        aflag? &disp_env.md_id:
                                                 &add_mod->md_id), 
                          senderid = my_id,
                          targetid = list2[i].S_objid,
                          targetos = list2[i].osnum);
          }
     }
   }//form_flag

// end of warning
}//no_warn_flag

    /*
     *  if undo is turned off, delete the object and return
     */

    if (!me->undo_on)
    {
        if (is_grset) /* delete the graphic set */
        {
            sts = gr$gsdelete (msg = msg, object_id = add_id);
        }
        else /* delete the simple object */
        {
            sts = om$send (mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdelete (msg, add_mod),
                              senderid = my_id,
                              targetid = add_id->objid,
                              targetos = add_id->osnum);
        }

#ifdef DEBUG
        if (!(*msg & sts & 1)) printf ("GRudsave: delete failed\n");
        if (!(*msg & 1)) printf ("GRudsave: msg = 0x%x\n", *msg);
        if (!(sts & 1)) om$report_error (sts = sts);
#endif

        return (sts);
    }

    /*
     *  initialize channel selectors
     */

    sts = om$make_chanselect (channame = "GRundo.to_grset",
                              p_chanselect = &grset_chan);
    if (sts & 1)
    {
        sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                  p_chanselect = &comp_chan);
    }
    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("GRudsave: error making channel selector\n");
#endif
        goto finish;
    }

    /*
     *  send delete message out undo_chan, if necessary
     */

    if (me->can_undo)   /* implies that something is on undo_chan */
    {
        if (me->was_gra_set)
        {
            /* make sure that there is something on the channel */

            sts = om$get_channel_count (object = me,
                                        p_chanselect = &grset_chan,
                                        count = &object_count);

            if ((sts & 1) && object_count)
            {
                sts = gr$gsdelete (msg = msg, p_chanselect = &grset_chan);
            }
        }
        else
        {
            /* make sure that there is something on the channel */

            sts = om$get_channel_count (object = me,
                                        p_chanselect = &comp_chan,
                                        count = &object_count);

            if ((sts & 1) && object_count)
            {
                sts = om$send (mode = OM_e_wrt_object,
                                  msg = message GRgraphics.GRdelete
                                       (msg, &me->context),
                                  senderid = my_id,
                                  p_chanselect = &comp_chan);
            }
        }
        if (!(sts & *msg & 1) && object_count)
        {
#ifdef DEBUG
            printf ("GRudsave: failed to delete saved objects\n");
#endif
            goto finish;
        }
    }

    /*
     *  connect object being manipulated to the proper channel
     */

    if (is_grset)
    {
        sts = om$make_chanselect (channame = "GRgrset.to_owners",
                                  p_chanselect = &owners_chan);

        sts = om$send (msg = message Root.connect
                            (owners_chan, NULL, my_id,
                             OM_Gw_current_OS, grset_chan, NULL),
                       senderid = my_id,
                       targetid = add_id->objid,
                       targetos = add_id->osnum);
    }
    else
    {
        flex_flag = 1;
        myGRid.objid = my_id;
        myGRid.osnum = OM_Gw_current_OS;
        owners_index = graphics_index = OM_K_MAXINT;

        sts = om$send (msg = message GRconnector.GRflexconn
                            (msg, &flex_flag, &myGRid,
                             &owners_index, &graphics_index),
                       senderid = my_id,
                       targetid = add_id->objid,
                       targetos = add_id->osnum);

        /*
         * If the connection fails make sure the deletion succeeds.
         */
        if (!(sts & *msg & 1))
        {
            sts = om$send (mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdelete (msg, add_mod),
                              senderid = my_id,
                              targetid = add_id->objid,
                           targetos = add_id->osnum);
        }
    }
    if (!(sts & *msg & 1))
    {
#ifdef DEBUG
        printf ("GRudsave: failed to connect to object(s) to save\n");
#endif
        goto finish;
    }

    me->was_gra_set = is_grset; /* for next time through */
    me->context = *add_mod;     /* save context of GO being manipulated */

    /*
     *  turn off locate & display bits on GO being manipulated
     */

    set = FALSE;
    properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

    if (is_grset)
    {
        sts = gr$gspass (msg = msg,
                         pass_msg = message GRvg.GRchgprops
                                   (msg, &set, (IGRshort *)&properties),
                         p_chanselect = &grset_chan);
    }
    else
    {
        sts = om$send (msg = message GRvg.GRchgprops
                            (msg, &set, (IGRshort *)&properties),
                       p_chanselect = &comp_chan);

        om$get_classid ( osnum = add_id->osnum,
                         objid = add_id->objid,
                         p_classid = &add_classid );

        /*
         * If the object is a reference file
         */
        if ( om$is_ancestry_valid (superclassname = "GRreffile",
                                   subclassid = add_classid ) == OM_S_SUCCESS )
        {
            /*
             * Turn off locate and display for the clipping polygon.
             */
            om$make_chanselect(channame = "GRreffile.to_clip",
                               p_chanselect = &poly_chan);

	    sts = om$send( msg = message GRgraphics.GRchgprops (msg,
                                                                &set,
                                                    (IGRshort *)&properties),
                           senderid = add_id->objid,
                           p_chanselect = &poly_chan);
	}
    } 

finish:

    if (*msg & sts & 1)
    {
        me->can_undo = TRUE;
    }

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRudsave: msg = 0x%x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

void get_dependents(OM_S_OBJECT_LINKAGE *del_obj,struct GRid **disp_objs,
                             IGRint *ndeps)
{
    IGRlong sts;
    OM_p_OBJECT_LINKAGE cmp_list;
    OM_p_OBJECT_LINKAGE child1_list,child2_list; 
    OM_S_CHANSELECT     comp_chan,child_chan;
    OMuint              cmp_count=0,child1_cnt=0,child2_cnt=0;
    IGRint              sum_of_deps = 0,count = 0;
    struct GRid              *tmp_objids = NULL;
    
    om$make_chanselect (channame = "NDchildren.children",
                               p_chanselect = &child_chan);

    om$make_chanselect (channame = "GRcmpowner.to_components",
                               p_chanselect = &comp_chan);
    sts = om$get_channel_count(osnum = del_obj->osnum,
                         objid = del_obj->S_objid,
                         p_chanselect = &comp_chan,
                         count = &cmp_count);

    sts = om$get_channel_count(osnum = del_obj->osnum,
                         objid = del_obj->S_objid,
                         p_chanselect = &child_chan,
                         count = &child1_cnt);

 
    if(child1_cnt)
      sum_of_deps += child1_cnt;

    if(cmp_count) 
    {
        IGRint        size, jj;
        size = sizeof (OM_S_OBJECT_LINKAGE) * cmp_count;
        cmp_list = (OM_S_OBJECT_LINKAGE *)alloca(size);

        om$get_channel_objects(osnum = del_obj->osnum,
                               objid = del_obj->S_objid,
                               p_chanselect = &comp_chan,
                               list = cmp_list,
                               size = cmp_count,
                               count = &cmp_count);

        for ( jj=0; jj < cmp_count; jj++ )
       {

        sts = om$get_channel_count(osnum = cmp_list[jj].osnum,
                                objid = cmp_list[jj].S_objid,
                                p_chanselect = &child_chan,
                                count = &child2_cnt);

        if(child2_cnt)
          sum_of_deps += child2_cnt;
       } 
    }

    /* All the above processing is done to get the number of objects
       to be loaded in the incoming bucket 
    */
       *ndeps = sum_of_deps; 
       tmp_objids = (struct GRid *)malloc(sum_of_deps*sizeof(struct GRid));
       *disp_objs = tmp_objids;


   /* Now start filling up the dependent objids. First of all get the
      objects on the to_children channel of the del_objid
   */ 

      sts = om$get_channel_count(osnum = del_obj->osnum,
                         objid = del_obj->S_objid,
                         p_chanselect = &child_chan,
                         count = &child1_cnt);
    if(child1_cnt)
    {
        IGRint        size, ii;

        size = sizeof (OM_S_OBJECT_LINKAGE) * child1_cnt;
        child1_list = (OM_S_OBJECT_LINKAGE *)alloca(size);

        om$get_channel_objects(osnum = del_obj->osnum,
                               objid = del_obj->S_objid,
                               p_chanselect = &child_chan,
                               list = child1_list,
                               size = child1_cnt,
                               count = &child1_cnt);
        for ( ii=0; ii < child1_cnt; ii++ ) 
        {
           tmp_objids[count].objid = child1_list[ii].S_objid;
           tmp_objids[count].osnum = child1_list[ii].osnum;
           count++;
        }
    }

    /* Now get the objects on the to_components channel of the del_objid
       and get the objects lying on their to_children channel
    */

    {
        IGRint        size, jj;

        size = sizeof (OM_S_OBJECT_LINKAGE) * cmp_count;
        cmp_list = (OM_S_OBJECT_LINKAGE *)alloca(size);

        om$get_channel_objects(osnum = del_obj->osnum,
                               objid = del_obj->S_objid,
                               p_chanselect = &comp_chan,
                               list = cmp_list,
                               size = cmp_count,
                               count = &cmp_count);

        for ( jj=0; jj < cmp_count; jj++ )
       {

        sts = om$get_channel_count(osnum = cmp_list[jj].osnum,
                                objid = cmp_list[jj].S_objid,
                                p_chanselect = &child_chan,
                                count = &child2_cnt);
       if(child2_cnt)
       {
         
        IGRint        size, ii;

        size = sizeof (OM_S_OBJECT_LINKAGE) * child2_cnt;
        child2_list = (OM_S_OBJECT_LINKAGE *)alloca(size);

        om$get_channel_objects(osnum = cmp_list[jj].osnum,
                               objid = cmp_list[jj].S_objid,
                               p_chanselect = &child_chan,
                               list = child2_list,
                               size = child2_cnt,
                               count = &child2_cnt);
        
        for ( ii=0; ii < child2_cnt; ii++ )
        {
           tmp_objids[count].objid = child2_list[ii].S_objid;
           tmp_objids[count].osnum = child2_list[ii].osnum;
           count++;
        }
       }
     
       }
     }           
 wind_up:
     return;
}
/*
  The function GRplot_fence_del() has been written to take care of the
  TR# 119418207. This function checks whether there is a fence element
  in the undelete buffer and returns a TRUE flag in case there is one
*/

IGRint GRplot_fence_del()
{
 IGRlong msg,sts;
 OMuword objclass;
 IGRboolean flag;
 OM_S_CHANSELECT     comp_chan;
 OMuint              comp_count;
 OM_p_OBJECT_LINKAGE comp_list;
 
 extern IGRint GRquery_grset_chan();
   
 flag = FALSE;

 if(GRquery_grset_chan()) flag = TRUE;

 /*
  *  initialize channel selectors
  */

        sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                  p_chanselect = &comp_chan);

    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("GRudsave: error making channel selector\n");
#endif
        goto wrapup;
    }

    if(undo_objid)
    {
        sts = om$get_channel_count(objid = undo_objid,
                         osnum = undo_osnum,
                         p_chanselect = &comp_chan,
                         count = &comp_count);

        if(!(sts&1)) goto wrapup;
 
      if(comp_count)
      {
        IGRint        nsize, ii;

        nsize = sizeof (OM_S_OBJECT_LINKAGE) * comp_count;
        comp_list = (OM_S_OBJECT_LINKAGE *)alloca(nsize);
       
        sts =  om$get_channel_objects(osnum = undo_osnum,
                                     objid = undo_objid,
                                     p_chanselect = &comp_chan,
                                     list = comp_list,
                                     size = comp_count,
                                     count = &comp_count);
        if(!(sts&1)) goto wrapup;
 
        for(ii=0;ii<comp_count;ii++)
        { 
   if(om$get_classid(objid =comp_list[ii].S_objid,osnum = undo_osnum,
                  p_classid = &objclass) & 1)
          if((objclass == OPP_GR3dorthpoly_class_id) ||
             (objclass == OPP_GR3dpolygon_class_id))
              flag =  TRUE;
        } 
      }
    }

wrapup:
    return(flag);
}

IGRint GRquery_grset_chan()
{
 IGRlong msg,sts;
 OMuword objclass;
 IGRboolean flag;
 OM_S_CHANSELECT     to_comp,to_sets,to_grset;
 OMuint              set_count,grset_count,comp_count;
 OM_p_OBJECT_LINKAGE comp_list,set_list,grset_list;

 flag = FALSE;
 /*
  *  initialize channel selectors
  */

        sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                  p_chanselect = &to_comp);

        if(!(sts&1)) goto ret_end;

        sts = om$make_chanselect (channame = "GRundo.to_grset",
                                  p_chanselect = &to_grset);

        if(!(sts&1)) goto ret_end;

        sts = om$make_chanselect (channame = "GRgrset.to_sets",
                                  p_chanselect = &to_sets);

        if(!(sts&1)) goto ret_end;


    if(undo_objid)
    {
        sts = om$get_channel_count(objid = undo_objid,
                         osnum = undo_osnum,
                         p_chanselect = &to_grset,
                         count = &grset_count);

        if(!(sts&1)) goto ret_end;

      if(grset_count)
      {
        IGRint        nsize, ii;

        nsize = sizeof (OM_S_OBJECT_LINKAGE) * grset_count;
        grset_list = (OM_S_OBJECT_LINKAGE *)alloca(nsize);

        sts =  om$get_channel_objects(osnum = undo_osnum,
                                     objid = undo_objid,
                                     p_chanselect = &to_grset,
                                     list = grset_list,
                                     size = grset_count,
                                     count= &grset_count);
        if(!(sts&1)) goto ret_end;   

   for(ii=0;ii<grset_count;ii++)
    {
   if(om$get_classid(objid =grset_list[ii].S_objid,osnum = undo_osnum,
                  p_classid = &objclass) & 1)
     {
     if((objclass == OPP_GRgrset_class_id) ||
        (objclass == OPP_GRfcset_class_id))
       {
           sts = om$get_channel_count(objid = grset_list[ii].S_objid,
                         osnum = undo_osnum,
                         p_chanselect = &to_sets,
                         count = &set_count);

        if(!(sts&1)) goto ret_end;

        if(set_count)
        {
        IGRint        nsize, jj;

        nsize = sizeof (OM_S_OBJECT_LINKAGE) * set_count;
        set_list = (OM_S_OBJECT_LINKAGE *)alloca(nsize);

        sts =  om$get_channel_objects(osnum = undo_osnum,
                                     objid = grset_list[ii].S_objid,
                                     p_chanselect = &to_sets,
                                     list = set_list,
                                     size = set_count,
                                     count= &set_count);
        if(!(sts&1)) goto ret_end;

    for(jj=0;jj<set_count;jj++)
    {
   if(om$get_classid(objid =set_list[jj].S_objid,osnum = undo_osnum,
                  p_classid = &objclass) & 1)
     {
       if(objclass == OPP_GRsvset_class_id)
       {
          sts = om$get_channel_count(objid = set_list[jj].S_objid,
                         osnum = undo_osnum,
                         p_chanselect = &to_comp,
                         count = &comp_count);

        if(!(sts&1)) goto ret_end;

        if(comp_count)
        {
        IGRint        nsize, kk;

        nsize = sizeof (OM_S_OBJECT_LINKAGE) * comp_count;
        comp_list = (OM_S_OBJECT_LINKAGE *)alloca(nsize);

        sts =  om$get_channel_objects(osnum = undo_osnum,
                                     objid = set_list[jj].S_objid,
                                     p_chanselect = &to_comp,
                                     list = comp_list,
                                     size = comp_count,
                                     count= &comp_count);
        if(!(sts&1)) goto ret_end;
    
        for(kk=0;kk<comp_count;kk++)
        {
   if(om$get_classid(objid =comp_list[kk].S_objid,osnum = undo_osnum,
                  p_classid = &objclass) & 1)
        {
           if((objclass == OPP_GR3dorthpoly_class_id) ||
              (objclass == OPP_GR3dpolygon_class_id))

                  flag = TRUE;

        } /* om$get_classid */
        } /* for(kk=0;kk<comp_count;kk++)*/

        } /* if(comp_count) */




       } /* objclass == OPP_GRsvset_class_id */
     } /* om$get_classid */
    } /* for(jj=0;jj<set_count;jj++) */

   } /* if(set_count) */




         }/* objclass == OPP_GRgrset_class_id */
        } /* om$get_classid */
       } /* for(ii=0;ii<grset_count;ii++) */ 
      } /* if(grset_count) */
    } /* if(undo_objid) */        


ret_end :

    return(flag);
} 
end implementation GRundo;
