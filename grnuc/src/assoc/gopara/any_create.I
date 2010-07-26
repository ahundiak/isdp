
class implementation ASnode;

#include "OMmacros.h"
/* #include "OMintprims.h" */
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "exmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "macro.h"
#include "csdef.h"
#include "grcoordsys.h"

extern GRclassid OPP_GR3dlineseg_class_id,
		 OPP_GR3dpoint_class_id,
		 OPP_GR3dcircle_class_id,
		 OPP_GR3dcirarc_class_id,
		 OPP_GRgencs_class_id,
		 OPP_expression_class_id,
		 OPP_text_exp_class_id;

from expression import create;


#define SRCcircle 3
#define SRCarc    4


/*****************************************************************************

From a returned_structure create or update a graphic object

*****************************************************************************/

#argsused
 ASany_create( md_env,inst,creation_flag,go )
 struct GRmd_env *md_env;
 struct ret_struct *inst;
 int creation_flag;
 struct GRid *go;
/*.ASany_create*/
{
 GRclassid go_classid;
 IGRlong status,msg;
 IGRlong     cnst_lis_msg;  /* return msg from cnst          */
 struct GRmd_env local_env;
 struct GRvg_construct        cnst_lis;     /* construction list         */
 IGRshort               active_level;
 struct IGRdisplay      active_display;
 IGRlong NumberOfBytes;
 IGRlong BytesReceived;

 struct IGRpolyline geom_l;
 struct IGRarc geom_c;
 struct IGRlbsys  geom_r;
 struct GRcs_construct cs_args;
 IGRint i;
 char exp_syntax[200];
 char *syntax = NULL;
 struct GRid as_grid;

 enum possible_creation { CALL_ALTCONS,
			  CALL_CONS,
			  CALL_EXP_CREATE,
			  NO_CONST   };

 enum possible_creation construct_mode;





   /*
      Is module env provided by the caller 
   */
if(md_env == NULL)
  {
   IGRlong NumberOfBytes, BytesReceived,rt;
   /*|give_any_struc provides md_env */
   NumberOfBytes = sizeof( local_env );
   gr$get_module_env(msg = &rt,
                sizbuf = &NumberOfBytes,
                buffer = &local_env,
                nret = &BytesReceived );
   md_env = &local_env;
  }

    /*
     *  get the default symbology data from the DPB
     */
    NumberOfBytes = sizeof( active_level);
    gr$get_active_level(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &active_level,
            nret = &BytesReceived);

    if ( !(msg&1)) return (OM_W_ABORT);


    /*
     *  get the default display symbology data from the DPB
     */
    NumberOfBytes = sizeof( active_display);
    gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &active_display,
            nret = &BytesReceived);

    if ( !(msg&1)) return (OM_W_ABORT);



/* prepare cnst_list */

    cnst_lis.msg = &cnst_lis_msg;
    cnst_lis.env_info = md_env;
    cnst_lis.display = &active_display;
    cnst_lis.level = active_level;
    cnst_lis.geometry = 0;
    cnst_lis.newflag = FALSE;
    cnst_lis.class_attr = NULL;
    cnst_lis.properties = 0;
    cnst_lis.name = NULL;

     

/* prepare geometry */



  construct_mode = NO_CONST;

if(inst->type&line_generic)
  {
   go_classid = OPP_GR3dlineseg_class_id;
   cnst_lis.geometry = (IGRchar *) &geom_l;
   geom_l.num_points = 2;
   geom_l.points = inst->var.line_st.p0;
   construct_mode =  CALL_ALTCONS;
  }
else if(inst->type&point_generic)
  {
   cnst_lis.geometry = (IGRchar *) &geom_l;
   go_classid = OPP_GR3dpoint_class_id;
   geom_l.num_points = 1;
   geom_l.points = inst->var.point_st.pt;
   construct_mode =  CALL_ALTCONS;
  }
else if(inst->type&conic_generic)
  {
   cnst_lis.geometry = (IGRchar *) &geom_c;
   construct_mode =  CALL_ALTCONS;

   geom_c.prim_axis   = inst->var.circle_st.rad;
   geom_c.sec_axis    = inst->var.circle_st.rad;
   geom_c.start_angle = inst->var.circle_st.start_angle;
   geom_c.sweep_angle = inst->var.circle_st.sweep_angle;
 
   for(i=0;i<3;i++)  geom_c.origin[i]     = inst->var.circle_st.cent_p[i];
   for(i=0;i<16;i++) geom_c.rot_matrix[i] = inst->var.circle_st.mat[i];
   if(inst->type==circle_type)
    {
     go_classid = OPP_GR3dcircle_class_id;
    }
   if(inst->type==arc_type)
    {
     go_classid = OPP_GR3dcirarc_class_id;
    }
   else goto wrapup;
  }
else if(inst->type==double_type)
  {
   construct_mode =  CALL_EXP_CREATE;
   sprintf(exp_syntax, "%20.9lf", inst->var.root_pm_st.value);
   syntax = exp_syntax;

   go_classid = OPP_expression_class_id;
  }
else if(inst->type==text_type) 
  {
   construct_mode =  CALL_EXP_CREATE;
   go_classid = OPP_text_exp_class_id;
   syntax = inst->var.text_st.text_string;
  }
else if(inst->type&lbs_generic)
  {
   goto wrapup;
  }
else if(inst->type&ref_generic)
  {
   cnst_lis.geometry = (IGRchar *) &geom_r;
   cnst_lis.class_attr = (IGRchar *) &cs_args;
   go_classid = OPP_GRgencs_class_id;
   construct_mode =  CALL_CONS;

   for(i=0;i<16;i++)  geom_r.matrix[i] = inst->var.ref_st.t[i];
   for (i=0;i<3;i++)
       {
        geom_r.diag_pt1[i]=0;
        geom_r.diag_pt2[i]=0;
       }

   cs_args.desc = NULL;
   cs_args.flag = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;

  }
else                    
  {
   wrapup : printf("error\n");
   return(OM_W_ABORT);
  }

/* now create the object */

       
 status=om$construct( classid = go_classid,
		    osnum   = md_env->md_id.osnum,
		    p_objid = &go->objid);
 go->osnum = md_env->md_id.osnum;

 as$status(action = RET_STATUS);

   switch (construct_mode)
    { 
      case CALL_CONS:
    	status = om$send( msg = message GRgraphics.GRconstruct( &cnst_lis ),
                    senderid = NULL_OBJID,
	    	    targetid = go->objid,
		    targetos = go->osnum );
	break;

      case CALL_ALTCONS:
    	status = om$send( msg = message GRgraphics.GRaltconstruct(&cnst_lis),
                    senderid = NULL_OBJID,
	    	    targetid = go->objid,
		    targetos = go->osnum );
	break;
   
      case CALL_EXP_CREATE:
    	status = om$send( msg = message expression.create(NULL,syntax,(IGRshort *)&msg),
                    senderid = NULL_OBJID,
	    	    targetid = go->objid,
		    targetos = go->osnum );
	if(!(msg&1)) status = OM_W_ABORT;
	break;

    }

/* Just to delete the graphic object at sleep time */

  if(construct_mode != CALL_EXP_CREATE)
    {
     status = as$make_source(go_grid = *go,
			     as_os = md_env->md_id.osnum,
			     as_grid = &as_grid);
     as$status(action = RET_STATUS);
    }
  else
    {
     as_grid = *go;
    }
  status = om$send(msg = message NDnode.NDchg_state(ND_SUP_ONLY,ND_SUP_ONLY),
		   senderid = NULL_OBJID,
	           targetid = as_grid.objid,
		   targetos = as_grid.osnum);
 as$status(action = RET_STATUS);
 return(status);
}
end implementation ASnode;

