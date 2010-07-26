class implementation GRvg;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "OMmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "OMerrordef.h" 
#include  "go.h"
#include  "gocmacros.h"
#include  "expression.h" 
#include  "report.h"

from expression import	give_formula;
from GRconic    import	GRgetarc, GRarea;
from GRcurve	import  GRendpts;
from GRbspline	import	GRtotlength;

method GRanalyze_element(IGRlong   		*msg; 
			 struct GRmd_env   	*md_env;
			 FILE      		*rep_file_ptr; 
		 	 enum GRanalyze_types   *analyze_option)
{
    IGRint		list_size, i, k=0;
    IGRlong		status;
    IGRboolean		world=0;
    OMuword		classid;
    IGRchar		expr_text[EXP_MAX_LEN];
    IGRdouble		arc_len, area_val, startpt[3], endpt[3],
			major_axis, minor_axis, aspect_ratio;
    GRrange		range;
    OM_S_CHANSELECT	to_comps;
    struct GRid		my_grid, sym_grid;
    struct IGRarc 	arc;
    struct GRreport_processor	processor;

    extern		GRreport_analyze(), GRanalyze_cell(),
			GRprint_analyze_header();

    extern IGRdouble    MAcos();

    extern IGRlong	GRprint_units_and_cs();

    extern OMuword	OPP_GRbspline_class_id, OPP_GRcircle_class_id,
			OPP_expression_class_id, OPP_GRcirarc_class_id,
			OPP_GRellarc_class_id, OPP_GRellipse_class_id,
			OPP_GRclhdr_class_id, OPP_GRsmhdr_class_id;

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    /* get classid */
    om$get_classid(objid = my_id,
	       p_classid = &classid);

    if (om$is_ancestry_valid(superclassid = OPP_expression_class_id,
			     subclassid   = classid) == OM_S_SUCCESS )
    {
	/* get text of the expression */
	status = om$send(msg = message expression.give_formula( expr_text),
			 targetid = my_id);
	fprintf(rep_file_ptr," Expression text : %s \n",expr_text);

    } else if (om$is_ancestry_valid(superclassid = OPP_GRcircle_class_id,
				    subclassid = classid) == OM_S_SUCCESS )
    {
	status = GRprint_units_and_cs(msg, rep_file_ptr);

	status = om$send(msg = message GRconic.GRgetarc(msg,
						 &md_env->md_env.matrix_type,
						 md_env->md_env.matrix,
						 &arc),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	status = om$send(msg = message GRbspline.GRtotlength(msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  &arc_len),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	status = om$send(msg = message GRconic.GRarea(msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  &area_val),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	fprintf(rep_file_ptr," Radius        : %lg \n", arc.prim_axis);
	fprintf(rep_file_ptr," Diameter      : %lg \n", arc.prim_axis * 2);
	fprintf(rep_file_ptr," Circumference : %lg \n", arc_len);
	fprintf(rep_file_ptr," Area          : %lg \n", area_val);

	fprintf(rep_file_ptr," Center: \n");
	for ( i = 0; i < 3; i ++)
	  fprintf(rep_file_ptr," %.20f \n", arc.origin[i]);
	for ( i = 0; i < 3; i ++) {
	  fprintf(rep_file_ptr," Rot matrix ( row %d ) \n", i+1);
	  fprintf(rep_file_ptr," %.20f \n %.20f \n %.20f \n",
			arc.rot_matrix[i+k], arc.rot_matrix[i+k+1],
			arc.rot_matrix[i+k+2]);
	  k = k+3;
	};

    } else if (om$is_ancestry_valid(superclassid = OPP_GRcirarc_class_id,
				    subclassid = classid) == OM_S_SUCCESS )
    {
	status = GRprint_units_and_cs(msg, rep_file_ptr);

	status = om$send(msg = message GRconic.GRgetarc(msg,
						   &md_env->md_env.matrix_type,
						   md_env->md_env.matrix,
						   &arc),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	status = om$send(msg = message GRcurve.GRendpts(msg,
						 &md_env->md_env.matrix_type,
						 md_env->md_env.matrix,
						 startpt, endpt),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	status = om$send(msg = message GRbspline.GRtotlength(msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  &arc_len),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	fprintf(rep_file_ptr," Radius      : %lf \n", arc.prim_axis);
	fprintf(rep_file_ptr," Diameter    : %lf \n", arc.prim_axis*2);
	fprintf(rep_file_ptr," Sweep angle : %lf \n", arc.sweep_angle);
	fprintf(rep_file_ptr," Arc length  : %lf \n", arc_len);
	fprintf(rep_file_ptr," Center : \n %.20f \n %.20f \n %.20f \n",
			arc.origin[0], arc.origin[1], arc.origin[2]);
	fprintf(rep_file_ptr," Start pt : \n %.20f \n %.20f \n %.20f \n",
			startpt[0], startpt[1], startpt[2]);
	fprintf(rep_file_ptr," End pt : \n %.20f \n %.20f \n %.20f \n",
			endpt[0], endpt[1], endpt[2]);

    } else if (om$is_ancestry_valid(superclassid = OPP_GRellipse_class_id,
				    subclassid = classid) == OM_S_SUCCESS )
    {
	status = GRprint_units_and_cs(msg, rep_file_ptr);

	status = om$send(msg = message GRconic.GRgetarc(msg,
						 &md_env->md_env.matrix_type,
						 md_env->md_env.matrix,
						 &arc),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

        if ( arc.prim_axis >= arc.sec_axis )           /* Determine axes */
  	{
    	  major_axis = arc.prim_axis * 2;
    	  minor_axis = arc.sec_axis * 2;
  	}
  	else
  	{
   	  major_axis = arc.sec_axis * 2;
    	  minor_axis = arc.prim_axis * 2;
  	}

	status = om$send(msg = message GRbspline.GRtotlength(msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  &arc_len),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;
	
	aspect_ratio = minor_axis / major_axis;

	fprintf(rep_file_ptr," Major axis : %lf \n", major_axis);
	fprintf(rep_file_ptr," Minor axis : %lf \n", minor_axis);
	fprintf(rep_file_ptr," Aspect ratio : %lf \n", aspect_ratio);
	fprintf(rep_file_ptr," Apparent ratio : %lf \n", MAcos(msg, &aspect_ratio) );
	fprintf(rep_file_ptr," Sweep angle : %lf \n", arc.sweep_angle);
	fprintf(rep_file_ptr," Perimeter : %lf \n", arc_len);

	status = om$send(msg = message GRconic.GRarea(msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  &arc_len),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	fprintf(rep_file_ptr," Area : %lf \n", arc_len);
	fprintf(rep_file_ptr," Center : \n %.20f \n %.20f \n %.20f \n",
			arc.origin[0], arc.origin[1], arc.origin[2]);

    } else if (om$is_ancestry_valid(superclassid = OPP_GRellarc_class_id,
				    subclassid = classid) == OM_S_SUCCESS )
    {
	status = GRprint_units_and_cs(msg, rep_file_ptr);

	status = om$send(msg = message GRconic.GRgetarc(msg,
						   &md_env->md_env.matrix_type,
						   md_env->md_env.matrix,
						   &arc),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	status = om$send(msg = message GRcurve.GRendpts(msg,
						 &md_env->md_env.matrix_type,
						 md_env->md_env.matrix,
						 startpt, endpt),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;

	status = om$send(msg = message GRbspline.GRtotlength(msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  &arc_len),
			 targetid = my_id);
	if ( !(status & *msg & 1) )
	  goto wrapup;
	
        if ( arc.prim_axis >= arc.sec_axis )           /* Determine axes */
  	{
    	  major_axis = arc.prim_axis * 2;
    	  minor_axis = arc.sec_axis * 2;
  	}
  	else
  	{
   	  major_axis = arc.sec_axis * 2;
    	  minor_axis = arc.prim_axis * 2;
  	}

	aspect_ratio = minor_axis / major_axis;

	fprintf(rep_file_ptr," Arc length : %lf \n", arc_len);
	fprintf(rep_file_ptr," Major axis : %lf \n", major_axis);
	fprintf(rep_file_ptr," Minor axis : %lf \n", minor_axis);
	fprintf(rep_file_ptr," Aspect ratio : %lf \n", aspect_ratio);
	fprintf(rep_file_ptr," Apparent ratio : %lf \n", MAcos(msg, &aspect_ratio) );
	fprintf(rep_file_ptr," Sweep angle : %lf \n", arc.sweep_angle);
	fprintf(rep_file_ptr," Center : \n %.20f \n %.20f \n %.20f \n",
			arc.origin[0], arc.origin[1], arc.origin[2]);
	fprintf(rep_file_ptr," Start pt : \n %.20f \n %.20f \n %.20f \n",
			startpt[0], startpt[1], startpt[2]);
	fprintf(rep_file_ptr," End pt : \n %.20f \n %.20f \n %.20f \n",
			endpt[0], endpt[1], endpt[2]);

    } else if (classid == OPP_GRclhdr_class_id)
    {
      if ( *analyze_option == DETAILED )
      {
        GRanalyze_cell(msg, rep_file_ptr, &my_grid, md_env);

        /* get the cell range & print it */
        status = om$send(msg = message GRvg.GRgetrang( msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
                                                  &world,
                                                  range),
                         targetid = my_id);
 
        fprintf(rep_file_ptr, " Cell range : \n");
        for ( i = 0; i < 6 ; i ++ )
          fprintf(rep_file_ptr, "%lf  ", range[i]);
 
        fprintf(rep_file_ptr, " \ncell object id : %d \n", my_id);
 
	return(OM_S_SUCCESS);
      }

    } else if (classid == OPP_GRsmhdr_class_id)
    {
      if ( *analyze_option == DETAILED )
      {
	om$make_chanselect(channame = "GRcmpowner.to_components",
			   p_chanselect = &to_comps);

        sym_grid.objid = NULL_OBJID;
	status = om$get_objid_at_index( object = me,
			      	        p_chanselect = &to_comps,
			      		index = 0,
			      		objidaddr = &sym_grid.objid,
			      		osnumaddr = &sym_grid.osnum);

	if ( sym_grid.objid != NULL_OBJID) 
          GRanalyze_cell(msg, rep_file_ptr, &sym_grid, md_env);

        fprintf(rep_file_ptr, " Symbol object id : %d \n",my_id);
        return(OM_S_SUCCESS);
      }

    } else {

        /* call GRreport_defaluts */
        status = om$send(msg = message GRgraphics.GRreport_defaults( msg,
							NULL,
							NULL,
							&list_size,
							NULL),
		         targetid = my_id);
        if ( !(1 & status & *msg) )
           goto wrapup;

        processor.report_function = GRreport_analyze;
        processor.report_info = NULL;
        processor.report_file = (IGRchar *)rep_file_ptr; 

        status = om$send(msg = message GRgraphics.GRreport( msg,
							    md_env,
							    &list_size,
							    NULL,
							    &processor),
		         targetid = my_id);
        if ( !(1 & status & *msg) )
           goto wrapup;
    }

    if ( *analyze_option == DETAILED )
    {	
	/* call detailed analysis */
	status = GRprintAssocInfo(rep_file_ptr, &my_grid);
    }
    return(OM_S_SUCCESS);

wrapup:
    return(status);

}

end implementation GRvg;
