/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emsmacros.h"
#include "OMstackalloc.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "bsparameters.h"

method EMget_range_edges  (
        IGRlong              *EMmsg;
        struct GRmd_env      *my_env;
        IGRshort             position;
        IGRint               num_parms;
        IGRdouble            *in_parms;
        GRobjid              (*pch_edge_ids)[4],
                             saved_edge;
        IGRint               *num_full_edge;
        GRobjid              *full_edge,
                             *keep_end_edge,
                             *keep_beg_edge,
                             *keep_mid_edge;
        struct EMSedgebound  *parme,
                             *parmb)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError error in edge method
Assumption

Bugs

History
	
	  gupta 	05/05/87:	design date
          Sudha         06/04/93         modified to include BSprototype header files

Algorithm

      This method, given an array of parameters (corresponding to the
      end points of split surface edges), will find whether these
      split surface edges fall within range of my end points. The 
      various categories thst these edges are placed in are

      o  full edge      -- these edges lie completely inside my range
      o  keep_end_edge  -- this natural edge has to be split and the
                           part edge towards the end point of the natural
                           edge should be kept
      o  keep_beg_edge  -- this natural edge has to be split and the
                           part edge towards the begin point of the
                           natural edge should be kept
      o  keep_mid_edge  -- this natural edge should be split at parme
                           and parmb and the portion in the middle has
                           to be kept


      Finally the parameters parme and parmb are found on the split
      surface edges where they should be split to produce the above
      edges.      
*/

{
  IGRlong                         stat_OM, msg;
  IGRint                          i, loc;
  IGRdouble                       beg0[2], end0[2];
  IGRdouble                       *parms, parb, pare;
  IGRdouble                       knot_tol;
  struct EMSedgebound             my_edge_infob, my_edge_infoe;

/* ------------------------------------------------------------- */

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *keep_end_edge = NULL_OBJID;
  *keep_beg_edge = NULL_OBJID;
  *keep_mid_edge = NULL_OBJID;

  (void)BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

  EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

  loc = (IGRint) position;
  my_edge_infob.span_inx = my_edge_infoe.span_inx = 0;
  parms = (IGRdouble *) OM_stack_alloc (
                        (num_parms + 2) * sizeof(IGRdouble));

  parms[0] = 0.0;
  parms[num_parms+1] = 1.0;
  for (i=0; i<num_parms; i++)
       parms[i+1] = in_parms[i];

  /* get my end points */

  stat_OM = om$send(msg=message EMSedge.EMendpts(
                        &msg, beg0, end0, NULL,NULL,NULL),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedrng_edgs.EMendpts");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  switch (position)
   {
    case 0:
    case 2: 
           parb = beg0[1];
           pare = end0[1];
           break;
    case 1:
    case 3: 
           parb = beg0[0];
           pare = end0[0];
           break;
   }

  if (position == 0 || position == 1)
   {
    for (i=0; i<(num_parms+1); i++)
     {
      /* full edge */

      if ((parms[i] >= parb-knot_tol) && (parms[i+1] <= pare+knot_tol))
       {
        full_edge[(*num_full_edge)] = pch_edge_ids[i][loc];
        (*num_full_edge)++;
       }

      /* keep end edge */

      else
      if ((parms[i] < parb-knot_tol) && (parms[i] <= pare-knot_tol) &&
          (parms[i+1] > parb+knot_tol) && (parms[i+1] <= pare+knot_tol))
       {
        *keep_end_edge = pch_edge_ids[i][loc];
        my_edge_infoe.param = parb;
       }
   
      /* keep beg edge */

      else
      if ((parms[i] < pare-knot_tol) && (parms[i] >= parb-knot_tol) &&
          (parms[i+1] > pare+knot_tol) && (parms[i+1] >= parb+knot_tol))
       {
        *keep_beg_edge = pch_edge_ids[i][loc];
        my_edge_infob.param = pare;
       }

      /* keep middle edge */

      else
      if ((parms[i] < parb-knot_tol) && (parms[i] < pare-knot_tol) &&
         (parms[i+1] > parb+knot_tol) && (parms[i+1] > pare+knot_tol))
       {
        *keep_mid_edge = pch_edge_ids[i][loc];
        my_edge_infob.param = pare;
        my_edge_infoe.param = parb;
       }
    } /* end for loop */  
   }  /* end if loop  */

  else   /* position == 2 || position == 3 */

   {
    for (i=0; i<(num_parms+1); i++)
     {
      /* full edge */

      if ((parms[i] >= pare-knot_tol) && (parms[i+1] <= parb+knot_tol))
       {
        full_edge[(*num_full_edge)] = pch_edge_ids[i][loc];
        (*num_full_edge)++;
       }

      /* keep beg edge */

      else
      if ((parms[i] < pare-knot_tol) && (parms[i] <= parb-knot_tol) &&
          (parms[i+1] > pare+knot_tol) && (parms[i+1] <= parb+knot_tol))
       {
        *keep_beg_edge = pch_edge_ids[i][loc];
        my_edge_infob.param = 1 - pare;
       }
   
      /* keep end edge */

      else
      if ((parms[i] < parb-knot_tol) && (parms[i] >= pare-knot_tol) &&
          (parms[i+1] > parb+knot_tol) && (parms[i+1] >= pare+knot_tol))
       {
        *keep_end_edge = pch_edge_ids[i][loc];
        my_edge_infoe.param = 1 - parb;
       }

      /* keep middle edge */

      else
      if ((parms[i] < pare-knot_tol) && (parms[i] < parb-knot_tol) &&
         (parms[i+1] > pare+knot_tol) && (parms[i+1] > parb+knot_tol))
       {
        *keep_mid_edge = pch_edge_ids[i][loc];
        my_edge_infob.param = 1 - pare;
        my_edge_infoe.param = 1 - parb;
       }
    } /* end for loop */  

   } /* end else loop */

  /* get the corresponding parameter(s) on the patch edge */
 
  if (! IF_NULL_OBJID (*keep_beg_edge))
   {
    stat_OM = om$send(msg = message EMSedge.EMchild_crv_parm(&msg,
                            &my_edge_infob, parmb, my_env, position,
                            *keep_beg_edge),
                      targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedrng_edgs.EMchild_crv_parm");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }  

  if (! IF_NULL_OBJID (*keep_end_edge))
   {
    stat_OM = om$send(msg = message EMSedge.EMchild_crv_parm(&msg,
                            &my_edge_infoe, parme, my_env, position,
                            *keep_end_edge),
                      targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedrng_edgs.EMchild_crv_parm");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }  

  if (! IF_NULL_OBJID (*keep_mid_edge))
   {
    stat_OM = om$send(msg = message EMSedge.EMchild_crv_parm(&msg,
                            &my_edge_infob, parmb, my_env, position,
                            saved_edge),
                      targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedrng_edgs.EMchild_crv_parm");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }  


wrapup:

  return(stat_OM);
}
end implementation EMSedge;
