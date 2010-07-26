class implementation DMroot;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "grdpb.h"
#include  "csdef.h"
#include  "OMmacros.h"
#include  "dpmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "DIdef.h"
#include  "DItypedef.h"
#include  "DIprims.h"
#include  "DIglob.h"
#include  "DImacros.h"
#include  "OMerrordef.h" 
#include  "gotextdef.h"
#include  "dpbco.h"

from GRtext	import	GRgettxattr;
from DMplan	import	give_axis;

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
			 enum GRanalyze_types  *analyze_option)
{
    IGRint		long_rc;
    IGRlong		status, msg_loc;
    struct GRid         my_grid, text_grid;
    GRrange   	        range;
    IGRboolean          world = 1 ;
    IGRuchar            *name = NULL;
    IGRshort            name_length = 0;
    struct IGRestx      text_attr;

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    /* Print header info */

    GRprint_analyze_header(msg,&my_grid,rep_file_ptr);

    status = GRprint_units_and_cs(msg, rep_file_ptr);

    if( me->dim_type != CENTER_LINE)
      {
	  status = 
	  om$send( msg = message DMroot.return_dim_go( &long_rc,
					      DIM_TEXT,
					      FALSE,
					      DM_TEXT,
					      md_env,
					      &text_grid),
		  targetid = my_id);
	  dm$status(action = RET_STATUS);

	  if( long_rc != DIM_E_NO_OBJECT)
	  {
	     status =
	     om$send( msg = message GRtext.GRgettxattr(&msg_loc,
						     &text_attr,
						     &name_length,
						     &name),
		  targetid = text_grid.objid,
		  targetos = text_grid.osnum);
	      dm$status(action = RET_STATUS);

	  if(name)
	    {
	      fprintf(rep_file_ptr," Dim text : ");
	      GRanalyze_string(name, name_length, rep_file_ptr);
	    }
	   }
	}

    if( ((1 << me->dim_type) & ANNOTATION_MASK) || 
	me->dim_type == WELD			||
	me->dim_type == SURF			||
	me->dim_type == CENTER_LINE )
      {
	/* nothing extra */
      }
    else
      {
	status = 
        om$send( msg = message GRgraphics.GRgetrang(msg, 
						   &md_env->md_env.matrix_type,
						   md_env->md_env.matrix,
						   &world,
						   range),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/* Dimension value */
       fprintf(rep_file_ptr, " Dim Range:\n\t %lf,  %lf,  %lf\n\t %lf,  %lf,  %lf\n\n", 
	       range[0],range[1],range[2], range[3],range[4],range[5]);

      }


    if ( *analyze_option == DETAILED )
    {
      enum GRanalyze_types option = GENERAL;
      status = om$send( msg = message GRgraphics.GRanalyze_element(msg,
				       		md_env,
						rep_file_ptr,
						&option), 
		        p_chanselect = &AS_to_comp);

      if( ((1 << me->dim_type) & ANNOTATION_MASK) ||
	  me->dim_type == WELD			||
	  me->dim_type == SURF	)
	{
	  struct DMsenv_param par_senv;

	  status = dm$get_dim_param( type = DM_SENV_PARAM,
				    dim_objid = my_id,
				    dim_osnum = OM_Gw_current_OS,
				    p_data = (char *)&par_senv);
	  dm$status(action = RET_STATUS);
	  
	  fprintf(rep_file_ptr, " Terminator_type: %d\n",par_senv.ter_type); 
	  fprintf(rep_file_ptr, " Text font: %d\n",par_senv.text_font); 
	  fprintf(rep_file_ptr, " Text height:%lf\n",par_senv.txt_heig); 
	}
      else if ( me->dim_type != CENTER_LINE)
	{
   	  IGRvector	     axis;
	  struct DMenv_param par_env;
	  struct DMloc_param par_loc;
	  struct DMplan_info plan_info;

	  status = 
	  om$send(msg = message DMroot.get_dimension_plane(&long_rc,
							   md_env,
							   &plan_info),
		  targetid = my_id);

	  status = dm$get_dim_param( type = DM_ENV_PARAM,
				    dim_objid = my_id,
				    dim_osnum = OM_Gw_current_OS,
				    p_data = (char *)&par_env);
	  dm$status(action = RET_STATUS);
	  
	  status = dm$get_dim_param( type = DM_LOC_PARAM,
				    dim_objid = my_id,
				    dim_osnum = OM_Gw_current_OS,
				    p_data = (char *)&par_loc);
	  dm$status(action = RET_STATUS);

	  fprintf(rep_file_ptr, " Delimiter: %c\n", 
		  par_loc.primary.deci_char ? ',':'.');

	  fprintf(rep_file_ptr, " Aspect ratio: %lf\n", 
		  par_env.txt_heig/ par_env.txt_widt);

	  fprintf(rep_file_ptr, " Tolerance Height Ratio setting : %lf\n", 
		  par_env.tol_size_r);

	  fprintf(rep_file_ptr, " Common origin: %d\n",par_env.comm_origin);
	  fprintf(rep_file_ptr, " Symbol Position: %d\n", par_env.sym_posn);
	  fprintf(rep_file_ptr, " Terminator type: %d\n", par_env.ter_type0);


	  fprintf(rep_file_ptr, " Text Font: %d\n", par_env.text_font);
	  fprintf(rep_file_ptr, " Text height: %lf\n",par_env.txt_heig);
	  GRmap_justification(rep_file_ptr,text_attr.just);
	  
	  status = 
	  om$send( msg = message DMplan.give_axis( &long_rc, axis, md_env),
		  p_chanselect = &ND_father,
		  from= DIM_ROOT_PLAN, to = DIM_ROOT_PLAN);

	  if ( long_rc != NO_AXIS && (status & 1 )&&  
	      me->dim_type != STACKED_ANGULAR && 
	      me->dim_type != STRINGED_ANGULAR)
	    {
	      struct GRid list[10]; 
	      IGRint count;

	      fprintf(rep_file_ptr," Measurement axis:%lf, %lf, %lf\n",
		     axis[0],axis[1],axis[2]);
	      status = om$send( msg = message NDnode.NDget_objects(
						      ND_ROOT,
						      list,
						      MAX_DIM_ROOTS,
						      NULL,
						      0,
						      10,
						      &count),
			       p_chanselect = &ND_father,
			       from = DIM_ROOT_PLAN,
			       to   = DIM_ROOT_PLAN);
	      dm$status(action = RET_STATUS);
	      fprintf(rep_file_ptr," Measurement axis id :%d\n", (count >1 ? list[1]:list[0]));
	      
	    }
	}
      GRprintAssocInfo(rep_file_ptr,&my_grid);

      fprintf(rep_file_ptr, " Object id : %d \n", my_id);
    }

    if (name)
      free(name);

    return(status);

}

end implementation DMroot;
