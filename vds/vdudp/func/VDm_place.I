/* $Id: VDm_place.I,v 1.2 2001/01/26 00:35:50 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/func / VDm_place.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_place.I,v $
 *	Revision 1.2  2001/01/26 00:35:50  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  20:41:30  pinnacle
# Invalid return warning
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
 *	10/31/97	ah		Warning messages
 * -------------------------------------------------------------------*/

class implementation COm_place;

#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "expression.h"

from NDmacro import ACgive_structure;

COm_place_get_active_symb (dup,Temp_List,Nb_Max_Temp,def_id,
			   active_level,active_display,dir_name,md_env)
struct sup *dup;
struct GRid *Temp_List,*def_id;
int Nb_Max_Temp;
short *active_level;
struct IGRdisplay *active_display;
struct GRmd_env *md_env;
char *dir_name;
{
 GRspacenum dir_os;
#define PAR "~~parent"
#define CMD "~~cmd"
long status,loc_msg;
int m_1,i;
struct ret_struct par_val,cmd_val;


 /* Is the operation type and the operand defined */

  status=om$send(msg = message NDmacro.ACgive_structure
                        ( (int *) &loc_msg,&m_1,PAR,&par_val,md_env),
		     senderid = NULL_OBJID,
                     targetid=def_id->objid,
                     targetos=def_id->osnum);
  if(par_val.type != text_type) loc_msg = MSFAIL;

  if(status&loc_msg&1)
  status=om$send(msg = message NDmacro.ACgive_structure
                        ((int *)&loc_msg,&m_1,CMD,&cmd_val,md_env),
		     senderid = NULL_OBJID,
                     targetid=def_id->objid,
                     targetos=def_id->osnum);
  if(cmd_val.type != text_type) loc_msg = MSFAIL;
  if(!(status&loc_msg&1)) goto FAILURE;

  /* search parent in template list */

  for(i=0;i<Nb_Max_Temp;i++)
     {if(strcmp(par_val.var.text_st.text_string,dup[i].prompt) == 0) break;}
  if(i>= Nb_Max_Temp || Temp_List[i].objid == NULL_OBJID) goto FAILURE;

  status = VDSget_dir_and_symb(&loc_msg,
  		     Temp_List+i,
		     cmd_val.var.text_st.text_string,
		     NULL,
		     dir_name,
		     active_level,
		     active_display);

  if(status&loc_msg&1) return OM_S_SUCCESS;
		  
 /* When all this shit does not work .... */

 FAILURE :
 ASget_active_symb(active_level,active_display);

 di$pwd(p_osnum = &dir_os,
	dirname = dir_name);
 if(dir_os != md_env->md_id.osnum) dir_name[0] = '\0';

 /* ----------------------------------------
  * 10/31/97 Art Hundiak
  * Did not use to have an explicit return and thus
  * generated some warnings.
  *
  * Gonna always return success, assuming ASget_active_symb
  * always works
  */
 return OM_S_SUCCESS;

}
end implementation COm_place;
