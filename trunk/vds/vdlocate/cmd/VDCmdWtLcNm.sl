/* $Id: VDCmdWtLcNm.sl,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/cmd / VDCmdWtLcNm.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdWtLcNm.sl,v $
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
# Revision 1.4  1996/03/18  11:01:28  pinnacle
# Replaced: smsurf/cmd/SMCmdSurf.sl for:  by ksundar for vds.240
#
# Revision 1.3  1995/08/07  23:09:12  pinnacle
# Replaced: vdlocate/cmd/VDCmdWtLcNm.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/01/06  16:51:46  pinnacle
# Replaced: vdlocate/cmd/VDCmdWtLcNm.sl by tdumbach r#
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

command_string       VDC_M_WrTxInFl, 0, VDWrTxInFl
command_table        "vds.cmd"
class                VDCmdWtLcNm
super_class          VDCmdLcNm
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
#include "grmessage.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "parametric.h"
#include "expression.h"
#include "griomacros.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "AS_status.h"


#include "VDStextdef.h"
#include "VDSpathdef.h"


#define AS_DEBUG 1
#define SUCCESS		1
#define SEVERE_ERROR	4
#define NO_WRITEN	6
#define RETURN_FORM	254
#define DEBUG 1
#define MAIN 0
#define SUB 1
#define COMMAND_NAME ":IGENOD:VDSpath_text_id"
     
#define ALLOC_INCR	5   

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
#define SEVERE_ERROR	4
#define NO_WRITEN	6

state start
	message_key	VD_M_WrTxInFl
	prompt_key	VD_P_EnFlNm2
	filter		get_event

  on EX_STRING
	do write_file	
	    on RETURN_CODE = "SEVERE_ERROR"
		do status_key VD_S_WrtFlErr			state start
	    on RETURN_CODE = "NO_WRITEN"
		do status_key VD_S_NtRdInFl			state terminate
	    on RETURN_CODE = "SUCCESS"
		do status_key VD_S_OperCmp			state terminate
								state terminate

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate


/* -------------------------------------------------------- */

action write_file
/*.write_file*/
{
 char			file_name[DI_PATH_MAX],path[DI_PATH_MAX+30];
 char			name[DI_PATH_MAX],real_name[DI_PATH_MAX];
 char			value[DI_PATH_MAX],extrd_value[DI_PATH_MAX];
 FILE			*pf;
 struct GRid		dir_obj, tmp_id;
 int			i, len, nb_lines;
 char			**lines;
 IGRshort               sts_short=0 ;

 nb_lines = 0;
 lines = NULL; 
 me->ret = SUCCESS;
 pf = NULL;

 if(me->event1.event.keyin[0] == '\0')
    strcpy(file_name,"VDSwrt_file");
 else
   strcpy(file_name, me->event1.event.keyin);

 /*| get_cur_mod */
 status = ex$get_cur_mod( id = &tmp_id.objid, osnum = &tmp_id.osnum );

 /*| give pathname */
 status = di$give_pathname(osnum  = tmp_id.osnum, pathname = path );
 if( status != DIR_S_SUCCESS ){
	printf("error di$give_pathname\n");goto wrapup;
 }

 strcat( path, VDS_EXPR_DIR );
 status = di$translate(	objname = path,
			p_objid = &dir_obj.objid,
			p_osnum = &dir_obj.osnum );
 if( status != DIR_S_SUCCESS ){ 
	me->ret = NO_WRITEN;
	return OM_S_SUCCESS;
 }


 len = strlen(path);

 strcpy(&path[len],":*");

 status = di$ls( 	regexp = path,
		lines  = &lines,
		ptr    = &nb_lines);
 if (status != DIR_S_SUCCESS) {
	if( status == DIR_I_DIR_EMPTY){
		me->ret = NO_WRITEN;
		di$report_error(sts=status); goto success;
	}
	else {di$report_error(sts=status);goto wrapup;}
 }

 pf = (FILE *) fopen(file_name,"w");
 if(pf == NULL) 
	{
		printf("cannot open file: %s\n",file_name);
   		me->ret = SEVERE_ERROR;
		goto wrapup;
	}

 for (i=0;i<nb_lines;i++)
   {
    EXP_extract_lhs_rhs(lines[i],name,value);

    status = di$split(pathname = name, name = real_name);
    if (status != DIR_S_SUCCESS) {di$report_error(sts=status);goto wrapup;}

    EXP_extract_string(value,extrd_value);
    if(extrd_value[0] == '\0') continue;

    sts_short = VDexp_locate(VDS_EXP_NAME,real_name);
    if (sts_short != 0){
          fprintf(pf,"%s",extrd_value);
          fprintf(pf,"%s","\n");
          continue;
    }
    sts_short = VDexp_locate(VDS_ACT_SELECT,real_name);
    if (sts_short != 0){
          fprintf(pf,"%s",&extrd_value[6]);
          fprintf(pf,"%s","\n");
          continue;
    }

   }

fflush(pf);
fclose(pf);
pf = NULL;

success:

	if(pf!= NULL) {fflush(pf);fclose(pf);pf = NULL;}
	if(lines != NULL && nb_lines != 0) {
    		di$free(lines = lines,
                  	count = nb_lines);
    		lines    = NULL;
    		nb_lines = 0;
 	}

	return OM_S_SUCCESS;
wrapup:
	if(pf!= NULL) {fflush(pf);fclose(pf);pf = NULL;}
	me->ret = SEVERE_ERROR;
	if(lines != NULL && nb_lines != 0) 
 	{
    	 di$free(lines = lines,
                          count = nb_lines);
    	 lines    = NULL;
    	 nb_lines = 0;
 	}

	goto quit ;
}

/* -------------------------------------------------------- */

action init
/*.init*/
{
 status     = om$send(  targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_GSLOCATE.init( type, str_ptr ) );
 as$status( action = RET_STATUS );
 goto quit ;
}

/* -------------------------------------------------------- */

action delete
/*.delete*/
{
   status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_GSLOCATE.delete ( 0 ));
   goto quit ;
}

