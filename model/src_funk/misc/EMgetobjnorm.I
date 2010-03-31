class implementation EMSdim;

/*
  HISTORY

    Sudha	07/09/93	Modified for BSprototypes anisfication

*/

#include "OMmacros.h"
#include "bserr.h"
#include "exdef.h"
#include "exmacros.h"
#include "bststcvdegn.h"
#include "bsproj1.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bscollinmn2.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

extern GRclassid OPP_GRcurve_class_id, OPP_dim_plan_class_id;

void EMget_obj_normal (msg, opts, 
                       mattyp, mat, id,
                       plpr_mattyp, plpr_mat, plpr_id,
                       normal)
IGRlong *msg;
IGRushort opts;
IGRshort *mattyp;
IGRmatrix mat;
struct GRid *id;
IGRshort *plpr_mattyp;
IGRmatrix plpr_mat;
struct GRid *plpr_id;
IGRvector normal;
{
  IGRboolean normal_found, degn, collinear;
  IGRint i, j;
  IGRlong msg_loc, stat_OM;
  IGRdouble *p_plpr_mat;
  IGRpoint temp_point, pln_point, cvpts[2], *poles;
  IGRvector pln_normal, cvdir;
  GRclassid objclass;
  struct IGRbsp_curve *absgcv;
  struct GRmd_env md_env;
  struct ret_struct ret_struct;
  struct IGRplane plane;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  normal_found = FALSE;

  plane.point = pln_point;
  plane.normal = normal;

  stat_OM = om$send (msg = message GRvg.GRdetplane (&msg_loc, mattyp,
			 mat, &plane), 
	targetid = id->objid, targetos = id->osnum,
             senderid = NULL_OBJID);
  if (stat_OM == OM_W_UNKNOWN_MSG)
    {
    if ((md_env.md_env.matrix_type = *mattyp) != MAIDMX)
      OM_BLOCK_MOVE (mat, md_env.md_env.matrix, sizeof (IGRmatrix));

    stat_OM = ex$get_modid (mod_osnum = id->osnum,
               mod_id = &md_env.md_id.objid);
    EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end);
    md_env.md_id.osnum = id->osnum;

    ret_struct.type = NULL;
    stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
               &ret_struct, &md_env), targetid = id->objid,
               targetos = id->osnum, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (!(ret_struct.type & ref_generic), *msg, EMS_E_InvalidCase,
     ret_end);

    OM_BLOCK_MOVE (&ret_struct.var.ref_st.t[ZAXIS_PLANEMAT_INX], normal, 
     sizeof (IGRvector));
    normal_found = TRUE;
    }
  else if (msg_loc != MSSUCC) 
    {
    om$get_classid (objid = id->objid, osnum = id->osnum,
     p_classid = &objclass);
    if (om$is_ancestry_valid (subclassid = objclass,
         superclassid = OPP_GRcurve_class_id) == OM_S_SUCCESS &&
        plpr_id)
      {
      stat_OM = EMgetabsg (&msg_loc, mattyp, mat, id->osnum, id->objid,
                 &absgcv);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      BStstcvdegn (absgcv, &degn, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      EMerr_hndlr (degn, *msg, EMS_E_InvalidCase, ret_end);

      if (absgcv->num_poles > 2)
        {
        BScollinmn2 (absgcv->num_poles, (IGRpoint *)absgcv->poles, absgcv->weights,
         &collinear, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        EMerr_hndlr (!collinear, *msg, EMS_E_InvalidArg, ret_end);
        }
      else
        collinear = TRUE;
      EMerr_hndlr (!collinear, *msg, EMS_E_InvalidArg, ret_end);

      if (collinear)
        {
        if ((md_env.md_env.matrix_type = *plpr_mattyp) != MAIDMX)
          OM_BLOCK_MOVE (plpr_mat, md_env.md_env.matrix, sizeof (IGRmatrix));

        stat_OM = ex$get_modid (mod_osnum = plpr_id->osnum,
                   mod_id = &md_env.md_id.objid);
        EMerr_hndlr (EMSerror (stat_OM), stat_OM, FALSE, ret_end);
        md_env.md_id.osnum = plpr_id->osnum;

        om$get_classid (objid = plpr_id->objid, osnum = plpr_id->osnum,
         p_classid = &objclass);
        if (om$is_ancestry_valid (subclassid = objclass,
             superclassid = OPP_dim_plan_class_id) == OM_S_SUCCESS)
          {
          stat_OM = om$send (msg = message dim_plan.give_plane ((IGRint *)&msg_loc,
                     plpr_mat, &md_env),
                     targetid = plpr_id->objid, targetos = plpr_id->osnum,
                     senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          p_plpr_mat = plpr_mat;
          }
        else
          {
          stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
                     &ret_struct, &md_env), 
                     targetid = plpr_id->objid, targetos = plpr_id->osnum,
                     senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);
          EMerr_hndlr (!(ret_struct.type & ref_generic), *msg,
           EMS_E_InvalidCase, ret_end);
          p_plpr_mat = ret_struct.var.ref_st.t;
          }

        OM_BLOCK_MOVE (&p_plpr_mat[ZAXIS_PLANEMAT_INX], pln_normal,
         sizeof (IGRvector));
        pln_point[X] = p_plpr_mat[XORIG_PLANEMAT_INX];
        pln_point[Y] = p_plpr_mat[YORIG_PLANEMAT_INX];
        pln_point[Z] = p_plpr_mat[ZORIG_PLANEMAT_INX];

        poles = (IGRpoint *) absgcv->poles;
        for (i=FIRST; i<=SECOND; i++)
          {
          for (j=X; j<=Z; j++)
            cvpts[i][j] = poles[i][j] / 
                           (absgcv->rational ? absgcv->weights[i] : 1.0);
          BSproj1 (&msg_loc, cvpts[i], pln_normal, pln_point, temp_point);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
          OM_BLOCK_MOVE (temp_point, cvpts[i], sizeof (IGRpoint));
          }
        BSmkvec (&msg_loc, cvdir, cvpts[FIRST], cvpts[SECOND]);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        BScrossp (&msg_loc, cvdir, pln_normal, normal);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        BSnorvec(&msg_loc, normal);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        normal_found = TRUE;
        }
      }
    }
  else
    normal_found = TRUE;

  EMerr_hndlr (!normal_found, *msg, EMS_I_NotFound, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMget_obj_normal");
  return;
}

end implementation EMSdim;
