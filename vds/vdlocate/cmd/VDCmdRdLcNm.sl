/* $Id: VDCmdRdLcNm.sl,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/cmd / VDCmdRdLcNm.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRdLcNm.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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
# Revision 1.3  1995/08/07  23:18:14  pinnacle
# Replaced: vdlocate/cmd/VDCmdRdLcNm.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/01/06  16:05:46  pinnacle
# Replaced: vdlocate/cmd/VDCmdRdLcNm.sl by tdumbach r#
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

command_string       VDC_M_RdTxFrFl, 0, VDRdTxFrFl
command_table        "vds.cmd"
class                VDCmdRdLcNm
super_class          VDCmdLcNm
product_name         "$VDS"

specification

#include <stdio.h>
#include "DIdef.h"
#include "parametric.h"
#include "griomacros.h"
#include "FI.h"
#include "VDmsg.h"

#include "VDStextdef.h"

#define AS_DEBUG 1
instance
{
	struct GRid	VDSread_co;
	int		overr_option;
}

implementation

#include <ctype.h>
#include <stdio.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "dpmacros.h"
#include "grmessage.h"
#include "grdpbmacros.h"
#include "COBmacros.h"
#include "parametric.h"
#include "expression.h"
#include "griomacros.h"
#include "lcmacros.h"
#include "adpdef.h"
#include "igewindef.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "AS_status.h"

#include "VDSpathdef.h"
#include "VDStextdef.h"

#define AS_DEBUG 1
#define SUCCESS		1
#define SEVERE_ERROR	4
#define NO_FILE		6
#define DEBUG 1
#define COMMAND_NAME ":IGENOD:VDSpath_text_id"
#define ALLOC_INCR	3
     

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

#define SUCCESS		1
#define NO_FILE		6
#define SEVERE_ERROR	4

state start
	message_key	VD_M_RdTxFrFl
	prompt_key	VD_P_OvExtSet
	filter		get_event

  on EX_STRING
	do get_option						state get_name

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state get_name
	message_key	VD_M_RdTxFrFl
	prompt_key	VD_P_EnFlNm
	filter		get_event

  on EX_STRING
	do read_file	
	   	  on RETURN_CODE = "NO_FILE"			state no_file
                  on RETURN_CODE = "SEVERE_ERROR"		state haveError
								state terminate

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state no_file
	status_key VD_E_NotFound
	on ELSE							state -

state haveError
	status_key VD_S_ReadErr
	on ELSE							state terminate

/* -------------------------------------------------------- */
action get_option
/*.get_option */
{
me->ret = SUCCESS;
status  = OM_S_SUCCESS;

  if(me->event1.event.keyin[0] == 'n' || me->event1.event.keyin[0] == 'N' )
         me->overr_option = 0;
  else   me->overr_option = 1;
  goto quit ;
}
/* -------------------------------------------------------- */
action read_file
{
 char			file_name[DI_PATH_MAX],savtext[DI_PATH_MAX],
			text[DI_PATH_MAX], after[DI_PATH_MAX];
 FILE			*pf;
 int			option, act_nb = 0, done = 0, i, len1, warn;
 long			msg, sts;
 struct	VDStextlist	list;
 struct	VDStextset	textset;
 

 me->ret = SUCCESS;
 pf = NULL;
 warn = 0;

  UI_status("");

  list.num_textset = 0;
  list.max_textset = 0;
  list.inc_textset = 10;

  list.text = NULL;
  list.max_textset += list.inc_textset;

  list.text = (struct VDStextset *)malloc( 
		list.max_textset * sizeof( struct VDStextset ));
  if( list.text == NULL ){
	printf(" ERROR: bad allocation of testlist(%d)\n", list.max_textset );
	goto wrapup;
  }

  for( i=0; i<list.max_textset; i++ ){
    sts = VDSset_null_text( &(list.text[i]) );
    if( ! sts ){
	  printf(" ERROR: fct VDSset_null_text failed \n");
	  goto wrapup;
    }
  }

  strcpy(file_name, me->event1.event.keyin);
  if(!( pf = (FILE *) fopen(file_name,"r"))){
   	printf("file [%s] not found\n",file_name);
  	me->ret = NO_FILE;
  	return OM_S_SUCCESS;
   }


while (fgets(text,DI_PATH_MAX-1,pf) != NULL)
 {
  	EXP_strip(text);
  	i = 0;

  	/* enleve les tabulations et les fins de lignes */
  	while(text[i] == '\t'){
    		strcpy(text,&text[i+1]);
    		i = i+1;
   	}
  	len1 = strlen(text);
  	/*"len1: %d\n",len1*/
  	while( text[len1-1] == '\t' || text[len1-1] == '\n' ){
    		text[len1-1] = '\0';
    		len1 = strlen(text);
   	}
  	sts = VDStextset_part_expression( text, savtext, after);
  	if( ! sts ){
	  	/*" text not readable, continue: %s\n",text*/
		strcpy(savtext,text);
	  	continue;
  	}
  	sts = VDSsplit_string( text, &textset );
  	if( ! sts ){
	  	/*" text not readable, continue: %s\n",text*/
		warn = 1;
	  	continue;
  	}

	option = 1;
  	sts = VDSadd_in_textset_list( &list, &textset,option,NULL );
  	if( ! sts ){
	  	printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	  	goto wrapup;
  	}
    	done = done + 1;
 }/* while EOF */
if(pf) fflush(pf);
if(pf)fclose(pf);
pf = NULL;


if(!done) goto success;

 /*"look if savtext is the nb of active text: %s\n",savtext*/
 if(isdigit(savtext[0])){
	sscanf(savtext,"%d", &act_nb);
	/*"act_nb: %d\n",act_nb */
	if(act_nb < 0 || act_nb > (done-1)){
		printf("active text not avalaible take the first one as active\n");
		act_nb = 0;
	}
 }

  /*^
	VDSshow_textset_list( &list );
   */

 status     = om$send(  targetid = me->VDSread_co.objid,
 			targetos = me->VDSread_co.osnum,
			mode   = OM_e_wrt_message,
			msg    = message VDCmdLcNm.VDSadd_textsets( &msg,list,act_nb,
						me->overr_option));
 if(!(status & 1))
  {
   printf("error sending message VDCmdLcNm.add_textsets\n");
   goto wrapup;
  }

success:

	if(pf!= NULL) {fflush(pf);fclose(pf);pf = NULL;}
	if(warn) {ex$message(msgnumb = VD_S_ExpNotRd);}
  	else if(!done)  {ex$message(msgnumb = VD_S_NotRd);}
	else {ex$message(msgnumb = VD_S_RdComp);}
	if( list.text != NULL ) {free(  list.text );list.text = NULL;}
	return OM_S_SUCCESS;

wrapup:
	if(pf!= NULL) {fflush(pf);fclose(pf);pf = NULL;}

	/*|dealloc */
  	if( list.text != NULL ) {free(  list.text );list.text = NULL;}
	
	me->ret = SEVERE_ERROR;
	goto quit ;
}

/* -------------------------------------------------------- */

action init
/*.init*/
{
 char 	path_name[DI_PATH_MAX];

 status     = om$send(  targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_GSLOCATE.init( type, str_ptr ) );
 as$status( action = RET_STATUS );
 status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			    pathname = path_name );

 if ( status != DIR_S_SUCCESS )
   {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_I_STOP_SENDING );
   }

 strcat( path_name, COMMAND_NAME );

 /*^fprintf( stderr, " Form path name is [%s] \n", path_name ); */

 status = di$translate (  objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &me->VDSread_co.objid,
			  p_osnum = &me->VDSread_co.osnum );

  if ( status != DIR_S_SUCCESS )
  {
   printf("ERROR: this command must only be used with the form VDDirPath\n");
   me->state = _terminate;
   return ( OM_I_STOP_SENDING );
  }
  goto quit ;
}

/* -------------------------------------------------------- */

action delete
/*.delete*/
{
  /*" my_id is %d\n", my_id */

   status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_GSLOCATE.delete ( 0 ));
   goto quit ;
}


