/* $Id: VDCmdUsrAtt.t,v 1.1.1.1 2001/01/04 21:07:44 cvs Exp $ */
/* *****************************************************************************
   I/VDS
   "Modify User Attributes"

   File:     vdattrib / VDCmdUsrAtt.t

   Purpose:  This file is input to slic to create the .T file,
             ${VDS}/config/commands/VDMdUsrAtt, which defines the states
	     and actions used to manipulate user attributes.
   Description:

   The Command Object provides a form interface for modifying the user
   attributes of elements. This file's command definition section and 
   state_table section is from file, VDCmdUsrAtt.sl.
   The locate_class of "+ACncpx" implies that only graphic macros can be
   identified for user attribute manipulation.

   Dependencies:

   VDS_LOCATE

   Revision History:
     $Log: VDCmdUsrAtt.t,v $
     Revision 1.1.1.1  2001/01/04 21:07:44  cvs
     Initial import to CVS

# Revision 1.2  1998/12/07  22:24:00  pinnacle
# TR_179802364:  Fixed crash when Copy form and Main form are cancelled succesively
#
     MM/DD/YY   AUTHOR  DESCRIPTION
  
     06/10/97   EJM     CR#179527294  Add "Read from File" capability
			This file was created from VDCmdUsrAtt.sl under this CR.

     07/28/97   EJM     CR#179602470  Add "Copy Attributes" capability
			Added the state, "copyAttr", and the method (action),
			"get_attributes". The state was added because the
			button, "Copy Attributes", on the parent form requires
			locating a second object whose attributes will be copied
			to the first object.

     12/07/98   EJM     TR#179802364:  Cancelling COPY form and then MAIN form
			causes crash. 
			Removed "do wrapup" under GR_UNKNOWN_TYPE.VD_FORM_CANCEL
			under state copyAttr to fix crash.  
			Also, as an extra change, isolated GR_UNKNOWN_TYPE.VD_
			FORM_CANCEL under state getAttr and added,
			"do wrapup       state terminate" to really cancel the
			MAIN form when Cancel icon is chosen.
***************************************************************************** */


command_string	VDC_M_VDMdUsrAtt,0,VDMdUsrAtt
command_table	"vds.cmd"
class		VDCmdUsrAtt
super_class     VDS_LOCATE
product_name	"$VDS"
options         "siTC"  /* suppress .S, i.I, output .T, update command_table */

form		"VDmodUsrAtt",0,0,"-1","-1"



/*---------------------
 * state table area
 */


state_table

#include "exdef.h"
#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDSFilter.h"
#include "VDusrAtt.h"

state start
     prompt_key              VD_P_IdStEls
     accept_key              VD_P_AccRej
     locate_class            "+ACncpx"
     locate_properties       "LC_DP_ONLY | LC_LC_ONLY "
     locate_owner            "LC_RIGID_OWNER | LC_FLEX_COMP | 
                              LC_RIGID_COMP  | LC_FLEX_OWNER "

     /*
      * Accept locate by name.
      */
     mask                    "GRm_DATA | GRm_OBJID"

     filter                  vds_locate

     on EX_DATA or EX_OBJID

          do process_locate

               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR  
                    do wrap_up                         state terminate

          do dspAttrs(0)

          state getAttr

     on GR_UNKNOWN_TYPE.EX_RJT_MOVEON or GR_UNKNOWN_TYPE.EX_RESET
          do wrap_up                                   state terminate


state getAttr
     display_form            0
     prompt_key	             VD_P_KyInAttr
     mask                    "GRm_BACK_UP | GRm_RESTART"
     execute                 set_dynamics_in_form( &me->ret, 
                                                   me->forms[0].form_ptr )
     filter                  vds_get_event_with_dynamics

     on GR_UNKNOWN_TYPE.VD_K_COPY_ATTRS_BTN
	  state copyAttr

     on GR_UNKNOWN_TYPE.VD_FORM_EXECUTE
          do dspAttrs(0)
	  state .

     on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
          /*
           * Form has been checked off.
           */
          do operation
               /*
               * Bad user input in form.
               */
               on RETURN_CODE = VD_RESTART_CMD
                    state .
               on RETURN_CODE = VD_ERROR
                    do wrap_up                            state terminate

          do erase_form 0
          do wrap_up

          state start

     on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
                    do wrap_up                            state terminate

     on GR_UNKNOWN_TYPE.EX_BACK_UP or 
        GR_UNKNOWN_TYPE.EX_RESTART     or GR_UNKNOWN_TYPE.EX_RJT_MOVEON  

          do erase_form 0

          do wrap_up

     state start

state copyAttr
        prompt_key              VD_P_IdObjCopyAttr
        accept_key              VD_P_AccRej
        locate_class            "+ACncpx "
        locate_properties       "LC_DP_ONLY | LC_LC_ONLY"
        locate_owner            "  LC_RIGID_COMP
                                 | LC_RIGID_OWNER
                                 | LC_FLEX_COMP
                                 | LC_FLEX_OWNER
                                 | LC_REF_OBJECTS"

	/*
         * Accept locate by name.
         */
        mask                    "GRm_DATA | GRm_OBJID"
        filter                  vds_locate

     on EX_DATA or EX_OBJID

          do get_attributes

               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR
                    do wrap_up                         state terminate


          state getAttr



     on GR_UNKNOWN_TYPE.VD_FORM_CANCEL or GR_UNKNOWN_TYPE.EX_BACK_UP or 
        GR_UNKNOWN_TYPE.EX_RESTART     or GR_UNKNOWN_TYPE.EX_RJT_MOVEON  


          state getAttr


at init		do message_key	VD_M_MdUsrAtt
/*
at delete	do cleanUp()
*/
