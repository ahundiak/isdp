/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This file contains all the imnplementations for the class -
    EMSlawmgr. See EMSlawmgr.S for further explanation fo this classes
    functionality.
 
  HISTORY

    SS  :  08/24/89  :  Creation
*/

class implementation EMSlawmgr;

#include <string.h>
#include "OMmacros.h"
#include "gocmacros.h"

#define MATCH    0
#define INVALID -1

method EMinit (IGRlong *msg)
{
  *msg = EMS_S_Success;
  ME.EMSlawmgr->num_lawcvs = 0;
  return (OM_S_SUCCESS);
}

/*
 * The name and the curve-structure are inputs. After posting the curve
 * this method will return also the index at which the curve is stored.
 * This index can be used in a later access, just like the name.
 */
method EMputcv (IGRlong *msg; IGRchar *name; IGRint *cvinx;
                struct IGRbsp_curve *cv)
{
  IGRint i, vlasize, blksize, num_lawcvs;
  IGRlong stat_OM;
  struct IGRbsp_curve *cvmem;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  num_lawcvs = ME.EMSlawmgr->num_lawcvs;
  for (i=0; i<num_lawcvs; i++)
    if (strcmp (ME.EMSlawmgr->name_lawcvs[i], name) == MATCH)
      EMerr_hndlr (TRUE, *msg, EMS_I_NotUnique, ret_end);

  vlasize = om$dimension_of (varray = ME.EMSlawmgr->lawcvs);
  if (vlasize < num_lawcvs+1)
    {
    om$vla_set_dimension (varray = ME.EMSlawmgr->lawcvs,
     size = vlasize+1);
    om$vla_set_dimension (varray = ME.EMSlawmgr->size_lawcvs,
     size = vlasize+1);
    om$vla_set_dimension (varray = ME.EMSlawmgr->name_lawcvs,
     size = vlasize+1);
    }

  GRbc_size (cv->order, cv->num_poles, cv->rational, NULL, blksize);
  cvmem = (struct IGRbsp_curve *) om$malloc (size = blksize);
  EMerr_hndlr (!cvmem, *msg, EMS_E_NoDynamicMemory, ret_end);
  *cvmem = *cv;
  GRbc_partition (cvmem, cv->order, cv->num_poles, cv->rational, NULL);

  OM_BLOCK_MOVE (cv->poles, cvmem->poles, cv->num_poles * sizeof (IGRpoint));
  OM_BLOCK_MOVE (cv->knots, cvmem->knots, cv->num_knots * sizeof (IGRdouble));
  if (cv->rational)
    OM_BLOCK_MOVE (cv->weights, cvmem->weights, cv->num_poles *
     sizeof (IGRdouble));
  
  ME.EMSlawmgr->lawcvs[num_lawcvs] = cvmem;
  ME.EMSlawmgr->size_lawcvs[num_lawcvs] = blksize;
  strcpy (ME.EMSlawmgr->name_lawcvs[num_lawcvs], name);
  *cvinx = num_lawcvs;
  ME.EMSlawmgr->num_lawcvs++;
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSlaw.EMputcv");
  return (stat_OM);
}


/*
 * Given the name or an curve-index, this method will return the law curve
 * geometry, mallocing the space for it as one contiguouis buffer. Space
 * for both name and curve-index must be input. If name is "" on input, then
 * input index is used and the corresponding name returned. If the index
 * is -1 on input, then nput name is used and the corresponding index is
 * returned.
 */
method EMgetcv (IGRlong *msg; IGRchar *name; IGRint *cvinx;
                struct IGRbsp_curve **cv)
{
  IGRchar (*names)[MAX_CHAR+1];
  IGRint i, num_lawcvs, blksize;
  IGRlong stat_OM;
  struct IGRbsp_curve *cvptr, *cvmem;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  num_lawcvs = ME.EMSlawmgr->num_lawcvs;
  if (strlen (name))
    {
    *cvinx = -1;
    names = ME.EMSlawmgr->name_lawcvs;
    for (i=0; i<num_lawcvs; i++)
      if (strcmp (names[i], name) == MATCH)
        {
        *cvinx = i;
        break;
        }
    }
  EMerr_hndlr (*cvinx < 0 || *cvinx >= num_lawcvs, *msg, EMS_I_NotFound,
   ret_end);
    
  if (cv)
    {
    cvptr = ME.EMSlawmgr->lawcvs[*cvinx];

    GRbc_size (cvptr->order, cvptr->num_poles, cvptr->rational, NULL, blksize);
    cvmem = (struct IGRbsp_curve *) om$malloc (size = blksize);
    EMerr_hndlr (!cvmem, *msg, EMS_E_NoDynamicMemory, ret_end);
    *cvmem = *cvptr;
    GRbc_partition (cvmem, cvptr->order, cvptr->num_poles, cvptr->rational,
     NULL);

    OM_BLOCK_MOVE (cvptr->poles, cvmem->poles, cvptr->num_poles *
     sizeof (IGRpoint));
    OM_BLOCK_MOVE (cvptr->knots, cvmem->knots, cvptr->num_knots *
     sizeof (IGRdouble));
    if (cvptr->rational)
      OM_BLOCK_MOVE (cvptr->weights, cvmem->weights, cvptr->num_poles *
       sizeof (IGRdouble));
  
    *cv = cvmem;
    }

  if (!strlen (name))
    strcpy (name, ME.EMSlawmgr->name_lawcvs[*cvinx]);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMlaw.EMgetcv");
  return (stat_OM);
}

end implementation EMSlawmgr;
