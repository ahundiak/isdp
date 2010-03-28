#include <stdio.h>
#include <string.h>

#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "dpdef.h"
#include "dperr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "GRtypedef.h"
#include "GRprims.h"
#include "dp.h"
#include "ex.h"
#include "gr.h"

/* prototype files */
/* #include "DIstring.h" -> include when prototype file is corrected */
#include "DPchgname.h"

struct fd_name
{
    IGRshort stat;
    IGRchar name[DI_PATH_MAX];
};


/***** #define DEBUG 1  ******/   /********* FIX 90N0767 *********/

#define MAX_NUM 100

int DPchg_vw_names(	IGRlong 	*msg,
			IGRlong 	in_flags,
			GRspacenum 	osnum,
			struct EXlstcol *list,
			IGRlong 	num_in_list,
			IGRchar 	*type,
			IGRchar 	*sub_dir )

{
    DIchar path[DI_PATH_MAX];  
    DIchar savpath[DI_PATH_MAX];  
    DIchar full_name[DI_PATH_MAX];  
    IGRint status;
    IGRlong stat2;
    DIchar dir_name[DI_PATH_MAX];
    DIchar add_dir_name[DI_PATH_MAX];
    DIchar find_dir_name[DI_PATH_MAX];

    IGRint number;
    IGRchar old_name_obj[DI_PATH_MAX]; /* the name currently associated with the 
					list[index].oid in the directory */
    struct GRid cur_owner_nm; /* the objid of the object that currently has the 
				name of list[index].string*/
    IGRint 	str_differ;
    IGRlong 	dir_differ;
    struct 	fd_name fd_removed[MAX_NUM];
    IGRlong 	index, ind, fd_index;
    IGRlong 	colon_msg = 1;
    char   	*colon_ptr = NULL;

    status = 1;
    *msg = 1;

    status = di$give_pathname (osnum = osnum,
			       pathname = path);
    if(!(1&status)) 
    {
	#ifdef DEBUG
	di$report_error(sts = status, comment = "give path name failed");
	#endif
	goto fini;
    }

    status = di$cd ( dirname = path); 
    if(!(1&status))
    {
	#ifdef DEBUG
	di$report_error(sts = status, comment = "change dir failed ");
	#endif
	goto fini;
    }

    if (in_flags & DP_PROTECTION)
    {
    	status = gr$cg (groupname = "ige",
		    	passwd ="IGE");
    	    if(!(1&status)) 
    	    {
		#ifdef DEBUG
		gr$report_error(sts = status, comment = "change group failed in saved vw construct");
		#endif
		goto fini;
	    }
    }

    DIstmcat (path,GRDP_VIEWS,type,0);
    DIstrcpy (savpath,path);

    if (sub_dir != NULL)
    {
	DIstrcat (path,sub_dir);
    }

    for(index = 0; ((index < num_in_list) && (index < MAX_NUM)); index++)
    {
    	fd_removed[index].stat = 0;
    }

    for(index = 0; ((index < num_in_list) && (index < MAX_NUM)); index++)
    {
	colon_ptr = (char *)strchr(list[index].string,':');
	if (colon_ptr != NULL)
	{
		colon_msg = DPINVINP;
	}
	else
	{
    		if (fd_removed[index].stat == 0 )
		{
		/* find the name currently in the directory system associated 
		   with the passed in objid */
			status = di$untranslate (objname = full_name ,
					path = GRDP_VIEWSS,
					objid = list[index].oid,
					osnum = osnum);
    			if(!(1&status))
    			{
				#ifdef DEBUG
				di$report_error(sts = status, comment = "untranslate failed ");
				#endif
				goto wrapup;
    			}

			status = di$split(pathname=full_name,
				  name = old_name_obj,
				  dirname = dir_name);
			if (!(status &1))
			{
				#ifdef DEBUG
				di$report_error(sts = status, comment = "split failed in DPchgname");
				#endif
			}

			str_differ = strcmp (old_name_obj,list[index].string);
    		}
   		else
    		{
			DIstrcpy (dir_name,fd_removed[index].name);
			str_differ = 1;
    		}

		/* if a name change for this objid has not occurred, then no farther
			processing is needed */
    		if (str_differ) /* name change */
    		{
			dir_differ = strcmp (dir_name, path);
			if ((sub_dir == NULL) || (!dir_differ))
	    		{
	    			DIstmcpy(add_dir_name,dir_name,list[index].string,0);
	   		}
			else
	    			DIstmcpy(add_dir_name,path,list[index].string,0);

			/* find the objid currently in the directory system associated with 
				the passed in (new) name */

        		DIstmcpy ( find_dir_name,savpath,"*",list[index].string,0);
			status = di$start_dump (regexp = find_dir_name,
					ptr = &number);
	    		if ((status != DIR_W_NAME_NOT_FOUND) && (!(1&status)))
    	    		{
				#ifdef DEBUG
				di$report_error(sts = status, comment = "start dump failed ");
				#endif
				goto wrapup;
    	    		}

    			if (status == DIR_W_NAME_NOT_FOUND)
    			{
    	    			if (fd_removed[index].stat == 0)
    	    			{
    	    				status = di$rename (oldname = full_name,newname = add_dir_name);
    	    				if(!(1&status))
    	    				{
	   					stat2 = di$add_name(objname = full_name,objid = list[index].oid);
						#ifdef DEBUG
						di$report_error(sts = status, comment = "rename failed in change name ");
						#endif
						goto wrapup;
    	    				}
            			}
            			else
            			{
	   				status = di$add_name(objname = add_dir_name,objid = list[index].oid);
    					if(!(1&status))
					{
						#ifdef DEBUG
						di$report_error(sts = status, comment = "add name failed ");
						#endif
						goto wrapup;
	        			}

            			}
    			}
    			else  /* another object was found with the "new" name, and it 
				must be deleted before list[index] can added */
    			{
	    	  		status = di$fetch_dump (p_grid = 
						(struct digrid *)&cur_owner_nm,
						line = dir_name,
						index = 0);
    		  		if(!(1&status))
		  		{
					#ifdef DEBUG
					di$report_error(sts = status, comment = "add name failed ");
					#endif
					goto wrapup;
	         		}
				/* be sure there is a replacement name for this objid before you
					remove it */
    	    			fd_index = -1;
    	    			for (ind = index + 1; ind < num_in_list; ind++)
    	    			{
            				if (list[ind].oid == cur_owner_nm.objid)
	    				{
			  		/* make sure the name the list[ind].name is not the same
					as the new name or would be like duplicate name */

		    				if (!(strcmp(list[index].string, list[ind].string)))
		    				{
							*msg = DPDUPLICNM;
							status = OM_E_ABORT;
							goto wrapup;
		    				}
		    				else
	    	    			  		fd_index = ind;
	    				}
    	    			}

	    			if (fd_index == -1 )
				{
#ifdef DEBUG
					printf("error name currently used but no name given");

#endif
				}
	    			fd_removed[fd_index].stat = 1;
	    			status = di$split(pathname = dir_name,
				  	dirname  = fd_removed[fd_index].name);
	        		if (!(status &1))
	    			{
					#ifdef DEBUG
					di$report_error(sts = status, comment = "split failed in DPaddname");
					#endif
	    			}
	    			status = di$rm_objid(objid = cur_owner_nm.objid, osnum = osnum);
    				if(!(1&status))
				{
					#ifdef DEBUG
					di$report_error(sts = status, comment = "change dir failed ");
					#endif
					goto wrapup;
	        		}

	    			if (fd_removed[index].stat == 0)
	    			{
					/* remove the entry with the old name */
	    				status = di$rm_objid(objid = list[index].oid, osnum = osnum);
    					if(!(1&status))
					{
						#ifdef DEBUG
						di$report_error(sts = status, comment = "change dir failed ");
						#endif
						goto wrapup;
	        			}

	    			}
	    			status = di$add_name(objname = add_dir_name, objid = list[index].oid);
    				if(!(1&status))
				{
					#ifdef DEBUG
					di$report_error(sts = status, comment = "change dir failed ");
					#endif
					goto wrapup;
	        		}

    			} /* close for else*/

    		} /* close for if str_differ */
	}
    } /* close for for */

wrapup:

   if (in_flags & DP_PROTECTION)
   {
    	status = gr$cg (groupname = "-");
    	if(!(1&status)) 
    	{
		#ifdef DEBUG
		gr$report_error(sts = status, comment = "change group failed in saved vw construct");
		#endif
    	}
   }

    status = di$cd ( dirname = "-"); 
    if(!(1&status))
    {
	#ifdef DEBUG
	di$report_error(sts = status, comment = "change dir failed ");
	#endif
    }
if (colon_msg == DPINVINP)
{
    *msg = DPINVINP;
    status = OM_E_ABORT;
}

fini:
	return(status);
}
