class implementation NDnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#define AS_DEBUG

extern GRclassid OPP_Gexp_class_id, OPP_Gtext_exp_class_id;
extern IGRboolean ASbroadcast_in_progress;

from NDmacro import ACgive_structure;
from expression import NDset_value, modify;

method NDdrawing_copy_geom
		(struct GRid *selected_elements;
		 int 	nb_elements;
		 struct GRid **drawing_elements;
		 int    *nb_drawing_elem;
		 double *vector,*point;
		 int *level; struct IGRlbsys *lbsys;
		 struct GRmd_env *from_env,*to_env)
{
 nb_elements = 0;
 return OM_S_SUCCESS;
}


method NDdrawing_copy_attr
	      (struct myfeet *attr_name; int nb_attr; struct GRid *drawing_attr;
		 struct GRmd_env *from_env,*to_env)
{
 long status,suc;
 int i;
 struct ret_struct ret_st;
 short rc;
 IGRboolean save_br;
 extern IGRboolean ASbroadcast_in_progress;

 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;
 status = OM_S_SUCCESS;

 
 for(i=0;i<nb_attr;i++)
  {
   status = om$send(msg = message NDmacro.ACgive_structure((int *) &suc,NULL,
				attr_name[i].name,&ret_st,from_env),
		    targetid = my_id);

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
 ASbroadcast_in_progress = save_br;
 return status;
}

end implementation NDnode;
