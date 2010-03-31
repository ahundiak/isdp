/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "bsparameters.h"
#include "emsedgedef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsimpdef.h"
#include "emsmapdef.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "EMSsfintsort.h"
#include "msmacros.h"
#include "emsgeteddef.h"
#include "emsbool.h"
#include "EMcp.h"
#include "EMSdef.h"

/*
 ABSTRACT
          This method trims a surface/solid for any of the special
          boolean operations. 

 HISTORY
        NP    09/09/93     The "sortpts_info" & "bad_pts_info" is now passed as
                           struct EMparms (which is more meaningful) instead of
                           EMSsortpt_info to the selective boolean function due 
                           to a change in parameters.
                           
        NP    07/24/92	   Modified function to call "EFperform_special_boolean"
                           instead of calling "EFperform_special_boolean_mod".
			   The new function "EFperform_special_boolean" is a 
                           re-write of "EFperform_special_boolean_mod" and will
                           fully replace it in the future.
                           
    	Tapadia 09/05/91   Added an argument (struct GRid) in the function 
			   EFperform_special_boolean. Hence changed 
			   it's name to EFperform_special_boolean_mod.
        DLB   06/02/91     After EMintcopy fix up creator id in topology.
        RC    07/22/89     Creation Date
*/


method  EMtrim_a_surface (IGRlong *EMmsg; GRobjid op1_elem;
           struct GRmd_env *op1_elem_env; IGRint num_op2_elems;
           GRobjid *op2_elems; struct GRmd_env *op2_elems_env;
           struct GRvg_construct *const_list;
           IGRboolean extend_operand_1;
           struct EMSextend_info *extend_info;
           IGRboolean copy_operand_2;
           IGRint num_pts;
           struct EMSsortpt_info  *sortpts_info;
           enum EMSbooltype  bool_type;
           IGRboolean  all_elements_solid;
           IGRint *num_bad_pts;
           struct EMSsortpt_info  **bad_pts_info)
{
 struct GRid         active_GRid, bool_GRid;
 struct EMcp_info    copy_info;
 IGRlong             OM_stat, mthd_stat, rc;
 IGRint              i, j, k;
 GRobjid             *op2_cp_elems, op2_cp_elems_mem[OP2_BUF_SIZE];
 GRspacenum          op2_elem_os, sortpt_os;
 struct EMparms      *loc_sortpts_info, *loc_bad_pts_info;
 IGRboolean          found_index=FALSE;
 extern void         EFperform_special_boolean(),
                     EFextend_sf_to_intersection ();
 
 /* ***************************************************************** */

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 bool_GRid.objid = NULL_OBJID;
 bool_GRid.osnum = op1_elem_env->md_id.osnum;

 op2_cp_elems = NULL;
 copy_info.num_entries = copy_info.array_size = 0;
 copy_info.objid_array = NULL;

 /*
  * Extend operand_1 if the information is supplied by the user
  */

 if (extend_operand_1)
 {
  EFextend_sf_to_intersection (EMmsg, op1_elem, op1_elem_env, 
              num_op2_elems, op2_elems, op2_elems_env, extend_info, 
              &num_pts, sortpts_info);

  if (*EMmsg == EMS_I_NoIntersection) goto wrapup;

  EMerr_hndlr (!(1 & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 } /* if (extend_info) */

 /*
  * Add ed_oprnd to sortpts_info 
  */

 for (i = 0; i < num_pts; i++)
 {
  sortpt_os = sortpts_info[i].md_env.md_id.osnum;

  OM_stat = om$send (msg =message EMSsurface.EMgetactiveid (&mthd_stat,
                        &active_GRid, NULL),
                       targetid = sortpts_info[i].sf_id,
                       targetos = sortpt_os);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  sortpts_info[i].ed_oprnd = EMSoprnd_A;
  
  for (j = 0; j < num_op2_elems; j++)
  {
   if (sortpt_os == op2_elems_env[j].md_id.osnum  &&
       active_GRid.objid == op2_elems[j])
   {
    sortpts_info[i].ed_oprnd = EMSoprnd_B;
    break;

   } /* if (sortpt_os == op2_elems_env[j].md_id.osnum  && */

  } /* for (j = 0; j < num_op2_elems; j++) */
  
 } /* for (i = 0; i < num_pts; i++) */

 /*
  * Copy all of the op2_elms into the op1_elem environment if
  * requested. This will be requested whenever operand2 is to be
  * for read only purposes e.g., in Trim operand1  or 
  * Extend operand1 to intersection with operand2. 
  */

 if (copy_operand_2)
 {
  if (num_op2_elems > OP2_BUF_SIZE)
  {
   op2_cp_elems = (GRobjid *) om$malloc (size = sizeof(GRobjid) *
                                        num_op2_elems);
   EMerr_hndlr (!op2_cp_elems, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

  } 
  else
    op2_cp_elems = op2_cp_elems_mem;

  /*
   * Use EMintcopy instead of GRcopy as it will return id/cp_id list
   * which will be used to update sortpts_info to reflect the 
   * sf_id/ed_id of the copied op2_elems.
   */

  for (i = 0; i < num_op2_elems; i++)
  {
   copy_info.num_entries = 0;
   op2_elem_os = op2_elems_env[i].md_id.osnum;

   OM_stat = om$send (msg = message EMSsurface.EMintcopy (&mthd_stat,
                      &op2_elems_env[i], op1_elem_env, &op2_cp_elems[i],
                      &copy_info, NULL, NULL),
                     targetid = op2_elems[i], 
                     targetos = op2_elem_os);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

   OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id(EMmsg, NULL,
                           op2_cp_elems[i], NULL),
                     targetid = op2_cp_elems[i]);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;                     

   for (j = 0; j < num_pts; j++)
   {
    if (sortpts_info[j].ed_oprnd == EMSoprnd_B)
    {
     sortpt_os = sortpts_info[j].md_env.md_id.osnum;

     OM_stat = om$send (msg =message EMSsurface.EMgetactiveid (&mthd_stat,
                        &active_GRid, NULL),
                       targetid = sortpts_info[j].sf_id,
                       targetos = sortpt_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     if (sortpt_os == op2_elem_os  && active_GRid.objid == op2_elems[i])
     {
      for (k = 0; k < copy_info.num_entries; k++)
      {
       if (copy_info.objid_array[2*k] == sortpts_info[j].sf_id)
       {
          sortpts_info[j].sf_id = copy_info.objid_array[2*k+1];
          break;
       }
      }

      for (k = 0; k < copy_info.num_entries; k++)
      {
       if (copy_info.objid_array[2*k]==sortpts_info[j].ptloc_info.loop_id)
       {
          sortpts_info[j].ptloc_info.loop_id=copy_info.objid_array[2*k+1];
          break;
       }
      }

      if (sortpts_info[j].ptloc_info.num_located_edges)
      {
       for (k = 0; k < copy_info.num_entries; k++)
       {
        if (copy_info.objid_array[2*k] == 
            sortpts_info[j].ptloc_info.edge[0].edge_id)
        {
          sortpts_info[j].ptloc_info.edge[0].edge_id = 
                                       copy_info.objid_array[2*k+1];
          break;
        }
       }

      } /* if (sortpts_info[j].ptloc_info.num_located_edges) */

     } /* if (sortpt_os == op2_elem_os  && active_GRid.objid ==  */

    } /* if (sortpts_info[j].ed_oprnd == EMSoprnd_B) */

   } /* for (j = 0; j < num_pts; j++) */
  
  } /* for (i = 0; i < num_op2_elems; i++) */

 } /* if (copy_operand_2) */


 /* Due to a change in the arguments of "EFperform_special_boolean", we convert 
  * the sortpts_info and bad_pts_info arguments into the new form. The rest of 
  * this function is left as it is, so that perturbation is minimum.
  */ 

  
 loc_sortpts_info = (struct EMparms *)alloca(sizeof(struct EMparms) * num_pts);
 /* for alloca, checking if "*loc_sortpts_info" is NULL is not of any use */

 for (i=0; i<num_pts; i++)
 {
   loc_sortpts_info[i].leaf_id.objid = sortpts_info[i].sf_id;
   loc_sortpts_info[i].leaf_id.osnum = op1_elem_env->md_id.osnum;
   loc_sortpts_info[i].u = sortpts_info[i].ptloc_info.edge[0].nst_pt.proj_pt[0];
   loc_sortpts_info[i].v = sortpts_info[i].ptloc_info.edge[0].nst_pt.proj_pt[1];
 }

 *num_bad_pts=0;
 loc_bad_pts_info=NULL;

 EFperform_special_boolean(&rc, op1_elem_env, op1_elem,
            num_op2_elems, copy_operand_2 ? op2_cp_elems : op2_elems, 
            all_elements_solid, const_list, bool_type, num_pts, 
            loc_sortpts_info, NULL, num_bad_pts, &loc_bad_pts_info, bool_GRid);
 EMerr_hndlr (!(1&rc), *EMmsg, rc, wrapup);

/* now convert "loc_bad_pts_info" to the needed output format */

 if (*num_bad_pts)
 {
   *bad_pts_info = (struct EMSsortpt_info *) om$malloc (size = 
                             sizeof (struct EMSsortpt_info) * (*num_bad_pts));
   for (i=0; i<*num_bad_pts; i++)
   {
     found_index = FALSE; 
     /* find the index of the bad point in the original array*/
     for (j=0; j<num_pts; j++)
     {
        if ( (loc_sortpts_info[j].leaf_id.objid == 
                       loc_bad_pts_info[i].leaf_id.objid)      &&
             (loc_sortpts_info[j].leaf_id.osnum == 
                       loc_bad_pts_info[i].leaf_id.osnum)      &&
             (loc_sortpts_info[j].u == loc_bad_pts_info[i].u)  &&
             (loc_sortpts_info[j].v == loc_bad_pts_info[i].v) )
                      
        {
          /* copy bad point to the bad_pts array */
          OM_BLOCK_MOVE ( &(sortpts_info[j]), &((*bad_pts_info)[i]), 
                             sizeof (struct EMSsortpt_info) );
          found_index = TRUE;
          break;
        }
  
     }
     if (!found_index)
     {
       *EMmsg = EMS_E_Fail;
       goto wrapup;
     }
   }
 }


 /*free the local bad_pts_info*/

 if (loc_bad_pts_info)
   om$dealloc(ptr=loc_bad_pts_info);

 wrapup:

  EMWRAPUP (*EMmsg, OM_stat, "EMSsurface.EMtrim_a_surface");

  if (copy_operand_2)
  {
   /*
    * If the operation has failed, cleanup the op2_elems
    */

   if (!(1 & OM_stat & *EMmsg))
   {
    for (i = 0; i < num_op2_elems; i++)
     OM_stat = om$send (msg = message GRgraphics.GRdelete (&mthd_stat,
                         op1_elem_env),
                        targetid = op2_cp_elems[i],
                        targetos = op1_elem_env->md_id.osnum);
   }

   if (num_op2_elems > OP2_BUF_SIZE)
    if (op2_cp_elems) om$dealloc (ptr = op2_cp_elems);

   if (copy_info.objid_array) om$dealloc (ptr = copy_info.objid_array);
  }


  return (OM_stat);

} 


end implementation EMSsurface;
