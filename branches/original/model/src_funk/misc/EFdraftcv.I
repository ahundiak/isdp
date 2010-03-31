/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

/********************************************************************

History
        RV    ?????       Creation Date.
        RC    04/20/88    Modified name, arguments and code
                          to accomodate the changes in the
                          processing flow.
        RC    05/03/89    Use ang_dis only if the off_code is BSCONSTOFF.
                          Otherwise, it may have a junk value.
        BL    05/24/90    Added error checking behind BScmpcvoff().
        ashok 07/18/90    Modified to tinker output of BScmpcvoff(),
                          if necessary, so that each component of input
                          composite curve has a corresponding component in
                          the output 'draft_cvs'
        AMD   02/01/92    Fix for TR 92n0494.
        AMD   02/15/92    Fix for TR 92n0936. If number of output
                          drafted curves is >= number of input curves
                          then do not introduce degenerate points.
        Sudha  07/08/93   Modified for BSprototypes ansification
        Rustagi 02/04/94  Fix for TR#119416701
        Hari    06/xx/95  We cannot have more than 1 gap between any 2 
                          offset curve with draft. If BS returns successive
                          -ve values, it indicates invalid draft-options and
                          we have to fail the operation. Fix for ABR. 

*********************************************************************/

#include "EMS.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif


#include <stdio.h>
%safe
#include <math.h>
%endsafe
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "bsicmpcvoff.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"
#include "bsnorkts.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bscvoffsetd.h"
#include "bscmpcvoff.h"
#include "bsalloccv.h"

#include "ECmsg.h" // for ex$message 
#include "msmacros.h"

void EFdraftcv(
       EFmsg, 
       num_cvs,
       cvs, 
       right_side, 
       draft_vec,
       is_uniform,
       ang_dis, 
       off_code, 
       phy_closed, 
       fillet,
       num_draft_cvs, 
       draft_cvs, 
       table)

  IGRlong               *EFmsg;
  struct IGRbsp_curve   **cvs, **draft_cvs;
  IGRint                num_cvs, *num_draft_cvs, *table, *off_code;
  IGRboolean            right_side, is_uniform, phy_closed, fillet;
  IGRvector             draft_vec;
  IGRdouble             *ang_dis;
{
 struct IGRbsp_curve  **rm_lps = NULL, *pt_crv;
 IGRdouble          dvec_len, from_pt[3], wt, ldraft_vec[3];

 IGRlong            OM_stat, rc, 
	            ind, knt, next_ind, chk_ind;
 IGRint             i, j, k, *rm_lps_table = NULL, num_rm_lps = 0;
 IGRboolean         status;
 IGRpoint	    link_pt;
 

 OM_stat = OM_S_SUCCESS;
 *EFmsg = EMS_S_Success;

 for (i = 0; i < 3; i++) from_pt[i] = 0.;

 for (i = 0; i < 3; i++) ldraft_vec[i] = draft_vec[i];

 dvec_len = BSdistptpt (&rc, from_pt, draft_vec);
 EMerr_hndlr (rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);

 status = BSnorvec (&rc, ldraft_vec);
 EMerr_hndlr (!status || rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

 if (is_uniform)
 {
    ang_dis[0] = (ang_dis[0] == 0.0 ? 0.0 : dvec_len*tan(ang_dis[0]));
 }
 else 
 {
  for (i = 0; i < num_cvs; i++)
    if (off_code[i] == BSCONSTOFF)
      ang_dis[i] = (ang_dis[i] == 0.0 ? 0.0 : dvec_len*tan(ang_dis[i]) );
 }

 if (num_cvs == 1)
 {
   BScvoffsetd(cvs[0], ang_dis[0], NULL, TRUE, (fillet ? 1 : 0),
               2, &right_side, ldraft_vec, draft_cvs, &num_rm_lps, 
               &rm_lps, &rc);
   EMerr_hndlr(rc != BSSUCC,*EFmsg,EMS_E_BSerror, wrapup);

   /* 
    * fix a math bug which does not set phy_closed 
    * on the offset curve 
    */

   if (cvs[0]->phy_closed) draft_cvs[0]->phy_closed = TRUE;

   *num_draft_cvs = 1;
   *table = 0;

 } /* if (num_cvs == 1) */

 else
 {

    BScmpcvoff(num_cvs, cvs, right_side, ldraft_vec, ang_dis, is_uniform,
               off_code, fillet, TRUE, phy_closed, num_draft_cvs, 
               draft_cvs, table, &num_rm_lps,  &rm_lps, &rm_lps_table, 
               &rc);

    /* BL 05/24/90 : detect if the returned draft_cvs are OK */
    /* EMerr_hndlr(num_cvs > *num_draft_cvs, *EFmsg, EMS_E_BSerror, wrapup); */

    EMerr_hndlr(rc == BSINARG, *EFmsg, EMS_E_InvalidArg, wrapup);
    EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

    /* EMerr_hndlr(! *num_draft_cvs, *EFmsg, EMS_I_Fail, wrapup); */

    if ( *num_draft_cvs && (num_cvs > *num_draft_cvs))  /* AMD : 02/15/92 */
    {
     /* Check if any of the components of the input composite curve does'nt
        have corresponding curve in the returned draft_cvs. If not construct
        appropriate degenerate curve (ie point) and insert it into the
        'draft_cvs' array. Also update the 'table' array. -Ashok
      */ 

      knt = *num_draft_cvs;
      for(i=knt; i < 2*num_cvs +1 ; i++)
	table[i] = 0;
      for(i=0, next_ind=0, chk_ind=0; (i < num_cvs || i < knt); i++, next_ind++)
      {
	if(table[next_ind] < 0) continue;
	if(table[next_ind] != chk_ind)
	{
	   /* construct point and insert it in the draft_cvs array */
	   pt_crv = NULL;
	   BSalloccv(2, 2, 0, 0, &pt_crv, &rc);
           EMerr_hndlr(rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);

	   ind = (next_ind == *num_draft_cvs ? 0 : next_ind);
           for(j = 0; j < 3; j++)
           {
               link_pt[j] = draft_cvs[ind]->poles[j];
               if(draft_cvs[ind]->rational) 
                  link_pt[j] /= draft_cvs[ind]->weights[0];
           } /* for(j = 0; j < 3; j++) */

           BSptcvgen(link_pt, 2, FALSE, pt_crv, &rc);
           EMerr_hndlr(rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);

	   for(j = *num_draft_cvs; j > next_ind; j--)
	   {
		table[j] = table[j-1];
		draft_cvs[j] = draft_cvs[j-1];
	   }
	   table[next_ind] = chk_ind;
	   draft_cvs[next_ind] = pt_crv;
	   *num_draft_cvs = *num_draft_cvs + 1;
	}
	   chk_ind++;
      }
    } /* if( num_cvs != *num_draft_cvs) */

    /*
     * table[0:res_num_crvs-1] values must not have more than 1 successive
     * -ve values. i.e we cannot have more than 1 gap between any 2 offset
     * curve with draft. If BS returns successive -ve values, it indicates
     * invalid draft-options and we have to fail the operation. Hari
     */

    {
      IGRboolean flag1 = FALSE;
      IGRint aft_gap,bef_gap,ix;

      for(ix = 0; ix < *num_draft_cvs; ix++)
      {
        aft_gap = (ix+1 == *num_draft_cvs ? 0 : table[ix+1]);
        bef_gap = (ix == 0 ? table[*num_draft_cvs - 1] : table[ix-1]);
        if((bef_gap < 0 && table[ix] < 0 ) || (table[ix] < 0 && aft_gap <0))
                                                           flag1=TRUE;
       }
       if (flag1) 
       {
         ex$message(msgnumb = EMS_E_OperationFailed);
         *EFmsg = EMS_E_InvalidArg; goto wrapup;
        }
     }

 } /* else for if (num_cvs == 1) */


 /*
  * Translate the offset curves with draft vector.
  */

  for (i = 0; i < *num_draft_cvs; i++)
  {
     /*
      * Normalize the knot_vector of the offset_curve if it is not so.
      */

     status = BSnorkts (&rc, &draft_cvs[i]->order, 
                        &draft_cvs[i]->num_poles, draft_cvs[i]->knots);
     EMerr_hndlr (rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);

     for(j = 0; j < draft_cvs[i]->num_poles; j++)
     {
       if (draft_cvs[i]->rational)
       {
         wt = draft_cvs[i]->weights[j];
         for (k = 0; k < 3; k++)
            (draft_cvs[i]->poles[3*j+k]) += draft_vec[k]*wt;

       } /* if (draft_cvs[i]->rational) */

       else 
         for (k = 0; k < 3; k++)
            (draft_cvs[i]->poles[3*j+k]) += draft_vec[k];

     } /* for(j = 0; j < draft_cvs[inx]->num_poles; j++) */

  } /* for (i = 0; i < *num_draft_cvs; i++) */

wrapup:
  /*
   * Dealloc removed loops in case math returns it.
   */

  for (i = 0; i < num_rm_lps; i++)
    if (rm_lps && rm_lps[i]) BSfreecv(&rc, rm_lps[i]);
  if (rm_lps) om$dealloc(ptr = rm_lps);
  if (rm_lps_table) om$dealloc (ptr = rm_lps_table);

  EMWRAPUP(*EFmsg, OM_stat, "In EFdraftcv");
  return;
}


end implementation Root;
