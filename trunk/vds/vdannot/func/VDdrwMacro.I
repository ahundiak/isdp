/* $Id: VDdrwMacro.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/func / VDdrwMacro.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwMacro.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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

/*
 * DESCIPTION
 *	The drawing extraction from structical defined objects.
 *	
 * HISTORY:
 *	15/10/93	Copy of functions to be called in for creation for
 *			of the drawing macros.
 */

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"

#include "msmacros.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "ACdb_info.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "AS_status.h"
#include "VDmsg.h"

from	GRvg		import GRchgname;
from	ACcpx_defn	import ACgive_feet_desc,ACgive_name;
from	ci_mac_def	import ACplace;

extern	GRclassid	OPP_ci_mac_def_class_id;

extern			ACconstruct_wd(), ACconstruct_path();

#define AS_DEBUG

#define GEOM_PART  "constructs:VDgeomdef"
#define PREDEFINED_FEET 4
#define PREDEF0 "macro"
#define PREDEF1 "occurence"
#define PREDEF2 "design"
#define PREDEF3 "quantity"

int VDreadDrawingMacro(	md_env )
struct	GRmd_env	*md_env;
{
/* 
   This method initializes the drawing macro and the name of locatable parts.
   A predefined ASCII file is read to define the macro definitions to create.
   The file is called DrawingTable and is found in <product>/config/.

   The macro definitions are created in the default working directory "."
*/
#define MAX_FEET	200
#define	VDTYPE_MAX	512

long	status,loc_msg;
FILE	*input_file;
int	temp_type,len_locate_type;
int	nb_feet,i_feet,nb_feet_def;
char	tpname[macro_MAX_CHAR];
char	*temp_name, *feet_names[MAX_FEET];
char	ftname[MAX_FEET*macro_MAX_CHAR];
char	drawing_macro_name[macro_MAX_CHAR],
	model_macro_name[macro_MAX_CHAR],
	locate_type[VDTYPE_MAX],
	full_macro_name[80];
char	full_path[200];
char	cur_mac_lib[macro_MAX_CHAR+1];
int	cur_mac_len;
int	from_setup;
struct	GRid	geom_macro;

OM_S_OBJID drawing_macro;
struct	myfeet *feet_def;
struct	GRid	mac_lib_id;

 /* Template name and type init */

  status = OM_S_SUCCESS;
  temp_type = 0;
  strcpy(tpname, "model" );
  temp_name = tpname;

  /* initialisation of the feet name table */
  VDinit_feet_name( ftname, feet_names, MAX_FEET);

  /* test if a macro library is active */
  cur_mac_lib[0] = '\0';
  cur_mac_len    = 0;
  status = ac$construct_wd(mode 	= AC_INQ,
			   name		= cur_mac_lib,
			   name_size	= macro_MAX_CHAR,
			   name_len	= &cur_mac_len );
  if( !(status&1)) return( status );

  /* create the default path for the macro library */
  status = di$give_pathname(	osnum	=  md_env->md_id.osnum,
				pathname = full_path );
  strcat( full_path, ":constructs" );

  status = di$translate(objname = full_path,
			p_objid = &mac_lib_id.objid,
			p_osnum = &mac_lib_id.osnum );
  if( !(status&1)){
    status = ac$construct_path(	mode	= AC_ADD_PATH,
				name	= "." );
    if( !(status&1)){
      printf("Can't get construct path directory: %s\n", full_path );
      return OM_W_ABORT;
    }
    status = ac$construct_wd(	mode	= AC_SET,
				name	= ".",
				dir	= &mac_lib_id );
    if( !(status&1)){
      printf("Can't get construct working directory: %s\n", full_path );
      return OM_W_ABORT;
    }
  }

  /*
   * search or initialize macro definition for geometry
   */
  sprintf(full_macro_name, "%s:VDgeomdef", full_path );
  status = di$translate(	objname = full_macro_name,
				osnum   = mac_lib_id.osnum,
				p_objid = &geom_macro.objid,
				p_osnum = &geom_macro.osnum);
  if( !(status&1)){

    status =
    om$construct(classid = OPP_ci_mac_def_class_id,
		osnum = mac_lib_id.osnum,
		p_objid = &geom_macro.objid,
		msg = message ci_mac_def.ACplace
					((int *)&loc_msg,0,"VDgeomdef",
					 "",0,1,&temp_name,&temp_type,
					 0,NULL,NULL,0,NULL,NULL,
					 MAX_FEET,feet_names,NULL,NULL)); 
    geom_macro.osnum = mac_lib_id.osnum; 
    as$status();
  }

  /*
   * search or initialize macro definition for frame extraction
   */

  len_locate_type = 0;
  sprintf(full_macro_name, "%s:drawing_frame", full_path );
  status = di$translate(objname = full_macro_name,
			osnum   = mac_lib_id.osnum,
			p_objid = &geom_macro.objid,
			p_osnum = &geom_macro.osnum);
  if( !(status&1)){
    nb_feet = 0;
    VDadd_predef_feet(&nb_feet,feet_names);
    strcpy(feet_names[nb_feet++],"VD*Pl*|SM*Pl*");

    /*
     * construct the macro definition
     */
    status =
    om$construct(classid = OPP_ci_mac_def_class_id,
		osnum = mac_lib_id.osnum,
		p_objid = &drawing_macro,
		msg = message ci_mac_def.ACplace
					((int *)&loc_msg,0,"drawing_frame",
					 "",0,1,&temp_name,&temp_type,
					 0,NULL,NULL,0,NULL,NULL,
					 nb_feet,feet_names,NULL,NULL));
  }



 /*
    Try to read the macro to extract from struct set up file , and if
    it doesn't work, take them from file DrawingTable
 */

 input_file = NULL;
 if(VDinit_from_drawing_setup()) from_setup = 1;
 else				 from_setup = 0;

 while(1)
  {
   if(from_setup > 0)
    {
     if(VDread_from_drawing_setup(drawing_macro_name,
	model_macro_name,feet_names,&nb_feet,MAX_FEET) == EOF)
       {
	if(from_setup ==2) break;
	else {from_setup = 0; continue;}
       }
     else
       {
	if(drawing_macro_name[0] == '\0') continue;
	from_setup = 2;
       }
    }
   else if(from_setup == 0)
    {
     VDinit_from_DrawingTable(&input_file);
     if(!input_file) break;
     from_setup = -1;
     continue;
    }
   else
    {
     if(VDread_from_DrawingTable(input_file,drawing_macro_name,model_macro_name,
	feet_names,&nb_feet,MAX_FEET) == EOF) break;
    }

   /* That's because ci_mac_def.ACplace only accept ci_macro with 
      name_len = macro_MAX_CHAR-1
   */
   drawing_macro_name[macro_MAX_CHAR-2] = '\0';


/* construct search criteria */

   if(len_locate_type && len_locate_type < VDTYPE_MAX-1)
    {strcpy(locate_type+len_locate_type,"|");
     len_locate_type++;
    }
   if(strlen(model_macro_name) < VDTYPE_MAX - len_locate_type -1)
     {
      strcpy(locate_type+len_locate_type,model_macro_name);
      len_locate_type += strlen(model_macro_name);
     }


    /*
     * Add now feet with predefined names
     */

    VDadd_predef_feet(&nb_feet,feet_names);
    strncpy(feet_names[nb_feet],model_macro_name,macro_MAX_CHAR);
    (feet_names[nb_feet++])[macro_MAX_CHAR-1] = '\0';

    /*
     * contruct the macro definition if it does not already exist
     */

    sprintf(full_macro_name, "constructs:%s", drawing_macro_name );
    status = di$translate(	objname	= full_macro_name,
				osnum	= mac_lib_id.osnum,
				p_objid	= &drawing_macro);
    if(status&1){

      /*
       *  controle if the macro definition matches with the file definition
       */
      status = om$send(msg = message ACcpx_defn.ACgive_feet_desc
					(&nb_feet_def,&feet_def),
		       targetid = drawing_macro,
		       targetos = mac_lib_id.osnum,
		       senderid = NULL_OBJID);
      i_feet = -1;
      if(status&1 && nb_feet_def == nb_feet){
	for(i_feet=0;i_feet<nb_feet;i_feet++)
	 if(strcmp(feet_names[i_feet],feet_def[i_feet].name)) break;
      }
      if(i_feet >= nb_feet) continue;

      /* if the definition is changed
        - tell the user 
        - remove the name of previous def
      */

      status = 
      om$send(msg = message GRvg.GRchgname( &loc_msg, md_env, NULL),
	      targetid = drawing_macro,
	      targetos = mac_lib_id.osnum,
	      senderid = NULL_OBJID);
      as$status();
      ex$message(msgnumb = VD_S_WarMod, type = "%s",var = `drawing_macro_name`);
    }

    /*
     * construct the macro definition
     */
    status =
    om$construct(classid = OPP_ci_mac_def_class_id,
		osnum = mac_lib_id.osnum,
		p_objid = &drawing_macro,
		msg = message ci_mac_def.ACplace
					((int *)&loc_msg,0,drawing_macro_name,
					 "",0,1,&temp_name,&temp_type,
					 0,NULL,NULL,0,NULL,NULL,
					 nb_feet,feet_names,NULL,NULL));
    as$status(); 
  }

  if(input_file) fclose(input_file);
  return OM_S_SUCCESS;

}

end implementation Root;
