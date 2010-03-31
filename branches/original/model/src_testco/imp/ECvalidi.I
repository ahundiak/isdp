/* ###################   APOGEE COMPILED   ################## */
class implementation ECvalid;

/*
DESCRIPTION

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

HISTORY

	SM	01-Jun-89	Reworked RV's CO to support sets, added 
				AUTO_CORRECT type etc etc. Used the
				make compsf CO as a base to write this
				CO.
      Vadiraj   06/05/92        Modified for message subsystem compliance.
        scw     08/14/94        Clarified sleep method
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
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMSaction.h"  /* Structure definition for select handler */
#include "emsdef.h"


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
from EMSsurface		import EMvalidate;
from OMObjSpace import pass;

extern OMuword OPP_EMSsurface_class_id,
               OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id, 
	       OPP_GRowner_class_id, OPP_GRcurve_class_id, 
	       OPP_EMSsplit_class_id;
	
#define VALIDATE	0
#define AUTO_CORRECT	1
#define NO_EDGE_MATCH	2


method init (IGRint type; IGRchar *string)
{
 IGRlong sts;

 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message COconst.init(type, string), 
	       targetid = my_id);
	
 me->num_located = 0;
 me->stdreportonly = FALSE;
 return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhhd;
 IGRint sts=OM_S_SUCCESS,i;
 IGRlong msg=EMS_S_Success;
 IGRshort *mxt;
 IGRdouble *mx;
 struct GRid	id;
 
 mxt = &me->ModuleInfo.md_env.matrix_type;
 mx = me->ModuleInfo.md_env.matrix;	

 for (i = 0; i < me->num_located; i++)
  { 
   id = me->locate_info[i].located_obj;
   sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
			mxt, mx, &Display_Mode, &me->ModuleInfo.md_id), 
                   targetid = id.objid, 
                   targetos = id.osnum);
   ERRORs(sts, msg, "ECvalid_wake draw hi", wrapup);
  }
 
 if(ME.super_cmd->mytype == VALIDATE)
  ex$message(msgnumb = EM_M_ValdtSfOrSolidMod)
 else if(ME.super_cmd->mytype == AUTO_CORRECT)
  ex$message(msgnumb = EM_M_AutCrrctSfSolidMod)
 else
  ex$message(msgnumb = EM_M_VldtSfSolidModWthOtEdgMtch);

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 sts = dp$erase_hilite(msg = &msg);
 ERRORs(sts, msg, "ECvalid_sleep erase hi", wrapup);

 ex$message(msgnumb = EM_M_ClearMessageField)
 ex$message(msgnumb = EMS_I_00000)
 ex$message(msgnumb = EMS_P_00000)

 wrapup:
  return(sts);
}

method execute(int *response; char *response_data; int pos)
{
 IGRint                sts=OM_S_SUCCESS, display_flag;
 IGRlong               size=sizeof(struct GRevent), msg;
 IGRint                locate_mask, accept_mask, token = 0, i, j;
 enum     GRdpmode     Display_Mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass[2];
 IGRlong               loc_key, acc_key, reloc_key;
 IGRshort	       *mxt;
 IGRdouble	       *mx;
 extern IGRboolean	IGEstop();

#   define NUM_TOKENS 6
    static int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, EX_OBJID, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, rem_obj, store_obj
    };

#   define NUM_STATES 3
    enum states
    {
        start, filename, validate
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:        BACK_UP DATA      OBJ      STRING   MOVEON      UNK
    old state: */                                   
    /* start    */   {start, start,    start,    start,   filename,   start},
    /* filename */   {start, filename, filename, validate, validate,filename}, 
    /* validate */    {start, start,    start,    start,   start,    start}
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP   DATA      OBJ       STRING       MOVEON   UNK
    old state: */
    /* start    */ {rem_obj, store_obj, store_obj, store_obj,   NIL,   NIL},
    /* filename */ {NIL,      NIL,      NIL,       NIL,         NIL,   NIL}, 
    /* validate */ {NIL,      NIL,      NIL,       NIL,         NIL,   NIL}
    }; 

 mxt = &me->ModuleInfo.md_env.matrix_type;
 mx = me->ModuleInfo.md_env.matrix;	

 do
 {
  switch (ME.COconst->action)
  {
   case NIL:
   case ERR:
   {
     break;
   }


   case rem_obj:
   {
    struct GRlc_info *junk;
    junk = me->num_located ? &me->locate_info[me->num_located - 1] : NULL;

    if (me->num_located == 1)
     {
      sts = dp$erase_hilite(msg = &msg);
      ERRORs(sts, msg, "ECvalid_exec erase hi", wrapup);
     }
    else if (me->num_located)
     {
      Display_Mode = GRhe;
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			  mxt, mx, &Display_Mode, &me->ModuleInfo.md_id),
                    targetid = junk->located_obj.objid,
                    targetos = junk->located_obj.osnum);
      ERRORs(sts, msg, "ECvalid_exec erase", wrapup);
     }
    if(me->num_located) me->num_located--;
    break;
   }

   case store_obj:
   {
    IGRlong             number_of_objects;
    struct              GRlc_info *objects, static_object;
    extern            IGRlong EMunwind_stupid_sets();
    OMuword           list1, list2;
    OM_S_CLASSLIST    yes_classes, no_classes;
    extern            IGRlong EMselective_fence();

    number_of_objects = 0;
    objects = NULL;

    /*
     * If a set was located then decompose it into leaf nodes ensuring
     * that only surfaces and composite surfaces are present. 
     */


    list1 = OPP_EMSsurface_class_id;
    yes_classes.w_count = 1;
    yes_classes.p_classes = &list1;
    list2 = OPP_GRcurve_class_id;
    no_classes.w_count = 1;
    no_classes.p_classes = &list2;
    sts = EMselective_fence(
        &yes_classes,
        &no_classes,
        &me->locate_event.located_object[0],
        FALSE,                  /* Don't break up composites */
        TRUE,                  /* This is read only */
        my_id,
        &number_of_objects,
        &objects,
        &msg);
       ERRORs(sts, msg, "ECmkcompsf_exec EMselective_fence", wrapup);

  /*
   * For each object in the set discard those which
   * have already been located during a previous operation.
   */
  for (i = 0; i < me->num_located; i++)
   for (j = 0; j < number_of_objects; j++)
    {
     struct GRid junk;
	
     junk = me->locate_info[i].located_obj;
	
     if ((junk.objid == objects[j].located_obj.objid) &&
            (junk.osnum == objects[j].located_obj.osnum))
      {
       IGRlong       number_remaining;

       number_remaining = number_of_objects - (j + 1);
       if (number_remaining)
        OM_BLOCK_MOVE(&objects[j + 1], &objects[j],
             number_remaining * sizeof(struct GRlc_info));
       number_of_objects--;
       j--;                                  /* Stay on this entry */

      } /* If the object is not acceptable */

    } /* for (j = 0; j < number_of_objects; j++) */


  if (number_of_objects)
   {
    IGRboolean        put_on_queue;
    IGRlong           total_count;

    /*
     * Add the processed element set to the processed list.
    */
    put_on_queue = me->locate_event.response != EX_OBJID;
    total_count = me->num_located + number_of_objects + 2; /* Conservative */
    sts = om$vla_set_dimension(varray = me->locate_info,
        size = total_count);
    ERRORs(sts, EMS_S_Success, "ECvalid_exec expand vla", wrapup);

    OM_BLOCK_MOVE(objects, &me->locate_info[me->num_located], 
		number_of_objects * sizeof(struct GRlc_info));
    me->num_located += number_of_objects;

    /*
     * Put the accept event on the queue if the object
     * was not a specified object (fence).
    */

    if (put_on_queue)
     {
      sts = ex$putque(msg = &msg, response = response, byte = &size,
          	      buffer = (char *)&me->locate_event.event);
      ERRORs(sts, EMS_S_Success, "ECvalid_exec put que", wrapup);
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
	struct GRid	id;

        id = me->locate_event.located_object[0].located_obj;
        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
	     mxt, mx, &Display_Mode, &me->ModuleInfo.md_id), 
            targetid = id.objid, targetos = id.osnum);
        ERRORs(sts, msg, "ECvalid GRdisplay", wrapup);

       } /* if (me->num_located) */
      else
        sts = dp$erase_hilite(msg = &msg);

     } /* if (me->locate_event.response != EX_OBJID) */

    ex$message(msgnumb = EMS_I_00092)
    sleep(2);
   }
   /*
    * Free the memory
   */
   if (objects && (objects != &static_object)) free(objects);
     break;

    } /* case store_obj: */

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
    locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_SPECIFIED_OBJ
		  | GRm_TEXT_VALUE; 
    if(me->num_located) locate_mask |= GRm_RJT_MOVEON;
    loc_key = me->num_located ? EMS_P_IdSfSlEnough : EMS_P_00134;
    acc_key = EMS_P_AccwSfSl;
    reloc_key = EMS_I_SfSlNotLocated;		
    display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | 
		   LC_ERASE_ALL;
    accept_mask = GRm_DATA | GRm_TEXT_VALUE;   

    attr.properties = 
     LC_LC_ONLY         |       /* Locate locatable objects */
     LC_DP_ONLY         |       /* Locate displayable objects */
     IGN_MOD_BIT        |       /* Ignore modified and new props */
     IGN_PLANAR_BIT     |       /* Ignore planar checks */
     LC_RW;             	/* I am only going to read*/
    attr.owner_action = 
     LC_RIGID_OWNER     |       /* Composites */
     LC_RIGID_COMP  	|	/* Members of composites */
     LC_FLEX_OWNER      |       /* Graphic groups, etc. */
     LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
     LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
     LC_NO_REF_HEADER;          /* No reference file headers */

    rtree_classes.w_count = 1;
    elig_classes.w_count = 2;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass[0] = OPP_EMSsurface_class_id;
    eliclass[1] = OPP_GRowner_class_id;	/* Groups */

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass[0];
    /*
     * Call the graphic set deposit function.  This will help
     * us weed out garbage from the fence.
    */
    sts = gr$gsput_locate_criteria(
      msg = &msg,
      attributes = &attr,
      rtree_classes = &rtree_classes,
      eligible_classes = &elig_classes);
     ERRORs(sts, msg, "ECvalid_exec gsput_locate_criteria", wrapup);

    /*
     * call an action handler to mark already located
     * objects as not eligible for locate.
    */
   {
    extern      IGRlong EFlocate_action_handler();
    struct      EMSaction_handler already_located;

    already_located.next = NULL;
    already_located.option = 0;		/* Don't locate objects in list*/
    already_located.type = 0;		/* passing GRlc_info's */
    already_located.num_objects = me->num_located;
    for(i=0; i<me->num_located; i++)
     already_located.objects.lc_info[i] = &me->locate_info[i];

    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->locate_event,
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= (int *)&size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_key = loc_key, 
              acc_key = acc_key,
              relocate_key = reloc_key, 
              attributes = &attr, 
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes, 
	      regex = TRUE);	/* regular expressions */
   }

  token = GRloc_token(&msg, Tokens, &me->locate_event);
  break;
 }

   case filename:
   {
    FILE	*ptr = NULL;

    ex$message(msgnumb = EMS_P_ReportFileName);
    locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
    token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, (int *)&size, 
                         response, response_data);
    ex$message (msgnumb = EMS_I_ClearStatusField);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
         me->stdreportonly = TRUE;
    else if(Tokens[token] == STRING)  
     {
      strcpy(me->filename, me->locate_event.event.keyin);
      me->stdreportonly = FALSE;
      ptr = fopen(me->filename, "r");
      if(ptr)
       {
        ex$message(msgnumb = EMS_I_FileExistsWillApp);
        sleep(3);
        fclose(ptr);
       }
     }
    break;
   }


   case validate:
   {
    IGRushort	option = NULL;
    IGRint		i;
    IGRchar		str[MS_MAX_MSG_LENGTH+1];
    struct GRid		id;
    GRobjid		cancer;
    OMuword		gen_classid;
    FILE		*ptr = NULL;

    sts = dp$erase_hilite(msg = &msg);
    ERRORs(sts, msg, "ECvalid_exec erase hi", wrapup);
    ex$message (msgnumb = EMS_P_ClearPromptField);
    if(ME.super_cmd->mytype == NO_EDGE_MATCH) option = NULL;
    else option = EMSvalidateEdgeMatch;
    if(ME.super_cmd->mytype == AUTO_CORRECT) option |= EMSvalidateAutoCorrect;

    if(!me->stdreportonly)
     ptr = fopen(me->filename, "a");
    else ptr = NULL;

    for(i=0; i<me->num_located; i++)
     {
      cancer = NULL_OBJID;

      if(IGEstop())
       {
        ex$message(msgnumb = EMS_I_ProcessingInterrupt);
        sleep(2);
        break;
       }

      id = me->locate_info[i].located_obj;
      sprintf(str, "Processing element %d out of %d [OID=%d]", 
       i+1, me->num_located, id.objid);
      UI_status (str);

      sts = om$get_classid(objid = id.objid, osnum = id.osnum,
                  p_classid = &gen_classid);
      sts = om$is_ancestry_valid(subclassid = gen_classid,
                                superclassid = OPP_EMSsolid_class_id);
      if (sts == OM_S_SUCCESS) option |= EMSvalidateSolid;
      else {sts = OM_S_SUCCESS; option &= ~EMSvalidateSolid;}

      /* Do not change the auto correct bit if mytype is not
         AUTO_CORRECT. This is because for a particular element, after
	 a defect was reported, the user might have picked the 'a' option
	 indicating auto correction after that point. Carry over this option
	 to the next element also.
      */

      sts = om$send(msg = message GRgraphics.EMvalidate(&msg,
                            &me->locate_info[i].module_info, NULL,
			    &cancer, &option, NULL, (char *)ptr),
                       targetid = id.objid, targetos = id.osnum);

      if(msg == EMS_I_Interrupt)
      {
        UI_status ("Validation process interrupted...");
        sleep(2);
        break;
      }

      else if (EMSerror (sts & msg))
      {
        sprintf(str, "Could not validate -- %d ...skipping [OID=%d]", 
         i+1, id.objid);
        UI_status (str);
        sleep(2);
      }

      else if(!IF_NULL_OBJID(cancer))
      {
        sprintf(str, "Defect(s) exists -- %d ... [OID=%d]", 
         i+1, id.objid);
        UI_status (str);
        sleep(2);
      }

      else 
      {
        sprintf(str, "Element seems valid -- %d ... [OID=%d]", 
         i+1, id.objid);
        UI_status (str);
        sleep(2);
      }
    }

    me->num_located = 0;
    me->stdreportonly = FALSE;
    if(ptr) fclose(ptr);
    break;
   }


   default:
   {
    ERRORs(OM_E_ABORT, EMS_E_Fail, "ECvalid_exec state garbage", wrapup);
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



end implementation ECvalid;
