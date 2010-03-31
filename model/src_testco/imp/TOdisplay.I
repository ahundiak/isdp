/*
    This file contains the routines for displaying data
    for the "Analyze Adjacency between Surface" project.

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
** create an b_spline curve element as duplicate of old, in the
** parameter range bound[0]-bound[1]
** and with new colour and weight
*/
static int create_element(struct GRid *old, struct GRid *new, 
        struct EMSedgebound *bound, struct IGRbsp_curve *edge_geom,
	int layer, int color, int weight, int style)
{
  long Rc;
  IGRlong sts;
  IGRlong crv_msg;                    

  struct IGRbsp_curve   *new_curve =NULL;
  IGRlong EMmsg;
  
  struct IGRdisplay     crv_dis;
  struct GRmd_env       crv_env;
  struct GRvg_construct crv_const;

 
   /* trim the bspcurve at two parameters */

   if(bound[0].param > 1.0e-5 || bound[1].param < 1.0-1.0e-5)
   {
      new_curve = (struct IGRbsp_curve *)om$malloc(size = 
                                          sizeof(struct IGRbsp_curve));
      if(new_curve == NULL) goto wrapup;

      /* allocate enough space for the new curve */
      new_curve->poles = NULL;
      new_curve->knots = NULL;
      new_curve->weights = NULL;

      new_curve->poles = (IGRdouble *)om$malloc
                        (size = (3 * edge_geom->num_poles * sizeof(IGRdouble)));
      if(new_curve->poles == NULL) goto wrapup;
      new_curve->knots = (IGRdouble *)om$malloc
                         (size = (edge_geom->num_knots * sizeof(IGRdouble)));
      if(new_curve->knots == NULL) goto wrapup;
      if(edge_geom->rational == 1)
      {
         new_curve->weights = (IGRdouble *)om$malloc
                       (size = ( edge_geom->num_poles * sizeof(IGRdouble)));
         if(new_curve->weights == NULL) goto wrapup;
      }

	/* printf("trimming.\n"); */
       BSpartofcv(&Rc, edge_geom, bound[0].param, 
		0.5 *(bound[0].param+bound[1].param), bound[1].param,
	        new_curve);
       if(Rc != BSSUCC)
       {
#ifdef DBG
	    printf("ERROR BSpartofcv\n");
#endif
	    new_curve = edge_geom;
       } 
   }
   else new_curve = edge_geom;

   sts = gr$get_active_layer(msg = &crv_msg, buffer = &crv_const.level);
   sts = gr$get_module_env  (msg = &crv_msg, buffer = &crv_env);

   crv_const.msg        = &crv_msg;
   crv_const.env_info   = &crv_env;
   crv_const.newflag    = FALSE;
   crv_const.level      = layer;
   crv_const.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   crv_const.geometry    = (IGRchar *) new_curve;    
   crv_const.display    = &crv_dis;
                          crv_dis.color  = color;
                          crv_dis.weight = weight;
                          crv_dis.style  = style; 
   crv_const.class_attr = NULL;
   crv_const.name       = NULL;

   /*  construct  */
   sts = om$construct(classname = "GRbcsubbc",          
                      osnum     = old->osnum,
                      msg       = message GRgraphics.GRconstruct(&crv_const),
                      p_objid   = &new->objid);
   if(! (1 & sts )) 
   {
#ifdef DBG
printf("ERROR construct for %d\n", old->objid);
#endif
	goto wrapup;
   }

  new->osnum = old->osnum;

  if(n_to_display < MAX_TO_DISPLAY)
  {
      to_display[n_to_display].osnum = new->osnum;
      to_display[n_to_display].objid = new->objid;
      n_to_display++;
  }

wrapup:

  /* free bspcurve crv_geom */
  if ( new_curve != edge_geom )
  {
	BSfreecv (&Rc, new_curve);
  }
  return 0;
}

#ifdef NOT_YET_USED
  -- currently all elements will always be deleted before
  -- the next analyze, so we never change element
/*
** change_element symbology
**
** change color and weight of an element
*/
static int change_element_symb(struct GRid *obj,
	int layer, int color, int weight, int style)
{
    struct GRsymbology symbology;

    gr$get_symbology( object_id = obj,
		      symb      = &symbology);

    if( symbology.level               != layer ||
        symbology.display_attr.color  != color ||
        symbology.display_attr.weight != weight||
        symbology.display_attr.styl   != style)
    {
        symbology.level               = layer;
        symbology.display_attr.color  = color;
        symbology.display_attr.weight = weight;
        symbology.display_attr.style  = style;
        gr$put_symbology( object_id = obj,
                          symb      = &symbology);
    }

    return 0;
}
#endif


/*
** display_outer_boundary - loop through list out_bdr_head--out_bdr_tail
** and create (or change) temporary objects for all list elements
*/
static int display_outer_boundary( struct TOPO_param *pa,
                 struct elist *out_bdr_head,
                 struct elist *out_bdr_tail)
{
   struct elist *l = out_bdr_head;


   if(l == NULL)
   {
#ifdef DBG
	printf("Empty list of outer boundary\n");
#endif
	return -1;
   }
 
   while((l=l->next) != out_bdr_tail)
   {
#ifdef NOT_YET_USED
      if(l->ied->ext->displayed_object.objid == NULL)
      {
#endif
         create_element(&l->ied->ext->referenced_object,
		        &l->ied->ext->displayed_object,
			l->ied->ext->bound,
			l->ied->edid0->ext->edge,
		        pa->layer[TOPO_DO_I_OUTER], 
		        pa->color[TOPO_DO_I_OUTER], 
                        pa->weight[TOPO_DO_I_OUTER],
                        pa->style[TOPO_DO_I_OUTER]);
#ifdef NOT_YET_USED
      }
      else
	change_element_symb(&l->ied->ext->displayed_object,
		        pa->layer[TOPO_DO_I_OUTER], 
		        pa->color[TOPO_DO_I_OUTER], 
                        pa->weight[TOPO_DO_I_OUTER],
                        pa->style[TOPO_DO_I_OUTER]);
#endif
	
   }
   return 0;
}

/*
** display_violated - display list of violated normal/curvature etc./
** loop for list bdr_head -- bdr_tail and create (or change)
** temporary element for all list elements
*/
static int display_violated( struct TOPO_param *pa,
                 struct telist *bdr_head,
                 struct telist *bdr_tail,
		 int index)
{
   struct telist *l = bdr_head;
   struct elist *el;


   if(l == NULL)
   {
#ifdef DBG
	printf("Empty list of boundary %d\n",index);
#endif
	return -1;
   }
 
   while((l=l->next) != bdr_tail)
   {
      if(l->ied->num_ele == 0) continue;
      el = l->ied->elehead;
      while((el = el->next) != l->ied->eletail)
      {
#ifdef NOT_YET_USED
       if(el->ied->ext->displayed_object.objid == NULL)
       {
#endif
         create_element(&el->ied->ext->referenced_object,
			&el->ied->ext->displayed_object,
			el->ied->ext->bound,
			el->ied->edid0->ext->edge,
		        pa->layer[index], 
		        pa->color[index], 
                        pa->weight[index],
                        pa->style[index]);
#ifdef NOT_YET_USED
       }
       else
	 change_element_symb(&el->ied->ext->displayed_object,
		        pa->layer[index], 
		        pa->color[index], 
                        pa->weight[index],
                        pa->style[index]);
#endif
      
      }
   }
   return 0;
}

/*
** create an b_spline curve element from a point
*/
static int create_point(IGRdouble x, IGRdouble y, IGRdouble z, 
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
   struct point *l = bdr_head;
   int weight;


   if(l == NULL)
   {
#ifdef DBG
	printf("Empty list of points %d\n",index);
#endif
	return -1;
   }
   if(pa->weight[index] < 16)
      weight = 2 * pa->weight[index];
   else
      weight = 31;
   if(weight < 5)
      weight = 5;
 
   while((l=l->next) != bdr_tail)
   {
      {
#ifdef NOT_YET_USED
       if(el->ied->ext->displayed_object.objid == NULL)
       {
#endif
         create_point(l->x,l->y,l->z,
		      pa->layer[index], 
		      pa->color[index], 
                      weight);
      }
   }
   return 0;
}

/*
Name

    TOdisplay

Abstract

    display temporary objects for everything, which is
    requested.

Synopsis

int TOdisplay(struct topology *topo,
                 int n_out_bdr,
                 struct elist *out_bdr_head,
                 struct elist *out_bdr_tail,
                 int n_poi_con, struct telist *poi_con_head,
                                struct telist *poi_con_tail,
                 int n_nor_con, struct telist *nor_con_head,
                                struct telist *nor_con_tail,
                 int n_rad_con, struct telist *rad_con_head,
                                struct telist *rad_con_tail,
                 int n_ramific, struct telist *ramific_head,
                                struct telist *ramific_tail,
                 int n_poi_p_con, struct point    *p_con_head,
                                  struct point    *p_con_tail,
                 int n_poi_n_con, struct point    *n_con_head,
                                  struct point    *n_con_tail,
                 int n_poi_r_con, struct point    *r_con_head,
                                  struct point    *r_con_tail)


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
int TOdisplay(struct topology *topo,
                 int n_out_bdr,
                 struct elist *out_bdr_head,
                 struct elist *out_bdr_tail,
                 int n_poi_con, struct telist *poi_con_head,
                                struct telist *poi_con_tail,
                 int n_nor_con, struct telist *nor_con_head,
                                struct telist *nor_con_tail,
                 int n_rad_con, struct telist *rad_con_head,
                                struct telist *rad_con_tail,
                 int n_ramific, struct telist *ramific_head,
                                struct telist *ramific_tail,
                 int n_poi_p_con, struct point *p_con_head,
                                  struct point *p_con_tail,
                 int n_poi_n_con, struct point *n_con_head,
                                  struct point *n_con_tail,
                 int n_poi_r_con, struct point *r_con_head,
                                  struct point *r_con_tail)

{
   IGRlong msg;
   n_poi_p_con = n_poi_p_con; /*                 */
   n_poi_n_con = n_poi_n_con; /* wrt the compiler*/
   n_poi_r_con = n_poi_r_con; /*                 */ 

   /* get the env matrix */
   to_mdenv.matrix_type = MAIDMX;
   MAidmx (&msg, to_mdenv.matrix);

   /* set up temporary list of temporary objects */
   n_to_display = 0;
   to_display = (struct GRid *) alloca(sizeof(struct GRid) * MAX_TO_DISPLAY);

   if(topo->pa.form_state == FORM_STATE_AA)
   {
      if( (topo->pa.option & TOPO_DO_OUTER_BOUNDARY) && n_out_bdr > 0)
      {
	/* display outer boundaries: n_out_bdr etc. */
	display_outer_boundary(&topo->pa, out_bdr_head, out_bdr_tail);
      }
      if( (topo->pa.option & TOPO_DO_VIOLATED_CONTI) && n_poi_con > 0)
      {
	/* display edges with violated continuity: n_poi_con etc. */
        display_violated(&topo->pa, poi_con_head, poi_con_tail,TOPO_DO_I_VCONT);
        display_point(&topo->pa, p_con_head, p_con_tail,TOPO_DO_I_VCONT);
        display_point(&topo->pa, n_con_head, n_con_tail,TOPO_DO_I_VNORM);
        display_point(&topo->pa, r_con_head, r_con_tail,TOPO_DO_I_RADIU);

      }
      if( (topo->pa.option & TOPO_DO_VIOLATED_RADIU) && n_rad_con > 0)
      {
	/* display edges with violated radius: n_rad_con etc.  */
        display_violated(&topo->pa, rad_con_head, rad_con_tail,TOPO_DO_I_RADIU);
        display_point(&topo->pa, p_con_head, p_con_tail,TOPO_DO_I_VCONT);
        display_point(&topo->pa, n_con_head, n_con_tail,TOPO_DO_I_VNORM);
        display_point(&topo->pa, r_con_head, r_con_tail,TOPO_DO_I_RADIU);
      }
      if( (topo->pa.option & TOPO_DO_VIOLATED_NORMA) && n_nor_con > 0)
      {
	/* display edges with violated normal: n_nor_con etc.  */
        display_violated(&topo->pa, nor_con_head, nor_con_tail,TOPO_DO_I_VNORM);
        display_point(&topo->pa, p_con_head, p_con_tail,TOPO_DO_I_VCONT);
        display_point(&topo->pa, n_con_head, n_con_tail,TOPO_DO_I_VNORM);
        display_point(&topo->pa, r_con_head, r_con_tail,TOPO_DO_I_RADIU);
      }
      if( (topo->pa.option & TOPO_DO_RAMIFICATION_C) && n_ramific > 0)
      {
	/* display ramification edges: n_ramific */
        display_violated(&topo->pa, ramific_head, ramific_tail,TOPO_DO_I_RAMIF);
      }
   }
   else if(topo->pa.form_state == FORM_STATE_IE)
   {
	/* not yet implemented ... */
#ifdef DBG
	fprintf(stderr,"Investigate edge match not yet implemented\n");
#endif
   }
   else if(topo->pa.form_state == FORM_STATE_MM)
   {
      if( n_out_bdr > 0)
      {
	/* display the outer boundaries of all multiple defined surfaces:
            n_out_bdr etc. */
	display_outer_boundary(&topo->pa, out_bdr_head, out_bdr_tail);
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

   if(topo->pa.temporary_objects->displayed_object.objid == NULL)
   {
     gr$create_graphic_group(
	msg         = &msg,
        object_ids  = to_display,
        num_objects = n_to_display,
        gg_id       = &topo->pa.temporary_objects->displayed_object);
   }
   else
   {
     gr$add_to_graphic_group(
	msg         = &msg,
        object_ids  = to_display,
        num_objects = n_to_display,
        gg_id       = &topo->pa.temporary_objects->displayed_object);
   }

   /* display the temporary objects */
   dp$display( msg = &msg,
	oids     = &topo->pa.temporary_objects->displayed_object,
        mode     = GRbdheo);    /* background draw, and
                                ** highlight erase override, so that
                                ** the lines are visible, even if 
                                ** highlighted as selected element */

   return 0;
}


/*
Name

    TOdelete_temp

Abstract

    delete the temporary object(s) created for
    showing topology

Synopsis

int TOdelete_temp(struct topology *topo, int and_redraw)

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    16 Mar 94   GWW     Creation
*/
int TOdelete_temp(struct topology *topo,int and_redraw)
{
  IGRlong msg;
  IGRlong stat_OM;
  
  if((topo->pa.temporary_objects->displayed_object.objid != NULL) &&
     (!(topo->pa.option & TOPO_DO_GRAPHIC_PERMAN)))

  {
 
    gr$delete_object(
      msg = &msg,
      object_id = &topo->pa.temporary_objects->displayed_object);

    if(and_redraw)
    {
      /* redraw the underlying geometry */
      stat_OM = om$send(
	    msg = message ECtpanaly.highlight_surfaces( GRbd , TRUE),
	    senderid = NULL_OBJID,
	    targetid = topo->pa.temporary_objects->referenced_object.objid
	    );
    }
  }
  topo->pa.temporary_objects->displayed_object.objid = NULL;
  return 0;
}
end implementation ECtpanaly;
