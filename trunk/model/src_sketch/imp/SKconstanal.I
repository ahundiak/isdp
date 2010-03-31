class implementation SKconstraint;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "csdef.h"
#include  "OMmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "OMerrordef.h" 

from SKvariable  import		SKgetvar;

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
			 enum GRanalyze_types  *analyze_option)
{
    IGRshort		idmattyp; 
    IGRint		i;
    OMuint		num_ptvars = 0;
    IGRlong		status;
    IGRpoint		xyzpt; 
    IGRmatrix		idmat;
    struct GRid		my_grid;
    OM_S_OBJECT_LINKAGE *objlist = NULL;    
    OM_S_CHANSELECT	cnstr_pts_chan;

    extern IGRlong	GRprint_units_and_cs();

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    status = GRprint_units_and_cs(msg, rep_file_ptr);

    EMmake_chanselect (SKconstraint_to_variables, &cnstr_pts_chan);
    om$get_channel_count (object = me, 
			  p_chanselect = &cnstr_pts_chan,
                          count = &num_ptvars);
    EMidmatrix (msg, &idmattyp, idmat);
    
    if (num_ptvars)
    {
 
       objlist = (OM_p_OBJECT_LINKAGE) alloca (num_ptvars * 
				       sizeof (OM_S_OBJECT_LINKAGE));
       
       status = om$get_channel_objects (object = me, 
					p_chanselect = &cnstr_pts_chan,
                                        size= num_ptvars, 
					list = objlist, 
					count = &num_ptvars);
       for (i=0; i<num_ptvars; i++)
       {
          status = om$send (msg = message SKvariable.SKgetvar (msg, 
					NULL, &idmattyp,
       					idmat, xyzpt), 
			    targetid = objlist[i].S_objid);
 
          fprintf (rep_file_ptr, " \t %d) Pt obj %d : [%lf %lf %lf]\n",
       		   i, objlist[i].S_objid, xyzpt[X], xyzpt[Y], xyzpt[Z]);  
       }
    }

    if ( *analyze_option == DETAILED )
    {		
	/* call detailed analysis */
	status = GRprintAssocInfo(rep_file_ptr, &my_grid);
    }

    return(status);

}

end implementation SKconstraint;
