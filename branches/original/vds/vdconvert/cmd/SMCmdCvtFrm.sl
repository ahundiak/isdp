/* $Id: SMCmdCvtFrm.sl,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdconvert/cmd / SMCmdCvtFrm.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdCvtFrm.sl,v $
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
# Revision 1.3  1995/08/07  21:26:04  pinnacle
# Replaced: vdconvert/cmd/SMCmdCvtFrm.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/29  15:54:24  pinnacle
# Replaced: vdconvert/cmd/SMCmdCvtFrm.sl for:  by azuurhou for vds.240
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

/**********************************************************************/
/*  CO for updating a frame system                                    */
/*  Jean Jasinczuk                                                    */
/*  Creation Dates : May-92                                           */ 
/**********************************************************************/

command_string		SMC_M_CvtPlnSys,0,SMCnPlSs
command_table		"sman.cmd"
class			SMCmdCvtFrm
super_class		VDS_LOCATE
product_name		"$VDS"

specification

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"

#include "exdef.h"
#include "exmacros.h" 

#include "go.h"
#include "gomacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "expression.h"
#include "expmacros.h"

#include "ACrg_collect.h"
#include "SMframe.h"

#include "SMmsg.h" 

/*************************************************************************/

implementation

#define AS_DEBUG 1 
#include "AS_status.h"

/* include/protypes */

struct FRSel 
{
  int nb_cc;
  int size;
  struct GRid *cc;
};

from OMObjSpace import pass;
from GRgraphics import GRfunction;

/*************************************************************************/

state_table

state start

   on CMD_TYPE = 0 do UpdAllFrmSyst				state terminate

                    
action UpdAllFrmSyst
{
OM_S_CLASSLIST		clist;
struct GRfunction_info	f_info;
extern GRclassid	OPP_nci_macro_class_id;
OMuword			classes[1];
int             	SMGiveYourId(); 
long			msg;
struct GRid		attr_grid;
OM_S_OBJID		mod_id;
struct FRSel		sel;
struct GRid		*cc = NULL;
int			i;
IGRchar			file_name[DI_PATH_MAX],
			exp_name[DI_PATH_MAX],
			cur_dir[DI_PATH_MAX];
struct GRid		tmp_obj;
  
  sel.nb_cc	= 0;
  sel.size	= 0;
  sel.cc	= cc;

  /* Test if the expression is already defined : if so the file */
  /* was already update*/

  ex$get_cur_mod( id = &mod_id, osnum = &attr_grid.osnum );

  VDSget_filename(file_name);
  di$pwd(dirname = cur_dir);

  strcat( file_name, ":IGENOD" );
  sprintf(exp_name, "%s:NewFrame", file_name );

  di$cd(dirname = file_name);
  status = di$translate(	objname = exp_name,
				osnum	= attr_grid.osnum,
				p_objid = &tmp_obj.objid);
  if(status == DIR_S_SUCCESS)
   {
#ifdef DEBUG
     printf("File already update\n");
#endif
    di$cd(dirname = cur_dir);
    goto wrapup;
   }
  else
   {
     /* Create the expression of file already update */
     status =  exp$create(exp_name  = exp_name,
			  exp_value = 1.0,
			  osnum     = attr_grid.osnum,
			  p_exp_id  = &tmp_obj);
     if(!(status & 1))
       printf("Can't create expression Newframe\n");
     di$cd(dirname = cur_dir);
   }

  go$build_user_function_buffer(buffer    = &f_info,
				 your_info = &sel);

  classes[0]      = OPP_nci_macro_class_id;
  
  clist.w_count   = 1;
  clist.w_flags   = OM_CLST_subclass;
  clist.p_classes = classes;

  status = om$send(msg = message OMObjSpace.pass
		   (&clist,OM_e_wrt_object,
		    message GRgraphics.GRfunction(&msg,SMGiveYourId, 
			                               (char *) &f_info)),
                         senderid = NULL_OBJID,
			 targetid = OM_GO_current_OS_objid,
			 targetos = attr_grid.osnum);
  as$status(action = RET_STATUS);
  if(msg == MSFAIL) 
   { 
     printf("Warning problem with update of one frame system\n");
     return OM_S_SUCCESS;
   }

  if(sel.nb_cc == 0) goto wrapup;

  for(i=0;i<sel.nb_cc;i++)
    SMUpdFrmSyst(&sel.cc[i]);

  if(sel.nb_cc > 0 && sel.cc != NULL)
    om$dealloc(ptr = sel.cc);

wrapup:
  UI_status( " Verified Conversion of Plane System " );

  goto quit ;

}  

