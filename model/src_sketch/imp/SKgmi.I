class implementation SKgeometry;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/
#include <math.h>
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"

#include "matypemx.h"
#include "maoptsxfo.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bsnorvec.h"

#define BEGIN  0
#define CENTER 1
#define END    2


extern GRclassid OPP_GRcompcurve_class_id, OPP_GRbspline_class_id;
extern GRclassid OPP_SKpoint_class_id, OPP_SKline_class_id;
extern GRclassid OPP_SKarc_class_id, OPP_SKcircle_class_id;
extern GRclassid OPP_SKcompcurve_class_id, OPP_SKbspline_class_id;

from SKmgr 	 import SKgetornt, SKget_xymat;
from SKvariable  import SKgetvar;
from GRcompcurve import GRdetplane;
from GRbspline import GRdetplane;

method GRgetobjinfo (long *msg; struct GRobj_info *info)
{
  char      *type;
  GRclassid myclass;

  *msg = EMS_S_Success;

  type = info->type;
  om$get_classid (object = me, p_classid = &myclass);
  if (myclass == OPP_SKpoint_class_id)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfilePoint );
  }
  else if (myclass == OPP_SKline_class_id)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfileLine );
  }
  else if (myclass == OPP_SKarc_class_id)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfileArc );
  }
  else if (myclass == OPP_SKcircle_class_id)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfileCircle );
  }
  else if (myclass == OPP_SKcompcurve_class_id)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfileComposite );
  }
  else if (myclass == OPP_SKbspline_class_id)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfileBspline ); 
  }
  else
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_ProfileGeometry );
  }

  return OM_S_SUCCESS;
}


method SKcreate_self_constraints (long *msg; unsigned short opts;
                                  struct GRmd_env *md_env;
                                  int *num_cnstrs; GRobjid **cnstrs)
{
  *msg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

method GRdetplane(long *msg; short *matrix_type; IGRmatrix matrix; 
        struct IGRplane *plane)
{
 IGRboolean got_plane_info = FALSE;
 long status;
 long msg_loc;
 OM_S_OBJID sk_mgr_id;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;
 
 sk_mgr_id = NULL_OBJID;
 
 om$send (msg = message SKgeometry.SKgetmgr(&msg_loc, &sk_mgr_id),
          targetid = my_id);

 if (sk_mgr_id != NULL_OBJID)
 {
  status = om$send (msg = message SKmgr.SKgetornt(&msg_loc, plane->point,
                          NULL, plane->normal),
                    targetid = sk_mgr_id);
  if (1&status&msg_loc)
  {
   got_plane_info = TRUE;

   if ((*matrix_type) != MAIDMX)
   {
    IGRshort  rot_mx_type;
    long      one = 1;
    IGRmatrix rot_mx;

    OM_BLOCK_MOVE(matrix, rot_mx, sizeof (IGRmatrix));

    rot_mx[3] = 0.0;
    rot_mx[7] = 0.0;
    rot_mx[11] = 0.0;
    rot_mx[15] = 1.0;

    MAtypemx(&msg_loc,rot_mx, &rot_mx_type);
    if (!(1&msg_loc)) goto wrapup;
  
    MAoptsxform(&msg_loc,&one,&rot_mx_type,rot_mx,plane->normal,
               plane->normal);
    if (!(1&msg_loc)) goto wrapup;

    MAoptsxform(&msg_loc,&one,matrix_type,matrix,plane->point,
               plane->point);
    if (!(1&msg_loc)) goto wrapup;
   }
  }
 }

 if (!got_plane_info)
 {
  if (EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS, 
                          OPP_GRcompcurve_class_id, FALSE))
  {
   return (om$send (msg = message GRcompcurve.GRdetplane(msg,
                          matrix_type, matrix, plane),
                    mode = OM_e_wrt_message,
                    targetid = my_id));
  }
  else
  {
   return (om$send (msg = message GRbspline.GRdetplane(msg,
                          matrix_type, matrix, plane),
                    mode = OM_e_wrt_message,
                    targetid = my_id));
  }
 }

wrapup:
 return (status);
}

/*

Name
  SKcheck_degeneracy

Abstract
  This routine checks if any profile segment has degenerated.
  
Synopsis

Description
  Check if a segment degenerates.
  
Return Value

Notes

Index

Keywords
  profile

History
  11/03/93 : Rajiv Agrawal : created
  01/28/94 : Rajiv Agrawal : Changed calls to BSdistptpt to BSdistptpts to get 
			     a tighter control over degeneracy (TR119416380).
  03/31/94 : Satya         : Fix for TR 119313993 -- Improved degeneracy
                             Checking mechanism for arcs.
  01/09/94 : Satya         : Checked in the above fix into EMS3.2
  01/10/94 : Satya         : Changed calls to BSdistptpts back to BSdistptpt.
			     The change was leading to problems with design
			     files created in 2.2 . TR# 119421927

 */

method SKcheck_degeneracy (IGRlong *msg; IGRushort options; struct GRmd_env *md_env;
                           struct SKsolvevars *solvedvars;
                           GRobjid *degenerate)
{
  IGRushort 		gmtype;
  OMuint                num_pts, i, stat_OM;
  long                  msg_loc;
  double                lentol;
  IGRpoint              pts[4];
  struct SKsolvevars    *tmp;
  OM_S_OBJECT_LINKAGE   ptobjs[4];
  OM_S_CHANSELECT       chan_to_defpts;
  extern void           SKgetgeomtype();
  extern IGRboolean   	SKvarlistinx();
  IGRvector             beg_vec,end_vec;
  IGRboolean            status;
  IGRdouble             dotp;


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
  stat_OM = om$get_channel_objects (list = ptobjs, size = 4, 
                                    objid = my_id,
                                    p_chanselect = &chan_to_defpts,
                                    count = &num_pts);
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );

  for (i=0; i<num_pts; i++)
  {
    if (SKvarlistinx ( solvedvars, ptobjs[i].S_objid, VAR_X, &tmp, NULL ))
      pts[i][X] = tmp->var [X];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
    if (SKvarlistinx ( solvedvars, ptobjs[i].S_objid, VAR_Y, &tmp, NULL ))
      pts[i][Y] = tmp->var [Y];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
    pts[i][Z] = 0.0;
  }
  
  /*
   * Degeneracy checks based on the geometric element.
   */
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  SKgetgeomtype(my_id, OM_Gw_current_OS, &gmtype);
  if (gmtype & SK_LINE)
  {
    if (BSdistptpt(&msg_loc, pts[0], pts[1]) < lentol)
    {
      *msg = EMS_I_Degenerate;          
      if (degenerate)
        *degenerate = my_id;
    }
  }
  else if(gmtype & SK_ARC)
  {
    /*
     * Check for degenerate radius and sweep angle
     */
    if (BSdistptpt(&msg_loc, pts[0], pts[1]) < lentol || 
        BSdistptpt(&msg_loc, pts[0], pts[2]) < lentol)
    {
      *msg = EMS_I_Degenerate;          
      if (degenerate)
        *degenerate = my_id;
    }
    /*
     * Degeneracy could also arise due to the lines between center point and
     * end points becoming nearly parallel to each other
     * -- Fix for TR 119313993   -- Satya
     */
     else
     {
       for (i = 0; i < 3; i++)
       {
         beg_vec[i] = pts[BEGIN][i] - pts[CENTER][i];
         end_vec[i] = pts[END][i] - pts[CENTER][i];
       }
       status = BSnorvec (&msg_loc, beg_vec);
       status = BSnorvec (&msg_loc, end_vec);
       dotp = BSdotp (&msg_loc, beg_vec, end_vec);
       if(fabs(1.0 - dotp) < lentol)
       {
         *msg = EMS_I_Degenerate;
         if (degenerate)
           *degenerate = my_id;
       }
     }
  }
  
ret_end:  
  EMWRAPUP (*msg, stat_OM, "SKgeometry.SKcheck_degeneracy" );
  return (stat_OM);
}


extern GRclassid OPP_SKbspline_class_id;
from GRbcsubbc import debug;

method debug()
{
 OM_S_CHANSELECT  geom_pts_chan;
 GRclassid myclass;

 om$get_classid ( object = me, p_classid = &myclass );
 
 if (om$is_ancestry_valid ( subclassid = myclass,
         superclassid = OPP_SKbspline_class_id) == OM_S_SUCCESS)
 {
   om$send (mode = OM_e_wrt_message,
            msg = message GRbcsubbc.debug(), 
            targetid = my_id);
 }
 else 
 {
   om$send (mode = OM_e_wrt_parent,
            msg = message SKgeometry.debug(), 
            targetid = my_id);
 }

 EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);

 om$send (msg = message Root.debug(),
          p_chanselect = &geom_pts_chan);

 return (OM_S_SUCCESS);
}

end implementation SKgeometry;
