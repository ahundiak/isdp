#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "igetypedef.h"
#include "exmacros.h"
#include "dperr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "grimport.h"

/* prototype files */
#include "DPgetid.h"
/* #include "DIstring.h" -> include when a useable prototype file is created. */


/*
#include "GRdef.h"
#include "GRtypedef.h"
#include "GRprims.h"
*/

IGRint DPgetid(
   IGRlong *msg,
   IGRchar *name,
   IGRlong array_size,
   IGRlong *total_num,
   IGRlong *numid,
   struct GRid *found_ids,
   GRspacenum *osnum,
   IGRchar *path)

{
    	IGRint status;
    	GRspacenum f_osnum;
    	GRobjid mod_objid;
        DIint  total_num_int;
  	DIint  tot_num_ids;
  	DIint	 *matches;
  	DIchar pathname[DI_PATH_MAX];  
  	DIchar savpath[DI_PATH_MAX];  
  	IGRshort index;
	GRclassid classid;
	OM_S_CLASSLIST class_list;

    	status = OM_S_SUCCESS;
    	*msg = MSSUCC;
    	*numid = 0;

	class_list.w_count = 1;
	class_list.w_flags= OM_CLST_subclass;
        class_list.p_classes = &classid;

  	status = om$get_classid( classname = "IGEgragad",
				 p_classid = &classid);
	if(!(1&status)) {
     		#ifdef DEBUG
     		printf("DPgetid.C: om$get_classid for IGEgragad failed\n");
     		#endif
     		goto fini;
	}

    	if (total_num != NULL)
        {
                total_num_int = 0;
		matches = &total_num_int;
    	}
    	else
        {
		tot_num_ids = 0;
		matches = &tot_num_ids;
    	}

    	if (osnum == NULL){
	ex$get_cur_mod( id=&mod_objid, osnum=&f_osnum);
    	}
    	else {
		f_osnum = *osnum;
    	}

	DIstmocpy (pathname,path,name,0,f_osnum);
	status = di$start_dump (regexp = pathname,
				p_classes = &class_list,
		   		ptr = matches);
        

	if (status == DIR_W_DIR_NOT_FOUND){
		*msg = DPNOOBJECTS;
	}
	else if ( status == DIR_W_NAME_NOT_FOUND ){
		DIstmocpy (savpath,path,"*",0,f_osnum);

		status = di$start_dump (regexp = savpath,
					p_classes = &class_list,
		   			ptr = &tot_num_ids);

		if ( tot_num_ids == 0){
	 		*msg = DPNOOBJECTS;
		}
	}
	else if(!(1&status)) {
     		#ifdef DEBUG
     		di$report_error(sts = status, comment = "didump failed in get savvw id");
     		#endif
     		goto fini;
	}
	else{  
    		for (index=0;(index < *matches && index < array_size);index++){
        		status = di$fetch_dump ( p_grid = (struct digrid *)found_ids,
						 index = index);
    			if(!(1&status)) {
    	    			#ifdef DEBUG
    				di$report_error(sts = status, comment = "difetch_dump failed in get savvw id");
    	    			#endif
  				goto fini;
			}

			found_ids ++;

    		} /* close for for */

    		*numid = index;

	}  /* close for else */

fini:
        if (total_num != NULL)
        {
           *total_num = total_num_int;
        } 
    	return(status);
}

