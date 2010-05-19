/* $Id: EMbcPostAb.I,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintersect / EMbcPostAb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EMbcPostAb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


/* ###################	 APOGEE COMPILED   ################## */
class implementation GRbcsubbc;

#include "EMS.h"
#include "bserr.h"
#include "marptsxfo.h"
#include "bsptlnplan.h"
#include "bscvtstclsd.h"
#include "bsbx2.h"
/*
DESCRIPTION

   This method posts the abstract data representation
   for a 3-D double precision subsurface back into the object's
   instance data.  The input structure contains a transformation
   matrix to be applied to the object before posting.

RETURN VALUES

   EMmsg		  completion code
			- MSSUCC if successful
			- GRSNOINVTRAN (severe) if input
			  matrix is not invertible
			- GRSDGNEXCEED (severe) if range
			  exceeds design limits
			- MANOMEMORY (severe) if no memory
			- MSFAIL (severe) if failure

   newobjid		used if object changes classes,
			otherwise is same as my_id

   NOTES

   If a failure occurs, the object's instance data will not be modified.

   Note that if the object id of the GRmodule object is passed in as the
   NULL_OBJID then no R-tree modifications will take place.  If you are
   doing this then be careful since there will be a mismatch.

   ALGORITHM

   This method converts the internal format (abstract geometry form) of
   the subsurface to its 3-D floating point permanent format (instance
   data). Before the instance data is modified, the internal format is
   transformed using inverse of the matrix in the input structure.  If
   the size of the object changes and is too large to be stored in the
   instance data, the instance data must be increased in size to hold
   the new object.  A new range for the object is then calculated and
   compared against the design limits.	If all tests pass, the instance
   data for the object is posted, including the range.	The updated
   object is inserted into the R-tree using the new range.  If the object
   is being constructed then the object is inserted in the R-tree.

   HISTORY

   10/14/91 : DLB : Check for non-NULL module id before trying to update
		    r-tree range.
   09/30/91 : DLB : Pass *int to BSbx2 rather than *short. - SUN ISSUE.
   03/02/89 : rlw : Modified to add conditional compilation statements
		    for the I/DRAW product.
   09/26/88 : rlw : Modified to call a different math routine to determine
		    planarity.	Colinear poles where not being properly
		    flagged as planar.
   02/22/88 : dhm : Added GR_NOTIFY_LISTENERS
   02/03/88 : DLB : Modified to give old range to GRupdaterng rather
		    than the first pole.  It seems this was causing
		    problems due to noise in the last bits of
		    of the poles which made the rtree check fail
		    (OM code does a bit wise comparison for
		    intersection).
   12/13/87 : rlw : Modified to perform planarity and physically closed
		    checks.
   11/17/87 : AIC : Do not attempt to add to the Rtree if
		    the module id is NULL_OBJID.
   04/02/87 : rlw : Radically modified due to instance data changes
   06/16/86 : KMO : Revision date.
   04/11/86 : REJ : Revision date.
   Sudha  06/16/93     Modified for BSprototype ansification
*/

# include "madef.h"	 /* Has MAIDMX */
# include "msdef.h"	 /* Has MSSUCC, MSFAIL */
# include "OMmacros.h"	 /* Has OM_BLOCK_MOVE + VLA macros */
# include "EMSerrordef.h"
# include "emserr.h"
# include "bstypes.h"
# include "godef.h"
# include "gocmacros.h"

from GRmodule import GRmdaddwrng;

method GRpostabsg(
  IGRlong *EMmsg;			/* Error return code */
  struct GRmd_env *md_env;		/* My module enviroment info */
  struct GRpost_info *post_info;	/* Post information */
  IGRchar *absptr;			/* Pointer to curve structure */
  GRobjid *newobjid)			/* Resultant id after posting */
{
  extern	 IGRlong GRpostrtransutil();
  IGRlong	 sts;
  GRrange	 new_range;
  struct	 IGRbsp_curve *curve;
  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;
  *newobjid = my_id;	/* Once a bcsubbc, always bcsubbc */
  curve = (struct IGRbsp_curve *) absptr;
  /*
   * Perform planarity and physically closed checks
   *
   * rlw - 12/13/87
   */
  if (curve->num_knots == 4)		/* Order 2, 2 poles */
   {
    curve->planar = TRUE;		/* To be consistent with lines */
    curve->phy_closed = FALSE;
   }
  else
   {
    IGRlong	loc_msg, planar_code;
    IGRvector	vector;

    BSptlnplan(
     curve->num_poles,
     curve->rational,
     (IGRpoint *)curve->poles,
     curve->weights,
     (IGRint *)&planar_code,		/* 1 point, 2 line, 3 plane, 4 non-planar */
     vector,
     &loc_msg);
    curve->planar = ((planar_code == 4) ? FALSE : TRUE);
    BScvtstclsd(
     curve,
     &loc_msg);
   }
  /*
   * Transform the poles to local coordinates and compute the new range
   */
  sts = GRpostrtransutil(EMmsg, md_env, post_info, &curve->num_poles,
			 &curve->rational, curve->weights, curve->poles,
			 new_range);
  if (! (1 & sts)) goto wrapup;

  /*
   * Update the range in the R-tree and possibly instance data
   */
  if (post_info->construct_flag)
  {
#ifndef IDRAW
    sts = om$send(msg = message GRvg.GRputrang(EMmsg, new_range),
		  targetid = my_id);
    if (!(1 & sts)) goto wrapup;
#endif
    if(md_env->md_id.objid != NULL_OBJID)
    {
      sts = om$send(msg = message GRmodule.GRmdaddwrng(EMmsg, new_range,
		    &my_id), targetid = md_env->md_id.objid);
      if (!(1 & sts)) goto wrapup;
    }
  } /* if (post_info->construct_flag) */
  else if(md_env->md_id.objid != NULL_OBJID) /*added if - DLB 10/14/91*/
  {
    GRrange	 old_range;
    IGRdouble	 *weight_ptr;
    IGRlong	 num_poles;
    extern	 IGRlong GRupdaterng();
    BSrc	 rc;
    IGRboolean	 bs_sts;

    /*DLB addition/modification 02/03/88*/
    weight_ptr = &me^^GRbcsubbc.packed_doubles[0] +
		 3 * me^^GRbcsubbc.num_poles;

    num_poles = ME.GRbcsubbc->num_poles;  /*SUN FIX - DLB*/

    /*Compute old range box.*/
    bs_sts = BSbx2(&rc,
		   &num_poles,
		   (IGRpoint *)&me^^GRbcsubbc.packed_doubles[0],
		   (me^^GRbcsubbc.bc_props & GRIS_RATIONAL)?weight_ptr:NULL,
		   &old_range[0],
		   &old_range[3]);
    if (!bs_sts) {*EMmsg = MSFAIL; goto wrapup;}
    /*End DLB stuff.*/

    sts = GRupdaterng(EMmsg, md_env, post_info, &my_id,
		      &me^^GRgraphics.properties, old_range, new_range);
    if (! (1 & sts)) { *EMmsg = MSFAIL; goto wrapup; }
    me^^GRgraphics.properties |= GRIS_MODIFIED;
  } /* ELSE FOR if (post_info->construct_flag) */

  /*
   * Update the control information in the instance data
   */
  me^^GRbcsubbc.order = curve->order;
  me^^GRbcsubbc.num_poles = curve->num_poles;
  me^^GRbcsubbc.bc_props = 0;
  if (curve->periodic) me^^GRbcsubbc.bc_props |= GRIS_PERIODIC;
  if (curve->non_uniform) me^^GRbcsubbc.bc_props |= GRIS_NON_UNIFORM;
  if (curve->rational) me^^GRbcsubbc.bc_props |= GRIS_RATIONAL;
  if (curve->phy_closed) me^^GRbcsubbc.bc_props |= GRIS_PHY_CLOSED;
  if (curve->planar)
    me^^GRgraphics.properties = me^^GRgraphics.properties | GRIS_PLANAR;
  else
    me^^GRgraphics.properties = me^^GRgraphics.properties & ~GRIS_PLANAR;

  /*
   * Fix the poles, weights, and knots
   */
  {
    IGRlong	  current_size, future_size;
    IGRdouble	  *double_ptr;

    current_size = OM_DIMENSION_OF(me^^GRbcsubbc.packed_doubles);
    future_size = curve->num_poles * (curve->rational ? 4 : 3) +
		  ((curve->non_uniform || curve->periodic)
		   ? curve->num_knots : 0);
/*
 * Eric FAIVRE ( 10/06/94 ) If the new number of poles is less than the old,
 * we keep the memory, hence the size of design file will not reduce !!!
 */
//    if (future_size > current_size)
      OM_SET_DIMENSION(me^^GRbcsubbc.packed_doubles, future_size);

    /*
     * Fix the poles
     */
    double_ptr = &me^^GRbcsubbc.packed_doubles[0];
    OM_BLOCK_MOVE(curve->poles, double_ptr,
		  curve->num_poles * sizeof(IGRpoint));
    double_ptr += curve->num_poles * 3;

    /*
     * Fix the weights
     */
    if (curve->rational)
    {
      OM_BLOCK_MOVE(curve->weights, double_ptr,
		    curve->num_poles * sizeof(IGRdouble));
      double_ptr += curve->num_poles;
    }

    /*
     * Fix the knots
     */
    if(curve->non_uniform || curve->periodic)
    {
      OM_BLOCK_MOVE(curve->knots, double_ptr,
		    curve->num_knots * sizeof(IGRdouble));
    }
  } /* Fix the poles, weights, and knots */

  /*
   * Transform the poles back to world coordinates in order to
   * restore the abstract geometry
   */
  if (md_env->md_env.matrix_type != MAIDMX)
  {
    IGRboolean	 status;

    status = MArptsxform(EMmsg, &curve->num_poles, &curve->rational,
			 curve->weights, md_env->md_env.matrix,
			 curve->poles, curve->poles);
    if (!status) { *EMmsg = MSFAIL; goto wrapup; }
  } /* if (md_env->md_env.matrix_type != MAIDMX) */

wrapup:
  EMWRAPUP(*EMmsg, sts, "GRbcsubbc.GRpostabsg")

  GR_NOTIFY_LISTENERS(EMmsg, &sts, GR_GEOM_POSTED);
  return(sts);
}

end implementation GRbcsubbc;
