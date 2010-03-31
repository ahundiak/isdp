/* ###################   APOGEE COMPILED   ################## */
class implementation ECmvpls;

#include "EMS.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "OMmacros.h" /* for OM_BLOCK_MOVE */
#include "grdpbmacros.h" /* For gr$get_dit.. */
#include "igrdef.h"     /* For IGRPS */
#include "EMSssprops.h" /* For EMSIS_POLYDIS */
#include "dp.h" /* For struct var_list */
#include "dpdef.h" /* For VVOL_VIEWPORT.. */
#include "dpmacros.h" /* For dp$inq.. */

#define BUFF_SIZE 10
#define INCREMENT 10

from GRvg import GRgetsize,GRgetgeom,GRgetattr,GRputattr;
from GRgraphics import GRdisplay,GRdelete;
from GRgsmgr import GRget_prism_size, GRget_prism;
from EMSsurface import EMgetactiveid;

extern OMuword OPP_EMSsolid_class_id;

/*
History
	DLB	9/22/91		Mod dit_tol call to *sizbuf - SUN issue.
        scw    08/14/94         clarified sleep method
*/

method get_pole_position(struct GRevent *event;IGRint *pole_index;
                         IGRboolean *onpolygon)
{
  IGRpoint		pnt1, pnt2; 
  IGRlong		msg;
  IGRlong nret;
  struct GRparms dum_parms;
  struct IGRline boreline;
  IGRlong sts,which_error;
  IGRdouble tol,scale;
  IGRdouble line_point[3],line_parameter,mindist;
  IGRint sizd=sizeof(IGRdouble);
  IGRpoint pole;
  struct var_list list_var[2];
  extern short prj_line_to_pole();
  struct IGRbsp_surface *surf;
  IGRint temp_u,temp_v;

  *pole_index = 0;

  boreline.point1 = pnt1;  /* allocates storage for */
  boreline.point2 = pnt2;  /* the boreline          */

  sts = EFboreline(&msg, my_id, event, &boreline);
  if (!(1&sts&msg)) goto wrapup;

  if (!me->surf_ptr) return (OM_E_ABORT);
  else
    surf = me->surf_ptr;

  dum_parms.u = 5.0;  /* kludge for the tolerance */

  prj_line_to_pole (&msg,surf, &boreline,line_point,&line_parameter,
                    pole, &temp_u, &temp_v,&mindist);
  if (!(1&msg)) goto wrapup;

  sts = gr$get_dit_tolerance(msg = &msg,sizbuf = &sizd,
                            buffer = &tol, nret = (int *)&nret);
  if (!(1&sts)) return (OM_E_ABORT);

  list_var[0].var            = VVOL_VIEWPORT_SCALE;
  list_var[0].var_ptr        = (char *)&scale;
  list_var[0].num_bytes      = sizeof(IGRdouble);
  list_var[0].bytes_returned = &nret;

  list_var[1].var            = END_PARAM;
  list_var[1].var_ptr        = NULL;
  list_var[1].num_bytes      = 0;
  list_var[1].bytes_returned = NULL;

  sts = dp$inq_set_gragad (msg = &msg,
              osnum = event->event.button.osnum,
              gragad_objid = event->event.button.objid,
              which_error = &which_error,
              var_list = list_var);
  if (!(1&sts&msg)) goto wrapup;

  tol /= scale;

  if (mindist > tol)
   *onpolygon = FALSE;
  else
   *onpolygon = TRUE;

  *pole_index = (surf->u_num_poles)*temp_v + 
                temp_u;
wrapup:
  if (!(1&sts&msg)) return (OM_E_ABORT);
  return(OM_S_SUCCESS);
}


method display_polygon(IGRboolean display)
{
  IGRint status = OM_S_SUCCESS;
  IGRlong		msg;
  struct IGResbs esbs;
  struct GRmd_env *env;
  enum GRdpmode display_mode;
  struct GRid *surf_GRid;
  IGRchar *esb;
/*
 * If (display)
 *  See if the surface has the polygon turned on. If so noop.
 *  Else turn the polygon on.
 * Else
 *  See if this command object had actually turned the polygon. If so
 *  erase the polygon.
 */
 

  msg = MSSUCC;
  status = OM_S_SUCCESS;

  surf_GRid = &me->surface.located_obj;

  if (surf_GRid->objid != NULL_OBJID)
  {
     esb = (char *)&esbs;

     status = om$send(msg = message GRvg.GRgetattr(&msg, esb),
                      targetid = surf_GRid->objid,
                      targetos = surf_GRid->osnum);

     if (!(1&status&msg)) goto wrapup;

     if (display ? !esbs.is_polydis : (esbs.is_polydis && (!me->savedis)))
     {
        env = &me->surface.module_info;

       if (!display)
       {
        display_mode = GRbe;

        status = om$send(
                         msg = message GRgraphics.GRdisplay(&msg,
                               &env->md_env.matrix_type,
                               env->md_env.matrix,
                               &display_mode,
                               &env->md_id),
                         targetid = surf_GRid->objid,
                         targetos = surf_GRid->osnum);
        if (!(1&status&msg)) goto wrapup;
       }

/*
 * It is assumed that the polygon display is only turned off if it is turned
 * on by this command object.
 */
        if (display)
        {
         ME.ECmvpls->savedis = esbs.is_polydis;
         esbs.is_polydis = EMSIS_POLYDIS;
        }
        else
        {
         esbs.is_polydis = ME.ECmvpls->savedis;
        }

        status = om$send(msg = message GRvg.GRputattr(&msg, esb),
                         targetid = surf_GRid->objid,
                         targetos = surf_GRid->osnum);
        if (!(1&status&msg)) goto wrapup;

        display_mode  = GRbd;

        status = om$send(
                         msg = message GRgraphics.GRdisplay(&msg,
                               &env->md_env.matrix_type, env->md_env.matrix,
                               &display_mode,
                               &env->md_id),
                         senderid = my_id,
                         targetid = surf_GRid->objid,
                         targetos = surf_GRid->osnum);
        if (!(1&status&msg)) goto wrapup;
     }
  }

wrapup:
  if (!(1&status&msg)) return (OM_E_ABORT);
  return (status);
}

method wakeup(int pos)
{
 IGRlong sts;
 IGRlong EMmsg;
 enum GRdpmode display_mode;

 sts = OM_S_SUCCESS;
 EMmsg = 1;
 

 sts = om$send(mode = OM_e_wrt_message,
                  msg = message ECelement.wakeup(pos),
                  targetid = my_id);
 if (!(1&sts)) return (OM_E_ABORT);

 if (me->form_displayed)
 {
  FIf_display(ME.ECmvpls->form1);

 }

 if (me->num_pole_events)
 {
   sts = om$send (msg = message ECmvpls.display_pole_event(TRUE,TRUE),
                  targetid = my_id);
   if (!(1&sts)) return (OM_E_ABORT);
 }

/*
 * Display the newly constructed surface which has been constructed with
 * polygon turned off since it is an order 2 surface and the polgon 
 * matches the surface display. 
 */

 if (me->mytype == MOVE_NODES)
 {
  if ((me->surface.located_obj.objid != NULL_OBJID) &&
     (me->save_surf.located_obj.objid != NULL_OBJID))
  {
         display_mode = GRbd;

         sts = om$send (msg = message GRgraphics.GRdisplay(&EMmsg,
                         &me->surface.module_info.md_env.matrix_type,
                         me->surface.module_info.md_env.matrix,
                         &display_mode,
                         &me->surface.module_info.md_id),
                   targetid = me->surface.located_obj.objid,
                   targetos = me->surface.located_obj.osnum);
        if (!(1&sts&EMmsg)) return (OM_E_ABORT);
  }
 }
 else
 {
  sts = om$send(msg = message ECmvpls.display_polygon(TRUE),
               targetid = my_id);
  if (!(1&sts)) return (OM_E_ABORT);
 }
 return (sts);

}

method super_cmd.sleep(int pos)
{
 IGRlong sts,msg;
 enum GRdpmode display_mode;

 sts = OM_S_SUCCESS;
 msg = 1;


 if (me->form_displayed)
 {
  FIf_erase(ME.ECmvpls->form1);
 }

 if (me->num_pole_events)
 {
   sts = om$send (msg = message ECmvpls.display_pole_event(TRUE,FALSE),
                  targetid = my_id);
   if (!(1&sts)) return (OM_E_ABORT);
 }
/*
 * Erase the constructed surface.
 */

 if (me->mytype == MOVE_NODES)
 {
  if ((me->surface.located_obj.objid != NULL_OBJID) &&
     (me->save_surf.located_obj.objid != NULL_OBJID))
  {
         display_mode = GRbe;

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->surface.module_info.md_env.matrix_type,
                         me->surface.module_info.md_env.matrix,
                         &display_mode,
                         &me->surface.module_info.md_id),
                   targetid = me->surface.located_obj.objid,
                   targetos = me->surface.located_obj.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);
  }
 }
 else
 {
  sts = om$send (msg = message ECmvpls.display_polygon(FALSE),
                targetid = my_id);
  if (!(1&sts)) return (OM_E_ABORT);
 }
 return (sts);
}

method init(int type; char *str_ptr)
{

  int		  status = OM_S_SUCCESS;

  status = om$send (msg = message ECelement.init(type,str_ptr),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  if (!(1&status)) return (OM_E_ABORT);

  me->savedis = TRUE;
  me->magnitude_gadgets_displayed = TRUE;
  me->form_id = NULL_OBJID;
  me->form_displayed = FALSE;
  me->pole_selection = INDIVIDUALLY;
  me->direction = VECTOR;
  me->surf_ptr = 0;
  me->surf_size = 0;
  me->num_poles = 0;
  me->row = 1;
  me->mag = EQUALLY;
  me->num_pole_events = 0;
  me->surface.located_obj.objid = NULL_OBJID;

/*
 * Initialise for node points.
 */
 if (me->mytype == MOVE_NODES)
 {
  me->u_insert = 0;
  me->v_insert = 0;
  me->unum = 0;
  me->vnum = 0;
  me->num_pts = 0;
  me->u_vals = NULL;
  me->v_vals = NULL;
  me->weights = NULL;
  me->node_pts = NULL; 
  me->save_surf.located_obj.objid = NULL_OBJID;
 }

  return (status);
}


method display_indices(IGRlong from_index; IGRlong to_index;
               IGRboolean draw)
{
 IGRlong sts;
 IGRlong msg,i,j,k;
 IGRpoint point;
 IGRshort type;
 IGRdouble weight = 1;
 IGRint save_wt,wt,ii;
 struct IGRbsp_surface *surf;
 extern IGRlong ECdisplayPointSetByBuffer0();

 sts = OM_S_SUCCESS;
 msg = 1;

 save_wt = ME.ECelement->active_display.weight;


 if ((from_index < 0 ) || (to_index > me->num_poles))
 {
  return (OM_E_ABORT);
 }
 surf = me->surf_ptr;

 type = IGRPS;

 for (i=from_index;i<to_index;i++)
 {
  j = me->indices[i];
  if (surf->rational)
   weight = surf->weights[j];
  else
   weight = 1;

  for (k=0;k<3;k++)
   point[k] = surf->poles[3*j+k]/weight; 
/*
 * Decide the weight of the point. This has not been optimised as it is
 * expected that the number of poles being moved is not large.
 */
  wt = 0;
  for (ii=0;ii<me->num_poles;ii++)
  {
   if (j == me->indices[ii]) ++wt;
  }

  if (save_wt < 3)
   ME.ECelement->active_display.weight = 3 + wt - 1;
  else
   ME.ECelement->active_display.weight = save_wt + wt - 1;

  ECdisplayPointSetByBuffer0 (&msg, ME.ECelement->active_display,
       ME.ECelement->md_env, my_id, 1, point, (draw ? GRhd : GRhe), type);
  if (!(1&msg)) goto wrapup;
 }

wrapup:
 ME.ECelement->active_display.weight = save_wt;
 if (!(1&sts&msg)) return (OM_E_ABORT);
 return (sts);
}

method store_row(IGRboolean row; IGRint index)
{
 IGRlong sts;
 IGRint i;
 IGRint stinx,edinx,u_pole_inx, v_pole_inx,current_size, future_size;
 struct IGRbsp_surface *surf = NULL;

 sts = OM_S_SUCCESS;

 surf = me->surf_ptr;
 if (!surf) return (OM_E_ABORT);

 u_pole_inx = index % surf->u_num_poles;
 v_pole_inx = index / surf->u_num_poles;

  if (row) future_size = me->num_poles + surf->u_num_poles;
  else future_size = me->num_poles + surf->v_num_poles;

  current_size = OM_DIMENSION_OF(me->indices);

  if (current_size < future_size)
   sts = OM_SET_DIMENSION(me->indices,future_size);
   if (!(1&sts))
   {
    sts = OM_E_ABORT;
    goto wrapup;
   }

 if (row)
 {
  stinx = v_pole_inx * surf->u_num_poles;
  edinx = stinx + surf->u_num_poles;

  for (i=stinx;i< edinx;i++)
  {
    me->indices[me->num_poles] = i;
    ++(me->num_poles);
  }
 }
 else
 {
   stinx = u_pole_inx;
   edinx = surf->u_num_poles * surf->v_num_poles;

   for (i=u_pole_inx;i<edinx;i += (surf->u_num_poles))
   {
     me->indices[me->num_poles] = i;
     ++(me->num_poles);
   }
 }

  sts = om$send (msg = message ECmvpls.add_pole_event((row ? surf->u_num_poles :
                       surf->v_num_poles)),
                 targetid = my_id);
  if (!(1&sts)) goto wrapup;

wrapup:
 return (sts);
}

IGRboolean return_volume_object(msg,comp_GRid,md_env,volume_GRid,type)

IGRlong *msg;
struct GRid *comp_GRid;
struct GRmd_env *md_env;
struct GRid *volume_GRid;
IGRint *type;

/* *****************************************************************

 This function when given the component of an object located determines 
if its owner/active id is a volume (solid) or an implied volume (fence)
object. 

   ***************************************************************** */
{
 IGRlong sts;
 OMuword comp_classid;
 IGRint size;
 IGRint prism_type, num_poles,num_weights,num_knots,
             num_boundaries;
 struct GRid active_GRid;
 OMuword active_classid;

 sts = OM_S_SUCCESS;
 *msg = 1;

 *type = 0;
 volume_GRid->objid = NULL_OBJID;

/*
 * If the object located is the same as the one being modified then it has
 * to be a surface.
 */

 sts = om$get_classid (osnum = comp_GRid->osnum,
                       objid = comp_GRid->objid,
                       p_classid = &comp_classid);
 if (!(1&sts)) goto wrapup;

  sts = om$send (msg = message GRgsmgr.GRget_prism_size(msg, md_env,
                           &prism_type,&size,&num_poles,&num_weights,
                           &num_knots,&num_boundaries),
                 senderid = NULL_OBJID,
                 targetid = comp_GRid->objid,
                 targetos = comp_GRid->osnum);
  if (1&sts)
  {
   *type = VOLUME_LOCATED | FENCE_LOCATED;
   *volume_GRid = *comp_GRid;
   goto wrapup;
  }
  else if (sts == OM_W_UNKNOWN_MSG)
   sts = OM_S_SUCCESS;
  else goto wrapup;

  sts = om$send (msg = message EMSsurface.EMgetactiveid(msg,&active_GRid,
                       NULL),
                 senderid = NULL_OBJID,
                 targetid = comp_GRid->objid,
                 targetos = comp_GRid->osnum);
  if (!(1&sts&*msg)) goto wrapup;
  
  sts = om$get_classid (osnum = active_GRid.osnum,
                        objid = active_GRid.objid,
                        p_classid = &active_classid);
  if (!(1&sts)) goto wrapup;

  sts = om$is_ancestry_valid(subclassid = active_classid,
                             superclassid = OPP_EMSsolid_class_id);
  if (sts == OM_S_SUCCESS)
  {
    *type = VOLUME_LOCATED | SOLID_LOCATED;
    *volume_GRid = active_GRid;
  }

wrapup:
 if (!(1&sts&*msg)) *type = 0;
 return (sts);
}

method storepoles_in_volume(IGRlong *msg; IGRint type; 
                            struct GRmd_env *md_env;
                            struct GRid *volume)
{
 IGRlong sts;
 IGRint *b_ptr = NULL, b_indices[BUFF_SIZE],*m_indices = NULL;
 IGRint num_poles;

 sts = OM_S_SUCCESS;

 if (type & FENCE_LOCATED)
 {
   EFreturn_poles_within_fence(msg,
                               me->surf_ptr,
                               NULL,NULL,
                               md_env,
                               volume,
                               NULL,NULL,
                               &num_poles,BUFF_SIZE,
                               b_indices,NULL,&m_indices,NULL);
   if (!(1&*msg)) goto wrapup;
 }
 else if (type & SOLID_LOCATED)
 {
   EFreturn_poles_within_solid(msg,
                               me->surf_ptr,
                               &me->surface.module_info,
                               &me->surface.located_obj,
                               md_env,
                               volume,
                               &num_poles,BUFF_SIZE,
                               b_indices,NULL,&m_indices,NULL);
   if (!(1&*msg)) goto wrapup;
 }
 
   if (num_poles > BUFF_SIZE)
    b_ptr = m_indices;
   else 
    b_ptr = b_indices;

   sts = om$send (msg = message ECmvpls.add_pole(num_poles,b_ptr),
                  targetid = my_id);
   if (!(1&sts)) goto wrapup;

   sts = om$send (msg = message ECmvpls.add_pole_event(num_poles),
                  targetid = my_id);
   if (!(1&sts)) goto wrapup;

   sts = om$send (msg = message ECmvpls.display_pole_event(FALSE,TRUE),
                  targetid = my_id);
   if (!(1&sts)) goto wrapup;

wrapup:
   if (m_indices) om$dealloc(ptr = m_indices);
   if (!(1&sts&*msg)) return (OM_E_ABORT);
 return (sts);
}

method store_geom(IGRlong *msg)
{
 IGRlong sts;
 struct GRmd_env *md_env;
 IGRlong buff_size;

 *msg = MSSUCC;

 md_env = &me->surface.module_info;
 sts = om$send (msg = message GRvg.GRgetsize (msg, 
                      &md_env->md_env.matrix_type, 
                      md_env->md_env.matrix,
                      &buff_size), 
                targetid = me->surface.located_obj.objid,
                targetos = me->surface.located_obj.osnum);
 if (!(1&sts&*msg)) return (OM_E_ABORT);

 if (buff_size > me->surf_size)
 {
  if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
        
  me->surf_ptr = (struct IGRbsp_surface *) om$malloc(size = buff_size);
  if (!me->surf_ptr) return (OM_E_ABORT);

  me->surf_size = buff_size;
 }
 sts = om$send (msg = message GRvg.GRgetgeom(msg,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix,
                        (char *)me->surf_ptr),
                targetid = me->surface.located_obj.objid,
                targetos = me->surface.located_obj.osnum);
 if (!(1&sts&*msg)) return (OM_E_ABORT);

 if (!(1&sts&*msg)) return (OM_E_ABORT);
 return (sts);
}

method add_pole(IGRint num_poles; IGRint *inx)
{
 IGRshort i;
 IGRlong sts,current_size, future_size;
 
 sts = OM_S_SUCCESS;

 current_size = OM_DIMENSION_OF(me->indices);
 future_size = me->num_poles + num_poles;

 if (future_size > current_size)
   sts = OM_SET_DIMENSION(me->indices, future_size + INCREMENT);
   if (!(1&sts)) goto wrapup;

 for (i=0;i<num_poles;i++)
 {
   me->indices[me->num_poles] =  inx[i];
   ++(me->num_poles);
 }

wrapup:
 return (sts);
}

method add_pole_event(IGRint num_poles)
{
 IGRlong sts,current_size,future_size;

 sts = OM_S_SUCCESS;

 current_size = OM_DIMENSION_OF(me->num_poles_array);
 future_size = me->num_pole_events + 1;

 if (future_size > current_size)
 {
  sts = OM_SET_DIMENSION(me->num_poles_array,future_size + INCREMENT);
  if (!(1&sts)) goto wrapup;
 }

 me->num_poles_array[me->num_pole_events] = num_poles;
 ++(me->num_pole_events);

wrapup:
 return (sts);
}

method display_pole_event(IGRboolean all; IGRboolean display)
{
 IGRlong sts;
 IGRint stinx;

 sts = OM_S_SUCCESS;

 if (all)
 {
  sts = om$send (msg = message ECmvpls.display_indices(0,me->num_poles,display),
                       targetid = my_id);
  if (!(1&sts)) goto wrapup;
 }
 else
 {
  stinx = me->num_poles - (me->num_poles_array[me->num_pole_events - 1]);

  sts = om$send (msg = message ECmvpls.display_indices(stinx,me->num_poles,
                       display),
                 targetid = my_id);
  if (!(1&sts)) goto wrapup;
 }

wrapup:
return(sts);
}

method backup_pole_event()
{
 IGRint num_poles_in_last_event;
 IGRint i,ii,j;
 IGRlong sts = OM_S_SUCCESS;
 
 num_poles_in_last_event = me->num_poles_array[me->num_pole_events - 1];
 me->num_poles -= num_poles_in_last_event;
 --(me->num_pole_events);

/*
 * Redisplay overlapping poles.
 */

 for (i=0;i<num_poles_in_last_event;i++)
 {
  j = me->indices[me->num_poles + i];
  for (ii=0;ii<me->num_poles;ii++)
  {
   if (j == me->indices[ii])
   {
    sts = om$send (msg = message ECmvpls.display_indices(ii,ii+1,
                       TRUE),
                 targetid = my_id);
    if (!(1&sts)) return(sts);
   }
  }
 }
 
 return (OM_S_SUCCESS);
}

method delete(int defer_flag)
{
 IGRlong sts;

 sts = OM_S_SUCCESS;
/*
 * Delete the form object.
 */

 if (me->form_id != NULL_OBJID)
 {
  sts = om$send (msg = message Root.delete(1),
                 targetid = me->form_id);
  if (!(1&sts)) return (OM_E_ABORT);
 }
/*
 * Delete the nodal surface if constructed.
 */

 if (me->mytype == MOVE_NODES)
 {
  if ((me->surface.located_obj.objid != NULL_OBJID) &&
     (me->save_surf.located_obj.objid != NULL_OBJID))
  {
   IGRlong cln_sts,loc_msg;

   cln_sts = om$send (msg = message GRgraphics.GRdelete(&loc_msg,
                  &me->surface.module_info),
                  targetid = me->surface.located_obj.objid,
                  targetos = me->surface.located_obj.osnum);
  }
/*
 * Dealloc memory.
 */

  if (me->u_vals) om$dealloc(ptr = me->u_vals);
  if (me->v_vals) om$dealloc(ptr = me->v_vals);
  if (me->weights) om$dealloc(ptr = me->weights);
  if (me->node_pts) om$dealloc(ptr = me->node_pts);

 }
  sts = om$send(mode = OM_e_wrt_ancestor,
                msg = message Root.delete(1),
                targetid = my_id);
  if (!(1&sts)) return (OM_E_ABORT);

 return (sts);
}

end implementation ECmvpls;
