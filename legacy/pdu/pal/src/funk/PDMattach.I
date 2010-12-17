/***************************************************************************/
/*                                                                         */
/*   This file contains routines to load macro libraries if p_attach = 'Y' */
/*   for parametric parts                                                  */
/*                                                                         */
/*           File Creation Date:     28-July-92   MMS (IGI)                */
/*                                                                         */
/***************************************************************************/

class implementation Root;
 
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <sys/param.h>
#include <PDUmacros.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dp.h"
#include "gr.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ci_mac_def.h"
#include "ci_macro.h"
#include "cisymb.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "nddef.h"
#include "MOmacros.h"

#include "FI.h"
#include "MEMstruct.h"
#include "PALglbs.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"

from ACrg_collect import ACget_named_attribute;
from NDnode import NDget_objects ;
from  ACmacro_defn import ACgive_upscan ;

struct GRmd_env lmod_env ;
extern OMuword OPP_ACcpx_class_id ;

#define	AC_ATTRIB_MASK_TYPE	0x00ff

PDMattach()

{
	char   dir_name[MAXPATHLEN] ;
	struct GRid dir_grid, part_grid ;
	int    i,nb_lines, sts = 0 ;
	char   **lines;
	GRobjid macro ;
	OMuword classid ;

	 
	get_mod_info(&lmod_env);

	/* Read the directory struture :PDU:macro_part: level to get list
	   of objects 
	*/

	sts = DIstmocpy(dir_name,"PDU","macro_parts",0,lmod_env.md_id.osnum);  

	if(!(sts&1)){
		di$report_error(sts = sts);
		return(0);
	}

	sts = di$translate(p_objid   = &dir_grid.objid,
			     osnum   = dir_grid.osnum,
			   objname   = dir_name);

	if(!(sts&1)){
		di$report_error(sts = sts);
		return(0);
	}

	_pdm_debug("directory containing macro is: ", dir_name );

  
	/*   Get and print the contents of this directory */

	strcat(dir_name,":*");

	sts = di$ls(	  regexp = dir_name ,
        	          lines  = &lines ,
                	  ptr    = &nb_lines);

	if(!(sts&1)){
		di$report_error(sts = sts);
		return(0);
	}

	if(nb_lines == 0)
        	return(0) ;


	for(i = 0 ; i < nb_lines ; i = i + 1 ){

		remove_brackets(lines[i]);

		macro = NULL_OBJID ;

		sts = di$translate ( objname = lines[i],
                                     osnum   = dir_grid.osnum,
		             	     p_objid = &macro);

		_pdm_debug("macro: %s",lines[i]);
		_pdm_debug("osnum: %d",dir_grid.osnum);

		if( macro != NULL_OBJID && macro != 0 ){

			sts = om$get_classid(   objid     = macro, 
			       			osnum     = lmod_env.md_id.osnum,
			       			p_classid = &classid);

			if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
				  subclassid  = classid ) == OM_S_SUCCESS ){

				part_grid.objid = macro ;
				part_grid.osnum = lmod_env.md_id.osnum ;

				attach_macro_libraries(&part_grid);
			}
		}
	}

	if(lines != NULL && nb_lines != 0)
        	di$free(lines = lines,count = nb_lines);

	return(1);
}

attach_macro_libraries(part_grid)
struct GRid *part_grid;
{


	int sts, alcsize, cnt , no_temps , props;
	char *str,catname[20]  ;
	struct sup *sup ;
	struct GRid ACdyn_col_obj, mac_hdr  ;

	if (!GetMacroHeaderGivenGrid (*part_grid, &mac_hdr))
		return (0);

	/* Get macro template info of the edited macro	*/
	sts = om$send( msg = message ACmacro_defn.ACgive_upscan(
						&no_temps,
						&props,
						&sup),
       			senderid = mac_hdr.objid,
			targetid = mac_hdr.objid,
			targetos = mac_hdr.osnum);


	_MO_omerr_chk("GetTemplateInfo () : ACmacro_defn.ACgive_upscan : ", sts, wrapup);

	_pdm_debug("After give_temp_desc:no.temps=%d", no_temps);

     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, &ACdyn_col_obj, 1,
						    NULL, no_temps-1, no_temps-1, &cnt),
                       	targetid = part_grid->objid, 
                       	targetos = part_grid->osnum,
			senderid = part_grid->objid);

     	_MO_omerr_chk("GetCatalogTemplateValue () : NDnode.NDgetobjects ",  sts,  wrapup);

	_pdm_debug("ACdyncolobj:%d",ACdyn_col_obj.objid);

	str = (char *) malloc (10 * sizeof (char));
	alcsize = 10;
	str[0] = '\0' ;
	catname[0] = '\0' ;

	if(! GetACrgAttribVal(&ACdyn_col_obj,"n_catalogname",&str,&alcsize))
		return(0);
	str[strlen(str)-1] = '\0' ;
	strcpy(catname,str);

	if(! GetACrgAttribVal(&ACdyn_col_obj,"p_attach",&str,&alcsize) )
		return(0);

	/* If p_attach is set to 'y' load macro library */

	if( str[0] == 'Y' || str[0] == 'y' ) {
		copy_and_load_macro_lib(catname);
	}

	return(1);
wrapup:
	return(0);
}


end implementation Root;

