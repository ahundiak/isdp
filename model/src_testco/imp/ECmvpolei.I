class implementation ECmvpole;


/*
Abstract
   This command object will modify a B-spline element by moving a pole
    in its geometry.

Algorithm
    If the element is a curve of type other than GRbcsubbc, then this
    command changes the class of it to GRbcsubbc and toggles the polygon
    on.  If the polygon display is off (for either a curve or surface),
    then this command toggles it on.

Notes
    This is a rewrite of the command object ECmvpole (with some changes
    added) written by siki on 10/04/86.

History
    dhm    7/6/87    Creation date
    dhm    8/14/87   changed to handle surfaces too.
    dhm    8/20/87   changed to dehilite after a locate, toggle polygon
                     off if originally off when backing up to first
                     state, and added a delete method.
    dhm    1/12/88   converted to 1.1.0.
    dhm    6/13/88   added maintain tangency at endpoints if requested.
    dhm    11/14/88  added maintain z view if requested.
    DLB    10/29/91  cast tan & z depth to short in trans.
    dhm    10/27/93  changed to locate components of GRcompcurve, SKcompcurve,
                     or SKmgr.
    dhm    10/29/93  un-COB'ed it.
*/

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "godef.h"
#include "lcmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "ECcmd_def.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "EMSssprops.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grmessage.h"
#include "EMSutlmacros.h"

#define EMS_CK_TANGENCY 101
#define EMS_INV_POLE    102

from GRgraphics import GRdisplay, GRgetprops, GRdelete;
from GRvg import GRgetattr, GRputattr, GRkeypoint, GRmodify;
from GRvg import GRdynmod, GRgetsize, GRgetgeom;
from GRlistener import GRnotifylis;

extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_SKcompcurve_class_id;
extern OMuword OPP_SKmgr_class_id;


#define _start 0
#define _map_zview 1
#define _start_id 2
#define _locate_ele 3
#define _input_pole 4
#define _maintain_tangent 5
#define _input_new_pos 6
#define _not_mod 7


method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message ECcmd.init(type, str_ptr),
                   targetid = my_id);
  EMomerr_hndlr(status, quit, "ECcmd init");

  me->tangency_cond = FALSE;
  me->zview_cond = FALSE;
  me->polydis = TRUE;
  me->chg_class_flag = FALSE;
  me->has_owner = FALSE;
  me->objid = NULL_OBJID;
  me->located_obj[0].located_obj.objid = NULL_OBJID;
  me->tan_line.point1 = NULL;
  me->tan_line.point2 = NULL;

quit:
  return OM_S_SUCCESS;
}


method delete ( int f_defer_flag )
{
  int		  status = OM_S_SUCCESS;

  status = om$send(msg = message ECmvpole.delete_obj(&me->objid, FALSE),
                   targetid = my_id);
  EMomerr_hndlr(status, quit, "delete method:ECmvpole.delete_obj\n");

  status = om$send(mode = OM_e_wrt_message,
                   msg = OPPmargs,
                   targetid = my_id);
  EMomerr_hndlr(status, quit, "send to ECmvpole's parent delete\n");

  if (me->tan_line.point1)  om$dealloc(ptr = me->tan_line.point1);
  if (me->tan_line.point2)  om$dealloc(ptr = me->tan_line.point2);
  me->tan_line.point1 = NULL;
  me->tan_line.point2 = NULL;

quit:
  return OM_S_SUCCESS;
}


method turn_poly_off ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong			msg;
  struct IGResbc	esbc;
  struct IGResbs	esbs;
  IGRchar			*esb;

  if (!me->polydis)
  {
     if (me->mytype == CURVE)
       esb = (IGRchar *) &esbc;
     else
       esb = (IGRchar *) &esbs;

     status = om$send(msg = message GRvg.GRgetattr(&msg, esb),
                      targetid = me->objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, quit, "GRgetattr error");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, quit);

     me->DisplayMode = GRbe;
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                      senderid = my_id,
                      targetid = me->objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, quit, "GRdisplay error\n");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, quit);

     if (me->mytype == CURVE)
         esbc.is_polydis = me->polydis;
     else
         esbs.is_polydis = me->polydis;

     status = om$send(msg = message GRvg.GRputattr(&msg, esb),
                      targetid = me->objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, quit, "GRputattr error");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, quit);

     me->DisplayMode = GRbd;
     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                      senderid = my_id,
                      targetid = me->objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, quit, "GRdisplay error\n");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, quit);

     me->polydis = TRUE;
  }

quit:
  return OM_S_SUCCESS;
}


method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

  struct cond_str
  {
    IGRboolean  tangency_cond;
    IGRboolean  zview_cond;
  };

  IGRlong		msg;
  IGRint		(*dum_func)() = NULL;
  IGRchar		*dum_buff;
  struct GRparms dum_parms;
  enum GRdyn_flag dum_action;
  struct cond_str  cond;

  cond.tangency_cond = me->tangency_cond;
  cond.zview_cond = me->zview_cond;
  dum_buff = (IGRchar *)&cond;

  *sts = OM_S_SUCCESS;
  switch (dynamics)
    {
      case dynmod:
        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRdynmod(&msg,
                               &me->located_obj[0].module_info.md_env.
                               matrix_type, me->located_obj[0].
                               module_info.md_env.matrix, &dum_parms,
                               me->pole, &dum_action, dum_buff,
                               (IGRboolean (*)())dum_func),
                         senderid = my_id,
                         targetid = me->objid,
                         targetos = me->located_obj[0].located_obj.osnum);
        EMomerr_hndlr(status, quit, "GRdynmod error");
        EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);
        break;

      default:
        status = om$send(mode = OM_e_wrt_message,
                         msg = OPPmargs,
                         senderid = my_id,
                         targetid = my_id);
        EMomerr_hndlr(status, quit, "dynamics error");
        break;
    }

quit:
  return OM_S_SUCCESS;
}


method delete_obj (GRobjid *objid; IGRboolean reinitialize)
{
  int		  status = OM_S_SUCCESS;

  IGRlong	msg;

  if (me->chg_class_flag)
  {
     status = om$send(msg = message GRgraphics.GRdelete(&msg,
                            &me->located_obj[0].module_info),
                      targetid = *objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, quit, "GRdelete error");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, quit);

     *objid = NULL_OBJID;
     me->chg_class_flag = FALSE;
  }
  else if (reinitialize)
     *objid = NULL_OBJID;

quit:
  return OM_S_SUCCESS;
}


method check_ancestry ( long * sts )
{
  int		  status = OM_S_SUCCESS;

 IGRshort          props;
 OM_S_CHANSELECT   to_owner;

 *sts = MSSUCC;
 me->has_owner = FALSE;

 /*
  * Check the located object's ancestry to see if it is a component of a
  * profile, composite profile, or a composite curve. First, check the object's
  * properties for a rigid relationship and then check the class of the owner
  * for SKmgr, SKcompcurve, and GRcompcurve. If the object has no owner,
  * then it is okay to process it.
  */

 if (me->mytype != CURVE)
     goto quit;

 status = om$send(msg = message GRgraphics.GRgetprops(sts, &props),
                  targetid = me->event1.located_object[0].located_obj.objid,
                  targetos = me->event1.located_object[0].located_obj.osnum);
 EMomerr_hndlr(status, quit, "ECmvpole.check_ancestry : GRgetprops");
 EMerr_hndlr(EMis_error(*sts), me->ret, OM_E_ABORT, quit);

 if (props & GR_RIGID_RELATIONSHIP)  /* object has a rigid owner */
 {
     me->has_owner = TRUE;

     /*
      * Now let's see if it's one of the ones we want.
      */

     ems$make_chanselect(chan_label = GRconnector_to_owners,
                         chan_selector = &to_owner);

     status = om$get_objid_at_index(
                        osnum = me->event1.located_object[0].located_obj.osnum,
                        objid = me->event1.located_object[0].located_obj.objid,
                        p_chanselect = &to_owner,
                        index = 0,
                        objidaddr = &me->owner_id.objid,
                        osnumaddr = &me->owner_id.osnum);

     status = om$get_classid(osnum = me->owner_id.osnum,
                             objid = me->owner_id.objid,
                             p_classid = &me->owner_classid);
     EMomerr_hndlr(status, quit, "ECmvpole.check_ancestry : om$get_classid");

     status = om$is_ancestry_valid(subclassid = me->owner_classid,
                                   superclassid = OPP_SKmgr_class_id);

     if (status != OM_S_SUCCESS)
     {
         status = om$is_ancestry_valid(subclassid = me->owner_classid,
                                      superclassid = OPP_SKcompcurve_class_id);

         if (status != OM_S_SUCCESS)
         {
             status = om$is_ancestry_valid(subclassid = me->owner_classid,
                                      superclassid = OPP_GRcompcurve_class_id);

             if (status != OM_S_SUCCESS)
             {
                 me->has_owner = FALSE;
                 *sts = MSFAIL;
             }
         }
     }
 }

quit:
  return OM_S_SUCCESS;
}


method change_class (IGRchar *new_class)
{
  int		  status = OM_S_SUCCESS;

  IGRlong		msg, EMget_the_geometry(), EMchgclass();
  IGRboolean	chan_flag, del_flag;
  struct IGRbsp_curve	*crv;
  IGRshort		properties;
  struct GRid           my_GRid;
  OMuword               obj_classid;

  extern OMuword  OPP_GRbcsubbc_class_id;
  crv = NULL;

  if (me->located_obj[0].located_obj.objid == NULL_OBJID)
     goto ret_end;

  me->objid = me->located_obj[0].located_obj.objid;

  /*
   * Get the classname of the object
   * and compare it to GRbcsubbc to
   * see if need to change class.
   */

  status = om$get_classid(osnum = me->located_obj[0].located_obj.osnum,
                          objid = me->located_obj[0].located_obj.objid,
                          p_classid = &obj_classid);
  EMomerr_hndlr(status, ret_end, "get_classid error");

  status = om$is_ancestry_valid(subclassid = obj_classid,
                                superclassid = OPP_GRbcsubbc_class_id);

  if ( (me->mytype == CURVE) && (status != OM_S_SUCCESS) )
  {
     /*
      * Get the geometry of the curve
      * and change the class so can
      * toggle the polygon display on.
      */

     status = EMget_the_geometry(&me->located_obj[0], TRUE, FALSE, FALSE,
                                 my_id, &crv, &msg);
     EMomerr_hndlr(status, ret_end, "EMget_the_geometry error");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, ret_end);

     status = om$send(msg = message GRgraphics.GRgetprops(&msg,
                            &properties),
                      targetid = me->located_obj[0].located_obj.objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, ret_end, "GRgetprops error");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, ret_end);

     chan_flag = TRUE;
     del_flag = FALSE;
     my_GRid.objid = me->located_obj[0].located_obj.objid;
     my_GRid.osnum = me->located_obj[0].located_obj.osnum;

     status = EMchgclass(&msg, &me->located_obj[0].module_info,
                         my_GRid, new_class,
                         (IGRushort *)&properties, crv, &chan_flag, &del_flag,
                         &me->objid);
     EMomerr_hndlr(status, ret_end, "EMchgclass error");
     EMerr_hndlr(EMis_error(msg), me->ret, OM_E_ABORT, ret_end);

     me->chg_class_flag = TRUE;
  }

ret_end:
  if (crv) free(crv);
  return OM_S_SUCCESS;
}


method turn_poly_on ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong		msg;
  struct IGResbc esbc;
  struct IGResbs esbs;
  IGRchar        *esb;

  /*
   * Get the attributes of the curve
   * to see if the polygon display is
   * on or off.  If off, then turn it
   * on.
   */

  if (me->objid != NULL_OBJID)
  {
     if (me->mytype == CURVE)
       esb = (IGRchar *) &esbc;
     else
       esb = (IGRchar *) &esbs;

     status = om$send(msg = message GRvg.GRgetattr(&msg, esb),
                      targetid = me->objid,
                      targetos = me->located_obj[0].located_obj.osnum);
     EMomerr_hndlr(status, quit, "GRgetattr error");
     EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

     if (me->mytype == CURVE ? !esbc.is_polydis : !esbs.is_polydis)
     {
        me->DisplayMode = GRbe;
        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                         senderid = my_id,
                         targetid = me->objid,
                         targetos = me->located_obj[0].located_obj.osnum);
        EMomerr_hndlr(status, quit, "GRdisplay error\n");
        EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);

        me->polydis = (me->mytype == CURVE ? esbc.is_polydis :
                                             esbs.is_polydis);
        if (me->mytype == CURVE)
            esbc.is_polydis = GRIS_POLYDIS;
        else
            esbs.is_polydis = EMSIS_POLYDIS;

        status = om$send(msg = message GRvg.GRputattr(&msg, esb),
                         targetid = me->objid,
                         targetos = me->located_obj[0].located_obj.osnum);
        EMomerr_hndlr(status, quit, "GRputattr error");
        EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

        me->DisplayMode = GRbd;
        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                         senderid = my_id,
                         targetid = me->objid,
                         targetos = me->located_obj[0].located_obj.osnum);
        EMomerr_hndlr(status, quit, "GRdisplay error\n");
        EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);
     }
  }

quit:
  return OM_S_SUCCESS;
}


method keypoint_pole ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRpoint		pnt1, pnt2; 
  IGRlong		msg;
  struct GRparms dum_parms;
  struct IGRline boreline;

  boreline.point1 = pnt1;  /* allocates storage for */
  boreline.point2 = pnt2;  /* the boreline          */

  status = EFboreline(&msg, my_id, &me->event1, &boreline);
  EMerr_hndlr(EMis_error(status)||EMis_error(msg), *sts, MSFAIL, quit);

  dum_parms.u = 5.0;  /* kludge for the tolerance */
  status = om$send(msg = message GRvg.GRkeypoint(&msg,
                        &me->located_obj[0].module_info.md_env.matrix_type,
                        me->located_obj[0].module_info.md_env.matrix,
                        &boreline, me->pole, &dum_parms),
                   targetid = me->objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, quit, "GRkeypoint error");
  EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

quit:
  return OM_S_SUCCESS;
}


method check_for_endpoint ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong               msg_loc;
  IGRint                last_pole;
  IGRdouble             dist_pole1, dist_pole2, 
                        dist_pole3, dist_pole4;
  extern IGRdouble      BSdistptpt();
  IGRdouble             tol;
  struct IGRbsp_curve  *crv;
  struct GRlc_info      obj_info;
  IGRlong               EMget_the_geometry();

  crv = NULL;

  if ( (me->mytype == SURFACE) || ( me->zview_cond && !(me->has_owner) ) )
    goto ret_end;

  obj_info.located_obj.objid = me->objid;
  obj_info.located_obj.osnum = me->located_obj[0].located_obj.osnum;
  obj_info.module_info.md_env.matrix_type =
           me->located_obj[0].module_info.md_env.matrix_type;
  OM_BLOCK_MOVE(me->located_obj[0].module_info.md_env.matrix,
                obj_info.module_info.md_env.matrix, sizeof(IGRmatrix) );

  status = EMget_the_geometry(&obj_info, TRUE, FALSE, FALSE, my_id, &crv,
                              &msg_loc);
  EMomerr_hndlr(status, ret_end, "EMget_the_geometry error\n");
  EMerr_hndlr(EMis_error(msg_loc), *sts, OM_E_ABORT, ret_end);

  status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, tol);

  dist_pole1 = BSdistptpt(&msg_loc, me->pole, &crv->poles[0]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  dist_pole2 = BSdistptpt(&msg_loc, me->pole, &crv->poles[3]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  last_pole = (crv->num_poles - 1) * 3;
  dist_pole3 = BSdistptpt(&msg_loc, me->pole, &crv->poles[last_pole-3]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  dist_pole4 = BSdistptpt(&msg_loc, me->pole, &crv->poles[last_pole]);
  EMerr_hndlr(msg_loc != BSSUCC, *sts, OM_E_ABORT, ret_end);

  if ( (dist_pole1 <= tol) || (dist_pole2 <= tol) )
  {
    if (me->has_owner)  /* can't modify start poles of a component object */
    {
        *sts = EMS_INV_POLE;
        goto ret_end;
    }
    else
        *sts = EMS_CK_TANGENCY;

    if (!me->tan_line.point1)
    {
      me->tan_line.point1 = (IGRdouble *) om$malloc( size = 3 *
                                                     sizeof(IGRdouble) );
      EMerr_hndlr(!me->tan_line.point1, *sts, OM_E_ABORT, ret_end);
    }

    if (!me->tan_line.point2)
    {
      me->tan_line.point2 = (IGRdouble *) om$malloc( size = 3 *
                                                     sizeof(IGRdouble) );
      EMerr_hndlr(!me->tan_line.point2, *sts, OM_E_ABORT, ret_end);
    }

    me->tan_line.point1[0] = crv->poles[0];
    me->tan_line.point1[1] = crv->poles[1];
    me->tan_line.point1[2] = crv->poles[2];
    me->tan_line.point2[0] = crv->poles[3];
    me->tan_line.point2[1] = crv->poles[4];
    me->tan_line.point2[2] = crv->poles[5];
  }
  else if ( (dist_pole3 <= tol) || (dist_pole4 <= tol) )
  {
    if (me->has_owner)  /* can't modify end poles of a component object */
    {
        *sts = EMS_INV_POLE;
        goto ret_end;
    }
    else
        *sts = EMS_CK_TANGENCY;

    if (!me->tan_line.point1)
    {
      me->tan_line.point1 = (IGRdouble *) om$malloc( size = 3 *
                                                     sizeof(IGRdouble) );
      EMerr_hndlr(!me->tan_line.point1, *sts, OM_E_ABORT, ret_end);
    }

    if (!me->tan_line.point2)
    {
      me->tan_line.point2 = (IGRdouble *) om$malloc( size = 3 *
                                                     sizeof(IGRdouble) );
      EMerr_hndlr(!me->tan_line.point2, *sts, OM_E_ABORT, ret_end);
    }

    me->tan_line.point1[0] = crv->poles[last_pole-3];
    me->tan_line.point1[1] = crv->poles[last_pole-2];
    me->tan_line.point1[2] = crv->poles[last_pole-1];
    me->tan_line.point2[0] = crv->poles[last_pole];
    me->tan_line.point2[1] = crv->poles[last_pole+1];
    me->tan_line.point2[2] = crv->poles[last_pole+2];
  }

ret_end:
  if (crv) free(crv);
  return OM_S_SUCCESS;
}


method set_cond (IGRboolean  *value, condition)
{

  *value = condition;

  return OM_S_SUCCESS;
}


method process ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong	msg;
  struct IGRline	boreline;
  struct GRparms	dum_parms;

  msg = OM_S_SUCCESS;

  boreline.point2 = NULL;
  if (me->tangency_cond)
  {
    IGRboolean    fn_sts;
    extern IGRboolean  MAptlnproj();
    IGRpoint      point, proj_pt;
    IGRlong       msg_loc;
    IGRdouble     t;

    point[0] = me->event1.event.button.x;
    point[1] = me->event1.event.button.y;
    point[2] = me->event1.event.button.z;

    fn_sts = MAptlnproj(&msg_loc, point, &me->tan_line, proj_pt, &t);
    if (!fn_sts)  goto ret_end;

    boreline.point1 = &proj_pt[0];
  }
  else if (me->zview_cond)
  {
    IGRlong    EMmap_button_to_z_view();

    status = EMmap_button_to_z_view(&msg, me->pole,
                                    &me->event1.event.button);
    EMomerr_hndlr(status, ret_end, "EMmap_button_to_z_view error\n");
    EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);

    boreline.point1 = &me->event1.event.button.x;
  }
  else
    boreline.point1 = &me->event1.event.button.x;

  me->DisplayMode = GRbe;
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                   senderid = my_id,
                   targetid = me->objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);

  status = om$send(msg = message GRvg.GRmodify(&msg,
                         &me->located_obj[0].module_info, &dum_parms,
                         me->pole, &boreline, &me->objid),
                   targetid = me->objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "GRmodify error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, ret_end);

/* 
 * Commented the following line. This deletes the new object
 * created.  -- RC 01/16/90
 */           
/*
  if (me->objid != me->located_obj[0].located_obj.objid)
      me->located_obj[0].located_obj.objid = me->objid;
*/

ret_end:
  me->DisplayMode = GRbd;
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                   senderid = my_id,
                   targetid = me->objid,
                   targetos = me->located_obj[0].located_obj.osnum);
  EMomerr_hndlr(status, quit, "GRdisplay error\n");
  EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);

  me->pole[0] = boreline.point1[0];
  me->pole[1] = boreline.point1[1];
  me->pole[2] = boreline.point1[2];
  
  if (me->mytype == CURVE && me->has_owner)
  {
    if (me->owner_classid == OPP_GRcompcurve_class_id)
    {
      long mask = GR_GEOM_POSTED;
      OMuint count;
      OM_S_CHANSELECT chandef;

      om$make_chanselect(channame = "GRnotify.notification",
                         p_chanselect = &chandef);

      status = om$get_channel_count( objid = me->owner_id.objid,
                                     osnum = me->owner_id.osnum,
                                     p_chanselect = &chandef,
                                     count = &count);
      if ((1 & status) && (count))
      {
        /* send notification to the listeners   */

        status = om$send( msg = message GRlistener.GRnotifylis
                                (&msg,&msg,&mask,OPPmargs),
                          senderid = me->owner_id.objid,
                          targetos = me->owner_id.osnum,
                          p_chanselect = &chandef);
      }
    }
    else
    {
      nd$wait_batch(type = GR_GEOM_POSTED,
                    nb_obj = 1,
                    l_object = &me->owner_id);
    }

  }

quit:
  return OM_S_SUCCESS;
}


method arg_name_to_value( int addr_mode ; char * class_name ; char * arg ;
                     COB_arg_union * data ; int * ret_type ; char * is_const )
{
/* Incoming arguments
    int           addr_mode;     == _COB_regular  for regular data
                                 == _COB_indirect for "*<arg>"      
                                 == _COB_address  for "&<arg>"      

    char        * class_name;    not NULL => argname used to start  
                                 with "me(class_name)->" of some  
                                 form; now this has been stripped 
                                 NULL => original arg had no "me->" 

    char        * arg;           arg string to find a value for     


   Outgoing arguments
    COB_arg_union * data;        value of arg string variable       

    int         * ret_type;      type of value found for arg string
                                 (see COB_arg.h)                  

    char        * is_const;      set to 1 => this variable value is 
                                 "constant" and needn't be looked 
                                 up ever again                    

   Description
    translate a string into its variable name value
    Jeff Johnson's code.
*/

  int		  status = OM_S_SUCCESS;


  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )	/*** arg string used to begin with "me->" ***/
    {
	/**************************************************************/
	/*		  ECmvpole instance data		      */
	/**************************************************************/
      if ( !strcmp(arg, "objid") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->oid = ME.ECmvpole->objid;
	      * ret_type = _COB_arg_oid;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmvpole->objid;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmvpole->objid ***/

    else if ( !strcmp(arg, "zview_cond") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->oid = ME.ECmvpole->zview_cond;
	      * ret_type = _COB_arg_oid;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmvpole->zview_cond;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmvpole->zview_cond ***/

    else if ( !strcmp(arg, "tangency_cond") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->oid = ME.ECmvpole->tangency_cond;
	      * ret_type = _COB_arg_oid;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmvpole->tangency_cond;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmvpole->tangency_cond ***/

    } /* end if class_name[0] */
  else	/*** arg string did not begin with "me->" ***/
    {
    }

	/*** if it's unknown, send it to parent ***/
  if ( * ret_type == _COB_UNKNOWN_ARG )
    {
      status = om$send ( targetid = my_id,
			 mode = OM_e_wrt_message,
			 msg = message ECcmd.arg_name_to_value (
					addr_mode, class_name, arg,
					data, ret_type, is_const ) );
      _check ( status );
    }


quit:
  return OM_S_SUCCESS;
}

end implementation ECmvpole;
