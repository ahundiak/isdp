/*

Name
  ECnelecnstr.execute

Abstract
  Command object to place constraints that support more than 2 elements.
  
Synopsis

Description
 This routine implements the command interface for some of the 
 profile commands.  All the commands support more than 2 inputs.
 The commands implemented are:
 
 Equality constraint
 Collinear constraint

Return Value

Notes
  Equality between arcs is supported by putting the equality on their radii.
  KNOWN BUG:
    Allows locate of elements across reference files.  This needs to be plugged
    at the ECelements level.  Currently the owner_action is set to LC_REF_OBJECTS
    which needs to be taken out a later date.  - Rajiv 12/04/93
  
Index

Keywords
  method,profile

History
  06/08/93 : Rajiv Agrawal : Code cleanup and calling new ECvg_report_conflict routine.
  07/28/93 : Rajiv Agrawal : Disallow duplicate points in collinear constraint (TR119222548).
  10/26/93 : Rajiv Agrawal : Check return codes after SKprocess_sketch_graphics call (TR11925175).
  11/15/93 : Satya         : Disallow equality constraint across angled ref planes TR 119308991
  11/22/93 : Satya         : Break from the switch statement in case of failure TR 119312993
  12/07/93 : G M K         : TR # 11924896 : first selected element should be a SKgeometry element.
  12/16/93 : Rajiv Agrawal : Added proper include files for Bspmath calls.
 */
class implementation ECnelecnstr;

#include <alloca.h>
#include <math.h>
#include "nddef.h"
#include "ndmacros.h"
#include "SKdef.h"
#include "ECmsg.h"
#include "ECcmd.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#define EQUALLEN_CMD		0
#define COLLINEAR_CMD		1

#define LOCATE_PARMELES       0
#define PROCESS_VGCNSTR       1

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1
#define Z 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_GRpoint_class_id, OPP_GRlineseg_class_id;
extern GRclassid OPP_GRcirarc_class_id, OPP_GRcircle_class_id;
extern GRclassid OPP_SKptvar_class_id, OPP_SKline_class_id, OPP_SKarc_class_id;
extern GRclassid OPP_SKcircle_class_id, OPP_SKgeometry_class_id;
extern GRclassid OPP_SKequal_class_id, OPP_SKcollinear_class_id;
extern GRclassid OPP_SKifequal_class_id, OPP_SKifcol_class_id;

from GRgraphics   import GRdisplay, GRdelete;
from SKconstraint import SKinit, SKvalidate, SKgetmgr;
from SKmgr        import SKgetornt;
from SKgeometry   import SKgetmgr;
from GRvg         import GRdetplane, GRgenabsg;

method wakeup ( int pos )
{
  int  bytes_in, bytes_out;
  long msg_loc, stat_OM;
  IGRboolean aflag;
 
  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;
 
  UI_prompt ( "" );
  stat_OM = om$send (mode = OM_e_wrt_parent, msg = message
             ECelements.wakeup (pos ),
             targetid = my_id);

  aflag = pwIsActivationOn();
  if (aflag)
  {
    pwGetActiveModuleEnv(&ME.ECelements->active_md_env);
  }
  else
  {
  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in,
   buffer = &ME.ECelements->active_md_env, nret = &bytes_out);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }
  dp$erase_hilite ( msg = &msg_loc );
ret_end:
  return OM_S_SUCCESS;
}

method get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; IGRushort *geomprops;
                            IGRshort *operation; IGRushort *options;
                            IGRint *minnum_to_locate, *maxnum_to_locate)
{
  IGRint cmdtype;
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  rtree_classes->w_count = 1;
  rtree_classes->w_flags = OM_CLST_subclass;
  rtree_classes->p_classes[0] = OPP_GRbspline_class_id;

  cmdtype = ME.super_cmd->mytype;
  if (cmdtype == EQUALLEN_CMD)
  {
    elig_classes->p_classes[0] = OPP_SKline_class_id;
    elig_classes->p_classes[1] = OPP_SKarc_class_id;
    elig_classes->p_classes[2] = OPP_SKcircle_class_id;
    elig_classes->w_count = 3;
  }
  else
  {
    elig_classes->p_classes[0] = OPP_SKline_class_id;
    elig_classes->p_classes[1] = OPP_SKptvar_class_id;
    elig_classes->w_count = 2;
  }
  elig_classes->w_flags = OM_CLST_subclass;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_APPENDOBJNUM | EC_LOC_NOFLEXGROUPS;

  *minnum_to_locate = 2;
  *maxnum_to_locate = MAXINT;

  return (stat_OM);
}


method proc_locobj (IGRlong *msg; struct GRevent *loc_event, *acc_event,   
                    *obj_event)
{
  IGRushort first_geomtype;
  struct GRid locobj;
  OM_p_CLASSLIST p_eliclasses;

  *msg = EMS_I_Found;

  if (!ME.ECelements->num_elems)
  {
    locobj = obj_event->located_object[0].located_obj;
    SKgetgeomtype (locobj.objid, locobj.osnum, &first_geomtype);

    p_eliclasses = &ME.ECelements->elig_classes;
    if (ME.super_cmd->mytype == EQUALLEN_CMD)
    {
      if (first_geomtype & SK_LINE)
      {
        p_eliclasses->p_classes[0] = OPP_SKline_class_id;
        p_eliclasses->p_classes[1] = OPP_GRlineseg_class_id;
        p_eliclasses->w_count = 2;
      }
      else
      {
        p_eliclasses->p_classes[0] = OPP_SKarc_class_id;
        p_eliclasses->p_classes[1] = OPP_SKcircle_class_id;
        p_eliclasses->p_classes[2] = OPP_GRcirarc_class_id;
        p_eliclasses->p_classes[3] = OPP_GRcircle_class_id;
        p_eliclasses->w_count = 4;
      }
    }
    else
    {
      p_eliclasses->p_classes[0] = OPP_SKline_class_id;
      p_eliclasses->p_classes[1] = OPP_SKptvar_class_id;
      p_eliclasses->p_classes[2] = OPP_GRpoint_class_id;
      p_eliclasses->p_classes[3] = OPP_GRlineseg_class_id;
      p_eliclasses->w_count = 4;
    }
  }

  return (OM_S_SUCCESS);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean 		val_cnstr, chkcycle, is_duplicate;
  IGRushort 		cnstrprops;
  IGRint 		i, j, k, loc_num_vgpts, num_vgpts;
  IGRint 		num_elems, num_conflict_cnstr, cmdtype;
  OMuint 		count;
  IGRint 		batch_mode, comp_type;
  IGRlong 		val_msg_loc, msg_loc, stat_OM;
  GRclassid 		classid, cnstrclass;
  GRobjid 		loc_vgpts[3], *vgpts, *conflict_cnstr;
  struct GRmd_env 	*env;
  struct GRid 		cnstr_grid, mgrid, first_eleid, eleid;
  struct GRlc_info 	*elems;
  OM_S_CHANSELECT 	chan_to_defpts;
  OM_S_OBJECT_LINKAGE 	objlist[4];
  enum EMSuser_responses useract;
  char 			elemtype[10];
  IGRdouble             dottol,disttol,dotp;
  IGRvector             my_zaxis,other_zaxis;
  struct  IGRplane      igr_plane;
  IGRpoint              cv_point,pnt1,pnt2,pnt1proj,pnt2proj;
  IGRpoint              my_origin;
  IGRvector             cv_normal;
  IGRint                brk_flg,break_flag;
  struct IGRbsp_curve   *cv;
  IGRdouble             dist1,dist2;
  extern IGRlong SKprocess_sketch_graphics();

  stat_OM = OM_S_SUCCESS;

  conflict_cnstr = NULL;
  
  cv = NULL;

  cmdtype = ME.super_cmd->mytype;

  if (cmdtype == EQUALLEN_CMD)
  {
    ex$message (msgnumb = EM_M_PlaceEqualityConstraint);
  }
  else if (cmdtype == COLLINEAR_CMD)
  {
    ex$message (msgnumb = EM_M_PlaceCollinearConstraint);
  }

  env = &ME.ECelements->active_md_env;

  do
  {
    switch (ME.super_cmd->state)
    {
      case LOCATE_PARMELES:
        ex$message (msgnumb = EMS_P_Element, buff = elemtype);
        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                           &useract, response, response_data, elemtype,
                           NULL, NULL, NULL, NULL, NULL), targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_moveon)
          ME.super_cmd->state = PROCESS_VGCNSTR;
        else
          goto ret_end;
        break;

      case PROCESS_VGCNSTR:
        dp$erase_hilite(msg = &msg_loc); 

        num_elems = ME.ECelements->num_elems;
        elems = ME.ECelements->elems;
        first_eleid = elems[FIRST].located_obj;

        /*
         * For equality constraint if the reference planes are at an angle disallow the constraint
         * placement. TR 119308991
         */
        if (cmdtype == EQUALLEN_CMD )
        {
          brk_flg = FALSE;
          igr_plane.point = cv_point;
          igr_plane.normal = cv_normal;

          BSEXTRACTPAR(&msg_loc,BSTOLTRPLPROD,dottol);
          BSEXTRACTPAR(&msg_loc,BSTOLLENVEC,disttol);
          
          /*
          * Get the reference plane info for this first element
          */
          stat_OM = om$send (msg = message GRvg.GRdetplane(&msg_loc,&env->md_env.matrix_type,
                             env->md_env.matrix,&igr_plane),
                             targetid = first_eleid.objid,
                             targetos = first_eleid.osnum);
          OM_BLOCK_MOVE(igr_plane.point,my_origin,sizeof(IGRpoint));
          OM_BLOCK_MOVE(igr_plane.normal,my_zaxis,sizeof(IGRvector));

          /*
          * Get the reference plane info for the other elements selected
          */
          for(i=1;i<num_elems;i++)
          {
            eleid = elems[i].located_obj;

            /*
            * If the element is a non associative line segment we cannot determine
            * its reference plane so we project the line onto the first reference
            * plane and see if the projected length of the line segment and original
            * line segment length are same , if they are same it implies that they are on
            * parallel reference planes else they are on angular reference planes.
            */
            om$get_classid (objid = eleid.objid,
                            osnum = eleid.osnum,
                            p_classid = &classid);
            if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_GRlineseg_class_id) == OM_S_SUCCESS)
            {
               /* Get geometry of the line segment */
               stat_OM = om$send( msg = message GRvg.GRgenabsg( &msg_loc, &env->md_env.matrix_type,
                                  env->md_env.matrix,(IGRchar **) &cv),
                                  senderid = NULL_OBJID,
                                  targetid = eleid.objid,
                                  targetos = eleid.osnum);

               EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,ret_end);
               for(j=0;j<3;j++)
               {
                 pnt1[j] = cv->poles[j];
                 pnt2[j] = cv->poles[j+3];
               }
               BSproj1(&msg_loc,pnt1,my_zaxis,my_origin,pnt1proj);
               BSproj1(&msg_loc,pnt2,my_zaxis,my_origin,pnt2proj);
               dist1 = BSdistptpt(&msg_loc,pnt1,pnt2);
               dist2 = BSdistptpt(&msg_loc,pnt1proj,pnt2proj);
               if(fabs(dist1 - dist2) > disttol)
               {
                 brk_flg = TRUE;
                 break;
               }
               else
                 continue;
            }

            stat_OM = om$send (msg = message GRvg.GRdetplane(&msg_loc,
                               &env->md_env.matrix_type,env->md_env.matrix,&igr_plane),
                               targetid = eleid.objid,
                               targetos = eleid.osnum);
            OM_BLOCK_MOVE(igr_plane.normal,other_zaxis,sizeof(IGRvector));
            dotp = BSdotp(&msg_loc,my_zaxis,other_zaxis) ;

            /*
            * This is to ensure that even reference planes at 180 degrees as valid for
            * equality constraint placement
            */
            dotp = fabs(dotp);
            if(fabs(dotp - 1.0) > dottol)
            {
              brk_flg = TRUE;
              break;
            }
          }
          if(brk_flg)
          {
            ex$message (msgnumb = EMS_S_IncompatiblePlane);
            ME.super_cmd->state = LOCATE_PARMELES;
            stat_OM = om$send (msg = message ECnelecnstr.init(ME.super_cmd->mytype, NULL),
                               mode = OM_e_wrt_parent,
                               targetid = my_id);
            brk_flg = FALSE;
            break;
          }
        }
        
        if (cmdtype == COLLINEAR_CMD && num_elems == 2)
        {
          eleid = elems[0].located_obj;
          om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
           p_classid = &classid);
          if (om$is_ancestry_valid (subclassid = classid,
               superclassid = OPP_GRlineseg_class_id) != OM_S_SUCCESS)
          {
            eleid = elems[1].located_obj;  
            om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
                            p_classid = &classid);
            if (om$is_ancestry_valid (subclassid = classid,
                 superclassid = OPP_GRlineseg_class_id) != OM_S_SUCCESS)
            {
              ex$message (msgnumb = EMS_S_InvalidConstraint);

              ME.super_cmd->state = LOCATE_PARMELES;
              stat_OM = om$send (msg = message ECnelecnstr.init 
                         (ME.super_cmd->mytype, NULL), mode = OM_e_wrt_parent,
                         targetid = my_id);
              EMomerr_exit (stat_OM, ret_end);

              break;
            }
          }
        }
        
        /*
         * First element should be a SKgeometry element or a SKptvar element
         * TR # 11924896   -- GMK 12/07/93
         */
        om$get_classid (objid = first_eleid.objid, osnum = first_eleid.osnum,
                        p_classid = &classid);
        if ( (om$is_ancestry_valid (subclassid = classid,
                 superclassid = OPP_SKgeometry_class_id) != OM_S_SUCCESS) &&
             (om$is_ancestry_valid (subclassid = classid,
                 superclassid = OPP_SKptvar_class_id) != OM_S_SUCCESS) )
        {
           ex$message (msgnumb = EMS_S_NotYetSupported);

           ME.super_cmd->state = LOCATE_PARMELES;
           stat_OM = om$send (msg = message ECnelecnstr.init 
                         (ME.super_cmd->mytype, NULL), mode = OM_e_wrt_parent,
                         targetid = my_id);
           EMomerr_exit (stat_OM, ret_end);

           break;
        }

        vgpts = (GRobjid *) alloca (num_elems * 2 * sizeof (GRobjid));
        EMerr_hndlr (!vgpts, stat_OM, OM_E_ABORT, ret_end);

        if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS)
        {
          vgpts[FIRST] = first_eleid.objid;
          num_vgpts = 1;
        }
        else
        {
          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
          stat_OM = om$get_channel_objects (objid = first_eleid.objid,
                     osnum = first_eleid.osnum, p_chanselect = &chan_to_defpts,
                     count = &count, size = 4, list = objlist);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (count < 2 || count > 3, stat_OM, OM_E_ABORT, ret_end);

          count = count > 2 ? 2 : count;
          for (i=FIRST; i<count; i++)
            vgpts[i] = objlist[i].S_objid;
          num_vgpts = count;
        }

        chkcycle = FALSE;
        break_flag = FALSE;
        for (i=1; i<num_elems; i++)
        {
          eleid = elems[i].located_obj;
          stat_OM = SKprocess_sketch_graphics (&msg_loc, SK_PROCSKGR_MERGESK,
                     env, &first_eleid, NULL, NULL, 1, &eleid,
                     &loc_num_vgpts, loc_vgpts);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
          if (msg_loc == EMS_I_BadPlane)
          {
            ex$message (msgnumb = EMS_S_IncompatiblePlane);
            me->state = LOCATE_PARMELES;
            break_flag = TRUE;
            break;
          }
          else if (msg_loc == EMS_I_Cycle)
          {
            ex$message (msgnumb = EMS_S_CyclicDependency);
            ME.super_cmd->state = LOCATE_PARMELES;
            break_flag = TRUE;
            break;
          }

          if (msg_loc == EMS_I_Assoc)
            chkcycle = TRUE;

          loc_num_vgpts = loc_num_vgpts > 2 ? 2 : loc_num_vgpts;
          if (cmdtype == EQUALLEN_CMD)
          {
            for (j=FIRST; j<loc_num_vgpts; j++)
              vgpts[num_vgpts++] = loc_vgpts[j];
          }
          else if (cmdtype == COLLINEAR_CMD)
          {
            /*
             * Disallow addition of points that are already there in the list.
             */
            for (j=FIRST; j<loc_num_vgpts; j++)
            {
              is_duplicate = FALSE;
              for (k=FIRST; k<num_vgpts; k++)
              {
                 if (loc_vgpts[j] == vgpts[k])
                 { 
                   is_duplicate = TRUE;
                   break;
                 }
              }
              if (!is_duplicate)
                vgpts[num_vgpts++] = loc_vgpts[j];
            }
          }
        }

        if(break_flag)
        {
           /*
            * In case of the failure initialize and break out of switch statement TR 119312993
            */
           stat_OM = om$send (msg = message ECnelecnstr.init(ME.super_cmd->mytype, NULL),
                              mode = OM_e_wrt_parent,
                              targetid = my_id);
           break_flag = FALSE;
           break;
        }
 
        cnstrprops = NULL;
        if (cmdtype == EQUALLEN_CMD)
        {
          if (num_vgpts > 4)
            cnstrclass = OPP_SKifequal_class_id;
          else
            cnstrclass = OPP_SKequal_class_id;
        }
        else if (cmdtype == COLLINEAR_CMD)
        {
          if (num_vgpts > 3)
            cnstrclass = OPP_SKifcol_class_id;
          else
            cnstrclass = OPP_SKcollinear_class_id;
        }

	stat_OM = om$construct (classid = cnstrclass,
                   osnum = env->md_id.osnum,
                   msg = message SKconstraint.SKinit (&msg_loc,
                   SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY |
                   SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD,
                   env, num_vgpts, vgpts, cnstrprops, NULL, NULL),
                   p_objid = &cnstr_grid.objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        cnstr_grid.osnum = env->md_id.osnum;

        stat_OM = om$send (msg = message SKconstraint.SKvalidate (&val_msg_loc,
                   chkcycle ? SK_UPDATE_CHKCYCLE : NULL, env, &val_cnstr,
                   &num_conflict_cnstr, &conflict_cnstr),
                   targetid = cnstr_grid.objid, targetos = cnstr_grid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

	if (val_cnstr)
        {
          if (val_msg_loc == EMS_I_FullyConstrained)
          {
            ex$message (msgnumb = EMS_S_FullyConstrained);
          }

          stat_OM = om$send (msg = message SKconstraint.SKgetmgr(&msg_loc,
                     &mgrid.objid), targetid = cnstr_grid.objid,
                     targetos = cnstr_grid.osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);
          mgrid.osnum = cnstr_grid.osnum;

          comp_type = ND_COMP;
          nd$wait_batch (type = GR_GEOM_POSTED,
           l_object = &mgrid, l_obj_info = &comp_type, nb_obj = 1);

          nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
          if (batch_mode == ND_IMMEDIATE)
             nd$exec_batch();
        }
        else
        {
          ECvg_report_conflict(&msg_loc, val_msg_loc, env, cnstr_grid, 
                               num_conflict_cnstr, conflict_cnstr);
          conflict_cnstr = NULL;
        }

        ME.super_cmd->state = LOCATE_PARMELES;
        stat_OM = om$send (msg = message ECnelecnstr.init 
                                 (ME.super_cmd->mytype, NULL), 
                           mode = OM_e_wrt_parent,
                           targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
    }
  }
  while (TRUE);

ret_end:
  if (conflict_cnstr)
    om$dealloc (ptr = conflict_cnstr);

  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}

end implementation ECnelecnstr;
