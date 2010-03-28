class implementation ASnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "asbox.h"
#define AS_DEBUG

extern IGRboolean ASbroadcast_in_progress;
extern GRclassid OPP_GRcurve_class_id;


method NDdrawing_copy_geom
		(struct GRid *selected_elements;
		 int 	nb_elements;
		 struct GRid **drawing_elements;
		 int    *nb_drawing_elem;
		 double *vector,*point;
		 int *level;  struct IGRlbsys *lbsys;
		 struct GRmd_env *from_env,*to_env)
{
 long status,loc_msg;
 int i,index,nb_draw;
 IGRboolean save_br;
 extern IGRboolean ASbroadcast_in_progress;
 OM_S_OBJID component;

 struct GRid *drawing_component,*draw_elem;
 int nb_drawing_comp;
 GRspacenum osnum;
 int allocated_size = 0;
 GRclassid obj_class;
 struct IGRplane plane;
 double mx[16];
 short mx_type;
 struct GRmd_env id_env;
 struct GRsymbology his_symb;
 short his_props;

 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;
 status = OM_S_SUCCESS;

 /* allocate enought space to return copies */

 status = om$get_channel_count(object = me,
			       p_chanselect = &AS_to_comp,
			       count = (OMuint *) &allocated_size);
 as$status(action = GOTO_VALUE, value = wrapup);

 allocated_size +=10;
 draw_elem = (struct GRid *) om$malloc
				(size = allocated_size * sizeof(struct GRid));
  


 /*
    Copy my components by NDdrawing_copy_geom if they understand the message.
    If none of them understand the message copy by GRcopy/GRcreate_wireframe
 */

  nb_draw = 0;
  index = 0;
  while(1)
  {
   status = om$get_objid_at_index( objid      = my_id,
                                  p_chanselect  = &AS_to_comp,
                                  index         = index++,
                                  objidaddr     = &component,
				  osnumaddr	= &osnum);
   if(!(status&1)) break;

   drawing_component = NULL;
   nb_drawing_comp = 0;
   status = om$send(msg = message NDnode.NDdrawing_copy_geom
					(selected_elements, nb_elements,
		  		 	 &drawing_component,
		 			 &nb_drawing_comp,
		 			 vector,point,
					 level, lbsys,
		 			 from_env,to_env),
		    targetid = component);

   if(!(status&1))
  
    {
     status = om$send(msg = message GRgraphics.GRgetprops(&loc_msg,&his_props),
                      targetid = component);
     if(!(status&loc_msg&1)) continue;
     if(!(his_props & GRIS_DISPLAYABLE)) continue;

     status = om$send(msg = message GRvg.GRgetsymb(&loc_msg,&his_symb),
                      targetid = component);
     if(!(status&loc_msg&1)) continue;
     if(!(DPlevel_check(his_symb.level,level))) continue;

     status == om$get_classid(objid = component,
			      p_classid = &obj_class);

     if(om$is_ancestry_valid(superclassid = OPP_GRcurve_class_id,
			     subclassid = obj_class) == OM_S_SUCCESS)
       {
        status = om$send(msg = message GRgraphics.GRcopy
				          (&loc_msg,from_env,to_env,&component),
		      targetid = component);
        if(status&loc_msg&1) 
          {
	   draw_elem[nb_draw].objid = component;
           draw_elem[nb_draw++].osnum = to_env->md_id.osnum;
          }
       }

      /* use classname to be sure GRNUC link */
      /* The function is implemented in model/src_assoc/funk/ASmkwireframe */
      /* and stub in grnuc/src/go/EMSstubs/ASmkewireframe.I                */

      else if(om$is_ancestry_valid(superclassname = "EMSsurface",
				  subclassid = obj_class) == OM_S_SUCCESS)
       {
        status = ASmake_wireframe(&component,OM_Gw_current_OS,from_env,to_env,
			 &drawing_component,&nb_drawing_comp);
	if(!(status&1)) nb_drawing_comp = 0;
       }
    }

   /* +1 because when storing component_if after GRcopy */
    if(nb_draw + nb_drawing_comp +1 > allocated_size)
     {
      allocated_size = nb_draw + nb_drawing_comp +10;
      draw_elem = (struct GRid *) om$realloc(ptr = (char *) draw_elem,
				     size = allocated_size*sizeof(struct GRid));
     }

     for(i=0;i<nb_drawing_comp;i++)
      {
       draw_elem[nb_draw++] = drawing_component[i];
      }

     if(nb_drawing_comp && drawing_component)
	om$dealloc(ptr = drawing_component);
   
    }

wrapup :
 /* Now project all the elements on the drawing plane */
 plane.point  =  point;
 plane.normal =  vector;
 MAplpromx(&loc_msg,&plane,mx);
 MAtypemx(&loc_msg,mx,&mx_type);
 id_env = *to_env;

 MAidmx(&loc_msg,id_env.md_env.matrix);
 id_env.md_env.matrix_type = MAIDMX;
 for(i=0;i<nb_draw;i++)
   { 
    status = om$send(msg = message GRgraphics.GRxform(&loc_msg,&id_env,
						      &mx_type,mx,
						&draw_elem[i].objid),
		     targetid = draw_elem[i].objid,
		     targetos = draw_elem[i].osnum);
    as$status();
   }
 ASbroadcast_in_progress = save_br;
 *nb_drawing_elem = nb_draw;
 *drawing_elements = draw_elem;
 return OM_S_SUCCESS;
}

end implementation ASnode;
