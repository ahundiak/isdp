/*
 DESCRIPTION

   This function accepts the traced and oriented intersection data between
   two surfaces. The intersections must contain uv-edge objects for
   uv-data. It does the following - 
    1) Validates the data based on following criteria - 
        o Endpoints of subgroups must end on some valid existing edges
          (incident edges). If a subgroup end is dangling, an attempt is made 
          to fix it, provided it is within 2*chord_height_tol from the nearest
          boundary in model space.
        o The incidence location on a pair of common edges must be similar
          (middle-middle or end-end).
        o If the incidence location is end-end, the corresponding ends of the
          common edges must form a vertex. An exception to this rule exists:
          If the vertices lie on the same surface this indicates that the 
          loop(s) of this surface touch internally at this vertex point.
          This may still produce a valid result.
        o If the incidence location is middle-middle (the only other possible
          valid case), the subgroup continuity must be consistent with the
          corresponding incident edges being common edges.
    2) Returns appropriate error if the data is found to be invalid.
    3) Optionally creates topology objects (loops and edges) and 
       outputs the following pieces of information -
        o surface-loop pairs
        o end information for each loop created
        o parametric tolerance for each surface
        o total number of edges to be split on each input operand.

    The output can be used to directly drive the Boolean function along
    with the intersection list and the trace data.

  ARGUMENTS

    msg			- Output: Message return code.
    mdenvinfo		- Input: Information about the module matrix in which
			   the surfaces reside.
    sf1_inters,		- Input: The intersection lists for the surfaces.
    sf2_inters             sf2_inters could be NULL.
    sf1_tracedata,	- Input: The trace information for the surfaces.
    sf2_tracedata          sf2_tracedata could be NULL.
    options		- Input: Options used to change the default
			   characteristics of this function: 
			    EMSsfbool_opt_SingleTopology
                            EMSsfbool_opt_ValidateAllData 
                            EMSsfbool_opt_ConnectToComEdge
                           are currently the possible options.
			   See emssfintdef.h
    sf1_loopdata,	- Output: Either or both could be NULL. This argument
    sf2_loopdata	   if non-NULL must point to an EMSsfintloopsdata
			   structure. The output arrays are returned here.

  RETURN VALUES

    On successful completion
     - EMS_S_Success

    On error, one fo the following
     - EMS_E_IntersectTrim, the intersection data has failed the topological
        test in some way.
     - EMS_E_Fail, unspecific failure.

  HISTORY

    SM	11-Jul-89  Created this function from the code
                   which used to be in the function 
                   EMboolean_surfaces_w_intersection().
                   Modified it some to output the data, 
                   use commed_k_exists variable from the structure etc.
    SS  19-Jul-89  Changed the argument list and rearranged the code
                   and comments a little bit.
  Inasu 17-Aug-91  Added a the new flag EMSsfbool_opt_ConnectToComEdge to
                   options.
    NP  27-Aug-92  Modified for ANSI compliance.
    NP  02-Jun-93  Option to check common edge connections is NOT set to FALSE
                   unconditionally for the second set of trace data (operand 2).
                   See comments just before EMsfintloops call for more details .
*/

class implementation EMSsurface;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
  
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

from EMSedge import EMendpts, EMfind_commvtx, EMget_props;
from EMSloopset import EMpt_location;
from EMSsubbs import EMpassloop;

%safe
static IGRboolean degelem();
%endsafe


IGRlong EMsfint_topology_validate (msg, mdenvinfo,
                                   sf1_inters, sf2_inters,
                                   sf1_tracedata, sf2_tracedata,
                                   options,
                                   sf1_loopdata, sf2_loopdata)
IGRlong *msg;
struct GRmdenv_info *mdenvinfo;
struct EMSinters *sf1_inters, *sf2_inters;
struct EMSsftracedata *sf1_tracedata, *sf2_tracedata;
IGRushort options;
struct EMSsfintloopsdata *sf1_loopdata, *sf2_loopdata;
{
  IGRboolean op1_only, notpycont, try_flip, exit_on_error;
  IGRboolean connect_commedge_opt, connect_to_commedges;
  IGRboolean **subgrp_rev[2], ***elem_rev[2], *grp_closed[2];
  IGRboolean **subgrp_closed[2];
  IGRboolean deallocate_sfintloops[2];
  IGRboolean incednull1, incednull2;
  IGRuchar *commed_p_exists, *nocommed_p_exists;
  IGRshort *mattyp;
  IGRint count,i, j, k;
  IGRuint commed_exists;
  IGRint opinx, tryinx, inxlim, circinxj, circinxk;
  IGRint altinx1, altinx2, opinxlim;
  IGRint num_grps[2], *num_subgrps_grp[2], **num_elems_subgrp[2];
  IGRint numedsplit[2];
  IGRlong msg_loc, stat_OM;
  IGRdouble **sfpartolb[2], *mat, chktol;
  GRobjid **loop_sf[2], **endedges[2];
  GRobjid incedge1, incedge2, commedge;
  GRobjid intedge1, intedge2, vtxeds[2];
  GRspacenum thisos;
  struct EMSinters *inters[2];
  struct EMSintobj ***elems[2];
  struct EMSsfintedpar ***intedpars[2], *intedpar, *intedpar1, *intedpar2;
  struct EMSsftracedata *tracedata[2];
  struct EMSsfintloopsdata dumloopdata, *loopdata[2], *outloopdata;
  struct EMSdataselect tmpdata;
  struct GRid tmpid;
  enum EMScvinttype incloc1, incloc2;
  OM_S_CHANSELECT chan_to_common_edge;
  OM_S_OBJECT_LINKAGE objlink;
  extern IGRint EMsfintloops(), EMgetincinfo();
  extern void EMsfintloops_free(), EMsfintloops_data_free();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
		
  op1_only = options & EMSsfbool_opt_SingleTopology || !sf2_inters ||
             !sf2_tracedata;
  opinxlim = op1_only ? 1 : 2;
  exit_on_error = !(options & EMSsfbool_opt_ValidateAllData);
  connect_commedge_opt = options & EMSsfbool_opt_ConnectToComEdge;

  tracedata[FIRST] = sf1_tracedata;
  tracedata[SECOND] = sf2_tracedata;
  loopdata[FIRST] = sf1_loopdata;
  loopdata[SECOND] = sf2_loopdata;
  for (opinx=FIRST; opinx<opinxlim; opinx++)
    {
    inters[opinx] = opinx == FIRST ? sf1_inters : sf2_inters;
    num_grps[opinx] = tracedata[opinx]->num_grps;
    num_subgrps_grp[opinx] = tracedata[opinx]->num_subgrps_grp;
    num_elems_subgrp[opinx] = tracedata[opinx]->num_elems_subgrp;
    elems[opinx] = tracedata[opinx]->elems;
    subgrp_rev[opinx] = tracedata[opinx]->subgrp_rev;
    elem_rev[opinx] = tracedata[opinx]->elem_rev;
    grp_closed[opinx] = tracedata[opinx]->grp_closed;
    subgrp_closed[opinx] = tracedata[opinx]->subgrp_closed;
    }
  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    loop_sf[opinx] = NULL;
    endedges[opinx] = NULL;
    intedpars[opinx] = NULL;
    sfpartolb[opinx] = NULL;
    deallocate_sfintloops[opinx] = FALSE;   
    }

  thisos = sf1_inters->cvs->this_uvintobj.data.object->osnum;
  mattyp = &mdenvinfo->matrix_type;
  mat = mdenvinfo->matrix;
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chktol);
  chktol *= 2;

  /*
   * The groups (on a global basis) and subgroups (on a surface basis) 
   * as given in the trace data are constructed into loops. Topology is
   * maintained by connecting corresponding edges of an intersection together
   * (forming common edges). The output from this stage are three
   * two-dimensional arrays - 
   * i)   loopid-srfid pairs for every subgroup. Each of these loops could 
   *      be either open or closed.
   * ii)  objid pairs of the two edges (start and end) on every loop.
   * iii) pointers to pairs of "intedpars"-structures that correspond to the 
   *      begin and end endpoints of each of the loops in i). These tell where
   *      exactly these endpoints are incident, viz. on which edge and at what
   *      edge-parameter.
   *
   * A check is made at this stage to see if the information to split 
   * existing edges is indeed there for all "splitting edges". If an edge
   * belongs to a loop which is itself closed, then and then alone is it
   * not a "splitting edge". All closed loops can be detected where a group
   * consists of just one subgroup. If a splitting edge does not have
   * the information about which element to split, an error condition has
   * occurred. An attempt to generate such missing information about an
   * end-point is carried out. If the end-point does not lie on a boundary
   * element, the recovery attempt has failed.
   *
   * A check is put in here, that validates, using topology, the direction
   * of any subgroup containing a point-edge at it's end. The order in which
   * the splitting information is stored is basically correct. There is the
   * possibility that trace has incorrectly set the subgroup-reverse flag.
   * The same is corrected. NB: If more than one element is contained in
   * the sub-group, currently a semi-kludge reverses the order of the
   * splitting information in the hope that the correct data is now at the
   * splitting end.
   *
   * A final check is made to see if the splitting ends end up on
   * common-edges. If they don't an error code is returned.
   *
   * These and other validation checks are described in some detail in
   * the comments below.
   *
   * Also, keep track of the number of edges that will need to be split and
   * then unsplit, in later stages.
   */

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common_edge);
  for (opinx=FIRST; opinx<opinxlim; opinx++)
    {
    connect_to_commedges = op1_only ? connect_commedge_opt : TRUE;


    /* The function "EMsfintloops" checks for existing common edge connections
     * before it even looks at the input argument "connect_to_commedges", so 
     * ALWAYS setting it to TRUE (unless "connect_commedge_opt" says otherwise)
     * does not mean any extra work (except one call to "EMgetbsdef" once per
     * surface, which is not very expensive). The above change is beneficial in
     * the following case:
     *  In the case of features (ribs for one) we may need to pass in inters 
     * lists, where there may exist common edge connections between surfaces of
     * the SAME inters list. Imagine a scenario, where the first inters list
     * corresponding to "opinx==FIRST" has common edge connection exclusively
     * with the OTHER inters list. The second inters list has SOME common edge
     * connections within itself. Going by the original code, when the second
     * inters list is checked, "connect_to_commedges" is always FALSE, and these
     * internal common edge connections are NEVER made.  Q.E.D.    (NP 6/2/93)
     */

    numedsplit[opinx] = 0;
    stat_OM = EMsfintloops (&msg_loc, mattyp, mat, thisos, NULL,
               num_grps[opinx], num_subgrps_grp[opinx],
               num_elems_subgrp[opinx], elems[opinx], subgrp_rev[opinx],
               elem_rev[opinx], grp_closed[opinx], subgrp_closed[opinx],
               connect_to_commedges, FALSE,
               &loop_sf[opinx], &endedges[opinx],
               &intedpars[opinx], &sfpartolb[opinx]);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    deallocate_sfintloops[opinx] = TRUE;
  
    outloopdata = opinx == FIRST ? sf1_loopdata : sf2_loopdata;
    commed_p_exists = outloopdata ? &loopdata[opinx]->commed_k_exists 
                                  : &dumloopdata.commed_k_exists;
    nocommed_p_exists = outloopdata ? &loopdata[opinx]->nocommed_k_exists
                                    : &dumloopdata.nocommed_k_exists;
    *commed_p_exists = TRUE;
    *nocommed_p_exists = FALSE;
			
    for (i=0; i<num_grps[opinx]; i++)
      {
      if (subgrp_closed[opinx][i][0])
        continue;

      count = num_subgrps_grp[opinx][i];
      inxlim = count * 2;
      for (j=0, k=0; k<inxlim; j++, k+=2)
        {
        circinxk = (k + 2) % inxlim;
        circinxj = (j + 1) % count;
        numedsplit[opinx] += 2;

        for (tryinx=FIRST; tryinx<opinxlim; tryinx++)
          {
          try_flip = FALSE;

          altinx1 = subgrp_rev[opinx][i][j] ? 0 : 1;
          intedge1 = endedges[opinx][i][k+altinx1];
          intedpar1 = intedpars[opinx][i][k+altinx1];
          if (intedpar1)
            incedge1 = intedpar1->edgeid;
          else
            incedge1=NULL_OBJID;

          altinx2 = subgrp_rev[opinx][i][circinxj] ? 1 : 0;
          intedge2 = endedges[opinx][i][circinxk+altinx2];
          intedpar2 = intedpars[opinx][i][circinxk+altinx2]; 
          if (intedpar2)
            incedge2 = intedpar2->edgeid;
          else
            incedge2 = NULL_OBJID;

          incednull1 = IF_NULL_OBJID (incedge1);
          incednull2 = IF_NULL_OBJID (incedge2);

          /*
           * The end-points of the sub-groups must end on some valid
           * edge of the existing topology. If not, try to obtain through
           * a point-location call. If such information is still unobtainable,
           * an irrecoverable error condition has occurred. 
           */

          if (incednull1)
            {
            tmpdata.datatype = EMSdata_object; 
            tmpdata.data.object = &tmpid;
            tmpid.objid = intedge1;
            tmpid.osnum = thisos;
            EMgetincinfo (&msg_loc, thisos, &tmpdata, altinx1, NULL,
             mattyp, mat,
             loop_sf[opinx][i][k+1], chktol, sfpartolb[opinx][i][j],
             intedpars[opinx][i][k+altinx1]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (exit_on_error)
              {
              EMerr_hndlr (msg_loc != EMS_I_Found, *msg, EMS_E_IntersectTrim,
               ret_end);
              incedge1 = intedpar1->edgeid;
              }
            else
              continue;
            }
          if (incednull2)
            {
            tmpdata.datatype = EMSdata_object; 
            tmpdata.data.object = &tmpid;
            tmpid.objid = intedge2;
            tmpid.osnum = thisos;
            EMgetincinfo (&msg_loc, thisos, &tmpdata, altinx2, NULL,
             mattyp, mat,
             loop_sf[opinx][i][circinxk+1], chktol,
             sfpartolb[opinx][i][circinxj],
             intedpars[opinx][i][circinxk+altinx2]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (exit_on_error)
              {
              EMerr_hndlr (msg_loc != EMS_I_Found, *msg, EMS_E_IntersectTrim,
               ret_end);
              incedge2 = intedpar2->edgeid;
              }
            else
              continue;
            }

          incloc1 = intedpar1->intloc;
          incloc2 = intedpar2->intloc;

          /*
           * If the subgroup end-points are incident on vertices, check
           * if these vertices happen to be one and the same. If not
           * a topological error has occurred. Try flipping end-point
           * info on degeneracy at ends and then retry. If they are the same no
           * further checks need to be performed on this sub-group.
           * Exception: The exception to this rule is that if the incident
           * vertices belong to the same surface then the edges may not 
           * belong to the same topological vertex and yet this may be
           * a valid situation.
           */

          if (incloc1 != EMScvint_middle && incloc2 != EMScvint_middle)
            {
            if (loop_sf[opinx][i][k+1] == loop_sf[opinx][i][circinxk+1])
              break;

            stat_OM = om$send (msg = message EMSedge.EMfind_commvtx (&msg_loc,
                       incedge1, incloc1 == EMScvint_rtend ? TRUE : FALSE,
                       TRUE, vtxeds), targetid = incedge2, targetos = thisos,
                       senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (msg_loc == EMS_I_Fail)
              {
              try_flip = TRUE;
              goto Try_Flip;
              }
            else
              break;
            }

          /*
           * Obtain the common-edges of the incident edges. Flag their
           * existence (or absence) in the corresponding EMSsfintedpar 
           * structure by having the "info" field point to a "TRUE" or
           * "FALSE" variable. These variables are defined in the structure
	   * EMSsfintloopsdata. If the caller wishes the sfintloops data
	   * to be returned, use the variables from the caller supplied
	   * structures. Otherwise use local variables. In the latter case
           * use the variables from a dummy local structure instead of simple
           * local variables so that this code is independent of the values
           * these variables are supposed to have (other than TRUE/FALSE).
           * An abstract pointer to these variables is available at this 
           * stage.
           */

          stat_OM = om$get_channel_objects (objid = incedge1, osnum = thisos,
                     p_chanselect = &chan_to_common_edge, list = &objlink,
                     size = 1, count = &commed_exists);
          EMomerr_exit (stat_OM, ret_end);
          if (commed_exists)
            {
            commedge = objlink.S_objid;
            intedpar1->info = (IGRchar *) commed_p_exists;
            }
          else
            intedpar1->info = (IGRchar *) nocommed_p_exists;

          stat_OM = om$get_channel_objects (objid = incedge2, osnum = thisos,
                     p_chanselect = &chan_to_common_edge, list = &objlink,
                     size = 1, count = &commed_exists);
          EMomerr_exit (stat_OM, ret_end);
          if (commed_exists)
            intedpar2->info = (IGRchar *) commed_p_exists;
          else
            intedpar2->info = (IGRchar *) nocommed_p_exists;

          /*
           * Typically, both end-points should end in the middle of
           * some edge. If only one of the end-points end in the
           * middle, the condition is pardonable only when the "middle" edge
           * is a degenerate edge or in general, an edge without a
           * common-edge. Else an error condition. Try flip in this case.
           */

          if ((incloc1 != EMScvint_middle || incloc2 != EMScvint_middle))
            {
            notpycont = incloc1 == EMScvint_middle ? 
                         *intedpar1->info == *nocommed_p_exists : 
                         *intedpar2->info == *nocommed_p_exists;
            if (notpycont)
              break;
            else
              {
              try_flip = TRUE;
              goto Try_Flip;
              }
            }

          /*
           * At this point both the ends terminate in the middle of some
           * existing edges. There are only two valid possibilities.
           * First, that neither of the incident edges have common-edges,
           * and the second that both of them have common-edges. In the
           * latter case, a further restriction is that the respective
           * common-edges are each other. In the case of any error condition
           * try flipping the end-point info around if there is a degenarcy
           * at the end-points of sub-groups. See if this helps.
           */
            
          if (*intedpar1->info == *nocommed_p_exists &&
              *intedpar2->info == *nocommed_p_exists)
            break;

          if (! (*intedpar1->info == *commed_p_exists &&
                 *intedpar2->info == *commed_p_exists))
            {
            try_flip = TRUE;
            goto Try_Flip;
            }

          if (!IF_EQ_OBJID (incedge2, commedge))
            {
	     IGRushort edprops;
	     IGRboolean is_ok = FALSE;
	     if(IF_EQ_OBJID(incedge1, incedge2))
	      {
	       stat_OM = om$send(msg = message EMSedge.EMget_props(&msg_loc, 
	                 &edprops), targetid = incedge1, targetos = thisos, 
	                 senderid = NULL_OBJID);
               EMomerr_exit (stat_OM, ret_end);
               EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
               if(edprops & EMED_SEAM)
                is_ok = TRUE;
	      }
	
	    if(is_ok)
	     break;
	
            try_flip = TRUE;
            goto Try_Flip;
            }
          else
            break;

          /*
           * On failure of the above tests, it may be possible that the
           * intersection edges at the ends of the subgroups are degenerate
           * and should actually be reversed. This can only be attempted
           * once for a given pair.
           */

          Try_Flip:
          if (try_flip)
            {
            if (tryinx == SECOND)
              {
              if (exit_on_error)
                {EMerr_hndlr (TRUE, *msg, EMS_E_IntersectTrim, ret_end);}
              else
                break;
              }
            
            if (degelem (NULL, NULL, &intedge1, thisos))
              subgrp_rev[opinx][i][j] = !subgrp_rev[opinx][i][j];
            else if (degelem (NULL, NULL, &intedge2, thisos))
              subgrp_rev[opinx][i][circinxj] = !subgrp_rev[opinx][i][circinxj];
            }
          }
        }
      }
    }

  /*
   * Transfer the loopdata into the output variables,
   * if such output is desired.
   */

  if (sf1_loopdata || sf2_loopdata)
    for(opinx=FIRST; opinx<opinxlim; opinx++)
      {
      outloopdata = opinx == FIRST ? sf1_loopdata : sf2_loopdata;
      if (outloopdata)
        {
        loopdata[opinx]->loop_sf = loop_sf[opinx];
        loopdata[opinx]->endedges = endedges[opinx];
        loopdata[opinx]->intedpars = intedpars[opinx];
        loopdata[opinx]->sfpartolb = sfpartolb[opinx];
        loopdata[opinx]->sfintloops_alloced = TRUE;
        loopdata[opinx]->numedsplit = numedsplit[opinx];
        deallocate_sfintloops[opinx] = FALSE;
        }
      }

ret_end:
  /*
   * Deallocate any locally used memory
   * that was malloced here.
   */

  for (opinx=FIRST; opinx<opinxlim; opinx++)
    if (deallocate_sfintloops[opinx])
      {
      EMsfintloops_data_free (num_grps[opinx], num_subgrps_grp[opinx],
       loop_sf[opinx], thisos);

      EMsfintloops_free (loop_sf[opinx], endedges[opinx], intedpars[opinx],
       sfpartolb[opinx]);
      }

  EMWRAPUP (*msg, stat_OM, "EMsfbool_validate");
  return (stat_OM);
}

/*
 * A locally used function to detect if a given element is degenerate
 * or not.
 */

static IGRboolean degelem (intobj, inx, intid, os)
struct EMSintobj *intobj;
IGRint inx;
GRobjid *intid;
GRspacenum os;
{
  IGRboolean stat_func;
  struct GRid intgrid;
  struct EMSdataselect intdata;
  extern IGRboolean EMdegenerate_data();

  if (intobj)
    {
    while (inx--)
      intobj = intobj->next;
    stat_func = intobj->props & EMSintobj_uvdegenerate ? TRUE : FALSE;
    }
  else if (intid)
    {
    intgrid.objid = *intid;
    intgrid.osnum = os;
    intdata.datatype = EMSdata_object;
    intdata.data.object = &intgrid;
    stat_func = EMdegenerate_data (&intdata, FALSE, NULL); 
    }
  return (stat_func);
}

end implementation EMSsurface;
                            
