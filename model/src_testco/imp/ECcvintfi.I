/* ###################   APOGEE COMPILED   ################## */
class implementation ECcvintf;

#include "EMS.h"
/*
DESCRIPTION

This command object shows the interfernce between 2 curves.
1) If the curves intersect it displays line segments at the maximum
   interference between the curves.
2) If the curves do not intersect -
   a) if cv1 and cv2 are not nested, it displays the minimum clearence between
      the two curves.
   b) if the curves are nested, it displays the minimum and the maximum
      interference between the two curves.

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

HISTORY

    Tapadia 05/21/92  Modified for message sub system compliance
		      Also changed the status from "No Can Do" to 
		      "Possible Math Error"
    Sudha   07/05/93  Modified for BSprototypes ansification
    scw     08/14/94  clarified sleep method

*/

# ifndef DEBUG
# define DEBUG 0
# endif

#define INTERSECT	0
#define NESTED		1
#define DISJOINT	2

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
#include "EMSintf.h"
#include "bserr.h"
#include "bsvcdst2cvs.h"
#include "bsmxdstcvcv.h"
#include "bsmdistcvcv.h"

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

extern OMuword OPP_EMSsurface_class_id, OPP_GRcurve_class_id;

method init (IGRint type; IGRchar *string)
{
 IGRlong sts=OM_S_SUCCESS;

 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message COconst.init(type, string), 
	       targetid = my_id);
	
 me->num_located = 0;
 return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhhd;
 IGRint  sts=OM_S_SUCCESS,i;
 IGRlong msg=EMS_S_Success;

 if (me->num_located)
 { 
   for (i = 0; i < me->num_located; i++)
   { 
     sts = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg, 
			&me->ModuleInfo.md_env.matrix_type, 
			me->ModuleInfo.md_env.matrix, 
                        &Display_Mode, 
			&me->ModuleInfo.md_id),
                   targetid = me->locate_info[i].located_obj.objid, 
                   targetos = me->locate_info[i].located_obj.osnum);
     ERRORs(sts, msg, "ECcvintf_wake draw hi", wrapup);
   }
 }
 if(ME.super_cmd->mytype == INTERSECT)
	ex$message(msgnumb = EM_M_CvIntIntersect)
 else if(ME.super_cmd->mytype == NESTED)
	ex$message(msgnumb = EM_M_CvIntNested)
 else
  {
	ex$message(msgnumb = EM_M_CvIntDisjoint);
   	ME.super_cmd->mytype = DISJOINT;
  }

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint  sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 sts = dp$erase_hilite(msg = &msg);
 ERRORs(sts, msg, "ECcvintf_sleep erase hi", wrapup);

 ex$message(msgnumb = EM_M_ClearMessageField)
 ex$message(msgnumb = EMS_I_00000)
 ex$message(msgnumb = EMS_P_00000)

 wrapup:
  return(sts);
}


method execute(int *response; char *response_data; int pos)
{
 IGRint                sts=OM_S_SUCCESS, display_flag;
 IGRlong               msg;
 IGRlong               size=sizeof(struct GRevent);
 IGRint                locate_mask, accept_mask, token = 0, i;
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
         NIL, ERR, rem_obj, store_obj
    };

#   define NUM_STATES 2
    enum states
    {
        start, analyze
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:        BACK_UP DATA      OBJ    STRING   MOVEON      UNK
    old state: */                                   
    /* start    */   {start, start,    start,  start,   start,    start},
    /* analyze */    {start, start,    start,  start,   start,    start}
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP   DATA      OBJ       STRING       MOVEON   UNK
    old state: */
    /* start    */ {rem_obj, store_obj, store_obj, store_obj,  store_obj, NIL},
    /* analyze */  {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}
    }; 

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
    if (me->num_located)
    {
      struct GRlc_info *junk;
      junk = &me->locate_info[me->num_located - 1];

      if (me->num_located == 1)
      {
        sts = dp$erase_hilite(msg = &msg);
        ERRORs(sts, msg, "ECcvintf_exec erase hi", wrapup);
      }
      else
      {
        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			  &me->ModuleInfo.md_env.matrix_type, 
			  me->ModuleInfo.md_env.matrix, 
                          &Display_Mode, 
			  &me->ModuleInfo.md_id), 
                    targetid = junk->located_obj.objid,
                    targetos = junk->located_obj.osnum);
        ERRORs(sts, msg, "ECcvintf_exec erase", wrapup);
      }
      me->num_located--;
    }
    break;
   }


   case store_obj:
   {
    IGRboolean          put_on_queue;

    put_on_queue = me->num_located < 1 ? TRUE : FALSE;
    OM_BLOCK_MOVE(&me->locate_event.located_object[0], 
	          &me->locate_info[me->num_located], sizeof(struct GRlc_info));
    me->num_located++;
    if (me->num_located < 2)
     {
      sts = ex$putque(msg = &msg, response = response, byte = &size,
          	      buffer = (char *)&me->locate_event.event);
      ERRORs(sts, EMS_S_Success, "ECcvintf_exec put que", wrapup);

     } /* if (put_on_queue) */

    if(me->num_located > 1) ME.super_cmd->state = analyze;
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
		  | GRm_TEXT_VALUE; /* element name */
		
    loc_key = EMS_P_00036; /* Identify planar curve */
    acc_key = me->num_located ? EMS_P_00038 /* Accept/reject */
			     : EMS_P_00045; /* Accept with next curve/reject */
    reloc_key = EMS_I_00013;		/* element not found */
    display_flag = ALL_WINDOWS | ELEM_HILIGHT |
        NO_PROJ_ACCEPT_POINT | LC_ERASE_ALL;

    /*Set proper accept prompt*/
    accept_mask = GRm_DATA | GRm_TEXT_VALUE;   

    attr.properties = 
     LC_LC_ONLY         |       /* Locate locatable objects */
     LC_DP_ONLY         |       /* Locate displayable objects */
     IGN_MOD_BIT        |       /* Ignore modified and new props */
     IGN_PLANAR_BIT     |       /* Ignore planar checks */
     LC_RW;             	/* I am only going to read*/
    attr.owner_action = 
     LC_RIGID_COMP  	|	/* Members of composites */
     LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
     LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
     LC_NO_REF_HEADER;          /* No reference file headers */

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_GRcurve_class_id;
    eliclass = OPP_GRcurve_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;
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
              eventsize= (IGRint *)&size, 
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
              eligible_classes = &elig_classes, 
	      regex = TRUE);	/* regular expressions */
   }

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;
   }

   case analyze:
   {
    struct GRvg_construct konst;
    IGRlong		rc;
    struct IGRbsp_curve	*cv[2];
    extern IGRlong	EMgetvggeom();
    enum EMSdatatype	type;
    IGRint		num = 0, ind1, ind2;
    IGRdouble		par1, par2, pt[6], dist, *par1ptr = NULL, 
			*par2ptr = NULL;
    IGRpoint		*pt1ptr = NULL, *pt2ptr = NULL;
    extern IGRboolean	EFplace_line_string();
    struct GRid		seg;

    konst.msg        = &msg;
    konst.class_attr = NULL;       
    konst.level      = ME.COconst->ActiveLevel;
    konst.display    = &ME.COconst->ActiveDisplay;
    konst.env_info   = &me->ModuleInfo;
    konst.newflag    = FALSE;
    konst.name       = NULL;
    konst.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    konst.geometry   = NULL;
    for(i=0; i<2; i++)cv[i] = NULL;

    seg.osnum = me->ModuleInfo.md_id.osnum;

    sts = dp$erase_hilite(msg = &msg);
    ERRORs(sts, msg, "ECcvintf_exec erase hi", wrapup);
    ex$message (msgnumb = EMS_I_Processing);
    ex$message (msgnumb = EMS_P_ClearPromptField);
    for(i=0; i<2; i++)
     {
      sts = EMgetvggeom(&rc, 
		      &me->locate_info[i].module_info.md_env.matrix_type, 
		      me->locate_info[i].module_info.md_env.matrix, 
		      &me->locate_info[i].located_obj, 
		      &cv[i], &type);
     }
    if(ME.super_cmd->mytype == INTERSECT)
     {
      BSvcdst2cvs(cv[0], cv[1], NULL, &num, &par1, &par2, pt, &pt[3], &dist, 
		  &ind1, &ind2, &rc);
      if( (rc != BSSUCC) || !num)
       {
	printf("BSvcdst2cvs error code = %d\n", rc);
	ex$message(msgnumb = EMS_E_PossibleMathError);
	/* Changed as the above error status makes more sense
		UI_error("No Can Do");
	*/
	goto finish;
       }
      printf("\nMaximum interference is %3.12lf\n", dist);
     }
    else if(ME.super_cmd->mytype == NESTED)
     {
      BSmxdstcvcv(cv[0], cv[1], &num, &par1, &par2, pt, &pt[3], &dist, &rc);
      if( (rc != BSSUCC) || !num)
       {
	printf("BSmxdstcvcv error code = %d\n", rc);
	ex$message(msgnumb = EMS_E_PossibleMathError);
	/* Changed as the above error status makes more sense
		UI_error("No Can Do");
	*/
	goto finish;
       }
      printf("\nMaximum interference is %3.12lf\n", dist);

      sts = EFplace_line_string(my_id, &konst, 2, pt, &seg.objid, &rc);
      if(!(1&rc))
       ERRORs(OM_E_ABORT, EMS_E_Fail, "EFplace_line_string fail", wrapup);
      Display_Mode = GRbdhd;
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
   	     &me->ModuleInfo.md_env.matrix_type, me->ModuleInfo.md_env.matrix, 
             &Display_Mode, &me->ModuleInfo.md_id), targetid = seg.objid,
                    targetos = seg.osnum);
      ERRORs(sts, msg, "ECcvintf_exec erase", wrapup);
      konst.display->weight += 2;
      num = 0;
      BSmdistcvcv(cv[0], cv[1], &num, &par1ptr, &par2ptr, &pt1ptr, &pt2ptr, 
		  &dist, &rc);
      if( (rc != BSSUCC) || !num)
       {
	printf("BSmdistcvcv error code = %d\n", rc);
	ex$message(msgnumb = EMS_E_PossibleMathError);
	/* Changed as the above error status makes more sense
		UI_error("No Can Do");
	*/
	goto finish;
       }
      printf("\nMinimum clearence is %3.12lf\n", dist);
      OM_BLOCK_MOVE(pt1ptr, pt, sizeof(IGRpoint));
      OM_BLOCK_MOVE(pt2ptr, &pt[3], sizeof(IGRpoint));
     }
    else if(ME.super_cmd->mytype == DISJOINT)
     {
      BSmdistcvcv(cv[0], cv[1], &num, &par1ptr, &par2ptr, &pt1ptr, &pt2ptr, 
		    &dist, &rc);
      if( (rc != BSSUCC) || !num)
       {
	printf("BSmdistcvcv error code = %d\n", rc);
	ex$message(msgnumb = EMS_E_PossibleMathError);
	/* Changed as the above error status makes more sense
		UI_error("No Can Do");
	*/
	goto finish;
       }
      printf("\nMinimum clearence is %3.12lf\n", dist);
      OM_BLOCK_MOVE(pt1ptr, pt, sizeof(IGRpoint));
      OM_BLOCK_MOVE(pt2ptr, &pt[3], sizeof(IGRpoint));
     }
    sts = EFplace_line_string(my_id, &konst, 2, pt, &seg.objid, &rc);
    if(!(1&rc))
      ERRORs(OM_E_ABORT, EMS_E_Fail, "EFplace_line_string fail", wrapup);
    Display_Mode = GRbdhd;
    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			  &me->ModuleInfo.md_env.matrix_type, 
			  me->ModuleInfo.md_env.matrix, 
                          &Display_Mode, 
			  &me->ModuleInfo.md_id), 
                    targetid = seg.objid,
                    targetos = seg.osnum);
    ERRORs(sts, msg, "ECcvintf_exec erase", wrapup);

finish:
    for(i=0; i<2; i++)  
     {if(cv[i]) om$dealloc(ptr = cv[i]); cv[i] = NULL;}
    if(par1ptr) om$dealloc(ptr = par1ptr);
    if(par2ptr) om$dealloc(ptr = par2ptr);
    if(pt1ptr) om$dealloc(ptr = pt1ptr);
    if(pt2ptr) om$dealloc(ptr = pt2ptr);
    ex$message(msgnumb = EMS_I_00000)
    me->num_located = 0;
    sts = OM_S_SUCCESS;
    break;
   }


   default:
   {
    ERRORs(OM_E_ABORT, EMS_E_Fail, "ECcvintf_exec state garbage", wrapup);
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



end implementation ECcvintf;
