/* ###################   APOGEE COMPILED   ################## */
class implementation ECboolean;

/*****************
#define NO_ASSOC 0  Replaced by local variable "Associative" in the execute 
                    method.
******************/

#include "EMS.h"
#include "EMSprop.h"
#include <string.h>
#include "EMSascmacros.h"
/*
DESCRIPTION

This command will locate multiple curves/surfaces/solids and will
perform a boolean operation on them depending on mytype.  The
command constructs an EMSsfboolean or EMSslboolean class object.

RETURNED VALUES

Response contains information for the command server.  If
response is TERMINATE then the command is deleted by the command
server.

HISTORY

08/14/94   scw  clarified sleep method
10/25/93   dhm  TR 119311796 - don't locate profiles.
02/20/92    NP  The associative boolean code did not have the ability to 
                highlight (in case of boolean error) the offending intersection
                curves. Therefore, the second time around, (after the user hits
                a data point to output intersections) the boolean is done in a
                non-associative manner. After that, the boolean is again made
                associative. To do this, the "NO_ASSOC" #define has been
                replaced with a local variable called "Asociative". Wherever
                this variable appears is where the changes have been made.
08/08/91    scw Converted to use gr$dpb associative flag
06/04/91    DLB Support current_creator.
04/09/91    DLB Made this dude associative.  Also mod to allow the locate
                of associative elements.
10/03/89    DLB Commented out JUST ENOUGH of the cht processing code to allow
                the command to work.  Note that there is a lot more that can
                be removed, but I will wait until after the 1.3.0 release.
                One look at the complexity of this command will tell you why I
                wish to wait.
                P.S with the addition of Sunit's SPLIT solid type, there are
                    now 16 commands crunched together into one execute method.
                    Eeeeeee Gaaaaaddddddd!
09/29/89    pp  Changed arguments to EFshort_cvt.
09/17/89    SS  Added the STOP-interrupt handling for Booleans.
05/18/89    SM/DLB  Added code to handle 'split surface/solid'. All the code
                that was added has a comment with it. 
2/28/89     dhm Added ifndef's for I/DRAW product.

09 Jan 1989 jBk Replaced em$xsMessage invocations with ex$message
                invocations.
                Accordingly, replaced EMScimacros.h inclusion
                with inclusion of msmacros.h.
12/01/88    rlw Modified to display catastrophic error as information
                and to bring up an error box telling the user not
                to save the file.
10/21/88    DLB Added state logic for support of locate by name.
10/21/88    rlw Added support for locate by name.
09/26/88    rlw Initialized new field to select handler.
09/20/88    rlw Modified to supress locate of objects already located
08/04/88    DLB Added code to handle being driven by PPL.
16 Jul 1988 AIC Removed some 'mytype' options.
03 Jun 1988 jBk Changed an erroneous semicolon before declaration
                of OPP_EMSsolid_class_id to a correct comma.  The
                change solved the problem of this command, and
                consequently EFmksolid, thinking solids were
                merely surfaces. 
01 Jun 1988 jBk Added case to test switch upon return EMboolean
                message to check for message subsystem codes
                which require no processing other than output.
05 May 1988 jBk Added GRtext to the rtree classes for some uses
                of the locate filter.
14 Apr 1988 jBk Extensive modifications to accomplish:

                Added code for several more types of disjoint
                boolean operations.

                Added code to allow for use of the disjoint retry
                when no intersections are found in an operation
                requiring surface intersections.

                Modified to use message subsystem and removed
                sleep invocations.

                Altered how boolean operation types are set and
                utilized.

                Changed user input sequence to make command more
                mouse driven.

19 Feb 1988 SS  Changed the arguments to EMboolean method.
02/06/88    DLB Added code for curve booleans.
04 Dec 1987 jBk Added code for disjoint operations.
                Added message for multiple intersection case. 
01/06/87    DLB Creation date.
*/

# define INTER  0   /* intersect */

# define MUNION 3   /* multiple union */
# define MDIFF  4   /* multiple difference */
# define MINTER 5   /* multiple intersect */

# define MDISU  6   /* multiple disjoint union */
# define MDISD  7   /* multiple disjoint difference */
# define MDISI  8   /* multiple disjoint intersection */

# define MINTU  9   /* multiple interior union */
# define MINTD 10   /* multiple INTERIOR DIFFERENCE/hollow */
# define MHOLL 11   /* multiple interior difference/HOLLOW */
# define MINTI 12   /* multiple interior intersection */

# define MENCU 13   /* multiple encompassing union */
# define MENCD 14   /* multiple encompassing difference */
# define MENCI 15   /* multiple encompassing intersection */

# define SPLIT 16   /* split surface/solid with a surface */    /* SM/DLB */

/*#define DEBUG 0*/ /*Set to 1 if want error strings.*/

#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "EMSopt.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "EMSaction.h"                  /* Locate action handler */
#include "msmacros.h"   /* ex$message */
#include "emsdef.h"
#include "EMS_M.h"  /*command name numbers (for the Message field) */
#include "EMS_I.h"  /*informational message numbers (for the status field) */
#include "EMS_E.h"  /*error message numbers (for the status field) */
#include "EMS_F.h"  /*error message numbers (for the error box) */
#include "EMS_P.h"  /*prompt numbers (for the prompt field) */
#include "EMStypedef.h" /* EMSrc */
#include "EMSasopts.h"
#include "EMSdpb.h"


from GRvg         import GRgeomprops;
from GRgraphics   import GRdisplay, GRdelete;
from EMSdpr       import  EMsetprops;
#ifndef IDRAW
  from EMSdpr       import EMundo;
  from EMSsurface   import EMdisplay_edges;
  from EMSsfboolean import EMboolean;
  from EMSsfspltwsf import EMsplit_with_surface;        /* SM/DLB */
/*  from EMSsubbs     import EMmk_nat_bdry;               Ashok - 8/Jun/90 */
#endif

#ifndef IDRAW
  extern OMuword OPP_EMSsubbs_class_id,
                 OPP_EMSsurface_class_id,
                 OPP_EMSsfboolean_class_id,
                 OPP_EMSslboolean_class_id,
                 OPP_EMSsolid_class_id, 
                 OPP_EMSsfspltwsf_class_id,     /* SM/DLB */
                 OPP_EMSslspltwsf_class_id,     /* SM/DLB */
                 OPP_EMSdpr_class_id;
#endif

extern OMuword OPP_GRcurve_class_id,
               OPP_GRbspline_class_id,
               OPP_GRtext_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;

extern EMSrc EFextractOperationInformation ();

static IGRboolean aflag;

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhd;
 IGRlong sts=OM_S_SUCCESS,msg=EMS_S_Success,i;

#if DEBUG
 fprintf(stderr,"\nCommand in DEBUG\n");
#endif

 if (me->num_located && me->is_hilited)
 { 
   for (i = 0; i < me->num_located; i++)
   { 
     sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                        &me->locate_info.module_info.md_env.matrix_type, 
                        me->locate_info.module_info.md_env.matrix, 
                        &Display_Mode, 
                        &me->locate_info.module_info.md_id),
                   targetid = me->located_ids[i],
                   targetos = me->locate_info.located_obj.osnum);
     ERROR(sts, msg, "ECbool_wake draw hi", wrapup);
   }
 }

#ifndef IDRAW
 /*if (me->newtol)   10/3/89 DLB*/
 {
   IGRlong sizbuf = sizeof(IGRdouble), nret;
   IGRdouble tol;
   IGRchar a_string[80];
 
   /*get worlds tol*/
   gr$get_chord_height_tolerance(msg = &msg, 
                                 sizbuf = &sizbuf,
                                 buffer = &tol,
                                 nret = &nret);
   ERROR(OM_S_SUCCESS, msg, "ECbool_sleep get cht tol", wrapup);

   /*put commands tol in*/
   /*******************************************10/3/89 DLB
   gr$put_chord_height_tolerance(msg = &msg,
                                 sizbuf = &sizbuf,
                                 buffer = &me->chttol);
   ERROR(OM_S_SUCCESS, msg, "ECbool_sleep put cht", wrapup);
   *******************************************/
    
   a_string[0] = '\0';

   sts = EFshort_cvtn(a_string, tol, 0,80);
   ERROR(sts, EMS_S_Success, "ECbool_wake short cvt", wrapup);

   ex$message (
        msgnumb = EMS_I_ChordHeightTolIs,       /*SetTo     10/3/89 DLB*/
        var = a_string,
        type = "%s"
   );

   /*store worlds tol*/
   /*me->chttol = tol;  10/3/89 DLB*/
 }
#endif

 {
   IGRboolean  state;
   extern IGRboolean EMshould_be_associative();

   if ( (ME.super_cmd->mytype != SPLIT) && (EMshould_be_associative()))
      gr$get_associative_flag( buffer = &state );
   else
      state = FALSE;

   if (state)
   {
     GRdisplay_associative_button(TRUE);
     me->associative = TRUE;
   }
   else
     me->associative = FALSE;
 }

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRlong sts=OM_S_SUCCESS,msg=EMS_S_Success;
 void localMsg ();

 if (me->num_located && me->is_hilited)
 {
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "ECbool_sleep erase hi", wrapup);
 }

#ifndef IDRAW
 if (me->newtol)
 {
   IGRlong sizbuf = sizeof(IGRdouble), nret;
   IGRdouble tol;
   IGRchar a_string[80];
 
   /*store this commands tol*/
   gr$get_chord_height_tolerance(msg = &msg, 
                                 sizbuf = &sizbuf,
                                 buffer = &tol,
                                 nret = &nret);
   ERROR(OM_S_SUCCESS, msg, "ECbool_sleep get cht tol", wrapup);

   /*put old tol back*/
   gr$put_chord_height_tolerance(msg = &msg,
                                 sizbuf = &sizbuf,
                                 buffer = &me->chttol);
   ERROR(OM_S_SUCCESS, msg, "ECbool_sleep put cht", wrapup);

   a_string[0] = '\0';

   sts = EFshort_cvtn(a_string, me->chttol, 0,80);
   ERROR(sts, EMS_S_Success, "ECbool_wake short cvt", wrapup);

   ex$message (
        msgnumb = EMS_I_ChordHeightTolReset,
        var = a_string,
        type = "%s"
   );

   /*store this commands tol*/
   me->chttol = tol;
 }
#endif

 localMsg (EM_M_ClearMessageField);

 localMsg (EMS_P_ClearPromptField);

 if (me->associative) GRdisplay_associative_button(FALSE);

 wrapup:
  return(sts);
}


method delete(int f_defer_flag)
{
  IGRlong i, sts, msg;
  struct GRid tempid;

#ifndef IDRAW
  /* Added && .. -- SM/DLB */

  if (!me->got_curve)
  {
    for (i=0; i<me->num_located; i++)
    {
      if (me->changed[i])
      {
         tempid.objid = me->located_ids[i];
         tempid.osnum = me->locate_info.located_obj.osnum;

         sts = ECunprepsurf(&msg, tempid, me->changed[i]);
         ERROR(sts, msg, "ECbool_exec unprepsf", wrapup);
      }
    }
  }
#endif
  
  sts = om$send(mode = OM_e_wrt_message,
                msg = message COconst.delete(NULL),
                targetid = my_id);
  ERROR(sts, EMS_S_Success, "ECbool_delete delete", wrapup);

 wrapup:
  return(sts);
}


method execute(int *response; char *response_data; int pos)
{
 IGRlong               nret, sizbuf = sizeof(IGRdouble);
 IGRlong               sts, msg, size=sizeof(struct GRevent),display_flag,
                       eventmsg, qsize;
 IGRint                locate_mask, accept_mask, token = 0, i;
 IGRint                eventsts, save_rsp = 0, num_crvs_out, index;
 GRobjid               *crv_out_ids, res_id;
 enum     GRdpmode     Display_Mode;
 enum     EMSbooltype  type, generalOperation;
 IGRboolean multipleBool, curvesAllowed;
 struct   GRvg_construct construct_list;
 struct   GRlc_locate  attr;
 struct   GRevent      loc_obj_event;        /*Added by DLB 08/04/88*/
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass[3], eliclass[2];
 IGRboolean            found_same, gothru=FALSE, output_inters=FALSE;
 IGRushort     change_mask;
 IGRchar               a_string[80];
 void localMsg ();
 IGRboolean	       Associative, action = TRUE;
 IGRushort             mask = EMS_POST310_OBJECT;

#define NUM_TOKENS 6
#define NUM_STATES 7

 static int Tokens[NUM_TOKENS] =
 {
   EX_BACK_UP, DATA, VALUE, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
 };

 enum actions
 {
   NIL, ERR, init, rem_it, store_it, do_bool, reset_all,  store_tol,
   stmask, undo, accept
 };

 enum states
 {
   start, prepsf, get_tol, dummy, ck_result, acc_rjt, sv_hist
 };

 static enum states NextState[NUM_STATES][NUM_TOKENS] =
 {
 /*  token:     BACK_UP  DATA       VALUE      STRING  MOVEON    UNK
 old state:  */                                   
 /* start    */ {prepsf, prepsf,    start,     prepsf, ck_result,start    },
 /* prepsf   */ {start,  prepsf,    prepsf,    start,  prepsf,   prepsf   },
 /* get_tol  */ {start,  dummy,     dummy,     get_tol,get_tol,  get_tol  },
 /* dummy    */ {dummy,  ck_result, dummy,     dummy,  dummy,    dummy    },
 /* ck_result*/ {start,  ck_result, ck_result, start,  ck_result,ck_result},
 /* acc_rjt  */ {start,  start,     start,     start,  start,    start    }, 
 /* sv_hist  */ {start,  sv_hist,   sv_hist,   ck_result, ck_result,  sv_hist}
 };

 static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
 {
 /*  token:      BACK_UP    DATA      VALUE      STRING    MOVEON   UNK
 old state: */                                     
 /* start    */ {NIL,       store_it, NIL,       store_it, do_bool, NIL   },
 /* prepsf   */ {rem_it,    NIL,      NIL,       stmask,   NIL,     NIL   },
 /* get_tol  */ {reset_all, store_tol,store_tol, NIL,      NIL,     NIL   },
 /* dummy    */ {NIL,       do_bool,  NIL,       NIL,      NIL,     NIL   },
 /* ck_result*/ {undo,      NIL,      NIL,       init,     NIL,     NIL   },
 /* acc_rjt  */ {undo,      accept,   accept,    accept,   accept,  accept}, 
 /* sv_hist  */ {NIL,       NIL,      NIL,       do_bool,  do_bool, NIL}
 };


 /* intentional block */
 {
    IGRlong msgnumb;

    multipleBool = TRUE;
    curvesAllowed = FALSE;

    switch(ME.super_cmd->mytype)
    {
    case INTER:
        msgnumb = EM_M_Intx2CvSfSl;
        type = EMSbool_intersect;
        multipleBool = FALSE;
        curvesAllowed = TRUE;
        break;
/*
    case MINTER:
        msgnumb = EM_M_IntxCvSfSl;
        type = EMSbool_intersect;
        curvesAllowed = TRUE;
        break;
*/
    case MUNION:
        msgnumb = EM_M_UnionCvSfSl;
        type = EMSbool_union;
        curvesAllowed = TRUE;
        break;
    case MDIFF:
        msgnumb = EM_M_DiffCvSfSl;
        type = EMSbool_difference;
        curvesAllowed = TRUE;
        break;
#ifndef IDRAW
    case MDISU:
        msgnumb = EM_M_UnionSfSlDis;
        type = EMSbool_disjointU;
        break;
#endif
/*
    case MDISD:
        msgnumb = EM_M_DiffSfSlDis;
        type = EMSbool_disjointD;
        break;
    case MDISI:
        msgnumb = EM_M_IntxSfSlDis;
        type = EMSbool_disjointI;
        break;

    case MINTU:
        msgnumb = EM_M_UnionSfSlInt;
        type = EMSbool_interiorU;
        break;
    case MINTD:
        msgnumb = EM_M_DiffSfSlInt;
        type = EMSbool_interiorD;
        break;
*/
#ifndef IDRAW
    case MHOLL:
        msgnumb = EM_M_HollDiffSfSl;
        type = EMSbool_interiorD;
        break;
#endif
/*
    case MINTI:
        msgnumb = EM_M_IntxSfSlInt;
        type = EMSbool_interiorI;
        break;

    case MENCU:
        msgnumb = EM_M_UnionSfSlEnc;
        type = EMSbool_surroundU;
        break;
    case MENCD:
        msgnumb = EM_M_DiffSfSlEnc;
        type = EMSbool_surroundD;
        break;
    case MENCI:
        msgnumb = EM_M_IntxSfSlEnc;
        type = EMSbool_surroundI;
        break;
*/

/* Upto endif -- SM/DLB */

#ifndef IDRAW
    case SPLIT:
        msgnumb = EM_M_SplSurfWSurf;
        type = EMSbool_difference;
        multipleBool = FALSE;
        break;
#endif

    default:
        ERROR(OM_E_ABORT, EMS_E_Fail, "invalid mytype", wrapup);
    }

    sts = EFextractOperationInformation (
        &msg,
        type,
        &generalOperation,
        NULL /* = reverseOrientation */,
        NULL /* = emptySet */,
        NULL /* = disjointSurfaces */,
        NULL /* = firstOnly */,
        NULL /* = allButFirst */,
        NULL /* = lastOnly */,
        NULL /* = removedSolids */,
        NULL /* = msgNumber */
    );

    localMsg (msgnumb);
 }

 Associative = TRUE;  /* Make sure the Associative Boolean code is done */

 do
 {
  IGRlong locKey = MS_NO_MSG, accKey = MS_NO_MSG, relKey = MS_NO_MSG;

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
    break;
   }


   case rem_it:
   {
    if (me->num_located)
    {
      if (me->num_located == 1)
      {
        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "ECbool_exec erase hi", wrapup);
      }
      else
      {
        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &me->locate_info.module_info.md_env.matrix_type,
                          me->locate_info.module_info.md_env.matrix,
                          &Display_Mode, 
                          &me->locate_info.module_info.md_id),
                    targetid = me->located_ids[me->num_located-1],
                    targetos = me->locate_info.located_obj.osnum);
        ERROR(sts, msg, "ECbool_exec erase", wrapup);
      }      
     
#ifndef IDRAW

      if (!me->got_curve && me->changed[me->num_located-1])
      {
        struct GRid tempid;  /*DECLARE*/

        tempid.objid = me->located_ids[me->num_located-1];
        tempid.osnum = me->locate_info.located_obj.osnum;

        sts = ECunprepsurf(&msg, tempid, me->changed[me->num_located-1]);
        ERROR(sts, msg, "ECbool_exec unprepsf", wrapup);
      }
#endif

      me->num_located--;
    }
    break;
   }


   case store_it:
   {
    found_same = FALSE;

    if (me->num_located)
    {
      if (me->locate_event.located_object[0].located_obj.osnum !=
          me->locate_info.located_obj.osnum)
      {
        if (me->got_curve)
          localMsg (EMS_I_LocCvHasDiffEnv);
        else
          localMsg (EMS_I_LocSfSlHasDiffEnv);

        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                           &me->locate_info.module_info.md_env.matrix_type, 
                           me->locate_info.module_info.md_env.matrix, 
                           &Display_Mode, 
                           &me->locate_info.module_info.md_id),
           targetid = me->locate_event.located_object[0].located_obj.objid,
           targetos = me->locate_event.located_object[0].located_obj.osnum);
        ERROR(sts, msg, "ECbool_exec hi erase", wrapup);

        found_same = TRUE;
      }
    }     

    for (i = 0; (i < me->num_located && !found_same); i++)
    {
      if (me->located_ids[i] ==
          me->locate_event.located_object[0].located_obj.objid)
      {
        if (me->got_curve)
          localMsg (EMS_I_CvAlreadyLocated);
        else
          localMsg (EMS_I_SfSlAlreadyLocated);
        found_same = TRUE;
      }
    }

    if (found_same) 
    {
      ME.super_cmd->state = start;
      break;
    }

    if (me->num_located == 0)
    {
      OMuword classid;  /*DECL*/

      OM_BLOCK_MOVE(&me->locate_event.located_object[0], &me->locate_info, 
                    sizeof(struct GRlc_info));

      sts = om$get_classid(objid = me->locate_info.located_obj.objid,
                           osnum = me->locate_info.located_obj.osnum,
                           p_classid = &classid);
      ERROR(sts, EMS_S_Success, "ECbool_exec get classid", wrapup); 
      
      sts = om$is_ancestry_valid(superclassid = OPP_GRcurve_class_id,
                                 subclassid = classid);
      ERROR(sts, EMS_S_Success, "ECbool_exec is ancect valid", wrapup);   

      if (sts == OM_S_SUCCESS) me->got_curve = TRUE;
    }

    if (om$dimension_of(varray = me->located_ids) <= me->num_located)
    {
      sts = om$vla_set_dimension(varray = me->located_ids,
                                 size = me->num_located + 3);
      ERROR(sts, EMS_S_Success, "ECbool_exec expand vla", wrapup);

#ifndef IDRAW
      if (!me->got_curve)
      {
        sts = om$vla_set_dimension(varray = me->changed,
                                   size = me->num_located + 3);
        ERROR(sts, EMS_S_Success, "ECbool_exec expand change vla", wrapup);
      }
#endif
    } 

    me->located_ids[me->num_located] = me->locate_event.located_object[0].
                                       located_obj.objid;

    if (me->got_curve)
    {
      /*Perform curve closure check*/
      struct GRprops props;             /*DECL*/
      IGRboolean bad_curve=FALSE;
   
      sts = om$send(msg = message GRvg.GRgeomprops(&msg, 
                          &me->locate_info.module_info.md_env.matrix_type,
                          me->locate_info.module_info.md_env.matrix,
                          &props),
                    targetid = me->located_ids[me->num_located],
                    targetos = me->locate_info.located_obj.osnum);
      ERROR(sts, msg, "ECbool_exec get gromprops", wrapup);

      if (!props.phy_closed)
      {
        localMsg (EMS_I_CvNotClosed);
        bad_curve = TRUE;
      }       

      if ((!me->num_located) && (!props.planar))
      {
        localMsg (EMS_I_CvNotPlanar);
        bad_curve = TRUE;
      }

      if (bad_curve)
      {
        if (!me->num_located)
        {
          sts = dp$erase_hilite(msg = &msg);
          ERROR(sts, msg, "ECbool_exec erase hi", wrapup);
        }
        else
        {
          Display_Mode = GRhe;
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                           &me->locate_info.module_info.md_env.matrix_type, 
                           me->locate_info.module_info.md_env.matrix, 
                           &Display_Mode, 
                           &me->locate_info.module_info.md_id),
                        targetid = me->located_ids[me->num_located],
                        targetos = me->locate_info.located_obj.osnum);
          ERROR(sts, msg, "ECbool_exec hi erase", wrapup);
        }

        ME.super_cmd->state = start;

        break;
      }      
    }

#ifndef IDRAW
    if (!me->got_curve)
    {
      OMuword classid;  /*DECL*/
  
      sts = om$get_classid(objid = me->located_ids[me->num_located],
                           osnum = me->locate_info.located_obj.osnum,
                           p_classid = &classid);
      ERROR(sts, EMS_S_Success, "ECbool_exec get classid", wrapup); 

      sts = om$is_ancestry_valid(superclassid = OPP_EMSsolid_class_id,
                                 subclassid = classid);
      ERROR(sts, EMS_S_Success, "ECbool_exec is ancect valid", wrapup);   

      if (sts == OM_S_SUCCESS || classid == OPP_EMSsolid_class_id)
        me->got_solid = TRUE;
      else
        me->got_all_solids = FALSE;
    }
#endif

    /*I CAN FINALLY DO THIS!!!*/
    me->num_located++;
    me->is_hilited = TRUE;

    break;
   }   


   case stmask:
   {
     if (!me->got_curve) me->changed[me->num_located-1] = change_mask;
  
     /*do put que if only 1 located OR its a multiple bool*/
     if (me->num_located == 1 || multipleBool)
     {
       if (save_rsp == EX_BACK_UP)  break;  /*All done here!!*/

       /*Place accept event on the software stack for the next locate*/
       /*MOD 06/15/88 by DLB*/
       if ( (me->locate_event.subtype != GRst_REGULAR) && 
            me->locate_event.num_id && 
            (me->locate_event.located_object[0].located_obj.objid ==
             me->accept_event.located_object[0].located_obj.objid) ) break;

#if DEBUG
       fprintf(stderr,"\nDoing putque now!");
#endif
       qsize = sizeof(me->accept_event.event) + sizeof (IGRint);
       sts = ex$putque(msg = &msg, 
                       response = &me->accept_event.response, /*save_rsp,*/
                       byte = &qsize,
                       buffer = (IGRchar *) &me->accept_event.event);
       ERROR(sts, EMS_S_Success, "ECbool_exec put que", wrapup);
       break;  /*Break only if multiple operation.*/
    }

    /*Otherwise dont break and fall thru to do boolean*/
   }


   case do_bool:
   {
    GRobjid    inters=NULL_OBJID, endpts=NULL_OBJID;  /*DECLARE*/
    IGRboolean bad_error=FALSE, no_error=TRUE; 
    IGRchar    status_str[54];

    /* Following code (upto ex$..) added -- SM/DLB */

#ifndef IDRAW
    if( (ME.super_cmd->mytype == SPLIT) && (!me->hist_asked))
     {ME.super_cmd->state = sv_hist; ME.COconst->action = NIL; break;}
#endif

    ex$message (msgnumb = EMS_I_Processing, buff = status_str);

    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "ECbool_sleep erase hi", wrapup);

    me->is_hilited = FALSE;

    construct_list.msg = &msg;
    construct_list.env_info = &me->locate_info.module_info,
    construct_list.newflag = FALSE;
    construct_list.geometry = NULL;
    construct_list.class_attr = NULL;
    construct_list.level = ME.COconst->ActiveLevel;
    construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    construct_list.display = &ME.COconst->ActiveDisplay;
    construct_list.name = NULL;

    localMsg (EMS_I_Processing);
    localMsg (EMS_P_ClearPromptField);

    if (me->got_curve)
    {
      struct GRlc_info *info=NULL;   /*DECL*/
      int cvBoolType = 0;
      
      info = (struct GRlc_info *) om$malloc(size = me->num_located * 
                                            sizeof(struct GRlc_info));
      if (!info) 
      {
       ERROR(sts, EMS_E_NoDynamicMemory, "ECbool_exec malloc info", wrapup);
      }
   
      for (index=0; index<me->num_located; index++)
      {
        info[index] = me->locate_info;
        info[index].located_obj.objid = me->located_ids[index];
      }

      num_crvs_out = 0;
      crv_out_ids = NULL;

      /* set curve boolean type */
      switch (type)
      {
      case EMSbool_intersect:
        cvBoolType = 3;
        break;

      case EMSbool_union:
        cvBoolType = 0;
        break;

      case EMSbool_difference:
        cvBoolType = 1;
      /* no break necessary */

      /* no default:  no other types for curves */
      }

      if (!me->associative)
      sts = EMmult_boolean(&msg, info, me->num_located, cvBoolType,
                           &construct_list, &num_crvs_out, &crv_out_ids);
      else
      {
       sts = EFplace_associative_curve_boolean(&msg,NULL,me->num_located,info,
              cvBoolType, &construct_list, &res_id);
       if (1&msg&sts)
       {
        crv_out_ids = &res_id;
        num_crvs_out = 1;
       }
       else
        num_crvs_out = 0;
      }

      if (info) om$dealloc(ptr = info);

      localMsg (EMS_I_ClearStatusField);

      if ( COERROR(sts) || 
           COERROR(msg) ||
           msg == EMS_I_NoIntersection ||
           msg == EMS_I_BoolFail ||
           msg == EMS_I_CvsNonCoplanar)
      {
        /*IT FAILED!!*/
        no_error = FALSE;
        bad_error = TRUE;
        switch(msg)
        {
          case EMS_I_NoIntersection:
            localMsg (EMS_I_CvEltsNoIntersect);
            break;
          case EMS_I_BoolFail:
            localMsg (EMS_I_DisjointElements);
            break;
          case EMS_I_CvsNonCoplanar:
            localMsg (EMS_I_CvNotCoplanar);
            break;
          default:
            localMsg (EMS_E_OperationFailed);
            /* no break necessary */
        }/*end switch*/

        for(index=0; index < num_crvs_out; index++)
        {
          sts = om$send(msg = message GRgraphics.GRdelete(&msg, 
                              &me->locate_info.module_info),
                        targetid = crv_out_ids[index],
                        targetos = me->locate_info.located_obj.osnum);
          ERROR(sts, msg, "ECbool_exec delete crv_out_ids", wrapup);
        }

        if (crv_out_ids && (crv_out_ids != &res_id)) 
               om$dealloc(ptr = crv_out_ids);

      }/*end if error*/
      else
      {
        /*IT WORKED!!!*/
        Display_Mode = GRbe;
        for(index=0; index < me->num_located; index++)     
        {
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                        targetid = me->located_ids[index],
                        targetos = me->locate_info.located_obj.osnum);
          ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    
        }/*end for*/

        Display_Mode = GRbdhd;
        for(index=0; index < num_crvs_out; index++)     
        {
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                        targetid = crv_out_ids[index],
                        targetos = me->locate_info.located_obj.osnum);
          ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    
        }/*end for*/
      }/*end else !error*/
    }
    else
    {
#ifndef IDRAW
      /*Its a surface/solid boolean!*/

      me->construct_id.osnum = me->locate_info.located_obj.osnum;

      /* If statement added -- SM/DLB */
      if(ME.super_cmd->mytype == SPLIT)
        sts = om$construct(classid = (me->got_solid ? 
                                    OPP_EMSslspltwsf_class_id :
                                    OPP_EMSsfspltwsf_class_id),
                         p_objid = &me->construct_id.objid,
                         osnum = me->locate_info.located_obj.osnum);
/***********
#if NO_ASSOC
***********/
      else if (!Associative)
      {		sts = om$construct(classid = (me->got_all_solids ? 
                                    OPP_EMSslboolean_class_id :
                                    OPP_EMSsfboolean_class_id),
                         p_objid = &me->construct_id.objid,
                         osnum = me->locate_info.located_obj.osnum);
      }
      ERROR(sts, EMS_S_Success, "ECbool_exec construct", wrapup);
/*****
#endif
*****/
  
      /* if statement added -- SM/DLB */
      if(ME.super_cmd->mytype == SPLIT)
      {
        extern OM_S_OBJID current_creator;
        IGRushort optionsEMboolean = EMSsfbool_opt_display |
                                             EMSsfbool_opt_HandleStop;
        IGRushort splt_options = NULL;

/****** This block added by Ashok - 8/Jun/90 *******/
/* Similar check is now made in the method for both the operands. So commented
   out this block. Also this block was causing the command to error out
   for non EMSsubbs type operand because 'sts' was not being reset to
   OM_S_SUCCESS -- SM Jul 07, 1990.
*/
/********************
        IGRboolean        is_primitive_surface;
        OM_S_CHANSELECT   to_loopset;

	IGRint		  count;

        sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
        ERROR(sts, EMS_S_Success, "ECbool_exec make chan sel", wrapup);
        count = 0;
        sts = om$get_channel_count(
          objid = me->located_ids[0],
          osnum = me->locate_info.located_obj.osnum,
          p_chanselect = &to_loopset,
          count = &count);
        is_primitive_surface = (1 & sts); 
        if (is_primitive_surface && (count == 0))
            sts = om$send(
                     msg = message EMSsubbs.EMmk_nat_bdry(
                           &msg, 
                           &me->locate_info.module_info.md_env,
                           NULL), 
                     targetid = me->located_ids[0],
                     targetos = me->locate_info.located_obj.osnum);
           ERROR(sts, EMS_S_Success, "ECbool_exec mknat bdry", wrapup);

*********************/

/******          Block End         *******/        
        if(me->keep_history) splt_options = EMsws_MaintainHistory;
        current_creator = me->construct_id.objid;        
        eventsts = om$send(msg = message EMSsfspltwsf.EMsplit_with_surface(
                         &eventmsg,
                         &construct_list, 
                         me->located_ids[0],
                         me->located_ids[1], 
                         (output_inters ? optionsEMboolean |
                                          EMSsfbool_opt_doublecheck |
                                          EMSsfbool_opt_outinters | 
                                          EMSsfbool_opt_outaux :
                                          optionsEMboolean),
                         splt_options, 
                         &me->locate_info.module_info,
                         status_str, 
                         (output_inters ? &inters : NULL), 
                         (output_inters ? &endpts : NULL), NULL, NULL),
                       targetid=me->construct_id.objid,
                       targetos=me->construct_id.osnum);
        current_creator = NULL_OBJID;
      }
      else
      {
/****************
#if NO_ASSOC
****************/

        if (_Pathway)
        {
          _pathway_trim = 1;
          _pathway_orient = 1;
        }
        	
   	if (!Associative)
        {
          IGRushort optionsEMboolean =
              EMSsfbool_opt_display | EMSsfbool_opt_retryDisjoint |
              EMSsfbool_opt_HandleStop;
  
          eventsts = om$send(msg = message EMSsfboolean.EMboolean(&eventmsg,
                           &me->locate_info.module_info.md_env.matrix_type,
                           me->locate_info.module_info.md_env.matrix,
                           me->located_ids[0], me->num_located-1,
                           &me->located_ids[1], &construct_list, type, 
                           (output_inters ? optionsEMboolean |
                                            EMSsfbool_opt_doublecheck |
                                            EMSsfbool_opt_outinters | 
                                            EMSsfbool_opt_outaux :
                                            optionsEMboolean),
                           status_str, 
                           (output_inters ? &inters : NULL), 
                           (output_inters ? &endpts : NULL), NULL, NULL), 
                         targetid=me->construct_id.objid,
                         targetos=me->construct_id.osnum);
          
          /*
           * Mark the object as a post 310 object
           */
          sts = om$send (msg = message EMSdpr.EMsetprops (&msg,
                                    &action, &mask),
                                    targetid = me->construct_id.objid,
                                    targetos=me->construct_id.osnum);

          if (!(1&sts&msg)) goto wrapup;
  
          Associative = TRUE;  /* Once the bad intersections have been output 
                                  go back to associative booleans */
        }
/***************
#else
***************/
        else
        {
/*****************************************************************************
           eventsts = EFboolean(&eventmsg, 
                                (me->associative ? NULL :
                                                   EFfunc_PLACE_NON_ASSOC), 
                                me->num_located,
                                me->located_ids, type, &construct_list,
                                &me->construct_id); 
*****************************************************************************/
           eventsts = ems$boolean(msg = &eventmsg,
                   options = (me->associative ? NULL : EFfunc_PLACE_NON_ASSOC),
                   num_opnds = me->num_located,
                   opnd_info = me->located_ids,
                   bool_type = type,
                   construction_list = &construct_list,
                   resultant_obj = &me->construct_id);  
        }                              
/**************
#endif
**************/

        if (_Pathway)
        {
          _pathway_trim = 0;
          _pathway_orient = 0;
        }

      }

      if ( COERROR(eventsts) || 
           COERROR(eventmsg) || 
           (eventmsg == EMS_I_NoIntersection) ||
           (eventmsg == EMS_I_Interrupt)) 
      {
        /* for some reason, no intersection and no retry */

        no_error = FALSE;
        bad_error = TRUE;

        switch(eventmsg)
        {
          case EMS_I_Interrupt:
            ex$message (msgnumb = EMS_I_Intrupt);
            break;
          case EMS_I_NoIntersection:
            localMsg (EMS_I_SfSlEltsNoIntersect);
            break;
          case EMS_E_IntersectClosure:
          case EMS_E_IntersClosureOrient:
          case EMS_E_IntersectOrient:
          {
            if (eventmsg == EMS_E_IntersectClosure)
                localMsg (EMS_E_IntxCvsNotClosed);
            else if (eventmsg == EMS_E_IntersClosureOrient)
                localMsg (EMS_E_IntersOrientClosure);
            else
                localMsg (EMS_E_IntxCvsImproperOrient);

            bad_error = FALSE;
            ME.super_cmd->state = get_tol;

            break;
          }
          case EMS_E_Intersect:
            localMsg (EMS_E_BadIntersectionResults);
            break;
          case EMS_E_NoDynamicMemory:
            localMsg (EMS_E_InsufficientDynamicMemory);
            break;
          case EMS_E_Fail:
            localMsg (EMS_E_PossibleMathError);
            break;
          case EMS_F_Fail:
            localMsg (EMS_I_00101);     /* rlw - 12/01/88 */
            localMsg (EMS_F_0006);
            break;
          default:
            localMsg (EMS_E_OperationFailed);
            /* no break necessary */
        }  


        if (eventmsg != EMS_E_BoolFail)
         {
          sts = om$send(msg = message Root.delete(NULL),
                      targetid = me->construct_id.objid,
                      targetos = me->construct_id.osnum);
          ERROR(sts, EMS_S_Success, "ECbool_exec delete", wrapup);
         }
        
        if (output_inters)
        {
          if (inters != NULL_OBJID)
          {
            /*I want to do a background draw and half hilite draw
             * but because of display stupidity I must do it with two
             * seperate requests.
             */
            Display_Mode = GRbd;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                         targetid = inters,
                         targetos = me->locate_info.located_obj.osnum);
            ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    

            Display_Mode = GRhhd;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                         targetid = inters,
                         targetos = me->locate_info.located_obj.osnum);
            ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    
          }

          if (endpts != NULL_OBJID)
          {
            Display_Mode = GRbdhd;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                          targetid = endpts,
                          targetos = me->locate_info.located_obj.osnum);
            ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    
          }
          output_inters = FALSE;
        } /* end if (output_inters) */
      } /* end if, for some reason, no intersection and no retry */
      else if (
        eventmsg IS EMS_I_DisjointElements OR
        eventmsg IS EMS_I_EmptySet
      )
      {
        /* no intersection and a successful disjoint retry */

        localMsg (eventmsg);
      }
      else
      {
        /* success */

        localMsg (EMS_I_ClearStatusField);
      }
#endif
    } /*else !curve*/

    /*If there was no error then do proper state*/
    if (no_error)  
    {
      if (me->got_curve)
        ME.super_cmd->state = acc_rjt;
      else      
        ME.super_cmd->state = ck_result;  
      break;
    }

    /*If there was no bad error then break*/
    if (!bad_error) break; 
   }

   
   case reset_all:
   {
     IGRint i;     /*DECLARE*/
     struct GRid tempid;

#ifndef IDRAW
     if (!me->got_curve)
     {
       for (i=0; i<me->num_located; i++)
       {
         if (me->changed[i])
         {
           tempid.objid = me->located_ids[i];
           tempid.osnum = me->locate_info.located_obj.osnum;
           sts = ECunprepsurf(&msg, tempid, me->changed[i]);
  
           ERROR(sts, msg, "ECbool_exec unprepsf", wrapup);
         }
       }
     }
#endif

     me->num_located = 0;
     ME.super_cmd->state = start;
     break;
   }  
     

   case store_tol:
   {
#ifndef IDRAW
     if (token == 1)
     {
       /* Got data */
       
       output_inters = TRUE;
       Associative   = FALSE; /* Make sure the Non-associative boolean is called
                                 next time, since the associative boolean cannot
                                 output bad intersections */ 

     }
     else
     {
       /* Assume got value */

       IGRdouble bas_tol;

       gr$get_basis_tolerance(msg = &msg, 
                              sizbuf = &sizbuf,
                              buffer = &bas_tol,
                              nret = &nret);
       ERROR(OM_S_SUCCESS, msg, "ECbool_exec get bas tol", wrapup);

       if (me->locate_event.event.value <= bas_tol)
       {
         localMsg (EMS_F_TolMustBeGtBasis);
         ME.super_cmd->state = get_tol;
         break;
       }

       gr$put_chord_height_tolerance(
                                    msg = &msg,
                                    sizbuf = &sizbuf,
                                    buffer = &me->locate_event.event.value);
       ERROR(OM_S_SUCCESS, msg, "ECbool_exec put cht", wrapup);

       me->newtol = TRUE;
     }
    
#endif
     break;
   }


   case undo:
   {
     if (me->got_curve)
     {
       Display_Mode = GRbehe;
       for(index=0; index < num_crvs_out; index++)     
       {
         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                           &me->locate_info.module_info.md_env.matrix_type,
                           me->locate_info.module_info.md_env.matrix,
                           &Display_Mode, 
                          &me->locate_info.module_info.md_id),
                      targetid = crv_out_ids[index],
                      targetos = me->locate_info.located_obj.osnum);
         ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    

         sts = om$send(msg = message GRgraphics.GRdelete(&msg, 
                             &me->locate_info.module_info),
                       targetid = crv_out_ids[index],
                       targetos = me->locate_info.located_obj.osnum);
         ERROR(sts, msg, "ECbool_exec delete crv_out_ids", wrapup);
       }/*end for*/

       if (crv_out_ids) om$dealloc(ptr = crv_out_ids);
       crv_out_ids = NULL;
       num_crvs_out = 0;

       Display_Mode = GRbdhd;
       for(index=0; index < me->num_located; index++)     
       {
         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                       targetid = me->located_ids[index],
                       targetos = me->locate_info.located_obj.osnum);
         ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    
       }/*end for*/
     }
     else  
     {
#ifndef IDRAW
       /*sf/solid boolean*/
       IGRint display_count = 0, involk_count = 0;
       GRobjid *display_ids = NULL;
       IGRushort option;  /*DECL*/

       option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
       sts = om$send(msg = message EMSdpr.EMundo(&msg, &option, 
                           &me->locate_info.module_info, NULL, NULL, NULL,
                           &display_ids, &display_count, &involk_count),
                     targetid = me->construct_id.objid,
                     targetos = me->construct_id.osnum);
       ERROR(sts, msg, "ECbool_exec undo fail", wrapup);  

       Display_Mode = GRhd;
       for(index=0; index < me->num_located; index++)     
       {
         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->locate_info.module_info.md_env.matrix_type,
                            me->locate_info.module_info.md_env.matrix,
                            &Display_Mode, 
                            &me->locate_info.module_info.md_id),
                       targetid = me->located_ids[index],
                       targetos = me->locate_info.located_obj.osnum);
         ERROR(sts, msg, "ECbool_exec erase loc curves", wrapup);    
       }/*end for*/
#endif
     }

     me->is_hilited = TRUE;

     /* || added -- SM */

     if ( (ME.super_cmd->mytype == INTER) ||
          (ME.super_cmd->mytype == SPLIT))
       ME.super_cmd->state = prepsf;
     break;                        
   }  


   case accept:
   {
     sts = dp$erase_hilite(msg = &msg);
     ERROR(sts, msg, "ECbool_sleep erase hi", wrapup);

     if (!me->associative)
     {
      for(index=0; index < me->num_located; index++)
      {
       sts = om$send(msg = message GRgraphics.GRdelete(&msg, 
                           &me->locate_info.module_info),
                     targetid = me->located_ids[index],
                     targetos = me->locate_info.located_obj.osnum);
       ERROR(sts, msg, "ECbool_exec delete crv_out_ids", wrapup);
       }
     }
     me->num_located = 0;

     if (crv_out_ids) om$dealloc(ptr = crv_out_ids);
     crv_out_ids = NULL;
     num_crvs_out = 0;

     if (!gothru)
     {
       /*Place accept event on the software stack*/
       qsize = sizeof(me->locate_event.event) + sizeof (IGRint);
       sts = ex$putque(msg = &msg, 
                       response = response, 
                       byte = &qsize,
                       buffer = (IGRchar *) &me->locate_event.event);
       ERROR(sts, msg, "ECbool_exec put que", wrapup);
     }
     else
     {
       gothru = FALSE;
       ME.COconst->action = NIL;
       return(OM_S_SUCCESS);
     }

     break;
   }


   default:
   {
    ERROR(OM_E_ABORT, EMS_E_Fail, "ECbool_exec action garbage", wrapup);
    break;
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {
   case start:
   {

#ifndef IDRAW
    if (me->newtol)
    {
       /*put old tol back*/
       gr$put_chord_height_tolerance(msg = &msg,
                                     sizbuf = &sizbuf,
                                     buffer = &me->chttol);
       ERROR(OM_S_SUCCESS, msg, "ECbool_sleep put cht", wrapup);

       me->newtol = FALSE;

       a_string[0] = '\0';
 
       sts = EFshort_cvtn(a_string, me->chttol, 0,80);
       ERROR(sts, EMS_S_Success, "ECbool_wake short cvt", wrapup);

       ex$message (
            msgnumb = EMS_I_ChordHeightTolReset,
            var = a_string,
            type = "%s"
       );
    }
#endif

    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   

    switch(me->num_located)
    {
      case 0:
      {
        me->got_curve = FALSE;
        me->got_solid = FALSE;
        me->got_all_solids = TRUE;
        me->is_hilited = FALSE;
        output_inters = FALSE;

        /* Following two lines added -- SM/DLB */
        me->hist_asked = FALSE;
        me->keep_history = FALSE;
        
        if (generalOperation IS EMSbool_difference)
        {
          if (curvesAllowed)
          { 
            locKey = EMS_P_IdCvSfSlArea;
            accKey = EMS_P_AccwEltHole;
          }
#ifndef IDRAW
          else
          {
            /* if statement added -- SM/DLB */
        
            if(ME.super_cmd->mytype == SPLIT)
            {
             locKey = EMS_P_IdSurfToSplit;
             accKey = EMS_P_AcWithSplSurf;
            }
            else
            {
             locKey = EMS_P_IdSfSlArea;
             accKey = EMS_P_AccwSfSlHole;
            }
        
          }
#endif
        }
        else
        {
          if (curvesAllowed)
          {
            locKey = EMS_P_IdCvSfSl;
            accKey = EMS_P_AccwElt;
          }
#ifndef IDRAW
          else
          {
            locKey = EMS_P_IdSfSl;
            accKey = EMS_P_AccwSfSl;
          }
#endif
        }

        break;
      }
     
      case 1:
      {
        if (generalOperation IS EMSbool_difference)
        {
          if (me->got_curve)
          {
            locKey = EMS_P_IdCvHole;
            accKey = EMS_P_AccwCvHole;
          }
#ifndef IDRAW
          else
          {
            /* if statement added -- SM/DLB */
            if(ME.super_cmd->mytype == SPLIT)
            {
             locKey = EMS_P_IdSplSurf;
             accKey = EMS_P_00038;      /* Accept/reject */
            }
            else
            {
             locKey = EMS_P_IdSfSlHole;
             accKey = EMS_P_AccwSfSlHole;
            }
          }
#endif
        }
        else
        {
          if (me->got_curve) 
          {
            locKey = EMS_P_IdCv;
            if (multipleBool)
                accKey = EMS_P_AccwCv;
            else
                accKey = EMS_P_AccCv;
          }
#ifndef IDRAW
          else
          {
            locKey = EMS_P_IdSfSl;
            if (multipleBool)
                accKey = EMS_P_AccwSfSl;
            else
                accKey = EMS_P_AccSfSl;
          }
#endif
        }
        break;
      }
    
      default:
      {
        locate_mask |= GRm_RJT_MOVEON;
        if (generalOperation IS EMSbool_difference)
        {
          if (me->got_curve)
          {
            locKey = EMS_P_IdCvHoleEnough;
            accKey = EMS_P_AccwCvHole;
          }
#ifndef IDRAW
          else
          {
            locKey = EMS_P_IdSfSlHoleEnough;
            accKey = EMS_P_AccwSfSlHole;
          }
#endif
        }
        else
        {
          if(me->got_curve)
          {
            locKey = EMS_P_IdCvEnough;
            accKey = EMS_P_AccwCv;
          }
#ifndef IDRAW
          else
          {
            locKey = EMS_P_IdSfSlEnough;
            accKey = EMS_P_AccwSfSl;
          }      
#endif
        }
        break;
      }
    }

    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    if (me->num_located)
    {
      if (me->got_curve)
      {
        attr.properties = LC_LC_ONLY | 
                          LC_DP_ONLY |
                          LC_RW      |
                          LC_PLANAR_ONLY;

        rtree_classes.w_count = 1;
        rclass[0] = OPP_GRbspline_class_id;

        eliclass[0] = OPP_GRcurve_class_id;

        relKey = EMS_I_CvNotLocated;
      }
      else
      {
#ifndef IDRAW
        aflag = pwIsActivationOn();
        if (aflag)
        {
        attr.properties = LC_LC_ONLY | 
                          LC_DP_ONLY |
                          LC_REF_OBJECTS | /* Added for RFA */
                          LC_RW;
        }
        else
        {
        attr.properties = LC_LC_ONLY | 
                          LC_DP_ONLY |
                          LC_RW;
        }

        rtree_classes.w_count = 2;
        rclass[0] = OPP_EMSsubbs_class_id;
        rclass[1] = OPP_GRtext_class_id;

        relKey = EMS_I_SfSlNotLocated;  
        eliclass[0] = OPP_EMSsurface_class_id;
#endif
      }

      elig_classes.w_count = 1;

      display_flag = LC_ERASE_LOC_ELEMENT |
                        NO_PROJ_ACCEPT_POINT |
                        LC_ACCEPT_CURSOR |
                        ELEM_HILIGHT;
    }
    else
    {
      aflag = pwIsActivationOn();
      if (aflag)
      {
      attr.properties = LC_LC_ONLY | 
                        LC_DP_ONLY |
                        LC_REF_OBJECTS | /*Added for RFA*/
                        LC_RW;
      }
      else
      {
      attr.properties = LC_LC_ONLY | 
                        LC_DP_ONLY |
                        LC_RW;
      }

      if (curvesAllowed)
      {
        rtree_classes.w_count = 2;
        elig_classes.w_count = 1;

        rclass[0] = OPP_GRbspline_class_id;
        rclass[1] = OPP_GRtext_class_id;
#ifndef IDRAW
        rclass[2] = OPP_EMSsubbs_class_id;
        rtree_classes.w_count = 3;
#endif
        eliclass[0] = OPP_GRcurve_class_id;
#ifndef IDRAW
        eliclass[1] = OPP_EMSsurface_class_id;
        elig_classes.w_count = 2;               
#endif

        relKey = EMS_I_EltNotLocated;
      }    
      else
      {
#ifndef IDRAW
        rtree_classes.w_count = 2;
        elig_classes.w_count = 1;

        rclass[0] = OPP_EMSsubbs_class_id;
        rclass[1] = OPP_GRtext_class_id;
        eliclass[0] = OPP_EMSsurface_class_id;
        
        relKey = EMS_I_SfSlNotLocated;
#endif
      }

      display_flag = NO_PROJ_ACCEPT_POINT |
                        LC_ACCEPT_CURSOR |
                        ELEM_HILIGHT;
    }

    aflag = pwIsActivationOn();
    if (aflag)
    {
    attr.owner_action = LC_FLEX_COMP | 
                        LC_REF_OBJECTS | /* Added for RFA */
                        LC_RIGID_OWNER;
    }
    else
    {
    attr.owner_action = LC_FLEX_COMP | 
                        LC_RIGID_OWNER;
    }

    if(ME.super_cmd->mytype != SPLIT)
     attr.owner_action |= (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

    strcpy(attr.classes, "EMSrigid_comp");

    rtree_classes.p_classes = rclass;
    elig_classes.p_classes = eliclass;
/*
 * Modified to call an action handler which mark already located
 * objects as not eligible for locate.
 *
 * 09/20/88 : rlw
 *
 * Modified to support locate element by name.
 *
 * 10/21/88 : rlw
 */
   {
    OMuword reject_classid;
    extern   IGRlong EFlocate_action_handler();
    extern OMuword OPP_SKgeometry_class_id;
    struct   EMSaction_handler already_located;
    struct   EMSaction_handler dont_locate;

    locate_mask |= GRm_STRING;
    if ( me->num_located == 0 || multipleBool ) 
      accept_mask |= GRm_STRING;
    already_located.next = NULL;
    already_located.option = 0;
    already_located.type = 2;
    already_located.num_objects = me->num_located;
    already_located.objects.same_space.space_number = 
                                       me->locate_info.located_obj.osnum;
    already_located.objects.same_space.objid = &me->located_ids[0];

/*    if (!me->associative)     took out for tr 119311796.  dhm 10/25/93
    {*/
     reject_classid = OPP_SKgeometry_class_id;
     dont_locate.next = NULL;
     dont_locate.option = 2;
     dont_locate.type = 3;
     dont_locate.num_objects = 1;
     dont_locate.objects.classids = &reject_classid;
     already_located.next = &dont_locate;
/*    }*/

    me->accept_event.response = -1;
    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->accept_event,  /*Mod by DLB 08/04/88*/
              event3 = &loc_obj_event,     /*Added by DLB 08/04/88*/
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhd,
              locate_key = locKey,
              acc_key = accKey,
              relocate_key = relKey, 
              attributes = &attr, 
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);
   }

#if DEBUG
    fprintf(stderr,"\nloc_event.response = %d", me->locate_event.response);
    fprintf(stderr,"\nacc_event.response = %d", me->accept_event.response);
    fprintf(stderr,"\nloc_obj_event.response = %d", loc_obj_event.response);
    fprintf(stderr,"\nloc_stk.#entries = %d", me->locate_stack.num_entries);
    fprintf(stderr,"\nloc_stk.#loc = %d", me->locate_stack.number_located);
#endif

    /*Added by DLB 08/04/88*/
    /*Personal comment: Locate is screwed beyond belief!!  If you 
     * decide to modify the code that follows then heed the words of
     * Zork "Abandon hope all ye that enter here."  So trust me when I
     * say "DO NOT CHANGE THE CODE THAT FOLLOWS THIS STATEMENT."
     */

    if (msg == LC_OBJ_LOCATED) /*Something was located.*/
    {
      me->locate_event.num_id = loc_obj_event.num_id;
      me->locate_event.located_object[0] = loc_obj_event.located_object[0];
      me->locate_event.response = me->accept_event.response; /*correct it*/
    }
    else if (me->locate_stack.num_entries)
      /*Exited locate during acc/rjt, reflect response in locate_event.*/
      me->locate_event.response = me->accept_event.response; 
    else if (me->locate_event.response == EX_DATA)
    {
      if (me->accept_event.response == -1)    
        me->locate_event.response = VALUE;      /*nothing located, loop thru*/
      else
        me->locate_event.response = EX_BACK_UP; /*Backed out of acc/rjt*/
    }

    token = GRloc_token(&msg, Tokens, &me->locate_event);

#if DEBUG
    fprintf(stderr,"\ntoken = %d", token);
#endif

    break;                                               
   }                                                     
                                                         
                                                         
   case prepsf:
   {                                                     
     if (me->num_located)                                
     { 
       /* Added || -- SM/DLB */

       if (me->got_curve || 
           ((ME.super_cmd->mytype == SPLIT) && (me->num_located != 1)))
       {                                                 
         if (token == 0)
           /*I got here due to a backup op. so I continue to backup.*/
           break;
         else
         {
	   change_mask = NULL;
           save_rsp = me->locate_event.response;
           token = 3; /*SIMULATE STRING EVENT*/            
           break;                                          
         }
       }                                                 

#ifndef IDRAW                                                         
       {
         struct GRid    tempid;   /*DECLARE*/              
         struct GRevent tempevent;                         
                                                         
         change_mask = NULL;                               
         locate_mask = GRm_BACK_UP;                        
         tempid.objid = me->located_ids[me->num_located-1];
         tempid.osnum = me->locate_info.located_obj.osnum; 
                                                         
         save_rsp = me->locate_event.response;  /*save the response*/
         tempevent = me->locate_event;          /*save the data event*/

         sts = ECprepsurf(&msg, &me->locate_info.module_info,
                         &ME.COconst->ActiveDisplay, tempid, &tempevent,
                        locate_mask, response, response_data, &change_mask);
         ERROR(sts, msg, "ECbool_exec prepsf", wrapup);

         if (msg == EMS_I_NoResponse)
         {
           if (save_rsp == EX_BACK_UP)
             tempevent.response = EX_BACK_UP;
           else
             tempevent.response = STRING;
         }

         token = GRloc_token(&msg, Tokens, &tempevent);
       }
#endif
     }
     else
       token = 0;  /*SIMULATE A EX_BACK_UP OP*/
     break;
   }


   case get_tol:
   {
#ifndef IDRAW
     /******************************************************10/3/89 DLB
     IGRdouble  tol;

     gr$get_chord_height_tolerance(msg = &msg, 
                                   sizbuf = &sizbuf,
                                   buffer = &tol,
                                   nret = &nret);
     ERROR(OM_S_SUCCESS, msg, "ECbool_exec get cht tol", wrapup);
 
     if (!me->newtol) me->chttol = tol;

     a_string[0] = '\0';

     sts = EFshort_cvtn(a_string, tol, 0,80);
     ERROR(sts, EMS_S_Success, "ECbool_exec short cvt", wrapup);

     ex$message (
        msgnumb = EMS_I_ChordHeightTolIs,
        var = a_string,
        type = "%s"
     );
     **********************************************************************/

     localMsg (EMS_P_KeyinCHTaccCHTwD);

     locate_mask = GRm_BACK_UP | GRm_DATA;      /*GRm_DIST |    10/3/89 DLB*/
     
     token = GRget_token(&eventmsg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
     localMsg (EMS_I_ClearStatusField);
#endif
     break;
   }           

 
   case dummy:
   {
     token = 1; /*Simulate a DATA event.*/
     break;
   }


   case ck_result:
   {
#ifndef IDRAW

     if (me->got_all_solids)
     {
       token = 3;  /*Simulate string event.*/
       break;
     }

     {
       IGRushort options;  /*DECL*/

       msg = EMS_S_Success;
       options = EMS_CHECK_CLOSURE;

       if (me->got_solid)
         options |= EMS_GOOD_ORIENT;
       else
         options |= EMS_ASK_CONVERT;

       /* if statement for SPLIT added -- SM. */
       if(ME.super_cmd->mytype == SPLIT)
        {
         OM_S_CHANSELECT        to_mirror_image;
         OM_S_OBJECT_LINKAGE    image;
         OMuint                 count = 0;
         IGRlong                msg1, msg2;
         struct GRid            image_id;
         IGRchar                cvrtPrompt[MS_MAX_MSG_LENGTH+1];

         sts = EMmake_chanselect (EMSsfspltwsf_to_mirror_image, 
                                  &to_mirror_image);
         sts = om$get_channel_objects(objid = me->construct_id.objid,
                            osnum = me->construct_id.osnum, 
                            p_chanselect = &to_mirror_image, 
                            list = &image, size = 1, count = &count);
         ERROR(sts, msg, "ECbool_exec get chan objects", wrapup);
         if(!count) image.S_objid = NULL_OBJID;
         ex$message (msgnumb = EMS_P_CvrtClPieceSol, buff = cvrtPrompt);

         sts = EFmksolid(&msg1, &me->locate_info.module_info, 
                       &ME.COconst->ActiveDisplay, &me->construct_id,
                       &me->locate_event, response, response_data, Tokens,
                       options, "EMSslspltwsf", cvrtPrompt);
         ERROR(sts, msg1, "ECbool_exec EFmksolid", wrapup);
         token = GRloc_token(&msg, Tokens, &me->locate_event);

         if(Tokens[token] == EX_BACK_UP) break;

         image_id.objid = image.S_objid;
         image_id.osnum = me->construct_id.osnum;
         sts = EFmksolid(&msg2, &me->locate_info.module_info, 
                       &ME.COconst->ActiveDisplay, &image_id,
                       &me->locate_event, response, response_data, Tokens,
                       options, "EMSslspltwsf", cvrtPrompt);
         ERROR(sts, msg, "ECbool_exec EFmksolid", wrapup);

         if (msg1 == EMS_I_NoResponse)
          {
           IGRint edge_count;    /*DECL*/
           sts = om$send(msg = message EMSsurface.EMdisplay_edges(&msg, 
                           &me->locate_info.module_info,
                           EMS_OPT_CONNECTABLE, GRhe, &edge_count),
                     targetid = me->construct_id.objid,
                     targetos = me->construct_id.osnum);
           ERROR(sts, msg, "ECbool_exec EMdisplay_edges", wrapup);     
           localMsg (EMS_I_ClearStatusField);
          }
        
         if (msg2 == EMS_I_NoResponse)
          {
           IGRint edge_count;    /*DECL*/
           sts = om$send(msg = message EMSsurface.EMdisplay_edges(&msg, 
                           &me->locate_info.module_info,
                           EMS_OPT_CONNECTABLE, GRhe, &edge_count),
                     targetid = image_id.objid,
                     targetos = image_id.osnum);
           ERROR(sts, msg, "ECbool_exec EMdisplay_edges", wrapup);     
           localMsg (EMS_I_ClearStatusField);
          }
        
        } /* if(ME.super_cmd->mytype == SPLIT) */
       else
        {
         sts = EFmksolid(&msg, &me->locate_info.module_info, 
                       &ME.COconst->ActiveDisplay, &me->construct_id,
                       &me->locate_event, response, response_data, Tokens,
                       options, "EMSslboolean", NULL);
         ERROR(sts, msg, "ECbool_exec EFmksolid", wrapup);     
         if (msg == EMS_I_NoResponse)
          {
           IGRint edge_count;    /*DECL*/
           sts = om$send(msg = message EMSsurface.EMdisplay_edges(&msg, 
                           &me->locate_info.module_info,
                           EMS_OPT_CONNECTABLE, GRhe, &edge_count),
                     targetid = me->construct_id.objid,
                     targetos = me->construct_id.osnum);
           ERROR(sts, msg, "ECbool_exec EMdisplay_edges", wrapup);     
           localMsg (EMS_I_ClearStatusField);
           msg = EMS_I_NoResponse;
          }
        }

       token = GRloc_token(&msg, Tokens, &me->locate_event);

     }

#endif

     break;
   }

  
   case acc_rjt:
   {
     localMsg (EMS_P_AccwAnyEventBackupForUndo);
     locate_mask = GRm_BACK_UP | GRm_DATA;
     
     token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);

     localMsg (EMS_I_ClearStatusField);

     if (Tokens[token] == GR_UNKNOWN_TYPE) 
       gothru = TRUE;
     else
       gothru = FALSE;

     break;
   }


   /* Following state added -- SM/DLB */

#ifndef IDRAW
   case sv_hist:
    {
     OMuword locclassid;
     IGRboolean hist = FALSE;
     IGRint i;
     for(i=0; i<me->num_located; i++)
      {
       sts = om$get_classid(objid = me->located_ids[i],
                           osnum = me->locate_info.located_obj.osnum,
                           p_classid = &locclassid);
       ERROR(sts, EMS_S_Success, "ECbool_exec get classid", wrapup); 

       sts = om$is_ancestry_valid(superclassid = OPP_EMSdpr_class_id,
                                 subclassid = locclassid);
       ERROR(sts, EMS_S_Success, "ECbool_exec is ancect valid", wrapup);   

       if (sts == OM_S_SUCCESS || locclassid == OPP_EMSdpr_class_id)
        {hist = TRUE; break;}
      }

     if(hist)
      {
       ex$message(msgnumb = EMS_P_MaintainHist)
       locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
       token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);

       localMsg (EMS_I_ClearStatusField);
       me->hist_asked = TRUE;
       if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
         me->keep_history = TRUE;
       else if(Tokens[token] == STRING)  
        {
         if(toupper(me->locate_event.event.keyin[0]) == 'O') 
          me->keep_history = FALSE;
         else me->keep_history = TRUE;
        }
       else {me->hist_asked = FALSE;me->keep_history = TRUE;}
      }
     else
      {
       me->keep_history = FALSE;        
       me->hist_asked = TRUE;
      }
    }
    break;

#endif

   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "ECbool_exec state garbage", wrapup);
     break;
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE || gothru);
 return(sts);

 wrapup:
  *response = TERMINATE;
  return(OM_E_ABORT);

}

void localMsg (msgnumb)
IGRlong msgnumb;
{
    ex$message (msgnumb = msgnumb);

    return;
}

end implementation ECboolean;
