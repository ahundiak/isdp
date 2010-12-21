class implementation VDCmdupdbox;



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


#define _start 0

method update_text_leader ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation VDCmdupdbox;
