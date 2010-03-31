/*
    This file contains the routines for displaying data
    for the "Investigate Edge Match" feature.

*/

class implementation ECtpanaly;

# include <alloca.h>
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "dp.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "EMSmsgdef.h"
# include "OMerrordef.h"
# include "emserr.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMSopt.h"
# include "EMS.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSlmdef.h"
#include "EMSasopts.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_E.h"
#include "EC_M.h"
#include "GRtypedef.h"
#include "EMSascmacros.h"
# include <stdio.h>
# include "TOstruct1.h"
# include "TOdsl.h"
# include "TOtopology.h"
# include "TOproto_ta.h"
#include "TOproto_ds.h"
# include <time.h>
#undef clock
#include "exmacros.h"
#include "bserr.h"
#include "dpmacros.h"
#include "grmacros.h"

from GRgraphics   import GRconstruct; 
from EMSedge      import EMget_bcxyz_geom;


static struct GRid *to_display; /* this is the list of objects to display */
static int        n_to_display;
#define MAX_TO_DISPLAY 10000

static  struct GRmdenv_info to_mdenv; /* to store the env */



/*
** create an b_spline curve element from a point
*/
int create_point(IGRdouble x, IGRdouble y, IGRdouble z, 
	                int layer, int color, int weight)
{
  IGRlong             sts;
  IGRlong             crv_msg;                    
  struct GRid         new;
  struct IGRbsp_curve new_curve;
  struct IGRpolyline  py;
  IGRdouble           knots[6]; 
  IGRdouble           points[6]; 
  IGRlong             EMmsg;
  
  struct IGRdisplay     crv_dis;
  struct GRmd_env       crv_env;
  struct GRvg_construct crv_const;

 
   /* create a bspline curve from point */
   py.num_points = 1;
   py.points     = points;
   py.points[0]  = x; 
   py.points[1]  = y; 
   py.points[2]  = z; 
   new_curve.poles     = py.points;
   new_curve.knots     = knots;

   sts=MApytobc(&EMmsg,&py,&new_curve);
   if(EMmsg != MAIDGENRAT)
   { 
      sts = 1;
#ifdef DBG
      printf("ERROR MApytobc\n");
#endif
      goto wrapup;
   }

   sts = gr$get_active_layer(msg = &crv_msg, buffer = &crv_const.level);
   sts = gr$get_module_env  (msg = &crv_msg, buffer = &crv_env);

   crv_const.msg        = &crv_msg;
   crv_const.env_info   = &crv_env;
   crv_const.newflag    = FALSE;
   crv_const.level      = layer;
   crv_const.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   crv_const.geometry    = (IGRchar *) &new_curve;    
   crv_const.display    = &crv_dis;
                          crv_dis.color  = color;
                          crv_dis.weight = weight;
                          crv_dis.style  = NULL; 
   crv_const.class_attr = NULL;
   crv_const.name       = NULL;

   /*  construct  */
   sts = om$construct(classname = "GR3dpoint",          
                      osnum     = crv_env.md_id.osnum,
                      msg       = message GRgraphics.GRconstruct(&crv_const),
                      p_objid   = &new.objid);
   if(! (1 & sts )) 
   {
#ifdef DBG
printf("ERROR construct for %f  %f  %f\n", x,y,z);
#endif
	goto wrapup;
   }

  new.osnum = crv_env.md_id.osnum;

  if(n_to_display < MAX_TO_DISPLAY)
  {
      to_display[n_to_display].osnum = new.osnum;
      to_display[n_to_display].objid = new.objid;
      n_to_display++;
  }

wrapup:

  return 0;
}


/*
** display_violated - display list of violated normal/curvature etc./
** loop for list bdr_head -- bdr_tail and create (or change)
** temporary element for all list elements
*/
static int display_point( struct TOPO_param *pa,
                 struct point *bdr_head,
                 struct point *bdr_tail,
		 int index)
{
   int weight;
   struct point *l = bdr_head;


   if(l == NULL)
   {
#ifdef DBG
	printf("Empty list of points %d\n",index);
#endif
	return -1;
   }
 
   while((l=l->next) != bdr_tail)
   {
      weight = pa->edge_weight[index];
      if(l->status == 99)weight = 2*weight;
      if(weight < 5)
         weight = 5;
      else if(weight > 31)
         weight = 31;
      create_point(l->x,l->y,l->z,
                   pa->edge_layer[index], 
                   pa->edge_color[index], 
                   weight);
      
   }
   return 0;
}

/*
Name

    TOdisplay_points

Abstract

    display temporary objects for everything, which is
    requested.

Synopsis

int TOdisplay_points(struct topology *topo,
                     int n_poi_con, struct point *p_con_head,
                                    struct point *p_con_tail,
                     int n_nor_con, struct point *n_con_head,
                                    struct point *n_con_tail,
                     int n_rad_con, struct point *r_con_head,
                                    struct point *r_con_tail)

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    17 mar 94   GWW     Creation
    17 Jun 94   BBU     Use available edge geometry
*/
int TOdisplay_points(struct topology *topo,
                     int n_poi_p_con, struct point *p_con_head,
                                      struct point *p_con_tail,
                     int n_poi_n_con, struct point *n_con_head,
                                      struct point *n_con_tail,
                     int n_poi_r_con, struct point *r_con_head,
                                      struct point *r_con_tail)

{
   IGRlong msg;

   /* get the env matrix */
   to_mdenv.matrix_type = MAIDMX;
   MAidmx (&msg, to_mdenv.matrix);

   /* set up temporary list of temporary objects */
   n_to_display = 0;
   to_display = (struct GRid *) alloca(sizeof(struct GRid) * MAX_TO_DISPLAY);

   if(topo->pa.form_state == FORM_STATE_IE)
   {
      if( (topo->pa.option & TOPO_MO_DISTANCE) && n_poi_p_con > 0)
      {
        /* display distance violation: */
        display_point(&topo->pa, p_con_head, p_con_tail,TOPO_DO_I_OUTER);
      }
      if( (topo->pa.option & TOPO_MO_NORMAL) && n_poi_n_con > 0)
      {
        /* display normal violation: n_poi_con etc. */
        display_point(&topo->pa, n_con_head, n_con_tail,TOPO_DO_I_VCONT);
      }
      if( (topo->pa.option & TOPO_MO_RADIUS  ) && n_poi_r_con > 0)
      {
        /* display edges with violated radius: n_poi_r_con etc.  */
        display_point(&topo->pa, r_con_head, r_con_tail,TOPO_DO_I_VNORM);
      }
   }
   else 
   {
      /* not yet implemented ... */
#ifdef DBG
      fprintf(stderr,"Invalid form state %d='%c'\n",topo->pa.form_state,
                                                    topo->pa.form_state);
#endif 
   }

   /* collect the temporary objects in a group */

   if(topo->pa.temporary_points->displayed_object.objid == NULL)
   {
     gr$create_graphic_group(
	msg         = &msg,
        object_ids  = to_display,
        num_objects = n_to_display,
        gg_id       = &topo->pa.temporary_points->displayed_object);
   }
   else
   {
     gr$add_to_graphic_group(
	msg         = &msg,
        object_ids  = to_display,
        num_objects = n_to_display,
        gg_id       = &topo->pa.temporary_points->displayed_object);
   }

   /* display the temporary objects */
   dp$display( msg = &msg,
	oids     = &topo->pa.temporary_points->displayed_object,
        mode     = GRbdheo);    /* background draw, and
                                ** highlight erase override, so that
                                ** the lines are visible, even if 
                                ** highlighted as selected element */

   return 0;
}


/*
Name

    TOdelete_points

Abstract

    delete the temporary object(s) created for
    showing topology

Synopsis

int TOdelete_points(struct topology *topo, int and_redraw)

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    16 Mar 94   GWW     Creation
*/
int TOdelete_points(struct topology *topo,int and_redraw)
{
  IGRlong msg;
  IGRlong stat_OM;
  
  if((topo->pa.temporary_points->displayed_object.objid != NULL) &&
     (!(topo->pa.option & TOPO_DO_GRAPHIC_PERMAN)))

  {
 
    gr$delete_object(
      msg = &msg,
      object_id = &topo->pa.temporary_points->displayed_object);

    if(and_redraw)
    {
      /* redraw the underlying geometry */
       struct GRmd_env       crv_env;
       IGRlong     loc_mx_type;
       IGRmatrix   *loc_mx_ptr;
       stat_OM = gr$get_module_env  (msg = &msg, buffer = &crv_env);
 
       loc_mx_type = (IGRlong) crv_env.md_env.matrix_type;
       loc_mx_ptr = &crv_env.md_env.matrix;
   
       stat_OM = dp$display(msg = &msg,
                        mtx_type = &loc_mx_type,
                        matrix = &loc_mx_ptr,
                        oids = &topo->pa.temporary_objects->displayed_object,
                        mode = GRbd);
    }
  }
  topo->pa.temporary_points->displayed_object.objid = NULL;
  return 0;
}
end implementation ECtpanaly;
