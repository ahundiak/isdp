/* $Id: VDCmdupdbox.sl,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdconvert/cmd / VDCmdupdbox.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdupdbox.sl,v $
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
# Revision 1.5  1996/05/09  22:39:46  pinnacle
# Replaced: vdconvert/cmd/VDCmdupdbox.sl for:  by yzhu for vds.240
#
# Revision 1.4  1995/08/05  15:54:40  pinnacle
# Replaced: vdconvert/cmd/VDCmdupdbox.sl for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/31  14:11:04  pinnacle
# Replaced: vdconvert/cmd/VDCmdupdbox.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/29  15:39:18  pinnacle
# Replaced: vdconvert/cmd/VDCmdupdbox.sl for:  by azuurhou for vds.240
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
 *      05/08/96        yzhu            change all VDtxbox to VDfrmtxt
 * -------------------------------------------------------------------*/

/****************************************************************************

        Filename:       VDCmdupdbox.sl
        Author:         AD Zuurhout
        Type:           Slic File
        Process by:     $EXNUC/bin/slic VDCmdupdbox.sl
        Output:         VDCmdupdbox.S  and VDCmdupdboxi.I
        makemake file   vdannot.m -> makefile -> ../lib/vdannot.o

        Description:

		Temporary command object file to convert VDtxldr object into
		VDfrmtxt object with instance setting to VD_box_NO_DISPLAY.

        History:
        ADZ     09-23-1993      Creation date


/****************************************************************************/
/*      CLASS SPECIFICATIONS                                            *****/
/****************************************************************************/

command_string       VDC_M_CvtFrmTxt,0,VDCnTxLd
class                VDCmdupdbox
super_class          VDS_LOCATE
command_table        "vds.cmd"
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

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"


#include "VDSannot.h"

#include "AS_status.h"

from VDfrmtxt		import	set_box_type;

/************************************************************************/
/*      STATE TABLE                                                     */
/************************************************************************/

state_table

state start

   on CMD_TYPE = 0 do update_text_leader		state terminate

/************************************************************************/
/*      METHOD: update_text_leader                                      */
/************************************************************************/

action update_text_leader
{
  OM_S_OBJID	mod_id;
  OMuword	classid;
  GRspacenum	cur_os;
  IGRchar	file_name[DI_PATH_MAX],
		exp_name[DI_PATH_MAX],
		cur_dir[DI_PATH_MAX];
  struct GRid	tmp_obj;
  IGRuchar	box_type;
  IGRint	i, max;
  IGRlong	error = MSSUCC;

  extern GRclassid	 OPP_VDtxldr_class_id;

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
  sprintf( exp_name, "%s:NewVDtxbox", file_name );
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
    /* Create the expression of file already update */
    status =  exp$create(exp_name  = exp_name,
			 osnum     = cur_os,
			 exp_value = 1.0,
			 p_exp_id  = &tmp_obj);
    if(!(status & 1))
       printf("Can't create expression NewVDtxbox\n");

    di$cd(dirname = cur_dir);
  }

  box_type = VD_box_NO_DISPLAY;

  max = OM_GA_OSDs[cur_os]->CurSpaceMapSize ;

  /*
   * Loop on all objects in object space, looking for VDtxldr's:
   * The object wil change class into VDfrmtxt.
   */
  for( i = 0 ; i < max ; i++ ) {

                status = om$get_classid(objid           = i,
                                        osnum           = cur_os,
                                        p_classid       = &classid ) ;
                if( !( status & 1 ) ) continue ;

                if( om$is_ancestry_valid(
                                superclassid    = OPP_VDtxldr_class_id,
                                subclassid      = classid ) != OM_S_SUCCESS )
                        continue ;

		/*
		 * change class
		 */
		status =
		om$change_class(osnum     = cur_os,
				objid     = i,
				classname = "VDfrmtxt" ) ;
		if( ! ( status & 1 ) ){
			error = MSFAIL;
			continue;
        	}

		/*
		 * set new instance value / and attribute.
		 */
	        status =
		om$send(msg = message VDfrmtxt.set_box_type(sts, box_type ),
			targetid = i,
			targetos = cur_os,
			senderid = NULL_OBJID );
		if( ! (status & *sts & 1) ){
			error = MSFAIL;
			continue;
        	}
    }
    UI_status("Verified Conversion of Formatted Text with Leader");

wrapup:
    if ( error == MSFAIL ){ 
		printf("Warning problem with updating of text with leader.\n");
		return OM_S_SUCCESS;
    }

    if( cur_dir[0] != '\0' ){
		di$cd(dirname = cur_dir);
    }

    UI_status(" ");

    goto quit;
}  

