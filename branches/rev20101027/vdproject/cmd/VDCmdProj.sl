/* $Id: VDCmdProj.sl,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdproject/cmd / VDCmdProj.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdProj.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
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
# Revision 1.5  1996/06/17  17:53:38  pinnacle
# Replaced: vdproject/cmd/VDCmdProj.sl for:  by yzhu for vds.240
#
# Revision 1.4  1995/11/29  13:53:34  pinnacle
# Replaced: ./vdproject/cmd/VDCmdProj.sl for:  by ksundar for vds.240
#
# Revision 1.3  1995/10/31  14:25:22  pinnacle
# Replaced: vdproject/cmd/VDCmdProj.sl for:  by sundar for vds.240
#
# Revision 1.2  1995/09/25  21:50:46  pinnacle
# Replaced: vdproject/cmd/VDCmdProj.sl for:  by sundar for vds.240
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

/*
  FILE:		VDCmdProj.sl
  AUTHOR:	MALLIK.

  HISTORY:	
   CREATION:	17-FEB-1993.
*/


command_string	VDC_M_DefProjDat,0,VDDfPrDt
command_table	"vds.cmd"
class		VDCmdProj
super_class	VDS_LOCATE
product_name	"$VDS"
form		"VDProjIn",0,0,0,0


/***************************************************************************/

specification
#include <stdio.h>
#include <string.h>


instance
{
	char	VDproject_num[40];
	char	VDprj_num[20];
	char	VDprj_ver[12];
	int	VDprj_units_set;
	int	VDprj_no;
}

/***************************************************************************/

implementation
#include  "VDmsg.h"
#include  "VDprojdef.h"
#include  "VDDbDef.h"
#include  "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include  "PDUerror.h"

#include  "OMerrordef.h"
#include  "OMprimitives.h"
#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include  "DIdef.h"
#include  "DItypedef.h"
#include  "DIprims.h"
#include  "expression.h"
#include  "expmacros.h"
#include  "vdbmacros.h"
#include  "v_dbgmacros.h"

#include  "AS_status.h"

state_table

#include "VDmsg.h"

state start
erase_form 0  
  on CMD_TYPE = 0
    do init_all 
       on ERROR state terminate
    state form_display

state form_display

  display_form 	0
  message_key	VD_M_DefProjDat
  prompt_key	VD_P_SelPrjNum
  filter	get_event

  on EX_FORM_FINISHED	state terminate

/*
at wakeup  do form_wakeup
at sleep do form_sleep
at delete do form_delete
*/

action save_all extern

action init_all
{
  IGRint	row, num,ret_msg;
  IGRchar	**buf;
  IGRchar	project[20];
  IGRchar	proj_ver[12];
  IGRint	prj_units,prj_no;
  IGRchar	where[100];
  IGRboolean	found=FALSE, inref=FALSE;

  if(VDSverify_login() != PDM_S_SUCCESS )
  {
     ex$message(msgnumb=VD_E_PrUsNotLog);
     me->state = _terminate;
     *sts = OM_E_ABORT;
     return OM_S_SUCCESS;
  }

  /* Check if the Project number is already defined in the Reference files */
  if(VDCheckProjectNum( me->ModuleInfo.md_id.osnum, project,proj_ver,&prj_units,&prj_no, &found, &inref) != 1)
  {
     *sts = OM_E_ABORT;
     return OM_S_SUCCESS;
  }

#ifdef DEBUG
printf("Project = %s\n", project);
#endif
     ret_msg =
     vdb$RisSelect(     select        =    "prj_number",
                        table_name    =    "vds_project",
                        where         =     NULL,
                        order         =     NULL,
                        group         =     NULL,
                        numselect     =     1,
                        p_numrows     =     &num,
                        p_buffer      =     &buf );
 
     if( ret_msg != 1 )
     {
        ex$message(msgnumb=VD_E_PrVdsPrj);
        *sts = OM_E_ABORT;
        return OM_S_SUCCESS;
     }
     if ( num == 0) { ;ex$message(msgnumb=VD_E_PrVdsPrj);  *sts = OM_E_ABORT;
     return OM_S_SUCCESS;}

#ifdef DEBUG
for (row = 0; row < num; ++row)  printf("buf[%d] = %s\n", row, buf[row] );
#endif

  for (row = 0; row < num; ++row)
  {
     if (VDfld_set_list_text( me->forms[0].form_ptr,
                              G_PRJNUM,
                              row,
                              0,
                              buf[row],
                              0) != FI_SUCCESS)
     {
        UI_status("Failed to set text in project list");
        vdb$RisFreeBuffer ( buffer     =     buf,
                            size       =     num);
        *sts = OM_E_ABORT;return OM_S_SUCCESS;
     }
  }
  strcpy(project,buf[0]);
  strcpy( me->VDprj_num,project);
  vdb$RisFreeBuffer (  buffer  =   buf, 
                       size    =   num);

  sprintf(where,"prj_number='%s'", project);
  ret_msg =
  vdb$RisSelect(        select      =       "prj_version",
                        table_name  =       "vds_project",
                        where       =        where,
                        order       =        NULL,
                        group       =        NULL,
                        numselect   =        1,
                        p_numrows   =        &num,
                        p_buffer    =        &buf );
 
  if( ret_msg != 1 )
  {
     ex$message(msgnumb=VD_E_PrVdsPrj);
     *sts = OM_E_ABORT;return OM_S_SUCCESS;
  }
  if ( num == 0) { ex$message(msgnumb=VD_E_PrVdsPrj);  *sts = OM_E_ABORT;
     return OM_S_SUCCESS;
}

  for (row = 0; row < num; ++row)
  {
     if (VDfld_set_list_text( me->forms[0].form_ptr,
                              G_PRJVER,
                              row,
                              0,
                              buf[row],	/* PROJECT VERSION */
                              0) != FI_SUCCESS)
     {
        UI_status("Failed to set text in project list");
        vdb$RisFreeBuffer (    buffer   =     buf,
                               size     =     num);
        *sts = OM_E_ABORT;
     return OM_S_SUCCESS;
     }
  }

  strcpy(proj_ver,buf[0]);
  strcpy( me->VDprj_ver,proj_ver);
  vdb$RisFreeBuffer ( buffer  =    buf,
                      size    =    num);

  FIfld_set_text( me->forms[0].form_ptr, G_PRJNUM, 0, 0, project, 0);
  FIfld_set_text( me->forms[0].form_ptr, G_PRJVER, 0, 0, proj_ver, 0);

#ifdef DEBUG
printf(" me->VDprj_num = %s\n",me->VDprj_num );
#endif

  status = om$send(msg = message VDCmdProj.save_all(sts),
	  targetid = my_id );
  as$status();

  *sts = OM_S_SUCCESS;
}

action form_notification
{
  IGRint  		sel_flag, r_pos;
  IGRchar       	project[20];
  IGRchar       	proj_ver[12];
  IGRint		row, num,ret_msg;
  IGRchar		where[100];
  IGRchar		**buf;
  IGRlong 		sts=OM_S_SUCCESS;

#ifdef DEBUG
	printf(" form_notification %d\n",gadget_label );
#endif
  if( me->forms[0].form_ptr == NULL )
    return (OM_E_INVARG) ;  /* no form ptr set */

  buf = NULL ;
  num = 0;

  FIfld_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, 0, 0, "", FALSE);

  switch( gadget_label )
  {
    case FI_CANCEL: 
	me->VDproject_num[0]='\0';
        _put_response(resp = TERMINATE);
	break;

    case G_PRJNUM:
	
	FIfld_get_text( me->forms[0].form_ptr, G_PRJNUM, 0, 0, 20, 
                        (unsigned char *)project, &sel_flag, &r_pos);
	project[19]='\0';
    	if((project == NULL) || (project[0] == '\0'))
    	{
	   FIg_set_text(me->forms[0].form_ptr,FI_PROMPT_FIELD,
	   			"Missing Project Name");
	   FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT );
  	   _put_response(resp = TERMINATE);
	   goto wrapup;
    	}
	strcpy( me->VDprj_num,project);

	sprintf(where,"prj_number='%s'", project);
        ret_msg =
        vdb$RisSelect(  select     =       "prj_version",
                        table_name =       "vds_project",
                        where      =        where,
                        order      =        NULL,
                        group      =        NULL,
                        numselect  =        1,
                        p_numrows  =        &num,
                        p_buffer   =        &buf );

	if( ret_msg  != 1 || !num || buf == NULL )
     	{
	   ex$message(msgnumb = VD_E_PrjNotFound,
		   type = "%s", var = `project`);
           status = OM_E_ABORT;
           goto wrapup ; 
     	}
	FIfld_set_list_num_rows( me->forms[0].form_ptr,G_PRJVER,0,num);
	for (row = 0; row < num; ++row)
	{
  		VDfld_set_list_text( me->forms[0].form_ptr,
                              	     G_PRJVER,
                              	     row,
                              	     0,
                              	     buf[row],	/* PROJECT VERSION */
                              	     0);
	}

	strcpy(proj_ver,buf[0]);
 	FIfld_set_text( me->forms[0].form_ptr, G_PRJVER, 0, 0, proj_ver, 0);
	FIfld_get_text( me->forms[0].form_ptr, G_PRJVER, 0, 0, 12, 
			(unsigned char *)proj_ver, &sel_flag, &r_pos);
	proj_ver[11]='\0';
	strcpy( me->VDprj_ver,proj_ver);
	status = om$send(msg = message VDCmdProj.save_all(&sts),
	   targetid = my_id );
	__CheckRC( status, sts, "VDCmdProj.save_all", wrapup );
	break;

    case G_PRJVER:
	FIfld_get_text( me->forms[0].form_ptr, G_PRJVER, 0, 0, 12, 
		      (unsigned char *)proj_ver, &sel_flag, &r_pos);
	proj_ver[11]='\0';
	strcpy( me->VDprj_ver,proj_ver);
	status = om$send(msg = message VDCmdProj.save_all(&sts),
	   targetid = my_id );
	__CheckRC( status, sts, "VDCmdProj.save_all", wrapup );
	break;

    case FI_ACCEPT:
	VDCreateExp ( me->VDproject_num,TRUE );   /* In Transient */
	VDCreateExp ( me->VDproject_num,FALSE );  /* In USR       */
	status = om$send(msg = message VDCmdProj.save_all(&sts),
	   targetid = my_id );
	__CheckRC( status, sts, "VDCmdProj.save_all", wrapup );
	FIg_set_state_off( me->forms[0].form_ptr, FI_ACCEPT );
        _put_response(resp = TERMINATE);
	break;
  }

	vdb$RisFreeBuffer(	buffer 	= buf,
				size	= num ) ;
	goto quit ;

wrapup:
	vdb$RisFreeBuffer(	buffer 	= buf,
				size	= num ) ;
	return( status );
}

/*
action form_wakeup
{
  *sts = OM_S_SUCCESS;
}

action form_sleep
{
  *sts = OM_S_SUCCESS;
}

action form_delete
{
  *sts = OM_S_SUCCESS;
}
*/
