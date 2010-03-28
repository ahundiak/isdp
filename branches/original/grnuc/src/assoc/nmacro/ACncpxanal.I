class implementation ACncpx;

#include  <alloca.h> 
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
#include  "DItypedef.h"
#include  "DIdef.h"
#include  "DIglob.h"
#include  "DIprims.h"
#include  "OMerrordef.h" 
#include  "acdef.h"
#include  "acmacros.h"

from ACmacro_defn import	ACgive_upscan, ACgive_feet_desc;
from ACcond_def   import	ACgive_condit_desc;

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
		         enum GRanalyze_types *analyze_option)
{
    IGRint		i, feet_num; 
    IGRlong		status;
    IGRchar		dir_name[DI_PATH_MAX], *macro_lib_name;
    struct GRid		my_grid, macro_grid, *feet_list;
    struct myfeet	*feet_def;
    enum GRanalyze_types	option;

    *msg = status = OM_S_SUCCESS;
    option = GENERAL;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    /* get the macro definition id */
    status = om$send(msg = message ACcpx.find_macro(&macro_grid),
		     targetid = my_id);

    /* get name of macro library */
    status = di$give_pathname(osnum = macro_grid.osnum,
			      pathname = dir_name);

    macro_lib_name = strrchr(dir_name,':');
    fprintf(rep_file_ptr," Name of macro library : %s \n", macro_lib_name);

    /* get the feet */
    status = om$send(msg = message ACmacro_defn.ACgive_feet_desc(&feet_num,
								 &feet_def),
		     targetid = macro_grid.objid,
		     targetos = macro_grid.osnum);

    if ( feet_num ) 
      feet_list = (struct GRid *) alloca( feet_num * sizeof(struct GRid) );

    for ( i = 0; i < feet_num; i ++)
    {
	status = om$send(msg = message NDmacro.ACreturn_foot(msg,
						feet_def[i].name,
						&feet_list[i],
						NULL, NULL),
			 targetid = my_id);
    
        if ( *analyze_option == GENERAL )
 	  status = om$send(msg = message GRgraphics.GRanalyze_element(msg,
								md_env,
								rep_file_ptr,
							        &option),
			 targetid = feet_list[i].objid,
			 targetos = feet_list[i].osnum);
     }
    if ( *analyze_option == DETAILED )
    {	
	for ( i = 0; i < feet_num; i ++ )
	{ 
	   status = om$send(msg = message GRgraphics.GRanalyze_element(msg,
								md_env,
								rep_file_ptr,
							        analyze_option),
			    targetid = feet_list[i].objid,
			    targetos = feet_list[i].osnum);
	   fprintf(rep_file_ptr, " Name of element : %s \n", feet_def[i].name);
	   status = GRprintAssocInfo(rep_file_ptr, &feet_list[i]); 
        };

        fprintf(rep_file_ptr, " Object id of Macro : %d \n", macro_grid.objid);

        /* Additionnal information for condit                    */
        {
           IGRchar 		  text[80];
	   IGRint 		  num_condit,num_value;
           struct ACcond_descrip  *condit_desc;
           struct ACcond_temp     *def_value;
 
           status = om$send(msg = message ACcond_def.ACgive_condit_desc
                                			(&num_condit,
							&condit_desc,
							&num_value,
							&def_value),
                            targetid = macro_grid.objid,
                            targetos = macro_grid.osnum );
           if(status&1)
           {
	      fprintf(rep_file_ptr, " Conditional Values \n");

              for(i=0;i<num_condit;i++)
              {
                ACprint_condition(&condit_desc[i].cond,text);
                fprintf(rep_file_ptr,"%s   %s\n",text,condit_desc[i].konst);
	      }
	   }
	}

    }

    return(status);

}

end implementation ACncpx;
