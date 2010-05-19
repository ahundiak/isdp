/* $Id: VDCmdCrBom.t,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDCmdCrBom.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdCrBom.t,v $
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
# Revision 1.4  1995/01/23  19:10:48  pinnacle
# Replaced:  vdbom/cmd/VD* r#
#
# Revision 1.3  1994/12/16  15:11:20  pinnacle
# Replaced:  vdbom/cmd/*.t r#
#
# Revision 1.2  1994/12/07  15:29:24  pinnacle
# Replaced:  vdbom/cmd r#
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
 *	12/07/94	R. Manem	Additional state for getting table name
 *	12/16/94	R. Manem	Moved init_form and dspAttrs to 
 *					previous state
 *      01/23/95        R. Manem        Sort objects after erasing form
 *
 * -------------------------------------------------------------------*/


command_string  VDC_M_VDCrBOM,0,VDCrBOM
command_table   "vds.cmd"
class           VDCmdBOM
super_class     VDS_LOCATE
product_name    "$VDS"
options         "siTC"

form            "VDBillOfMat",0,0,"-1","-1"


/*---------------------
 * state table area
 */


state_table

#include "exdef.h"
#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDSFilter.h"

state start
     message_key             VD_M_VDCrBOM
     prompt_key              VD_P_EntTblNm
     mask                    "GRm_STRING"

     filter                  vds_get_event

     on EX_STRING

          do store_tblName

               on RETURN_CODE = VD_RESTART_CMD           state .

               on RETURN_CODE = VD_ERROR                 state terminate

               on RETURN_CODE = VD_SUCCESS               state locElements

          state locElements

state locElements
     message_key             VD_M_VDCrBOM
     prompt_key              VD_P_IdStEls
     accept_key              VD_P_AccRej
     locate_class            "+VDSroot"
/*    locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"	*/
     locate_owner            "LC_RIGID_OWNER | LC_FLEX_COMP |
                              LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS "

     /*
      * Accept locate by name.
      */
     mask                    "GRm_BACK_UP | GRm_DATA | GRm_STRING | GRm_OBJID"

     filter                  vds_locate

     on EX_DATA or EX_OBJID

          do process_locate

               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR  
                    do wrap_up                         state terminate

          do init_form
          do dspAttrs(0)
          state getFormat

     on EX_BACK_UP                                     state -

     on EX_RJT_MOVEON or EX_RESET
          do wrap_up                                   state terminate


state getFormat
     message_key             VD_M_VDCrBOM
     display_form            0
     prompt_key	             VD_P_KyInAttr
     mask                    "GRm_BACK_UP | GRm_RESTART"
     execute                 set_dynamics_in_form( &me->ret, 
                                                   me->forms[0].form_ptr )
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

          state getCoordSys

     on GR_UNKNOWN_TYPE.VD_FORM_CANCEL or EX_BACK_UP or EX_RESTART or 
                                                        EX_RJT_MOVEON  
          do erase_form 0

          do wrap_up

     state terminate

state getCoordSys
     message_key             VD_M_VDCrBOM
     prompt_key              VD_P_VDIdCS
     accept_key              VD_P_AccRej

     locate_class            "+GRgencs"
     locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
     locate_owner            "LC_RIGID_OWNER | LC_FLEX_COMP |
                              LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS"

     mask                    "GRm_DATA | GRm_STRING | GRm_OBJID"

     filter                  vds_locate

     on EX_DATA or EX_OBJID

          do store_cs
           
          do check_item
             on RETURN_CODE =  VD_SUCCESS
             state get_window
  
             on RETURN_CODE = VD_ERROR
                do generate_bom
                do wrap_up
             state terminate
     
     state terminate

state get_window
     message_key             VD_M_VDCrBOM
     prompt_key              VD_P_VDIdWnMvOn

     mask                    "EX_DATA | EX_RESTART | EX_RJT_MOVEON"
     filter                  vds_get_event

     on EX_DATA 

          do store_window
          do generate_bom
          do wrap_up

     state terminate

     on EX_RESTART or EX_RJT_MOVEON

          do generate_bom
          do wrap_up

     state terminate

at init	        do my_init


