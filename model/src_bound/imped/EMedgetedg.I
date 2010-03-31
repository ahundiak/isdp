/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "OMmacros.h"

#define INITIAL_SIZE    4
#define INCREMENT       4

method EMget_edges(
        IGRlong         *EMmsg;         /* return code         */
        IGRint          tree_depth;     /* how deep the loop tree
                                           to be processed     */
        IGRlong         option;         /* type of the edges   */
                                        /* to be selected      */
        struct GRid     **edges;        /* edges returned      */
        IGRint          *array_size;    /* size of edge array  */
        IGRint          *num_edges)     /* num of edges ret    */
/*

Notes
  Upon exit the return code may be
        - EMS_S_Success         if successful
        - EMS_E_NoDynamicMemory if fail to allocate
                                or reallocate memory
       - EMS_E_InvalidArg       if option is invalid
       - EMS_E_OMerror          if failure in om call
	
  The current options available for edge selection are

  EMS_OPT_ALL:            return all edges.
  EMS_OPT_NATURAL:        return only natural edges.
  EMS_OPT_CONNECTABLE:    return all connectable edges (ones that can
                          be connected across common edge channel)
  EMS_OPT_NATURAL_NONDEG: return only natural non_degenerate edges.
  EMS_OPT_NONDEG_NONSEAM: return edges that are non_degenerate
                          and not seam edges.
  EMS_OPT_STITCHED:       return edges that are non_degenerate, non_seam
                          and have a common edge.
  EMS_OPT_STITCHED_ALL:   return all edges (including degenerate) that are
			  non_seam and have a common edge.
  EMS_OPT_NON_DEG_SEAM_XYZCLSD : return edges that are 
                          non_degenerate, non_seam and are not closed
                          in model space.
  EMS_OPT_SEAM:           return seam edges.
                           
  EMS_OPT_NON_DEG_STITCHED : return edges that are non_degenerate
                          and have a common edge.
  EMS_OPT_NAT_LOC0        return natural that correspond to location 0.
  EMS_OPT_NAT_LOC1        return natural that correspond to location 1.
  EMS_OPT_NAT_LOC2        return natural that correspond to location 2.
  EMS_OPT_NAT_LOC3        return natural that correspond to location 3.
  EMS_OPT_NONDEG:         return edges that are non_degenerate
  EMS_OPT_NONDEG_NONTANSEAM:  return edges that are non_degenerate
                              and if it is a seam, non_tangent.
  EMS_OPT_NONTAN_NONDEG: returns edges that are non_tangent and non_degenerate.  

  These options are includes in EMSopt.h file.
  Any other option can be added upon request.

  If the caller wants only the num_edges, edges variable should
  be passed in as NULL.
  The space will be allocated to store edges. The caller
  has the responsibility of deallocating this space.


History
	RC	03/26/87	Creation date
	RV	09/25/87	added option for STITCHED edges.
    RC  11/03/87    added option EMS_OPT_NON_DEG_SEAM_XYZCLSD.
    SAM 07-Apr-88   added option EMS_OPT_SEAM to return seam edges.
    RC  04/18/88    Modified the code such that only num_edges
                    can be obtained.
    gupta 05/12/88  added option EMS_OPT_NON_DEG_STITCHED.
    RC  12/09/88    Added options EMS_OPT_NAT_LOC(s).
    gupta 12/13/88  added option EMS_OPT_NONDEG.
    Inasu Dec 7,90  added option EMS_OPT_STITCHED_ALL.
    Jack  03 Mar 92 Added option EMS_OPT_NONDEG_NONTANSEAM.
    Jack  07/10/92  Added option EMS_OPT_NONTAN_NONDEG.
    Jack  09/30/92  For option EMS_OPT_NONTAN_NONDEG, if the edge is 
                    not marked tangent, check its common_edge(if it has
                    one).  If the common edge is tangent, mark myself as
                    tangent and don't return me for this option.
    Jack  11/15/92  Ansi compliance.
*/

{
  OM_S_CHANSELECT cm_ed_chan;
  IGRlong         OM_stat, mthd_stat;
  OMuint          count=0,
                  cm_ed_count=0;
  IGRboolean      ed_selected = FALSE;
  GRobjid         common_edge=NULL_OBJID;
  IGRushort       common_props=0;
  OM_S_OBJECT_LINKAGE	comm;
  
  /* *************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  cm_ed_chan.type = OM_e_addr;
  cm_ed_chan.u_sel.addr = &ME.EMSedge->to_common_edge;

  switch(option)
  {
    case EMS_OPT_ALL:
      ed_selected = TRUE;
      break;

    case EMS_OPT_NATURAL:
      if (ME.EMSedge->ed_props & EMED_NATURAL) ed_selected = TRUE;
      break;

    case EMS_OPT_SEAM:
	  if(ME.EMSedge->ed_props & EMED_SEAM) ed_selected = TRUE;
	  break;

    case EMS_OPT_NONTAN_NONDEG:
      /*
       * if I am not tangent, see if my common_edge is and change
       * my prop if necessary.
       */
      if ( !(ME.EMSedge->ed_props & EMED_TANGENT))
       {

        OM_stat = om$get_channel_objects(object = me, 
                                         p_chanselect = &cm_ed_chan, 
                                         list = &comm, 
                                         size = 1, 
                                         count = &cm_ed_count);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        /* if I had a common edge */
        if(cm_ed_count)
         {
            common_edge = comm.S_objid;
            OM_stat = om$send (msg = message EMSedge.EMget_props (
                                &mthd_stat, &common_props),
                               targetid = common_edge);
            EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
    
            if ( common_props & EMED_TANGENT )
             {
               /* this case wouldn't occur if we lived in a world where 
                * all tangent edges were marked properly, but we don't.
                */  
               ME.EMSedge->ed_props |= EMED_TANGENT;
               break;           
             }
         }

       }

      if ( !(ME.EMSedge->ed_props & EMED_TANGENT))
       if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE))
         ed_selected = TRUE;          
      break; 

    case EMS_OPT_CONNECTABLE:
      if(!(ME.EMSedge->ed_props & EMED_DEGENERATE))
      {
         OM_stat = om$get_channel_count(object = me, 
                      p_chanselect = &cm_ed_chan, count = &count);
         EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
         if (!count) ed_selected = TRUE;
	     else
	     {
	       GRobjid		mate_id, loop_id;
	       IGRlong		rc;

	       OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
					          &mate_id),
				             p_chanselect = &cm_ed_chan);
           EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   	       loop_id = NULL_OBJID;
	       OM_stat = EMsend_loops(&rc, message EMSboundary.EMget_objid(
                                   EMmsg, &loop_id), mate_id, 0, 
                                   OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
	       EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

	       if (loop_id == NULL_OBJID) ed_selected = TRUE;

         } /* else for if (!count) */

      } /* if(!(ME.EMSedge->ed_props & EMED_DEGENERATE)) */

      break;

    case EMS_OPT_NATURAL_NONDEG:
      if ( (ME.EMSedge->ed_props & EMED_NATURAL)      &&
          !(ME.EMSedge->ed_props & EMED_DEGENERATE) )
        ed_selected = TRUE;
      break;

    case EMS_OPT_NONDEG_NONSEAM:
      if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE)      &&
           !(ME.EMSedge->ed_props & EMED_SEAM) )
         ed_selected = TRUE;
      break;

    case EMS_OPT_NONDEG_NONTANSEAM:
      if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE))
       {
        ed_selected = TRUE;
        if ((ME.EMSedge->ed_props & EMED_SEAM)      &&
           (ME.EMSedge->ed_props & EMED_TANGENT))
          ed_selected = FALSE;
       } 
      break; 

    case EMS_OPT_STITCHED:
      if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE)      && 
           !(ME.EMSedge->ed_props & EMED_SEAM) )
      {
        OM_stat = om$get_channel_count(object = me, 
                     p_chanselect = &cm_ed_chan, count = &count);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        if (count) ed_selected = TRUE;
      }
      break;

    case EMS_OPT_STITCHED_ALL:
      if ( !(ME.EMSedge->ed_props & EMED_SEAM) )
      {
        OM_stat = om$get_channel_count(object = me, 
                     p_chanselect = &cm_ed_chan, count = &count);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        if (count) ed_selected = TRUE;
      }
      break;

    case EMS_OPT_NON_DEG_SEAM_XYZCLSD:
      if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE)      &&
           !(ME.EMSedge->ed_props & EMED_SEAM)            &&
           !(ME.EMSedge->ed_props & EMED_XYZ_CLOSED) )
         ed_selected = TRUE;
      break;

    case EMS_OPT_NON_DEG_STITCHED:
      if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE))
      {
        OM_stat = om$get_channel_count(object = me, 
                     p_chanselect = &cm_ed_chan, count = &count);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        if (count) ed_selected = TRUE;
      }
      break;

    case EMS_OPT_NAT_LOC0:
    case EMS_OPT_NAT_LOC1:
    case EMS_OPT_NAT_LOC2:
    case EMS_OPT_NAT_LOC3:
    
      if (ME.EMSedge->ed_props & EMED_NATURAL)
      {
        IGRshort ed_loc;

        OM_stat = om$send (msg = message EMSedge.EMget_location (
                            &mthd_stat, &ed_loc),
                           targetid = my_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        if ( (ed_loc == 0 && option == EMS_OPT_NAT_LOC0) ||
             (ed_loc == 1 && option == EMS_OPT_NAT_LOC1) ||
             (ed_loc == 2 && option == EMS_OPT_NAT_LOC2) ||
             (ed_loc == 3 && option == EMS_OPT_NAT_LOC3) )
         ed_selected = TRUE;

      } /* if (ME.EMSedge->ed_props & EMED_NATURAL) */

      break;

    case EMS_OPT_NONDEG:
      if ( !(ME.EMSedge->ed_props & EMED_DEGENERATE))
         ed_selected = TRUE;
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;

  } /* switch(option) */

  if(ed_selected)
  {
   if (edges)
   {    
    if (! *array_size)	
    {
      *edges = (struct GRid *) om$malloc (size = (unsigned) 
                         (INITIAL_SIZE * sizeof (struct GRid)));
      EMerr_hndlr (!(*edges),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      *array_size = INITIAL_SIZE;

     }
     else if ((*num_edges + 1) > *array_size)
     {
      (*array_size) += INCREMENT;
      *edges = (struct GRid *) om$realloc (ptr = (IGRchar *)*edges, 
		size = (unsigned) (*array_size) * sizeof(struct GRid));
      EMerr_hndlr (!(*edges),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
     }
 
     (*edges)[*num_edges].objid = my_id;
     (*edges)[*num_edges].osnum = OM_Gw_current_OS;

   } /* if (edges) */
   (*num_edges)++;
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSedge.EMget_edges");

  return(OM_stat);
}

end implementation EMSedge;
