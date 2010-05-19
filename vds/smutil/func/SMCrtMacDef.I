/* $Id: SMCrtMacDef.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMCrtMacDef.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCrtMacDef.I,v $
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

class implementation Root;

#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "acdef.h"
#include "macro.h"
#include "acmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "exmacros.h"

#include "AS_status.h"

from ci_mac_def	import ACplace;
from GRvg import GRgetname;

/* 
/*   SMCrtMacDef:
/*
/*   This function initializes a simple macro definition
/*
/* */
SMCrtMacDef(mac_def, mac_lib, nb_temp, temp_list, temp_type, nb_feet, feet_list, 
            nb_temp_feet, temp_feet_ind, temp_feet_list, mac_id)
char	*mac_def;	  /* Macro definition name	(I) */
char	*mac_lib;	  /* Macro library name		(I) */
int	 nb_temp;	  /* Number of of templates	(I) */
char	*temp_list[];	  /* Template list		(I) */
int	temp_type[];	  /* Template type list		(I) */
int	 nb_feet;	  /* Number of feet		(I) */
char	*feet_list[];	  /* Feet list			(I) */
int	 nb_temp_feet;    /* Number of template feet	(I) */
int	 temp_feet_ind[]; /* template feet index	(I) */
char	*temp_feet_list[];/* template feet list		(I) */
struct GRid	*mac_id;/* Macro definition id		(O) */
{
 long 		status, loc_msg;
 IGRchar 	full_path[40+15+macro_MAX_CHAR+15+macro_MAX_CHAR+1];
 struct GRid	dir, tmp_id;
 IGRchar 	cur_mac_lib[macro_MAX_CHAR+1];
 IGRint  	name_len;

 cur_mac_lib[0] = '\0';
 
 /* Get the active macro lib */
 status = ac$construct_wd(mode 		= AC_INQ, 
   		    	  name 		= cur_mac_lib,
			  name_size 	= macro_MAX_CHAR,
			  name_len  	= &name_len);
 if(!(status & 1)) return status;

 /* Get the path of the macro def (do a translate to know if existing) */
 VDSget_filename(full_path);
 strcat(full_path,":constructs_lib:");
 strcat(full_path, mac_lib);

 status = di$translate(objname = full_path,
              p_objid = &mac_id->objid,
              p_osnum = &mac_id->osnum);
 if(!(status&1))
  {
   /* The macro lib is not mounted, so do it */
   /* Add name to the path (if not already done) */
   status = ac$construct_path (	mode = AC_ADD_PATH,
                          	name = mac_lib);
   if(!(status & 1)) return status;
  }

 /* Look if the macro already exist */
 strcat(full_path, ":constructs:");
 strcat(full_path, mac_def);

 status = di$translate(	objname = full_path,
              		p_objid = &tmp_id.objid,
              		p_osnum = &tmp_id.osnum);
 if(!(status&1))
  {
   IGRint def_mode;

   /* The macro does not exist */
   /* Set the mac_lib active */
   status = ac$construct_wd(mode = AC_SET, 
                    	    name = mac_lib, 
			    dir  = &dir);
   if(!(status & 1)) return status;
   mac_id->osnum = dir.osnum;


   /* The macro is not defined, so do it */
   def_mode = ACcant_place_sym;
   status = om$construct(classid = OPP_ci_mac_def_class_id,
			 osnum   = mac_id->osnum,
			 p_objid = &mac_id->objid,
			 msg = message ci_mac_def.ACplace((int *) &loc_msg, def_mode,
			     mac_def, "", 0, nb_temp, temp_list, temp_type,
			     nb_temp_feet, temp_feet_ind, temp_feet_list, 
			     0, NULL, NULL, nb_feet, feet_list, NULL, NULL)); 
   /* save the macro lib */
   if(status & 1) ac$save_wd();

   /* Restore the active macro lib */
   if(cur_mac_lib[0] != '\0') ac$construct_wd(mode = AC_SET, name = cur_mac_lib);
   as$status(action = RET_STATUS);
  }
 else
  {
   *mac_id = tmp_id;
  }

 return OM_S_SUCCESS;
}

/* A fonction of global use : respond 1 if the object is an ancestre */
/*  of the classid */

int SMIsKindOf(obj,classid)
struct GRid *obj;    
GRclassid   classid;
{
  GRclassid  obj_class;
 
  om$get_classid(osnum = obj->osnum,
		 objid = obj->objid,
		 p_classid = &obj_class );
     
  if(om$is_ancestry_valid(subclassid = obj_class ,
			  superclassid = classid) == OM_S_SUCCESS)
     return 1;
  else return 0;
}

/* A fonction of global use : return the split name of an object or
   "defined" if no split name found
   Return 0 if bad argument or 1 */

int SMGetSplitName(obj,name)
struct GRid *obj; 
IGRchar *name;
{
  char comp_name[DI_PATH_MAX];
  IGRlong status,msg; 
  
  if(!obj || !name) return 0;

  name[0] =   '\0';
  comp_name[0] = '\0';
  
  status = om$send(msg = message GRvg.GRgetname(&msg,comp_name),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum);
  
  if(status != OM_S_SUCCESS || strcmp(comp_name,"") == 0)
    strcpy(name,"defined");
  else
    di$split(pathname = comp_name, name = name);  

  return 1;
}

end implementation Root;

