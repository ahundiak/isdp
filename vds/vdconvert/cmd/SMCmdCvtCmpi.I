class implementation SMCmdCvtCmp;



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


#define _start 0

method convert_compartments ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation SMCmdCvtCmp;
