/*
HISTORY:

Siki  : ???      : Creator

Ashok : 12/12/92 : Added the following functions to this file in collaboration
   		   with Siki.
   EMmsplit_sf_intobj_uv() - Splits a given intobj at multiple split points
			     passed in as a "EMSpypoint" list.
   EMsplit_sf_intobj_uv2() - Transferred code of EMsplit_sf_intobj_uv() to
			     this new function which has an additional
			     argument providing the option to split the "other"
			     intobj. EMsplit_sf_intobj_uv() now calls this
			     with that option set to TRUE.
   EMconvert_to_edge() - Converts data of an intobj to an edge.
   EMintobj_closed() - Finds in an intobj is closed in XYZ or UV.

Siki  : ??/??/93   : New functions added for Phoenix Rounding.

Ashok : 03/04/93   : Reintegrated above changes into the file as they all got
		     lost due to an over-write in RCS by Siki. Also knocked off
		     my version of EMconvert_to_edge().
NP    : 06/01/93   : Function call "EMmkintobj" was replaced by "EMmakeintobj".
                     The name was changed due to addition of a new parameter.
                     Also, added code to update the newly created "curve_type"
                     field of the intobj when the intobj is split.
                     Deleted new function "EFdelete_empty_inters" since it was 
                     doing what "EMcmpinters" already does.
NP    : 06/06/93   : Moved EMget_intersection_points() to EMdatasupp.I.
NP    : 06/07/93   : Moved EFget_intersection_points() (which is Nirmal's 
                     enhancement of "EMget_intersection_points" to handle 
                     objects) to the file EMdatasupp.I, where it will replace 
                     the function "EMget_intersection_points".
                     My contribution here is the addition of a new parameter
                     "intdata2_reversed" which makes the function consistent.
Sudha : 07/09/93   : Modified for BSprototypes anisfication

NP    : 07/16/93   : Added new function "EMdelintobj_selective".
 
NP    : 12/08/93   : Added two new functions "EFtransfer_inters" and 
                     "EFget_coincident_edge".

Vadi  : 05/24/94   : In 'mergetrace', the subgrp_rev data for the trace2
                     was wrongly being recorded.  

Sanjay: 08/25/95   : Modified "EMfind_uv_xyz_point" to check for all possible
                     uv points if the projected xyz point falls on the seam 
                     of the surface and return that uv point which is close
                     to the given uv dataselect.

Aditya: 11/20/95   : Added functions EMaddintobj(), EMmergeintobjs() and
                     EMcheck_intobj_endpt_match().
*/            

class implementation Root;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "gocmacros.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMminimum.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "emsdattyp.h"
#include "emssfintdef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emserr.h"
#include "msdef.h"
#include "madef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bscvmidpt.h"
#include "mabcendpts.h"
#include "emsmapdef.h"
#include "EMSprop.h"
#include "emsinterdef.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "emsgeteddef.h"
#include "EMStpmacros.h"

%safe
#include <math.h>
#include "bssfkttol2.h"
#include "bssfeval.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
static void create_sibling();
%endsafe

#define EMerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define U 0
#define V 1

#define FIRST  0
#define SECOND 1

#define THIS  0
#define OTHER 1

#define START 0
#define STOP  1

#define UV  0
#define XYZ 1

#define WANT_TO_DISPLAY_INTOBJS_BEING_DELETED  FALSE

#define NUM_INTERNAL_SAMPLES 3

extern GRclassid OPP_GRbcsubbc_class_id;

extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_EMScomposite_class_id;

from GRvg import GRgetsize, GRgetgeom, EMpratpt;
from GRcurve import GRendpts;
from GRowner import GRget_number_components, GRget_components;
from EMSedge import EMgetvtxedges, EMget_bcxyz_geom;
from EMScompsurf import GRptproject;

from GRvg import EMptatpr;

#ifndef IDRAW
from EMSboundary import EMget_objid;
from EMSedge import  EMendpts;
from EMSsubbs import EMpassloop, EMpartolbasis;
from EMSloopset import EMpt_location;
from EMSloop import EMnext_edge;
from EMSedge import EMpratpt;
#endif

/******************************************************************************/
/*                                                                            */
/*      PLEASE PUT ALL "DATASELECT" RELATED FUNCTIONS IN "EMdatasupp.I" FILE  */
/*                             AND NOT IN HERE.                               */
/*    THIS FILE IS FOR FUNCTIONS THAT OPERATE ON "EMSintobj" and "EMSinters"  */
/******************************************************************************/


/*
  ABSTRACT

    Function to remove from the intersection list, a given EMSintobj
    node. Also this node's corresponding node (in the sister-list), if
    it exists, is removed through the back-pointer built into the EMSintobj
    structure. The relevant parent EMSinters node is updated to reflect
    such removals. The value of this function being returned is the pointer
    to the next intobj. This next intobj is the one that existed in the list
    after the one being deleted.
 
  NOTES
    
    The EMSinters parents may be left with no EMSintobj children, but these
    are NOT removed from the list. Such empty nodes can be detected by
    the caller by "num_pts" and "num_cvs" fields being zero. Also the
    pointer to the EMSintobj children would have been set to NULL.

  HISTORY

    SS  :  10/30/87  :  Creation 
  Inasu :  07/01/91  :  Modified to reset the 'props','fwd','bwd' pointers 
                        of 'bwd','fwd' respectively of this_intobj.
    SS  :  06/25/93  :  Function now returns pointer to the next intobj
                        in the list (could be NULL of the intobj being
                        deleted was the last one).
*/

#define CURVE 0
#define POINT 1

struct EMSintobj *EMdelintobj (msg, this_intobj)
IGRlong *msg;
struct EMSintobj *this_intobj;
{
  IGRboolean inters_attached;
  IGRshort type;
  IGRlong msg_loc, stat_func;
  struct EMSinters *this_inters;
  struct EMSintobj *other_intobj, *prev_intobj, *next_intobj;
  void EMintobj_free(), EMintobj_data_free(), EMsfintedpar_free();

  *msg = EMS_S_Success;

  next_intobj = NULL;

  this_inters = this_intobj->this_obj_node;
  for (type=CURVE; type<=POINT; type++)
    {
    prev_intobj = type == CURVE ? this_inters->cvs : this_inters->pts;
    inters_attached = TRUE;
    if (prev_intobj != this_intobj)
      {
      inters_attached = FALSE;
      while (prev_intobj && prev_intobj->next != this_intobj)
        prev_intobj = prev_intobj->next;
      if (prev_intobj)
        break;
      }
    else
      break;
    }
  EMerr_hndlr (!prev_intobj, *msg, EMS_E_InvalidArg, ret_end);
  other_intobj = this_intobj->other_intobj_node;

  /* If this_intobj has got 'fwd' ,'bwd' pointers. Update the 'props' field
   * of these and reset the 'bwd' of 'fwd' and 'fwd' of 'bwd' to NULL.
   */ 

   if(this_intobj->bwd )
   {
    this_intobj->bwd->props &= 
			~(EMSintobj_fwd_connectuv | EMSintobj_fwd_noconnectuv);
    this_intobj->bwd->fwd   = NULL;
   }
                      
   if(this_intobj->fwd)
   {
    this_intobj->fwd->props &= 
			~(EMSintobj_bwd_connectuv | EMSintobj_bwd_noconnectuv);
    this_intobj->fwd->bwd   = NULL;
   }

  next_intobj = this_intobj->next;
  if (inters_attached)
    {
    if (type == CURVE)
      this_inters->cvs = next_intobj;
    else
      this_inters->pts = next_intobj;
    }
  else
    prev_intobj->next = next_intobj;

  EMintobj_data_free (&msg_loc, this_intobj, 1, EMsfintedpar_free);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMintobj_free (this_intobj, 1);

  if (type == CURVE)
    this_inters->num_cvs--;
  else
    this_inters->num_pts--;

  if (other_intobj)
    {
    other_intobj->other_intobj_node = NULL;
    EMdelintobj (&msg_loc, other_intobj);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  
ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "EMdelintobj");
  return (next_intobj);
}


/***************************************************************************/
/*
 ABSTRACT:

 This function deletes from an inters list, those intobjs specified by bits
 that it MUST have ("check_present_bits") and those it must NOT 
 ("check_absent_bits"). If BOTH arguments are NULL, it deletes ALL the intobjs
 in the inters list. For debugging purposes, it is possible to actually diaply
 points on intobjs being deleted using a #define.

 POSSIBLE ENHANCEMENT:
 
 1. Compression of inters list (using EMcmpinters) if a particular inters node
    lost all its intobjs.

 2. If ALL inters nodes are empty after this function call (assuming step 1 
    above is implemented), return appropriate error message.

 3. Use options argument to drive behavior.

 HISTORY:

  NP  07/16/93  Creation.
  NP  09/06/93  Changed arguments of function.
 */

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

void EMdelintobj_selective(EMmsg, options, inters, check_present_bits,
                             check_absent_bits)
IGRlong *EMmsg, options, check_present_bits, check_absent_bits;
struct EMSinters *inters;
{
  IGRlong sts, msg_loc;
  struct EMSinters *inters_loc;
  struct EMSintobj *intobj_loc, *next_intobj;

#if WANT_TO_DISPLAY_INTOBJS_BEING_DELETED 
  IGRlong i, bufsiz, nret;
  struct GRmd_env md_env;
  struct GRvg_construct construct_list;
  struct IGRdisplay display_attr;
  IGRpoint *pts;
  extern IGRlong EMinternalpt();
#endif

 
  sts    = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
   
#if WANT_TO_DISPLAY_INTOBJS_BEING_DELETED 
   /* get current display info, env etc. */
   pts = (IGRpoint *) alloca (sizeof (IGRpoint) * 3);
   EMgetmdenv (&md_env, NULL, NULL, inters->this_obj.osnum);
   EMinitvgcnstr (&msg_loc, &md_env, NULL, NULL, &construct_list);
   bufsiz = sizeof(struct IGRdisplay);
   gr$get_active_display(msg = &msg_loc,
                        sizbuf = &bufsiz,
                        buffer = &display_attr,
                        nret = &nret);
   construct_list.display = &display_attr;
#endif


   inters_loc = inters;
   while (inters_loc)
   {  intobj_loc = inters_loc->cvs;
      while (intobj_loc)
      {
        next_intobj =  intobj_loc->next;

        /* delete those intobjs that have "check_present_bits" set,
         * and "check_absent_bits" NOT set.If both are NULL, delete this intobj
         * anyway.
         */
        if((check_present_bits? (intobj_loc->props&check_present_bits):TRUE) &&
           (check_absent_bits ?!(intobj_loc->props&check_absent_bits) :TRUE) )
           {

#if WANT_TO_DISPLAY_INTOBJS_BEING_DELETED 
             /* get 3 internal pts for the intobj */
             EMinternalpt (&msg_loc, &(md_env.md_env.matrix_type), 
                           md_env.md_env.matrix, &(intobj_loc->this_xyzintobj),
                           EMScvint_middle, 3, pts);
             EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
             construct_list.display->color +=2;
             construct_list.display->weight +=3;
             for (i=0; i<3; i++)
             { ECdisplayPointSetByBuffer(&msg_loc,
                        *(construct_list.display),
                        *(construct_list.env_info), NULL_OBJID, 1,
                        &(pts[i]), TRUE);
               EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
             }
             construct_list.display->color -= 2;
             construct_list.display->weight -=3;
#endif

             EMdelintobj (&msg_loc, intobj_loc);
             EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
           }
        intobj_loc = next_intobj;
      }
      inters_loc = inters_loc->next;
   }

  wrapup:

  EMWRAPUP (*EMmsg, sts, "In EMdelintobj_selective");
}
/***************************************************************************/


/*
  ABSTRACT

    The following function is used to compress an EMSinters list, viz,
    remove any EMSinters nodes that may exist without any EMSintobj nodes
    on them. Finally if no EMSinters nodes are left this NULL-list condition
    is flagged.

  HISTORY

    SS  :  10/24/89  :  Creation
*/

void EMcmpinters (msg, inters)
IGRlong *msg;
struct EMSinters **inters;
{
  IGRboolean exhausted, at_start;
  struct EMSinters *inters_prev, *inters_del;
  extern void EMinters_free();

  *msg = EMS_S_Success;

  if (!inters)
    goto ret_end;

  exhausted = FALSE;
  while (! exhausted)
    {
    inters_prev = *inters;
    at_start = TRUE;
    inters_del = NULL;
    if (inters_prev && (inters_prev->num_cvs || inters_prev->num_pts))
      {
      at_start = FALSE;
      while (inters_prev->next)
        {
        if (! (inters_prev->next->num_cvs || inters_prev->next->num_pts))
          {
          inters_del = inters_prev->next;
          break;
          }
        inters_prev = inters_prev->next;
        }
      }
    else if (inters_prev)
      inters_del = inters_prev;
  
    if (inters_del)
      {
      if (at_start)
        {
        if (! (*inters = inters_prev->next))
          {
          *msg = EMS_I_NoMore;
          }
         else
          {
          inters_prev->next->num_coincs = inters_prev->num_coincs;
          inters_prev->next->coinc_info_list = inters_prev->coinc_info_list;
          inters_prev->num_coincs = NULL;
          inters_prev->coinc_info_list = NULL;
          }
        EMinters_free (inters_del, 1);
        }
      else
        {  
        inters_prev->next = inters_prev->next->next;
        EMinters_free (inters_del, 1);
        }
      }
    else
      exhausted = TRUE;
    }

ret_end:;
}


/*
  ABSTRACT

    The following function is used to swap the places of two given EMSintobj
    nodes in the EMSinters list.

  NOTES

    Except in rare cases it only makes sense to swap EMSintobj's belonging
    to the same EMSinters. But no such restriction is imposed.

  HISTORY

    SS  :  05/09/89  :  Creation
*/


void EMswapintobj (msg, is_curve, intobj1, intobj2)
IGRlong *msg;
IGRboolean is_curve;
struct EMSintobj *intobj1, *intobj2;
{
  IGRboolean at_start[2];
  IGRshort i;
  struct EMSintobj *prev_intobj[2], *intobj[2], *next_intobj[2];
  struct EMSinters *inters[2];

  *msg = EMS_S_Success;

  if (intobj1 == intobj2)
    goto  ret_end;

  intobj[FIRST] = intobj1;
  intobj[SECOND] = intobj2;

  for (i=FIRST; i<=SECOND; i++)
    {
    inters[i] = intobj[i]->this_obj_node;
    prev_intobj[i] = is_curve ? inters[i]->cvs : inters[i]->pts;

    if (intobj[i] == prev_intobj[i])
      at_start[i] = TRUE;
    else
      {
      at_start[i] = FALSE;
      while (prev_intobj[i] && prev_intobj[i]->next != intobj[i])
        prev_intobj[i] = prev_intobj[i]->next;
      EMerr_hndlr (!prev_intobj[i], *msg, EMS_E_InvalidArg, ret_end);
      if (prev_intobj[i] == intobj[!i])
        prev_intobj[i] = intobj[i];
      }

    next_intobj[i] = intobj[i]->next;
    if (next_intobj[i] == intobj[!i])
      next_intobj[i] = intobj[i];
    }

  for (i=FIRST; i<=SECOND; i++)
    {
    if (at_start[i])
      {
      if (is_curve)
        inters[i]->cvs = intobj[!i];
      else
        inters[i]->pts = intobj[!i];
      }
    else
      prev_intobj[i]->next = intobj[!i];
    intobj[!i]->next = next_intobj[i];
    }

ret_end:
  return;
}


/*
  DESCRIPTION

    This functions merges the second list into the first
    one.
*/

void EMmergeinters (EMmsg, main_list, sub_list)
IGRlong *EMmsg;
struct EMSinters **main_list,*sub_list;
{
  struct EMSinters *current_main_node,*current_sub_node, *next_sub_node;
  struct EMSintobj *current_intobj;

    *EMmsg = EMS_S_Success;

    if (!main_list || !sub_list)
      goto ret_end;

    current_main_node = NULL;
    current_sub_node  = NULL;
    next_sub_node     = NULL;
    current_intobj    = NULL;

    if(*main_list )
    {
        /* take a node of sub list and if this surface already present in the
         * main list concatenate the intobjs of sub list to the main node.
         * Update the num cvs and the this_obj_node filed of the sub list
         */
      for( current_sub_node = sub_list; 
           current_sub_node != NULL;
           current_sub_node = next_sub_node)
      {
          next_sub_node = current_sub_node->next;

          for(current_main_node = *main_list;
              current_main_node != NULL;
              current_main_node = current_main_node->next) 
           {
               if( IF_EQ_OBJID(current_main_node->this_obj.objid,
                                  current_sub_node->this_obj.objid)) 
               {
               /* Total number of intersections woulde sum of the following */

                current_main_node->num_cvs += current_sub_node->num_cvs;

                for( current_intobj = current_main_node->cvs;
                     current_intobj->next != NULL;
                     current_intobj = current_intobj->next);

                current_intobj->next = current_sub_node->cvs;

                /* And 'this_obj_node' field of the added  intersections will 
		   be the 'current_main_node' */

                for( current_intobj = current_sub_node->cvs;
                     current_intobj != NULL;
                     current_intobj = current_intobj->next)
                       current_intobj->this_obj_node = current_main_node;

                 break; /* from the for loop of main_list */
                }
	        else 

                if(current_main_node->next == NULL)
                {
                  /* means the surface node is not in the main list
                   * So simply 'cat' to the main list
                   */ 

                   current_main_node->next = current_sub_node;
                   current_main_node->next->next = NULL;
                   break; /* indicates the  end of the main_list */
                }
           }
      }

    } 
    else 
        (*main_list) = sub_list;

ret_end:
  return;
}

/*
   DESCRIPTION:

     Given a surface id, and two inters lists, this function will tranfer the
     node in the first inters list that corresponds to the given surface id to 
     the second inters list. 
 
   INPUT/OUTPUT:

O    EFmsg             Return code. 
                       EMS_S_Success     on success.
                       EMS_E_Fail        on failure.
                       EMS_I_InvalidArg  if input is invalid.
                       EMS_I_NotFound    if inters node correponding to input
                                         surface was not found in "in_inters"

I    sf_id             Surface id which determines the inters node that will
                       be transferred from "in_inters" to "out_inters".

I/O  in_inters         The inters list which contains the inters node that
                       corresponds to "sf_id". The node is unlinked from this
                       list and added to the "out_inters" list.

I/O  out_inters        The inters list to which we will add the inters node 
                       from "in_inters" that corresponds to "sf_id".

   ALGORITHM:

   Self evident.

   HISTORY:

   12/08/93 : NP  : Creation.

 */

void  EFtransfer_inters (EFmsg, sf_id, in_inters, out_inters)
IGRlong *EFmsg;
struct GRid *sf_id;
struct EMSinters **in_inters;
struct EMSinters **out_inters;
{
  IGRlong sts, msg_loc;
  struct EMSinters *inters_loc, *inters_loc_next, *inters_loc_prev;
  IGRboolean found_node;

  extern void EMmergeinters();

  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  /* Exit without error (EMS_I_InvalidArg) on finding invalid input */
  if (!sf_id  || 
      (sf_id && (sf_id->objid==NULL_OBJID)) || 
      !(*in_inters) ||  
      !out_inters )
     {EMerr_hndlr(TRUE, *EFmsg, EMS_I_InvalidArg, wrapup);}
     

  inters_loc = *in_inters;
  inters_loc_prev = NULL;
  found_node = FALSE;

  while (inters_loc)
  { 
      inters_loc_next = inters_loc->next;
      if ((inters_loc->this_obj.objid == sf_id->objid) &&
          (inters_loc->this_obj.osnum == sf_id->osnum))
      {
         /* reset the incoming list to skip this node */ 
         if (inters_loc_prev)
           inters_loc_prev->next = inters_loc_next;
         else
           (*in_inters) = inters_loc_next;

         /* the node to be transferred does not point to its old list any more*/
         inters_loc->next = NULL;

         /* merge current node with the out_inters list */

         (void) EMmergeinters (&msg_loc, out_inters, inters_loc);
         EMerr_hndlr(!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

         found_node = TRUE;
         break; /* we have found & processed the correct inters node*/
      }

    inters_loc_prev = inters_loc;
    inters_loc = inters_loc_next;
  }

  /* return info code back saying surface not found on "in_inters" list */
  if (!found_node)
     *EFmsg = EMS_I_NotFound;

  wrapup:

  EMWRAPUP( *EFmsg, sts, "In EFtransfer_inters");
}

/* This function merges the two trace data's & creates a new one */

void EMmergetrace(EMmsg, trace1, trace2, merged_trace)
IGRlong *EMmsg;
struct EMSsftracedata	*trace1, *trace2, *merged_trace;
{
	IGRint num_grps, i, j, k, temp, temp_i;
	struct EMSsftracedata *temp_trace;

	num_grps = trace1->num_grps + trace2->num_grps;

	merged_trace->num_grps = num_grps;

	merged_trace->num_subgrps_grp = (IGRint *) om$malloc(size = num_grps * 
		sizeof(IGRint));

	EMerr_hndlr(!(merged_trace->num_subgrps_grp), *EMmsg, 
		EMS_E_NoDynamicMemory, wrapup);

	merged_trace->num_elems_subgrp = (IGRint **) om$malloc(size = 
		num_grps * sizeof(IGRint *));

	EMerr_hndlr(!(merged_trace->num_elems_subgrp), *EMmsg, 
		EMS_E_NoDynamicMemory, wrapup);

	merged_trace->elems = (struct EMSintobj ***) om$malloc(size = 
		num_grps * sizeof(struct EMSintobj **));

	EMerr_hndlr(!(merged_trace->elems), *EMmsg, 
		EMS_E_NoDynamicMemory, wrapup);

	merged_trace->subgrp_rev = (IGRboolean **) om$malloc(size = 
		num_grps * sizeof(IGRboolean *));

	EMerr_hndlr(!(merged_trace->subgrp_rev), *EMmsg, EMS_E_NoDynamicMemory,
		wrapup);

	merged_trace->elem_rev = (IGRboolean ***) om$malloc(size = 
		num_grps * sizeof(IGRboolean **));

	EMerr_hndlr(!(merged_trace->elem_rev), *EMmsg, EMS_E_NoDynamicMemory, 
		wrapup);

	merged_trace->grp_closed = (IGRboolean *) om$malloc(size = 
		num_grps * sizeof(IGRboolean));

	EMerr_hndlr(!(merged_trace->grp_closed), *EMmsg, EMS_E_NoDynamicMemory,
		wrapup);

	merged_trace->subgrp_closed = (IGRboolean **) om$malloc(size = 
		num_grps * sizeof(IGRboolean *));

	EMerr_hndlr(!(merged_trace->subgrp_closed), *EMmsg, 
		EMS_E_NoDynamicMemory, wrapup);

	for(i = 0; i < num_grps; i++) {
		if(i < trace1->num_grps) {
			temp_i = i;
			temp_trace = trace1;
		}
		else {
			temp_i = i - trace1->num_grps;
			temp_trace = trace2;
		}
		
		merged_trace->num_subgrps_grp[i] = 
			temp_trace->num_subgrps_grp[temp_i];

		merged_trace->elem_rev[i] = (IGRboolean **)
		     om$malloc(size = temp_trace->num_subgrps_grp[temp_i] *
				sizeof(IGRboolean *)); 

		EMerr_hndlr(!(merged_trace->elem_rev[i]), *EMmsg, 
			EMS_E_NoDynamicMemory, wrapup);
                
                merged_trace->num_elems_subgrp[i] = (IGRint *)
                     om$malloc(size = temp_trace->num_subgrps_grp[temp_i] *
                                sizeof(IGRint));

                EMerr_hndlr(!(merged_trace->num_elems_subgrp[i]), *EMmsg,
                        EMS_E_NoDynamicMemory, wrapup);

                merged_trace->elems[i] = (struct EMSintobj **)
                     om$malloc(size = temp_trace->num_subgrps_grp[temp_i] *
                                sizeof(struct EMSintobj *));

                EMerr_hndlr(!(merged_trace->elems[i]), *EMmsg,
                        EMS_E_NoDynamicMemory, wrapup);

		for(j = 0; j < temp_trace->num_subgrps_grp[temp_i]; j++) {

		    merged_trace->elem_rev[i][j] = (IGRboolean *)
		     om$malloc(size = temp_trace->num_elems_subgrp[temp_i][j] *
				sizeof(IGRboolean)); 

		    EMerr_hndlr(!(merged_trace->elem_rev[i][j]), *EMmsg, 
			EMS_E_NoDynamicMemory, wrapup);
   		}
		merged_trace->subgrp_rev[i] = (IGRboolean *)
		    om$malloc(size = temp_trace->num_subgrps_grp[temp_i] *
				sizeof(IGRboolean)); 

		EMerr_hndlr(!(merged_trace->subgrp_rev[i]), *EMmsg, 
			EMS_E_NoDynamicMemory, wrapup);

		merged_trace->subgrp_closed[i] = (IGRboolean *)
		    om$malloc(size = temp_trace->num_subgrps_grp[temp_i] *
				sizeof(IGRboolean)); 

		EMerr_hndlr(!(merged_trace->subgrp_closed[i]), *EMmsg, 
			EMS_E_NoDynamicMemory, wrapup);
	}

	for(i = 0; i < trace1->num_grps; i++) {
		for(j = 0; j < (merged_trace->num_subgrps_grp)[i];j++) {
			merged_trace->num_elems_subgrp[i][j] = 
				trace1->num_elems_subgrp[i][j];

			merged_trace->elems[i][j] = trace1->elems[i][j], 

			merged_trace->subgrp_rev[i][j] = 
				trace1->subgrp_rev[i][j];

			for(k = 0; k < merged_trace->num_elems_subgrp[i][j];
				k++) {
				merged_trace->elem_rev[i][j][k] = 
					trace1->elem_rev[i][j][k];
			}
			merged_trace->subgrp_closed[i][j] = 
				trace1->subgrp_closed[i][j];
		}
		merged_trace->grp_closed[i] = trace1->grp_closed[i];
	}

	temp = trace1->num_grps;

	for(i = 0; i < trace2->num_grps; i++) {
		for(j = 0; j < merged_trace->num_subgrps_grp[temp + i]; j++) {
			merged_trace->num_elems_subgrp[temp + i][j] = 
				trace2->num_elems_subgrp[i][j];

			merged_trace->elems[temp + i][j] = trace2->elems[i][j]; 

			merged_trace->subgrp_rev[temp + i][j] = 
				trace2->subgrp_rev[i][j];

			for(k=0; k<merged_trace->num_elems_subgrp[temp + i][j];
				k++) {
				merged_trace->elem_rev[temp + i][j][k] = 
					trace2->elem_rev[i][j][k];
			}
			merged_trace->subgrp_closed[temp + i][j] = 
				trace2->subgrp_closed[i][j];
		}
		merged_trace->grp_closed[temp + i] = trace2->grp_closed[i];
	}

wrapup:;
}

/*
   DESCRIPTION:
     Given an intobj, this function uses its endpt incidence info to get the 
     objid of the edge with which this intobj may be coincident. It DOES NOT 
     change the existing "more_info" of the intobj. If any infomation about 
     endpt incidence is missing in the intobj, it is generated inside the 
     function in the process of getting the coincident edge.

   OPTIONS:
     None at present. Maybe we can have options later to update the "more_info"
     of the intobj (i.e. the endpt incidence info).

   INPUT/OUTPUT:

O    EFmsg             Return code. Will return EMS_I_Found if a coincident edge
                       is found, else will return EMS_I_NotFound.

I    options           Currently unused.

I    mattyp            Environment matrix type.

I    mat               Environment matrix.

I    altuvtol          Parametric tolerance. Can be NULL. If NULL, will be 
                       calculated inside the function.

I    altxyztol         Model space cht tolerance. Can be NULL. If NULL, will be 
                       calculated inside the function to twice chord height.

I    intobj            Intobj being checked.

O    coincident_edgeid Objid of edge that is coincident with the intobj. If 
                       there is no such edge, then NULL_OBJID is returned.

   ALGORITHM:

   The function tries to trivially ascertain the coincident edge by checking to
   see if the "sfintedpars" in "more_info" point to the same edge. If not, it 
   uses the sfintedpar info (generating it if necessary) to get two lists of
   edges (one at each end of the intobj) on which the intobj is incident. Having
   done this, getting the possibly coincident edge is simply a matter of getting
   the edge that is common to both lists. If there is a possible coincident edge
   then we make doubly sure by projection sample points from the edge onto the 
   intobj. If all projected points are within tolerance of the sample points,
   we have found the coincident edge.

   HISTORY:

   12/07/93 : NP :  Creation.

 */


#argsused
void EFget_coincident_edge (EFmsg, options, mattyp, mat, altuvtol, altxyztol, 
                             intobj, coincident_edgeid)
IGRlong *EFmsg, options;
struct EMSintobj *intobj;
GRobjid *coincident_edgeid;
IGRdouble *altuvtol, *altxyztol, *mat;
IGRshort *mattyp;
{

  IGRlong sts, msg_loc; 
  IGRint  i,j, num_edges_start, num_edges_end;
  GRobjid *edges_at_start, *edges_at_end;
  IGRboolean *is_rightend, found_edge;
  IGRboolean right_vtx, intobj_coinc_with_edge, in_world;
  GRobjid likely_coincident_edgeid;
  struct EMSsfintedpar *intedpar_start, *intedpar_end;
  struct EMSsfintedpar *loc_intedpar_start, *loc_intedpar_end;
  GRspacenum thisos;
  IGRdouble *internal_pts, *mindist, uvtol, xyztol;
  struct IGRbsp_curve edge_geom_xyz;
  struct EMSdataselect edge_geom;
  struct GRmdenv_info modenv;
  struct EMSpypoint *projected_pts;
  struct EMSpartolbasis partolbasis;
 
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern struct EMSpypoint *EMpypoint_malloc();
  extern void EMgetincinfo(), EMpypoint_free(), EMsfintedpar_free();
  extern IGRlong EMinternalpt();

   *EFmsg = EMS_I_NotFound;
   sts    = OM_S_SUCCESS;

   /* INITIALIZATIONS */
   *coincident_edgeid    = NULL_OBJID; /** assume at start **/
   intedpar_start        = NULL;
   intedpar_end          = NULL;
   loc_intedpar_start    = NULL;
   loc_intedpar_end      = NULL;
   is_rightend           = NULL;
   edges_at_start        = NULL;
   edges_at_end          = NULL;
   found_edge            = FALSE;
   internal_pts          = NULL;
   edge_geom_xyz.poles   = NULL;
   edge_geom_xyz.knots   = NULL;
   edge_geom_xyz.weights = NULL;
   projected_pts         = NULL;
   mindist               = NULL;


   thisos         = intobj->this_obj_node->this_obj.osnum;

   /* These will refer to the UV dataselect and NOT to the LOGICAL direction
    * of the intobj. We do not take the intobj->reversed field into account.
    */
   intedpar_start = (struct EMSsfintedpar *)(intobj->more_info);
   intedpar_end   = intedpar_start? intedpar_start->next : NULL;

   loc_intedpar_start = EMsfintedpar_malloc (&msg_loc, 1);
   loc_intedpar_end   = EMsfintedpar_malloc (&msg_loc, 1);

  if (altuvtol)
    uvtol = *altuvtol;
  else
  {
     in_world = TRUE;
     sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                   mattyp, mat, &in_world, FALSE, &partolbasis.tol),
                   targetid = intobj->this_obj_node->this_obj.objid, 
                   targetos = intobj->this_obj_node->this_obj.osnum, 
                   senderid = NULL_OBJID);
     EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_SurfaceError, wrapup);
     uvtol = partolbasis.tol;
  }
  
  if (altxyztol)
    xyztol = *altxyztol;
  else
  { BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
    xyztol *= 2.0;
  }
   
  if (!intedpar_start || 
      (intedpar_start && (intedpar_start->edgeid==NULL_OBJID)))
  {

     (void) EMgetincinfo (&msg_loc, thisos, &(intobj->this_uvintobj), 
                             FALSE, NULL, mattyp, mat, 
                             intobj->this_obj_node->this_obj.objid,
                             xyztol, uvtol, loc_intedpar_start);
     EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
  }
  else
  {
     OM_BLOCK_MOVE (intedpar_start, loc_intedpar_start, 
                        sizeof(struct EMSsfintedpar));
     /* so that orig. info does not get freed when the local node is freed.*/
     loc_intedpar_start->info = NULL; 
     loc_intedpar_start->next = NULL; 
  }

  if (!intedpar_end || 
      (intedpar_end && (intedpar_end->edgeid==NULL_OBJID)))
  {

     (void) EMgetincinfo (&msg_loc, thisos, &(intobj->this_uvintobj), 
                             TRUE, NULL, mattyp, mat, 
                             intobj->this_obj_node->this_obj.objid,
                             xyztol, uvtol, loc_intedpar_end);
     EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
  }
  else
  {
     OM_BLOCK_MOVE (intedpar_end, loc_intedpar_end, 
                        sizeof(struct EMSsfintedpar));
     /* so that orig. info does not get freed when the local node is freed.*/
     loc_intedpar_end->info = NULL; 
     loc_intedpar_end->next = NULL;  
  }

  /* try to get the coincident edge trivially through the sfintedpars */
  if (loc_intedpar_start->edgeid != NULL_OBJID &&
      loc_intedpar_start->edgeid == loc_intedpar_end->edgeid)
  {
     *coincident_edgeid = loc_intedpar_start->edgeid;
     *EFmsg = EMS_I_Found;
  }/*if*/
  else 
  {
    found_edge     = FALSE;
    edges_at_start = NULL;
    is_rightend    = NULL;

    switch (loc_intedpar_start->intloc)
    {
      case EMScvint_middle:    
        /* if the intobj ends on the middle of the edge, then we have found
         * the edge at start. We cannot say if the intobj is coincident with
         * it, however, till we check the other end of intobj.
         */
        edges_at_start = (GRobjid *)om$malloc(size=sizeof(GRobjid));
        EMerr_hndlr(!edges_at_start, *EFmsg, EMS_E_NoDynamicMemory, wrapup); 

	*edges_at_start = loc_intedpar_start->edgeid;
	num_edges_start = 1;
 	found_edge      = TRUE;
	break;
      case EMScvint_rtend:
      case EMScvint_rtendcoll:
	 right_vtx = TRUE;
	 break;
      case EMScvint_lfend:
      case EMScvint_lfendcoll:
	 right_vtx = FALSE;
	 break;
      default:
         /* if intobj lies at an unknown location on the edge, then the next
          * method will fail too, since it HAS to know if intobj lies at a 
          * vertex. So we simply exit.
          */
         goto wrapup;
     }/*switch*/

    if (!found_edge)
    { 
      num_edges_start = 0;  /*IMPORTANT: EMgetvtxedges expects this */
      sts = om$send (msg = message EMSedge.EMgetvtxedges (
                         &msg_loc,EMSvtxedges_onlythissurf, right_vtx,
                         0, &num_edges_start, &edges_at_start, &is_rightend),
                     targetid = loc_intedpar_start->edgeid,
                     senderid = NULL_OBJID,
		     targetos = thisos); 

      EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup); 
    }/*if*/
 
    if (is_rightend)
      {om$dealloc (ptr = is_rightend); is_rightend=NULL;} /* reused below */


    /* NOW WORK ON THE OTHER END OF THE INTOBJ */

    edges_at_end = NULL;
    is_rightend  = NULL;
    found_edge   = FALSE;

    switch (loc_intedpar_end->intloc)
    {
      case EMScvint_middle:    
        /* if the intobj ends on the middle of the edge, then we have found
         * the edge at end. We cannot say if the intobj is coincident with
         * it, however, till check with the edge at the other end.
         */
        edges_at_end = (GRobjid *)om$malloc(size=sizeof(GRobjid));
        EMerr_hndlr(!edges_at_end, *EFmsg, EMS_E_NoDynamicMemory, wrapup); 

        *edges_at_end = loc_intedpar_end->edgeid;
        num_edges_end = 1;
        found_edge    = TRUE;
        break;
      case EMScvint_rtend:
      case EMScvint_rtendcoll:
	right_vtx = TRUE;
	break;
     case EMScvint_lfend:
     case EMScvint_lfendcoll:
	right_vtx = FALSE;
	break;
     default:
       /* if intobj lies at an unknown location on the edge, then the next
        * method will fail too, since it HAS to know if intobj lies at a
        * vertex. So we simply exit.
        */
       goto wrapup; 
    }/*switch*/

    if (!found_edge)
    {  
       num_edges_end = 0; /*IMPORTANT: EMgetvtxedges expects this */
       sts = om$send (msg = message EMSedge.EMgetvtxedges (
                       &msg_loc,EMSvtxedges_onlythissurf, right_vtx,
                       0, &num_edges_end, &edges_at_end, &is_rightend),
                    targetid = loc_intedpar_end->edgeid,
                    senderid = NULL_OBJID,
                    targetos = thisos); 
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup); 
    }/*if*/

    /* At this point check for a common edge in the two lists, which then
     * is a likely candidate for coincidence. This likely coincident 
     * edge is confirmed by projecting the intobj on it.
     */

     found_edge = FALSE;
     likely_coincident_edgeid = NULL_OBJID;
     for (i=0; i<num_edges_start && !found_edge; i++)
     {  for (j=0; j<num_edges_end && !found_edge; j++)
        {	
          if (edges_at_start[i] == edges_at_end[j])
          {  likely_coincident_edgeid = edges_at_start[i];
	     found_edge = TRUE;
          }/*if*/
        }/*for,j*/
     }/*for,i*/


     /* If we have found a likely coincident edge, then we have to make one 
      * final check, that is to project the intobj on the edge and make sure
      * that they are REALLY coincident. 
      */
     if (likely_coincident_edgeid != NULL_OBJID)
     {
       /* Find 3 internal points (XYZ) of the intobj */

       internal_pts = alloca (sizeof(IGRpoint) * NUM_INTERNAL_SAMPLES); 

       EMinternalpt (&msg_loc, mattyp, mat, &(intobj->this_xyzintobj), 
                       EMScvint_middle, NUM_INTERNAL_SAMPLES, internal_pts);
       EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup); 

       /* get XYZ geometry of edge */
       edge_geom_xyz.poles   = NULL;
       edge_geom_xyz.knots   = NULL;
       edge_geom_xyz.weights = NULL;
       modenv.matrix_type = *mattyp;
       OM_BLOCK_MOVE(mat, modenv.matrix, sizeof (IGRmatrix));

       sts = om$send (msg = message EMSedge.EMget_bcxyz_geom
                                      (&msg_loc, &modenv, NULL, NULL, 0,
                                       MAXINT, FALSE, NULL, &edge_geom_xyz),
                              targetid = likely_coincident_edgeid,
                              senderid = NULL_OBJID,
                              targetos = thisos);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

       /*put the geometry in a dataselect format*/
       edge_geom.datatype = EMSdata_curve3d;
       edge_geom.data.curve = &edge_geom_xyz;

      
       projected_pts = EMpypoint_malloc (&msg_loc, NUM_INTERNAL_SAMPLES);
       mindist=NULL;
       mindist       = (IGRdouble *) om$malloc(size= sizeof(IGRdouble) *
                                                 NUM_INTERNAL_SAMPLES);
       EMerr_hndlr(!mindist, *EFmsg, EMS_E_NoDynamicMemory, wrapup); 

       /* Project intobj's internal points onto the edge */
       EMprojectpt (&msg_loc, mattyp,mat,
                         &edge_geom, NUM_INTERNAL_SAMPLES, internal_pts,
                         xyztol, projected_pts, mindist);
       EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

       /* Check if internal points and corresponding projected points
        * are within tol. If ALL of them are, we can finally say that the
        * intobj lies on the edge.
        */
       intobj_coinc_with_edge = TRUE; /** assume **/
       for (i=0; i< NUM_INTERNAL_SAMPLES; i++)
       { if (mindist[i] > xyztol) 
         {  intobj_coinc_with_edge = FALSE;
            break;
         }/*if*/
       }/*for*/ 

       if (intobj_coinc_with_edge)
       {
          *EFmsg = EMS_I_Found;
          *coincident_edgeid = likely_coincident_edgeid;
       }
     }

 }/*else*/

wrapup:

   if (is_rightend)
     {om$dealloc (ptr = is_rightend);}
   if (edges_at_start)
     {om$dealloc (ptr = edges_at_start);}
   if (internal_pts)
     {stackfree(internal_pts);}
   if (edge_geom_xyz.poles)
     {om$dealloc (ptr = edge_geom_xyz.poles);}
   if (edge_geom_xyz.knots)
     {om$dealloc (ptr = edge_geom_xyz.knots);}
   if (edge_geom_xyz.weights)
     {om$dealloc (ptr = edge_geom_xyz.weights);}
   if (projected_pts)
     {(void) EMpypoint_free(projected_pts, MAXINT);}
   if (mindist)
     {om$dealloc (ptr = mindist);}
   if (loc_intedpar_start)
     {(void) EMsfintedpar_free(loc_intedpar_start,MAXINT);}
   if (loc_intedpar_end)
     {(void) EMsfintedpar_free(loc_intedpar_end,MAXINT);}

   EMWRAPUP (*EFmsg, sts, "EFget_coincident_edge");
}



/*
 * Function that obtains the end-point incidence information
 * for a given end-point of a given edge.
 * "uvcvdata" and "atstop" are arguments mutually exclusive with
 * "uvendpts". The former, implicitly points to a uvpt.
 *
 * NB: On the first attempt, the location of the point wrt to the loopset is
 * searched for in purely uv-space. If this attempt does not yield an
 * on-boundary result, a second try is tried with xyz geometry (using 
 * xyz tolerances). If this attempt too fails, then the given uv-point
 * is definitely not on boundary.
 */

void EMgetincinfo (msg, thisos, uvcvdata, atstop, uvendpts,
                   mattyp, mat, sfid,
                   tol, partol, intedpar)
IGRlong *msg;
GRspacenum thisos;
struct EMSdataselect *uvcvdata;
IGRboolean atstop;
IGRdouble *uvendpts;
IGRshort *mattyp;
IGRmatrix mat;
GRobjid sfid;
IGRdouble tol, partol;
struct EMSsfintedpar *intedpar;
{
  IGRshort location, tryinx;
  IGRlong stat_OM, msg_loc, send_msg;
  IGRdouble tempuv[3], uvpts[2][2], xyzpts[2][3];
  struct EMSpartolbasis partol_basis;
  struct EMSptloc_info ptloc_info;
  extern IGRlong EMinternalpt();

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  if (!uvendpts)
    {
    stat_OM = EMinternalpt (&msg_loc, mattyp, mat, uvcvdata, 
               atstop ? EMScvint_rtend : EMScvint_lfend, 1, tempuv);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
    OM_BLOCK_MOVE (tempuv, uvpts[0], 2 * sizeof (IGRdouble));
    }
  else
    OM_BLOCK_MOVE (uvendpts, uvpts[0], 2 * sizeof (IGRdouble));

  partol_basis.is_valid = TRUE;
  partol_basis.in_world = TRUE;
  partol_basis.mattyp = mattyp;
  partol_basis.mat = mat;
  partol_basis.tol = partol;
  ptloc_info.options = EMS_PTLOC_CLOSEST_EDGE | EMS_PTLOC_ACTLOOP |
                        EMS_PTLOC_LS_INFINITE;

  for (tryinx=FIRST; tryinx<=SECOND; tryinx++)
    {
    if (tryinx == SECOND)
      ptloc_info.options |= EMS_PTLOC_XYZ_ONEDGE;

    stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&send_msg,
               message EMSloopset.EMpt_location (&msg_loc, uvpts[0],
               &ptloc_info, &partol_basis)), targetid = sfid, 
               targetos = thisos, senderid = NULL_OBJID);
    EMerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (send_msg) || EMSerror(msg_loc), *msg, 
     EMS_E_LoopsetError, ret_end);

    location = ptloc_info.location;
    if (location == EMS_L_INHOLE || location == EMS_L_INAREA)
      {
      OM_BLOCK_MOVE (ptloc_info.edge[0].nst_pt.proj_pt, uvpts[1],
       2 * sizeof (IGRdouble));
      stat_OM = om$send (msg = message GRvg.EMptatpr (&msg_loc, mattyp, mat,
                 (IGRdouble *) uvpts, 4, (IGRdouble *) xyzpts),
                 targetid = sfid, targetos = thisos, senderid = NULL_OBJID);
      EMerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

      if (BSdistptpt (&msg_loc, xyzpts[0], xyzpts[1]) <= tol)
        location = EMS_L_ONEDGE;
      }

    if (location == EMS_L_ONEDGE || location == EMS_L_ONVRTX)
      break;
    }

  if (location == EMS_L_ONEDGE || location == EMS_L_ONVRTX)
    {
    intedpar->intloc = ptloc_info.edge[0].nst_pt.location;
    intedpar->edgeid = ptloc_info.edge[0].edge_id;
    intedpar->edgepar = ptloc_info.edge[0].nst_pt.param;
    OM_BLOCK_MOVE (ptloc_info.edge[0].nst_pt.proj_pt, intedpar->point,
     2 * sizeof (IGRdouble));
    *msg = EMS_I_Found;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetincinfo");
  return;
}

/*****************************************************************************/
/*
 * DESCRIPTION: 
 * This function works on a linked list of EMSsfintedpar node-pairs (i.e. there
 * should be a multiple of two nodes in the linked list) AND the list has to
 * NULL-terminated. This function is typically invoked by the loopset trimming
 * function, once it has determined the incidence info on the loopset boundary.
 * Sometimes, while trimming, an intobj that is coincident with an edge will
 * NOT have both its sfintedpars pointing to the SAME edge. 
 *
 * eg. Intobj lies on edge E. The previous and next edges in the loopset are P
 *     and N. The two ways that trimming generates endpt incidence info are
 *     (endpt of P, endpt of E) OR (startpt of E, startpt of N). Note that in 
 *     both cases, the intedpars point to different edges and not to the SAME
 *     edge E as required.
 *
 * This function will fix that.
 *
 * NOTE: 
 * ----
 * 1. It is very important to pass in a NULL-terminated linked list of
 *    boundary parameters to this function.
 * 2. While this function is typically called just after trimming, with a linked
 *    list of intedpars against the boundary of loopset, it can also be called
 *    at any time to fix the intedpars for a single intobj in the inters list.
 *    Again, it is very important that the list be NULL-terminated.
 * 3. If called with the intedpars in the "more_info" of the intobj, it is 
 *    important that the edgeids be non-NULL, else the function does nothing.
 *    It would be a good idea to call the function EMgetincinfo() to
 *    generate the edgeids in case they are NULL, before calling this function.
 *
 * HISTORY:
 * 
 *  ??????   NR  Long time ago
 *  10/07/93 NP  Moved this function here from the loopset trimming method and 
 *               added description and notes above. Also, changed its name from 
 *               "post_process_incident_info" to "EMpost_process_incident_info".
 *  10/13/93 NP  Next & prev edge were NOT being obtained from the ACTIVE loop.
 *               Also trapped bad trimming results, where an intersection 
 *               overlapping two edges is not split at their join.
 */

IGRlong EMpost_process_incident_info(EMmsg,bdry_parms, partolbasis, os)
 IGRlong *EMmsg;
 struct EMSsfintedpar **bdry_parms;
 struct EMSpartolbasis *partolbasis;
 GRspacenum  os;
 {
   IGRlong msg_loc = EMS_S_Success, stat_OM = OM_S_SUCCESS;
   struct EMSsfintedpar *epptr = NULL, *chk_epptr = NULL;
   GRobjid prev_edge, next_edge, act_loop;
   OM_S_CHANSELECT to_owner;
   IGRboolean off_edge;

   extern IGRint EMsend_loops();



   *EMmsg = EMS_S_Success;

   stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
   EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

   if(bdry_parms) epptr = *bdry_parms;

   while (epptr && epptr->next)
   {
        if(epptr->edgeid == NULL_OBJID || epptr->next->edgeid == NULL_OBJID)
        {
           epptr = epptr->next->next;
           continue;
         }

        if(
         (epptr->intloc == EMScvint_lfend && 
                                      epptr->next->intloc == EMScvint_lfend)
                                     ||
         (epptr->intloc == EMScvint_rtend && 
                                      epptr->next->intloc == EMScvint_rtend)
         )
         {

            act_loop = NULL_OBJID;
            stat_OM = EMsend_loops (
                        EMmsg, 
                        message EMSboundary.EMget_objid(&msg_loc, &act_loop),
                        epptr->edgeid, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
            EMerr_hndlr (!(1&stat_OM&*EMmsg&msg_loc), *EMmsg,EMS_E_Fail,wrapup);


            if(act_loop == NULL_OBJID)  /* or error out?*/
            {
                epptr = epptr->next->next;
                continue;
            }

            stat_OM = om$send( msg = message EMSloop.EMnext_edge
                        (&msg_loc, EMGetEd_Previous, epptr->edgeid, &prev_edge),
                         senderid = NULL_OBJID,
                         targetid = act_loop,
                         targetos = os);
            EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

            stat_OM = om$send( msg = message EMSloop.EMnext_edge
                        (&msg_loc, EMGetEd_Next, epptr->edgeid, &next_edge),
                         senderid = NULL_OBJID,
                         targetid = act_loop,
                         targetos = os);
            EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);


            if(epptr->intloc == EMScvint_rtend)
            {
               if(epptr->next->edgeid == next_edge) 
               {
                   epptr->edgeid = epptr->next->edgeid;
                   epptr->intloc = EMScvint_lfend ;
                   chk_epptr     = epptr;
               }
               else if(epptr->next->edgeid == prev_edge)
               {
                   epptr->next->edgeid = epptr->edgeid;
                   epptr->next->intloc = EMScvint_lfend ;
                   chk_epptr           = epptr->next;
               }
               else
               {
                 /* This indicates a bad trimming result. This means that an 
                  * an intersection that fully overlaps two edges has NOT been
                  * split at their join.
                  */
                 EMerr_hndlr (TRUE, *EMmsg, EMS_E_InvalidArg,wrapup);
               }
            }
            else if(epptr->intloc == EMScvint_lfend)
            {
               if(epptr->next->edgeid == prev_edge) 
               {
                   epptr->edgeid = epptr->next->edgeid;
                   epptr->intloc = EMScvint_rtend ;
                   chk_epptr     = epptr;
               }
               else if(epptr->next->edgeid == next_edge)
               {
                   epptr->next->edgeid = epptr->edgeid;
                   epptr->next->intloc = EMScvint_rtend ;
                   chk_epptr           = epptr->next;
               }
               else
               {
                 /* This indicates a bad trimming result. This means that an 
                  * an intersection that fully overlaps two edges has NOT been
                  * split at their join.
                  */
                 EMerr_hndlr (TRUE, *EMmsg, EMS_E_InvalidArg,wrapup);
               }
            }
  
            /* now update the span index and param for the sfintedpar node that
             * just had its edge id updated.
             */
          
            off_edge             = FALSE;
  
            stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg_loc,
                                     chk_epptr->point, 1, &(chk_epptr->edgepar),
                                     &off_edge, NULL, partolbasis),
                          senderid = NULL_OBJID,
                          targetid = chk_epptr->edgeid,
                          targetos = os);
            EMerr_hndlr (!(1&stat_OM&msg_loc) || off_edge, *EMmsg, EMS_E_Fail,
                           wrapup);
  
        }
        epptr = epptr->next->next;
      }
 wrapup:
   EMWRAPUP(*EMmsg, stat_OM, "EMpost_process_incident_info");
   return(stat_OM);
 }
/*****************************************************************************/

/*
  DESCRIPTION

    This function accepts an EMSintobj structure and split info in the
    form of an EMSpypoint structure. This function will change the data
    in the input "intobj" to correspond with the first resultant split object.
    It would have created a new EMSintobj and inserted it, in the middle of
    "intobj" and it's next node. If this "intobj" is connected to the "other"
    list, then the corresponding other list is also correctly altered.

    The sequence of the preserved "intobj" followed by the newly created
    one is a sequence without regard to the "reverse" fields. So the 
    "next" intobj in this sequence is the geomtric next. The "fwd" "bwd"
    pointers though, are updated wrt to the logical sequence as per their
    definition. The sequence of intobjs returned in "split_intobjs" is
    the geometric sequence and not the logical sequence.
*/

IGRboolean EMmsplit_sf_intobj_uv (msg, options, mdenv_info, intobj, 
                                  uv_split_info, xyz_split_info, split_other)
IGRlong *msg;
IGRushort options;
struct GRmdenv_info *mdenv_info;
struct EMSintobj *intobj;
struct EMSpypoint *uv_split_info, *xyz_split_info;
IGRboolean split_other;
{
  IGRint curr_span, i;
  IGRlong msg_loc, stat_OM;
  IGRboolean status, is_end;
  IGRdouble curr_par;
  struct EMSpypoint *prev_split_infos[2], *split_infos[2];
  struct EMSpypoint tmp_split_infos[2];

  IGRboolean EMsplit_sf_intobj_uv2();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  status = TRUE;
  split_infos[UV] = uv_split_info;
  split_infos[XYZ] = xyz_split_info;
  prev_split_infos[UV] = prev_split_infos[XYZ] = NULL;
  while (split_infos[UV] || split_infos[XYZ])
    {
    for (i=UV; i<=XYZ; i++)
      {
      if (split_infos[i])
        {
        if (prev_split_infos[i])
          {
          /*
           * TBD: IF THE split_info AND THE prev_split_info POINT TO
           * THE SAME VERTEX BUT THROUGH DIFFERENT PARAMTERIZATION SCHEMES
           * (EG: 4,1 AND 5,0), THE FOLLOWING CODE GIVES WRONG RESULTS.
           */

          curr_span = split_infos[i]->span_inx - prev_split_infos[i]->span_inx;
          if (curr_span == 0)
            curr_par = (split_infos[i]->param - prev_split_infos[i]->param) / 
                         (1.0 - prev_split_infos[i]->param);
          else
            curr_par = split_infos[i]->param;
          }
        else
          {
          curr_span = split_infos[i]->span_inx;
          curr_par = split_infos[i]->param;
          }
        tmp_split_infos[i] = *split_infos[i];
        tmp_split_infos[i].span_inx = curr_span;
        tmp_split_infos[i].param = curr_par;

        /*
         * TBD: IF THE tmp_split NOW POINTS TO A "NEW" START THEN
         * THE PROPS FIELD MUST REFLECT THIS
         */
        }
      }

    is_end = FALSE;
    for (i=UV; i<=XYZ; i++)
      if (split_infos[i])
	if(split_infos[i]->props & EMS_PYPT_ATSTART ||
           split_infos[i]->props & EMS_PYPT_ATSTOP) is_end = TRUE;

    if(!is_end)
    {
      status = EMsplit_sf_intobj_uv2 (&msg_loc, options, mdenv_info, intobj, 
               uv_split_info ? &tmp_split_infos[UV] : NULL,
               xyz_split_info ? &tmp_split_infos[XYZ] : NULL,
               NULL, split_other);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    
      intobj = intobj->next;
    }

    for (i=UV; i<=XYZ; i++)
      {
      if (split_infos[i])
        {
        prev_split_infos[i] = split_infos[i];
        split_infos[i] = split_infos[i]->next;
        }
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMmsplit_sfintobj_uv");
  return (status);
}


IGRboolean EMsplit_sf_intobj_uv (msg, options, mdenv_info, intobj, 
                                 uv_split_info, xyz_split_info, split_intobjs)
IGRlong *msg;
IGRushort options;
struct GRmdenv_info *mdenv_info;
struct EMSintobj *intobj;
struct EMSpypoint *uv_split_info, *xyz_split_info;
struct EMSintobj *split_intobjs[2][2];
{
  IGRboolean EMsplit_sf_intobj_uv2();

  return(EMsplit_sf_intobj_uv2(msg, options, mdenv_info, intobj, uv_split_info,
                               xyz_split_info, split_intobjs, TRUE));
}


IGRboolean EMsplit_sf_intobj_uv2 (msg, options, mdenv_info, intobj, 
              uv_split_info, xyz_split_info, split_intobjs, split_other)
IGRlong *msg;
IGRushort options;
struct GRmdenv_info *mdenv_info;
struct EMSintobj *intobj;
struct EMSpypoint *uv_split_info, *xyz_split_info;
struct EMSintobj *split_intobjs[2][2];
IGRboolean split_other;
{
  IGRboolean same_xyzdat;
  IGRint i, j;
  IGRlong msg_loc, stat_OM;
  IGRdouble chktol, dum_double;
  IGRpoint xyz_split_point;
  struct GRid *other_srfid;
  struct IGRbsp_surface *other_srf;
  struct EMSdataselect uvint1, uvint2, xyzint1, xyzint2;
  struct EMSintobj *p_intobj, *this_sibling, *other_sibling, *other_intobj;
  struct EMSpypoint loc_uv_split_info, loc_xyz_split_info;
  struct EMSpypoint other_uv_split_info, other_xyz_split_info;
  enum EMSdatatype datatype;
  IGRboolean EMis_same_dataselect();
  IGRlong EMfind_uv_xyz_point();
  


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize the output split-intobjs to be the original 
   * ones.
   */

  other_intobj = intobj->other_intobj_node;
  if (split_intobjs)
    for (i=THIS; i<=OTHER; i++)
      {
      p_intobj = i == THIS ? intobj : other_intobj;
      for (j=START; j<=STOP; j++)
        split_intobjs[i][j] = p_intobj;
      }

  EMerr_hndlr (!uv_split_info && !xyz_split_info, *msg, 
   EMS_E_InvalidArg, ret_end);
  EMerr_hndlr ((uv_split_info && !(uv_split_info->props & EMS_PYPT_ATMIDDLE))
   || (xyz_split_info && !(xyz_split_info->props & EMS_PYPT_ATMIDDLE)), *msg,
   EMS_I_Useless, ret_end);

  if (other_intobj)
    same_xyzdat = EMis_same_dataselect (&intobj->this_xyzintobj,
                   &other_intobj->this_xyzintobj);
  else
    same_xyzdat = NULL;

  /*
   * Obtain the missing split point information, deriving it 
   * from the info passed in.
   */

  if (!uv_split_info)
    {
    stat_OM = EMfind_uv_xyz_point (&msg_loc, mdenv_info, 
               &intobj->this_obj_node->this_obj, NULL, 
               &intobj->this_uvintobj, &intobj->this_xyzintobj,
               FALSE, NULL, &loc_uv_split_info, xyz_split_info);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    loc_uv_split_info = *uv_split_info;

  if (!xyz_split_info)
    {
    stat_OM = EMfind_uv_xyz_point (&msg_loc, mdenv_info, 
               &intobj->this_obj_node->this_obj, NULL, 
               &intobj->this_uvintobj, &intobj->this_xyzintobj,
               TRUE, NULL, uv_split_info, &loc_xyz_split_info);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    loc_xyz_split_info = *xyz_split_info;

  /*
   * Using the spaninx/param info in uv-space split this-uv-intobj.
   * Using the xyz-splitinfo split the this-xyz-intobj. In so doing, also
   * compute the exact xyz-split-point for future use.
   */

  stat_OM = EMsplit_data (&msg_loc, mdenv_info, &intobj->this_uvintobj,
             loc_uv_split_info.span_inx, loc_uv_split_info.param, FALSE,
             NULL, &uvint1, &uvint2);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = EMsplit_data (&msg_loc, mdenv_info, &intobj->this_xyzintobj,
              loc_xyz_split_info.span_inx,  loc_xyz_split_info.param, TRUE,
              xyz_split_point, &xyzint1, &xyzint2);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  create_sibling (&msg_loc, options, intobj, &xyzint1, &xyzint2,
                  &uvint1, &uvint2, &this_sibling);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (split_intobjs)
    {
    split_intobjs[THIS][START] = intobj;
    split_intobjs[THIS][STOP] = this_sibling;
    }

  if(other_intobj && !split_other)
  {
    intobj->other_intobj_node = NULL;
    other_intobj->other_intobj_node = NULL;
  }

  if (!other_intobj || !split_other)
    goto ret_end;


  /*
   * Obtain the span_inx/param pair for the split point on the "other"
   * intobj. If the datatypes are matched, then use the same info as on
   * "this" intobj, else obtain the info by mapping. 
   */
  
  datatype = intobj->this_uvintobj.datatype;
  if ((datatype == EMSdata_poly2d || datatype == EMSdata_curve3d) &&
      (datatype == other_intobj->this_uvintobj.datatype) && 
       !(other_intobj->props & EMSintobj_unmatched_dat))
    {
    stat_OM = EMsplit_data (&msg_loc, mdenv_info, &other_intobj->this_uvintobj,
               loc_uv_split_info.span_inx, loc_uv_split_info.param, FALSE,
               NULL, &uvint1, &uvint2);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (!same_xyzdat)
      {
      stat_OM = EMfind_uv_xyz_point (&msg_loc, mdenv_info, 
                 &other_intobj->this_obj_node->this_obj, NULL, 
                 &other_intobj->this_uvintobj, &other_intobj->this_xyzintobj,
                 TRUE, NULL, &loc_uv_split_info, &other_xyz_split_info);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = EMsplit_data (&msg_loc, mdenv_info, 
                 &other_intobj->this_xyzintobj,
                 other_xyz_split_info.span_inx, other_xyz_split_info.param,
                 TRUE, NULL, &xyzint1, &xyzint2);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
  else
    {
    other_srfid = &other_intobj->this_obj_node->this_obj;
    EMgetabsg (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
     other_srfid->osnum, other_srfid->objid, &other_srf);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (!same_xyzdat)
      {
      BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, chktol);
      EMprojectpt (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
       &other_intobj->this_xyzintobj, 1, xyz_split_point, chktol, 
       &other_xyz_split_info, &dum_double);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      other_xyz_split_info = loc_xyz_split_info;

    stat_OM = EMfind_uv_xyz_point (&msg_loc, mdenv_info, 
               &other_intobj->this_obj_node->this_obj, NULL, 
               &other_intobj->this_uvintobj, &other_intobj->this_xyzintobj,
               FALSE, NULL, &other_uv_split_info, &other_xyz_split_info);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = EMsplit_data (&msg_loc, mdenv_info, &other_intobj->this_uvintobj,
               other_uv_split_info.span_inx, other_uv_split_info.param, FALSE,
               NULL, &uvint1, &uvint2);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (!same_xyzdat)
      {
      stat_OM = EMsplit_data (&msg_loc, mdenv_info, 
                 &other_intobj->this_xyzintobj,
                 other_xyz_split_info.span_inx, other_xyz_split_info.param,
                 TRUE, NULL, &xyzint1, &xyzint2);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  create_sibling (&msg_loc, options, other_intobj, &xyzint1, &xyzint2,
                  &uvint1, &uvint2, &other_sibling);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  this_sibling->other_intobj_node = other_sibling;
  other_sibling->other_intobj_node = this_sibling;

  if (split_intobjs)
    {
    split_intobjs[OTHER][START] = other_intobj;
    split_intobjs[OTHER][STOP] = other_sibling;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMsplit_sfintobj_uv2");
  return (!EMSerror (stat_OM));
}

 

IGRboolean EMall_intobjs_marked (inters)
struct EMSinters *inters;
{
  IGRboolean status;
  struct EMSintobj *intobj_node;

  status = TRUE;
  intobj_node = inters->cvs;
  while (intobj_node)
    {
    if (! (intobj_node->props & EMSintobj_marked ))
      {
      status = FALSE;
      break;
      }
    intobj_node = intobj_node->next;
    }

  return (status);
}


void EMkeep_mindist_intobj (msg, mattyp, mat, intobjs, pt)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSintobj *intobjs;
IGRpoint pt;
{
  IGRlong msg_loc;
  IGRdouble dist, mindist;
  IGRpoint internalpt;
  struct EMSintobj *intobj, *n_intobj, *mindist_intobj;
  extern IGRlong EMinternalpt();
 
  *msg = EMS_S_Success;

  intobj = intobjs;
  mindist_intobj = intobj;
  mindist = MAXDOUBLE;
  while (intobj)
    {
    EMinternalpt (&msg_loc, mattyp, mat, &intobj->this_xyzintobj,
     EMScvint_middle, 1, internalpt);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if ((dist = BSdistptpts (&msg_loc, pt, internalpt)) < mindist)
      {
      mindist = dist;
      mindist_intobj = intobj;
      }
    intobj = intobj->next;
    }

  intobj = intobjs;
  while (intobj)
    {
    n_intobj = intobj->next;
    if (intobj != mindist_intobj)
      EMdelintobj (&msg_loc, intobj);
    intobj = n_intobj;
    }

ret_end:
  return;
} 

/*
  Local function used to create the second, sibling EMSintobj structure
  
 HISTORY:

  Inasu  ?????     Creation.
  NP     7/27/93   Updated the "fwd" and "bwd" connections of the sibling after 
                   the intobj and its sibling are connected to each other.
  NP     08/18/93  Sibling "connect" properties were not being updated.
*/

static void create_sibling (msg, options, intobj,
                            my_xyzintobj, sibling_xyzintobj,
                            my_uvintobj, sibling_uvintobj,
                            sibling)
IGRlong *msg;
IGRushort options;
struct EMSintobj *intobj;
struct EMSdataselect *my_xyzintobj, *sibling_xyzintobj;
struct EMSdataselect *my_uvintobj, *sibling_uvintobj;
struct EMSintobj **sibling;
{
  IGRchar *more_info;
  IGRuchar new_curve_type;
  IGRulong save_props, props, xfer_props;
  IGRlong msg_loc, sts;
  struct EMSsfintedpar *sfintedpar, *sfintedpar1, *sfintedpar2;
  struct EMSintobj *save_fwd=NULL, *save_bwd=NULL;
  struct EMSdataselect *data, *other_data;


  IGRboolean EMis_same_dataselect();
  struct EMSsfintedpar *EMsfintedpar_malloc();
  struct EMSintobj *EMmakeintobj();
  extern IGRlong EFget_clipped_edge_type();
  extern void EMdataselect_data_free();

  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;

   sts = EFget_clipped_edge_type(&msg_loc,intobj->curve_type,&new_curve_type);
   EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Deallocate the data fields of uvdata and xyz data fields 
   * and update the above intobj fields.
   */

  EMdataselect_data_free (&msg_loc, &intobj->this_uvintobj, 1);

  data = &intobj->this_xyzintobj;
  if (intobj->other_intobj_node)
    {
    other_data = &intobj->other_intobj_node->this_xyzintobj;
    if (data->datatype != EMSdata_null &&
        EMis_same_dataselect (data, other_data))
      intobj->this_xyzintobj.datatype = EMSdata_null;
    else
      EMdataselect_data_free (&msg_loc, &intobj->this_xyzintobj, 1);
    }
  else
    EMdataselect_data_free (&msg_loc, &intobj->this_xyzintobj, 1);
     
  OM_BLOCK_MOVE (my_uvintobj, &intobj->this_uvintobj,
   sizeof(struct EMSdataselect));
  OM_BLOCK_MOVE (my_xyzintobj, &intobj->this_xyzintobj,
   sizeof(struct EMSdataselect));

  /*
   * If this node contains more info, there will be a linked list of two
   * sfintedpar's. These have be shared with the node and it's sibling.
   * Since each of them requires two of these info, create dummies.
   */

  sfintedpar = (struct EMSsfintedpar *) intobj->more_info;
  if (sfintedpar)
    {
    sfintedpar1 = EMsfintedpar_malloc (&msg_loc, 1);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    sfintedpar2 = EMsfintedpar_malloc (&msg_loc, 1);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

    sfintedpar2->next = sfintedpar->next;
    sfintedpar->next  = sfintedpar1;

    more_info = (IGRchar *) sfintedpar2;
    }
  else
    more_info = NULL;

  /*
   * Create the sibling intobj. All the properties of the original
   * intobj are transferred, except the ones that deal with end-points
   * and with connectivity. Properties dealing with the latter are
   * computed and tacked on.
   */

  if (options & EMSintobj_split_ignoreconnect)
    props = NULL;
  else if (options & EMSintobj_split_noconnectuv)
    props = intobj->reversed ? EMSintobj_fwd_noconnectuv
                             : EMSintobj_bwd_noconnectuv;
  else
    props = intobj->reversed ? EMSintobj_fwd_connectuv
                             : EMSintobj_bwd_connectuv;
  xfer_props = intobj->props;
  xfer_props &= ~((intobj->reversed?EMSintobj_exact_atstop:
                                    EMSintobj_exact_atstart) |
                  EMSintobj_fwd_noconnectuv |
                  EMSintobj_bwd_noconnectuv |
                  EMSintobj_fwd_connectuv |
                  EMSintobj_bwd_connectuv);
  intobj->next = EMmakeintobj (&msg_loc, sibling_xyzintobj, sibling_uvintobj,
                  intobj->reversed, props | xfer_props, intobj->this_obj_node,
                  NULL, more_info, NULL, NULL, intobj->next, NULL, sibling);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /* REMOVE the "exact" properties for the intobj (first half of split) too 
   * (NP 1/8/94)
   */
   if (intobj->reversed)
     intobj->props &= ~EMSintobj_exact_atstart;
   else
     intobj->props &= ~EMSintobj_exact_atstop;

  /* keep track of the continuity BEYOND the sibling (NP: 7/26/93)*/
  if (intobj->reversed)
  {
     save_bwd = intobj->bwd;
     save_props = intobj->props & 
                   (EMSintobj_bwd_noconnectuv |EMSintobj_bwd_connectuv); 
  }
  else
  {
     save_fwd = intobj->fwd;
     save_props = intobj->props & 
                   (EMSintobj_fwd_noconnectuv |EMSintobj_fwd_connectuv); 
  }

  /*
   * Update the properties of the intobjs reflecting the connectivity
   * specified via the options
   */

  if (intobj->reversed)
    {
    if (options & EMSintobj_split_ignoreconnect)
      {
      intobj->props &= ~(EMSintobj_bwd_connectuv |
                         EMSintobj_bwd_noconnectuv);
      (*sibling)->props &= ~(EMSintobj_fwd_connectuv |
                             EMSintobj_fwd_noconnectuv);

      intobj->bwd = NULL;
      (*sibling)->fwd = NULL;
      }
    else if (options & EMSintobj_split_noconnectuv)
      {
      intobj->props |=  EMSintobj_bwd_noconnectuv;
      intobj->props &= ~EMSintobj_bwd_connectuv;
      (*sibling)->props |=  EMSintobj_fwd_noconnectuv;
      (*sibling)->props &= ~EMSintobj_fwd_connectuv;

      intobj->bwd = *sibling;
      (*sibling)->fwd = intobj;
      }
    else
      {
      intobj->props |=  EMSintobj_bwd_connectuv;
      intobj->props &= ~EMSintobj_bwd_noconnectuv;
      (*sibling)->props |=  EMSintobj_fwd_connectuv;
      (*sibling)->props &= ~EMSintobj_fwd_noconnectuv;

      intobj->bwd = *sibling;
      (*sibling)->fwd = intobj;
      }

    (*sibling)->bwd = save_bwd;
    (*sibling)->props |= save_props;
    if (save_bwd && save_bwd->fwd && (save_bwd->fwd == intobj))
       save_bwd->fwd = (*sibling);
    }

  else
    {
    if (options & EMSintobj_split_ignoreconnect)
      {
      intobj->props &= ~(EMSintobj_fwd_connectuv |
                         EMSintobj_fwd_noconnectuv);
      (*sibling)->props &= ~(EMSintobj_bwd_connectuv |
                             EMSintobj_bwd_noconnectuv);

      intobj->fwd = NULL;
      (*sibling)->bwd = NULL;
      }
    else if (options & EMSintobj_split_noconnectuv)
      {
      intobj->props |=  EMSintobj_fwd_noconnectuv;
      intobj->props &= ~EMSintobj_fwd_connectuv;
      (*sibling)->props |=  EMSintobj_bwd_noconnectuv;
      (*sibling)->props &= ~EMSintobj_bwd_connectuv; 

      intobj->fwd = *sibling;
      (*sibling)->bwd = intobj;
      }
    else
      {
      intobj->props |=  EMSintobj_fwd_connectuv;
      intobj->props &= ~EMSintobj_fwd_noconnectuv;
      (*sibling)->props |=  EMSintobj_bwd_connectuv;
      (*sibling)->props &= ~EMSintobj_bwd_noconnectuv;

      intobj->fwd = *sibling;
      (*sibling)->bwd = intobj;
      }

    (*sibling)->fwd = save_fwd;
    (*sibling)->props |= save_props;
    if (save_fwd && save_fwd->bwd && (save_fwd->bwd == intobj))
      save_fwd->bwd = (*sibling);
    }

  /* 
   * Set the curve types after the split 
   */

  intobj->curve_type = new_curve_type;
  (*sibling)->curve_type = new_curve_type;

  /*
   * Since an intobj node of the EMSinters has been split, the number
   * intersections must be incremeted by 1
   */

  if (intobj->this_obj_node)
    intobj->this_obj_node->num_cvs++;

ret_end:
  EMWRAPUP (*msg, sts, "create_sibling");
  return;
}


IGRlong EMfind_uv_xyz_point (msg, mdenv_info, sfid, srf, 
                             uvdata, xyzdata,
                             uv_to_xyz, chktol, uvpt, xyzpt)
IGRlong *msg;
struct GRmdenv_info *mdenv_info;
struct GRid *sfid;
struct IGRbsp_surface *srf;
struct EMSdataselect *uvdata, *xyzdata;
IGRboolean uv_to_xyz;
IGRdouble *chktol;
struct EMSpypoint *uvpt, *xyzpt;
{
  IGRlong msg_loc, stat_OM;
  IGRdouble loc_chktol, dum_double=0;
  IGRpoint xferpt, dum_point;
  struct IGRbsp_surface *loc_srf=NULL;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!srf)
  {
    EMgetabsg (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
     sfid->osnum, sfid->objid, &loc_srf);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else
    loc_srf = srf;

  if (!chktol)
  {
    if (uv_to_xyz)
      BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, loc_chktol);
    else
      BSsfkttol2 (loc_srf->u_order, loc_srf->v_order,
       loc_srf->u_knots, loc_srf->v_knots, 
       loc_srf->u_num_poles, loc_srf->v_num_poles, loc_srf->poles, 
       loc_srf->weights, &loc_chktol, &msg_loc);
  }
  else
    loc_chktol = *chktol;

  if (uv_to_xyz)
  {
    BSsfeval (loc_srf, uvpt->point[U], uvpt->point[V], 0, &xferpt, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
    
    EMprojectpt (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
     xyzdata, 1, xferpt, loc_chktol, xyzpt, &dum_double);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    xferpt[2] = 0.0;
    BSmdistptsf (&msg_loc, loc_srf, xyzpt->point, &xferpt[U], &xferpt[V],
     dum_point, &dum_double);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

    EMprojectpt (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
     uvdata, 1, xferpt, loc_chktol, uvpt, &dum_double);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if ((loc_srf->u_phy_closed &&
         (xferpt[0] < loc_chktol || fabs(1.0 - xferpt[0]) < loc_chktol)) ||
        (loc_srf->v_phy_closed && 
         (xferpt[1] < loc_chktol || fabs(1.0 - xferpt[1]) < loc_chktol)))
    {
      /*
       * The projected xyz point falls on the seam of the surface. Collect
       * all the possible combinations of uv points and project one by one
       * on the given uv dataselect and return the one which will have min.
       * distance from the uv dataselect.
       */

      int num_points=0, right_pt=0, i=0;
      double  dist[4], mindist=0;
      double  testuvpt[12];
      struct EMSpypoint testpypt[4];

      /*
       * Collect all the possible uv points.
       */
      memset (testpypt, 0, 4 * sizeof (struct EMSpypoint));
      memset (testuvpt, 0, 12 * sizeof (double));

      num_points = 1;
      dist[0] = dum_double; 
      testuvpt[0] = xferpt[0]; 
      testuvpt[1] = xferpt[1];
      testuvpt[2] = xferpt[2];

      memcpy (&testpypt[0], uvpt, sizeof (struct EMSpypoint)); 

      if (loc_srf->u_phy_closed && 
          (xferpt[0] < loc_chktol || fabs(1.0 - xferpt[0]) < loc_chktol))
      {
        testuvpt[num_points*3] = xferpt[0] < loc_chktol ? 1.0 : 0.0;
        testuvpt[num_points*3+1] = xferpt[1];
        num_points ++;
      }

      if (loc_srf->v_phy_closed && 
          (xferpt[1] < loc_chktol || fabs(1.0 - xferpt[1]) < loc_chktol))
      {
        testuvpt[num_points*3] = xferpt[0];
        testuvpt[num_points*3+1] = xferpt[1] < loc_chktol ? 1.0 : 0.0;
        num_points ++;
      }

      if (loc_srf->u_phy_closed && loc_srf->v_phy_closed && 
          (xferpt[0] < loc_chktol || fabs(1.0 - xferpt[0]) < loc_chktol) &&
          (xferpt[1] < loc_chktol || fabs(1.0 - xferpt[1]) < loc_chktol))
      {
        testuvpt[num_points*3] = xferpt[0] < loc_chktol ? 1.0 : 0.0;
        testuvpt[num_points*3+1] = xferpt[1] < loc_chktol ? 1.0 : 0.0;
        num_points ++;
      }

      /*
       * Project all the uv points on to uv dataselect.
       */
      for (i=1; i<num_points; i++)
      {
        EMprojectpt (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
         uvdata, 1, &testuvpt[i*3], loc_chktol, &testpypt[i], &dist[i]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

      /*
       * Find the minimum distance point and return the same.
       */
      mindist = dist[0]; right_pt=0;

      for (i=1; i<num_points; i++)
      {
        if (dist[i] < mindist)
        {
          mindist = dist[i];
          right_pt = i;
        }
      }

      memcpy (uvpt, &testpypt[right_pt], sizeof (struct EMSpypoint));
    }

  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMfind_uv_xyz");
  return (stat_OM);
}


IGRboolean EMintobj_closed(msg, intobj, in_xyz, tol)
IGRlong *msg;
struct EMSintobj *intobj;
IGRboolean in_xyz;
IGRdouble  tol;

{
IGRboolean		stat_func;
IGRlong			msg_loc, stat;
struct EMSdataselect	*p_datasel;
IGRdouble 		uvpts[2][2], xyzpts[2][3];


  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  stat_func = FALSE;

  if(in_xyz)
  {
    p_datasel = &intobj->this_xyzintobj;
    stat = EMgetendpts_xyz(&msg_loc, (IGRshort *) NULL, (IGRdouble *) NULL, 
			 p_datasel, intobj->reversed, 1, xyzpts[0], xyzpts[1]);
    EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_Fail, ret_end);
    if(BSdistptpt (&msg_loc, xyzpts[0], xyzpts[1]) <= tol)
      stat_func = TRUE;
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
  }
  else /* uv */
  {
    IGRdouble dist;

    p_datasel = &intobj->this_uvintobj;
    stat = EMgetendpts_uv(&msg_loc, p_datasel, intobj->reversed,
			   1, uvpts[0], uvpts[1]);
    EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_Fail, ret_end);
    dist = EM2ddistptpt (uvpts[0], uvpts[1]);
    if(dist <= tol)
      stat_func = TRUE;
  }
ret_end:
  EMWRAPUP (*msg, stat, "EMintobj_closed");
  return(stat_func);
}

 /*
  DESCRIPTION

    This function accepts a surface and a curve and adds the curve information
    relative to the surface into the inters-list passed in. The given curve
    can get mapped into more than one intobj depending on the surface
    boundaries and/or the input curve being a composite or not.

    NOTE : Presently, it is assumed that only composite surfaces
           are being input. Keeping this in mind, the surface
           data-type has to be EMSdata_object.

           As for the curves, they can be either single curves or
           composite curves. But, the curve type has to be EMSdata_object.

  ALGORITHM

    If the input curve is a composite, get the component curves. For each
    simple curve, get the mapped uv-space geometry. Trim the geometry
    against the surface's loopset. Add to the intlist.

  ARGUMENTS

        IGRlong *msg                       Error return message.

        IGRushort opts                     The mapping options.

        struct GRmdenv_info *sfenv         The environment info for the
                                           composite surface.

        struct GRmdenv_info *cvenv         The environment info for the
                                           curve to be mapped.

        struct GRmdenv_info *cvdata        The dataselect info for the
                                           curve to be mapped.

        GRobjid *lrgst_cmpid               Can be NULL by value.  If non-
                                           null, the first intobj returned
                                           will correspond to this.

        struct EMSinters **inters          The inters list generated for the
                                           for the composite surface.
*/

struct EMSintobj *EMcnvtcvintobj (msg, opts, sfenv, sfdata, cvenv, cvdata,
                                  lrgst_cmpid, inters, overlap)
IGRlong *msg;
IGRushort opts;
struct GRmdenv_info *sfenv, *cvenv;
struct EMSdataselect *sfdata, *cvdata;
GRobjid *lrgst_cmpid;
struct EMSinters **inters;
IGRboolean *overlap;
{
  IGRlong msg_loc, stat_OM, sf_size, nret, bufsiz, comp_size;
  IGRint num_components, num_curves, 
         i, j, k, p, num_edges, num_compsfs;
  IGRpoint my_start, my_stop, tmp_point;
  IGRshort location[2], mid_location;
  OMuint obj_count, ed_count;
  GRobjid *cv_ids = NULL, mrkd_intobjid = NULL_OBJID;
  enum EMSdatatype sfdattyp, cvdattyp;
  struct EMSdataselect edge_dataselect, xyz_cv_dataselect,
                       cv_dataselect;
  struct EMSpartolbasis tol_basis;
  GRclassid sfclass, cvclass;
  OM_S_CHANSELECT composite_chan, to_comps_chan, compcv_to_cv_chan,
                  to_loopset;
  OM_S_OBJECT_LINKAGE loop_set, *ed_list = NULL;
  IGRdouble xyztol, temp_pt[3], connect_tol, mpar, dis_tol,
            internal_pts[6];
  IGRboolean in_world, found, already_checked;
  IGRchar *moreinfo = NULL;
  struct GRid clip_ls, *cv_grids = NULL, *components = NULL;
  struct EMSgetlp_output out_loops, out_cvs;
  struct IGRbsp_surface *sf_geom=NULL;
  struct IGRbsp_curve *comp_geom = NULL, *tmp_cvgeom = NULL;
  struct GRlc_info *cv_obj_info = NULL;
  struct EMSintobj *first_intobj = NULL, *new_intobj = NULL;
  struct EMSinters *loc_inters;
  struct GRmd_env cv_env, sf_env, md_env;
  struct GRvg_construct construct_list;
  struct IGRdisplay display_attr;
  struct EMScvsfs tmp_parms;

  extern struct EMSintobj *EMmakeintlist();
  extern IGRlong EMgetsfsofcv();  
  extern IGRlong EMinternalpt();
  extern IGRint EMget_mapped_data();
  extern IGRint EMgetvggeom();
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern void EMgetincinfo();
  extern IGRlong EMpost_process_incident_info();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /* extract current module info. This has to be changed to get the
     module_env of curve and surface as they are.
  */

  stat_OM = BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, connect_tol);
  dis_tol = connect_tol;
  bufsiz = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg_loc,
                    sizbuf = &bufsiz,
                    buffer = &md_env,
                    nret = &nret);

  bufsiz = sizeof(struct IGRdisplay);
  gr$get_active_display(msg = &msg_loc,
                        sizbuf = &bufsiz,
                        buffer = &display_attr,
                        nret = &nret);

  sfdattyp = sfdata->datatype;
  sf_env.md_id.objid = md_env.md_id.objid;
  sf_env.md_id.osnum = md_env.md_id.osnum;
  OM_BLOCK_MOVE(sfenv, &sf_env.md_env, sizeof(struct GRmdenv_info));
  cvdattyp = cvdata->datatype;
  cv_env.md_id.objid = md_env.md_id.objid;
  cv_env.md_id.osnum = md_env.md_id.osnum;
  OM_BLOCK_MOVE(cvenv, &cv_env.md_env, sizeof(struct GRmdenv_info));

  stat_OM = EMmake_chanselect(EMSbd_owner_to_comps, &to_comps_chan);
  EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,wrapup);

  stat_OM = EMmake_chanselect(GRcmpowner_to_components, &compcv_to_cv_chan);
  EMerr_hndlr (!(1&stat_OM),*msg,EMS_E_OMerror,wrapup);

  stat_OM = EMmake_chanselect(GRcmpowner_to_components, &composite_chan);
  EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,wrapup);

 if((sfdattyp != EMSdata_object) || (cvdattyp != EMSdata_object))
     {
       *msg = EMS_E_InvalidArg;
       goto wrapup;
     }

 om$get_classid (objid = sfdata->data.object->objid,
                 osnum = sfdata->data.object->osnum,
                 p_classid = &sfclass);

 if (om$is_ancestry_valid (subclassid = sfclass,
     superclassid = OPP_EMScomposite_class_id) != OM_S_SUCCESS)
     {
       *msg = EMS_E_InvalidArg;
       goto wrapup;
     }

/* twice XYZ chord height tol is used for calc. end-info of edges on surface */

     BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
     xyztol *= 2;

/* Get the number of components of the composite surface */

      stat_OM = om$send(msg = message GRowner.GRget_number_components(
                            &msg_loc, &num_compsfs),
                   targetid = sfdata->data.object->objid,
                   targetos = sfdata->data.object->osnum,
                   senderid = NULL_OBJID);
      EMerr_hndlr (!(1&stat_OM) || !num_compsfs, *msg, EMS_E_OMerror,wrapup);

     stat_OM = om$get_classid(objid = cvdata->data.object->objid,
                              osnum = cvdata->data.object->osnum,
                              p_classid = &cvclass);
     if (!(1 & stat_OM)) goto wrapup;

     if (om$is_ancestry_valid(subclassid = cvclass,
         superclassid = OPP_GRcompcurve_class_id) == OM_S_SUCCESS)

         {
  /*
    GET COMPONENTS FOR THE COMPOSITE CURVE
  */

  stat_OM = om$send(msg = message GRowner.GRget_number_components(
                            &msg_loc, &num_components),
                   targetid = cvdata->data.object->objid,
                   targetos = cvdata->data.object->osnum,
                   senderid = NULL_OBJID);
      EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_CurveError, wrapup);

     components = (struct GRid *) om$malloc(size =
                                        (OMuint)num_components *
                                        sizeof(struct GRid));
     EMerr_hndlr(! components, *msg, EMS_E_NoDynamicMemory, wrapup);

     stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc,
                          &cv_env, components, num_components,
                          (IGRint *)&obj_count, 0, num_components-1),
                          targetid = cvdata->data.object->objid,
                          targetos = cvdata->data.object->osnum,
                          senderid = NULL_OBJID);
     if (!(1 & stat_OM) || (obj_count != num_components)) goto wrapup;

    }   /* If composite-curve */
    else {
     num_components = 1;
     *lrgst_cmpid = NULL_OBJID;
     components = (struct GRid *) om$malloc(size = (OMuint)num_components *
                                                   sizeof(struct GRid));
     EMerr_hndlr(! components, *msg, EMS_E_NoDynamicMemory, wrapup);
     components[0].objid = cvdata->data.object->objid;
     components[0].osnum = cvdata->data.object->osnum;
    }  /* If single curve */

  /*
     for each component curve or the single curve passed in get the surface
     on which it is residing
  */

  for(i =0; i < num_components; i++)
     {
      already_checked = FALSE;
      stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                           &cvenv->matrix_type,
                           cvenv->matrix,
                           &comp_size),
                     senderid = NULL_OBJID,
                     targetid = components[i].objid,
                     targetos = components[i].osnum);
      EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

      comp_geom = (struct IGRbsp_curve *) om$malloc(size = (OMuint)
                            comp_size);
      EMerr_hndlr(! comp_geom, *msg, EMS_E_NoDynamicMemory, wrapup);

      stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                           &cvenv->matrix_type,
                           cvenv->matrix,
                           (IGRchar *)comp_geom),
                        senderid = NULL_OBJID,
                        targetid = components[i].objid,
                        targetos = components[i].osnum);
      EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

      BScvmidpt(comp_geom, &mpar, temp_pt, &msg_loc);

      tmp_parms.surface.objid = NULL_OBJID;
      stat_OM = EMgetsfsofcv(&msg_loc,
                             &sfenv->matrix_type,
                             sfenv->matrix,
                             sfdata->data.object,  
                             temp_pt, FALSE, &tmp_parms);
      EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);
      mid_location = tmp_parms.location;

      if(mid_location == EMS_L_ONEDGE || mid_location == EMS_L_ONVRTX) {
         MAbcendpts(&msg_loc, comp_geom, my_start, my_stop);

         for(p = 0; p < 2; p++) {
         if(!p) 
         OM_BLOCK_MOVE(my_start, tmp_point, sizeof(IGRpoint));
         else 
         OM_BLOCK_MOVE(my_stop, tmp_point, sizeof(IGRpoint));

         stat_OM = EMgetsfsofcv(&msg_loc,
                                &sfenv->matrix_type,
                                sfenv->matrix,
                                sfdata->data.object,
                                tmp_point, TRUE, &tmp_parms);
         EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

         if(!p)
         location[0] = tmp_parms.location;
         else
         location[1] = tmp_parms.location;
         }        

         if((location[0] == EMS_L_ONEDGE || location[0] == EMS_L_ONVRTX) &&
            (location[1] == EMS_L_ONEDGE || location[1] == EMS_L_ONVRTX))
         {
         cv_dataselect.datatype = EMSdata_object;
         cv_dataselect.data.object = &components[i];

         stat_OM = EMinternalpt(&msg_loc, &sfenv->matrix_type, sfenv->matrix,
                                &cv_dataselect, EMScvint_middle, 
                                2, internal_pts);
         EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

         for(p = 0; p < 2; p++) {
         if(!p)
         OM_BLOCK_MOVE(&internal_pts[0], tmp_point, sizeof(IGRpoint));
         else
         OM_BLOCK_MOVE(&internal_pts[3], tmp_point, sizeof(IGRpoint));

         stat_OM = EMgetsfsofcv(&msg_loc,
                                &sfenv->matrix_type,
                                sfenv->matrix,
                                sfdata->data.object,
                                tmp_point, TRUE, &tmp_parms);
         EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

         if(!p)
         location[0] = tmp_parms.location;
         else
         location[1] = tmp_parms.location;
         }

         if((location[0] != EMS_L_ONEDGE && location[0] != EMS_L_ONVRTX) ||
            (location[1] != EMS_L_ONEDGE && location[1] != EMS_L_ONVRTX))
         {
         mid_location = EMS_L_INAREA;
         already_checked = TRUE;
         }
         else {
            opts &= ~(EMMapBnd_RmvDegenCvs| EMMapBnd_ClipBdryArea);
            opts |= EMMapBnd_NoClip;
            mid_location = EMS_L_ONEDGE;
            already_checked = TRUE;
            }  
         }
         else if((location[0] == EMS_L_ONEDGE || location[0] == EMS_L_ONVRTX)
              && (location[1] == EMS_L_INAREA || location[1] == EMS_L_INHOLE)) 
         {
         mid_location = EMS_L_INAREA;
         already_checked = TRUE;
         }
         else if((location[0] == EMS_L_INAREA || location[0] == EMS_L_INHOLE)
              && (location[1] == EMS_L_ONEDGE || location[1] == EMS_L_ONVRTX))
         {
         mid_location = EMS_L_INAREA;
         already_checked = TRUE;
         }
      }

      construct_list.msg = &msg_loc;
      construct_list.env_info = &sf_env;
      construct_list.newflag = FALSE;
      construct_list.geometry = NULL;
      construct_list.class_attr = NULL;
      construct_list.level = NULL;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.display = &display_attr;
      construct_list.name = NULL;

      /* Get the geometry and the loop_set of the map-surface */

       stat_OM = om$send(msg = message GRvg.GRgetsize(
                     &msg_loc,
                     &(sfenv->matrix_type),
                     sfenv->matrix,
                     &sf_size),
                     senderid = NULL_OBJID,
                     targetid = tmp_parms.surface.objid,
                     targetos = tmp_parms.surface.osnum);
             EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, msg_loc, wrapup);

       /* allocate memory for surface geometry */

       sf_geom = (struct IGRbsp_surface *) om$malloc (size = (OMuint)sf_size);
       EMerr_hndlr(!sf_geom, *msg, EMS_E_NoDynamicMemory, wrapup);

       /* Get the surface geometry */

      stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                                     &(sfenv->matrix_type),
                                                     sfenv->matrix,
                                                     (IGRchar *)sf_geom),
                       senderid = NULL_OBJID,
                       targetid = tmp_parms.surface.objid,
                       targetos = tmp_parms.surface.osnum);
      EMerr_hndlr(!(msg_loc&stat_OM&1), *msg, msg_loc, wrapup);

      stat_OM = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
      EMerr_exit(stat_OM, wrapup);

      stat_OM = om$get_channel_objects(objid = tmp_parms.surface.objid,
                                       osnum = tmp_parms.surface.osnum,
                                       p_chanselect = &to_loopset,
                                       list = &loop_set,
                                       size = 1,
                                       count = &obj_count);
      EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);

      in_world = FALSE;
      tol_basis.is_valid = FALSE;
      tol_basis.in_world = FALSE;
      tol_basis.mattyp   = &(sfenv->matrix_type);
      tol_basis.mat      = sfenv->matrix;
      stat_OM = om$send(msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                              &(sfenv->matrix_type), sfenv->matrix, &in_world,
                              FALSE, &(tol_basis.tol)),
                        targetid = tmp_parms.surface.objid,
                        targetos = tmp_parms.surface.osnum,
                        senderid = NULL_OBJID);
      EMerr_hndlr(!(msg_loc&stat_OM&1), *msg, msg_loc, wrapup);
      tol_basis.is_valid = TRUE;

   /* create appropriate input structure for the curve */

      cv_obj_info= (struct GRlc_info *) alloca(sizeof(struct GRlc_info));

      cv_obj_info->located_obj.objid  = components[i].objid;
      cv_obj_info->located_obj.osnum  = cvdata->data.object->osnum;
      cv_obj_info->module_info.md_id.objid = md_env.md_id.objid;
      cv_obj_info->module_info.md_id.osnum = md_env.md_id.osnum;
      OM_BLOCK_MOVE(cvenv, &cv_obj_info->module_info.md_env,
                    sizeof(struct GRmdenv_info));
   /*
     MAPPING TO THE UV-SPACE RETURNS THE LOOP OBJECTS WHICH ARE SUB-GROUP
     EQUIVALENTS
   */

     clip_ls.objid = loop_set.S_objid;
     clip_ls.osnum = loop_set.osnum;
     out_loops.objs = NULL;
     out_cvs.objs   = NULL;
     stat_OM = EMget_mapped_data(
               (IGRlong)1,   /* no. of curves to be mapped */
               NULL,
               cv_obj_info,   /* curve on this surface*/
               &construct_list,
               sf_geom,
               NULL,
               &sf_env,
               NULL,               /* not intersted in outputting bad curves */
               NULL,/* not interested in dangling data (should never happen) */
               &out_loops,/* output: loops on surface (kinda like subgroups) */
               &out_cvs,                        /* output: XYZ mapped curves */
               clip_ls,                            /* loopset to clip against*/
               opts,
               NULL,                                /* no planar info needed */
               &msg_loc);
      EMerr_hndlr(!(msg_loc & stat_OM & 1), *msg, msg_loc, wrapup);

      if(!out_loops.objs) {
      if(num_components > 1 && i < num_components &&
         IF_EQ_OBJID(*lrgst_cmpid, components[i].objid))
      *lrgst_cmpid = components[i+1].objid;
      else if(i == num_components - 1)
      *lrgst_cmpid = NULL_OBJID;
      continue;
    }

   /* At this time we have loops created on this surface. Each loop may have
    * any number of edges. We convert all edges into dataselects.
    */

    for(j = 0; j < (out_loops.num_objs); j++)
    { /* get all edges of the loop */

      ed_list = (OM_S_OBJECT_LINKAGE *) alloca(num_components *
                                       sizeof(OM_S_OBJECT_LINKAGE));

      stat_OM = om$get_channel_count( objid = out_loops.objs[j],
                                      osnum = sfdata->data.object->osnum,
                                      p_chanselect = &to_comps_chan,
                                      count = &ed_count);
      EMerr_hndlr (!(1&stat_OM) || !ed_count,*msg,EMS_E_OMerror,wrapup);

      stat_OM = om$get_channel_objects (objid = (out_loops.objs[j]),
                                    osnum = sfdata->data.object->osnum,
                                    p_chanselect = &to_comps_chan,
                                    list = ed_list,
                                    size = ed_count,
                                    count = (OMuint *)&num_edges);
      EMerr_hndlr (!(1&stat_OM) || !num_edges || (num_edges != ed_count),
                                            *msg, EMS_E_OMerror, wrapup);

      if(!IF_NULL_OBJID(*lrgst_cmpid)) {
      if(components[i].objid == *lrgst_cmpid)
      mrkd_intobjid = ed_list[0].S_objid;
      }

      /* Get XYZ curve objects corresponding to the edges. Struct "out_cvs" is
       * very similar to the "out_loops" structs. i.e. every loop in "out_loops"
       * corresponds to a composite curve in "out_cvs". However, for loops with
       * only ONE edge, corresponding element is a curve and not a composite
       * curve. Example (L=loop, E=edge, CC=comp cv, C=curve) : Consider the
       * output of the following three loops:
       * L1 (E1 E2 E3) L2 (E4 E5) & L3 (E6).
       *      Corrresponding "out_cvs" entries are,
       * CC1 (C1 C2 C3) CC2 (C4 C5) & C6
       */
     if(num_edges > 1)
     {
     cv_ids   = (GRobjid *)alloca (num_components * sizeof(GRobjid));
     cv_grids = (struct GRid *)alloca (num_components * sizeof(struct GRid));

     stat_OM = om$send (msg = message GRowner.GRget_number_components (&msg_loc,
                          &num_curves),
                          targetid = out_cvs.objs[j],
                          targetos = sfdata->data.object->osnum,
                          senderid = NULL_OBJID);
     EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);
     EMerr_hndlr (num_curves != num_edges, *msg,EMS_E_Fail,wrapup);

         /* get the ids of the model space curves (pass num_edges as the
          * max. number of curves on this composite, since num_curves
          * has to be separately passed).
          */
     stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc,
                        &cv_env, cv_grids, num_edges,
                        &num_curves, 0, num_edges-1),
                        targetid = out_cvs.objs[j],
                        targetos = sfdata->data.object->osnum,
                        senderid = NULL_OBJID);
     EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);
     EMerr_hndlr (num_curves != num_edges, *msg, EMS_E_Fail, wrapup);

         for(k = 0; k < num_curves; k++)
            cv_ids[k] = cv_grids[k].objid;
     }
     else /* ==> loop with one edge ==> no comp. cv */
        {
        cv_ids   = (GRobjid *)alloca(num_components * sizeof(GRobjid));
        cv_ids[0] = out_cvs.objs[j];
        }
     for(k = 0; k < num_edges; k++)    /* for (each edge) */
     {
   /* put UV-edge and XYZ curve in dataselect format */

         edge_dataselect.datatype       = EMSdata_object;
         edge_dataselect.data.object    = NULL;
         edge_dataselect.data.object    =
                      (struct GRid *) om$malloc (size = sizeof (struct GRid));
         EMerr_hndlr (!(edge_dataselect.data.object), *msg,
                             EMS_E_NoDynamicMemory, wrapup);
         edge_dataselect.data.object->objid     = ed_list[k].S_objid;
         edge_dataselect.data.object->osnum     = sfdata->data.object->osnum;

         xyz_cv_dataselect.datatype     = EMSdata_object;
         xyz_cv_dataselect.data.object  = NULL;
         xyz_cv_dataselect.data.object  =
                      (struct GRid *) om$malloc (size = sizeof (struct GRid));
         EMerr_hndlr (!(xyz_cv_dataselect.data.object), *msg,
                        EMS_E_NoDynamicMemory, wrapup);

         xyz_cv_dataselect.data.object->objid = cv_ids[k];
         xyz_cv_dataselect.data.object->osnum = sfdata->data.object->osnum;

     /* The more-info field in the intobj structure is being initialised */

         moreinfo = (IGRchar *)EMsfintedpar_malloc (&msg_loc, 2);
                     EMerr_hndlr (!(1&msg_loc) || !(moreinfo),
                                       *msg, msg_loc, wrapup);

     /* get sfintedpar info about start point of edge */

         EMgetincinfo (&msg_loc, sfdata->data.object->osnum,
                       &edge_dataselect,
                       FALSE, NULL,
                       &(sfenv->matrix_type),
                       sfenv->matrix, tmp_parms.surface.objid, xyztol,
                       tol_basis.tol,
                       (struct EMSsfintedpar *)moreinfo);
         EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrapup);

     /* get sfintedpar info about stop point of edge */

         EMgetincinfo(&msg_loc, sfdata->data.object->osnum,
                      &edge_dataselect,
                      TRUE, NULL,
                      &(sfenv->matrix_type),
                      sfenv->matrix, tmp_parms.surface.objid, xyztol,
                      tol_basis.tol,
                      ((struct EMSsfintedpar *)moreinfo)->next);
         EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrapup);

         new_intobj = EMmakeintlist(&msg_loc,
                                    inters,
                                    NULL,
                                    &tmp_parms.surface,
                                    NULL, (IGRchar *)sf_geom,
                                    NULL, NULL,
                                    NULL,
                                    &xyz_cv_dataselect,
                                    &edge_dataselect, NULL, FALSE, FALSE,
                                    moreinfo, NULL, NULL, NULL, NULL, NULL,
                                    TRUE, FALSE);
         EMerr_hndlr (EMSerror(msg_loc), *msg, msg_loc, wrapup);

         if(mid_location == EMS_L_ONEDGE && !already_checked) {
         EMgetvggeom(&msg_loc, &(sfenv->matrix_type),
                     sfenv->matrix,
                     xyz_cv_dataselect.data.object,
                     &tmp_cvgeom, NULL);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

         MAbcendpts(&msg_loc, tmp_cvgeom, my_start, my_stop);

         for(p = 0; p < 2; p++) {
         if(!p)
         OM_BLOCK_MOVE(my_start, tmp_point, sizeof(IGRpoint));
         else
         OM_BLOCK_MOVE(my_stop, tmp_point, sizeof(IGRpoint));

         stat_OM = EMgetsfsofcv(&msg_loc,
                                &sfenv->matrix_type,
                                sfenv->matrix,
                                sfdata->data.object,
                                tmp_point, TRUE, &tmp_parms);
         EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

         if(!p)
         location[0] = tmp_parms.location;
         else
         location[1] = tmp_parms.location;
         }
        
         if((location[0] != EMS_L_ONEDGE && location[0] != EMS_L_ONVRTX) ||
            (location[1] != EMS_L_ONEDGE && location[1] != EMS_L_ONVRTX))
         mid_location = EMS_L_INAREA;  
       }

       if(mid_location == EMS_L_ONEDGE) {
          if(!(*overlap)) *overlap = TRUE;
          new_intobj->props |= EMSintobj_overlap;
       }

       EMpost_process_incident_info(&msg_loc,
                                    (struct EMSsfintedpar **)&moreinfo,
                                    &tol_basis,
                                    sfdata->data.object->osnum);
       EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrapup);
    } /* for (each edge) */

      /*
       * now delete the loop object after doing a wild-disconnect on its
       * channels. This is so as to not delete the edges that are now part
       * of the inters lists. Similarly we need to delete the composite
       * curve (its component curves are used in the inters list and hence not
       * deletable).
       */

       stat_OM = om$send(msg = message Root.wild_disconnect(to_comps_chan),
                                targetid = out_loops.objs[j],
                                targetos = sfdata->data.object->osnum,
                                senderid = NULL_OBJID);
       EMerr_hndlr (!(1&stat_OM) ,*msg, EMS_E_OMerror, wrapup);

       /*
        * now delete the loop (it is not connected to any loopset and neither
        * does it have any inner loops)
        */

       stat_OM = om$send(msg = message Root.delete(1),
                         targetid = out_loops.objs[j],
                         targetos = sfdata->data.object->osnum,
                         senderid = NULL_OBJID);
       EMerr_hndlr (!(1&stat_OM) ,*msg, EMS_E_OMerror, wrapup);

       /*
        * Do the same thing with the composite curve (composite curve is
        * produced ONLY if the number of curves is > 1).
        */

       if(num_edges > 1)
       {
       stat_OM = om$send(msg = message Root.wild_disconnect(compcv_to_cv_chan),
                         targetid = out_cvs.objs[j],
                         targetos = sfdata->data.object->osnum,
                         senderid = NULL_OBJID);
       EMerr_hndlr (!(1&stat_OM) , *msg, EMS_E_OMerror, wrapup);

       stat_OM = om$send(msg = message Root.delete(1),
                         targetid = out_cvs.objs[j],
                         targetos = sfdata->data.object->osnum,
                         senderid = NULL_OBJID);
       EMerr_hndlr (!(1&stat_OM) ,*msg, EMS_E_OMerror, wrapup);
       }

  }  /* for (each loop) */

        /* 
           Keep this commented out till somebody references it (else we get a 
           compiler warning)..............
        loc_wrapup:
         ************/

            if(sf_geom)
               sf_geom = NULL;

            if(comp_geom) {
               om$dealloc(ptr = comp_geom);
               comp_geom = NULL;
            }

 }   /* for each component curve */

 loc_inters = *inters;

 if(!IF_NULL_OBJID(*lrgst_cmpid)) {
   found = FALSE;

   while(loc_inters) {
        first_intobj = loc_inters->cvs;
        while(first_intobj) {
             if(first_intobj->this_uvintobj.data.object->objid
                == mrkd_intobjid) {
               found = TRUE;
               break;
             }
             first_intobj = first_intobj->next;
        }
        if(found) break;
        loc_inters = loc_inters->next;
   }
 }
 else {
 if(loc_inters)
 first_intobj = loc_inters->cvs;
 }

wrapup:

if(components){
 om$dealloc(ptr = components);
 components = NULL;
  }

EMWRAPUP (*msg, stat_OM, "EMcnvtcvintobj");
return(first_intobj);
}


/*
  ABSTRACT

    This function takes an intobj that may have the uv-data in the form
    of geometry buffers and converts the uv-data into an EMSedge object.
    This is useful when calling functions that operate solely on edge-objects.
    Example: Boolean function.

  ALGORITHM

    If the uv-dataselect is not already an object - get the curve-type from
    the xyz-dataselect, initialize the env_info field in a local const_list,
    create the new uv-dataselect with EMSedge by calling EMmkintdata,
    free the old dataselect, replace new one in place.
*/

void EMconvert_to_edge (msg, intobj, os)
IGRlong *msg;
struct EMSintobj *intobj;
GRspacenum os;
{
  IGRuchar cvtype;
  IGRushort cv_props;
  IGRlong msg_loc, status;
  struct GRmd_env md_env;
  struct GRvg_construct const_list;
  struct EMSdataselect *uvdata, new_uvdata;
  extern IGRuchar EMcurve_typing();
  extern void EMdataselect_data_free(); 
  *msg = EMS_S_Success;

  uvdata = &intobj->this_uvintobj;
  if (uvdata->datatype != EMSdata_object)
    {
    cvtype = EMcurve_typing (&intobj->this_uvintobj, &intobj->this_xyzintobj);
    cv_props = (intobj->props & EMSintobj_isocurve ?
                EMSintdata_isoedge : NULL) |
               (intobj->props & EMSintobj_xyzdegenerate ?
                EMSintdata_xyzdegen : NULL);
    EMgetmdenv (&md_env, NULL, NULL, os);
    EMinitvgcnstr (&msg_loc, &md_env, NULL, NULL, &const_list);

    EMmkintdata (&msg_loc, uvdata, cvtype, cv_props,
     FALSE, NULL, &const_list, TRUE, NULL, NULL, &new_uvdata);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    EMdataselect_data_free (&msg_loc, uvdata, 1);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    *uvdata = new_uvdata;
    }

ret_end:
  status = TRUE;
  EMWRAPUP (*msg, status, "EMconvert_to_edge");
  return;
}


/*
 * DESCRIPTION:
      Given a collection of sub-groups belonging to a single group, this
      function returns the minimum distance from a specified xyz point, to
      the group [here, group, sub-groups, etc. refer to information
      generated through EMsfinttrace() ].
      Note that, since the operation is performed on sub-groups belonging
      to a single group, the intersections within these subgroups MUST
      necessarily define a position continuous intersection in model space.
      Thus, the operation determines the minimum distance from the specified
      xyz point, to this logically continuous model space intersection.

 * OPTIONS:
      None.

 * INPUT:
      mat_type, matrix	Construction environment information.
      ref_pt            The model space point from which the minimum
                        distance to the intersection is determined.
      subgrps           An array of sub-groups belonging to a single group.
      num_subgrps
      num_elems_per_subgrp Number of uv intersections within each sub-group
                           (by definition, these are all continuous in uv
                           space, which implies continuity in model space).

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      min_dist		Minimum distance from 'ref_pt' to the logical
                        model space intersection defined by the collection
                        of 'subgrps.
      total_num_elems	Total number of intersections in 'subgrps'.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 02/10/93 : Orginal.
 */

IGRlong	EMget_mindist_to_grp( IGRlong *EMmsg, IGRshort mat_type,
              IGRmatrix matrix, IGRpoint ref_pt,
              struct EMSintobj *subgrps[], IGRint num_subgrps,
              IGRint num_elems_per_subgrp[],
              IGRdouble *min_dist, IGRint *total_num_elems )

{
   IGRint		i, j;
   IGRlong		msg, OM_stat;
   IGRdouble		current_dist, cht_tol;

   struct EMSpypoint	projected_pt;
   struct EMSintobj	*tmp_intobj;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   BSEXTRACTPAR( &msg, BSTOLCHRDHT, cht_tol );

   projected_pt.next = NULL;
   *total_num_elems = 0;
   *min_dist = MAXINT;
   for( i = 0; i < num_subgrps; i++ )
      /* Iterate through the collection of sub-groups */
   {
      tmp_intobj = subgrps[i];
      for( j = 0; j < num_elems_per_subgrp[i]; j++ )
          /* Iterate through each intersection within the ith sub-group */
      {
         OM_stat = EMprojectpt( &msg, &mat_type, matrix,
                     &tmp_intobj->this_xyzintobj, 1, ref_pt, cht_tol,
                     &projected_pt, &current_dist );
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
         tmp_intobj = tmp_intobj->next;
         (*total_num_elems)++;
         if( current_dist < *min_dist )
            *min_dist = current_dist;
      }
   }

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "EMget_mindist_to_grp" );
   return( OM_stat );
}

/*
 * DESCRIPTION:
     Given a list of intersections, this functions determines the group of
     intersections that are closest to a given reference point.  The grouping
     of intersections are performed based on their model space position
     continuity.

 * OPTIONS:
     None.

 * INPUT:
     options		None.
     md_env		The construction environment.
     ref_pt		Model space point utilized for filtering out
                        intersections.
     inters_list   	The list of intersections.  Only those intersections
                        on the first surface in the list are operated on.
     uv_tol		The parametric space tolerance of the surface on which
                        the intersections lie on.

 * OUTPUT:
     EMmsg	 	 EMS errors.
     return value	 OM errors.
     num_intobjs_to_keep Number of intersection in 'keep_intobjs'
     keep_intobjs	 The collection of intersections (as an array of
                         pointers to EMSintobjs) that is closest to
                         'ref_pt'.
                         Memory is allocated within this function.  Caller
                         should free this memory with a single call to
                         om$dealloc() on that single pointer.
     are_identical	 If the 'keep_intobjs' is equal to the collection of
                         intersections within 'inters_list', then this will
                         be TRUE, else FALSE.

 * ALGORITHM:
     . Determine whether there is a single intersection 'inters_list'.  If so,
       there is no filtering required.
     . Trace 'inters_list'.  This results in the grouping of intersections
       such that each group consists of a collection of intersection
       (sub-groups) that are position continuous in model space.
       If there is one such group, then the intersections to be retained are
       exactly those in the collection. Else, retain the group that is closest
       to 'ref_pt'.

     Notes and assumptions:
       . This function may re-order intersections (intobjs) within
         'inters_list' (due to the trace).
       . Only those intersections that are on the first surface in
         'inters_list' are worked on.

 * HISTORY:
     Janaka : 02/09/93 : Original.
 */

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

IGRlong EMweed_out_inters( IGRlong *EMmsg, IGRushort options,
          struct GRmd_env *md_env, IGRpoint ref_pt,
          struct EMSinters *inters_list,
          IGRint *num_intobjs_to_keep, struct EMSintobj ***keep_intobjs,
          IGRboolean *are_identical )

{
   IGRboolean	dum_bool;
   IGRshort	mat_type;
   IGRint	save_grp, i, j, k, num_elems_in_grp;
   IGRlong 	msg, OM_stat;
   IGRdouble	min_dist, current_dist, basis_tol, uv_cht_tol, uv_tol,
                cht_tol, *matrix;

   struct EMSinters		*next_inters;
   struct EMSintobj		*tmp_intobj;
   struct EMSsftracedata	trace_data;

   extern void		EMsfinttrace();

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   mat_type = md_env->md_env.matrix_type;
   matrix = md_env->md_env.matrix;

   *num_intobjs_to_keep = 0;
   *keep_intobjs = NULL;
   *are_identical = FALSE;
   next_inters = inters_list->next;
   inters_list->next = NULL;  /* Work on the intersections on the
                               * first surface (reset in wrapup).
                               */
   trace_data.num_grps = 0;   /* So that memory inside 'trace_data'
                               * can be safely deallocated using
                               * $MODEL/src_funk/misc/EMsfinttrace.I/
                               * EMsfinttrace_free().
                               */

   BSEXTRACTPAR( &msg, BSTOLLENVEC, basis_tol );
   BSEXTRACTPAR( &msg, BSTOLCHRDHT, cht_tol );

   /* Obtain the parametric tolerance of the single surface on which the
    * intersections lie.
    */
       OM_stat = om$send( msg = message EMSsubbs.EMpartolbasis( &msg,
                                 &mat_type, matrix,
                                 &dum_bool, TRUE, /* these two are not used
                                                   * within the method!!.
                                                   */
                                 &uv_tol ),
                          senderid = NULL_OBJID,
                          targetid = inters_list->this_obj.objid,
                          targetos = inters_list->this_obj.osnum );
       EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                    wrapup );

   uv_cht_tol = uv_tol * cht_tol / basis_tol;

   /* STEP 1:
    *
    * . Trivially, check 'inters_list' for a singleton.  If so return.
    * . Trace 'inters_list' to group the intersections into logically
    *   position continuous intersections in model space. (the result will be
    *   one or more groups, each defining a model space position continuous
    *   intersection.  Each of these groups would consist of one or more
    *   sub-groups.  Each sub-group would consist of uv space position
    *   continuous intersection elements.  The elements within each sub-group
    *   (where all subgroups belong to one group) are position discontinuous
    *   in uv space).  Pick the group that is closest to 'ref_pt', and return
    *   its intersections..
    */
       if( inters_list->num_cvs == 1 )
       {
          *num_intobjs_to_keep = 1;
          *are_identical = TRUE;
          *keep_intobjs = ( struct EMSintobj ** ) om$malloc( size = 
                                               sizeof( struct EMSintobj * ) );
          EMerr_hndlr( !( *keep_intobjs ), *EMmsg, EMS_E_NoDynamicMemory,
                       wrapup );
          **keep_intobjs = inters_list->cvs;
          goto wrapup;
       }

       EMsfinttrace( &msg, &mat_type, matrix, inters_list, &uv_cht_tol,
            &cht_tol,
            &trace_data.num_grps, &trace_data.num_subgrps_grp,
            &trace_data.num_elems_subgrp, &trace_data.elems,
            &trace_data.subgrp_rev, &trace_data.elem_rev,
            &trace_data.grp_closed, &trace_data.subgrp_closed );
       EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );

       /* Now, find the group that is within minimum distance to
        * 'ref_pt' (a single group case is included here).
        */
          if( trace_data.num_grps == 1 ) *are_identical = TRUE;
          min_dist = MAXINT;
          for( i = 0, save_grp = 0; i < trace_data.num_grps; i++ )
          {
             OM_stat = EMget_mindist_to_grp( &msg, mat_type, matrix,
                          ref_pt, trace_data.elems[i],
                          trace_data.num_subgrps_grp[i],
                          trace_data.num_elems_subgrp[i], &current_dist,
                          &num_elems_in_grp );
             EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail,
                          wrapup );
             if( current_dist < min_dist )
             {
                min_dist = current_dist;
                save_grp = i;
                *num_intobjs_to_keep = num_elems_in_grp;
             }
          }

       *keep_intobjs = ( struct EMSintobj ** ) om$malloc( size =
                       *num_intobjs_to_keep * sizeof( struct EMSintobj * ) );
       EMerr_hndlr( !( *keep_intobjs), *EMmsg, EMS_E_NoDynamicMemory,
                    wrapup );

       for( i = 0, k =0; i < trace_data.num_subgrps_grp[ save_grp ]; i++ )
       {
          tmp_intobj = trace_data.elems[ save_grp ][ i ];
          for( j = 0; j < trace_data.num_elems_subgrp[ save_grp ][ i ]; j++ )
          {
             (*keep_intobjs)[k++] = tmp_intobj;
             tmp_intobj = tmp_intobj->next;
          }
       }

wrapup:

   EMsfinttrace_free( &msg, trace_data.num_grps,
         trace_data.num_subgrps_grp, trace_data.num_elems_subgrp,
         trace_data.elems, trace_data.subgrp_rev, trace_data.elem_rev,
         trace_data.grp_closed, trace_data.subgrp_closed );

   inters_list->next = next_inters;
   EMWRAPUP( *EMmsg, OM_stat, "EMweed_out_inters" );
   return( OM_stat );
}


/*
 * DESCRIPTION:
     Given an inters list, this function converts ANY dataselect (UV or XYZ)
     that is NOT an object (i.e. is poly2D/3D or curve3D) into an object. The
     objects are created in the environment of the input construct list.

 * OPTIONS:
     None.

 * INPUT:

     options         Currently unused. Can be used later if necessary to 
                     selectively convert either UV or XYZ or both (default)
                     into objects etc.
     check_present   Convert only those intobjs that HAVE these bits set 
                     (AND do NOT have the "check_absent" [if non-NULL] bits set)
                     Can be NULL.

     check_absent    Convert only those intobjs that do NOT have these bits 
                     set (AND HAVE the "check_present" [if non-NULL] bits set)
                     Can be NULL.

     inters          Input inters list.

     inters_env      Module environment of the inters list.

     construct_list  Defines environment for newly created objects. 

 * OUTPUT
     
     EFmsg               Return code.

     inters              The modified inters list.

 * ALGORITHM:

     Check each UV and XYZ dataselect of every intobj to see if it is not 
     already an object. If not an object, convert it to one. Free the old 
     dataselects. Make sure that for intobjs which have "same XYZ" with the 
     "other_intobj", only ONE object is retained (by deleting the non-object 
     XYZ dataselect of the "other intobj".

     Intobjs can be selectively chosen for conversion to objects, by passing in
     bits that the intobj MUST have (check_present) and those it must NOT have
     (check_absent). If both are NULL, ALL intobjs are checked.

 * HISTORY:

     NP : 06/29/93 : Creation
     NP : 07/14/93 : Added the "check_present" and "check_absent" arguments.
 */

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

IGRlong EFconvert_intobjs_to_objects(EFmsg, 
                                     options, 
                                     check_present, 
                                     check_absent, 
                                     inters, 
                                     inters_env, 
                                     construct_list)
IGRlong *EFmsg, options;
struct GRvg_construct *construct_list;
struct EMSinters *inters;
struct GRmd_env  *inters_env;
IGRlong check_present,check_absent;
{

  IGRlong                 sts, msg_loc;
  struct EMSdataselect    uvdata, xyzdata;
  IGRboolean              check_this_intobj, same_xyzdat, world;
  IGRdouble               partolbasis, cht, *mat;
  IGRshort                mat_type;
  struct EMSinters        *inters_loc;
  struct EMSintobj        *intobj;
  extern IGRboolean EMis_same_dataselect();
  extern void EMdataselect_data_free();
  extern IGRint EMmkintdata();


  *EFmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

  mat             = inters_env->md_env.matrix;
  mat_type        = inters_env->md_env.matrix_type;

  BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);

  /* Now change all dataselects to objects. The boolean function expects them
   * to be objects (particularly EMsfintloops).
   */
    inters_loc = inters;

    while (inters_loc)
    {
      /* get the parametric tolerance for this surface */

      world=FALSE;
      sts = om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                             &mat_type, mat, &world, TRUE, &partolbasis),
                           senderid = NULL_OBJID,
                           targetid = inters_loc->this_obj.objid,
                           targetos = inters_loc->this_obj.osnum);

      EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, msg_loc, wrapup);

      intobj = inters_loc->cvs;
      while (intobj)
      {
        if( (check_present? (intobj->props & check_present) : TRUE) &&
            (check_absent ?!(intobj->props & check_absent)  : TRUE))
            check_this_intobj = TRUE;
        else
            check_this_intobj = FALSE; 

        if ( !check_this_intobj )
          goto next_intobj;

        xyzdata.datatype = EMSdata_null;
        uvdata.datatype  = EMSdata_null;

        if (intobj->other_intobj_node)
        {  same_xyzdat = EMis_same_dataselect (&intobj->this_xyzintobj,
                   &intobj->other_intobj_node->this_xyzintobj);
        }
         else
           same_xyzdat = NULL;


        if (intobj->this_xyzintobj.datatype != EMSdata_object)
        {
           sts = EMmkintdata (&msg_loc, &(intobj->this_xyzintobj),
                           EMfreeform_curve, NULL, TRUE, NULL,
                           construct_list, TRUE, &cht, NULL, &xyzdata);
           EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, msg_loc, wrapup);

           /*free the original data */
           EMdataselect_data_free (&msg_loc, &(intobj->this_xyzintobj), NULL);

           OM_BLOCK_MOVE (&xyzdata, &(intobj->this_xyzintobj),
                                  sizeof(struct EMSdataselect));
        }

        if (same_xyzdat &&
             intobj->other_intobj_node->this_xyzintobj.datatype!=EMSdata_object)
        {
           /*free the original data */
           EMdataselect_data_free (&msg_loc,
                         &(intobj->other_intobj_node->this_xyzintobj), NULL);
           OM_BLOCK_MOVE(&xyzdata, &(intobj->other_intobj_node->this_xyzintobj),
                                     sizeof(struct EMSdataselect));
        }

        if (intobj->this_uvintobj.datatype != EMSdata_object)
        {
           sts = EMmkintdata (&msg_loc, &(intobj->this_uvintobj),
                           EMfreeform_curve, NULL, FALSE, NULL,
                           construct_list, TRUE, &partolbasis, NULL, &uvdata);
           EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, msg_loc, wrapup);

           /*free the original data */
           EMdataselect_data_free (&msg_loc, &(intobj->this_uvintobj), NULL);

           OM_BLOCK_MOVE(&uvdata, &(intobj->this_uvintobj),
                                     sizeof(struct EMSdataselect));
         }

         next_intobj:
           intobj = intobj->next;
      }

      inters_loc = inters_loc->next;
    }


  wrapup:

  EMWRAPUP( *EFmsg, sts, "In EFconvert_intobjs_to_objects");
  return (sts);

}

/*
  ABSTRACT

   This function simply returns the end-info (EMSsfintedpar) associated
   with the given EMSintobj in the logical sequence (taking into account
   the "reversed" flag in the EMSintobj). Returns TRUE on success and 
   FALSE on failure to find this information.
*/

IGRboolean EMgive_endinfo (intobj, start_end, stop_end)
struct EMSintobj *intobj;
struct EMSsfintedpar **start_end, **stop_end;
{
  IGRboolean stat_func;
  struct EMSsfintedpar *edpar;

  stat_func = FALSE;
  if (edpar = (struct EMSsfintedpar *) intobj->more_info)
    {
    if (intobj->reversed)
      {
      *start_end = edpar->next;
      *stop_end = edpar;
      }
    else
      {
      *start_end = edpar;
      *stop_end = edpar->next;
      }
    stat_func = TRUE;
    }

  return (stat_func);
}


/*
  ABSTRACT

    This function computes the parametric-space tolerance of the surface
    referred to by this EMSinters node. A side-effect of this is that
    if the "more_info" of the structure is non-instantiated with the
    surface-geometry pointer (is NULL), then this function will cause
    it to be filled up with the geometry
*/

IGRlong EMget_partol_inters (inters, mattyp, mat, uvtol)
struct EMSinters *inters;
IGRshort *mattyp;
IGRmatrix mat;
IGRdouble *uvtol;
{
  IGRlong msg, dummsg;
  extern IGRint EMgetvggeom();

  msg = EMS_S_Success;

  if (!inters->more_info)
    {
    msg = EMgetvggeom (&dummsg, mattyp, mat, &inters->this_obj,
           &inters->more_info, NULL);
    EMerr_exit (msg, ret_end);
    }

  ems$sspbtol_by_geom (msg = &msg, surface = inters->more_info,
   partolbasis = uvtol);
  EMerr_exit (msg, ret_end);

ret_end:
  dummsg = TRUE;
  EMWRAPUP (msg, dummsg, "get_partol");
  return (msg);
}


/*
  DESCRIPTION

  This function simply appends the given EMSintobj to the end of the list
  pointed to within the input EMSinters structure. The list is then NULL-
  terminated.

  ARGUMENTS

  IGRlong            *msg       O    Return message.
  struct EMSinters   *inters    I/O  The inters node to which the intobj
                                     is to be appended.
  IGRboolean         is_cv      I    True if the intobj is of curve type,
                                     else it is assumed to be of point type.
  struct EMSintobj   *intobj    I    The intobj that is to be appended to
                                     the inters node. 

  NOTES

  The EMSinters list field -- num_cvs or num_pts -- is updated with every
  addition.
  The caller has the responsibilty of calling this function on the other
  intersection object i.e. intobj->other_intobj_node, with its corresponding
  inters node, if necessary.
*/

void EMaddintobj (msg, inters, is_cv, intobj)
IGRlong *msg;
struct EMSinters *inters;
IGRboolean is_cv;
struct EMSintobj *intobj;
{
  struct EMSintobj *p_intobj;

  *msg = EMS_S_Success;
  EMerr_hndlr((!inters || !intobj), *msg, EMS_E_InvalidArg, wrapup);

  if( is_cv )
      p_intobj = inters->cvs;
  else
      p_intobj = inters->pts;

  /*
   * Get to the last intobj node on this inters list.
   */
  while( p_intobj && p_intobj->next )
               p_intobj = p_intobj->next;

  if(p_intobj)
  {
     p_intobj->next = intobj;
  }
  else
  {
    /*
     * If the inters node comes in without any intobjs attached initialise
     * the num_cvs/num_pts fields to zero as there are no intobjs on it and
     * set 'intobj' as the first intobj.
     */
    if( is_cv )
    {
       inters->cvs = intobj;
       inters->num_cvs = 0;
    }
    else
    {
       inters->pts = intobj;
       inters->num_pts = 0;
    }
  }

  if( is_cv )
     (inters->num_cvs)++;
  else
     (inters->num_pts)++;

  intobj->this_obj_node = inters;
  intobj->next = NULL;
  
wrapup:
  return;
}


#define UNKNOWN       0
#define STARTSTART    1
#define STARTSTOP     2
#define STOPSTART     3
#define STOPSTOP      4

/*
  DESCRIPTION
  
  This function takes in an array of EMSintobj structures which are end-point
  connected and returns a single EMSintobj that could take their place. They
  need to be ordered in a particular sequence. All that is required is that
  every EMSintobj in this list, share atleast one end-point with the next.

  The original intobjs are not modified and are returned intact. The reversed
  flag of the resulting intobj is set based on the the flag of the first intobj
  in the array.

  The  resultant EMSintobj is returned in the output structure passed in. Every
  field of this output structure is set by the function. The caller may then
  replace this resultant structure in place of the existing set.

  The intobjs on the other surface are also merged and the resultant intobj
  on the other surface is returned as the 'other_intobj_node' of out_intobj.


  NOTES

  Use EMdelintobj to delete EMSintobjs from the 'inters' list and use
  EMaddintobj to add to the 'inters' list. This should be done on this surf
  for 'out_intobj' and other_surf for its 'other_intobj_node'.

  BUGS

  It is assumed that the intobjs in the array are atleast end point
  continuous and can form one contiguous group.
  This function cannot detect if the resultant intobj forms a closed curve.
*/

void EMmergeintobjs (msg, mattyp, mat, num_intobjs, intobjs, out_intobj)
IGRlong *msg;
IGRshort mattyp;
IGRmatrix mat;
IGRint num_intobjs;
struct EMSintobj **intobjs;
struct EMSintobj *out_intobj;
{
  IGRint inx=0, data=0, surf=0;
  IGRlong msg_loc, sts;
  IGRdouble tol;
  IGRboolean true = TRUE, match=FALSE;
  struct EMSinters *p_inters=NULL;
  struct EMSintobj *p_intobj=NULL, *p_next_intobj=NULL, *p_dumintobj=NULL;
  struct EMSintobj *p_tmpintobj1=NULL, *p_tmpintobj2=NULL, dum_intobj;
  struct EMSdataselect *p_data1=NULL, *p_data2=NULL, *p_tmpdata=NULL;
  struct EMSdataselect merged_data, *p_data=NULL, tmp_data1, tmp_data2;
  void EMcheck_intobj_endpt_match();
  extern void EMdataselect_copy();
  extern void EMdataselect_free();
  extern void EMdataselect_data_free();
  extern struct EMSintobj *EMintobj_malloc();
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern void EMintobj_free();

  sts = 1;
  *msg = msg_loc = EMS_S_Success;

  /* p_dumintobj is a dummy intobj */
  p_dumintobj = &dum_intobj;
  p_data = &tmp_data1;
  p_tmpdata = &tmp_data2;

  /*
   * Loop for this and the other surface.
   */
  for( surf=0; surf<2; surf++)
  {
     p_inters = (surf==0)? intobjs[0]->this_obj_node :
                         intobjs[0]->other_intobj_node->this_obj_node;

    /*
     * Loop for xyz and uv data.
     */
    for(data=0; data<2; data++)
    {
      /*
       * Process the xyz data in the first pass itself as both the
       * intobjs point to the same xyz dataselect.
       */
      if(surf==1 && data==0) continue;

      if(data == 0)
      {
        BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, tol);
      }
      else
      {
        sts =  om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                                                         &mattyp,
                                                         mat, &true, TRUE,
                                                         &tol),
                            senderid = NULL_OBJID,
                            targetos = p_inters->this_obj.osnum,
                            targetid = p_inters->this_obj.objid);
        EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_SurfaceError, wrapup);
      }

      for(inx=0; inx < num_intobjs-1; inx++)
      {
        p_intobj = (surf==0)? intobjs[inx] : intobjs[inx]->other_intobj_node;
        p_next_intobj = (surf==0)? intobjs[(inx+1)] :
                        intobjs[(inx+1)]->other_intobj_node;

        if(inx != 0) p_intobj = p_dumintobj;
        match = 0;
        EMcheck_intobj_endpt_match ( &msg_loc, mattyp, mat, p_intobj,
                                     p_next_intobj, !data, &match, tol, FALSE);
        EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);

        p_data1 = (data==0) ? &p_intobj->this_xyzintobj :
                              &p_intobj->this_uvintobj;
        p_data2 = (data==0) ? &p_next_intobj->this_xyzintobj :
                              &p_next_intobj->this_uvintobj;

        if( match == STOPSTART)
        {
          /* The intobjs are lying fine. Go ahead and merge them. */

          EMdataselect_copy (&msg_loc, p_data1, p_data);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);
          EMdataselect_copy (&msg_loc, p_data2, p_tmpdata);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);

          EMmergedata (&msg_loc, mattyp,mat, p_data, p_tmpdata, &merged_data);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);

          EMdataselect_data_free(&msg_loc, p_data, 1);
          EMdataselect_data_free(&msg_loc, p_tmpdata, 1);
        }
        else if(match == STARTSTART || match == STOPSTOP)
        {
          /* Start of 1 & 2 match. Reverse 2 for merging. */
          /* Stops of 1 & 2 match. Reverse 2 for merging. */
          /* 
           * For the first dataselect, copy it directly into
           * merged_data. Others have to be merged into
           * merged_data.
           */
          EMdataselect_copy (&msg_loc, p_data2, p_tmpdata);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);
          EMdata_reverse (p_tmpdata);

          if(inx == 0)
          {
            EMdataselect_copy (&msg_loc, p_data1, p_data);
            EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);
          }
          else
          {
            p_data = p_data1;
          }

          EMmergedata (&msg_loc, mattyp,mat, p_data, p_tmpdata, &merged_data);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);

          EMdataselect_data_free(&msg_loc, p_data, 1);
          EMdataselect_data_free(&msg_loc, p_tmpdata, 1);
        }
        else if( match == STARTSTOP)
        {
          /* Start of 1 and stop of 2 match. Reverse both and merge */

          EMdataselect_copy (&msg_loc, p_data2, p_tmpdata);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);
          EMdata_reverse (p_tmpdata);

          if(inx == 0)
          {
            EMdataselect_copy (&msg_loc, p_data1, p_data);
            EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);
          }
          else
          {
            p_data= p_data1;
          }

          EMdata_reverse (p_data);

          EMmergedata (&msg_loc, mattyp, mat, p_data, p_tmpdata, &merged_data);
          EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);

          EMdataselect_data_free(&msg_loc, p_data, 1);
          EMdataselect_data_free(&msg_loc, p_tmpdata, 1);
        }
        else continue;

        if(data == 0) p_dumintobj->this_xyzintobj = merged_data;
        else p_dumintobj->this_uvintobj = merged_data;

      } // for...

      if(data == 0)
      {
        (out_intobj)->this_xyzintobj = merged_data;
        (out_intobj)->other_intobj_node->this_xyzintobj = merged_data;
      }
      else
      {
        if(surf == 0)
          (out_intobj)->this_uvintobj = merged_data;
        else
          (out_intobj)->other_intobj_node->this_uvintobj = merged_data;
      }

    } // for ( data ....

    /* Do the orientation of the merged intobj based on uv data */
    match = 0;
    p_tmpintobj1 = (surf==0)? intobjs[0] : intobjs[0]->other_intobj_node;
    p_tmpintobj2 = (surf==0)? (out_intobj) : (out_intobj)->other_intobj_node;

    EMcheck_intobj_endpt_match(&msg_loc, mattyp, mat, p_tmpintobj1,
                               p_tmpintobj2, FALSE, &match, tol, FALSE);
    EMerr_hndlr(!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);

    if(match == STARTSTART || match == STOPSTOP)
       p_tmpintobj2->reversed = p_tmpintobj1->reversed; 
    else 
       p_tmpintobj2->reversed = !p_tmpintobj1->reversed;

  } // for ( surf ....

wrapup:
  return;
}


/*
   DESCRIPTION

   Checks how the intobjs' end points lie relative to each other.

   ARGUMENTS

   IGRlong             *msg      O     The return status of the function.
   struct EMSintobj    *intobj1, I     The intobjs whose end points are
                       *intobj2        to be matched.
   IGRboolean          xyz       I     Flag to indicate whether the match
                                       is to be found in xyz(TRUE) or
                                       uv(FALSE) coordinates.
   IGRshort            *match    O     Return value of the intobjs endpoint
                                       match. The values that can be
                                       returned are:
                                           UNKNOWN       0
                                           STARTSTART    1
                                           STARTSTOP     2
                                           STOPSTART     3
                                           STOPSTOP      4
                                       eg. STARTSTOP indicates that the
                                       start point of intobj1 matches
                                       the stop point of intobj2.
   IGRdouble           tol       I     The tolerance within which a match
                                       will be true.
   IGRboolean          logical   I     If TRUE, then the reversed flag of
                                       the intobjs will also be considered
                                       and the match returned will be
                                       between the logical end points of
                                       the intobjs. Else, the match will
                                       be based on the geometry of the
                                       dataselects.

*/


void EMcheck_intobj_endpt_match(msg, mattyp, matrix, intobj1, intobj2, xyz,
                                match, tol, logical)
IGRlong *msg;
IGRshort mattyp;
IGRmatrix matrix;
struct EMSintobj *intobj1, *intobj2;
IGRboolean xyz, logical;
IGRshort *match;
IGRdouble tol;
{
  struct EMSdataselect *data1=NULL, *data2=NULL;
  IGRpoint start1, stop1, start2, stop2;
  IGRlong sts = 1, msg_loc;
  IGRint size = 0;
  extern pwIsSamePt2d();
  extern IGRint EMgetendpts();

  *msg = msg_loc = EMS_S_Success;
  *match = 0;
  size = 3*sizeof(IGRdouble);

  memset(start1, NULL, size);
  memset(stop1, NULL, size);
  memset(start2, NULL, size);
  memset(stop2, NULL, size);

  if( !xyz )
  {
    data1 = &intobj1->this_uvintobj;
    data2 = &intobj2->this_uvintobj;
  }
  else
  {
    data1 = &intobj1->this_xyzintobj;
    data2 = &intobj2->this_xyzintobj;
  }

  sts = EMgetendpts( &msg_loc, mattyp, matrix, data1,
                    logical ? intobj1->reversed : FALSE, 1, start1, stop1, xyz);
  EMerr_hndlr(!(1 & msg_loc & sts), *msg, EMS_E_Fail, wrapup);

  sts = EMgetendpts( &msg_loc, mattyp, matrix, data2,
                    logical ? intobj2->reversed : FALSE, 1, start2, stop2, xyz);
  EMerr_hndlr(!(1 & msg_loc & sts), *msg, EMS_E_Fail, wrapup);

  if(pwIsSamePt (stop1, start2, tol)) *match = STOPSTART;
  else if(pwIsSamePt (start1, stop2, tol)) *match = STARTSTOP;
  else if(pwIsSamePt (start1, start2)) *match=STARTSTART;
  else if(pwIsSamePt (stop1, stop2)) *match = STOPSTOP;
  else *match = UNKNOWN;

wrapup:
  return;
}

end implementation Root;
