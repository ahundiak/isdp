/* $Id: VDCmdPathAc.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPathAc.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPathAc.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

command_string       VDC_M_StAcPt, 0, VDStAcPt
command_table        "vds.cmd"
class                VDCmdPathAc
super_class          VDS_LOCATE
product_name         "$VDS"


specification


implementation

#include <stdio.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"

#include "AS_status.h"
#include "vddirmacros.h"
#include "VDSpath_form.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"

#include "VDSudpco.h"

#define AS_DEBUG 1
     
/**********************************************************/

state_table

#include "exdef.h"
#include "lcdef.h"
#include "ex.h"
#include "grio.h"
#include "griomacros.h"
#include "grmessage.h"
#include "AS_status.h"
#include "VDmsg.h"
#include "VDSudpco.h"

state start
	message_key	VD_M_StAcPt
	prompt_key	VD_P_ActPthNm
	filter		get_event

  on EX_STRING
	do get_name  
	    on RETURN_CODE = "NO_NAME"
		do status_key VD_S_NmNtFnd			state .
	    on RETURN_CODE = "NO_PATH"
		do status_key VD_S_DrNtFnd			state .
	    on RETURN_CODE = "SEVERE_ERROR"			state haveError
								state haveSearch

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state haveSearch
	message_key	VD_M_StAcPt
	prompt_key	VD_P_ActSrPthNm
	filter		get_event

  on EX_STRING
	do get_search  
	    on RETURN_CODE = "SEVERE_ERROR"			state haveError
	do status_key VD_S_OperCmp				state terminate

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state haveError
	status_key VD_E_ErrInCmd
	on ELSE							state terminate

/* -------------------------------------------------------- */
action get_name
/*.get_name */
{
char  		 	return_path[DI_PATH_MAX],return_name[NAME_MAX],
		 	out[DI_PATH_MAX];
long		 	sts;
int 		 	found;
struct GRsymbology  	symbology;	

me->ret = SUCCESS;

  sts = vds$get_path(return_path = return_path, name_path = return_name,  
               in_name = me->event1.event.keyin, symbology = &symbology, 
	       found  =&found);

  if(!(sts&1))
   {
    	printf("error vds$get_path\n");
	me->ret = SEVERE_ERROR;
	return OM_S_SUCCESS;
   }
 if(found == 0) 
  {
	printf("name %s not found\n",me->event1.event.keyin);  
  	me->ret = NO_NAME;
  	return OM_S_SUCCESS;
  }
  
  sts = vds$set_current(current_dir = return_path,
		        out_path    = out,
		        symbology   = &symbology);
  if (! (sts & 1))
  { 
   if(sts == OM_W_WARNING)
    {
	printf(" path %s doesn't exist\n",out);
  	me->ret = NO_PATH;
  	return OM_S_SUCCESS;
              
    }
   else
    {
      	printf("error vds$set_current\n");
	me->ret = SEVERE_ERROR;
	return OM_S_SUCCESS;
    }
  }
 sts = vds$set_act_path(path_name = return_name, const_flag = MAIN_PATH);
 if(!(sts&1))
   {
    	printf("error vds$set_act_path\n");
	me->ret = SEVERE_ERROR;
	return OM_S_SUCCESS;
   }

/*|update dir form */
vd$dir_update_form();
return OM_S_SUCCESS;

}
/* -------------------------------------------------------- */
action get_search
/*.get_search */
{
long		 	sts;

me->ret = SUCCESS;


 sts = vds$set_act_path(path_name = me->event1.event.keyin, 
                        const_flag = SEARCH_PATH);
 if(!(sts&1))
   {
    	printf("error vds$set_act_path\n");
	me->ret = SEVERE_ERROR;
	return OM_S_SUCCESS;
   }
/*|update dir form */
vd$dir_update_form();
return OM_S_SUCCESS;

}

