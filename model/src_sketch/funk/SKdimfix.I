class implementation Root;

/*****************************************************************************

        Name:SKdimfix.I
        Desc:Retrieves lost dimensional constraints 

*****************************************************************************/

#include <math.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "dpmacros.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "exmacros.h"
#include "madef.h"
#include "dimplcmacros.h"
#include "dimmacros.h"
#include "dimangular.h"
#include "SKdef.h"
#include "bsparameters.h"

from NDnode import NDget_objects,ASreturn_go;
from SKvariable import SKgetvar;
from SKconstraint import SKgetprops;
from SKmgr import SKgetvarconstrs,SKget_xymat;
from GRconnector import GRrigidconn;
from GRcurve import GRmidpoint;
from GRcurve import GRendpts;
from expression import NDgive_value;
from EMSdatpln import EMget_pln_info;
from SKconstraint import GRdelete;

extern GRclassid OPP_SKhvptpt_class_id;
extern GRclassid OPP_SKifptpt_class_id;
extern GRclassid OPP_SKline_class_id;
extern GRclassid OPP_SKradial_class_id;
extern GRclassid OPP_SKarc_class_id;
extern GRclassid OPP_SKcircle_class_id;
extern GRclassid OPP_SKfixang_class_id;
extern GRclassid OPP_SKexplicit_class_id;
extern GRclassid OPP_SKrelang_class_id;
extern GRclassid OPP_SKaxisptpt_class_id;

extern IGRdouble BSlenvec();
extern IGRboolean BSmkvec();
extern IGRdouble BSdotp();
extern IGRint BSnorvec();

put_back_dim_constrs(struct GRid mgr)
{
    IGRlong msg_loc,sts;
    struct GRid planid, dimid, origid, measid,my_grid;
    IGRuint num_cnstrs,num_members;
    IGRuint num_ptvars,num_comps,num_geoms,num_parents;
    OM_S_CHANSELECT chan_to_parent,chan_to_geoms,chan_to_comps;
    OM_S_CHANSELECT chan_to_constrs,chan_to_members,chan_to_ptvars;
    IGRint trak_dir,axis,mask;
    OM_S_OBJECT_LINKAGE ptvars[4], ptvars_geoms[2][1];
    OM_S_OBJECT_LINKAGE parlist,members,*cnstrs;
    IGRpoint ptvals[4];
    IGRint i,j,k,kx,ky,m;
    GRclassid objclass,objclass1;
    IGRushort props;
    struct GRmd_env mod_env;
    int sizbuf,nret,counts[4],sector;
    IGRmatrix mat,xy_xyz_mat;
    IGRshort mattyp,xy_xyz_mattyp;
    GRobjid geoms[2],geomlist[4][3],obj;
    struct GRparms ref_parms;
    GRspacenum dum_os;
    IGRshort needs_repair;
    IGRdouble trak_dist, zerotol;
    struct DMenv_param frm_env;
    IGRdouble trak_dist_tmp, oldang,angle;
    IGRvector xdir,ydir,normal, vec2,vec1;
    IGRint num_hvpt,num_ifpt,num_rad,num_fang,num_rang;
    static int prof_num=0;

      EMmake_chanselect (NDfather_father, &chan_to_parent);
      EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
      EMmake_chanselect (SKconstraint_to_variables, &chan_to_ptvars);
      EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
      EMmake_chanselect (SKmgr_to_constrs, &chan_to_constrs);
      EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_members);

      /*
       * Create the dimension object. The plane parent is the plane parent
       * of this sketch manager.
       */

      prof_num++;
      num_hvpt = num_ifpt = num_rad = num_fang = num_rang = 0;
      zerotol = 1e-06;
      kx=ky=0;
      num_cnstrs = 0;
      sts = om$get_channel_count(objid = mgr.objid,
                                 osnum = mgr.osnum,
                                 p_chanselect = &chan_to_constrs,
                                 count = &num_cnstrs);

      if(! (1 & sts ) || !(num_cnstrs )) goto wrapup;
      cnstrs = (OM_p_OBJECT_LINKAGE) alloca (num_cnstrs * 
                              sizeof(OM_S_OBJECT_LINKAGE));
      sts = om$get_channel_objects(objid = mgr.objid,
                                   osnum = mgr.osnum,
                                   p_chanselect = &chan_to_constrs,
                                   list = cnstrs,
                                   size = num_cnstrs,
                                   count = &num_cnstrs);

      num_parents = 0;
      sts = om$get_channel_count(objid = mgr.objid,
                                 osnum = mgr.osnum,
                                 p_chanselect = &chan_to_parent,
                                 count = &num_parents);

      if(! (1 & sts ) || !(num_parents )) goto wrapup;
      sts = om$get_channel_objects(objid = mgr.objid,
                                    osnum = mgr.osnum,
                                    p_chanselect = &chan_to_parent,
                                    list = &parlist,
                                    size = 1,
                                    count = &num_parents);

      planid.objid = parlist.S_objid;
      planid.osnum = parlist.osnum;

      sizbuf = sizeof(struct GRmd_env);
      gr$get_module_env(msg = &msg_loc, sizbuf = &sizbuf,
                       buffer = &mod_env, nret = &nret);

      mattyp = mod_env.md_env.matrix_type;
      memcpy(mat ,mod_env.md_env.matrix,sizeof(IGRmatrix));
      sts = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
              SK_OPT_GET_XY_TO_XYZ, &mattyp, mat, &xy_xyz_mattyp, xy_xyz_mat),
              targetid = mgr.objid,targetos = mgr.osnum,senderid=NULL_OBJID);
 
      for(i = 0; i < num_cnstrs; i++)
      {
        needs_repair = FALSE;
        om$get_classid (objid = cnstrs[i].S_objid, osnum = cnstrs[i].osnum,
                        p_classid = &objclass);
        if (!(om$is_ancestry_valid (subclassid = objclass,
                     superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS))
          continue;
        if (om$is_ancestry_valid (subclassid = objclass,
                       superclassid = OPP_SKaxisptpt_class_id) == OM_S_SUCCESS)
          goto wrapup;
        /* If constraint has no components it needs repair */
        num_comps = 0;
        sts = om$get_channel_count(objid = cnstrs[i].S_objid,
                                   osnum = cnstrs[i].osnum,
                                   p_chanselect = &chan_to_comps,
                                   count = &num_comps);
        if(! (1 & sts )) goto wrapup;
        if(num_comps)
          needs_repair = FALSE;
        else
          needs_repair = TRUE;

        if(!needs_repair)
          continue;
        
        dm$get_dim_param(type = DM_ENV_PARAM, p_data = &frm_env);
        trak_dist_tmp = frm_env.txt_heig;

        /** Start repair of each dimension constraint ***/
        if ((om$is_ancestry_valid (subclassid = objclass,
                     superclassid = OPP_SKhvptpt_class_id) == OM_S_SUCCESS)
        || (om$is_ancestry_valid (subclassid = objclass,
                     superclassid = OPP_SKfixang_class_id) == OM_S_SUCCESS))
        {
          /* Get the SKptvars of the constraint */
          num_ptvars = 0;
          sts = om$get_channel_count(objid = cnstrs[i].S_objid,
                                    osnum = cnstrs[i].osnum,
                                    p_chanselect = &chan_to_ptvars,
                                    count = &num_ptvars);
          if(! (1 & sts ) || (num_ptvars != 2)) goto wrapup;
          sts = om$get_channel_objects(objid = cnstrs[i].S_objid,
                                       osnum = cnstrs[i].osnum,
                                       p_chanselect = &chan_to_ptvars,
                                       list = ptvars,
                                       size = 2,
                                       count = &num_ptvars);
          if(! (1 & sts)) goto wrapup;

          /* Get the values of the SKptvars */
 
          for (j = 0; j < 2; j++)
          {
            sts = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                           SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat, 
                           ptvals[j]), 
                           targetid = ptvars[j].S_objid,
                           targetos = ptvars[j].osnum,
                           senderid = NULL_OBJID);
            if(! (1 & sts )) goto wrapup;
          }

	  /*** STACKED LINEAR DIMENSION CONSTRAINTS **********/
          if (om$is_ancestry_valid (subclassid = objclass,
                     superclassid = OPP_SKhvptpt_class_id) == OM_S_SUCCESS)
          {
            /* Get the geometries of the SKptvars */
            for(j = 0; j < 2; j++)
            {
              num_geoms = 0;
              sts = om$get_channel_count(objid = ptvars[j].S_objid,
                                        osnum = cnstrs[i].osnum,
                                        p_chanselect = &chan_to_geoms,
                                        count = &num_geoms);
              if(!(1 & sts ) || !(num_geoms)) goto wrapup;
              sts = om$get_channel_objects(objid = ptvars[j].S_objid,
                                           osnum = ptvars[j].osnum,
                                           p_chanselect = &chan_to_geoms,
                                           list = ptvars_geoms[j],
                                           size = 1,
                                           count = &num_geoms);
              if(! (1 & sts)) goto wrapup;
            }
            
            origid.objid = ptvars_geoms[0][0].S_objid;
            origid.osnum = cnstrs[0].osnum;
	    measid.objid = ptvars_geoms[1][0].S_objid;
	    measid.osnum = cnstrs[0].osnum;
            trak_dir = TRUE;
            sts = om$send(msg = message SKconstraint.SKgetprops(&msg_loc,&props), 
                                targetid = cnstrs[i].S_objid,
                                targetos = cnstrs[i].osnum,
                                senderid = NULL_OBJID);

            axis = props & SK_HORIZONTAL ? DM_MEA_AXIS : NULL;
            if(axis)
            {
              trak_dist = kx * trak_dist_tmp;
              kx++;
            }
            else
            {
              trak_dist = ky * trak_dist_tmp;
              ky++;
            }
            my_grid.objid = cnstrs[i].S_objid;
            my_grid.osnum = cnstrs[i].osnum;
            dm$place_stack_linear (orig_grid = &origid, orig_pt = ptvals[0],
                                   trak_dist = trak_dist,
                                   meas_grid = &measid, meas_pt = ptvals[1], 
                                   plane_grid = &planid, trak_dir = trak_dir, 
                                   axis = axis, owner = &my_grid,
                                   dim_grid = &dimid);
            if(dimid.objid == NULL_OBJID) 
              goto wrapup;
            else
            {
              num_hvpt++;
              continue;
            }
          }
	  /*** ABSOLUTE ORIENTATION ANGULAR DIMENSION CONSTRAINTS **********/
          else
          {
            oldang = 0.0;
            sts = om$send (msg = message expression.NDgive_value (&oldang),
                                          targetid = cnstrs[i].S_objid, 
                                          senderid = NULL_OBJID,
                                          targetos = cnstrs[i].osnum);
            if(oldang > 180.0)
              goto wrapup;

            for(j = 0; j < 2; j++)
            {
              num_geoms = 0;
              sts = om$get_channel_count(objid = ptvars[j].S_objid,
                                         osnum = ptvars[j].osnum,
                                         p_chanselect = &chan_to_geoms,
                                         count = &num_geoms);
              if(! (1 & sts ) || !(num_geoms)) goto wrapup;
              counts[j] = 0;
              for (k = 0; k < num_geoms; k++)
              {
                sts = om$get_objid_at_index (objid = ptvars[j].S_objid, 
                                        osnum = ptvars[j].osnum,
                                        p_chanselect = &chan_to_geoms,
                                        index = k, 
                                        objidaddr = &obj, 
                                        osnumaddr = &dum_os);
                if(! (1 & sts )) goto wrapup;
                om$get_classid (objid = obj, osnum = dum_os,
                                 p_classid = &objclass1);
                if (om$is_ancestry_valid (subclassid = objclass1,
                     superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
                {
                   geomlist[j][counts[j]] = obj;
                   counts[j]++;
                }
              }
            }
            if((!counts[0]) || (!counts[1])) goto wrapup;
            geoms[0] = NULL_OBJID;
            for (j=0; j<counts[0]; j++)
              for (k=0; k<counts[1]; k++)
                if (geomlist[0][j] == geomlist[1][k])
                  geoms[0] = geomlist[0][j];
            if(geoms[0] == NULL_OBJID) goto wrapup;
 
            dimid.objid = NULL;
            origid.objid = geoms[0];
            origid.osnum = cnstrs[0].osnum;
            measid.objid = geoms[0];
            measid.osnum = cnstrs[0].osnum;
            sts = om$send(msg = message SKconstraint.SKgetprops(&msg_loc,
                          &props), targetid = cnstrs[i].S_objid,
                          targetos = cnstrs[i].osnum,
                          senderid = NULL_OBJID);
            mask = props & SK_HORIZONTAL ? ANG_DIM_HORIZANTAL:ANG_DIM_VERTICAL; 
            sts = om$send(msg = message EMSdatpln.EMget_pln_info( &msg_loc, 
                                         NULL, &mod_env, xdir, ydir, normal, 
                                         NULL, NULL),
                                         targetid = planid.objid,
                                         senderid = NULL_OBJID,
                                         targetos = planid.osnum);
            BSmkvec(&msg_loc,vec2,ptvals[0],ptvals[1]);
            BSnorvec(&msg_loc,vec2);
            if(props & SK_HORIZONTAL)
              memcpy(vec1,xdir,sizeof(IGRvector));
            else
              memcpy(vec1,ydir,sizeof(IGRvector));
            angle_between_lines(vec1,vec2,&angle,normal);

            angle = angle * 180.0/PI;
            sector = NULL;
            if(fabs(angle - oldang) < zerotol)
              sector = NULL;
            else
              sector |= MEAS_START;

            sector = sector;
            my_grid.objid = cnstrs[i].S_objid;
            my_grid.osnum = cnstrs[i].osnum;
            dm$place_angular (orig_grid = &origid, orig_pt = ptvals[0],
                              meas_grid = &measid, meas_pt = ptvals[0],
                              plane_grid = &planid, sector = sector ,
                              mask = mask,
                              owner = &my_grid,dim_grid =  &dimid);
            if(dimid.objid == NULL_OBJID) 
              goto wrapup;
            else
            {
              num_fang++;
              continue;
            }
          }
        }
	/*** RELATIVE ORIENTATION DIMENSION CONSTRAINTS ***/
        if (om$is_ancestry_valid (subclassid = objclass,
                        superclassid = OPP_SKrelang_class_id) == OM_S_SUCCESS)
        {
          oldang = 0.0;
          sts = om$send (msg = message expression.NDgive_value (&oldang),
                                          targetid = cnstrs[i].S_objid, 
                                          senderid = NULL_OBJID,
                                          targetos = cnstrs[i].osnum);
          if(oldang > 180.0)
            goto wrapup;

          /* Get the SKptvars of the constraint */
          num_ptvars = 0;
          sts = om$get_channel_count(objid = cnstrs[i].S_objid,
                                     osnum = cnstrs[i].osnum,
                                     p_chanselect = &chan_to_ptvars,
                                     count = &num_ptvars);
          if(!(1 & sts ) || (num_ptvars > 4) || (num_ptvars < 3)) 
            goto wrapup;
          sts = om$get_channel_objects(objid = cnstrs[i].S_objid,
                                       osnum = cnstrs[i].osnum,
                                       p_chanselect = &chan_to_ptvars,
                                       list = ptvars,
                                       size = num_ptvars,
                                       count = &num_ptvars);
          if(! (1 & sts)) goto wrapup;

          /* Get the values of the SKptvars */
 
          for (j = 0; j < num_ptvars; j++)
          {
            sts = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                           SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat, 
                           ptvals[j]), 
                           targetid = ptvars[j].S_objid,
                           targetos = ptvars[j].osnum,
                           senderid = NULL_OBJID);
            if(! (1 & sts )) goto wrapup;
          }

          counts[0] = counts[1] = counts[2] = counts[3] = 0;
          for(j = 0; j < num_ptvars; j++)
          {
            num_geoms = 0;
            sts = om$get_channel_count(objid = ptvars[j].S_objid,
                                       osnum = ptvars[j].osnum,
                                       p_chanselect = &chan_to_geoms,
                                       count = &num_geoms);
            if(! (1 & sts ) || !(num_geoms )) goto wrapup;
            counts[j] = 0;
            for (k = 0; k < num_geoms; k++)
            {
              om$get_objid_at_index (objid = ptvars[j].S_objid, 
                                     osnum = ptvars[j].osnum,
                                     p_chanselect = &chan_to_geoms,
                                     index = k, 
                                     objidaddr = &obj, 
                                     osnumaddr = &dum_os);
              if(! (1 & sts )) goto wrapup;
              om$get_classid (objid = obj, osnum = dum_os,
                              p_classid = &objclass1);
              if (om$is_ancestry_valid (subclassid = objclass1,
                   superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
              {
                  geomlist[j][counts[j]] = obj;
                  counts[j]++;
              }
            }
          }
          if((!counts[0]) || (!counts[1])|| (!counts[2]) ) 
            goto wrapup;
          if(num_ptvars == 4)
            if(!counts[3])
              goto wrapup;
          geoms[0] = NULL_OBJID;
          geoms[1] = NULL_OBJID;
          if(num_ptvars == 4)
          {
            BSmkvec(&msg_loc,vec1,ptvals[0],ptvals[1]);
            BSmkvec(&msg_loc,vec2,ptvals[2],ptvals[3]);
            for (j=0; j<counts[0]; j++)
              for (k=0; k<counts[1]; k++)
                if (geomlist[0][j] == geomlist[1][k])
                  geoms[0] = geomlist[0][j];
            for (j=0; j<counts[2]; j++)
              for (k=0; k<counts[3]; k++)
                if (geomlist[2][j] == geomlist[3][k])
                  geoms[1] = geomlist[2][j];
          }
          else
          {
            BSmkvec(&msg_loc,vec1,ptvals[0],ptvals[1]);
            BSmkvec(&msg_loc,vec2,ptvals[0],ptvals[2]);
            for (j=0,m=0; j<counts[0]; j++)
            {
              for (k=0; k<counts[1]; k++)
                if (geomlist[0][j] == geomlist[1][k])
                  geoms[m++] = geomlist[0][j];
              for (k=0; k<counts[2]; k++)
                if (geomlist[0][j] == geomlist[2][k])
                  geoms[m++] = geomlist[0][j];
            }
          }

          if((geoms[0] == NULL_OBJID) || (geoms[1] == NULL_OBJID))
            goto wrapup;

          sts = om$send(msg = message EMSdatpln.EMget_pln_info( &msg_loc, 
                                       NULL, &mod_env, NULL, NULL, normal, 
                                       NULL, NULL),
                                       targetid = planid.objid,
                                       senderid = NULL_OBJID,
                                       targetos = planid.osnum);
          BSnorvec(&msg_loc,vec1);
          BSnorvec(&msg_loc,vec2);
          angle_between_lines(vec1,vec2,&angle,normal);

          sector = NULL;
          angle = angle * 180.0/PI;
          if(fabs(angle - oldang) < zerotol)
            sector = NULL;
          else
            sector |= ORIG_START| CLOCK_WISE;

          dimid.objid = NULL;
          origid.objid = geoms[1];
          origid.osnum = cnstrs[0].osnum;
          measid.objid = geoms[0];
          measid.osnum = cnstrs[0].osnum;
          sector = sector;
          my_grid.objid = cnstrs[i].S_objid;
          my_grid.osnum = cnstrs[i].osnum;
          if(num_ptvars == 4)
            dm$place_angular (orig_grid = &origid, orig_pt = ptvals[0],
                              meas_grid = &measid, meas_pt = ptvals[1],
                              plane_grid = &planid,sector = sector,
                              owner = &my_grid,dim_grid =  &dimid);
          else
            dm$place_angular (orig_grid = &origid, orig_pt = ptvals[0],
                              meas_grid = &measid, meas_pt = ptvals[0],
                              plane_grid = &planid,sector = sector,
                              owner = &my_grid,dim_grid =  &dimid);
          if(dimid.objid == NULL_OBJID) 
            goto wrapup;
          else
          {
            num_rang++;
            continue;
          }
        }
         
        if ((om$is_ancestry_valid (subclassid = objclass,
                       superclassid = OPP_SKifptpt_class_id) == OM_S_SUCCESS)
            || (om$is_ancestry_valid (subclassid = objclass,
                       superclassid = OPP_SKradial_class_id) == OM_S_SUCCESS))
        {
          /* Get the SKptpt constraint */
          num_members = 0;
          sts = om$get_channel_count(objid = cnstrs[i].S_objid,
                                     osnum = cnstrs[i].osnum,
                                     p_chanselect = &chan_to_members,
                                     count = &num_members);
          if(!(1 & sts ) || !(num_members)) goto wrapup;
          sts = om$get_channel_objects(objid = cnstrs[i].S_objid,
                                       osnum = cnstrs[i].osnum,
                                       p_chanselect = &chan_to_members,
                                       list = &members,
                                       size = 1,
                                       count = &num_members);
          if(! (1 & sts)) goto wrapup;

          /* Get the SKptvars of the constraint */
          num_ptvars = 0;
          sts = om$get_channel_count(objid = members.S_objid,
                                     osnum = members.osnum,
                                     p_chanselect = &chan_to_ptvars,
                                     count = &num_ptvars);
          if(! (1 & sts ) || (num_ptvars != 2)) goto wrapup;
          sts = om$get_channel_objects(objid = members.S_objid,
                                       osnum = members.osnum,
                                       p_chanselect = &chan_to_ptvars,
                                       list = ptvars,
                                       size = 2,
                                       count = &num_ptvars);
          if(! (1 & sts)) goto wrapup;
          for (j = 0; j < 2; j++)
          {
             sts = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                            SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat, 
                            ptvals[j]), targetid = ptvars[j].S_objid,
                            targetos = ptvars[j].osnum,
                            senderid = NULL_OBJID);
           if(! (1 & sts )) goto wrapup;
          }
          if (om$is_ancestry_valid (subclassid = objclass,
                     superclassid = OPP_SKradial_class_id) == OM_S_SUCCESS)
          {
            for (j = 0; j <= 1; j++)
            {
              num_geoms = 0;
              sts = om$get_channel_count (objid = ptvars[j].S_objid, 
                                          osnum = ptvars[j].osnum,
                                          p_chanselect = &chan_to_geoms,
                                          count = &num_geoms);
              if(!(1 & sts ) || !(num_geoms)) goto wrapup;
              counts[j] = 0;
              for (k=0; k<num_geoms; k++)
              {
                om$get_objid_at_index (objid = ptvars[j].S_objid, 
                                       osnum = ptvars[j].osnum,
                                       p_chanselect = &chan_to_geoms,
                                       index = k, objidaddr = &obj, 
                                       osnumaddr = &dum_os);
                om$get_classid (objid = obj, osnum = dum_os,
                                p_classid = &objclass1);
                if ((om$is_ancestry_valid (subclassid = objclass1,
                      superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS) ||
                     (om$is_ancestry_valid (subclassid = objclass1,
                     superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS))
                {
                  geomlist[j][counts[j]] = obj;
                  counts[j]++;
                }
              }
            }
            if((!counts[0]) || (!counts[1])) goto wrapup;
            geoms[0] = NULL_OBJID;
            for (j=0; j<counts[0]; j++)
              for (k=0; k<counts[1]; k++)
                if (geomlist[0][j] == geomlist[1][k])
                  geoms[0] = geomlist[0][j];
            if(geoms[0] == NULL_OBJID) goto wrapup;

            /*
             * Obtain the midpoint of the arc as the point where the radial 
             * dimension  will attach.
             */

            sts = om$send (msg = message GRcurve.GRmidpoint (&msg_loc, 
                                 &mod_env.md_env.matrix_type, 
                                 mod_env.md_env.matrix, &ref_parms, 
                                 ptvals[0]), 
                                 targetid = geoms[0],
                                 targetos = dum_os,
                                 senderid = NULL_OBJID);

            my_grid.objid = cnstrs[i].S_objid;
            my_grid.osnum = cnstrs[i].osnum;
            dimid.objid = NULL_OBJID;
            origid.objid = geoms[0];
            origid.osnum = cnstrs[i].osnum;
            dm$place_radial (orig_grid = &origid, orig_pt = ptvals[0],
                             plane_grid = &planid, 
                             owner = &my_grid,dim_grid = &dimid);
            if(dimid.objid == NULL_OBJID) 
              goto wrapup;
            else
            {
              num_rad++;
              continue;
            }
          }
          else
          {
            for(j = 0; j < 2; j++)
            {
              num_geoms = 0;
              sts = om$get_channel_count(objid = ptvars[j].S_objid,
                                         osnum = ptvars[j].osnum,
                                         p_chanselect = &chan_to_geoms,
                                         count = &num_geoms);
              if(! (1 & sts ) || !(num_geoms)) goto wrapup;
              counts[j] = 0;
              for (k = 0; k < num_geoms; k++)
              {
                om$get_objid_at_index (objid = ptvars[j].S_objid, 
                                       osnum = ptvars[j].osnum,
                                       p_chanselect = &chan_to_geoms,
                                       index = k, 
                                       objidaddr = &obj, 
                                       osnumaddr = &dum_os);
                if(! (1 & sts )) goto wrapup;
                om$get_classid (objid = obj, osnum = dum_os,
                                p_classid = &objclass1);
                if (om$is_ancestry_valid (subclassid = objclass1,
                    superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
                {
                  geomlist[j][counts[j]] = obj;
                  counts[j]++;
                }
              }
            }
            if((!counts[0]) || (!counts[1])) goto wrapup;
            geoms[0] = NULL_OBJID;
            for (j=0; j<counts[0]; j++)
              for (k=0; k<counts[1]; k++)
                if (geomlist[0][j] == geomlist[1][k])
                  geoms[0] = geomlist[0][j];
            if(geoms[0] == NULL_OBJID) goto wrapup;

            origid.objid = geoms[0];
            origid.osnum = cnstrs[0].osnum;
            for (j=0; j<=2; j++)
              ptvals[0][j] = ptvals[0][j] + (ptvals[1][j] - ptvals[0][j])/2.0;
            trak_dir = FALSE;
            my_grid.objid = cnstrs[i].S_objid;
            my_grid.osnum = cnstrs[i].osnum;
            dm$place_sglpara (orig_grid = &origid, orig_pt = ptvals[0],
                              plane_grid = &planid, trak_dir = trak_dir,
                              owner = &my_grid,dim_grid =  &dimid);
            if(dimid.objid == NULL_OBJID) 
              goto wrapup;
            else
            {
              num_ifpt++;
              continue;
            }
	  }
        }
         
        wrapup:
        sts = om$send (msg = message SKconstraint.GRdelete (&msg_loc, &mod_env),
                              targetid = cnstrs[i].S_objid,
                              targetos = cnstrs[i].osnum,
                              senderid = NULL_OBJID);
        continue;
      }
     
      if((num_hvpt) || (num_ifpt) || (num_fang) || (num_rang) || (num_rad))
      {
        printf("**************************************************\n");
        printf("Constraints Retrieved on Profile # %d\n\n",prof_num);
      }
      if(num_hvpt)
        printf(" Stacked Linear         %d         \n",num_hvpt);
      if(num_ifpt)
        printf(" Single Parallel        %d         \n",num_ifpt);
      if(num_fang)
        printf(" Absolute Angular       %d         \n",num_fang);
      if(num_rang)
        printf(" Relative Angular       %d         \n",num_rang);
      if(num_rad)
        printf(" Radial                 %d         \n",num_rad);
      if((num_hvpt) || (num_ifpt) || (num_fang) || (num_rang) || (num_rad))
        printf("**************************************************\n");

      return(0);
}

angle_between_lines(vec1,vec2,angle,norm)
double *vec1,*vec2,*norm;
double *angle;
{
    int rc;
    double cost,sint, dotp;
    double perp_vec[3];

      BScrossp(&rc,vec1,vec2,perp_vec);
      sint = BSlenvec(&rc,perp_vec);
      cost = BSdotp(&rc,vec1,vec2);
      *angle = atan2(sint,cost);

      dotp = BSdotp(&rc,norm,perp_vec);
      if( dotp < 0)
      {
        if( *angle < 0) *angle = - *angle;
        else  *angle = 2* PI - *angle;
      }
      else if( *angle < 0 )  *angle = 2 * PI + *angle;
      return(OM_S_SUCCESS);
}

end implementation Root;
