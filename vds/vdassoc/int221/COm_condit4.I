/* $Id: COm_condit4.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / COm_condit4.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: COm_condit4.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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

class implementation COm_condit;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include <limits.h>
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"


#define AS_DEBUG
from expression import list;
from ACmacro_defn import ACgive_name,ACgive_upscan,ACgive_feet_desc;
from NDmacro import ACgive_structure,ACreturn_foot;

extern char *COm_condit_form_ptr;
method find_feet(char *name; int add_it, *visible_index) 
{
 int i,previous_size,status;
 char *c;
 

/*" Try to find feet %s\n",name */

 c= me->Feet_Name;
 for(i=0 ; i<me->Nb_Max_Feet ; i++,c+=macro_MAX_CHAR)
   {
    if (strncmp(c,name,macro_MAX_CHAR) == 0)
      { *visible_index = i; break; }
   }

/* add it if possible */

 if(i>= me->Nb_Max_Feet)
  {
   if(add_it)
    {
     previous_size = om$dimension_of(varray = me->Feet_Used);
     if(me->Nb_Max_Feet >= previous_size-1)
      {
       previous_size += 5;
       status = om$vla_set_dimension(varray = me->Feet_Name,
                                     size = previous_size*macro_MAX_CHAR);
       status = om$vla_set_dimension(varray = me->Feet_Used,
                                     size = previous_size);
       status = om$vla_set_dimension(varray = me->Feet_Channel,
                                     size = previous_size);
       as$status(action=RET_STATUS);

      }
     /* store information about the new added foot */
     strncpy(me->Feet_Name+me->Nb_Max_Feet*macro_MAX_CHAR,name,macro_MAX_CHAR);
     me->Feet_Name[me->Nb_Max_Feet*macro_MAX_CHAR+macro_MAX_CHAR-1] = '\0';

     /* jla jan 93 : store from which macro the foot comes and also its id
        in the corresponding default occurence
     */

    me->Feet_Channel[me->Nb_Max_Feet] = me->nb_macros;

    {
     int symb;
     long loc_msg;
     enum ACm_poss_hdr hdr_type;
     enum ACm_poss_scroll hdr_scroll;
     enum ACm_poss_def_par hdr_def;
     char search_path[DI_PATH_MAX],post_placement[DI_PATH_MAX];
     struct GRid def_occ,foot_grid;

     def_occ.objid = NULL_OBJID;
     COm_get_options(me->macro+me->nb_macros,&symb,&hdr_scroll,&hdr_type,
		&hdr_def,search_path,post_placement,&def_occ,&me->ModuleInfo);
     if(def_occ.objid != NULL_OBJID)
      {
       status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,name,
				&foot_grid,NULL,NULL),
		  	targetid = def_occ.objid,
		  	targetos = def_occ.osnum);
       if(status&loc_msg&1) 
		 me->Feet_Used[me->Nb_Max_Feet] = (int) foot_grid.objid; 
       else      me->Feet_Used[me->Nb_Max_Feet] = (int) NULL_OBJID;
      }
    }

     *visible_index  = me->Nb_Max_Feet;
     me->Nb_Max_Feet += 1;
    }
   else *visible_index = -1;
  }
/*"visible index %d\n",*visible_index*/
 return OM_S_SUCCESS;
}
end implementation COm_condit;
