/* $Id: SMCmdConInf.sl,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/cmd / SMCmdConInf.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdConInf.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
# Revision 1.3  1995/12/15  16:21:20  pinnacle
# Replaced: smutil/cmd/SMCmdConInf.sl for:  by v240_int for vds.240
#
# Revision 1.2  1995/07/29  16:08:12  pinnacle
# Replaced: smutil/cmd/SMCmdConInf.sl for:  by azuurhou for vds.240
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

command_string       SMC_M_CnxInf,0,SMGtCnInfo
command_table        "sman.cmd"
class                SMCmdConInf
super_class          CEO_LOCATE
product_name         "$VDS"


form "SMBrkConx" ,0,0,"-1","-1"

specification

#include <stdio.h>
#include "igrtypedef.h"
#include "FI.h"
#include "SMcon.h"

/* instance variables for form control */

instance
{
 int			nb_connections;
 struct ConnInfo	*connections;
 int			nb_broken;
 int			nb_still_broken;
 int			*broken_index;
 int			nb_TagCon;
 struct TagConInfo 	*TagCon;	
 IGRchar		report_file[DI_PATH_MAX];

}


implementation

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "parametric.h"
#include "expression.h"
#include "exdef.h"
#include "ex.h"
#include "griomacros.h"
#include "lcmacros.h"
#include "adpdef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "AS_status.h"


#define AS_DEBUG 1
     


/*----------------------- state_table ------------------------*/

state_table

#include "SMmsg.h"
#include "SMcon.h"


state start

  message_key           SM_M_CnxInf

	on CMD_TYPE = 0
		do display_form 0			state form_modify


state form_modify

  prompt_key            SM_P_CnxForm
  filter              	get_event

	on EX_FORM_FINISHED				state terminate
	on GR_UNKNOWN_TYPE.CHK_CON			state check_conx


state check_conx

  message_key           SM_M_CnxRpt		
  prompt_key            SM_P_RptName
  filter              	get_event

  on EX_STRING
	do read_file
	do create_report
		on ERROR do message_key SM_E_ErrRpt	state terminate
	do fill_form					state form_modify

  on EX_RJT_MOVEON
	do create_report
		on ERROR do message_key SM_E_ErrRpt	state terminate
	do fill_form					state form_modify

  on EX_BACK_UP						state form_modify

at init		do init_all
at delete	do delete_all

/***********************************************************/
action init_all
/*.init*/
{


 me->ret = MSSUCC;
 me->nb_connections = 0;
 me->connections = NULL;
 me->nb_broken = 0;
 me->nb_TagCon = 0;
 me->TagCon = NULL;
 me->nb_still_broken = 0;
 me->broken_index = NULL;
 strcpy(me->report_file, "TestCon.rep");

} 
/**********************************************************/

action delete_all
{
 int	i;

 if( me->connections) {free(me->connections); me->connections = NULL;}
 if( me->broken_index) {free(me->broken_index); me->broken_index = NULL;}
 if(me->TagCon){
	for(i=0;i<me->nb_TagCon;i++) FreeTagCon(&me->TagCon[i]);
	free(me->TagCon); me->TagCon = NULL;
 }
}

/**********************************************************/
action read_file
{

  if(me->event1.event.keyin[0] == '\0') strcpy(me->report_file, "TestCon.rep");
  else strcpy(me->report_file, me->event1.event.keyin);

}

/**********************************************************/
action fill_form
{
int		i, index, num_rows;
IGRchar		text[DI_PATH_MAX];


 FIfld_set_value(me->forms[0].form_ptr,NB_BROKEN,0,0,
				(IGRdouble)me->nb_broken,FALSE);
 FIfld_get_num_rows(me->forms[0].form_ptr,CONNECTION, &num_rows);
		
 FIfld_delete_rows(me->forms[0].form_ptr,CONNECTION,
                                        	0,num_rows);

 if(me->nb_broken){
	for(i=0;i<me->nb_broken;i++){
		index = me->broken_index[i] ;
		sprintf(text,"[%d,%d]",me->connections[index].source_id.objid,
				       me->connections[index].source_id.osnum);
		FIfld_set_text(me->forms[0].form_ptr,CONNECTION,i,
				0,text, FALSE);
		FIfld_set_text(me->forms[0].form_ptr,CONNECTION,i,
				1,"missing", FALSE);
	}
	
 }
 FIfld_set_value(me->forms[0].form_ptr,NB_STILL_BRK,0,0,
				(IGRdouble)me->nb_still_broken,FALSE);

}
/**********************************************************/
action create_report
{

 if( me->connections) {free(me->connections); me->connections = NULL;}
 if( me->broken_index) {free(me->broken_index); me->broken_index = NULL;}

  status = GetConnections(&me->nb_connections, &me->connections, 
			&me->nb_broken, &me->broken_index);
  if(!(status & 1)) return OM_E_ABORT;

  me->nb_still_broken = me->nb_broken;

  status = PrtCon(me->report_file, me->nb_connections, me->connections, 
			me->nb_broken, me->broken_index);
  if(!(status & 1)) return OM_E_ABORT;

}

/**********************************************************/


/**********************************************************************/
/* form_notification -						      */
/*   Override of CEO method for handling input from new C-based	forms.*/
/**********************************************************************/
action form_notification  

/*.fm_notification*/
{

 int  			i, index, suc;


 if ( form_ptr == NULL ) return( OM_E_INVARG ); 
 FIg_set_text(form_ptr,FI_MSG_FIELD, "");

 switch ( gadget_label ){

	case EXIT:
	case SAVE:
		_put_response(resp = TERMINATE);
		break;
	
	case CHK_BUTTON:
		_put_response(resp = CHK_CON);
		break;

	case ALL_CONNECT:
		if(me->nb_broken){
 			if(me->TagCon){
				for(i=0;i<me->nb_TagCon;i++) FreeTagCon(&me->TagCon[i]);
				free(me->TagCon); me->TagCon = NULL;
 			}
			status = GetTagCon(&me->nb_TagCon, &me->TagCon);
			if(!(status & 1)){
				printf("ERROR GetTagCon\n");
				goto quit;
			}

			for(i=0;i<me->nb_broken;i++){
				index = me->broken_index[i];
				status = TryReconnect(me->nb_TagCon,
						      me->TagCon,
						      &me->connections[index], 
						      &suc);
				if(status & suc & 1){
					me->nb_still_broken --;
					FIfld_set_text(me->forms[0].form_ptr,CONNECTION,i,
					1,"reconnected", FALSE);
				}
				else FIfld_set_text(me->forms[0].form_ptr,CONNECTION,i,
					1,"no object", FALSE);
			}
		}
		else  FIg_set_text(form_ptr,FI_MSG_FIELD, "Nothing to reconnect");

		FIfld_set_value(me->forms[0].form_ptr,NB_STILL_BRK,0,0,
				(IGRdouble)me->nb_still_broken,FALSE);

		break;

 }

}




