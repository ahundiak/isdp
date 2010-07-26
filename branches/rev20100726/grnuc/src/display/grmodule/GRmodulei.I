/*----
%CH           
   change history: 

   5/19/87   HT   break out from module so ige will not depend on gr stuff 
   7/30/88   AET  change not to initialize font pointer

----*/

class implementation GRmodule;

#include <stdio.h>

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "GRdpbfunc.h"
#include "DPfddefvw.h"

#define DEBUG 1


method wake_up(int vis_flag)     /* 0-invis, 1-vis, 2-wake after 
                                    temp sleep */
{

  IGRint  status, msg;
  int     buff_size;
  struct  EX_button  EXpoint;
  GRobjid default_objid;

  buff_size = sizeof(struct EX_button);       

/* initialize os_tbl_ptr to 0 so that the invisible modules will 
   get the malloced memory pointer				*/

  if (vis_flag == 1 || vis_flag == 0 )
  {
    ME.GRmodule->fnt_os_tbl_ptr = NULL;
  }

  status = om$send(mode = OM_e_wrt_message,
		   msg = message module.wake_up(vis_flag),
		   targetid = my_id);
  if(!(1&status)) 
  {
#ifdef DEBUG
	printf("sen to module.wakeup wrt_message error\n");
#endif
	return(OM_E_ABORT);
  }

status = gr$get_last_point(  msg = &msg,
                      sizbuf = &buff_size,
                      buffer = (IGRchar *)(&EXpoint),
	              nret   = &buff_size);

if(!(1&status)) 
{
#ifdef DEBUG
    om$report_error(sts = status);
    printf("error in get last point in module");
#endif
    goto fini;
}
    status = om$is_objid_valid(objid = EXpoint.objid,osnum = EXpoint.osnum);
    if (status != OM_S_SUCCESS)
    {
	status = OM_S_SUCCESS;

    	dp$find_defaultvw(msg = (IGRlong *)(&msg),flag = DPCONST_VW,
			osnum = OM_Gw_current_OS,objid = &default_objid);
    	EXpoint.objid = default_objid;  	   /* gragad id */
    	EXpoint.osnum = OM_Gw_current_OS;  /* gragad osnum */

    	status = gr$put_last_point(  msg = &msg,
		      sizbuf = &buff_size,
		      buffer = (IGRchar *)(&EXpoint) );

    	if(!(1&status)) 
    	{
#ifdef DEBUG
    	    om$report_error(sts =status);
    	    printf("error in put last point in module");
#endif
    	    goto fini;
    	}
   }

fini:

 return(status);

} /* method wake_up */


method sleep(int temp_sleep)
{
  int status,msg;
  int     buff_size;
  struct  EX_button  EXpoint;
  GRobjid default_objid;

  status = dp$find_defaultvw(msg = (IGRlong *)(&msg),flag = 0,
				osnum = OM_Gw_current_OS,
				objid = &default_objid);
  /* if the default view is found */
  if (status & 1)
  {
  	buff_size = sizeof(struct EX_button);       

	status = gr$get_last_point(  msg = &msg,
                      sizbuf = &buff_size,
                      buffer = (IGRchar *)(&EXpoint),
	              nret   = &buff_size);
	if(!(1&status)) 
	{
#ifdef DEBUG
	    om$report_error(sts = status);
	    printf("error in get last point in module");
#endif
	    goto fini;
	}
        if ( EXpoint.objid == default_objid && 	
		EXpoint.osnum == OM_Gw_current_OS)
        {
   	    EXpoint.objid = NULL_OBJID;
    	    status = gr$put_last_point(  msg = &msg,
		      sizbuf = &buff_size,
		      buffer = (IGRchar *)(&EXpoint) );
    	    if(!(1&status)) 
    	    {
#ifdef DEBUG
    	    	om$report_error(sts =status);
    	    	printf("error in put last point in module");
#endif
    	    	goto fini;
    	    }
       }
	status = om$send (msg = message Root.delete(1),
			targetid = default_objid);
  	if(!(1&status)) 
  	{
#ifdef DEBUG
	    printf("error when deleting default view\n");
   	    om$report_error(sts =status);
#endif
  	}
  }

  status = om$send(mode = OM_e_wrt_message,
		   msg = message module.sleep(temp_sleep),
		   targetid = my_id);

/*  check_error_status(status,"sen to module.sleep wrt_message error");*/

  if(!(1&status)) 
  {
#ifdef DEBUG
	printf("sen to module.sleep wrt_message error");
#endif
	return(OM_E_ABORT);
  }
fini:
  return(status);
}
end implementation GRmodule;
