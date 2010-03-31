/*
  The following functions reside in this file:

void EMgetmdenv (md_env, mattyp, mat, os)
struct GRmd_env *md_env;
IGRshort *mattyp;
IGRmatrix mat;
GRspacenum os;
*/

#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "madef.h"
#include "maerr.h"
#include "exdef.h"
#include "exmacros.h"
#include "bserr.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "bsgeom_cvsf.h"

/*
  DESCRIPTION

    Short hand way of getting the GRmd_env when one only has mattyp,
    mat and the OS.
*/

void EMgetmdenv (md_env, mattyp, mat, os)
struct GRmd_env *md_env;
IGRshort *mattyp;
IGRmatrix mat;
GRspacenum os;
{
  if (mattyp && mat)
    {
    if ((md_env->md_env.matrix_type = *mattyp) != MAIDMX)
      OM_BLOCK_MOVE (mat, md_env->md_env.matrix, sizeof (IGRmatrix));
    }
  else
    md_env->md_env.matrix_type = MAIDMX;
    
  md_env->md_id.objid = NULL_OBJID;
  ex$get_modid (mod_osnum = os, mod_id = &md_env->md_id.objid);
  md_env->md_id.osnum = os;

  return;
}

