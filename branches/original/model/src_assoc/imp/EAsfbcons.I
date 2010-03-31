/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMSas.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "emssfintdef.h"
#include "EMS_I.h"  /*informational message numbers (for the status field) */
#include "msdef.h"   /* ex$message */
#include "msmacros.h"   /* ex$message */
#include "ma.h"
#include "madetplan.h"
#include "bssfarrevnd.h"
#include "bsplptnorrg.h"
#include "bsnorvec.h"
#include "bschangepar.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "dpdef.h"
#include "DIdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"

extern IGRboolean EFisAncestryValid();
extern OMuword OPP_EMSsolid_class_id, OPP_EMAplane_class_id,
               OPP_GRcurve_class_id, OPP_GRcompcurve_class_id;

from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSsuppress import EMget_suppress_id;
from GRcurve import GRtotlength, GRendpts, GRrevparm;

method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort options;
                               GRobjid  old_objid;
                               IGRint nb_root;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)
/* ****************************************************************

Description
 This method does the actual construction of boolean object.

Arguments
Input
  options: ubiquitous argument. Currently not supported and is set to
           NULL.
  nb_root : number of parents.
  list : GRid of parents.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.
 
Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

Recomputation informaton for boolean:

Objects connected on the parent channel:
 Solids and/or surfaces operated on.

History
 WBC   12/16/93     Need to check at the end of the method and
                    make sure the display_ids have been posted in case
                    they have changed.
 GMK    7/09/93     TR 119300819
                    If EMboolean results EMS_I_NoIntersection and type is
                    EMSbool_saveside, make the cutting plane (which is
                    created for EMboolean) as non locatable and non displayable.
 Janaka 11/12/92    ANSI compilation error fix.
 SM     10/31/92    KLUDGE KLUDGE KLUDGE -
                    Multiple booleans are now done one at a time with a macro
                    object being at the top. This causes multiple displays
                    and a light show on the screen. The way to avoid it is
                    by supressing redraw in EMboolean and doing it at the
                    end. Since there is no suitable argument to return
                    back the display ids, the character pointers 'geometry'
                    and 'class_attr' in the structure GRvg_construct are
                    being used to return 'display_ids'
                    and 'display_count'. ALL THIS APPLIES ONLY DURING INITIAL
                    CONSTRUCTION. Please see src_assoc/impco/EFbool.I for
                    related changes.
 AMD    04/07/92    Fix for TR 92n3264
 DLB    3/20/91     Creation.
 mrm    4/08/91     Added special processing for intersect plane save side.
 DLB    4/12/91     Get the operation type to decide whtat type of op to 
                    perform.  
 DLB    7/02/91     I wasn't doing get_parent_info.  I should have been.
 mrm    7/30/91     Added code to regenerate plane with proper range for
                    save side.
 pp     10/05/91    Modified to fix problems with intersect plane save side

Sudha   06/01/93    modified to handle BSprototype headers

*********************************************************************** */
{
 IGRdouble            save_tol = 0.0;
 IGRlong              OM_stat=OM_S_SUCCESS, bs_msg;
 IGRint               ii;
 GRobjid              *opnd_ids=NULL;
 GRobjid              *display_ids=NULL, param_id, **in_display_ids = NULL;
 IGRint               display_count=0, *in_display_count = NULL;
 enum EMSbooltype     exact_type, general_type;
 union EMSparent_info *parents=NULL;
 union EMSri_table    *ri = NULL;
 IGRuint      *parent_type;
 IGRushort    bool_options = EMSsfbool_opt_display |
                                     EMSsfbool_opt_retryDisjoint;
 IGRboolean           recompute, status, update_display_ids = FALSE;

 

 *EMmsg = EMS_S_Success;

 /*NOTE: If a surface or solid boolean, ALL roots will be pass on to the
  *      EMboolean message. 
  *      If in intersect plane - save side operation then root[0] is the
  *      driving plane and root[1] is the component being cut.  In this 
  *      case the component (cutting) plane is generated in this method
  *      and the operands are reordered such that opnd[0] is the component
  *      being cut and opnd[1] is the generated (cutting) plane (nb_root will
  *      always be 2 in this case). 
  */

 recompute = options & EMSasconst_recompute;

 parent_type = (IGRuint *) alloca(nb_root * sizeof(IGRint));
 if (!parent_type) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 for(ii=0; ii<nb_root; ii++)
 {
   parent_type[ii] = EMSgrid;
 }

 parents = (union EMSparent_info *) alloca 
           (nb_root * sizeof(union EMSparent_info)); 
 if (!parents) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 OM_stat = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         nb_root, parent_info,
                         parent_type, parents),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 opnd_ids = (GRobjid *) alloca(nb_root * sizeof(GRobjid));
 if (!opnd_ids) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

 for(ii=0; ii<nb_root; ii++)
 {
   opnd_ids[ii] = parents[ii].grobj.grid.objid;
 }

 if (recompute)
 {
   /* Get the operation type. */
   OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                           EMmsg, NULL, &exact_type, &general_type, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL, NULL),
                     targetid = my_id);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   if (!(ME.EMSsfboolean->operation & DISJ_DUE_TO_RETRY))
   {
     /*Perform the operation exactly like specified (Otherwise the general
      * operation will be performed).
      */
     general_type = exact_type;
   }
   else if (exact_type == EMSbool_saveside)
   {
     /*For the computation, the general type for the saveside is saveside.*/
     general_type = EMSbool_saveside;
   }

   /*Save the current tolerance */
   status = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, save_tol);
   if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   /*Set the proper tolerance for this operation*/
   status = BSchangepar(&bs_msg, BSTOLCHRDHT, ME.EMSsfboolean->cht);
   if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}

   OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                    EMmsg, &display_count, &display_ids, NULL),
                             my_id, OM_Gw_current_OS, &param_id, NULL); 
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   update_display_ids = TRUE;
   bool_options |= EMSsfbool_opt_noredraw;
 }
 else bool_options |= EMSsfbool_opt_HandleStop;

#ifdef OLDWAY
 if (me->type == EMSbool_saveside)
 {
   /* slightly modified code from src_dpr/imp/EMsfbreex.I - mrm */

   IGRboolean world = TRUE;
   IGRboolean inrange;
   IGRboolean special_saveside, status;
   OMuword dumosnum;
   IGRint num_pnts;
   IGRlong num_bytes;
   OM_S_OBJID new_objid, cutting_obj, sliced_object, dep_plane;
   GRrange operand_range;
   IGRdouble plane_point[3], plane_normal[3];
   IGRdouble u_knots[4], v_knots[4];
   IGRpoint plane_poles[4];
   OM_S_CHANSELECT to_comps;
   struct IGRbsp_surface *exist_plane = NULL;
   struct IGRplane new_plane;
   struct GRpost_info post_info;
   struct IGRbsp_surface plane_to_intersect;
   sliced_object = 0;
   cutting_obj = 0;

   special_saveside = !EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                                         OPP_EMSsolid_class_id, FALSE);

   /* sliced_object is the object to be sliced */
   EMmake_chanselect(GRcmpowner_to_components, &to_comps);
   OM_stat = om$get_objid_at_index(object = me,
                                   p_chanselect = &to_comps,
                                   index = 0,
                                   objidaddr = &sliced_object,
                                   osnumaddr = &dumosnum);
   if (! (1 & OM_stat)) goto wrapup;

   /*This code is added for the saveside on composite surface
    * special case.  The plane is stored on the end of the
    * vla and was used to recompute the saveside.
    */
   OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                     targetid = my_id);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   cutting_obj = ri->saveside_info.plane_id;

   /*If this was a result of 'Intersect plane save side' then the plane
    * will have to be regenerated since the range of sliced_object might have
    * changed.
    */
   new_plane.point = &plane_point[0];
   new_plane.normal = &plane_normal[0];

   /* Get the range from sliced_object.*/
   OM_stat = om$send(msg = message GRvg.GRgetrang(EMmsg,
                           &construct_list->env_info->md_env.matrix_type,
                           construct_list->env_info->md_env.matrix,&world,
                           operand_range),
                     targetid = sliced_object);
   if(!(1 & *EMmsg & OM_stat)) {*EMmsg = EMS_E_Fail; goto wrapup;}
   else *EMmsg = EMS_S_Success;

   /* id of the plane upon which the boolean depends is the last parent */
   dep_plane = opnd_ids[nb_root - 1];

   /* reset the object to be used in the boolean to be the generated
      plane rather than the parent plane - the parents geometry is about
      to be inserted there */
   opnd_ids[nb_root - 1] = cutting_obj;

   /* Get the existing plane geometry*/
   OM_stat = om$send(msg = message GRvg.GRgetsize(EMmsg,
                           &construct_list->env_info->md_env.matrix_type,
                           construct_list->env_info->md_env.matrix,&num_bytes),
                     targetid = dep_plane);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   exist_plane = (struct IGRbsp_surface *) alloca(num_bytes); 

   OM_stat = om$send(msg = message GRvg.GRgetgeom(EMmsg,
                           &construct_list->env_info->md_env.matrix_type,
                           construct_list->env_info->md_env.matrix,
                           (IGRchar *)exist_plane),
                     targetid = dep_plane);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   /* Get the point normal definition of the existing plane.*/
   num_pnts = 3;
   status = MAdetplane(EMmsg, exist_plane->poles, &num_pnts, 
                       &ME.EMSsfboolean->cht, &new_plane);
   if (!(1 & *EMmsg)) goto wrapup;

   /* Get the plane definition which encompases the operand range.*/
   plane_to_intersect.poles = (IGRdouble *)plane_poles;
   plane_to_intersect.u_knots = u_knots;
   plane_to_intersect.v_knots = v_knots;

   BSplptnorrg(operand_range,&operand_range[3],new_plane.point,
               new_plane.normal, 1.1, &inrange,&plane_to_intersect,&bs_msg);
   if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}
   else *EMmsg = EMS_S_Success;

   { /*INTENTIONAL BLOCK*/
     /*The new plane may have had its uv orientation changed so need to check
      * this.  Code added by DLB 10/24/89
      */
     IGRint jj;
     IGRvector old_norm, new_norm;
     IGRdouble normal_pts[2][3], dotp, upar=0, vpar=0; 
     IGRdouble *norm;
     struct IGRbsp_surface *surf;
     
     for(ii=0; ii<2; ii++)
     {
       /*First get the natural normal at 0,0*/
       if (ii==0)
       {
         surf = exist_plane;
         norm = old_norm;
       }
       else 
       {
         surf = &plane_to_intersect;
         norm = new_norm;
       }
        
       BSsfarrevnd(surf, 
                   1, &upar, 1, &vpar,
                   (IGRdouble) 1.0, NULL, 
                   normal_pts, &bs_msg);
       if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}
       else *EMmsg = EMS_S_Success;
                      
       for(jj=0; jj<3; jj++)
       {
          norm[jj] = normal_pts[1][jj] - normal_pts[0][jj];
       }       
       BSnorvec(&bs_msg, norm);
       if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}
       else *EMmsg = EMS_S_Success;
     }     
        
     dotp = BSdotp(&bs_msg, old_norm, new_norm);
     if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}
     else *EMmsg = EMS_S_Success;

     if (dotp < 0) exist_plane->pos_orient = !exist_plane->pos_orient;
   }

   plane_to_intersect.pos_orient = exist_plane->pos_orient;

   /* Post the new plane definition into the plane object.*/
   post_info.construct_flag = FALSE;
    
   OM_stat = om$send(msg = message GRvg.GRpostabsg(EMmsg,
                           construct_list->env_info, &post_info, 
                           (IGRchar *)&plane_to_intersect, &new_objid), 
                     targetid = cutting_obj);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   if (special_saveside)
   {
     bool_options |= EMSsfbool_opt_OpenIntPossible |
                     EMSsfbool_opt_SingleTopology;
   }
 }
#else
 if (me->type == EMSbool_saveside)
 {
   IGRboolean world = TRUE;
   IGRboolean inrange;
   /*
   IGRboolean natural_side;
   */
   IGRint natural_normal,jj;
   IGRvector norm;
   BSrc  bs_msg;
   IGRdouble plane_point[3], plane_normal[3], range[6];
   /*
   IGRdouble point[3];
   */
   IGRdouble dotp, u_knots[4], v_knots[4], u, v;
   IGRdouble normal_pts[2][3];
   IGRpoint plane_poles[4];
   OM_S_OBJID new_objid,sliced_obj, cutting_obj, dep_plane;
   struct GRpost_info post_info;
   struct IGRplane cutting_plane;
   struct GRmd_env *cutting_mod, *sliced_mod=NULL;
   struct IGRbsp_surface plane_to_intersect;
/*
 * The following scenarios are possible:
 * a) Intersect plane save side associative on a solid.
 * b) Intersect plane save side associative on a surface.
 * c) Intersect plane save side non-associative on a solid.
 * d) Intersect plane save side non-associative on a surface.
 */
   sliced_obj = 0;
   cutting_obj = 0;

   cutting_mod = &parents[0].grobj.env;
   if (nb_root == 2)
   {
    cutting_obj = parents[0].grobj.grid.objid;
    sliced_obj = parents[1].grobj.grid.objid;
    sliced_mod = &parents[1].grobj.env;
   }
   else if (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE) && (nb_root == 1 ))
   {
    sliced_obj = parents[0].grobj.grid.objid;
    sliced_mod = &parents[0].grobj.env;
    cutting_obj = NULL_OBJID;
   }

   OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                    targetid = my_id);
   if (!(1 & OM_stat & *EMmsg) || !ri) goto wrapup;

   if (cutting_obj == NULL_OBJID)
    cutting_obj = ri->saveside_info.plane_id;

   if (ri->saveside_info.plane_id == NULL_OBJID)
   {
/*
 * See if the plane is connected to the suppressed node. If so, get his
 * copy and use the same.
 * If there does not exist one, then construct an EMAplane if I am
 * associative
 */
    if (cutting_obj == NULL_OBJID)
    {
     GRobjid suppress_id;
     OM_S_CHANSELECT to_children,to_comps;
     OM_S_OBJID temp_id;
     OMuword dum_os;

     suppress_id = NULL_OBJID;
     EMmake_chanselect(GRcmpowner_to_components, &to_comps);
     EMmake_chanselect(NDchildren_children, &to_children);
     om$send (msg = message EMSsuppress.EMget_suppress_id(EMmsg,
                             &suppress_id, NULL),
                       p_chanselect = &to_children);
     if (suppress_id == NULL_OBJID)
     {
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
     }

      OM_stat = om$get_objid_at_index(objid = suppress_id,
                                      osnum = OM_Gw_current_OS,
                                      index = 0,
                                      objidaddr = &temp_id,
                                      osnumaddr = &dum_os,
                                      p_chanselect = &to_children);
     if (OM_stat == OM_S_SUCCESS)
        cutting_obj = temp_id;
     else
     {
       *EMmsg = EMS_E_InvalidCase;
       goto wrapup;
     }
    }

   dep_plane = NULL_OBJID;
  }
  else
  {
   dep_plane = ri->saveside_info.plane_id;
  }


   /*
      get the range of the sliced object to use in computing the range
      of the new slicing plane 
   */

   OM_stat = om$send(msg = message GRvg.GRgetrang
                          (EMmsg, &sliced_mod->md_env.matrix_type,
                           sliced_mod->md_env.matrix,&world, range),
                     targetid = sliced_obj,
                     targetos = sliced_mod->md_id.osnum);

   cutting_plane.point = plane_point;
   cutting_plane.normal = plane_normal;

   OM_stat = om$send(msg = message GRvg.GRdetplane
                          (EMmsg, &cutting_mod->md_env.matrix_type,
                           cutting_mod->md_env.matrix, &cutting_plane),
                     targetid = cutting_obj,
                     targetos = cutting_mod->md_id.osnum);

   if (!(OM_stat & *EMmsg & 1)) goto wrapup;

   BSnorvec(EMmsg, plane_normal);
   if (*EMmsg != BSSUCC) goto wrapup;
   natural_normal = *((IGRint *)recomp_info);
 
   if (!natural_normal)
   {
    for (jj=0;jj<3;jj++)
     plane_normal[jj] *= -1;
   }

   plane_to_intersect.poles = (IGRdouble *)plane_poles;
   plane_to_intersect.u_knots = u_knots;
   plane_to_intersect.v_knots = v_knots;

   BSplptnorrg(range,&range[3],plane_point, plane_normal,
               1.1, &inrange,&plane_to_intersect,&bs_msg);
   if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}

   u = 0.0;
   v = 0.0;

   BSsfarrevnd(&plane_to_intersect, 
               1, &u, 1, &v,
               (IGRdouble) 1.0, NULL, 
               (IGRdouble *)normal_pts, &bs_msg);
   if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}
   else *EMmsg = EMS_S_Success;

   for(jj=0; jj<3; jj++)
   {
       norm[jj] = normal_pts[1][jj] - normal_pts[0][jj];
   }       
   BSnorvec(&bs_msg, norm);
   if(bs_msg != BSSUCC) {*EMmsg=EMS_E_BSerror; goto wrapup;}
   else *EMmsg = EMS_S_Success;

   dotp = norm[0]*plane_normal[0] + norm[1]*plane_normal[1] + 
          norm[2]*plane_normal[2];

   if (dotp < 0.0)
    plane_to_intersect.pos_orient = 1;
   else
    plane_to_intersect.pos_orient = 0;
   construct_list->geometry = (IGRchar *)&plane_to_intersect;

   if (dep_plane == NULL_OBJID)
   {
    OM_stat = om$construct(classid = OPP_EMAplane_class_id,
                          msg = message GRgraphics.GRconstruct(construct_list),
                          p_objid = &dep_plane);
    if(!(1 & OM_stat)) { *EMmsg = EMS_E_Fail; goto wrapup; }
   }
   else
   {
    post_info.construct_flag = FALSE;
    
    OM_stat = om$send(msg = message GRvg.GRpostabsg(EMmsg,
                           construct_list->env_info, &post_info, 
                           (IGRchar *)&plane_to_intersect, &new_objid), 
                     targetid = dep_plane);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    dep_plane = new_objid;
   }

   construct_list->geometry = NULL;

   OM_stat = om$send(msg = message EMSsurface.EMmk_nat_bdry
                     (EMmsg, &construct_list->env_info->md_env, NULL),
                     targetid = dep_plane);

   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   /*
      Reset the objects to be used in the boolean to be in the proper
      order.  There should be two operands - the cutting object (just
      constructed here) and the object being cut. 
   */

   opnd_ids[0] = parents[1].grobj.grid.objid;   /* sliced object */
   opnd_ids[1] = dep_plane;                     /* cutting object */

   /* check for special conditions */

   if (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                          OPP_EMSsolid_class_id, FALSE))
   {
     bool_options |= EMSsfbool_opt_OpenIntPossible |
                     EMSsfbool_opt_SingleTopology;
   }
 }
#endif

 if(me->type != EMSbool_TrimCompsfs) {
   
 IGRchar status_str[255];
 ex$message (msgnumb = EMS_I_Processing, buff = status_str);

 if(!recompute && construct_list->class_attr && construct_list->geometry)
  {
   in_display_ids = (GRobjid **) construct_list->geometry;
   in_display_count = (IGRint *) construct_list->class_attr;
   bool_options |= EMSsfbool_opt_noredraw;
  }
 else
  {
   in_display_ids = NULL;
   in_display_count = NULL;
  }

 OM_stat = om$send(msg = message EMSsfboolean.EMboolean(EMmsg,
                         &construct_list->env_info->md_env.matrix_type,
                         construct_list->env_info->md_env.matrix,
                         opnd_ids[0], nb_root-1,
                         &opnd_ids[1], construct_list,
                         (enum EMSbooltype) (recompute ? general_type :
                                                         me->type),  
                         bool_options,
                         status_str, NULL, NULL, 
                         recompute ? &display_ids : in_display_ids,
                         recompute ? &display_count : in_display_count), 
                   targetid=my_id);
 }

 /* GMK  TR 119300819
  * Check for EMS_I_NoIntersection and type to EMSbool_saveside, to
  * make the cutting plane (which is created for EMboolean) as non locatable
  * and non displayable.
  */
 if (( *EMmsg == EMS_I_NoIntersection ) && (general_type == EMSbool_saveside)){

       IGRshort action;
       IGRshort props;
       IGRlong  stat,msg;
       IGRboolean is_associative=FALSE;

       stat = om$send (msg = message EMSsurface.EMis_associative(&msg,
                                &is_associative),
                       targetid = opnd_ids[0] );
       if (!(1 & stat & msg))
          goto wrapup;

       if ( is_associative ){

       stat = om$send(msg = message GRvg.GRgetprops( &msg, &props ),
                     targetid = opnd_ids[1]);
       if (!(1 & stat & msg))
          goto wrapup;

       action = -1; /* replacing with input props */
       props &= ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
       stat = om$send(msg = message GRvg.GRchgprops(&msg,
                                       &action,
                                       &props ),
                     targetid = opnd_ids[1]);
       if (!(1 & stat & msg))
          goto wrapup;

       /****** Deleting the plane
       stat = om$send (  mode = OM_e_wrt_message,
                          msg = message Root.delete(1),
                targetid = opnd_ids[1] );
       if (!(1 & stat ))
          fprintf(stderr,"EAsfbcons:Error in Root.delete\n" );
       *******/
       }
 }

 if (recompute && me->type != EMSbool_TrimCompsfs)
 {
   /*Put the display_ids in the param object.*/
   IGRlong loc_msg;
   om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                 display_count, display_ids, NULL),
           targetid = param_id);
   display_ids = NULL;
   update_display_ids = FALSE;
   if (!(1 & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}

   /*Reset tolerance.*/
   status = BSchangepar(&bs_msg, BSTOLCHRDHT, save_tol);
   if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 }

 if(me->type == EMSbool_TrimCompsfs) {
    IGRint ii, num_crvs = NULL, i, 
           crv_index = NULL, obj_count,
           num_lrgst_crvs, j, tmp_inx, k,
           rev_crv, *lrgst_crv_inx = NULL,
           num_bad_pts = 0, num_components;
    OMuword cvclass; 
    IGRushort imp_options;
    IGRboolean same_inx;
    IGRlong reversed, msg, stat, n_bytes,
            b_rec;
    GRobjid lrgst_cmpid = NULL_OBJID,
            temp_objid = NULL_OBJID;
    IGRdouble length = 0.0,
              largest_length = 0.0,
              comp_length, lrgst_comp_ln,
              nxt_lrgst_comp_ln, end_dist, 
              distance_tol, connect_tol, dist[4],
              *bad_pts = NULL;   
    IGRpoint ref_start, ref_stop, comp_start,
             comp_stop; 
    struct IGRpointset points;
    OM_S_OBJECT_LINKAGE longest_comp_crv,
                        nxt_longest_comp_crv;
    struct GRlc_info **crvs_info = NULL,
                     *longest_crv = NULL,
                     surf_info;
    struct GRid bool_id, *components = NULL;
    struct GRmd_env temp_mdenv;
    struct IGRdisplay active_display;
    struct DPele_header ele_header;

    surf_info.located_obj.objid = NULL_OBJID;
    crvs_info = (struct GRlc_info **) om$malloc(size =
                                    (nb_root-1)  * sizeof(struct GRlc_info *));
    for(ii = 0; ii < nb_root; ii++) {
        if(!IF_NULL_OBJID(parents[ii].grobj.grid.objid)) {
        om$get_classid (objid = parents[ii].grobj.grid.objid,
                        osnum = parents[ii].grobj.grid.osnum,
                        p_classid = &cvclass);
        if(om$is_ancestry_valid (subclassid = cvclass,
           superclassid = OPP_GRcurve_class_id) == OM_S_SUCCESS)
          {
          num_crvs++;
          crvs_info[ii] =
          (struct GRlc_info *) om$malloc(size = sizeof(struct GRlc_info));
          crvs_info[ii]->located_obj.objid = parents[ii].grobj.grid.objid;  
          crvs_info[ii]->located_obj.osnum = parents[ii].grobj.grid.osnum;
          OM_BLOCK_MOVE(&parents[ii].grobj.env,
                        &crvs_info[ii]->module_info, sizeof(struct GRmd_env));
          }
        else if(!IF_EQ_OBJID(parents[ii].grobj.grid.objid,
                             surf_info.located_obj.objid))
               {
             surf_info.located_obj.objid = parents[ii].grobj.grid.objid;
             surf_info.located_obj.osnum = parents[ii].grobj.grid.osnum;
             OM_BLOCK_MOVE(&parents[ii].grobj.env,
                           &surf_info.module_info, sizeof(struct GRmd_env));  
         }
       } 
     } /* collecting the curves and the parents */
  
    if(!num_crvs) {
           *EMmsg = EMS_E_Fail;
           goto loc_wrapup;
           }

    longest_crv = crvs_info[0];
    for(ii=0; ii < num_crvs; ii++) {
       stat = om$send(msg = message GRcurve.GRtotlength(&msg,
                            &crvs_info[ii]->module_info.md_env.matrix_type,
                            crvs_info[ii]->module_info.md_env.matrix,
                            &length),
                        targetid = crvs_info[ii]->located_obj.objid,
                        targetos = crvs_info[ii]->located_obj.osnum);
      EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_CurveError,wrapup);

      if(longest_crv->located_obj.objid == crvs_info[ii]->located_obj.objid)
      {
      largest_length = length;
      continue;
      }
      else if(length > largest_length) {
         largest_length = length;
         longest_crv = crvs_info[ii];
         crv_index = ii;
        }
     }

   stat = om$get_classid(objid = longest_crv->located_obj.objid,
                           osnum = longest_crv->located_obj.osnum,
                           p_classid = &cvclass);
          if(!(1 & stat)) goto wrapup;

   if(om$is_ancestry_valid(subclassid = cvclass,
      superclassid = OPP_GRcompcurve_class_id) == OM_S_SUCCESS)
     {  
   stat = om$send(msg = message GRowner.GRget_number_components(
                            &msg, &num_components),
                   targetid = longest_crv->located_obj.objid,
                   targetos = longest_crv->located_obj.osnum);
          EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_CurveError, wrapup);
     
   components = (struct GRid *) om$malloc(size =
                                          (OMuint)num_components *
                                          sizeof(struct GRid));
   stat = om$send(msg = message GRowner.GRget_components (&msg,
                          &longest_crv->module_info, components, num_components,
                          &obj_count, 0, num_components-1),
                          targetid = longest_crv->located_obj.objid,
                          targetos = longest_crv->located_obj.osnum);
          EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_CurveError, wrapup);

   longest_comp_crv.S_objid = components[0].objid;
   longest_comp_crv.osnum = components[0].osnum;

   for(i=0;i<num_components;i++)
      {
      stat = om$send(msg = message GRcurve.GRtotlength(&msg,
                           &longest_crv->module_info.md_env.matrix_type,
                           longest_crv->module_info.md_env.matrix,
                           &comp_length),
                           targetid = components[i].objid,
                           targetos = components[i].osnum);
      EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_CurveError, wrapup);

      if(longest_comp_crv.S_objid == components[i].objid)
      {
      lrgst_comp_ln = comp_length;
      nxt_lrgst_comp_ln = 0.0;
      continue;
      }
      else if(comp_length > lrgst_comp_ln) {
              nxt_lrgst_comp_ln = lrgst_comp_ln;
              nxt_longest_comp_crv.S_objid = longest_comp_crv.S_objid;
              nxt_longest_comp_crv.osnum = longest_comp_crv.osnum;
              lrgst_comp_ln = comp_length;
              longest_comp_crv.S_objid = components[i].objid;
              longest_comp_crv.osnum = components[i].osnum;
              }
      else if(comp_length > nxt_lrgst_comp_ln) {
              nxt_lrgst_comp_ln = comp_length;
              nxt_longest_comp_crv.S_objid = components[i].objid;
              nxt_longest_comp_crv.osnum = components[i].osnum;
           }
        }
     }
     for(ii = 0; ii < num_crvs; ii++) {
             if(ii == crv_index)
               {
                temp_objid = crvs_info[0]->located_obj.objid;
                crvs_info[0]->located_obj.objid =
                crvs_info[ii]->located_obj.objid;
                crvs_info[ii]->located_obj.objid = temp_objid;
                OM_BLOCK_MOVE(&crvs_info[0]->module_info,
                              &temp_mdenv, sizeof(struct GRmd_env));
                OM_BLOCK_MOVE(&crvs_info[ii]->module_info,
                           &crvs_info[0]->module_info, sizeof(struct GRmd_env));
                OM_BLOCK_MOVE(&temp_mdenv,
                          &crvs_info[ii]->module_info, sizeof(struct GRmd_env));
                }
              else continue;
              }
     lrgst_crv_inx = (IGRint *) om$malloc(size = num_crvs *
                                                 sizeof(IGRint));
     num_lrgst_crvs = 1;
     stat = BSEXTRACTPAR(&msg, BSTOLLENVEC, connect_tol);
     distance_tol = connect_tol * connect_tol;
     lrgst_crv_inx[0] = 0;  

     for(k = 0; k < num_lrgst_crvs; k++) {
         tmp_inx = lrgst_crv_inx[k];
              same_inx = FALSE;
          stat = om$send(msg = message GRcurve.GRendpts(&msg,
                           &crvs_info[tmp_inx]->module_info.md_env.matrix_type,
                           crvs_info[tmp_inx]->module_info.md_env.matrix,
                                  ref_start, ref_stop),
                                  targetid =
                                  crvs_info[tmp_inx]->located_obj.objid,
                                  targetos =
                                  crvs_info[tmp_inx]->located_obj.osnum,
                                  senderid = my_id);
         EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_CurveError, wrapup);

         if(!BSdistptpts(&msg, ref_start, ref_stop ) < connect_tol)
             {
              end_dist = distance_tol;
              for(i = 1; i < num_crvs; i++)
                 {
                 rev_crv = 0;
                 for(j = 0; j < num_lrgst_crvs; j++) {

                     if(i == lrgst_crv_inx[j]) {
                        same_inx = TRUE;
                        break;
                         }
                       }
                 if(same_inx) continue;
                 stat = om$send(msg = message GRcurve.GRendpts(&msg,
                                  &crvs_info[i]->module_info.md_env.matrix_type,
                                  crvs_info[i]->module_info.md_env.matrix,
                                  comp_start, comp_stop),
                                  targetid =
                                  crvs_info[i]->located_obj.objid,
                                  targetos =
                                  crvs_info[i]->located_obj.osnum,
                                  senderid = my_id);
              EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_CurveError, wrapup);
              if(BSdistptpts(&msg, comp_start, comp_stop ) < connect_tol)
                    continue;
              else
                 {
              dist[0] = BSdistptpts(&msg, ref_stop, comp_start);
              dist[1] = BSdistptpts(&msg, ref_stop, comp_stop);
              dist[2] = BSdistptpts(&msg, ref_start, comp_stop);
              dist[3] = BSdistptpts(&msg, ref_start, comp_start);

              for(j = 0; j < 4; j++) {
                  if(dist[j] < end_dist)
                  end_dist = dist[j];

                  if(dist[j] >= end_dist &&
                     dist[j] < distance_tol)
                     rev_crv = j;
                  }
              if(end_dist >= distance_tol)
                 continue;
              else {
                   lrgst_crv_inx[num_lrgst_crvs] = i;
                   num_lrgst_crvs++;
                   if(rev_crv == 1 || rev_crv == 3)
                     {
                     stat = om$send(msg = message GRcurve.GRrevparm(&msg,
                                         &crvs_info[i]->module_info),
                                targetid = crvs_info[i]->located_obj.objid,
                                targetos = crvs_info[i]->located_obj.osnum);
                     EMerr_hndlr(!(1 & stat & msg), *EMmsg,
                                 EMS_E_CurveError, wrapup);
                           }
                        }
                     }
                 }
              }
          }

       bool_id.objid = my_id;
       bool_id.osnum = surf_info.located_obj.osnum;
       reversed = *((IGRlong *)recomp_info);
       imp_options = EMSsfbool_opt_HandleStop;
       stat = om$send(msg = message EMScompsurf.ECtrmcmpsfs(crvs_info,
                                      num_crvs,
                                      &surf_info,
                                      imp_options,
                                      num_lrgst_crvs,
                                      lrgst_crv_inx,
                                      reversed,
                                      &lrgst_cmpid,
                                      TRUE,
                                      &num_bad_pts,
                                      &bad_pts,
                                      &bool_id,
                                      &msg),
                 targetid = surf_info.located_obj.objid,
                 targetos = surf_info.located_obj.osnum);
        EMerr_hndlr(!(1 & stat & msg), *EMmsg, EMS_E_Fail, wrapup);

       if(msg == EMS_I_OutOfBounds) {
          ex$message(msgnumb = EMS_F_0003)
          stat = dp$erase_hilite(msg = &msg);
        
          if(num_bad_pts) {
             n_bytes = sizeof( struct IGRdisplay );
             gr$get_active_display(msg = &msg,
                                   sizbuf = &n_bytes,
                                   buffer = &active_display,
                                   nret = &b_rec );
             active_display.weight = 4;

             points.num_points = num_bad_pts;
             points.points     = bad_pts;               

             dp$build_dis_buffer(buffer = &ele_header,
                                 type = IGRPS,
                                 display_att = &active_display,
                                 geometry = (struct IGRpointset *)&points);

             stat = dp$display(msg = &msg,
                               osnum = surf_info.located_obj.osnum,
                               buffer = &ele_header);
            }
         }   

loc_wrapup :

 if(components) {
    om$dealloc(ptr = components);
    components = NULL;
    }

 if(bad_pts) {
    om$dealloc(ptr = bad_pts);
    bad_pts = NULL;
    }

 if(crvs_info) {
    for(ii = 0; ii < num_crvs; ii++)
       {
       if(crvs_info[ii])
          om$dealloc(ptr = crvs_info[ii]);
       crvs_info[ii]= NULL;
       }

 om$dealloc(ptr = crvs_info);
 crvs_info = NULL;
 }

 if(lrgst_crv_inx) {
    om$dealloc(ptr = lrgst_crv_inx);
    lrgst_crv_inx = NULL;
   }
 
} /* End Trim Comp */

wrapup:

 /* post the display_ids to the param object in case an error occurred
  * before the ids were posted in the "normal" flow of the code
  */

 if (update_display_ids && me->type != EMSbool_TrimCompsfs)
 {
   IGRlong loc_msg;

   om$send(msg = message EMSdprparam.EMput_display_ids(&loc_msg,
                                         display_count, display_ids, NULL),
           targetid = param_id);
 }

 if (ri) om$dealloc(ptr = ri);
  
 EMWRAPUP (*EMmsg,OM_stat, "sfb const_assoc")
 return (OM_stat);
}
end implementation EMSsfboolean;

