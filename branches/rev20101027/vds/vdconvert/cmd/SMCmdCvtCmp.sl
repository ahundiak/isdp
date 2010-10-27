/* $Id: SMCmdCvtCmp.sl,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdconvert/cmd / SMCmdCvtCmp.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdCvtCmp.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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
# Revision 1.3  1995/08/07  21:24:38  pinnacle
# Replaced: vdconvert/cmd/SMCmdCvtCmp.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/29  15:45:12  pinnacle
# Replaced: vdconvert/cmd/SMCmdCvtCmp.sl for:  by azuurhou for vds.240
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

/****************************************************************************

        Filename:       SMCmdCvtCmp.sl
        Author:         AD Zuurhout
        Type:           Slic File
        Process by:     $EXNUC/bin/slic SMCmdCvtCmp.sl
        Output:         SMCmdCvtCmp.S  and SMCmdCvtCmi.I
        makemake file   vdannot.m -> makefile -> ../lib/smcomp.o

        Description:

		PPL FILE TO UPDATE OLD COMPARTMENT FROM VERSION 2.2 TO 2.4
		Mainly this suppress static attributes from compartment 
		and put a flag in design file 

        History:
        ADZ     08-23-1994      Creation date

/****************************************************************************/
/*      CLASS SPECIFICATIONS                                            *****/
/****************************************************************************/

command_string       SMC_M_CvtCmpDB,0,SMCnCmFrDB
class                SMCmdCvtCmp
super_class          VDS_LOCATE
command_table        "sman.cmd"
product_name         "$VDS"

start_state          start

/****************************************************************************/
/*      SPECIFICATION AREA                                              *****/
/****************************************************************************/

specification

/****************************************************************************/
/*      IMPLEMENTATION AREA                                             *****/
/****************************************************************************/

implementation

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "exmacros.h" 
#include "expmacros.h"
#include "expression.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "SMdef.h"
#include "VDSannot.h"

#include "AS_status.h"


extern		SMUpdCompNewVers();

/************************************************************************/
/*      STATE TABLE                                                     */
/************************************************************************/

state_table

state start

   on CMD_TYPE = 0 do convert_compartments		state terminate

/************************************************************************/
/*      METHOD: convert_compartments                                    */
/************************************************************************/

action convert_compartments
{
  OM_S_OBJID	mod_id;
  GRspacenum	cur_os;
  IGRchar	file_name[DI_PATH_MAX],
		exp_name[DI_PATH_MAX],
		cur_dir[DI_PATH_MAX];
  struct GRid	tmp_obj;
  IGRlong	error = MSSUCC;

  *sts = MSSUCC;

  /*
   * Test if the expression is already defined : if so the file 
   * was already update
   */
  cur_dir[0] = '\0';
  status = di$pwd(dirname = cur_dir);
  if( status != DIR_S_SUCCESS ){
	error = MSFAIL;
	goto wrapup;
  }

  ex$get_cur_mod( id = &mod_id, osnum = &cur_os );
  status = di$give_pathname( osnum = cur_os, pathname = file_name );
  if( status != DIR_S_SUCCESS ){
	error = MSFAIL;
	goto wrapup;
  }

  strcat( file_name, ":IGENOD" );
  sprintf( exp_name, "%s:NewComp", file_name );
  status = di$cd(dirname = file_name);
  if( status != DIR_S_SUCCESS ){
	error = MSFAIL;
	goto wrapup;
  }

  status = di$translate(	objname = exp_name,
				osnum	= cur_os,
				p_objid = &tmp_obj.objid);
  if(status == DIR_S_SUCCESS){
#ifdef DEBUG
     printf("File already update\n");
#endif
    goto wrapup;
  }
 else{

  /*
   * Call function to update the compartments.
   */
   
   if(!SMUpdCompNewVers())
   {
	 error = MSFAIL;
         goto wrapup;
   }

   /* Create the expression of file already update */
   status =  exp$create(exp_name  = exp_name,
			 osnum     = cur_os,
			 exp_value = 1.0,
			 p_exp_id  = &tmp_obj);
   if(!(status & 1))
     printf("Can't create expression NewComp\n");

  }

wrapup:
  if ( error == MSFAIL ){ 
	UI_status("Error Updating compartment in design file\n");
	printf("Problem updating compartment in design file\n");
	return OM_S_SUCCESS;
  }

  if( cur_dir[0] != '\0' ){
	di$cd(dirname = cur_dir);
  }

  UI_status(" Verified Conversion of Compartments" );

  goto quit;
}  

