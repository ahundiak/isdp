/* $Id: VDCmdPathWr.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPathWr.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPathWr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/08/28  16:22:16  pinnacle
# Add 'path not found' correction.
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/03/18  11:01:38  pinnacle
# Replaced: smsurf/cmd/SMCmdSurf.sl for:  by ksundar for vds.240
#
# Revision 1.2  1996/03/13  23:09:38  pinnacle
# Replaced: vdudp/cmd/VDCmdPathWr.sl for:  by yzhu for vds.240
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
 *	08/28/98	adz		Writing 'path not found' correction
 * -------------------------------------------------------------------*/

command_string       VDC_M_WrFl, 0, VDWrFl
command_table        "vds.cmd"
class                VDCmdPathWr
super_class          VDCmdPath
product_name         "$VDS"


specification

implementation

#include <stdio.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "parametric.h"
#include "expression.h"

#include "AS_status.h"

#include "VDSudp_mac.h"
#include "VDSudp_priv.h"

#include "VDSudpco.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"


#define AS_DEBUG 1
extern IGRshort  VDexp_locate(char *Pattern, char *Source);
 
from	text_exp	import	NDgive_structure;

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
	message_key	VD_M_WrFl
	prompt_key	VD_P_EnFlNm2
	filter		get_event

  on EX_STRING
	do write_file	
	    on RETURN_CODE = "SEVERE_ERROR"
		do status_key VD_S_WrtFlErr			state start
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
 char			name[DI_PATH_MAX],real_name[DI_PATH_MAX],value[DI_PATH_MAX];
 char			extrd_value[DI_PATH_MAX];
 struct GRmd_env	md_env;
 FILE			*pf;
 struct ret_struct	ret_st;
 struct GRid		exp;
 int			i, len, nb_lines;
 long			msg, sts;
 char			**lines;
 char                   info[50];
 int                    retCode = 0;
 IGRshort               sts_short=0;

	SetProc( VDCmdPathWr.write_file ); Begin


 lines = NULL; 
 me->ret = SUCCESS;


 if(me->event1.event.keyin[0] == '\0')
    strcpy(file_name,"VDSwrt_file");
 else
   strcpy(file_name, me->event1.event.keyin);

 sts = VDSis_pathdir(path, &md_env);
 if (!(sts & 1)) {printf("WARNING: No paths to write\n"); return OM_S_SUCCESS;}

 /* Tr 179600846: test if the file exist */
 pf = (FILE *) fopen(file_name,"r");
 if(pf != NULL) 
	{
          sprintf( info, "Overwrite The Existing File?");
          retCode = GRconfirm_box( info );
          if( !retCode ) {
 		fclose( pf);
		goto wrapup;
          }
        }

 pf = (FILE *) fopen(file_name,"w");
 if(pf == NULL) 
	{
		printf("cannot open file: %s\n",file_name);
   		me->ret = SEVERE_ERROR;
		goto wrapup;
	}

 len = strlen(path);

 strcpy(&path[len],":*");

 sts = di$ls( 	regexp = path,
		lines  = &lines,
		ptr    = &nb_lines);
 if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts); goto wrapup;}

 for (i=0;i<nb_lines;i++)
   {
    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

    EXP_extract_string(value,extrd_value);


     sts_short = VDexp_locate("act",real_name);
     if (sts_short != 0)
        {
         /*|don't take active paths */
         continue;
        }
     sts_short = VDexp_locate("nb",real_name);
     if (sts_short != 0)
        {
         /*|don't take nb */
         continue;
        }
     sts_short = VDexp_locate("symbol_main",real_name);
     if (sts_short != 0)
        {
          
          strcpy(&path[len],":main");
          strcat(path,&real_name[11]);


          sts = di$translate(objname = path, 
			     p_objid = &exp.objid,
                             p_osnum = &exp.osnum);
          if (sts != DIR_S_SUCCESS){
                printf("path '%s' not found\n", path );
                continue ;
          }

          /*|give structure */
          sts = om$send ( msg = message text_exp.NDgive_structure(&msg,&ret_st, 
							  &md_env),
                              senderid = NULL_OBJID,
                              targetid = exp.objid,
		              targetos = exp.osnum);
          if (! (sts & 1))
               {
                 printf("failure sending text_exp.NDgive_structure\n");
    		 me->ret = MSFAIL;
        	 as$status(sts = sts, action = RET_STATUS);
    		 return OM_S_SUCCESS;
               }

          fprintf(pf,"%s","m");
          fprintf(pf,"%s","!");
 	  fprintf(pf,"%s",ret_st.var.text_st.text_string);
          fprintf(pf,"%s","!");
 	  fprintf(pf,"%s",extrd_value);
          fprintf(pf,"%s","\n");
          continue;
        }

      sts_short = VDexp_locate("search",real_name);
      if (sts_short != 0)
        {
          fprintf(pf,"%s","s");
          fprintf(pf,"%s","!");
          fprintf(pf,"%s",extrd_value);
          fprintf(pf,"%s","\n");
          continue;
        }
   }
fflush(pf);
fclose(pf);

if(lines != NULL && nb_lines != 0) 
 {
    di$free(lines = lines,
                  count = nb_lines);
    lines    = NULL;
    nb_lines = 0;
 }
End
return OM_S_SUCCESS;
wrapup:
	me->ret = SEVERE_ERROR;
	if(lines != NULL && nb_lines != 0) 
 	{
    	 di$free(lines = lines,
                          count = nb_lines);
    	 lines    = NULL;
    	 nb_lines = 0;
 	}
End
    	return OM_S_SUCCESS;

}

/* -------------------------------------------------------- */

action init
/*.init*/
{
 SetProc( VDCmdPathWr.init ); Begin
 status     = om$send(  targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.init( type, str_ptr ) );
 as$status( action = RET_STATUS );
 End

}

/* -------------------------------------------------------- */

action delete
/*.delete*/
{
   SetProc( VDCmdPathWr.delete ); Begin
   status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.delete ( 0 ));
   End
   return ( OM_S_SUCCESS );
}


