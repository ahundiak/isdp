
class implementation ACncpx;

#include "AS_status.h"
#define SOLID 0
#define DOTTED 5

extern GRclassid OPP_Gexp_class_id, OPP_Gtext_exp_class_id;

from expression import NDset_value, modify;
from ACmacro_defn import ACgive_feet_desc;

method NDdrawing_copy_attr
	      (struct myfeet *attr_name; int nb_attr; struct GRid *drawing_attr;
		 struct GRmd_env *from_env,*to_env)
{
 long status,msg,suc;
 int i;
 struct ret_struct ret_st;
 short rc;

 status = OM_S_SUCCESS;

/* copy first attribute from model */

 status = om$send(msg = message ACcpx.NDdrawing_copy_attr(attr_name,nb_attr,
					drawing_attr,from_env,to_env),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 as$status(action = RET_STATUS);

 
/* For not found attributes, try to find them from PDU shit */

 for(i=0;i<nb_attr;i++)
  {
   if(drawing_attr[i].objid != NULL_OBJID) continue;

   /* 
   status = christian_va_donc_chercher_l'attribut_dans_cette_merde_de_pdm/pdu
		(attr_name[i].feet_name,&ret_st);
   */

   drawing_attr[i].osnum = to_env->md_id.osnum;
   if( status&suc&1 && ret_st.type == double_type)
    {
     status = om$construct(osnum = to_env->md_id.osnum,
			   classid = OPP_Gexp_class_id,
			   msg = message expression.NDset_value
				  (NULL,ret_st.var.root_pm_st.value,to_env,&rc),
			   p_objid = &drawing_attr[i].objid);
     as$status();
    }
   else if ( status&suc&1 && ret_st.type == text_type)
    {
     status = om$construct(osnum = to_env->md_id.osnum,
			   classid = OPP_Gtext_exp_class_id,
			   msg = message expression.modify
				  (NULL,ret_st.var.text_st.text_string,&rc),
			   p_objid = &drawing_attr[i].objid);
     as$status();
    }
   else
    {
     /*"%s is not foot of %d %d\n", attr_name[i].name,my_id,OM_Gw_current_OS */
    }

   if(!(status&suc&1)) drawing_attr[i].objid = NULL_OBJID;
  }

 
wrapup :
 return status;
}

method NDdrawing_copy_geom
		(struct GRid *selected_elements;
		 int 	nb_elements;
		 struct GRid **drawing_elements;
		 int    *nb_drawing_elem;
		 double *vector,*point;
		 int *level; struct IGRlbsys *lbsys;
		 struct GRmd_env *from_env,*to_env)
{
 long status,loc_msg;
 struct ret_struct rst;
 struct GRid mac_def,option_def;
 int dir_index = -1;
 struct GRid my_grid,component;
 int nb_feet,i_feet;
 struct myfeet *feet_desc;
 char hidden[256],rev_hidden[256],invisible[256];
 short props,action,set=-1;
 struct GRsymbology symbology;
 int visible;
 double loc_vector[3],scale,sqrt();

 status = om$send(msg = message ACcpx.find_macro(&mac_def),
		  targetid = my_id);
 if(!(status&1)) goto wrapup;

 /* search hidden line info in default parameter box */ 

 status = COm_get_option_grid(&mac_def,&option_def,NULL);

 if(!(status&1) || mac_def.objid == NULL_OBJID) goto wrapup;

 visible = 0;
 dir_index = 0;
 status = om$send(msg = message NDmacro.ACgive_structure
			((int *)&loc_msg,&dir_index,"~~hidden",&rst,from_env),
		 targetid = option_def.objid,
		 targetos = option_def.osnum);
 if(status&loc_msg&1 && rst.type == text_type)
     {visible = 1; strcpy(hidden,rst.var.text_st.text_string);}
 else 
     {hidden[0] = '\0';}

 status = om$send(msg = message NDmacro.ACgive_structure
		     ((int *)&loc_msg,&dir_index,"~~rev_hidden",&rst,from_env),
		 targetid = option_def.objid,
		 targetos = option_def.osnum);
 if(status&loc_msg&1 && rst.type == text_type)
     {visible = 1; strcpy(rev_hidden,rst.var.text_st.text_string);}
 else 
     {rev_hidden[0] = '\0';}

 status = om$send(msg = message NDmacro.ACgive_structure
		       ((int *)&loc_msg,&dir_index,"~~invisible",&rst,from_env),
		 targetid = option_def.objid,
		 targetos = option_def.osnum);
 if(status&loc_msg&1 && rst.type == text_type)
     {visible = 1; strcpy(invisible,rst.var.text_st.text_string);}
 else 
     {invisible[0] = '\0';}



 if(!visible) goto wrapup;
 scale = sqrt(from_env->md_env.matrix[0] * from_env->md_env.matrix[0] +
 	      from_env->md_env.matrix[4] * from_env->md_env.matrix[4] +
 	      from_env->md_env.matrix[8] * from_env->md_env.matrix[8]);
 if(scale< 1.e-10) return (OM_W_ABORT);

 scale = 1./scale;
 loc_vector[0] = ( from_env->md_env.matrix[0] * vector[0]
 	       + from_env->md_env.matrix[4] * vector[1]
 	       + from_env->md_env.matrix[8] * vector[2]) * scale;

 loc_vector[1] = ( from_env->md_env.matrix[1] * vector[0]
 	       + from_env->md_env.matrix[5] * vector[1]
 	       + from_env->md_env.matrix[9] * vector[2]) * scale;

 loc_vector[2] = ( from_env->md_env.matrix[2] * vector[0]
 	       + from_env->md_env.matrix[6] * vector[1]
 	       + from_env->md_env.matrix[10]* vector[2]) * scale;

 status = om$send(msg = message ACmacro_defn.ACgive_feet_desc
					(&nb_feet,&feet_desc),
		  targetid = mac_def.objid,
		  targetos = mac_def.osnum);

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 for(i_feet = 0 ; i_feet < nb_feet; i_feet++)
  {
   if(ASmatchRE(hidden,feet_desc[i_feet].name)) visible = 1;
   if(ASmatchRE(rev_hidden,feet_desc[i_feet].name)) visible = -1;
   if(ASmatchRE(invisible,feet_desc[i_feet].name)) visible = 0 ;
   status = om$send(msg = message NDmacro.ACreturn_foot
			 (&loc_msg,feet_desc[i_feet].name,&component,NULL,NULL),
		    targetid = my_id);
   if (!(status&loc_msg&1)) continue;
   if(visible && !ASisElemVisible
	(&loc_msg,&component,&my_grid,nb_elements,selected_elements,loc_vector))
						             visible = -visible;


   status = om$send(msg = message GRvg.GRgetprops(&loc_msg, &props),
                    targetid = component.objid,
		    targetos = component.osnum);
   if (!(status&loc_msg&1)) continue;

   if(!visible)
    {
     action = 0 ; props = GRIS_DISPLAYABLE;
     status = om$send(msg = message GRvg.GRchgprops(&loc_msg,&action,&props),
                    targetid = component.objid,
		    targetos = component.osnum);
    }
   else
    {
     action = 1 ; props = GRIS_DISPLAYABLE;
     status = om$send(msg = message GRvg.GRchgprops(&loc_msg,&action,&props),
                    targetid = component.objid,
		    targetos = component.osnum);

     status = om$send(msg = message GRvg.GRgetsymb(&loc_msg, &symbology),
                  targetid = component.objid,
		  targetos = component.osnum);
     if (!(status&loc_msg&1)) continue;
     if(visible>0)
     {
      symbology.display_attr.style = SOLID;
     }
     else
     {
      symbology.display_attr.style = DOTTED;
     }
     status = om$send(msg = message GRvg.GRchgstyle
				(&loc_msg,&symbology.display_attr.style),
		    targetid = component.objid,
		    targetos = component.osnum);
    }
 
 }


  wrapup :
  return (om$send(msg = message ACcpx.NDdrawing_copy_geom (selected_elements,
		 nb_elements, drawing_elements, nb_drawing_elem, vector,point,
		 level, lbsys, from_env,to_env),
	  targetid = my_id,
	  mode = OM_e_wrt_message));
}
end implementation ACncpx;
