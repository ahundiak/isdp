/* $Id: SMint.I,v 1.3 2001/05/09 15:55:25 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/api/SMint.I
 *
 * Description: Surface Frame Intersections
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMint.I,v $
 *      Revision 1.3  2001/05/09 15:55:25  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/05/09 15:46:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/18  18:57:18  pinnacle
# SurfaceFrame
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  12/17/97  ah      Creation
 *  05/10/01  ylong   CR5128, reverse x values if needed for SfFrPts
 * -------------------------------------------------------------------*/

class implementation Root;

#include "VDmaster.h"

#include "vdAPImacros.h"

from GRlinear   import GRgetpolyline;
from SMframe 	import SMfind_frame_num;
from SMfrm_syst import SMfind_all_frame;

/* ---------------------------------------------
 * Prints a line segment out
 */
IGRstat SMintPrintLineSeg(TGRid *id, TGRmd_env *md_env, FILE *file)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRpolyline polyLine;
  IGRdouble   point[6];

  IGRint      action;

  polyLine.points = point;
  action = 0;
  sts = om$send(
    msg = message GRlinear.GRgetpolyline(
      &msg,
      &md_env->md_env.matrix_type,
       md_env->md_env.matrix,
      &action,
      &polyLine
    ),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );

  // Make sure it is a linear
  if (!(sts & msg & 1)) {
    printf("Problem with getting line segment for\n");
    // VDbroPrintObj(id);
    goto wrapup;
  }
  
  if (polyLine.num_points != 2) {
    printf("Multiple point data for\n");
    //VDbroPrintObj(id);
    goto wrapup;
  }

  action = 1;
  sts = om$send(
    msg = message GRlinear.GRgetpolyline(
      &msg,
      &md_env->md_env.matrix_type,
      md_env->md_env.matrix,
      &action,
      &polyLine
    ),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );

  if (file) {
//    fprintf(file,"SEG: %15.6f %15.6lf %15.6f\n",point[0],point[1],point[2]);
//    fprintf(file,"     %15.6f %15.6lf %15.6f\n",point[3],point[4],point[5]);
  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Prints a point out
 */
IGRstat SMintPrintPoint(TGRid *id, TGRmd_env *md_env, FILE *file, IGRshort revFlag)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRpolyline polyLine;
  IGRdouble   point[3];

  IGRint      action;
  TGRbsp_curve *bsp = NULL;

  polyLine.points = point;
  action = 0;
  sts = om$send(
    msg = message GRlinear.GRgetpolyline(
      &msg,
      &md_env->md_env.matrix_type,
       md_env->md_env.matrix,
      &action,
      &polyLine
    ),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );

  // Make sure it is a linear
  if (!(sts & msg & 1)) {

    // Sometimes get very tiny curve
    if (vd_$is_ancestry_valid(
        object  = id, 
        classid = OPP_GRcurve_class_id) == 0
      ) {

      printf("Problem with getting point data for\n");
      //VDbroPrintObj(id);
      goto wrapup;
    }
   
    sts = vd_$get_geometry(
      msg = &msg,
      grobjId  =  id,
      grobjEnv =  md_env,
      geometry = &bsp
    );

    if (!(sts & msg & 1)) {
      printf("Problem with getting point data for\n");
      //VDbroPrintObj(id);
      goto wrapup;
    }

    point[0] = bsp->poles[0];
    point[1] = bsp->poles[1];
    point[2] = bsp->poles[2];
  }

  else {

    if (polyLine.num_points != 1) {
      printf("Multiple point data for\n");
      //VDbroPrintObj(id);
      goto wrapup;
    }

    action = 1;
    sts = om$send(
      msg = message GRlinear.GRgetpolyline(
        &msg,
        &md_env->md_env.matrix_type,
        md_env->md_env.matrix,
        &action,
        &polyLine
      ),
      senderid = NULL_OBJID,
      targetid = id->objid,
      targetos = id->osnum
    );
  }

  if( revFlag ) point[0] = -point[0];

  if (file) {
    fprintf(file,"%15.6f %15.6lf %15.6f\n",point[0],point[1],point[2]);
  }

wrapup:
  _FREE(bsp);
  return retFlag;
}

/* ---------------------------------------------
 * Intersects surface with two frame systems
 * Frame with Frame then Surface
 */
IGRstat SMintSrfPlaneSystems(
  TGRobj_env *srf,
  TGRobj_env *fra1,
  TGRobj_env *fra2,
  IGRshort    revFlag
)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  struct {
    IGRint     i;
    IGRint     cnt;
    IGRint    *fraNum;
    IGRint     low,high;
    TGRid     *ids;
    TGRobj_env obj;
  } frx1,frx2,crv,pnt;

  TGRmd_env md_env;

  IGRchar status[128];
  FILE   *file = NULL;

  // Need Module Env Later */
  gr$get_module_env(buffer = &md_env);

  // Reset Frame Information
  memset(&frx1,0,sizeof(frx1));
  memset(&frx2,0,sizeof(frx2));
  memset(&crv, 0,sizeof(crv ));
  memset(&pnt, 0,sizeof(pnt ));

  // Point File
  file = fopen("points.txt","wt");

  // Get Frame Plane Objects
  sts = om$send(
    msg = message SMfrm_syst.SMfind_all_frame(
      &msg,
      &frx1.ids,
      &frx1.fraNum,
      &frx1.cnt,
      &frx1.low,
      &frx1.high
    ),
    senderid = NULL_OBJID,
    targetid = fra1->obj_id.objid,
    targetos = fra1->obj_id.osnum
  );
  __CheckRC( sts, msg, "SMfrm_syst.SMfind_all_frame", wrapup );

  // Get Frame Plane Objects
  sts = om$send(
    msg = message SMfrm_syst.SMfind_all_frame(
      &msg,
      &frx2.ids,
      &frx2.fraNum,
      &frx2.cnt,
      &frx2.low,
      &frx2.high
    ),
    senderid = NULL_OBJID,
    targetid = fra2->obj_id.objid,
    targetos = fra2->obj_id.osnum
  );
  __CheckRC( sts, msg, "SMfrm_syst.SMfind_all_frame", wrapup );

  //if (frx1.cnt > 2) frx1.cnt = 2;
  //if (frx2.cnt > 2) frx2.cnt = 2;

  for(frx1.i = 0; frx1.i < frx1.cnt; frx1.i++) {

    for(frx2.i = 0; frx2.i < frx2.cnt; frx2.i++) {

      frx1.obj.mod_env = fra1->mod_env;
      frx1.obj.obj_id  = frx1.ids[frx1.i];

      frx2.obj.mod_env = fra2->mod_env;
      frx2.obj.obj_id  = frx2.ids[frx2.i];

      crv.cnt = 0;
      crv.ids = NULL;

      sprintf(status,"Intersecting Frame %d ...",frx1.i + frx1.low);
      UI_status(status);

      sts = vd$int2elem(
        elem1 = &frx1.obj,
        elem2 = &frx2.obj,
        trim1req =  0,
        trim2req =  0,
        NumbInt  = &crv.cnt,
        GRidInt  = &crv.ids
      );

      if (!(sts & 1)) {
        printf("Problem Intersecting Frame Planes\n");
        //VDbroPrintObj(&frx1.ids[frx1.i]);
        //VDbroPrintObj(&frx2.ids[frx2.i]);
        goto wrapup;
      }

      // vd_$bulk_display(theEnv = &md_env, count = crv.cnt, grids = crv.ids);

      for(crv.i = 0; crv.i < crv.cnt; crv.i++) {

        //VDbroPrintObj(&crv.ids[crv.i]);
        SMintPrintLineSeg(&crv.ids[crv.i],&md_env,file);
        
        crv.obj.mod_env = md_env;
        crv.obj.obj_id  = crv.ids[crv.i];

        pnt.cnt = 0;
        pnt.ids = NULL;;

        sts = vd$int2elem(
          elem1 =  srf,
          elem2 = &crv.obj,
          trim1req = 2,
          trim2req = 0,
          NumbInt  = &pnt.cnt,
          GRidInt  = &pnt.ids
        );

        if (!(sts & 1)) {
//        printf("Problem Intersecting with hull surface\n");
//        VDbroPrintObj(&crv.obj.obj_id);
//        goto wrapup;
        }

        vd_$bulk_display(theEnv = &md_env, count = pnt.cnt, grids = pnt.ids);

        for(pnt.i = 0; pnt.i < pnt.cnt; pnt.i++) {
          SMintPrintPoint(&pnt.ids[pnt.i],&md_env,file, revFlag);
        }
        _FREE(pnt.ids);
        pnt.ids = NULL;
      }
    }

    vd_$bulk_delete(theEnv = &md_env, count = crv.cnt, grids = crv.ids);
    _FREE(crv.ids);
    crv.ids = NULL;
  }

  UI_status("Done ");

wrapup:
  _FREE(frx1.fraNum);
  _FREE(frx1.ids);

  _FREE(frx2.fraNum);
  _FREE(frx2.ids);

  _FREE(crv.ids);
  _FREE(pnt.ids);

  if (file) fclose(file);

  return retFlag;
}
/* ---------------------------------------------
 * Intersects surface with two frame systems
 * Surface with Frame then Frame
 */
IGRstat SMintSrfPlaneSystemsX(
  TGRobj_env *srf,
  TGRobj_env *fra1,
  TGRobj_env *fra2
)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  struct {
    IGRint     i;
    IGRint     cnt;
    IGRint    *fraNum;
    IGRint     low,high;
    TGRid     *ids;
    TGRobj_env obj;
  } frx1,frx2,crv,pnt;

  TGRmd_env md_env;

  IGRchar status[128];
  FILE   *file = NULL;

  // Need Module Env Later */
  gr$get_module_env(buffer = &md_env);

  // Reset Frame Information
  memset(&frx1,0,sizeof(frx1));
  memset(&frx2,0,sizeof(frx2));
  memset(&crv, 0,sizeof(crv ));
  memset(&pnt, 0,sizeof(pnt ));

  // Point File
  file = fopen("points.txt","wt");

  // Get Frame Plane Objects
  sts = om$send(
    msg = message SMfrm_syst.SMfind_all_frame(
      &msg,
      &frx1.ids,
      &frx1.fraNum,
      &frx1.cnt,
      &frx1.low,
      &frx1.high
    ),
    senderid = NULL_OBJID,
    targetid = fra1->obj_id.objid,
    targetos = fra1->obj_id.osnum
  );
  __CheckRC( sts, msg, "SMfrm_syst.SMfind_all_frame", wrapup );

  // Get Frame Plane Objects
  sts = om$send(
    msg = message SMfrm_syst.SMfind_all_frame(
      &msg,
      &frx2.ids,
      &frx2.fraNum,
      &frx2.cnt,
      &frx2.low,
      &frx2.high
    ),
    senderid = NULL_OBJID,
    targetid = fra2->obj_id.objid,
    targetos = fra2->obj_id.osnum
  );
  __CheckRC( sts, msg, "SMfrm_syst.SMfind_all_frame", wrapup );

//  if (frx1.cnt > 20) frx1.cnt = 2;

  for(frx1.i = 0; frx1.i < frx1.cnt; frx1.i++) {

    frx1.obj.mod_env = fra1->mod_env;
    frx1.obj.obj_id  = frx1.ids[frx1.i];

    crv.cnt = 0;
    crv.ids = NULL;

    sprintf(status,"Intersecting Frame %d ...",frx1.i + frx1.low);
    UI_status(status);

    sts = vd$int2elem(
      elem1 =  srf,
      elem2 = &frx1.obj,
      trim1req =  2,
      trim2req =  0,
      NumbInt  = &crv.cnt,
      GRidInt  = &crv.ids
    );

    if (!(sts & 1)) {
      printf("Problem Intersecting with hull surface\n");
      //VDbroPrintObj(&frx1.ids[frx1.i]);
      goto wrapup;
    }

    // vd_$bulk_display(theEnv = &md_env, count = crv.cnt, grids = crv.ids);

    for(crv.i = 0; crv.i < crv.cnt; crv.i++) {

      crv.obj.mod_env = md_env;
      crv.obj.obj_id  = crv.ids[crv.i];
 
      for(frx2.i = 0; frx2.i < frx2.cnt; frx2.i++) {

        frx2.obj.mod_env = fra2->mod_env;
        frx2.obj.obj_id  = frx2.ids[frx2.i];

        pnt.cnt = 0;
        pnt.ids = NULL;;

        sts = vd$int2elem(
          elem1 = &crv.obj,
          elem2 = &frx2.obj,
          trim1req = 0,
          trim2req = 0,
          NumbInt  = &pnt.cnt,
          GRidInt  = &pnt.ids
        );

        if (!(sts & 1)) {
          printf("Problem Intersecting with hull surface\n");
          //VDbroPrintObj(&frx1.ids[frx1.i]);
          //VDbroPrintObj(&frx2.ids[frx2.i]);
          goto wrapup;
        }

        vd_$bulk_display(theEnv = &md_env, count = pnt.cnt, grids = pnt.ids);

        for(pnt.i = 0; pnt.i < pnt.cnt; pnt.i++) {
          SMintPrintPoint(&pnt.ids[pnt.i],&md_env,file, 0);
        }
        _FREE(pnt.ids);
        pnt.ids = NULL;
      }
    }

    vd_$bulk_delete(theEnv = &md_env, count = crv.cnt, grids = crv.ids);
    _FREE(crv.ids);
    crv.ids = NULL;
  }

  UI_status("Done intersecting first frame set");

wrapup:
  _FREE(frx1.fraNum);
  _FREE(frx1.ids);

  _FREE(frx2.fraNum);
  _FREE(frx2.ids);

  _FREE(crv.ids);
  _FREE(pnt.ids);

  if (file) fclose(file);

  return retFlag;
}
/* ---------------------------------------------
 * Intersects surface with frame systems
 * Just leaves the curves behind
 */
IGRstat SMintSrfPlaneSystemsY(
  TGRobj_env *srf,
  TGRobj_env *fra
)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  struct {
    IGRint     i;
    IGRint     cnt;
    IGRint    *fraNum;
    IGRint     low,high;
    TGRid     *ids;
    TGRobj_env obj;
  } frx,crv;

  TGRmd_env md_env;

  IGRchar status[128];

  // Need Module Env Later */
  gr$get_module_env(buffer = &md_env);

  // Reset Frame Information
  memset(&frx,0,sizeof(frx));
  memset(&crv,0,sizeof(crv));

  // Get Frame Plane Objects
  sts = om$send(
    msg = message SMfrm_syst.SMfind_all_frame(
      &msg,
      &frx.ids,
      &frx.fraNum,
      &frx.cnt,
      &frx.low,
      &frx.high
    ),
    senderid = NULL_OBJID,
    targetid = fra->obj_id.objid,
    targetos = fra->obj_id.osnum
  );
  __CheckRC( sts, msg, "SMfrm_syst.SMfind_all_frame", wrapup );

//if (frx.cnt > 20) frx.cnt = 2;

  for(frx.i = 0; frx.i < frx.cnt; frx.i++) {

    frx.obj.mod_env = fra->mod_env;
    frx.obj.obj_id  = frx.ids[frx.i];

    crv.cnt = 0;
    crv.ids = NULL;

    sprintf(status,"Intersecting Frame %d ...",frx.i + frx.low);
    UI_status(status);

    sts = vd$int2elem(
      elem1 =  srf,
      elem2 = &frx.obj,
      trim1req =  2,
      trim2req =  0,
      NumbInt  = &crv.cnt,
      GRidInt  = &crv.ids
    );

    if (!(sts & 1)) {
      // printf("Problem Intersecting with hull surface\n");
      //VDbroPrintObj(&frx1.ids[frx1.i]);
      //goto wrapup;
    }

    vd_$bulk_display(theEnv = &md_env, count = crv.cnt, grids = crv.ids);

    _FREE(crv.ids);
    crv.ids = NULL;
  }

  UI_status("Done intersecting frame set");
  retFlag = 1;

wrapup:
  _FREE(frx.fraNum);
  _FREE(frx.ids);

  return retFlag;
}
  
end implementation Root;
