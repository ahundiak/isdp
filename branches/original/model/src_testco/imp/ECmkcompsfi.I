/* ###################   APOGEE COMPILED   ################## */
class implementation ECmkcompsf;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSasopts.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_E.h"
#include "EC_M.h"
#include "EMSascmacros.h"
/*
DESCRIPTION
        This command creates a composite surface given one or more surfaces
        or drops a solid to a composite surface.  If the resulting composite
        surface is closed then the operator is asked if he wants to make
        the result a solid.

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

HISTORY

    08/14/94 scw clarified sleep method
    08/08/91 scw Converted to use gr$dpb associative flag
    06/07/91 pp  Added support for the associativity button to always
                 be associative.
    11/02/89 SS  Notification for solid->compsurf
    01-Sep-89 SM Modified to try stitching even if only one surface is
                 selected. This will allow the user to stitch some edges within
                 a composite and possibly make it into a solid.
    10/11/88 SM  Modified for state tree purposes -
                 1) Construct EMSsfstitch instead of EMSgencompsf.
                 2) Argument addition to message EMmake_comp. Also the msg
                    moved from EMSgencompsf to EMSsfstitch.
                 3) The corresponding solid class now is EMSslstitch instead
                    of EMSgensolid.
                 4) Do not compress tree after successful stitch.
                
    10/06/88 DLB Removed EMreduce_range send per instructions.
                 This send prevented the user from retrieving the original
                 surface geometry. 

    09/28/88 rlw Modified not to erase the stitchable edges one by one but
                 to erase the highlight plane.  This was painful if the
                 model was rather large.

    09/26/88 rlw Modified not to allow the operator to locate the same
                 surface more than once.

    06/14/88 DLB Modified the make_cs action to construct more intelligent
                 objects or, in some cases, to not compress the state tree
                 during conversion between solids and surfaces.

    06/02/88 rlw Modified such that a set/fence of surfaces can be
                 input in order to create a composite surface.
                 Modified to use the message subsystem.
                 Removed Dave's error macro in order to try and
                 reduce the static string size in the image.

    04/20/88 DLB Added EMreduce_range send.

25-Feb-1988 jBk Added type 1 which differs from type 0 only in
                not asking before trying to make a solid.  Type 0
                remains the same.
                Added GRm_OBJID to locate mask.  Do not perform
                ex$putque if last event was EX_OBJID.
                This command does not yet allow EX_OBJID events
                for acceptance, but it really ought.
02-Feb-1988 jBk Changed locate display flag assignments to use
                mnemonics instead of literals.
29-Dec-1987 DLB Added EFmksolid call.
xx-Nov-1987 DLB Creation date.
06/03/92    Vadiraj Modified for message subsystem compliance.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMSaction.h"  /* Structure definition for select handler */
#include "emsdef.h"
#include "EMSdpb.h"

/* AND, ISNT ... */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif
                                        
#if DEBUG
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
        if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
                EMSmsgReport (error_number, error_message, FALSE)) \
                goto label; \
 }
#else
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
  if (! (1 & sts_stupid)) goto label;\
 }
#endif

from GRgraphics         import GRdisplay;
from GRgraphics         import GRconstruct;
from EMSsubbs           import EMmk_nat_bdry; /*,EMreduce_range; DLB 10/88*/
from EMScompsurf        import EMcompress_top;
from EMSsfstitch        import EMmake_comp;
from EMSsurface         import EMdisplay_edges, EMmovesurfs, EMpostdelete;
from EMSsfdpr           import EMgetsolidclass;
from GRowner            import GRget_number_components;

extern OMuword OPP_EMSgencompsf_class_id, 
               OPP_EMSsolid_class_id,
               OPP_EMScompsurf_class_id,
               OPP_EMSsurface_class_id,
               OPP_EMSdpr_class_id,
               OPP_EMSsubbs_class_id, 
               OPP_EMSsfstitch_class_id, 
               OPP_EMSslstitch_class_id;
        
method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhhd;
 IGRlong msg = EMS_S_Success;
 IGRint sts=OM_S_SUCCESS,i;

 if (me->num_located)
 { 
   for (i = 0; i < me->num_located; i++)
   { 
     sts = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg, 
                        &me->locate_info.module_info.md_env.matrix_type, 
                        me->locate_info.module_info.md_env.matrix, 
                        &Display_Mode, 
                        &me->locate_info.module_info.md_id),
                   targetid = me->surf_info[i],
                   targetos = me->locate_info.located_obj.osnum);
     ERRORs(sts, msg, "ECmkcompsf_wake draw hi", wrapup);
   }
 }

  {
   IGRboolean       state;

   gr$get_associative_flag( buffer = &state );
   if (state)
   {
     GRdisplay_associative_button(TRUE);
     me->is_associative = TRUE;
   }
  }

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS,msg=EMS_S_Success;

 sts = dp$erase_hilite(msg = &msg);
 ERRORs(sts, msg, "ECmkcompsf_sleep erase hi", wrapup);

 ex$message(msgnumb = EM_M_ClearMessageField)
 ex$message(msgnumb = EMS_I_00000)
 ex$message(msgnumb = EMS_P_00000)

/*
 * Restore the status of the associative button.
 */

 if (me->is_associative) GRdisplay_associative_button(FALSE);

 wrapup:
  return(sts);
}

method execute(int *response; char *response_data; int pos)
{
 IGRlong               msg;
 IGRlong               size = sizeof (struct GRevent);
 IGRint                sts,display_flag;
 IGRint                locate_mask, accept_mask, token, i, j;
 OMuint count;
 IGRint                key;
 enum     GRdpmode     Display_Mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass;
 IGRlong               loc_key, acc_key, reloc_key;

 
#   define NUM_TOKENS 6
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, EX_OBJID, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, init, rem_obj, store_obj, makecs
    };

#   define NUM_STATES 2
    enum states
    {
        start, ck_result
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP DATA      OBJ    STRING   MOVEON   UNK
    old state: */                                   
    /* start    */ {start, start,     start, start, ck_result, start    },
    /* ck_result*/ {start, ck_result, start, start, ck_result, ck_result}
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP   DATA      OBJ      STRING MOVEON  UNK
    old state: */
    /* start    */ {rem_obj, store_obj, store_obj, NIL, makecs, NIL},
    /* ck_result*/ {init,    NIL,       NIL,       NIL, NIL,    NIL}
    }; 


    switch (me->mytype)
    {
    case 1:
        key = EM_M_0103;       /* Force composite surface/solid */
        break;
    default:
        key = EM_M_0104;       /* Make composite surface/solid */
    }
 ex$message(msgnumb = key)

 do
 {
  switch (ME.COconst->action)
  {

   
   case NIL:
   case ERR:
   {
     break;
   }
 

   case init:
   {
    me->num_located = 0;
    me->got_solid = FALSE;
    break;
   }


   case rem_obj:
   {
    if (me->num_located)
    {
      if (me->num_located == 1)
      {
        sts = dp$erase_hilite(msg = &msg);
        ERRORs(sts, msg, "ECmkcompsf_exec erase hi", wrapup);
      }
      else
      {
        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &me->locate_info.module_info.md_env.matrix_type,
                          me->locate_info.module_info.md_env.matrix,
                          &Display_Mode, 
                          &me->locate_info.module_info.md_id),
                    targetid = me->surf_info[me->num_located-1],
                    targetos = me->locate_info.located_obj.osnum);
        ERRORs(sts, msg, "ECmkcompsf_exec erase", wrapup);
      }      
      me->num_located--;

      if (!me->num_located) me->got_solid = FALSE;
    }
    break;
   }

/*

 rlw : 06/02/88 : Reworked this action to try and support fences.

 */
   case store_obj:
   {
    IGRlong             number_of_objects;
    struct              GRlc_info *objects, static_object;
/*
 * Initialize
 */
    number_of_objects = 0;
    objects = NULL;
/*
 * If a set was located then decompose it into leaf nodes ensuring
 * that only surfaces and composite surfaces are present.  Note that
 * I also go through this code if only a single object was located
 * and we have already located some objects.  This is done because
 * the code will discard solids as being not eligible.
 */
    if ((me->locate_event.response == EX_OBJID) || 
         me->num_located)
     {
      OMuword           list1, list2;
      OM_S_CLASSLIST    yes_classes, no_classes;
      extern            IGRlong EMselective_fence();

      list1 = OPP_EMSsurface_class_id;
      yes_classes.w_count = 1;
      yes_classes.p_classes = &list1;
      list2 = OPP_EMSsolid_class_id;
      no_classes.w_count = 1;
      no_classes.p_classes = &list2;
      sts = EMselective_fence(
        &yes_classes,
        &no_classes,
        &me->locate_event.located_object[0],
        FALSE,                  /* Don't break up composites */
        FALSE,                  /* This is not read only */
        my_id,
        &number_of_objects,
        &objects,
        &msg);
       ERRORs(sts, msg, "ECmkcompsf_exec EMselective_fence", wrapup);
     } /* if (me->locate_event.response == EX_OBJID) */
    else
     {
      number_of_objects = 1;
      objects = &static_object;
      OM_BLOCK_MOVE(
       &me->locate_event.located_object[0],
       objects,
       sizeof(struct GRlc_info));
     } /* ELSE FOR if ((me->locate_event.response == EX_OBJID) ... */
/*
 * The first object which we located will determine the
 * object space and module enviroment of all other objects
 * that are located.
 */
    if (number_of_objects &&
        (me->num_located == 0))
     {
      OM_BLOCK_MOVE(
       objects,
       &me->locate_info,
       sizeof(struct GRlc_info));
     } /* If it's the first pass */
/*
 * For each object in the set discard those which
 * have already been located during a previous operation.  Also
 * ensure that we are staying in the same object space, as composites
 * cannot cross object spaces.
 */
    for (i = 0; i < me->num_located; i++)
     {
      for (j = 0; j < number_of_objects; j++)
       {
        if ((me->surf_info[i] == objects[j].located_obj.objid) ||
            (me->locate_info.located_obj.osnum != 
             objects[j].located_obj.osnum))
         {
          IGRlong       number_remaining;

          number_remaining = number_of_objects - (j + 1);
          if (number_remaining)
           {
            OM_BLOCK_MOVE(
             &objects[j + 1],
             &objects[j],
             number_remaining * sizeof(struct GRlc_info));
           } /* if (number_remaining) */
          number_of_objects--;
          j--;                                  /* Stay on this entry */
         } /* If the object is not acceptable */
       } /* for (j = 0; j < number_of_objects; j++) */
     } /* for (i = 0; i < me->num_located; i++) */
/*
 * Loop through each object and determine if it has
 * topology.  If not then construct some.
 */
    if (number_of_objects)
     {
      IGRboolean        put_on_queue, is_primitive_surface = FALSE;
      IGRlong           total_count;
      OM_S_CHANSELECT   to_loopset;

      sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
       ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec make chan sel", wrapup);
      for (i = 0; i < number_of_objects; i++)
       {
        count = 0;
        sts = om$get_channel_count(
          objid = objects[i].located_obj.objid,
          osnum = me->locate_info.located_obj.osnum,
          p_chanselect = &to_loopset,
          count = &count);
         is_primitive_surface = (1 & sts); /* Will fail if not primitive */
        if (is_primitive_surface &&
            (count == 0))
         {
          sts = om$send(
            msg = message EMSsubbs.EMmk_nat_bdry(
             &msg, 
             &me->locate_info.module_info.md_env,
             NULL), 
            targetid = objects[i].located_obj.objid,
            targetos = me->locate_info.located_obj.osnum);
           ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec mknat bdry", wrapup);
         } /* if (!count) */
       } /* for (i = 0; i < number_of_objects; i++) */
/*
 * Determine if the element located was a solid.
 */
      if ((number_of_objects == 1) &&   /* Located only 1 object */
          (me->num_located == 0) &&     /* No previously located objects */
          (! is_primitive_surface))     /* Not a primitive surface */
       {
        OMuword         comp_classid;

        sts = om$get_classid(
          objid = objects[0].located_obj.objid,
          osnum = me->locate_info.located_obj.osnum,
          p_classid = &comp_classid);
         ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec get_classid", wrapup);
        sts = om$is_ancestry_valid(
          subclassid = comp_classid,
          superclassid = OPP_EMSsolid_class_id);
         ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec is_ancestry", wrapup);
        me->got_solid = (sts == OM_S_SUCCESS);

        if (me->got_solid)
        {
          ex$message(msgnumb = EMS_I_SolidNtAllw);
          sts = dp$erase_hilite(msg = &msg);
          ME.super_cmd->state = start;
          me->got_solid = FALSE;
          me->num_located = 0;
          break;
        }

       } /* Find out if we located a solid */
/*
 * Add the processed element set to the processed list.
 */
      put_on_queue = (me->num_located &&
       (me->locate_event.response != EX_OBJID));
      total_count = me->num_located + number_of_objects + 2; /* Conservative */
      sts = om$vla_set_dimension(
        varray = me->surf_info,
        size = total_count);
       ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec expand vla", wrapup);
      for (i = 0; i < number_of_objects; i++)
       {
        me->surf_info[me->num_located] = objects[i].located_obj.objid;       
        me->num_located = me->num_located + 1;
       } /* for (i = 0; i < number_of_objects; i++) */
/*
 * Put the accept event on the queue if the object
 * was not a specified object (fence).
 */
      if (put_on_queue)
       {
        sts = ex$putque(
          msg = &msg, 
          response = response, 
          byte = &size,
          buffer = (IGRchar *) &me->locate_event.event);
        ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec put que", wrapup);
       } /* if (put_on_queue) */
     } /* if (number_of_objects) */
/*
 * Erase the highlighed object and tell the operator 
 * if we have thrown everything away.  Note that fences
 * do not need to be erased as they are never highlighted.
 */
    else
     {
      if (me->locate_event.response != EX_OBJID)
       {
        if (me->num_located)
         {
          struct        GRlc_info *info;

          info = &me->locate_event.located_object[0];
          Display_Mode = GRhe;
          sts = om$send(
            msg = message GRgraphics.GRdisplay(
             &msg,
             &info->module_info.md_env.matrix_type,
             info->module_info.md_env.matrix,
             &Display_Mode, 
             &info->module_info.md_id),
            targetid = info->located_obj.objid,
            targetos = info->located_obj.osnum);
          ERRORs(sts, msg, "ECmkcompsf GRdisplay", wrapup);
         } /* if (me->num_located) */
        else
         {
          sts = dp$erase_hilite(
            msg = &msg);
           ERRORs(sts, msg, "ECmkcompsf erase hilite", wrapup);
         } /* ELSE FOR if (me->num_located) */
       } /* if (me->locate_event.response != EX_OBJID) */
      ex$message(msgnumb = EMS_I_00092)
      ems_sleep(2);
     }
/*
 * Free the memory
 */
    if (objects &&
        (objects != &static_object)) free(objects);
/*
 * If we have a solid then we want to just proceed to
 * the make composite surface action, otherwise break.
 */
    if (!me->got_solid) break;
   } /* case store_obj: */


   case makecs:
   {
    OMuword    ele_classid;      /*DECL*/
    IGRboolean got_dpr=FALSE, got_subbs = FALSE;

#ifdef MODEL14
    IGRboolean create_shell = FALSE;
    IGRushort makecs_opt = NULL;
#endif

    sts = dp$erase_hilite(msg = &msg);
    ERRORs(sts, msg, "ECmkcompsf_exec erase hi", wrapup);

    /*Use the first element.*/
    me->construct_id.objid = me->surf_info[0];
    me->construct_id.osnum = me->locate_info.located_obj.osnum;

    sts = om$get_classid(objid = me->construct_id.objid,
                         osnum = me->construct_id.osnum,
                         p_classid = &ele_classid);
    ERRORs(sts, EMS_S_Success, "get_classid", wrapup);
      
    /*Is it a single surface?*/

    sts = om$is_ancestry_valid(superclassid = OPP_EMSsubbs_class_id,
                               subclassid = ele_classid);
    ERRORs(sts, EMS_S_Success, "is ancestry valid", wrapup);

    if (sts == OM_S_SUCCESS) got_subbs = TRUE;

/*******************************
    if (sts == OM_S_SUCCESS && me->num_located == 1) 
    {
      ME.super_cmd->state = start;
      me->num_located = 0;
      UI_status("Only one surface identified."); 
      break; 
    }
********************************/

    /*Is a DPR?*/
    sts = om$is_ancestry_valid(superclassid = OPP_EMSdpr_class_id,
                               subclassid = ele_classid);
    ERRORs(sts, EMS_S_Success, "is ancestry valid", wrapup);

    if (sts == OM_S_SUCCESS) got_dpr = TRUE; /*Yes.*/

    /*Set the default class for possible use in call to EFmksolid.*/
    strcpy(me->newclass, "EMSslstitch");

    if (me->got_solid)
    {
      IGRchar new_classname[OM_K_MAXCLASS_LEN];

      /*Get the proper composite surface class to change the solid to.*/
      if (got_dpr)
      {
        sts = om$get_parent_classname(classid = ele_classid,
                                      parent_classname = new_classname);
        ERRORs(sts, EMS_S_Success, "get parent classname", wrapup);
      }
      else
        strcpy(new_classname, "EMSgencompsf");  /*DLB change 11/04/88.*/

      /*Convert the solid to composite surface (or comp surf DPR).*/

      if (EMcheck_inhibit_postproc())
        {
        IGRlong msg_loc;

        om$send (msg = message EMSsurface.EMpostdelete (&msg_loc,
         EMS_POST_NOCOMPONENTS, &me->locate_info.module_info, NULL, NULL),
         targetid = me->construct_id.objid, targetos = me->construct_id.osnum);
        EMrestore_postproc();
        }

      sts = om$change_class(objid = me->construct_id.objid,
                            osnum = me->construct_id.osnum,
                            classname = new_classname);
      ERRORs(sts, EMS_S_Success, "change class to cs", wrapup);

      ex$message(msgnumb = EMS_I_00091)
    }
    else 
    {
      struct GRvg_construct construct_list;    /*DECL*/

#ifdef MODEL14
      if(me->num_located == 1)
       {
        /*Got 1 composite surface, so get the proper solid class 
         * for possible use during the call to EFmksolid.
         */
        if (got_dpr)
         {
          sts = om$send(msg = message EMSsfdpr.EMgetsolidclass(&msg, 
                            me->newclass),
                      targetid = me->construct_id.objid,
                      targetos = me->construct_id.osnum);
	  if(!(1&msg&sts)) create_shell = TRUE;
          ERRORs(sts, EMS_S_Success, "getsolidclass", wrapup); 
         }      
        else
         {
	  if(got_subbs) strcpy(me->newclass, "EMSsfsolid");
	  else
	   {
            sts = om$send(msg = message GRowner.GRget_number_components(&msg, 
                            &count),
                      targetid = me->construct_id.objid,
                      targetos = me->construct_id.osnum);
            ERRORs(sts, EMS_S_Success, "get num comps", wrapup); 

            if (count == 1) strcpy(me->newclass, "EMSsfsolid");
            else strcpy(me->newclass, "EMSgensolid");;
	   }
	 }
       }

#endif MODEL14
      construct_list.msg        = (IGRlong *)&msg;
      construct_list.class_attr = NULL;       /* use defaults */
      construct_list.level      = ME.COconst->ActiveLevel;
      construct_list.display    = &ME.COconst->ActiveDisplay;
      construct_list.env_info   = &me->locate_info.module_info;
      construct_list.newflag    = FALSE;
      construct_list.name       = NULL;
      construct_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.geometry   = NULL;


#ifdef MODEL14

      sts = om$construct(classid = OPP_EMSsfstitch_class_id,
                         p_objid = &me->construct_id.objid,
                         osnum = me->construct_id.osnum,
                         msg = message GRgraphics.GRconstruct(&const));
      ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec construct", wrapup);

      ex$message(msgnumb = EMS_I_00003);
      ex$message(msgnumb = EMS_P_ClearPromptField);
      makecs_opt = /*EMSmakecs_FineToCoarseTol;*/ NULL;
      if(create_shell) makecs_opt |= EMSmakecs_CreateShell;
      /*else makecs_opt = NULL;*/
      sts = om$send(msg = message EMSsfstitch.EMmake_comp(&msg, 
                          me->num_located, me->surf_info,
                          &me->locate_info.module_info, NULL, NULL, 0, 
			  NULL, makecs_opt),
                    targetid = me->construct_id.objid,
                    targetos = me->construct_id.osnum);
#else
      ex$message(msgnumb = EMS_I_00003);
      ex$message(msgnumb = EMS_P_ClearPromptField);

      /* call an associative function to construct the compsurf */
/*****************************************************************************
      sts = EFmake_comp_surf(&msg, 
                             (me->is_associative ? NULL : 
                               EMSasconst_notassociative),
                              me->num_located, me->surf_info,
                             &construct_list, &me->construct_id);
*****************************************************************************/
      sts = ems$make_comp_surf(msg = &msg,
             options = (me->is_associative ? NULL : EMSasconst_notassociative),
                               num_surfs = me->num_located,
                               surfaces = me->surf_info,
                              construction_list = &construct_list,
                       comp_surface = &me->construct_id); 
#endif

      if( (msg == EMS_E_NoDynamicMemory) || 
          (msg == EMS_E_DynamicMemoryAllocated))
       {
	ex$message(msgnumb = EMS_E_NoMemFewElem);
        msg = EMS_S_Success;
        sts = OM_S_SUCCESS;
        ME.super_cmd->state = start;
       }
      else
       {
	if(msg != EMS_E_IntersectOrient)
	 {
          ERRORs(sts, msg, "ECmkcompsf_exec make_comp", wrapup);
         }
      
        if ( (msg == EMS_I_Fail) || (msg == EMS_E_IntersectOrient))
                             /*Stitch failed.*/
         {
          OM_S_CHANSELECT       to_comps;  /*DECL*/

          if(msg == EMS_I_Fail)
           {
            ex$message(msgnumb = EMS_I_00090);
           }
          else
           {
            ex$message(msgnumb = EMS_I_BadOrntNoComp);
            msg = EMS_S_Success;
            sts = OM_S_SUCCESS;
           }

          sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
          ERRORs(sts, EMS_S_Success, "ECmkcompsf_exec mk chan sel", wrapup);

          sts = om$get_channel_count(objid = me->construct_id.objid,
                                   osnum = me->construct_id.osnum,
                                   p_chanselect = &to_comps,
                                   count = &count);
          ERRORs(sts, EMS_S_Success, "exec get chan count", wrapup);
  
          if (!count)
           {
            /*Delete composite object.*/
            sts = om$send(msg = message Root.delete(0),
                        targetos = me->construct_id.osnum,
                        targetid = me->construct_id.objid);
            ERRORs(sts, msg, "ECmkcompsf_exec rt del", wrapup);
           }
          if(me->num_located == 1)
           {
            me->construct_id.objid = me->surf_info[0];
            me->construct_id.osnum = me->locate_info.located_obj.osnum;
           }
          else ME.super_cmd->state = start;
         }
        else  /*It worked.*/
         { 
          if(msg == EMS_I_Interrupt)
           {
            ex$message(msgnumb = EMS_I_ProcessingInterrupt);
            ems_sleep(3);
           }
          ex$message(msgnumb = EMS_I_00091)

         }  /* Comp surf made */
       }

    } /*stitch op*/

    if (me->got_solid)
    {
      ME.super_cmd->state = start;
      me->got_solid = FALSE;
    }

    me->num_located = 0;
    break;
   }


   default:
   {
     ERRORs(OM_E_ABORT, EMS_E_Fail, "action garbage", wrapup);
     break;
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {

   case start:
   {

    /*Set proper locate prompt*/
    if (me->num_located < 1)
    {
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID;
      loc_key = EMS_P_00134;
      acc_key = EMS_P_AccSfSl;
      reloc_key = EMS_I_SfSlNotLocated;
      display_flag = ALL_WINDOWS | ELEM_HILIGHT |
        NO_PROJ_ACCEPT_POINT | LC_ERASE_ALL;
    }
    else
    {
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_RJT_MOVEON;
      loc_key = EMS_P_IdSfStEnough;
      acc_key = EMS_P_AccwSf;
      reloc_key = EMS_I_00011;
      display_flag = ALL_WINDOWS | ELEM_HILIGHT |
        NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;
    }

    /*Set proper accept prompt*/
    accept_mask = GRm_DATA;   

    attr.properties = 
     LC_LC_ONLY         |       /* Locate locatable objects */
     LC_DP_ONLY         |       /* Locate displayable objects */
     IGN_MOD_BIT        |       /* Ignore modified and new props */
     IGN_PLANAR_BIT     |       /* Ignore planar checks */
     LC_WRITE_ONLY;             /* I am going to change is guy */
    attr.owner_action = 
     LC_ASSOCIATIVE     |       /* Associative elements */
     LC_EXTERN_CONSTRAINED |    /* Externally constrained assoc elements */
     LC_RIGID_OWNER     |       /* Composites */
     LC_FLEX_OWNER      |       /* Graphic groups, etc. */
     LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
     LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
     LC_NO_REF_HEADER;          /* No reference file headers */
/*
 rlw : 06/02/88 : Replaced the code in this comment block with
                  the above code.

    attr.properties = 0x11 | LC_RW;
    attr.owner_action = 0x6;
    strcpy(attr.classes, "EMSsurface");
 */
    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsurface_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;
/*
 * Call the graphic set deposit function.  This will help
 * us weed out garbage from the fence.
 */
    sts = gr$gsput_locate_criteria(
      msg = &msg,
      attributes = &attr,
      rtree_classes = &rtree_classes,
      eligible_classes = &elig_classes);
     ERRORs(sts, msg, "ECmkcompsf_exec gsput_locate_criteria", wrapup);
/*
 * End of graphic set deposit
 */
#   if DEBUG
    (void)print_queue ();
#   endif
/*
 * Modified to call an action handler which mark already located
 * objects as not eligible for locate.
 *
 * 09/26/88 : rlw
 */
   {
    extern      IGRlong EFlocate_action_handler();
    struct      EMSaction_handler already_located;

    already_located.next = NULL;
    already_located.option = 0;
    already_located.type = 2;
    already_located.num_objects = me->num_located;
    already_located.objects.same_space.space_number = 
     me->locate_info.located_obj.osnum;
    already_located.objects.same_space.objid = &me->surf_info[0];
    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->locate_event,
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhhd,
              locate_key = loc_key, 
              acc_key = acc_key,
              relocate_key = reloc_key, 
              attributes = &attr, 
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
   }

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;
   }


   case ck_result:
   {
     {
       IGRushort options;  /*DECL*/

       msg = EMS_S_Success;

        switch (me->mytype)
        {
        case 1:
            options = EMS_CHECK_CLOSURE;
            break;
        default:
            /* Formerly, this was the only way this CO did it. */
            options = EMS_CHECK_CLOSURE | EMS_ASK_CONVERT;
        }

       sts = EFmksolid(&msg, &me->locate_info.module_info, 
                       &ME.COconst->ActiveDisplay, &me->construct_id,
                       &me->locate_event, response, response_data, Tokens,
                       options, me->newclass, NULL);
       ERRORs(sts, msg, "ECmkcompsf_exec EFmksolid", wrapup);     
     }

    /* If we do not ask, the locate_event will still be whatever
        it was after the location. -- jBk */
     token = GRloc_token(&msg, Tokens, &me->locate_event);

     if (msg == EMS_I_NoResponse)
     {
      sts = dp$erase_hilite(msg = &msg);
      ERRORs(sts, msg, "ECmkcompsf_exec erase hi", wrapup);
/* 
   rlw 09/28/88 - Removed this display logic and added erase
                  highlight plane logic.

       IGRint edge_count;
       sts = om$send(msg = message EMSsurface.EMdisplay_edges(&msg, 
                           &me->locate_info.module_info,
                           EMS_OPT_CONNECTABLE, GRhe, &edge_count),
                     targetid = me->construct_id.objid,
                     targetos = me->construct_id.osnum);
       ERRORs(sts, msg, "ECmkcompsf_exec EMdisplay_edges", wrapup);     
 */
       ex$message(msgnumb = EMS_I_00000)
     }
     break;
   }


   default:
   {
    ERRORs(OM_E_ABORT, EMS_E_Fail, "ECmkcompsf_exec state garbage", wrapup);
    break;
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return sts;

 wrapup:
  ex$message(msgnumb = EMS_F_0002)
  *response = TERMINATE;
  return(OM_E_ABORT);

}
end implementation ECmkcompsf;
