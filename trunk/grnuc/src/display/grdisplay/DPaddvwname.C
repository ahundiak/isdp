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

/* prototype files */
/* #include "DIstring.h" -> include when prototype file is stable/fixed */
#include "DPaddvwname.h"

extern char *strchr();

/*--------------------------------------------------------------------------*/

int DPadd_vw_name_dir(	IGRlong *msg,
			IGRlong in_flags,
			GRspacenum osnum,
			GRobjid objid,
			IGRchar *type,
			IGRchar *sub_dir,
			IGRchar *name )

{

    DIchar path[DI_PATH_MAX];  
    DIchar savpath[DI_PATH_MAX];  
    DIchar full_old_name[DI_PATH_MAX];  
    IGRint status;
    IGRint status1;
    DIint matches;
    DIchar dir_name[DI_PATH_MAX];
    IGRchar *colon_ptr=NULL;

    status = 1;
    *msg = 1;

    colon_ptr = strchr(name,':');
    if (colon_ptr != NULL)
    {
#ifdef DEBUG
      printf("DPadd_vw_name_dir: invalid name\n");
#endif
      status = OM_E_ABORT;
      *msg = DPINVINP;
      goto fini;
    }

    status = di$is_regexp( regexp = name );
    if(status == DIR_S_SUCCESS)
    {
#ifdef DEBUG
	printf("DPadd_vw_name_dir: ambiguous name\n");
#endif
	status = OM_E_ABORT;
	*msg = DPINVINP;
	goto fini;
    }

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
	goto wrapup;
    }

    DIstmcat (path,GRDP_VIEWS,type,0);
    DIstrcpy (savpath,path);
    matches = 0;

    status = di$start_find( start_dir = path,
			regexp = name,
			ptr = &matches);

    if(status == DIR_E_ABORT)
    {
#ifdef DEBUG
      di$report_error(sts = status, comment = "start find failed ");
#endif
      status = OM_E_ABORT;
      goto wrapup;
    }

    if(matches != 0)
    {

      /** get back to the working dir before return **/
 
      status = di$cd ( dirname = "-");
 
      if(!(1&status))
      {
#ifdef DEBUG
	  di$report_error(sts = status, comment = "change dir failed ");
#endif
      }
      if ((in_flags & DPCHG_VW_NAME) && (matches == 1))/* renaming to same name */
	return(OM_S_SUCCESS);

      return(DPDUPLICNM);
    }

    DIstmcat (path,sub_dir,name,0);

    if (in_flags & DPCHG_VW_NAME)
    {
	if (in_flags & DP_PROTECTION)
	{
    	    status = gr$cg (groupname = "ige", passwd ="IGE");
    	    if(!(1&status)) 
    	    {
		gr$report_error(sts = status, comment = "change group failed in saved vw construct");
		goto wrapup;
	    }
	}
	status = di$untranslate (objname = full_old_name,
			path = GRDP_VIEWSS,
			objid = objid,
			osnum = osnum);
    	if(!(1&status))
    	{
#ifdef DEBUG
	  di$report_error(sts = status, comment = "untranslate failed ");
#endif
	  goto wrapup;
    	}
	status = di$split(pathname=full_old_name,
				dirname = dir_name);
	if (!(status &1))
	{
#ifdef DEBUG
		di$report_error(sts = status, comment = "split failed in DPaddname");
#endif
		goto wrapup;
	}
	DIstrcat(dir_name,name);
	status = di$rename (oldname = full_old_name,newname = dir_name);
    	if(!(1&status))
    	{
#ifdef DEBUG
		di$report_error(sts = status, comment = "rename failed ");
#endif
		/** restore the old name, which gets deleted by di$rename **/
        	status1 = di$mkpath ( pathname = full_old_name, objid = objid );
         	if(!(1&status1)){
#ifdef DEBUG
			di$report_error(sts = status1, comment = "make path failed");
        		if(status1 == DIR_E_NAME_DUP)
				printf("DPaddvwname: path: %s DUPLICATE\n", path);
        		else if(status1 == DIR_E_SYNTAX)
				printf("DPaddvwname: path: %s BADLY FORMATTED\n", path);
        		else 
				printf("DPaddvwname: path: %s GENERAL FAILURE\n", path);
#endif
    		}
		
		goto wrapup;
    	}
   }
   else
   {
      	status = di$mkdir ( dirname = GRDP_VIEWS);
      	if(!(1&status) && status != DIR_E_DIR_DUP) 
      	{
#ifdef DEBUG
		di$report_error(sts = status, comment = "mkdir failed ");
#endif
		goto wrapup;
      	}

    	status = di$mkdir ( dirname = savpath);

    	if(!(1&status) && status != DIR_E_DIR_DUP) 
    	{
#ifdef DEBUG
		di$report_error(sts = status, comment = "mkdir failed ");
#endif
		goto wrapup;
    	}

    	if (in_flags & DP_PROTECTION)
    	{
    	    status = gr$cg (groupname = "ige", passwd ="IGE");
    	    if(!(1&status)) 
    	    {
#ifdef DEBUG
		gr$report_error(sts = status, comment = "change group failed in saved vw construct");
#endif
		goto wrapup;
	    }
    	}

    	status = di$mkpath ( pathname = path,
			objid = objid);
    	if(!(1&status)) 
    	{
#ifdef DEBUG
		di$report_error(sts = status, comment = "make path failed");
        	if(status == DIR_E_NAME_DUP)
			printf("DPaddvwname: path: %s DUPLICATE\n", path);
        	else if(status == DIR_E_SYNTAX)
			printf("DPaddvwname: path: %s BADLY FORMATTED\n", path);
        	else 
			printf("DPaddvwname: path: %s GENERAL FAILURE\n", path);
#endif
		goto wrapup;
    	}
    }

wrapup:
    status1 = di$cd ( dirname = "-"); 
    if(!(1&status1))
    {
#ifdef DEBUG
	di$report_error(sts = status, comment = "change dir failed ");
#endif
        status = status1;
        goto fini;
    }

    if (in_flags & DP_PROTECTION)
    {
    	status1 = gr$cg (groupname = "-");
    	if(!(1&status1)) 
    	{
#ifdef DEBUG
		gr$report_error(sts = status, comment = "change group failed in saved vw construct");
#endif
        	status = status1;
    	}
    }

fini:
	return(status);
}
