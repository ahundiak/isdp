/* $Id: vdattmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/include/vdattmacros.h
 *
 * Description:
 *      This include file provides functionalities
 *      to get the symbology from input file according to attribute conditions
 * 
 * Dependencies:
 *      
 *
 * Revision History:
 *	$Log: vdattmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	08/30/94	Y. Zhu	       Create.
 */

#ifndef	vdattmacros_include
#	define	vdattmacros_include

/* ---------------------------------------
 * include support files.
 */


#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif

#ifndef igetypedef_include
#	include "igetypedef.h"
#endif

#ifndef gr_include
#	include "gr.h"
#endif

#ifndef growner_include
#	include "growner.h"
#endif

#ifndef	msdef_include
#	include	"msdef.h"
#endif

#ifndef	acrg_collect_include
#	include	"ACrg_collect.h"
#endif

#ifndef	vd_pardef_include
#	include	"vdpardef.h"
#endif


/* ----------------------------------------
 * Prototypes
 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern  IGRint VDGetAttSymb __((  
				IGRlong          *msg,             
				IGRchar          *path,           
				IGRchar          *file_name,      
				struct GRid      *obj,             
				struct GRmd_env  *obj_env, 	   
				struct GRsymbology *symbology ));  


#if defined(__cplusplus)
}
#endif

/*+Me
  Extern Macro vd$get_attr_symbology 

  Abstract
      The macro is used to read the symbology from file according to 
      attribute conditions.

  Arguments
	IGRlong          *msg             [O] Completion code 
	IGRchar          *path            [I] Path under config 
	IGRchar          *file_name       [I] Name of the file to read 
	struct GRid      *obj             [I] object to get symbology 
	struct GRmd_env  *obj_env         [I] module env of the object 
	struct GRsymbology *symbology     [O] output symbology 

  Example:
        struct GRid            obj;
  	struct GRmd_env        mod_env;
 	IGRchar                path[DI_PATH_MAX];
 	IGRchar                filename[DI_PATH_MAX];
 	struct GRsymbology     symbology;
 	int                    status;
 	long                   msg;
        
        strcpy( filename, "equip.att");
 	strcpy( path,     "config/attribute");

        ci$locate(prompt       = "Locate object",
                  owner_action = LC_RIGID_COMP
                               | LC_RIGID_OWNER | LC_FLEX_COMP
                               | LC_FLEX_OWNER  | LC_REF_OBJECTS,
                  md_env       = &mod_env,
                  obj          = &obj.objid,
                  osnum        = &obj.osnum);

 	status = vd$get_attr_symbology( msg        = &msg,
                                     	path       = path,
                                     	file_name  = filename,
                                     	obj        = &obj,
                                     	obj_env    = &mod_env,
                                     	symbology  = &symbology );
	

  Status/Return Code
      1    : if it is TRUE.
      0    : otherwise
-Me*/
  
#omdef vd$get_attr_symbology( 
			        msg,
       				path,
       				file_name,
       				obj,
       				obj_env,
       				symbology )

       VDGetAttSymb( (msg), (path), (file_name),
		     (obj), (obj_env), (symbology) )


#endomdef

#endif /* vdattmacros_include */
