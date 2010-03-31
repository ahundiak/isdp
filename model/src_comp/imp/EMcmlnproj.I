class implementation EMScomposite;

#include "EMScc.h"
/*
Description
     This method projects a line onto a composite object.

Return values
     msg         EMS_S_Success - successful
                 EMS_E_Fail - severe error
     ln_pt       line project point
     proj_pt     project point on object
     t           line project point parameter
     proj_parms  curve project point parameters

History:
    RC  12/03/86 : Creation date
	dhm 10/19/87 : Added code to get the leaf_id of the curve project on.
    DLB 10/29/87 : Modified channel for version 1.1.0
    SM  24-Nov-87: Fixed the reversed addresses in OM_BLOCK_MOVE macros.
    RC  21-Mar-88  Changed the logic to fix a bug.
    rlw 01/29/89   Modified to work around a problem which occurs when
                   one of the elements of a composite is rather small.
                   In such cases MAlnlbproj() fails due to tolerancing
                   problems.
    Sudha 06/16/93 Modified to include for BSprototype ansification

*/

#include <stdio.h>
#include "bsparameters.h"
#include "bserr.h"
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "EMSerrordef.h"
#include "emsdef.h"
#include "emserr.h"
#include "OMmacros.h"
#include "malnlbpro.h"
#include "malncuber.h"
#include "maidmx.h"
#include "ma2pt2di.h"

method GRlnproject(IGRlong *msg; IGRshort *mat_type;
                   IGRmatrix matrix; struct IGRline *line;
                   IGRpoint ln_pt,proj_pt; IGRdouble *t;
                   struct GRparms *proj_parms)

{
  IGRdouble                    tpar, lnpr_min_dis, cbln_min_dis, 
                               dis, tolerance = 0., dis_tol;
  extern IGRdouble             fabs();

  IGRpoint                     sf_prjpt,  ln_prjpt;

  GRrange                      range;

  IGRlong                      OM_stat;                      

  IGRint                       i, ln_prj_idx, *un_lnprj_idx,
                               num_un_lnprj_idx;
  OMuint                       numb_comp;

  IGRboolean                   status, world_range_needed = TRUE;
  IGRshort                     relation = 1 ;

  struct IGRlbsys             range_cube;
  struct GRparms              parms;
  OM_S_CHANSELECT             composite_chan;
  


  OM_stat = OM_S_SUCCESS;
  *msg = MSSUCC;
  un_lnprj_idx = NULL;

  composite_chan.type = OM_e_addr;
  composite_chan.u_sel.addr = &ME.GRcmpowner->to_components;

  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &composite_chan,
                                 count = &numb_comp);
  if (!(1 & OM_stat)) goto wrapup;

  if (!numb_comp) goto wrapup;

  un_lnprj_idx = (IGRint *) om$malloc (size = numb_comp * sizeof(IGRint));
  EMerr_hndlr (!un_lnprj_idx, *msg, EMS_E_NoDynamicMemory,wrapup);

  /* Initalize variables */

  status = MAidmx(msg, range_cube.matrix);
  if (!(1 & status & *msg)) goto wrapup;
 
  status = BSEXTRACTPAR(msg, BSTOLLENVEC, dis_tol);
  lnpr_min_dis = GRDGNLIMITS_MAX_D;
  cbln_min_dis = GRDGNLIMITS_MAX_D;
 
  for ( i = 0; i < numb_comp; i++)
  {
       OM_stat = om$send(msg = message GRvg.GRgetrang(msg, mat_type,
                               matrix, &world_range_needed, range),
                         p_chanselect = &composite_chan,
                         from = i, to = i);
       if (!(1 & OM_stat & *msg)) goto wrapup;

       /*If the range box, degenerates to line, call the 
        * line project. As the line project will always
        * be invoked in this case, there is no need to 
        * find out whether the range box intersects the 
        * line or not.
        */

       if ( ( ( fabs(range[0] - range[3]) <= dis_tol ) && 
              ( fabs(range[1] - range[4]) <= dis_tol ) ) ||
            ( ( fabs(range[0] - range[3]) <= dis_tol ) && 
              ( fabs(range[2] - range[5]) <= dis_tol ) ) ||
            ( ( fabs(range[1] - range[4]) <= dis_tol ) && 
              ( fabs(range[2] - range[5]) <= dis_tol ) ) )
       {
          relation = 1;
       }
       else
       {
         /*Find out if the line intersect the range box*/
         status = MAlncuberel(msg, line, range, &range[3], &tolerance,
                              &relation);
         if (!(1 & status & *msg)) goto wrapup;      
       }

       if (relation != 1)
       {
         /* 
          * Project the line on the range cube
          */

         OM_BLOCK_MOVE(range, range_cube.diag_pt1, sizeof(IGRpoint));
         OM_BLOCK_MOVE(&range[3], range_cube.diag_pt2, sizeof(IGRpoint));

         status = MAlnlbproj(msg, line, &range_cube, ln_prjpt,
                             sf_prjpt, &tpar);
         if (!(1 & status & *msg))
         {
          *msg = MSSUCC;
          relation = 1;
         }
         else
         {
           status = MA2pt2dis(msg,ln_prjpt,sf_prjpt,&dis);
           if (!(1 & status & *msg)) goto wrapup; 
               
           if( dis < (cbln_min_dis - dis_tol) )
           {
             cbln_min_dis = dis;
             un_lnprj_idx[0] = i;
             num_un_lnprj_idx = 1;
           }
           else if (!(dis > (cbln_min_dis + dis_tol)))
           {
             un_lnprj_idx[num_un_lnprj_idx++] = i;
           }
         }
       } /* if (relation != 1) */

       if (relation == 1)
       {

           OM_stat = om$send(msg = message GRvg.GRlnproject(msg, mat_type,
                              matrix, line, ln_prjpt, sf_prjpt, &tpar,
                             &parms),
                            p_chanselect = &composite_chan,
                            from = i, to = i);
           if (!(1 & OM_stat & *msg)) goto wrapup;
       
           status = MA2pt2dis(msg,ln_prjpt,sf_prjpt,&dis);
           if (!(1 & status & *msg)) goto wrapup;

           if( dis < lnpr_min_dis )
           {
             lnpr_min_dis = dis;
             OM_BLOCK_MOVE(ln_prjpt, ln_pt, sizeof(IGRpoint));
             OM_BLOCK_MOVE(sf_prjpt, proj_pt, sizeof(IGRpoint));
             *t = tpar;
             *proj_parms = parms;
             ln_prj_idx = i;
           }

       } /* if (relation == 1) */

  } /* for ( i = 0; i < numb_comp; i++) */

  if (cbln_min_dis < lnpr_min_dis)
  {
    for (i = 0; i < num_un_lnprj_idx; i++)
    {
       OM_stat = om$send(msg = message GRvg.GRlnproject(msg, mat_type,
                          matrix, line, ln_prjpt, sf_prjpt, &tpar,
                          &parms),
                        p_chanselect = &composite_chan,
                        from = un_lnprj_idx[i], to = un_lnprj_idx[i]);
       if (!(1 & OM_stat & *msg)) goto wrapup;
       
       status = MA2pt2dis(msg,ln_prjpt,sf_prjpt,&dis);
       if (!(1 & status & *msg)) goto wrapup;

       if( dis < lnpr_min_dis )
       {
         lnpr_min_dis = dis;
         OM_BLOCK_MOVE(ln_prjpt, ln_pt, sizeof(IGRpoint));
         OM_BLOCK_MOVE(sf_prjpt, proj_pt, sizeof(IGRpoint));
         *t = tpar;
         *proj_parms = parms;
         ln_prj_idx = un_lnprj_idx[i];
       }

    } /* for (i = 0; i < num_un_lnprj_idx; i++) */

  } /* if (cbln_min_dis < lnpr_min_dis) */

  /*
   * get leaf_id
   */

/*
  OM_stat = om$get_objid_at_index(object = me,
                         p_chanselect = &composite_chan,
                         index = ln_prj_idx,
                         objidaddr = &proj_parms->leaf_id.objid,
                         osnumaddr = &proj_parms->leaf_id.osnum);
  if (!(1 & OM_stat)) goto wrapup;
*/

wrapup:
  if (un_lnprj_idx) om$dealloc (ptr = un_lnprj_idx);

  EMWRAPUP(*msg, OM_stat, "In EMScomposite.GRlnproj")
  return( OM_stat );

}
end implementation EMScomposite;


