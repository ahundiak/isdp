/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method is the override for obtaining the geometry (vector) in
    model-space for a parametric vector.


  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification

*/

class implementation EMSparamvc;

#include "OMmacros.h"
#include "maptsxfor.h"

method EMgetgeom (IGRlong *msg; IGRushort opts;
                  IGRshort *mattyp; IGRmatrix mat;
                  struct EMSgeomdata *vecdata)
{
  IGRlong one=1;
  IGRlong msg_loc, stat_OM;
  IGRdouble *vec;
  IGRvector xform_vec;
int i;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  vec = ME.EMSparamvc->vec;

  if (*mattyp != MAIDMX)
    {
	IGRvector trans;
	trans[0] = mat[3]; trans[1] = mat[7]; trans[2] = mat[11];
	mat[3] = mat[7] = mat[11] = 0.0;

    	MAptsxform (&msg_loc, &one, mat, vec, xform_vec);
    	EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	
	mat[3] = trans[0]; mat[7] = trans[1]; mat[11] = trans[2];
    	vec = xform_vec;
    }

  vecdata->geomtype = GEOMDATA_VECTOR;
  OM_BLOCK_MOVE (vec, vecdata->vector, sizeof (IGRvector));

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpvcgetgeom");
  return (stat_OM);
}

end implementation EMSparamvc;
