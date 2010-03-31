/*
  DESCRIPTION

    This function uses the input intersection data between surface-object A
    and the set of surface-objects B, and performs the specified Boolean
    operation between them. The boundaries of the comprising surfaces are
    modified to reflect the Boolean operation. An object of class EMSsfboolean
    is passed in which becomes the result of this operation. This object
    will own the modified A and B on it's channel on successful completion
    of this function.

    Since the intersections are being passed, a "Boolean" operation
    can be done just on object A. This would be equivalent to an impose
    boundary operation. For this, all data concerning the second operand
    B could be NULL.

    NOTE THIS :

    The intersection data may be non-oriented, except for one, marked
    EMSintobj which is definitely oriented. The EMSintobj is so oriented
    that the loop of which it becomes a part is a P-loop, that is,
    area on the right of the EMSintobj.

  ARGUMENTS


    msg			- Output: Message return code.

    boolid		- Input: The object that will be the result of
			   this operation. To this object A and B are
			   connected as the operands (only if A if B
                           is not specified). If objid of this GRid is
                           set to NULL_OBJID (osnum must still be set),
                           then no connections are made, no save-state
                           operation is attempted and the objects A and/or
                           B are modified in place. 

    boolop		- Input: The Boolean operation required to be
			   performed. If only data for A passed in, this
                           is not looked at.

    mdenv		- Input: Information about the module in which
			   boolid, A and B reside.

    sf1			- Input: Surface object A.

    numsfs2, sfs2	- Input: Surface objects that comprise the set B.
                           numsfs2 == 0, sfs2 == NULL, if B not specified.

    sf1_inters,		- Input: The intersection lists for A and B.
    sfs2_inters            sfs2 is NULL if B not specified.

    sf1_tracedata,	- Input: The trace information for A and B.
    sfs2_tracedata         sfs2_tracedata == NULL, if B not specified.

    sf1_loopdata,	- Input: The intersection data converted into 
    sfs2_loopdata	   toplogical data along with incidence information,
                           that can directly be used for splitting existing
                           edges and closing loops, and so on. Either or
                           both could be NULL (if so, this is generated
                           inside this function).

    options		- Input: Options used to change the default
			   characteristics of this function: 
			    EMSsfbool_opt_display,
			    EMSsfbool_opt_noredraw, 
			    EMSsfbool_opt_OpenIntPossible,
			    EMSsfbool_opt_SingleTopology,
			    EMSsfbool_opt_HandleStop,
 			    EMSsfbool_opt_AdjacentRegions  
                           are currently the possible options.
			   See emssfintdef.h
    num_dispsfs,	- Input/Output: Information about display surfaces
    dispsfids		   exchanged when the option to 'noredraw' is on.
			   The surfaces that are modified are added to
			   this list if not already in it and any erasure
			   of surfaces is done only if the surface is not
			   already in the list.

    status_str		- Input/Output: If non-NULL, the input string is
			   displayed in the status-space with dots (".") 
			   appended onto it incrementally as the function
			   proceeds. In this function a maximum of five dots
			   may be added, hence that much space must be
			   available in the string.

  RETURN VALUES
  
    Note that this function does not print any error message on a non-fatal
    error. Upon exit the completion code will be one of the following

      If the operation was successfully completed:
      - EMS_S_Success 
          if succeeded

      - EMS_I_Interrupt
          If the option to handle the STOP-interrupt was on and the procedure
          was interrupted.

      In all of the following errors a recovery operation succeeded
      and the two input solids are still intact and reusable. The method
      invocation has behaved essentially like a noop.

      - EMS_E_IntersectTrim
          the end-point incidence data on the surface intersection curves
          was incorrect in some way or indicated bad topology.

      - EMS_E_InvalidArg 
          if the input argument list was invalid, ie, the objects input
          belong to different object spaces.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_SurfaceError
          if a failure occurred when a call to a surface method was
          made.
      - EMS_E_LoopsetError
          if a failure occurred when a call to a surface-loopset method was
          made.
      - EMS_E_LoopError
          if a failure occurred when a call to a surface-loop method was
          made.
      - EMS_E_EdgeError
          if a failure occurred when a call to a surface-edge method was
          made.
      - EMS_E_OMError
          if a failure occurred when a call to an OM-primitive was
          made or,
          a failure on invocation of a method on some object.
      - EMS_E_Fail
          Most probably a failure in a call to a math-function.
          In some cases the reason for failure was not understood in greater
          detail. 

      A catastrophic failure has occurred. The input objects' topology
      has gotten corrupted.

      - EMS_F_Fail
          If an error occurred and the recovery was not possible or failed,
          the solids have possibility been destroyed beyond recovery.

  HISTORY

    Vadi :  24/05/94  : Modified for Trim Composite Surf/Solid functionality.
      
                        - Suppressing splitting for duplicate intobjs is
                          now done selectively.  Because, the act of
                          pushing the intobjs across the common edges results
                          in duplicate intobjs on a different surface from
                          that of their original counterpart.

                        - Modified 'search_and_get_intobj' so that if 'ptedges'
                          is NULL by reference, it returns the intobj
                          corresponding to the required 'intedge'.

    Vadi :  30/09/93  : Modified for Trim Composite Surf/Solid functionality.
                       
                       - Suppressing the splitting for duplicate intobjs(
                         relevant only if Trim Composite Surf/Solid
                         functionality.)
                       - if Trim Composite Surf/Solid functionality,
                         do nesting as the modification in EMlpnest.I   
                         fails to work for some cases.
                       - free the 'inters' list for the Trim Composite
                         Surf/Solid functionality.
                       - Sundry changes to overcome minor bugs related to
                         Trim Composite Surf/Solid functionality.

    NP  :  05/19/92  : Added calls to "timer" functions for timing the code.
    SS  :  03/17/92  : Modification to "edgeid" field of intedpar[12] changed
                       data in the incoming intersection list. This caused
                       problems. Now the change is done only when needed
                       and the structure restored to it's original state
                       after the need has been met.
    DLB :  02/06/92  : Fix TR 92N0694 - if severe failure during recompute
    		       EMundo was being sent which was disconnecting this
    		       node from the DPR tree.  I added a check for
    		       UNEVAL dpr_prop  if set then go ahead with the
    		       UNDO_DELETE but dont disconnect components or clean
    		       up next states.
    Tapadia: 02/20/91  Fix for TR 91n0161 - Arguments for booldisplay were
		       less & swaped. 
    SS  :  02/08/90  : Used the option EMS_UNDO_DONTDELME in addition to
                       the EMS_UNDO_DELETE in the recovery undo.
    DLB :  01/15/90  : Changed display send to use module GRid returned from
                       gr$get_display_env.  The display was not working if
                       the boolean occured in a reference file.
    SM  :  19-Dec-89 : For error recovery with 'unsplit_on_error' check
		       stat_OM in addition to *msg.
    SS  :  09/17/89  : Added support for the STOP-interruption.
    SM	:  11-Jul-89 : Removed the validation code (STAGE 1) and put it into
		       the function EMsfbool_validate. This new function
		       also outputs the various informational arrays from
		       the function EMsfintloops.
    SS  :  06/15/89  : All status strings are now output directly.
    SS  :  06/07/89  : Creation. This is the second portion of the
                       old EMjoiningBoolean method. The first part of
		       the same method has gone into the file EMsfinters.I

    The following history is about this code when it resided in the
    EMsfbJBool.I file:

    jBk :  01/09/89  : Replaced em$xsMessage invocations with ex$message
                       invocations. Accordingly, replaced EMScimacros.h
                       inclusion with inclusion of msmacros.h.
    SS  :  08/26/88  : Made the modifications to support the notification
                       scheme.
    DLB :  07/26/88  : Added code to set properties bit of all removed
                       surfaces to EMSIS_INACTIVE.  This effectively makes
                       the surface appear to not exist at even though it is
                       still in the R-tree.  The display, and locate code 
                       at the sub surface level have been modified to check
                       for this bit being set.
    SS  :  07/12/88  : The fixings that were being performed in stage 4
                       are now being done in EMfix_refine... Making use
                       of all these "fixings" to do a more stringent
                       validation of the intersection data in stage 3.
                       This is to minimize catastrophic failures.
    DLB :  06/01/88  : Modified Sunit's saveside code to NOT put the plane 
                       on the to_components channel. Instead, put it on the
                       end of the ids vla.  Note that this is a special case
                       of a saveside operation on a composite surface. 
    SM  :  13-May-88 : Made modification so that save side on
                       surfaces/composite surfaces will work even if the
                       intersection is open in model space (as long as
                       all the intersection pieces have incedent edges).
                       For this added two options -

                       EMSsfbool_opt_OpenIntPossible : Continue processing
                       even if the intersection is open. But error out
                       if a dangling piece is encountered (no harm done when
                       this is detected). THIS OPTION MOVED TO EMsfinters.I

                       EMSsfbool_opt_SingleTopology : Do not create any new
                       topology (resulting out of the intersection) on the
                       second operand(s) of the boolean. Consequently edges
                       created on first operand will have no common
                       edges.

                       I also added code to make the second operand for
                       save side (the plane) as non locatable and non
                       displayable if the first operand is non-solid.
                       The only purpose of the save side plane is to
                       hang around for re-execution.
    jBk :  13-Apr-88 : jBk Eliminated IGRchar dot[2].
                       Changed num_stages from IGRchar to IGRint,
                       although, I see it is never used.
                       Now use message subsystem for status messages.
                       Changed name of message implemented from
                       EMboolean to EMjoiningBoolean.
    DLB :  03/21/88  : Added dispsfids and num_dispsfs parameters. Also
                       modified display process to check for
                       EMSsfbool_opt_noredraw option.  If true modified ids
                       are added to display_ids array and nothing is
                       redrawn.  I do this so that reexecute will also
                       perform a selective display.
    SS  :  03/03/88  : Changed the EMSloop.EMunsplityourself to
                       EMSedge.EMunsplityourself.
    DLB :  01/27/88  : Added send to EMtoglpactive to toggle loops of
                       surfaces removed to inactive.  Note that this
                       used to be done by EMfixSSI but problems occurred
                       when a surface was displayed with inactive loops.
    DLB :  11/04/87  : Modified EMScompowner struct to retrieve ownerindex.
    DLB :  11/03/87  : Modified for version 1.1.0
    SS  :  03/01/87  : Creation
*/

class implementation EMSsfboolean;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"  
#include "msmacros.h"
#include "ECmsg.h"
#include "timerdef.h"
#include "emsimpdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR
#define PtEdgeBuf	10

extern GRclassid OPP_EMSsolid_class_id, OPP_EMSptedge_class_id;
extern IGRboolean _use_timers;

from EMSedge import EMgettopedge;
from EMSedge import EMsplityourself, EMunsplityourself, EMget_props;
from EMSloop import EMcloseyourself, EMremove_adjacent_holes; /* New method */
from EMSloopset import EMlscleanup, EMtoglpactive;
from EMSloopset import EMupdate_features;
from EMSsubbs import EMpassloop;

from EMSloopset import EMnesting, EMtreemod, EMget_loops;
from EMSloop import EMgivenestinfo, EMget_loops, EMtreemod, EMnesting,
                    EMget_props, EMtoggle_type;

%safe
static IGRlong booldisplay();
static struct EMSintobj *search_and_get_intobj();
%endsafe

IGRlong EMboolean_surfaces_w_trm_intersection (msg, boolid, boolop,
                                               mdenv, sf1, numsfs2, sfs2,
                                               sf1_inters, sfs2_inters,
                                               sf1_tracedata, sfs2_tracedata,
					       sf1_loopdata, sfs2_loopdata,
                                               options,
                                               num_dispsfs, dispsfids,
                                               status_str)
IGRlong *msg;
struct GRid *boolid;
enum EMSbooltype boolop;
struct GRmd_env *mdenv;
GRobjid sf1, *sfs2;
IGRint numsfs2;
struct EMSinters *sf1_inters, *sfs2_inters;
struct EMSsftracedata *sf1_tracedata, *sfs2_tracedata;
struct EMSsfintloopsdata *sf1_loopdata, *sfs2_loopdata;
IGRushort options;
IGRint *num_dispsfs;
GRobjid **dispsfids;
IGRchar *status_str;
{
  IGRboolean chkdisplist, dont_redraw, found, notify = FALSE, 
             op1_only, no_save_state, duplicate = FALSE, 
             my_fwd1, my_bwd1, other_fwd1, other_bwd1,
             my_fwd2, my_bwd2, other_fwd2, other_bwd2,
             skipped_split1; 
  IGRboolean undo_on_error, unsplit_on_error, handle_stop,
             both_inceds_are_same1, both_inceds_are_same2;
  IGRboolean **subgrp_rev[2], ***elem_rev[2], *grp_closed[2];
  IGRboolean **subgrp_closed[2];
  IGRboolean used_up, list_extended, sffound, do_display;
  IGRboolean unsplit1, unsplit2;
  IGRboolean surface_saveside, sfintloops_alloced[2];
  IGRchar dot[2];
  IGRshort *mattyp;
  IGRushort dpr_props;
  IGRuint count, commed_exists;
  IGRint i, j, k, l, num_comm_edges = 0, p;
  IGRint inx, opinx, inxlim, circinxj, circinxk;
  IGRint altinx1, altinx2, dispinx, opinxlim, splitdir, num_null_elems;
  IGRint num_grps[2], *num_subgrps_grp[2], **num_elems_subgrp[2];
  IGRint numedsplit = 0, numsfsadd, numsfsmod, numsolsmod, *num_loopsadd;
  IGRint totnumloops_in, totnumloops_out, totnumsfs_out, numaddfeats;
  IGRint num_loops_visited;
  IGRint connect_splted_dir, connect_ed_dir;  /* Newly added */
  IGRlong msg_loc, stat_loc, stat_OM, send_msg;
  IGRdouble **sfpartolb[2], *mat;
  GRobjid **loop_sf[2], **endedges[2];
  GRobjid incedge1, incedge2, commedge, spltedges1[2], spltedges2[2];
  GRobjid intedge1, intedge2, thissf, othersf, *comm_edges = NULL,
          l_edid, r_edid;
  GRobjid splitvtx, *objid_sfsadd, *edsplit, *addfeats, tmpedge;
  GRobjid *loops_visited;
  GRclassid myclassid;
  GRspacenum thisos;
  struct GRvg_construct const_args;
  struct GRmd_env loc_mdenv, display_env;
  struct EMSedgebound incpar1, incpar2;
  struct EMSinters *inters[2], *loc_inters;
  struct EMSintobj ***elems[2], *loc_intobj, *tmp_intobj = NULL,
                   *my_intobj = NULL, *other_intobj = NULL;
  struct EMSsfintedpar ***intedpars[2], *intedpar1, *intedpar2,
                       *more_info = NULL;
  struct EMSpartolbasis partol_basis;
  struct EMSownercomp *sfmodloops, *solrmsfs, *newrmloops;
  struct EMSownercomp *ownlist, *other_ownlist;
  struct EMSboolssi_table *myssiinfo;
  struct EMSsftracedata *tracedata[2];
  struct EMSsfintloopsdata s_loopdata[2], *p_loopdata[2];
  struct EMSsavesideri_table myriinfo; 
  union EMSssi_table *ssibuff;
  union EMSssiSizeData size_data;
  enum EMScvinttype incloc1, incloc2;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT chan_to_common_edge, chan_to_loopset, chan_to_comps;
  OM_S_CHANSELECT to_edges, to_owners; /* Newly added */
  OM_S_OBJECT_LINKAGE objlink;

  struct EMSnest_info temp_nesting, nesting;
  IGRint m, depth, buf_size;
  IGRboolean ambiguity = FALSE;
  GRobjid *loopids = NULL, save_parent_loop;
  IGRushort *props = NULL, granpa_props, parent_props, son_props,
             togtype_options = NULL;
  OM_S_CHANSELECT to_inner, to_outter, to_loops;
  OM_S_OBJECT_LINKAGE grand_parent, child_loop;

  extern IGRboolean EMcheck_inhibit_postproc(), IGEstop();
  extern void EMsfintloops_free(), EMsfintloops_data_free();
  extern void EMinters_data_free(), EMinters_free();
  extern void EMsfintedpar_free();
  extern void EMsfinttrace_free();
  extern void EMmkownlist(), EMrestore_postproc(), EMremove_array();
                                                   /* New function */
  extern IGRlong EMsfint_topology_validate();
  IGRboolean deg_split[2], rev_degen1 = FALSE, rev_degen2 = FALSE, 
             spliting_same_edge = FALSE;
  IGRushort edsplit_opt = NULL;
  struct EMSintobj *intobj1 = NULL, *intobj2 = NULL;
  enum EMScvinttype tmpincloc;
  GRobjid unconnected_edges[2], orig_edge_for_unconnected_edges = NULL_OBJID;
  GRobjid *ptedges = NULL;
  IGRint num_ptedges = 0, ptedges_buf = 0;

  /* START TIMER */
  if (_use_timers)
        start_timer (T_EMBOOLEAN_SURFACES_W_INTERSECTION);

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize pointers, variables, etc. Set the undo_on_error
   * so that on an error condition, the method knows if an undo
   * operation is to be attempted on the two solids.
   */

  op1_only = options & EMSsfbool_opt_SingleTopology || !numsfs2;
  opinxlim = op1_only ? 1 : 2;

  num_loopsadd = NULL;
  objid_sfsadd = NULL;
  sfmodloops = NULL;
  solrmsfs = NULL;
  newrmloops = NULL;
  ssibuff = NULL;
  edsplit = NULL;
  loops_visited = NULL;
  tracedata[FIRST] = sf1_tracedata;
  tracedata[SECOND] = sfs2_tracedata;
  for (opinx=FIRST; opinx<opinxlim; opinx++)
    {
     struct EMSinters *this_inters = NULL;
     struct EMSintobj *this_intobj = NULL;

    inters[opinx] = opinx == FIRST ? sf1_inters : sfs2_inters;
    num_grps[opinx] = tracedata[opinx]->num_grps;
    num_subgrps_grp[opinx] = tracedata[opinx]->num_subgrps_grp;
    num_elems_subgrp[opinx] = tracedata[opinx]->num_elems_subgrp;
    elems[opinx] = tracedata[opinx]->elems;
    subgrp_rev[opinx] = tracedata[opinx]->subgrp_rev;
    elem_rev[opinx] = tracedata[opinx]->elem_rev;
    grp_closed[opinx] = tracedata[opinx]->grp_closed;
    subgrp_closed[opinx] = tracedata[opinx]->subgrp_closed;
    deg_split[opinx] = FALSE;
    this_inters = inters[opinx];
    while(this_inters)
     {
      this_intobj = this_inters->cvs;
      while(this_intobj)
       {
	if((this_intobj->props & EMSintobj_degen_ornt_right) ||
	   (this_intobj->props & EMSintobj_degen_ornt_left))
	 {
	  deg_split[opinx] = TRUE;
	  break;
	 }
	this_intobj = this_intobj->next;
       }
      if(deg_split[opinx])
       break;
      this_inters = this_inters->next;
     }
    }
  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    loop_sf[opinx] = NULL;
    endedges[opinx] = NULL;
    intedpars[opinx] = NULL;
    sfpartolb[opinx] = NULL;
    sfintloops_alloced[opinx] = FALSE;
    }

  undo_on_error = FALSE;
  unsplit_on_error = FALSE;

  do_display = options & EMSsfbool_opt_display;

    dont_redraw = chkdisplist = FALSE;
  handle_stop = options & EMSsfbool_opt_HandleStop;
  no_save_state = IF_NULL_OBJID (boolid->objid);

  thisos = boolid->osnum;
  mattyp = &mdenv->md_env.matrix_type;
  mat = mdenv->md_env.matrix;

  if (status_str)
    strcpy (dot, ".");

  /*
   * The resultant Boolean solid and the objects that have been constructed
   * for the Boolean operation, should also exist in the current object space
   * (the operands are expected to be in this same object space).
   */

  EMerr_hndlr (sf1_inters->cvs->this_uvintobj.data.object->osnum != thisos,
   *msg, EMS_E_InvalidArg, ret_end);

  /*
   * STAGE 1:
   * Construct loops with the intersection data,, get the incident edge info
   * for each subgroup, and the parametric tolerances for the surfaces,
   * if these are not already passed in. While obtaining these, a validation
   * for the intersection data is performed based on topological
   * considerations.
   */

  if (status_str)
    {
    strcat (status_str, dot);
    ex$message(in_buff = status_str, field = ERROR_FIELD)
    }
  
  if (sf1_loopdata)
    p_loopdata[FIRST] = sf1_loopdata;
  else
    p_loopdata[FIRST] = &s_loopdata[FIRST];
  if (sfs2_loopdata)
    p_loopdata[SECOND] = sfs2_loopdata;
  else
    p_loopdata[SECOND] = &s_loopdata[SECOND];

  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    goto ret_end;
    }

  /* start timer for topology validate */
  if (_use_timers)
     start_timer (T2_TOPOLOGY_VALIDATE);

  if (!sf1_loopdata || !sfs2_loopdata)
    {
    stat_OM = EMsfint_topology_validate (&msg_loc, &mdenv->md_env,
               sf1_inters, sfs2_inters, sf1_tracedata, sfs2_tracedata, options,
               sf1_loopdata ? NULL : p_loopdata[FIRST],
               sfs2_loopdata ? NULL : p_loopdata[SECOND]);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /* stop timer for topology validate */
  if (_use_timers)
     stop_timer (T2_TOPOLOGY_VALIDATE, FALSE, "");
 
  numedsplit = 0;
  for(opinx=FIRST; opinx<opinxlim; opinx++)
    {
    loop_sf[opinx] = p_loopdata[opinx]->loop_sf;
    endedges[opinx] = p_loopdata[opinx]->endedges;
    intedpars[opinx] = p_loopdata[opinx]->intedpars;
    sfpartolb[opinx] = p_loopdata[opinx]->sfpartolb;
    sfintloops_alloced[opinx] = p_loopdata[opinx]->sfintloops_alloced;
    numedsplit += p_loopdata[opinx]->numedsplit;
    }

  if (numedsplit)
    {
    edsplit = (GRobjid *) om$malloc (size = numedsplit * sizeof (GRobjid));
    EMerr_hndlr (!edsplit, *msg, EMS_E_NoDynamicMemory, ret_end);
    numedsplit = 0;
    }

  /*
   * STAGE 1-1/2:
   * If a request to work the display for this operation has been received,
   * background erase those surfaces that are going to be affected. The
   * affected surface ids are obtained from the surface-surface intersection
   * list.
   * If (chkdisplist) add the modified ids to the dispsfids array and
   * realloc if needed. (3-21-88 DLB)
   */

  if (do_display)
    {
      IGRint env_size=sizeof(struct GRmd_env), nret;

      /*DLB addition 1/15/90*/
      gr$get_display_env(msg = &msg_loc,
                         sizbuf = &env_size,
                         buffer = &display_env,
                         nret = &nret);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = booldisplay (&msg_loc, GRbehe, num_dispsfs, dispsfids, 
               chkdisplist, opinxlim, inters, mattyp, mat, &display_env.md_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
 
  /*
   * STAGE 2:
   * There is now readily available the list of edges that
   * are involved in splitting the existing boundary on the solids.
   * Using the information about which existing boundary element
   * gets split (and where) by the "splitting edge", the actual
   * splitting operation is performed. If the loop to which this splitting
   * edge belongs closes by itself, no split occurs. Check if notification
   * flag is on. If so turn it off, as this function is taking the
   * responsibility for notification (after the notification the flag will be
   * turned back on).
   */

  if (status_str)
    {
    strcat (status_str, dot);
    ex$message(in_buff = status_str, field = ERROR_FIELD)
    }
  
  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    goto ret_end;
    }

  stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);
  EMomerr_exit (stat_OM, ret_end);

  partol_basis.is_valid = TRUE;
  partol_basis.in_world = TRUE;
  partol_basis.mattyp = mattyp;
  partol_basis.mat = mat;

  notify = EMcheck_inhibit_postproc();
    stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
    if(!(1&stat_OM)) goto ret_end;

    stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owners);
    if(!(1&stat_OM)) goto ret_end;

 /* start timer for splitting of incident edges */
  if (_use_timers)
    start_timer (T2_SPLIT_EDGES);

  for (opinx=FIRST; opinx<opinxlim; opinx++)
    {
    for (i = 0; i < num_grps[opinx]; i++)
      {
      if (subgrp_closed[opinx][i][0])
        {
        /*
         * The loop is closed and does not split any existing edge.
         * If the loop is closed, there is only one subgroup in this
         * group. Move on to the next group.
         */
        
        continue;
        }
      num_null_elems = 0;
      inxlim = num_subgrps_grp[opinx][i] * 2;
      unconnected_edges[0] = unconnected_edges[1] = NULL_OBJID;
      orig_edge_for_unconnected_edges = NULL_OBJID;
      for (j=0, k=0; k<inxlim; j++, k+=2)
        {
        /*
         * Split the incident edge at the logical end of the open loop.
         * Then split the incident edge at the beginning of the circularly
         * indexed, subsequent loop. By 'logical' end is meant the end that
         * would give continuity in model-space. For example, if the
         * jth subgroup is to be reversed (subgrp_rev[i][j] == TRUE)
         * for positional continuity, the logical beginning is it's
         * true end. The second incident edge is typically the
         * common edge to the first. A topological link
         * up of the split pieces is done. But if the split is taking place
         * at vertices no edges are split and topological link up is
         * necesssary.
         *
         * It is safe to assume that the intersection-location returned
         * (at middle, at right end or at left end) by the surface-
         * intersection method will continue to hold inspite of multiple
         * splits taking place on an incident edge. This, because a 'middle'
         * location becomes an 'end' location and vice versa only if the
         * incident edge is split two or more times at the same point.
         * This can never happen as the trace function would have strung
         * such would-be splitting edges together and their would-be
         * splitting ends will no longer remain so. 
         *
         * In the following code, the index i, j, k, l have the following
         * significance:
         *   i - is the index for the group being processed,
         *   j - is the subgroup in that group,
         *   k - increments parellel to j, but with increment of 2,
         *   l - locally used iteration counter.
         */

        rev_degen1 = rev_degen2 = FALSE;
        spliting_same_edge = FALSE;
  
        altinx1 = subgrp_rev[opinx][i][j] ? 0 : 1; 
        intedge1 = endedges[opinx][i][k+altinx1];
        intedpar1 = intedpars[opinx][i][k+altinx1];
        incedge1 = intedpar1->edgeid;
        unsplit1 = TRUE;
      
        {
          my_fwd1 = my_bwd1 = other_fwd1 = other_bwd1 = TRUE;
          both_inceds_are_same1 = FALSE;

          my_intobj = search_and_get_intobj(&msg_loc, intedge1, inters[opinx],
                                             NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          more_info = (struct EMSsfintedpar *)my_intobj->more_info;
          l_edid = my_intobj->reversed ? more_info->next->edgeid :
                   more_info->edgeid;
          r_edid = my_intobj->reversed ? more_info->edgeid :
                   more_info->next->edgeid;
       
          if(!(my_intobj->props & EMSintobj_overlap) && 
             IF_EQ_OBJID(l_edid, r_edid))
             both_inceds_are_same1 = TRUE;  

          if(IF_EQ_OBJID(incedge1, l_edid) && !my_intobj->bwd)
             my_bwd1 = FALSE;
          else if(IF_EQ_OBJID(incedge1, r_edid) && !my_intobj->fwd)
             my_fwd1 = FALSE;

          commed_exists = NULL;
          objlink.S_objid = NULL_OBJID;
          stat_OM = om$get_channel_objects (objid = intedge1, osnum = thisos,
                    p_chanselect = &chan_to_common_edge, list = &objlink,
                    size = 1, count = &commed_exists);
          EMomerr_exit (stat_OM, ret_end);

          if(commed_exists) {
          other_intobj = search_and_get_intobj(&msg_loc, objlink.S_objid,
                          inters[opinx], NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

          more_info = (struct EMSsfintedpar *)other_intobj->more_info;
          l_edid = other_intobj->reversed ? more_info->next->edgeid :
                   more_info->edgeid;
          r_edid = other_intobj->reversed ? more_info->edgeid :
                   more_info->next->edgeid;

          if(IF_EQ_OBJID(incedge1, l_edid) && !other_intobj->bwd)
             other_bwd1 = FALSE;
          else if(IF_EQ_OBJID(incedge1, r_edid) && !other_intobj->fwd)
             other_fwd1 = FALSE;
           }
        } /*here*/

        if(deg_split[opinx])
         {
          intobj1 = search_and_get_intobj(&msg_loc, intedge1, inters[opinx], 
                    &ptedges, &num_ptedges, &ptedges_buf);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
         }
        else
         intobj1 = NULL;

        partol_basis.tol = sfpartolb[opinx][i][j];
        incloc1 = intedpar1->intloc;
        incpar1 = intedpar1->edgepar;

        stat_OM = om$send (msg = message EMSedge.EMgettopedge (&msg_loc,
                   &incpar1, &partol_basis, &tmpedge),
                   targetid = incedge1, targetos = thisos,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (msg_loc == EMS_I_OutOfBounds, *msg, 
         EMS_E_IntersectTrim, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        if (!IF_EQ_OBJID (tmpedge, incedge1))
          unsplit1 = FALSE;
        incedge1 = tmpedge;
  
        stat_OM = om$get_channel_objects (objid = incedge1, osnum = thisos,
                   p_chanselect = &chan_to_common_edge, list = &objlink,
                   size = 1, count = &commed_exists);
        EMomerr_exit (stat_OM, ret_end);
        if (commed_exists)
          commedge = objlink.S_objid;
        else
          commedge = NULL_OBJID;
  
        circinxj = (j + 1) % num_subgrps_grp[opinx][i];
        altinx2 = subgrp_rev[opinx][i][circinxj] ? 1 : 0;
        circinxk = (k + 2) % inxlim;
        intedge2 = endedges[opinx][i][circinxk+altinx2];
        intedpar2 = intedpars[opinx][i][circinxk+altinx2]; 
        incedge2 = intedpar2->edgeid;
        unsplit2 = TRUE;
        incloc2 = intedpar2->intloc;
        incpar2 = intedpar2->edgepar;

        {
          my_fwd2 = my_bwd2 = other_fwd2 = other_bwd2 = TRUE;
          both_inceds_are_same2 = FALSE;
  
          my_intobj = search_and_get_intobj(&msg_loc, intedge2, inters[opinx],
                                             NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          more_info = (struct EMSsfintedpar *)my_intobj->more_info;
          l_edid = my_intobj->reversed ? more_info->next->edgeid :
                   more_info->edgeid;
          r_edid = my_intobj->reversed ? more_info->edgeid :
                   more_info->next->edgeid;

          if(!(my_intobj->props & EMSintobj_overlap) && 
             IF_EQ_OBJID(l_edid, r_edid))
             both_inceds_are_same2 = TRUE;

          if(IF_EQ_OBJID(incedge2, l_edid) && !my_intobj->bwd)
             my_bwd2 = FALSE;
          else if(IF_EQ_OBJID(incedge2, r_edid) && !my_intobj->fwd)
             my_fwd2 = FALSE;

          commed_exists = NULL;
          objlink.S_objid = NULL_OBJID;
          stat_OM = om$get_channel_objects (objid = intedge2, osnum = thisos,
                    p_chanselect = &chan_to_common_edge, list = &objlink,
                    size = 1, count = &commed_exists);
          EMomerr_exit (stat_OM, ret_end);

          if(commed_exists) {
          other_intobj = search_and_get_intobj(&msg_loc, objlink.S_objid,
                          inters[opinx], NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

          more_info = (struct EMSsfintedpar *)other_intobj->more_info;
          l_edid = other_intobj->reversed ? more_info->next->edgeid :
                   more_info->edgeid;
          r_edid = other_intobj->reversed ? more_info->edgeid :
                   more_info->next->edgeid;

          if(IF_EQ_OBJID(incedge2, l_edid) && !other_intobj->bwd)
             other_bwd2 = FALSE;
          else if(IF_EQ_OBJID(incedge2, r_edid) && !other_intobj->fwd)
             other_fwd2 = FALSE;
           }
        } /* Here */

        if(deg_split[opinx])
         {
          intobj2 = search_and_get_intobj(&msg_loc, intedge2, inters[opinx], 
                    &ptedges, &num_ptedges, &ptedges_buf);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
         }
        else
         intobj2 = NULL;

        if(intobj1 && intobj2)
         {
          IGRushort edprops = NULL;
          IGRboolean rev_connect = FALSE;

          stat_OM = om$send(msg = message EMSedge.EMget_props(&msg_loc, 
                    &edprops), targetid = incedge1, targetos = thisos, 
                    senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);
          rev_connect = (edprops & EMED_REVERSE_CONNECT) ? TRUE : FALSE;

          if(!rev_connect)
           {
            if((intobj1->props & EMSintobj_uvdegenerate) &&
               (intobj1->props & EMSintobj_xyzdegenerate))
             rev_degen1 = TRUE;
            else
             rev_degen2 = TRUE;
           }
          if(IF_EQ_OBJID(incedge1, incedge2))
           spliting_same_edge = TRUE;
         }

        if (incloc1 != EMScvint_middle || incloc2 != EMScvint_middle ||
            !IF_EQ_OBJID (commedge, incedge2))
          {
          partol_basis.tol = sfpartolb[opinx][i][circinxj];
          stat_OM = om$send (msg = message EMSedge.EMgettopedge (&msg_loc,
                     &incpar2, &partol_basis, &tmpedge), 
                     targetid = incedge2, targetos = thisos,
                     senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (msg_loc == EMS_I_OutOfBounds, *msg, 
           EMS_E_IntersectTrim, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
          if (!IF_EQ_OBJID (tmpedge, incedge2))
            unsplit2 = FALSE;
          incedge2 = tmpedge;
          }

        /*
         * The edges on which the intersections are incident
         * are split. 
         */

         {
          skipped_split1 = FALSE;  
          found = FALSE;
          duplicate = FALSE;
          for(p = 0; p < num_comm_edges; p++) {
              if(IF_EQ_OBJID(comm_edges[p], intedge1))
                {
                found = TRUE;
                duplicate = TRUE;
                break;
                }
          }
         if((found && ((!my_fwd1 && !other_bwd1) || (!my_bwd1 && !other_fwd1)))
             ||
            (found && both_inceds_are_same1 && ((!my_bwd1 && !other_bwd1) ||
                      (!my_fwd1 && !other_fwd1))))
             {
             skipped_split1 = TRUE;
             goto Next_Split;
             }
        } /* here */
        unsplit_on_error = TRUE;
  
        stat_OM = om$construct (classname = "EMSsplit", osnum = thisos,
                   p_objid = &splitvtx);
        EMomerr_exit (stat_OM, ret_end);
  
        partol_basis.tol = sfpartolb[opinx][i][j];
        splitdir = (altinx1 == 1 ? INCOMING : OUTGOING);
        tmpedge = intedpar1->edgeid;
        tmpincloc = intedpar1->intloc;
        intedpar1->edgeid = incedge1;

        if(intobj1)
         {
          intedpar1->intloc = EMScvint_unknown;
          if(rev_degen1)
           splitdir = OUTGOING;
         }

        if(intobj1 && (intobj1->props & EMSintobj_degen_ornt_right))
          edsplit_opt = EMSplitEd_ClosureOnRight;
        else if(intobj1 && (intobj1->props & EMSintobj_degen_ornt_left))
          edsplit_opt = EMSplitEd_ClosureOnLeft;
        else edsplit_opt = NULL;

        stat_OM = om$send (msg = message EMSedge.EMsplityourself (&msg_loc,
                   &intedpar1, edsplit_opt, &splitvtx, spltedges1, &intedge1, 
                   &splitdir, NULL, &partol_basis, NULL, NULL, NULL, NULL),
                   targetid = incedge1, targetos = thisos,
                   senderid = NULL_OBJID);
        intedpar1->edgeid = tmpedge;
        intedpar1->intloc = tmpincloc;
        if (unsplit1)
          edsplit[numedsplit++] = incedge1;
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        if(msg_loc == EMS_I_AlreadySplit) 
	  spltedges1[0] = spltedges1[1] = NULL_OBJID;

	if(spliting_same_edge && IF_NULL_OBJID(unconnected_edges[0]) &&
	   IF_NULL_OBJID(unconnected_edges[1]))
	 {
	  OM_BLOCK_MOVE(spltedges1, unconnected_edges, 2*sizeof(GRobjid));
	  orig_edge_for_unconnected_edges = incedge1;
	 }
	
        if((options & EMSsfbool_opt_AdjacentRegions) &&
           (msg_loc != EMS_I_AlreadySplit) && !duplicate &&
           (((!my_fwd1 && !other_bwd1) || (!my_bwd1 && !other_fwd1)) ||
           (both_inceds_are_same1 && ((!my_bwd1 && !other_bwd1) || 
                                      (!my_fwd1 && !other_fwd1))))) 
          {
          commed_exists = NULL;
          objlink.S_objid = NULL_OBJID;
          stat_OM = om$get_channel_objects (objid = intedge1, osnum = thisos,
                    p_chanselect = &chan_to_common_edge, list = &objlink,
                    size = 1, count = &commed_exists);
          EMomerr_exit (stat_OM, ret_end);

          if(commed_exists) {
             tmp_intobj = search_and_get_intobj(&msg_loc, intedge1, 
                                     inters[opinx], NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
             thissf = tmp_intobj->this_obj_node->this_obj.objid;
                    
             tmp_intobj = search_and_get_intobj(&msg_loc, objlink.S_objid,
                                     inters[opinx], NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
             othersf = tmp_intobj->this_obj_node->this_obj.objid;
          }

          if(IF_EQ_OBJID(thissf, othersf) && commed_exists) {
          if(!num_comm_edges) {
             comm_edges = (GRobjid *) om$malloc(size = sizeof(GRobjid));
             comm_edges[num_comm_edges] = objlink.S_objid;
             num_comm_edges++;
             }
          else
             {
             num_comm_edges++;
             comm_edges = (GRobjid *) om$realloc(ptr = (IGRchar *)comm_edges,
                           size = num_comm_edges * sizeof(GRobjid));
             comm_edges[num_comm_edges - 1] = objlink.S_objid;
             }

          stat_OM = om$construct (classname = "EMSsplit", osnum = thisos,
                   p_objid = &splitvtx);
          EMomerr_exit (stat_OM, ret_end);
   
          if(splitdir == INCOMING)
             connect_splted_dir = OUTGOING;
          else connect_splted_dir = INCOMING;
          stat_OM = om$send(msg=message Root.connect(to_edges,NULL,
                        objlink.S_objid,thisos,to_owners,
                        connect_splted_dir),
                        targetid = splitvtx,
                        targetos = thisos,
                        senderid = NULL_OBJID);
          if(!(1&stat_OM)) goto ret_end;
     
          if(connect_splted_dir == INCOMING)
             connect_ed_dir = OUTGOING;
          else connect_ed_dir = INCOMING;
          stat_OM = om$send(msg=message Root.connect(to_edges,NULL,
                       spltedges1[1],thisos,to_owners,connect_ed_dir),
                        targetid = splitvtx,
                        targetos = thisos,
                        senderid = NULL_OBJID);
          if(!(1&stat_OM)) goto ret_end;
             }
          }

        Next_Split :
 
        {
          found = FALSE;
          duplicate = FALSE;
          for(p = 0; p < num_comm_edges; p++) {
              if(IF_EQ_OBJID(comm_edges[p], intedge2))
                {
                found = TRUE;
                duplicate = TRUE;
                break;
                }
          }
        if((found && ((!my_fwd2 && !other_bwd2) || (!my_bwd2 && !other_fwd2)))
                   || 
             (found && both_inceds_are_same2 && ((!my_bwd2 && !other_bwd2) ||
                                                 (!my_fwd2 && !other_fwd2)))
              || (found && skipped_split1))
             continue;
        }
        stat_OM = om$construct (classname = "EMSsplit", osnum = thisos,
                   p_objid = &splitvtx);
        EMomerr_exit (stat_OM, ret_end);

        partol_basis.tol = sfpartolb[opinx][i][circinxj];
        splitdir = (altinx2 == 1 ? INCOMING : OUTGOING);
        if (IF_EQ_OBJID (incedge1, incedge2))
          {
          stat_OM = om$send (msg = message EMSedge.EMgettopedge (&msg_loc,
                     &incpar2, &partol_basis, &tmpedge), 
                     targetid = incedge2, targetos = thisos,
                     senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (msg_loc == EMS_I_OutOfBounds, *msg, 
           EMS_E_IntersectTrim, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
          unsplit2 = FALSE;
          incedge2 = tmpedge;
          }
        tmpedge = intedpar2->edgeid;
        tmpincloc = intedpar2->intloc;
        intedpar2->edgeid = incedge2;
        if(intobj2)
         {
          intedpar2->intloc = EMScvint_unknown;
          if(rev_degen2)
           splitdir = INCOMING;
         }

        if(intobj2 && (intobj2->props & EMSintobj_degen_ornt_right))
         edsplit_opt = EMSplitEd_ClosureOnRight;
        else if(intobj2 && (intobj2->props & EMSintobj_degen_ornt_left))
         edsplit_opt = EMSplitEd_ClosureOnLeft;
        else edsplit_opt = NULL;

        stat_OM = om$send (msg = message EMSedge.EMsplityourself (&msg_loc,
                   &intedpar2, edsplit_opt, &splitvtx, spltedges2, &intedge2, 
                   &splitdir, NULL, &partol_basis, NULL, NULL, NULL, NULL),
                   targetid = incedge2, targetos = thisos,
                   senderid = NULL_OBJID);
        intedpar2->edgeid = tmpedge;
        intedpar2->intloc = tmpincloc;
        if (unsplit2)
          edsplit[numedsplit++] = incedge2;
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        if(msg_loc == EMS_I_AlreadySplit) 
	  spltedges2[0] = spltedges2[1] = NULL_OBJID;

        if((options & EMSsfbool_opt_AdjacentRegions) &&
           (msg_loc != EMS_I_AlreadySplit) && !duplicate &&
           (((!my_fwd2 && !other_bwd2) || (!my_bwd2 && !other_fwd2)) ||
           (both_inceds_are_same2 && ((!my_bwd2 && !other_bwd2) || 
                                      (!my_fwd2 && !other_fwd2)))))
          {
          commed_exists = NULL;
          objlink.S_objid = NULL_OBJID;
          stat_OM = om$get_channel_objects (objid = intedge2, osnum = thisos,
                   p_chanselect = &chan_to_common_edge, list = &objlink,
                   size = 1, count = &commed_exists);
          EMomerr_exit (stat_OM, ret_end);

          if(commed_exists) {
             tmp_intobj = search_and_get_intobj(&msg_loc, intedge2,
                                     inters[opinx], NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
             thissf = tmp_intobj->this_obj_node->this_obj.objid;

             tmp_intobj = search_and_get_intobj(&msg_loc, objlink.S_objid,
                                     inters[opinx], NULL, NULL, NULL);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
             othersf = tmp_intobj->this_obj_node->this_obj.objid;
          }

          if(IF_EQ_OBJID(thissf, othersf) && commed_exists) {
          if(!num_comm_edges) {
             comm_edges = (GRobjid *) om$malloc(size = sizeof(GRobjid));
             comm_edges[num_comm_edges] = objlink.S_objid;
             num_comm_edges++;
             }
          else
             {
             num_comm_edges++;
             comm_edges = (GRobjid *) om$realloc(ptr = (IGRchar *)comm_edges,
                           size = num_comm_edges * sizeof(GRobjid));
             comm_edges[num_comm_edges - 1] = objlink.S_objid;
             }

          stat_OM = om$construct (classname = "EMSsplit", osnum = thisos,
                   p_objid = &splitvtx);
          EMomerr_exit (stat_OM, ret_end);

          if(splitdir == INCOMING)
             connect_splted_dir = OUTGOING;
          else connect_splted_dir = INCOMING;
          stat_OM = om$send(msg=message Root.connect(to_edges,NULL,
                        objlink.S_objid,thisos,to_owners,
                        connect_splted_dir),
                        targetid = splitvtx,
                        targetos = thisos,
                        senderid = NULL_OBJID);
          if(!(1&stat_OM)) goto ret_end;

          if(connect_splted_dir == INCOMING)
             connect_ed_dir = OUTGOING;
          else connect_ed_dir = INCOMING;
          stat_OM = om$send(msg=message Root.connect(to_edges,NULL,
                        spltedges2[1],thisos,to_owners,
                        connect_ed_dir),
                        targetid = splitvtx,
                        targetos = thisos,
                        senderid = NULL_OBJID);
          if(!(1&stat_OM)) goto ret_end;
             }
          }

        if (incloc1 == EMScvint_middle && incloc2 == EMScvint_middle &&
            *intedpar1->info == p_loopdata[opinx]->commed_k_exists &&
            *intedpar2->info == p_loopdata[opinx]->commed_k_exists)
          {
	   if(spliting_same_edge)
	    {
	     if(IF_EQ_OBJID(unconnected_edges[0], spltedges1[0]))
	      spltedges1[0] = spltedges1[1] = NULL_OBJID;
	     else
	      {
	       /* The unconnected edges we are going to common edge connect
	          should have come by spliting the common edge of the current
	          edge being split.
	       */
	       stat_OM = om$is_objid_on_channel(objid_c = incedge1, 
	                 osnum_c = thisos, 
	                 p_chanselect = &chan_to_common_edge, 
	                 objid = orig_edge_for_unconnected_edges, 
	                 osnum2 = thisos);
	       if(stat_OM == OM_S_SUCCESS)
	        {
		 IGRushort edprops = NULL;
		 
		 stat_OM = om$send(msg = message EMSedge.EMget_props(&msg_loc, 
		           &edprops), targetid = incedge1, targetos = thisos, 
		           senderid = NULL_OBJID);
                 EMomerr_exit (stat_OM, ret_end);
                 EMerr_hndlr (EMSerror(msg_loc),*msg,EMS_E_EdgeError, ret_end);
		 if(edprops & EMED_REVERSE_CONNECT)
		  {
		   spltedges2[0] = unconnected_edges[1];
		   spltedges2[1] = unconnected_edges[0];
		  }
		 else
		  OM_BLOCK_MOVE(unconnected_edges, spltedges2,
		                2*sizeof(GRobjid));
		
		 unconnected_edges[0] = unconnected_edges[1] = NULL_OBJID;
		 orig_edge_for_unconnected_edges = NULL_OBJID;
	        }
	       else
	        {
		 stat_OM = OM_S_SUCCESS;
		 *msg = EMS_E_EdgeError;
		 goto ret_end;
	        }
	      }
	    }
	
	   if(!IF_NULL_OBJID(spltedges1[0]) && !IF_NULL_OBJID(spltedges2[0]))
	    {
             stat_OM = om$send (msg = message Root.connect(chan_to_common_edge,
                       0, spltedges1[0], thisos, chan_to_common_edge,
                       0), targetid = spltedges2[0], targetos = thisos,
                       senderid = NULL_OBJID);
             EMomerr_exit (stat_OM, ret_end);
            }
	   if(!IF_NULL_OBJID(spltedges1[1]) && !IF_NULL_OBJID(spltedges2[1]))
	    {
             stat_OM = om$send (msg = message Root.connect(chan_to_common_edge,
                       0, spltedges1[1], thisos, chan_to_common_edge,
                       0), targetid = spltedges2[1], targetos = thisos,
                       senderid = NULL_OBJID);
             EMomerr_exit (stat_OM, ret_end);
            }
          }
        }
      }
    }

 /* stop timer for splitting of incident edges */
  if (_use_timers)
    stop_timer (T2_SPLIT_EDGES, FALSE, "");


  /*
   * STAGE 3:
   * The creation and/or splitting of edges has been accomplished at this
   * stage. Also the topology (adjacency of edges) is in place. The new
   * loops are now closed off (if required) and nested into their loopsets.
   *
   * The nett number of surfaces changed along with loops that were added
   * to them are recorded. Also recorded is the number of loops added
   * per surface and the object-id of the surface onto which these
   * loops were added.
   *
   * After all loops have been closed off, the original edges that got
   * split are sent an "unsplit" message. This message has the effect of
   * producing a situation in which both the old and the present state can
   * 'comfortably' coexist. This message works only after all loops have been
   * closed-off on a given surface.
   */

  if (status_str)
    {
    strcat (status_str, dot);
    ex$message(in_buff = status_str, field = ERROR_FIELD)
    }
  
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  EMomerr_exit (stat_OM, ret_end);

/* start timer for close loops */
  if (_use_timers)
    start_timer (T2_CLOSE_LOOPS);

  numsfsadd = 0;

/* Begin nesting for Trim Composite functionality */

  for (opinx=FIRST; opinx<opinxlim; opinx++)
    {
    for (i=0; i<num_grps[opinx]; i++)
      {
      inxlim = num_subgrps_grp[opinx][i];
      for (j=0, k=0; j<inxlim; j++, k+=2)
        {
        partol_basis.tol = sfpartolb[opinx][i][j];

        stat_OM = om$get_channel_objects (objid = loop_sf[opinx][i][k+1],
                   osnum = thisos, p_chanselect = &chan_to_loopset,
                   list = &objlink, size = 1, count = &count);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = om$send (msg = message EMSloop.EMcloseyourself (&msg_loc,
                   NULL, &used_up, &partol_basis),
                   targetid = loop_sf[opinx][i][k], targetos = thisos,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

        if (used_up)
          {
          EMmkownlist (&msg_loc, &sfmodloops, loop_sf[opinx][i][k+1], NULL,
           loop_sf[opinx][i][k], FALSE, &list_extended);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

          if (list_extended)
            numsfsadd++;
          }
        if (used_up) {
            stat_OM = om$send(msg = message EMSloop.EMgivenestinfo
                                         (&msg_loc, &temp_nesting),
                                         targetid=loop_sf[opinx][i][k],
                                         targetos = thisos,
                                         senderid = NULL_OBJID);
            EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);

            stat_OM = om$send(msg=message EMSloopset.EMnesting
                                (&msg_loc,&temp_nesting,&partol_basis),
                        targetid = objlink.S_objid,
                        targetos = thisos,
                        senderid = NULL_OBJID);
            EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopsetError,ret_end);

            if(IF_EQ_OBJID(objlink.S_objid,temp_nesting.parent) &&
               msg_loc != EMS_I_Ambiguous)
              {
              stat_OM = om$send(msg=message EMSloopset.EMtreemod
                                (&msg_loc,&temp_nesting,
                                 ADD_CHILD,&partol_basis),
                                 targetid = temp_nesting.parent,
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
              EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopsetError,ret_end);
              }
            else if(msg_loc == EMS_I_Ambiguous) {
                    ambiguity = TRUE;

             if(!IF_EQ_OBJID(objlink.S_objid,temp_nesting.parent)) {
             stat_OM = om$send(msg = message EMSloop.EMget_props(&msg_loc,
                              &parent_props),
                              targetid = temp_nesting.parent,
                              targetos = thisos,
                              senderid = NULL_OBJID);
                              }
             stat_OM = om$send(msg = message EMSloop.EMget_props(&msg_loc,
                              &son_props),
                              targetid = temp_nesting.loopid,
                              targetos = thisos,
                              senderid = NULL_OBJID);

             if((IF_EQ_OBJID(objlink.S_objid,temp_nesting.parent) && 
                !(parent_props & EMLP_EXTERNAL) && (son_props & EMLP_PLOOP))||
                ((parent_props & EMLP_PLOOP) && (son_props & EMLP_PLOOP))) {
                                depth = 2;
                                buf_size = 0;
                                count = 0;
              if(IF_EQ_OBJID(objlink.S_objid,temp_nesting.parent)) {
                 stat_OM = om$send(msg=message EMSloopset.EMget_loops
                               (&msg_loc,EMS_OPT_UNSPLIT,&depth,&loopids,&props,
                               &buf_size,(IGRint *)&count),
                               targetid = temp_nesting.parent,
                               targetos = thisos,
                               senderid = NULL_OBJID);
                               }
              else {   
              stat_OM = om$send(msg=message EMSloop.EMget_loops
                               (&msg_loc,EMS_OPT_UNSPLIT,&depth,&loopids,&props,
                               &buf_size,(IGRint *)&count),
                               targetid = temp_nesting.parent,
                               targetos = thisos,
                               senderid = NULL_OBJID);
                   }
              if(count > 1) {
              for(m=0;m<count;m++)
                 {
                 if(!IF_EQ_OBJID(loopids[m],temp_nesting.parent))
                   {
               stat_OM = om$send(msg = message EMSloop.EMgivenestinfo
                                (&msg_loc,&nesting),
                                targetid = loopids[m],
                                targetos = thisos,
                                senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);

               stat_OM = om$send(msg = message EMSloop.EMnesting
                                (&msg_loc,&nesting,&partol_basis),
                                 targetid = loop_sf[opinx][i][k],
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);

               if(IF_EQ_OBJID(nesting.parent,loop_sf[opinx][i][k]) ||
                  (msg_loc == EMS_I_Ambiguous && 
                   !IF_EQ_OBJID(nesting.parent, loopids[m])))
                {
                  temp_nesting.parent = loopids[m];
                  stat_OM = om$send(msg = message EMSloop.EMtreemod
                                 (&msg_loc,&temp_nesting,
                                 ADD_CHILD,&partol_basis),
                                 targetid = loopids[m],
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);

               break;
                  }
                }
              }
            }
            else if(count ==1 && (parent_props & EMLP_EXTERNAL)) { 
                   /* An external P-loop parent without any children and a
                      coinciding sun P-loop */

                 stat_OM = om$send(msg=message EMSloop.EMtreemod
                               (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                 targetid = temp_nesting.parent,
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
                 }
          }

         /* Catch the Culprit here...............................*/

          else if(!IF_EQ_OBJID(objlink.S_objid,temp_nesting.parent) &&
                  (parent_props & EMLP_PLOOP) && !(parent_props & EMLP_EXTERNAL)
                  && !(son_props & EMLP_PLOOP)) {
                stat_OM = EMmake_chanselect(EMSloop_to_outter,&to_outter);
                EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);

                stat_OM = om$get_channel_objects (objid = temp_nesting.parent,
                          osnum = thisos, p_chanselect = &to_outter,
                          list = &grand_parent, size = 1, count = &count);
                          EMomerr_exit (stat_OM, ret_end);
 
                if(!IF_EQ_OBJID(objlink.S_objid,grand_parent.S_objid)) {
                stat_OM = om$send(msg = message EMSloop.EMget_props(&msg_loc,
                              &granpa_props),
                              targetid = grand_parent.S_objid,
                              targetos = thisos,
                              senderid = NULL_OBJID);
                   }

                if(IF_EQ_OBJID(objlink.S_objid,grand_parent.S_objid) ||
                   (granpa_props & EMLP_PLOOP)) 
                  {
                  save_parent_loop = temp_nesting.parent;
                  temp_nesting.parent = temp_nesting.loopid;
                  stat_OM = om$send(msg = message EMSloop.EMtreemod
                             (&msg_loc,&temp_nesting,CHG_PARENT,&partol_basis),
                                targetid = save_parent_loop,
                                targetos = thisos,
                                senderid = NULL_OBJID);
                EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);

                   temp_nesting.parent = grand_parent.S_objid;

                   if(IF_EQ_OBJID(objlink.S_objid,grand_parent.S_objid)) {
                   stat_OM = om$send(msg = message EMSloopset.EMtreemod
                             (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                targetid = grand_parent.S_objid,
                                targetos = thisos,
                                senderid = NULL_OBJID);
                EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
                          } 
                   else {
                   stat_OM = om$send(msg = message EMSloop.EMtreemod
                             (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                targetid = grand_parent.S_objid,
                                targetos = thisos,
                                senderid = NULL_OBJID);
                EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
                       }                 
                 }
              else {
                stat_OM = om$send(msg = message EMSloop.EMtreemod
                             (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                targetid = temp_nesting.parent,
                                targetos = thisos,
                                senderid = NULL_OBJID);
                EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
              }
            }
         else if(!IF_EQ_OBJID(objlink.S_objid,temp_nesting.parent) &&
                 !(parent_props & EMLP_PLOOP) && (son_props & EMLP_PLOOP)) {
                stat_OM = EMmake_chanselect(EMSloop_to_inner,&to_inner);
                EMerr_hndlr(!(1&stat_OM),*msg,EMS_E_OMerror,ret_end);

                stat_OM = om$get_channel_objects (objid = temp_nesting.parent,
                   osnum = thisos, p_chanselect = &to_inner,
                   list = &child_loop, size = 1, count = &count);
                EMomerr_exit (stat_OM, ret_end);

                temp_nesting.parent = child_loop.S_objid;
                stat_OM = om$send(msg=message EMSloop.EMtreemod
                               (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                 targetid = temp_nesting.parent,
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
                EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
                }
         else /* Add child when the External loop is the coinciding parent */
              {
              stat_OM = om$send(msg=message EMSloop.EMtreemod
                               (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                 targetid = temp_nesting.parent,
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
              }      
         } /* End ambguity .... End of all troubles */

         else /* No ambiguity....No trouble! */
            {
              stat_OM = om$send(msg=message EMSloop.EMtreemod
                               (&msg_loc,&temp_nesting,ADD_CHILD,&partol_basis),
                                 targetid = temp_nesting.parent,
                                 targetos = thisos,
                                 senderid = NULL_OBJID);
               EMerr_hndlr(!(1&msg_loc&stat_OM),*msg,EMS_E_LoopError,ret_end);
              }
            }
          }
        }
      } /* End nesting for Trim Composite */

  EMerr_hndlr (! numsfsadd, *msg, EMS_E_Fail, ret_end);
  num_loopsadd = (IGRint *) om$malloc (size = numsfsadd * sizeof (IGRint));
  objid_sfsadd = (GRobjid *) om$malloc (size = numsfsadd * sizeof (GRobjid));
  EMerr_hndlr (! num_loopsadd || ! objid_sfsadd, *msg,
   EMS_E_NoDynamicMemory, ret_end);

  /* stop timer for close loops */
  if (_use_timers)
    stop_timer (T2_CLOSE_LOOPS, FALSE, "");


  /* start timer for unsplit edges */
  if (_use_timers)
    start_timer (T2_UNSPLIT_EDGES);

  totnumloops_in = 0;
  ownlist = sfmodloops;
  for (i=0; i<numsfsadd; i++)
    {
    totnumloops_in += (num_loopsadd[i] = ownlist->num_comps);
    objid_sfsadd[i] = ownlist->owner;
    ownlist = ownlist->next;
    }

  for (i=0; i<numedsplit; i++)
    {
    stat_OM = om$send (msg = message EMSedge.EMunsplityourself 
               (&msg_loc, NULL), targetid = edsplit[i], targetos = thisos,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    }
  if (edsplit)
    {
    om$dealloc (ptr = edsplit);
    edsplit = NULL;
    }

  /* stop timer for unsplit edges */
  if (_use_timers)
    stop_timer (T2_UNSPLIT_EDGES, FALSE, "");


  /*
   * STAGE 4:
   * Those boundary loops on the two solids that are not part of
   * this new solid should be removed from the surfaces loop-set. Also,
   * every surface that is no longer a part of this Boolean-solid should
   * be removed. All the surfaces that have been altered (had some 
   * intersection on them) is sent a "cleanup" message. The removed objects
   * (loops and surfaces) are appended/returned in two separate linked-lists -
   * "sfmodloops" and "solrmsfs". The total number of surfaces and loops
   * removed in this process is then computed for use in the next
   * stage.
   *
   * A pre-processing step is involved if the option to process "adjacent
   * regions" has been set. Here, we would like to locate the loop(s)
   * that are produced by EMSintobjs that have been "marked" and preserve
   * such loops as forming part of the area region. By traversing the
   * composite surface topology, we further would like the alternating regions
   * to be treated as "holes". The way this is achieved is by removing
   * those newly created loops that become part of the "hole" region and
   * maintaining the state of the system as if these were never created.
   * The effect should be the same as if the EMSintobjs that were responsible
   * for making these "hole" loops were never present in the first place.
   * This means that the "sfmodloops" linked-list and the "num_loopssadd"
   * array must have the information about these "removed" loops purged
   * from them.
   * 
   * Also, the feature loops on the surface to which the cleanup message is
   * sent must now be updated w.r.t. the new loopset. Feature loops may
   * be removed and/or added by this operation. The control information
   * regarding loop changes must also be updated.
   */

  /*start timer for cleanup and update features*/
  if (_use_timers)
    start_timer (T2_CLEANUP);

  if (status_str)
    {
    strcat (status_str, dot);
    ex$message(in_buff = status_str, field = ERROR_FIELD)
    }

  /*
     Toggling the loop types. It is an irony that this is required here.
     Sometimes, depending on the order of input of the curves, an ambiguous
     situation still persists, despite the above special nesting undertaken
     for 'coincident loops' case.  The loop-tree is toggled vertically to
     remove any inconsistencies in the P-C-P.... sequence.  This is done
     only if the ambuiguous situation is spotted. The local nesting flags off
     this condition.
  */

     if(ambiguity)
     {
     IGRint numtogloops;
     IGRushort outlp_props;
     GRobjid *togloops;
     OM_S_CHANSELECT to_outer;
     OM_S_OBJECT_LINKAGE outer_loop;

     stat_OM = EMmake_chanselect(EMSloopset_to_loops, &to_loops);
     EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

     stat_OM = EMmake_chanselect(EMSloop_to_outter, &to_outer);
     EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);  

     for(opinx = FIRST; opinx < opinxlim; opinx++)
     {
     for(i = 0; i < num_grps[opinx]; i++)
        {
     inxlim = num_subgrps_grp[opinx][i];  
        for(j = 0, k = 0; j < inxlim; j++, k+=2)
           {
     numtogloops = 0;
     togloops = NULL;
     outer_loop.S_objid = NULL_OBJID;  

     stat_OM = om$get_channel_objects (objid = loop_sf[opinx][i][k+1],
                              osnum = thisos, p_chanselect = &chan_to_loopset,
                              list = &objlink, size = 1, count = &count);
     EMomerr_exit(stat_OM, ret_end);

     togtype_options = EMTogType_SendInner | EMTogType_NoAction;
     stat_OM = om$send(msg = message EMSloop.EMtoggle_type
                       (&msg_loc, TRUE, FALSE, objlink.S_objid,
                        togtype_options,
                        &numtogloops, &togloops, NULL, NULL, NULL, NULL),
                        senderid = objlink.S_objid,
                        p_chanselect = &to_loops);
     EMerr_hndlr(!(1&msg_loc&stat_OM), *msg, EMS_E_LoopsetError, ret_end);

     if(numtogloops) {
     stat_OM = om$get_channel_objects (objid = togloops[0],
                              osnum = thisos, p_chanselect = &to_outer,
                              list = &outer_loop, size = 1, count = &count);
     EMomerr_exit(stat_OM, ret_end);

     if(!IF_NULL_OBJID(outer_loop.S_objid))
     {
     stat_OM = om$send(msg = message EMSloop.EMget_props(&msg_loc,
                              &outlp_props),
                              targetid = outer_loop.S_objid,
                              targetos = thisos,
                              senderid = NULL_OBJID);
     EMerr_hndlr(!(1&msg_loc&stat_OM), *msg, EMS_E_LoopError, ret_end);  
     }  

     if(!IF_NULL_OBJID(outer_loop.S_objid) && (outlp_props & EMLP_EXTERNAL) &&
        !(outlp_props & EMLP_NEW))
     continue;
     else {
     togtype_options &= ~EMTogType_NoAction;
     stat_OM = om$send(msg = message EMSloop.EMtoggle_type
                       (&msg_loc, TRUE, FALSE, objlink.S_objid,
                        togtype_options,
                        NULL, NULL, NULL, NULL, NULL, NULL),
                        senderid = objlink.S_objid,
                        p_chanselect = &to_loops);
     EMerr_hndlr(!(1&msg_loc&stat_OM), *msg, EMS_E_LoopsetError, ret_end);  
     }
   }
             } /* 2nd inner for loop */
       
          } /* 1st inner for loop */
       }
   }

  if (options & EMSsfbool_opt_AdjacentRegions) 
    for (opinx=FIRST; opinx<opinxlim; opinx++)
      for (loc_inters = inters[opinx];
           loc_inters;
           loc_inters = loc_inters->next)
        for (loc_intobj = loc_inters->cvs;
             loc_intobj;
             loc_intobj = loc_intobj->next)
          {
          if (loc_intobj->props & EMSintobj_marked)
            {
            num_loops_visited = 0;
            tmpedge = loc_intobj->this_uvintobj.data.object->objid;
            stat_OM = om$is_objid_valid(objid = tmpedge);
            
            if(stat_OM == OM_S_SUCCESS) {
            EMsend_loops (&send_msg, message EMSloop.EMremove_adjacent_holes
             (&msg_loc, EMS_O_Delete, FALSE, inters[opinx], &newrmloops,
             &num_loops_visited, &loops_visited), tmpedge, 0, 0,
             EMLP_ACTIVE, NULL, NULL);
            EMerr_hndlr (EMSerror (send_msg & msg_loc), *msg, EMS_E_LoopError,
             ret_end);
            if (loops_visited)
              {
              om$dealloc (ptr = loops_visited);
              loops_visited = NULL;
              }

            for (ownlist = newrmloops;
                 ownlist;
                 ownlist = ownlist->next)
              {
              found = FALSE;
              other_ownlist = sfmodloops;
              for (other_ownlist = sfmodloops; 
                   other_ownlist;
                   other_ownlist = other_ownlist->next)
                if (ownlist->owner == other_ownlist->owner)
                  {
                  found = TRUE;
                  break;
                  }
              EMerr_hndlr (!found, *msg, EMS_E_InvalidCase, ret_end);

              for (i=0; i<ownlist->num_comps; i++)
                {
                IGRint num_in_block = 1;               

                found = FALSE;
                for (j=0; j<other_ownlist->num_comps; j++)
                  if (ownlist->comps[i] == other_ownlist->comps[j])
                    {
                    found = TRUE;
                    break;
                    }
                EMerr_hndlr (!found, *msg, EMS_E_InvalidCase, ret_end);
                EMremove_array (&msg_loc,
                                (IGRchar *)other_ownlist->comps,
                                 other_ownlist->num_comps,
                                 sizeof (GRobjid),
                                 j,
                                 num_in_block);
          
                other_ownlist->num_comps -= num_in_block;
                }

              found = FALSE;
              for (i=0; i<numsfsadd; i++)
                if (objid_sfsadd[i] == ownlist->owner)
                  {
                  found = TRUE;
                  break;
                  }
              EMerr_hndlr (!found, *msg, EMS_E_InvalidCase, ret_end);
              num_loopsadd[i] -= ownlist->num_comps;
              }

            if (newrmloops)
              EMownercomp_free (newrmloops, MAXINT);
            newrmloops = NULL;
               } /* if intobj valid intobj */

             } /* if intobj marked */

          }   /* for each intobj */

  numsfsmod = numsfsadd;
  numsolsmod = 0;
  unsplit_on_error = FALSE;

  for (opinx=FIRST; opinx<opinxlim; opinx++)
    {
    for (i=0; i<num_grps[opinx]; i++)
      {
      inxlim = num_subgrps_grp[opinx][i];
      for (j=0, k=0; k<inxlim; j+=2, k++)
        {
        stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&send_msg,
                   message EMSloopset.EMlscleanup (&msg_loc, &numsfsmod,
                   &sfmodloops, &numsolsmod, &solrmsfs, FALSE)),
                   targetid = loop_sf[opinx][i][j+1], targetos = thisos,
                   senderid = NULL_OBJID);
	if (EMSerror (stat_OM & send_msg & msg_loc))
          {
	  undo_on_error = TRUE;
	  send_msg = EMS_S_Success;
	  msg_loc = EMS_S_Success;
	  stat_OM = OM_S_SUCCESS;
          }

        addfeats = NULL;
        numaddfeats = 0;
        partol_basis.tol = sfpartolb[opinx][i][k];
        stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&send_msg,
                   message EMSloopset.EMupdate_features (&msg_loc, &addfeats,
                   &numaddfeats, &numsfsmod, &sfmodloops, &numsolsmod, 
                   &solrmsfs, TRUE, &partol_basis)),
                   targetid = loop_sf[opinx][i][j+1], targetos = thisos,
                   senderid = NULL_OBJID);
	if (EMSerror (stat_OM & send_msg & msg_loc))
          {
	  undo_on_error = TRUE;
	  send_msg = EMS_S_Success;
	  msg_loc = EMS_S_Success;
	  stat_OM = OM_S_SUCCESS;
          }

        if (numaddfeats)
          {
          totnumloops_in += numaddfeats;
          sffound = FALSE;
          for (inx=0; inx<numsfsadd; inx++)
            {
            if (IF_EQ_OBJID (loop_sf[opinx][i][j+1], objid_sfsadd[inx]))
              {
              sffound = TRUE;
              break;
              }
            } 
          if (sffound)
            {
            num_loopsadd[inx] += numaddfeats;
            for (l=0; l<numaddfeats; l++)
              {
              EMmkownlist (&msg_loc, &sfmodloops, objid_sfsadd[inx], NULL,
               addfeats[l], EMS_O_Start, &list_extended);
              if (EMSerror (msg_loc) || list_extended)
                {
                undo_on_error = TRUE;
                msg_loc = EMS_S_Success;
                }
              }
            }
          else
            undo_on_error = TRUE;

          om$dealloc (ptr = addfeats);
          }
        }
      }
    }

  ownlist = solrmsfs;
  totnumsfs_out = 0;
  for (i=0; i<numsolsmod; i++)
    {
    totnumsfs_out += ownlist->num_comps;
    ownlist = ownlist->next;
    }
   
  ownlist = sfmodloops;
  totnumloops_out = 0;
  for (i=0; i<numsfsmod; i++)
    {
    sffound = FALSE;
    for (j=0; j<numsfsadd; j++)
      {
      if (IF_EQ_OBJID (ownlist->owner, objid_sfsadd[j]))
        {
        sffound = TRUE;
        break;
        }
      } 
    if (sffound)
      totnumloops_out += (ownlist->num_comps - num_loopsadd[j]);
    else
      totnumloops_out += ownlist->num_comps;
    ownlist = ownlist->next;
    }

  /*stop timer for cleanup and update features*/
  if (_use_timers)
    stop_timer (T2_CLEANUP, FALSE, "");


  /* STAGE 4.5:
   * Delete any point edges created during maximizing split procedure.
   * Note that this stage will not get executed in a typical case, but only
   * when the intersection was such that 2 intobjs were incedent at the same
   * location on the same edge on a surface.
   * SM 12/16/93
   */
   for(i=0; i<num_ptedges; i++)
    {
     /* Safety check, in case the loop itself got consumed during close..
     */
     if(!EFisAncestryValid(&msg_loc, ptedges[i], thisos,
         OPP_EMSptedge_class_id, TRUE))
      continue;
     stat_OM = om$send(mode = OM_e_wrt_message, 
               msg = message Root.delete(TRUE), targetid = ptedges[i], 
               targetos = thisos, senderid = ptedges[i]);
     /* Intentionally ignoring any error.
     */
    }


  /*
   * STAGE 5:
   * All the initialization needed to be performed for this object is
   * performed at this stage. The most important pieces of this phase are
   * listed below:
   *
   *   1) Unless inhibited, a save state information table is compiled;
   *      it represents the modifications made during the Boolean operation
   *      (boundary-loops that have been added/deleted and the surfaces that 
   *      have been removed). This information is explicitly stored in the 
   *      object's instance-data as a record of the Boolean operation. If 
   *      an invalid case occurs and is non-fatal, then undo this operation 
   *      at the end.
   *   2) If a difference operation was performed, the orientation of 
   *      the negative solid must be reversed.
   *   3) Unless inhibited, the two combining solids are to be connected onto
   *      this object. 
   *
   * All of the above steps are performed by the message EMboolinit invoked
   * on this object. 
   */

  if (no_save_state)
    goto End_save_state;

  /*start the save state and bool init timer */
  if (_use_timers)
    start_timer(T2_SAVE_STATE_AND_BOOLINIT);

  if (status_str)
    {
    strcat (status_str, dot);
    ex$message(in_buff = status_str, field = ERROR_FIELD)
    }
  
  size_data.bool_info.num_composites = numsolsmod;
  size_data.bool_info.num_surfaces_out = totnumsfs_out;
  size_data.bool_info.num_surfaces = numsfsmod;
  size_data.bool_info.num_regions_in = totnumloops_in;
  size_data.bool_info.num_regions_out = totnumloops_out;

  stat_OM = om$send (msg = message EMSdpr.EMgetSSIbuffer (&msg_loc,
             &size_data, &ssibuff),
             targetid = boolid->objid, targetos = thisos,
             senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  myssiinfo = &ssibuff->bool_info;
  myssiinfo->num_composites = numsolsmod;
  ownlist = solrmsfs;
  inx = 0;
  for (i=0; i<numsolsmod; i++)
    {
    myssiinfo->composite_ids[i] = ownlist->owner;
    inxlim = myssiinfo->num_surfaces_out[i] = ownlist->num_comps;
    for (j=0; j<inxlim; j++)
      {
      myssiinfo->surface_out_ids[inx] = ownlist->comps[j];
      myssiinfo->composite_indices[inx] = ownlist->ownerindex[j];
      inx++;
      }
    ownlist = ownlist->next;
    }

  myssiinfo->num_surfaces = numsfsmod;
  ownlist = sfmodloops;
  altinx1 = 0;
  altinx2 = 0;
  for (i=0; i<numsfsmod; i++)
    {
    myssiinfo->surface_ids[i] = ownlist->owner;
    sffound = FALSE;
    for (j=0; j<numsfsadd; j++)
      {
      if (IF_EQ_OBJID (ownlist->owner, objid_sfsadd[j]))
        {
        sffound = TRUE;
        break;
        }
      } 
    if (sffound)
      {
      inx = 0;
      inxlim = myssiinfo->num_regions_in[i] 
             = num_loopsadd[j];
      for (k=0; k<inxlim; k++)
        myssiinfo->region_in_ids[altinx1++] = ownlist->comps[inx++];

      inxlim = myssiinfo->num_regions_out[i]
             = (ownlist->num_comps - num_loopsadd[j]);
      for (k=0; k<inxlim; k++)
        myssiinfo->region_out_ids[altinx2++] = ownlist->comps[inx++];
      }
    else
      {
      myssiinfo->num_regions_in[i] = 0;

      inxlim = myssiinfo->num_regions_out[i] 
             = ownlist->num_comps;
      for (k=0; k<inxlim; k++)
        myssiinfo->region_out_ids[altinx2++] = ownlist->comps[k];
      }
    ownlist = ownlist->next;
    }

  surface_saveside = FALSE;
  if (boolop == EMSbool_saveside)  
    {
    stat_OM = om$get_classid (objid = boolid->objid, osnum = thisos,
               p_classid = &myclassid);
    EMomerr_exit (stat_OM, ret_end);

    if (om$is_ancestry_valid (subclassid = myclassid,
         superclassid = OPP_EMSsolid_class_id) != OM_S_SUCCESS)
      surface_saveside = TRUE;
    }
  
  { /*INTENTIONAL - get dpr_props before boolinit clears it - DLB*/
    stat_loc = om$send(msg = message EMSdpr.EMget_dpr_props(&msg_loc, 
                             &dpr_props),
                       senderid = NULL_OBJID,
                       targetid = boolid->objid, targetos = thisos);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  const_args.env_info = &loc_mdenv;
  const_args.env_info->md_env = mdenv->md_env;
  const_args.properties = NULL;
  if(options & EMSsfbool_opt_OperandsSwitched)
   {
    stat_OM = om$send (msg = message EMSsfboolean.EMboolinit (&msg_loc,
              *sfs2, numsfs2, &sf1, 
              ssibuff, &const_args, boolop),  
              targetid = boolid->objid, targetos = thisos,
              senderid = NULL_OBJID);
   }
  else
   {
    stat_OM = om$send (msg = message EMSsfboolean.EMboolinit (&msg_loc,
              sf1, (surface_saveside ? 0 : numsfs2), sfs2, 
              ssibuff, &const_args, boolop),  
              targetid = boolid->objid, targetos = thisos,
              senderid = NULL_OBJID);
   }

  if (msg_loc == EMS_I_InvalidCase)
    {
    undo_on_error = TRUE;
    msg_loc = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;
    }
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);


  /*stop the save state and bool init timer */
  if (_use_timers)
    stop_timer(T2_SAVE_STATE_AND_BOOLINIT, FALSE, "");


  /*
   * STAGE 5-1/3:
   * If a request to work the display for this operation has been received,
   * background erase those surfaces that have been removed and background
   * draw those that have been modified. The relevant surface ids are
   * obtained from the ssi-table. If no save-state is being done this
   * option is not catered to.
   */
  
   if (do_display && !no_save_state) /* Note the additional check */
     {
     dpmode = GRbehe;
     inx = 0;
     for (i=0; i<myssiinfo->num_composites; i++)
       {
       for (j=0; j<myssiinfo->num_surfaces_out[i]; j++)
         {
         found = FALSE;
         if (chkdisplist)
           for (dispinx=0; dispinx<*num_dispsfs; dispinx++)
             if ((*dispsfids)[dispinx] == myssiinfo->surface_out_ids[inx])
               {
               found = TRUE;
               break;
               }
 
         if (!found)
           {
           stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                      mattyp, mat, &dpmode, &display_env.md_id), 
                      targetid = myssiinfo->surface_out_ids[inx],
                      targetos = thisos, senderid = NULL_OBJID);
           EMomerr_exit (stat_OM, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
 
           if (chkdisplist)
             {
             EFrealloc_if_needed (&msg_loc, dispsfids, *num_dispsfs, 
              BUFF_INCR, sizeof(GRobjid));
             EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
             (*dispsfids)[*num_dispsfs]=myssiinfo->surface_out_ids[inx];
             (*num_dispsfs)++;
             }
           }
         inx++;  
         }
       }
 
     if (!dont_redraw)
       {
       dpmode = GRbd;
       for (i=0; i<myssiinfo->num_surfaces; i++)
         {
         stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                    mattyp, mat, &dpmode, &display_env.md_id),
                    targetid = myssiinfo->surface_ids[i], targetos = thisos,
                    senderid = NULL_OBJID);
         EMomerr_exit (stat_OM, ret_end);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
         }
       }
     }

  /*
   * STAGE 5-2/3:
   * The property bits - GRIS_DISPLAYABLE and GRIS_LOCATABLE are set off for
   * all the surfaces removed. All the loops removed are set to inactive.
   * If the operation is save side and we are not dealing with a solid then
   * set the save side plane to be non locatable and non displayable and
   * place it on the end of the vla.
   */

   inx = 0;
   for (i=0; i<myssiinfo->num_composites; i++)
     {
     for (j=0; j<myssiinfo->num_surfaces_out[i]; j++)
       {
       EFsetsfstate (&msg_loc, myssiinfo->surface_out_ids[inx],
        thisos, EMS_O_OFF);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

       stat_OM = om$send(msg = message EMSsubbs.EMpassloop(&send_msg, 
                  message EMSloopset.EMtoglpactive(&msg_loc)),
                  targetid = myssiinfo->surface_out_ids[inx++],
                  targetos = thisos, senderid = NULL_OBJID);
       EMomerr_exit (stat_OM, ret_end);
       EMerr_hndlr (EMSerror (send_msg) || EMSerror(msg_loc), *msg,
        EMS_E_SurfaceError, ret_end);
       }
     }

   if (surface_saveside)
     {
     EFsetsfstate (&msg_loc, sfs2[0], thisos, EMS_O_OFF);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

     myriinfo.plane_id = sfs2[0];
     stat_OM = om$send (msg = message EMSdpr.EMputRI (&msg_loc, 
                (union EMSri_table *) &myriinfo), targetid = boolid->objid,
                targetos = thisos, senderid = NULL_OBJID);
     EMomerr_exit (stat_OM, ret_end);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
     }

    /* Newly added */

  /*
   * If the "no_save_state" option was chosen, then some of the operations
   * performed within may have to be done locally here. The reversal of a
   * "difference" orientation is done locally. The topology of the surfaces
   * is compressed.
   */

  End_save_state:
  if (no_save_state)
    {
    if (boolop == EMSbool_difference || boolop == EMSbool_saveside)
      for (i=0; i<numsfs2; i++)
        om$send (msg = message EMSsurface.EMrevorient (&msg_loc),
         senderid = NULL_OBJID, targetid = sfs2[i], targetos = thisos);

    om$send (msg = message EMSsurface.EMcompress_top (&msg_loc, mdenv),
     senderid = NULL_OBJID, targetid = sf1, targetos = thisos);
    if (!op1_only)
      for (i=0; i<numsfs2; i++)
        om$send (msg = message EMSsurface.EMcompress_top (&msg_loc, mdenv),
         senderid = NULL_OBJID, targetid = sfs2[i], targetos = thisos);
    }                             /* Here it ends */
  
ret_end:
  /*
   * If the processing has completed "successfully" but with some error at
   * some stage which would require an "undo" to be performed for recovery,
   * (eg: errorneous cleanup), perform the undo. If the no-save-state option
   * was on, this cannot be done.
   */

  if (undo_on_error && !EMSerror(*msg) && !no_save_state)
    {
    IGRushort undo_option;
    IGRint num_dispsfs = 0, invoke_count = 0;
    GRobjid *dispsfids = NULL;

    *msg = EMS_E_Fail;
    stat_OM = OM_E_ABORT;

    undo_option = EMS_UNDO_DELETE | EMS_UNDO_DONTDELME | EMS_DO_DISPLAY;

    if (dpr_props & EMS_UNEVAL_STATE)  /*added check for recompute - DLB*/
      undo_option |= (EMS_UNDO_DONTCLEANOWN | EMS_UNDO_DONTDISCONCOMPS);    

    stat_loc = om$send (msg = message EMSdpr.EMundo (&msg_loc, &undo_option, 
                mdenv, NULL, NULL, NULL, &dispsfids, &num_dispsfs,
                &invoke_count), targetid = boolid->objid, targetos = thisos,
                senderid = NULL_OBJID);
    if (EMSerror (stat_loc & msg_loc))
      *msg = EMS_F_Fail;
    }

  /* 
   * If the processing was unsuccessfully aborted and at a stage requiring
   * the edges and loops to be unsplit for recovery, call the function to
   * perform this task. Such a condition arises if the abort was
   * after some splitting of edges has started but before the cleanup.
   * Also, no fatal errors should have occurred before this point.
   */

  if (unsplit_on_error && EMSerror (*msg & stat_OM) && 
      EMS_SeverityLevel (*msg) != FATL)
    {
    GRobjid *new_loops = NULL;
    IGRint num_new_loops = 0;

    *msg = EMS_E_Fail;
    stat_OM = OM_E_ABORT;

    for (opinx=FIRST; opinx<opinxlim; opinx++)
      {
      if (!sfintloops_alloced[opinx]) 
        continue;
      for(i=0; i<num_grps[opinx]; i++) 
	num_new_loops += num_subgrps_grp[opinx][i];
      }
    if (num_new_loops)
      new_loops = (GRobjid *)om$malloc(size = num_new_loops * sizeof(GRobjid));

    num_new_loops = 0;
    if (new_loops)
      for (opinx=FIRST; opinx<opinxlim; opinx++)
        {
        if (!sfintloops_alloced[opinx]) 
          continue;
        for (i=0; i<num_grps[opinx]; i++)
	  for (k=0; k < 2 * num_subgrps_grp[opinx][i]; k+=2)
            new_loops[num_new_loops++] = loop_sf[opinx][i][k];
        }
    stat_loc = EMsplit_graceful_exit (&msg_loc, numedsplit, edsplit, 
                num_new_loops, new_loops);
    if (new_loops)
      om$dealloc (ptr = new_loops);

    /* 
     * The surfaces that were modified have been erased and not redrawn after
     * that. So redraw them again.
     */

    if (!EMSerror (msg_loc & stat_loc) && do_display)

       /*DLB 1/15/90 */
/*   stat_loc = booldisplay (&msg_loc, GRbd, num_dispsfs, dispsfids, 
       inters, chkdisplist, mattyp, mat, &display_env.md_id); */

    	/* Fix for TR 91n0161 */
        stat_loc = booldisplay (&msg_loc, GRbd, num_dispsfs, dispsfids,
		chkdisplist, opinxlim, inters, mattyp, mat, &display_env.md_id);

    if (EMSerror (msg_loc & stat_loc))
      *msg = EMS_F_Fail;
    }

  /*
   * Free up all the memory that has been dynamically allocated by this
   * method for local purposes.
   */

  for (opinx=FIRST; opinx<opinxlim; opinx++)
    if ((opinx == FIRST ? !sf1_loopdata : !sfs2_loopdata) && 
        sfintloops_alloced[opinx])
      {
      EMsfintloops_data_free (num_grps[opinx], num_subgrps_grp[opinx],
       loop_sf[opinx], thisos);
         
      EMsfintloops_free (loop_sf[opinx], endedges[opinx], intedpars[opinx],
       sfpartolb[opinx]);
      }

    EMinters_data_free (&msg_loc, sf1_inters, MAXINT, NULL,
                        EMsfintedpar_free);
    EMinters_free (sf1_inters, MAXINT);
    EMsfinttrace_free (&msg_loc, sf1_tracedata->num_grps,
                       sf1_tracedata->num_subgrps_grp,
                       sf1_tracedata->num_elems_subgrp,
                       sf1_tracedata->elems,
                       sf1_tracedata->subgrp_rev,
                       sf1_tracedata->elem_rev,
                       sf1_tracedata->grp_closed,
                       sf1_tracedata->subgrp_closed);

  if (sfmodloops)
    EMownercomp_free (sfmodloops, MAXINT);
  if (solrmsfs)
    EMownercomp_free (solrmsfs, MAXINT);
  if (newrmloops)
    EMownercomp_free (newrmloops, MAXINT);

  if (num_loopsadd)
    om$dealloc (ptr = num_loopsadd);
  if (objid_sfsadd)
    om$dealloc (ptr = objid_sfsadd);

  if (edsplit)
    om$dealloc (ptr = edsplit);
  if (loops_visited)
    om$dealloc (ptr = loops_visited);

  if (ssibuff)
    om$dealloc (ptr = ssibuff);

  if(ptedges)
    om$dealloc (ptr = ptedges);

  /*
   * If the notification had to be performed and there were no errors
   * do the post-processing.
   */

  if (notify)
    {
    if (!EMSerror (*msg) && !undo_on_error)
      {
      EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);  

      count = 0;
      om$get_channel_count (objid = boolid->objid,
       p_chanselect = &chan_to_comps, count = &count);

      for (i=0; i<count; i++)
        om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
         EMS_POST_SAVEDSTATE | (i == FIRST ? NULL : EMS_POST_NOCOMPONENTS), 
         mdenv, NULL, NULL), from = i, to = i, p_chanselect = &chan_to_comps,
         senderid = NULL_OBJID);
      }
    EMrestore_postproc();
    }

  if (EMS_SeverityLevel (*msg) == FATL)
    {
    EMWRAPUP (*msg, stat_OM, "EMboolean_func FATAL");
    }

  if (EMSerror (*msg) && !EMSerror (stat_OM))
    stat_OM = OM_E_ABORT;
  else if (EMSerror (stat_OM) && !EMSerror (*msg))
    *msg = EMS_E_OMerror;

  /* STOP TIMER */
  if (_use_timers)
     stop_timer  (T_EMBOOLEAN_SURFACES_W_INTERSECTION, FALSE, "");

  return (stat_OM);
}





/*
 * Locally used function to perform the display (erase) of modified
 * surfaces during the Boolean operation.
 */

static IGRlong booldisplay (msg, dpmode,
                            numsfs, sfids, chkid,
                            num_lists, intlists, 
                            mattyp, mat, md_id)
IGRlong *msg;
enum GRdpmode dpmode;
IGRint *numsfs;
GRobjid **sfids;
IGRint num_lists;
struct EMSinters **intlists;
IGRboolean chkid;
IGRshort *mattyp;
IGRdouble *mat;
struct GRid *md_id;
{
  IGRint listinx, dispinx;
  IGRboolean found;
  GRspacenum os;
  struct EMSinters *inters_loc;
  IGRlong stat_OM, msg_loc;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  os = intlists[FIRST]->this_obj.osnum;
  for (listinx=FIRST; listinx<num_lists; listinx++)
    {
    inters_loc = intlists[listinx];
    while (inters_loc)
      {
      found = FALSE;
      if (chkid) 
        for (dispinx=0; dispinx<*numsfs; dispinx++)
          if ((*sfids)[dispinx] == inters_loc->this_obj.objid)
            {
            found = TRUE;
            break;
            }
  
      if (!found)
        {    
        stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                   mattyp, mat, &dpmode, md_id), 
                   targetid = inters_loc->this_obj.objid, targetos = os,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
 
        if (chkid)
          {
          EFrealloc_if_needed (&msg_loc, sfids, *numsfs, BUFF_INCR,
           sizeof(GRobjid));
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
          (*sfids)[*numsfs] = inters_loc->this_obj.objid;
          (*numsfs)++;
          }
        }
      inters_loc = inters_loc->next;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMboolean_func booldisplay");
  return(stat_OM);
}


static struct EMSintobj *search_and_get_intobj(EMmsg, intedge, inters, ptedges,
                                               num_ptedges, ptedges_buf)
IGRlong *EMmsg;
GRobjid intedge;
struct EMSinters *inters;
GRobjid **ptedges;
IGRint *num_ptedges, *ptedges_buf;
{
 struct EMSinters *this_inters = NULL;
 struct EMSintobj *this_intobj = NULL, *intobj = NULL;
 struct EMSdataselect *this_uv = NULL;
 struct GRid *this_obj = NULL;
 IGRlong rc;

 *EMmsg = EMS_S_Success;
 this_inters = inters;
 while(this_inters)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     if(!ptedges) {
       if(IF_EQ_OBJID(intedge, 
                      this_intobj->this_uvintobj.data.object->objid)){   
       intobj = this_intobj;
       break;
       }
       else goto NextIntobj;
     }  
     if( (!(this_intobj->props & EMSintobj_degen_ornt_right)) &&
         (!(this_intobj->props & EMSintobj_degen_ornt_left)))
       goto NextIntobj;

     this_uv = &this_intobj->this_uvintobj;
     if(this_uv->datatype != EMSdata_object)
      goto NextIntobj;
 
     this_obj = this_uv->data.object;
     if(!this_obj) 
      goto NextIntobj;

     if(this_obj->objid != intedge)
      goto NextIntobj;


     intobj = this_intobj;
     if(EFisAncestryValid(&rc, this_obj->objid, this_obj->osnum, 
        OPP_EMSptedge_class_id, TRUE))
      {
       if(!(*ptedges_buf))
        {
	 if(!(*ptedges))
	  *ptedges = (GRobjid *) om$malloc(size = PtEdgeBuf * sizeof(GRobjid));
	 else
	  *ptedges = (GRobjid *) om$realloc(ptr = (IGRchar *) *ptedges, 
	             size = sizeof(GRobjid) * (*num_ptedges + PtEdgeBuf));
	 if(!*ptedges)
	  {
           *EMmsg = EMS_E_NoDynamicMemory;
           goto wrapup;
	  }
	 *ptedges_buf = PtEdgeBuf;
        }

       (*ptedges)[*num_ptedges] = this_obj->objid;
       (*num_ptedges)++;
       (*ptedges_buf)--;
      }
     break;

NextIntobj:
     this_intobj = this_intobj->next;
    }

   if(intobj)
    break;
   this_inters = this_inters->next;
  }

wrapup:
return(intobj);
}

end implementation EMSsfboolean;
                            
