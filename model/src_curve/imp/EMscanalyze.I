class implementation GRsubbc;

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
#include  "expression.h" 
#include  "csmacros.h"
#include  "gocmacros.h"

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
			 FILE      *rep_file_ptr;
			 enum GRanalyze_types  *analyze_option)
{
    IGRint		size, i;
    IGRshort            flag = 0, num_alias = 3;
    IGRlong		status, bytes_ret;
    IGRchar		cs_name[256];
    IGRdouble		startpt[3], endpt[3];
    GRIOalias_name      distance_units[3];
    struct GRid		my_grid;
    struct IGRbsp_curve	*curve = NULL;

    *msg = status = OM_S_SUCCESS;
 
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);
    
    GRgetabsg(msg,
              &md_env->md_env.matrix_type,
              md_env->md_env.matrix,
              (IGRchar **) &curve,
              i);
 
    if (!(*msg & 1))
      goto wrapup;
 
    /* Determine BSCURVE endpts */
    status = om$send (msg = message GRcurve.GRendpts( msg,
                           		&md_env->md_env.matrix_type,
                           		md_env->md_env.matrix,
                           		startpt, endpt),
                      targetid = my_id);
 
    if (!(status & *msg & 1))
      goto wrapup;
   
    if ( curve->rational )
      fprintf(rep_file_ptr," Rational : YES;");
    else
      fprintf(rep_file_ptr," Rational : NO;");

    if ( curve->periodic )
      fprintf(rep_file_ptr," Periodic : YES;");
    else
      fprintf(rep_file_ptr," Periodic : NO;");

    if ( curve->planar )
      fprintf(rep_file_ptr," Planar : YES;");
    else
      fprintf(rep_file_ptr," Planar : NO;");

    if ( curve->phy_closed )
      fprintf(rep_file_ptr," Closed : YES;");
    else
      fprintf(rep_file_ptr," Closed : NO;");
    
    fprintf(rep_file_ptr," Order : %d;", curve->order);
    fprintf(rep_file_ptr," Number of Poles : %d\n", curve->num_poles);

    /* Get Coordinate system information */
    size = 256;
    status = cs$get_active_info(msg          = msg,
                                module       = md_env->md_id.objid,
                                namebuf_size = size,
                                name         = cs_name,
                                namebytes_ret= &bytes_ret);
 
    if (!(status & *msg & 1))
      goto wrapup;
 
    /*
     * Get the default readout units of measure.
     */
    status = co$get_default_units (msg = msg,
                                  table_name = GRIO_DISTANCE,
                                  flag = &flag,
                                  num_defaults = &num_alias,
                                  default_units = distance_units );
 
    if (!(status & *msg & 1))
      goto wrapup;

    fprintf(rep_file_ptr," Active Coordinate System: %s \n", cs_name);
    fprintf(rep_file_ptr," Units:  %s %s %s \n", distance_units[0],
                                        distance_units[0],distance_units[0]);
    fprintf(rep_file_ptr," Start pt : \n\t%lf\n\t%lf\n\t%lf\n", startpt[0],
                                        startpt[1], startpt[2]);
    fprintf(rep_file_ptr," End pt : \n\t%lf\n\t%lf\n\t%lf\n", endpt[0],
                                        endpt[1], endpt[2]);

    if ( *analyze_option  == DETAILED )
    {
      /* curve coordinates & weights of each pole */
      for ( i = 0; i < curve->num_poles; i ++ )
      {
        fprintf(rep_file_ptr," Pole (%d)\n", i);
        fprintf(rep_file_ptr,"   %lf\n    %lf\n    %lf\n", curve->poles[i],
                                curve->poles[i+1], curve->poles[i+2]);
      }

      fprintf(rep_file_ptr," Knots in U: \n");
      for ( i = 0; i < curve->num_knots; i ++ )
         fprintf(rep_file_ptr,"   %lf\n", curve->knots[i]);
      status = GRprintAssocInfo(rep_file_ptr, &my_grid);

    }

wrapup:
    return(status);

}

end implementation GRsubbc;
