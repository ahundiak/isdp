/* $Id: VDCmdHolei.I,v 1.1.1.1 2001/01/04 21:09:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/cmd / VDCmdHolei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdHolei.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:13  cvs
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
# Revision 1.2  1995/12/14  11:34:42  pinnacle
# Replaced: vdspace/cmd/VDCmdHolei.I for:  by rchennup for vds.240
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

/*  History :
/*	PL : Place macro "hole on a surface "
/*
/* */

class implementation VDCmdHole;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "nddef.h"
#include "acdef.h"
#include "acmacros.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lcmacros.h"

#include "asmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "expmacros.h"
#include "SMmsg.h"
#include "SMcmd.h"

#define AS_DEBUG

/* ----------------------------------------------------------------------- */

method init (int type; char *string_ptr )
{
 int 		status;
 char 		text[80];

 status = om$send(msg = message COm_place.init(type,string_ptr),
                   targetid = my_id,
                   mode = OM_e_wrt_message);

 if(me->mytype == 0) strcpy(text,"Place Bounded Opening");
 else strcpy(text,"Modify Bounded Opening");

 FIg_erase(me->form_ptr,CMD_NAME);
 FIg_delete(me->form_ptr,MAC_NAME);
 FIg_set_text(me->form_ptr,CMD_NAME,text);
 FIg_display(me->form_ptr,CMD_NAME);
 FIg_erase(me->form_ptr,DEF_SELECTION);

  return(status);
}

/* ----------------------------------------------------------------------- */

method prompt_macro()
{
 long status;

 strcpy(me->macro_name,"VDhole2");
 status = om$send(msg = message COm_place.set_action_and_state
							(STO_MAC,WAIT_TEM),
		  targetid = my_id);
 return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------------- */

method pro_occ()
{
 me->attr.properties = LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY;
 me->attr.owner_action =  LC_RIGID_OWNER
                        | LC_FLEX_COMP | LC_FLEX_OWNER;

 me->Obj_Generic = macro_generic;
 strcpy(me->Obj_Name,"VDhole2");
 ex$message(buff = me->loc_prompt, msgnumb = AS_P_LcMcOc);
 me->Entry_Request=PARENT;
 if(me->mytype&1) me->Obj_Generic |= set_generic;
 return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------------- */

method get_default_template()
{
 long i;

/*| Initialize default template */


 for(i=0;i<me->Nb_Max_Temp;i++)
  {
	  me->Temp_Value[i].type = me->dup[i].type;
	  me->Temp_Value[i].var.root_pm_st.value = 0;
	  me->Temp_List[i].objid = NULL_OBJID;
	  me->Temp_Elig[i].objid = NULL_OBJID;
  }

 me->Temp_Value[0].var.root_pm_st.value = 1;
 me->Temp_Value[0].type = double_type;

 return(OM_S_SUCCESS);
}

/* ----------------------------------------------------------------------- */

method wakeup ( IGRint n )
{
 int status,i;

 status = om$send(msg 		= message COm_place.wakeup(n),
                  targetid 	= my_id,
                  mode 		= OM_e_wrt_message);
 if(me->mytype == 0) UI_message(" Place Bounded Opening");
 else UI_message("Modify Bounded Opening");
 return (status);
}

end implementation VDCmdHole;
