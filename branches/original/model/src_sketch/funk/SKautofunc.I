class implementation SKmgr;

#include <math.h>
#include "igrtypedef.h"
#include "emsdef.h"
#include "msmacros.h"
#include "dimplcmacros.h"
#include "dimdef.h"
#include "dimangular.h"
#include "comisc.h"
#include "EMSopt.h"
#include "expression.h"
#include "ECmsg.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#define FIRST  0

from SKconstraint import SKinit, SKvalidate, SKcreate_geom, SKchgprops;
from SKexplicit   import SKputval;
from SKvariable	  import SKgetvar;
from EMSdatpln    import EMget_pln_info;
from expression   import NDgive_value, put_value, put_syntax;

/*

Name
  SKplace_constraint

Abstract
  This routine tries to place a constraint after proper validation.
  
Synopsis
  long            o	*msg		return code
  IGRushort       i	opts		options
  GRclassid       i	cnstrclass	classid
  IGRushort       i	cnstrprops	special constraint props
  struct GRmd_env i	*md_env		module env
  int             i	num_vgpts	number of ptvars that make up the constraint
  GRobjid         i	*vgpts		ids of the SKptvars
  struct GRid     o	*cnstr_grid	returned GRid of the created constraint

Description
 This routine will add a constraint to the profile.  Then check if conflicts with
 the existing constraints.  If so, the constraint will be deleted.
 
Return Value

Notes
 A NULL_OBJID will be returned if no constraint was created.
 All the constraints are marked as SK_USERADD so an Undo Profile will not delete them. 
 If the caller wants them to be available for undoing, then he should make a call
 to SKconstraint.SKchgprops and set the SK_NEWADD bit.

Index

Keywords
  constraint, create, validate
  
History
  10/12/93 : Rajiv Agrawal : created

 */
SKplace_constraint ( long            *msg,
                     IGRushort       opts,
                     GRclassid       cnstrclass,
                     IGRushort       cnstrprops,
                     struct GRmd_env *md_env,
                     int             num_vgpts,
                     GRobjid         *vgpts,
                     struct GRid     *cnstr_grid)
{
  IGRboolean      val_cnstr;
  IGRushort       loc_opts;
  int             num_conflict_cnstr;
  long            stat_OM, msg_loc;
  enum GRdpmode   dpmode;
  IGRboolean      aflag = 0;
  struct GRmd_env display_env;
  extern int	  IGEstop();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  if (IGEstop())
  {
    *msg = EMS_E_Stop;
    return (stat_OM);
  }
  
  loc_opts = SK_OPT_MARK_AS_USERADD;

  gr$get_module_env(buffer = &display_env);
  aflag = pwIsActivationOn();  

  cnstr_grid->objid = NULL_OBJID;
  stat_OM = om$construct (classid = cnstrclass,
                          osnum = md_env->md_id.osnum,
                          msg = message SKconstraint.SKinit (&msg_loc, loc_opts,
                                md_env, num_vgpts, vgpts, cnstrprops, NULL, NULL),
                          p_objid = &cnstr_grid->objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  cnstr_grid->osnum = md_env->md_id.osnum;
  stat_OM = om$send (msg = message SKconstraint.SKvalidate (&msg_loc,
                           NULL, md_env, &val_cnstr, &num_conflict_cnstr, NULL),
                     targetid = cnstr_grid->objid, targetos = cnstr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

  if (val_cnstr)
  {
    if (opts & SK_OPT_CREATE_GEOMETRY)
    {
      stat_OM = om$send ( msg = message SKconstraint.SKcreate_geom 
                                (&msg_loc, NULL, md_env, NULL),
                          targetid = cnstr_grid->objid, targetos = cnstr_grid->osnum,
                          senderid = NULL_OBJID);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

      if (opts & SK_OPT_CHECK_UNITS)
      /*
       * Since the geometric handle was created, see if we have to check if the units
       * convert flag for explicit dimensions needs to be set.
       */
      {
        stat_OM = SKset_units_convert_flag(&msg_loc, cnstr_grid);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
      }

      if (opts & SK_OPT_DISPLAY_GEOMETRY) 
      {
        dpmode = GRbd;

        stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &md_env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       md_env->md_env.matrix,
                                 &dpmode,
                                 aflag?&display_env.md_id:
                                 &md_env->md_id),
                          targetid = cnstr_grid->objid,
                          targetos = cnstr_grid->osnum,
                          senderid = NULL_OBJID);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      }
    }
  }
  else
  {  
     om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
              targetid = cnstr_grid->objid, targetos = cnstr_grid->osnum,
              senderid = NULL_OBJID);
     EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, OM_E_ABORT, ret_end );
     
     cnstr_grid->objid = NULL_OBJID;
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKplace_constraint");
  return (stat_OM);

}

SKcreate_sngl_parallel( msg, md_env, cnstr_grid, vgpts, planid, centpt)
long		*msg;
struct GRmd_env *md_env;
struct GRid 	cnstr_grid;
GRobjid 	*vgpts;
struct GRid 	planid;
IGRpoint	centpt;
{
  long			stat_OM, msg_loc;
  int 			i, trak_dir;
  double		dotp;
  IGRpoint      	pts[2], origpt;
  IGRvector		vec1, vec2, cross_vec, x_axis, y_axis, z_axis;
  struct GRid		line_id, dim_grid;
  enum GRdpmode 	dpmode;
  OM_S_CHANSELECT  	to_geom;
  IGRboolean            aflag = 0;
  struct   GRmd_env     display_env; 

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  gr$get_module_env(buffer = &display_env);
  aflag = pwIsActivationOn(); 
  EMmake_chanselect ( SKvariable_to_geometries, &to_geom);

  /*
   * Create a dimension handle on the constraint.
   */
  stat_OM = om$get_objid_at_index ( objid = vgpts[1], 
                                    osnum = md_env->md_id.osnum,
                                    p_chanselect = &to_geom,
                                    index = 0,
                                    objidaddr = &line_id.objid, osnumaddr = &line_id.osnum );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  
  dim_grid.objid = NULL_OBJID;
  
  /*
   * determine the track direction.
   */
  for (i=0; i < 2; i++) 
  {
    stat_OM = om$send ( msg = message SKvariable.SKgetvar(&msg_loc, NULL, 
                              &md_env->md_env.matrix_type, md_env->md_env.matrix,
                              (double *) pts[i]),
                        targetid = vgpts[i],
                        targetos = md_env->md_id.osnum,
                        senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  }

  stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info (&msg_loc,
                           NULL, md_env, x_axis, y_axis, z_axis, origpt, NULL),
                     targetid = planid.objid, targetos = planid.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  
  trak_dir = 1;
  BSmkvec (&msg_loc, vec1, pts[0], pts[1]);
  BSmkvec (&msg_loc, vec2, pts[0], centpt);
  BScrossp (&msg_loc, vec1, vec2, cross_vec);
  dotp = BSdotp (&msg_loc, cross_vec, z_axis);
  if (dotp > 0)
    trak_dir = 0;

  BSnorvec (&msg_loc, vec1);
  dotp = BSdotp (&msg_loc, vec1, x_axis);
  if (dotp > 0) 
    trak_dir = trak_dir == 0 ? 1 : 0;
  else if (dotp == 0)
  {
    dotp = BSdotp (&msg_loc, vec1, y_axis);
    if (dotp == 1.0)
      trak_dir = trak_dir == 0 ? 1 : 0;
  }
  dm$place_sglpara (orig_grid = &line_id,
                    orig_pt = pts[0],
                    plane_grid = &planid,
                    trak_dir = trak_dir, 
                    owner = &cnstr_grid, 
                    dim_grid = &dim_grid); 
  EMerr_hndlr (dim_grid.objid == NULL_OBJID, *msg, OM_E_ABORT, ret_end);
  
  dpmode = GRbd;

  stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                               aflag?&display_env.md_env.matrix_type:
                                     &md_env->md_env.matrix_type,
                               aflag?display_env.md_env.matrix:
                                     md_env->md_env.matrix,
                               &dpmode,
                               aflag?&display_env.md_id:
                               &md_env->md_id),
                        targetid = cnstr_grid.objid,
                        targetos = cnstr_grid.osnum,
                        senderid = NULL_OBJID);

  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  stat_OM = SKset_units_convert_flag( &msg_loc, &cnstr_grid);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

ret_end:
  return (stat_OM);
}
  
SKcreate_relang (msg, md_env, cnstr_grid, vgpts, planid)
long 		*msg;
struct GRmd_env *md_env;
struct GRid 	cnstr_grid;
GRobjid 	*vgpts;
struct GRid 	planid;
{
  long 			msg_loc, stat_OM;
  int  			i, sector;
  double		dotp;
  IGRpoint		pts[4], origpt;
  IGRvector		vec1, vec2, cross_vec, x_axis, z_axis;
  struct GRid 		line1_id, line2_id, dim_grid;
  OM_S_CHANSELECT  	to_geom;
  enum GRdpmode 	dpmode;
  IGRboolean            aflag = 0;
  struct  GRmd_env       display_env;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  aflag = pwIsActivationOn();
  gr$get_module_env(buffer = &display_env);  

  EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
  
  stat_OM = om$get_objid_at_index ( objid = vgpts[1], 
                                    osnum = md_env->md_id.osnum,
                                    p_chanselect = &to_geom,
                                    index = 0,
                                    objidaddr = &line1_id.objid, osnumaddr = &line1_id.osnum );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  
  stat_OM = om$get_objid_at_index ( objid = vgpts[3], 
                                    osnum = md_env->md_id.osnum,
                                    p_chanselect = &to_geom,
                                    index = 0,
                                    objidaddr = &line2_id.objid, osnumaddr = &line2_id.osnum );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
 
  
  for (i = 0; i < 4; i++) 
  {
    stat_OM = om$send ( msg = message SKvariable.SKgetvar(&msg_loc, NULL, 
                              &md_env->md_env.matrix_type, md_env->md_env.matrix,
                              (double *) pts[i]),
                        targetid = vgpts[i],
                        targetos = md_env->md_id.osnum,
                        senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  }
  
  stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info (&msg_loc,
                           NULL, md_env, x_axis, NULL, z_axis, origpt, NULL),
                     targetid = planid.objid, targetos = planid.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  
  /*
   * determine if the angle is to be measured clockwise or anti-clockwise.
   */
  BSmkvec (&msg_loc, vec1, pts[0], pts[1]);
  BSmkvec (&msg_loc, vec2, pts[2], pts[3]);
  BScrossp (&msg_loc, vec1, vec2, cross_vec);
  dotp = BSdotp (&msg_loc, cross_vec, z_axis);
  sector = 0;
  if (dotp > 0)
    sector |= CLOCK_WISE;
 
  dim_grid.objid = NULL_OBJID;
  dm$place_angular (orig_grid = &line1_id,
                    orig_pt = pts[1],
                    meas_grid = &line2_id,
                    meas_pt = pts[2],
                    plane_grid = &planid,
                    sector = sector, 
                    owner = &cnstr_grid,
                    dim_grid = &dim_grid);
  EMerr_hndlr (dim_grid.objid == NULL_OBJID, *msg, OM_E_ABORT, ret_end);

  dpmode = GRbd;

  stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                               aflag?&display_env.md_env.matrix_type:
                                     &md_env->md_env.matrix_type,
                               aflag?display_env.md_env.matrix:
                                     md_env->md_env.matrix,
                               &dpmode,
                               aflag?&display_env.md_id:
                               &md_env->md_id),
                        targetid = cnstr_grid.objid,
                        targetos = cnstr_grid.osnum,
                        senderid = NULL_OBJID);

  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );


  stat_OM = SKset_units_convert_flag (&msg_loc, &cnstr_grid);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
   
ret_end:
  return (stat_OM);
}

int SKget_degrees_of_freedom (msg, mgr_id, dof)
long	    *msg;
struct GRid mgr_id;
int	    *dof;
{
  long			stat_OM, msg_loc;
  struct SKsolvevars 	*varlist, *pvar;
  struct SKconstrinfo 	*constrs;
  int 			num_constrs, num_vars;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the list of variables and constraints for this system.
   */
  varlist = NULL;
  constrs = NULL;
  stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs 
                           (&msg_loc, NULL, &varlist, &num_constrs, &constrs),
                     targetid = mgr_id.objid, targetos = mgr_id.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /* count the number of variables */
  num_vars = 0;
  for (pvar = varlist, num_vars = 0; pvar; pvar = pvar->next, num_vars++);

  *dof = num_vars - num_constrs;
#if DEBUG
  printf("Number of variables = %d\n", num_vars);
  printf("Number of constraints = %d\n", num_constrs);
  printf("Profile has %d degrees of freedom\n", *dof);
#endif

ret_end:
  if (varlist)
    SKfreevarlist (varlist, MAXINT);
  if (constrs)
    om$dealloc (ptr = constrs);
  return (stat_OM);
}

SKfind_direction (msg, md_env, mgr_id, planid, direction)
long		*msg;
struct GRmd_env	*md_env;
struct GRid 	mgr_id, planid;
IGRint		*direction;
{
  long			stat_OM, msg_loc;
  OMuint		i, num_vars;
  struct GRid		varid;
  OM_S_CHANSELECT 	chan_to_vars;
  double		dotp;
  IGRpoint		pts[4], origpt;
  IGRvector		vec1, vec2, cross_vec, x_axis, z_axis;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMmake_chanselect(SKmgr_to_vars, &chan_to_vars);
  stat_OM = om$get_channel_count ( objid = mgr_id.objid, osnum = mgr_id.osnum,
                                   p_chanselect = &chan_to_vars,
                                   count = &num_vars );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );

  *direction = 0;
  if (num_vars > 3)
  {
    for (i= 0; i < 4; i++)
    {
      stat_OM = om$get_objid_at_index ( objid = mgr_id.objid, osnum = mgr_id.osnum,
                                        p_chanselect = &chan_to_vars,
                                        index = i,
                                        objidaddr = &varid.objid, osnumaddr = &varid.osnum );
      EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
      
      stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
                               &md_env->md_env.matrix_type, md_env->md_env.matrix,
                               (double *) pts[i]),
                         targetid = varid.objid,
                         targetos = varid.osnum,
                         senderid = NULL_OBJID);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    }
    stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info (&msg_loc,
                             NULL, md_env, x_axis, NULL, z_axis, origpt, NULL),
                       targetid = planid.objid, targetos = planid.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  
    BSmkvec (&msg_loc, vec1, pts[0], pts[1]);
    BSmkvec (&msg_loc, vec2, pts[1], pts[2]);
    BScrossp (&msg_loc, vec1, vec2, cross_vec);
    dotp = BSdotp (&msg_loc, cross_vec, z_axis);
    if (dotp > 0) 
      *direction = 1; 
  } 

ret_end:
  return (stat_OM);
}

SKfind_centroid (msg, md_env, mgr_id, centpt)
long		*msg;
struct GRmd_env	*md_env;
struct GRid 	mgr_id;
IGRpoint 	centpt;
{
  long			stat_OM, msg_loc;
  OMuint		i, j, num_vars;
  struct GRid		varid;
  OM_S_CHANSELECT 	chan_to_vars;
  IGRpoint		pt, min_pt, max_pt;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMmake_chanselect(SKmgr_to_vars, &chan_to_vars);
  
  stat_OM = om$get_channel_count ( objid = mgr_id.objid, osnum = mgr_id.osnum,
                                   p_chanselect = &chan_to_vars,
                                   count = &num_vars );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );

  for (i = 0; i<num_vars; i++)
  {
    stat_OM = om$get_objid_at_index ( objid = mgr_id.objid, osnum = mgr_id.osnum,
                                      p_chanselect = &chan_to_vars,
                                      index = i,
                                      objidaddr = &varid.objid, osnumaddr = &varid.osnum );
    EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
    
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
                             &md_env->md_env.matrix_type, md_env->md_env.matrix,
                             pt),
                       targetid = varid.objid,
                       targetos = varid.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    
    if (i == 0)
    {
      for (j = 0; j < 3; j++)
        min_pt[j] = max_pt[j] = pt[j];
    }
    else 
    {
      /*
       * update the maximum and minimum values of the coordinates
       */
      for (j = 0; j < 3; j++)
      {
        if (pt[j] < min_pt[j])
          min_pt[j] = pt[j];
        else if (pt[j] > max_pt[j])
          max_pt[j] = pt[j];
      }
    }
  }
  
  for (j = 0; j < 3; j++)
    centpt[j] = 0.5*(max_pt[j] + min_pt[j]);

ret_end:
  return (stat_OM);
}

SKset_units_convert_flag(long *msg, struct GRid *cnstr_grid)
{
  char 		syntax[EXP_MAX_LEN];
  long 		msg_loc, stat_OM;
  double 	value;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  stat_OM = om$send (msg = message expression.NDgive_value (&value),
                     targetid = cnstr_grid->objid,
                     targetos = cnstr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
      
  EMcnvt_db_dim_units (&msg_loc, cnstr_grid, &value, NULL, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_Modified)
  {
    stat_OM = om$send (msg = message SKconstraint.SKchgprops
                             (&msg_loc, EMS_O_ON, SK_UNITSCONVERT),
                       targetid = cnstr_grid->objid,
                       targetos = cnstr_grid->osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    
    /*
     * Change the instance data for the expression value and syntax also.
     */
    stat_OM = om$send (msg = message expression.put_value (value),
                       targetid = cnstr_grid->objid,
                       targetos = cnstr_grid->osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end);

    sprintf(syntax, "\\-1 = %lf", value);
    stat_OM = om$send (msg = message expression.put_syntax (syntax),
                       targetid = cnstr_grid->objid,
                       targetos = cnstr_grid->osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM), stat_OM, OM_E_ABORT, ret_end);
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKset_units_convert_flag");
  return (stat_OM);
}

end implementation SKmgr;


