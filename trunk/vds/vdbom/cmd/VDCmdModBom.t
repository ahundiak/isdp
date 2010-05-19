/* $Id: VDCmdModBom.t,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDCmdModBom.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdModBom.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
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
# Revision 1.5  1995/01/23  19:10:48  pinnacle
# Replaced:  vdbom/cmd/VD* r#
#
# Revision 1.4  1995/01/06  14:58:46  pinnacle
# Replaced:  vdbom/cmd/VDCmdModBom.t tr# 179524308
#
# Revision 1.3  1994/12/16  15:11:20  pinnacle
# Replaced:  vdbom/cmd/*.t r#
#
# Revision 1.2  1994/12/12  20:48:24  pinnacle
# Replaced:  vdbom/cmd/VDCmdModBom.t r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *			R. Manem	Creation
 *	12/12/94	R. Manem	locate_owner mask correction
 *	12/16/94	R. Manem	Moved update_form to previous state
 *	01/06/95	R. Manem	Sort objects
 *	01/23/95	R. Manem	Sort objects after erasing form
 *
 * -------------------------------------------------------------------*/




command_string  VDC_M_VDMdBOM,1,VDMdBOM
command_table   "vds.cmd"
class           VDCmdBOM
super_class     VDS_LOCATE
product_name    "$VDS"
options         "siTC"

form            "VDBillOfMat",0,0,"-1","-1"


state_table

#include "exdef.h"
#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDSFilter.h"

state start
     message_key             VD_M_VDMdBOM
     prompt_key              VD_P_IdBom
     accept_key              VD_P_AccRej
     locate_class            "+nci_macro"
     locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
     locate_owner            "LC_RIGID_OWNER | LC_FLEX_COMP |
                              LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS"

     /*
      * Accept locate by name.
      */
     mask                    "GRm_DATA | GRm_STRING | GRm_OBJID | 
			      GRm_BACK_UP | GRm_RESET"

     filter                  vds_locate

     on EX_DATA or EX_OBJID

          do store_bom
               
               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR  
                    do wrap_up                         state terminate

          do init_from_bom

               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR  
                    do wrap_up                         state terminate


          state addObjects

     on EX_RJT_MOVEON or EX_BACK_UP
          do wrap_up                                   state terminate


state addObjects
     message_key             VD_M_VDMdBOM
     prompt_key              VD_P_IdElAdMvOn
     accept_key              VD_P_AccRej
     locate_class            "+VDSroot"
/*   locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"	*/
     locate_owner            "LC_RIGID_OWNER | LC_FLEX_COMP |
                              LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS "


     /*
      * Accept locate by name.
      */
     mask                    "GRm_DATA | GRm_STRING | GRm_OBJID | GRm_RESET"

     filter                  vds_locate

     on EX_DATA or EX_OBJID

          do process_locate

               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR  
                    do wrap_up                         state terminate

     do update_form
     state getNewFormat

     on EX_RJT_MOVEON 

     do update_form
     state getNewFormat


state getNewFormat
     message_key             VD_M_VDMdBOM
     prompt_key	             VD_P_KyInAttr
     execute                 set_dynamics_in_form( &me->ret, 
                                                   me->forms[0].form_ptr )
     display_form            0
     mask                    "GRm_BACK_UP | GRm_RESTART"
     filter                  vds_get_event_with_dynamics

     on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
          /*
           * Form has been checked off.
           */
          do store_format                                 
               /*
                * Bad user input in form.
                */
               on RETURN_CODE = VD_RESTART_CMD
                    state .
               on RETURN_CODE = VD_ERROR
                    do wrap_up                            state terminate

          do erase_form 0
          do sort_objs

          do check_item
             on RETURN_CODE =  VD_SUCCESS
             state get_window
  
             on RETURN_CODE = VD_ERROR
                do generate_bom
                do wrap_up
             state terminate
     
     state terminate

     on GR_UNKNOWN_TYPE.VD_FORM_CANCEL or EX_BACK_UP or EX_RESTART or 
                                                        EX_RJT_MOVEON  
          do erase_form 0

          do wrap_up

     state start

state get_window
     message_key             VD_M_VDMdBOM
     prompt_key              VD_P_VsIdWin

     mask                    "GRm_DATA"
     filter                  vds_get_event

     on EX_DATA 

          do store_window
          do generate_bom
          do wrap_up

     state terminate

at init	        do my_init


