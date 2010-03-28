 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 


command_string  GRMPlcOrthPoly,CO_ni_place_linear,GRPOrPl
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table    "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"


/*  Fixed several problems where an ortho line string would be left
 *  upon leaving the command.  I added checks for a clear stack or 
 *  a terminate received while the command is active in order to close
 *  or delete the current ortho line string.  I did not add code to detect
 *  the deletion of the command object while the command is suspended
 *  since modifying or deleting the current ortho line string while the
 *  command is not active might be confusing to the user.  1/9/90,jjc
 */


state *
on  EX_RESTART                                       state start
on  EX_BACK_UP                                       state -
    


state start
   construct_class   "GR3dorthlnst"
   message_key       GRC_M_PlcOrthPoly
   prompt_key        GR_P_EntFirstPt
   filter            get_event
   on EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_TO    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_PERPEND_FROM
        do status_key  GR_E_InvDtTyp                 state .

   on EX_DATA
	do store_event_by_index( sts, 0 )             
        do copy_event_by_index( sts, 2, 0 )
        do get_construct_env_from_dpb                state have_first_event

   on EX_BACK_UP                                     state .



state have_first_event
   prompt_key    GR_P_EntNextPt 
   dynamics      DYrblinear
   filter        get_event
   on EX_DATA.GRst_ANGLE_TO      or 
      EX_DATA.GRst_ANGLE_FROM    or 
      EX_DATA.GRst_TANGENT_TO    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_PERPEND_FROM 
        do status_key  GR_E_InvDtTyp                 state .

   on EX_DATA
	do store_event_by_index( sts, 1 )             
        do construct_object               
         on ERROR                                    state start 
        do display_mode GRbd
        do display_constructed                 
        do reload_last_point
        do store_event_by_index( sts, 0 )            state have_segment



state have_segment
   prompt_key    GR_P_EntNextPt
   execute get_channel_count( sts, 0 ) /* NULL ptr indicates const_chansel */
   on RETURN_CODE != 1
        do status_key GR_E_MnpObjLost                   state start
/* dynamics      DYrborthline */
   execute const_dynamics ( sts, DYrborthline )
   filter        get_event
   on EX_DATA.GRst_ANGLE_TO     or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_TO   or
      EX_DATA.GRst_TANGENT_FROM or
      EX_DATA.GRst_PERPEND_TO   or
      EX_DATA.GRst_PERPEND_FROM 
        do status_key  GR_E_InvDtTyp                 state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do add_point
         on ERROR                                    state start
        do display_mode GRbd
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )            state have_created_element


   on EX_BACK_UP
        do display_mode GRbe
        do display_constructed
        do delete_element
        do display_mode GRbd
        do display_constructed
        do copy_event_by_index( sts, 0, 2 )          state have_first_event  

   on EX_RJT_MOVEON or
      GR_UNKNOWN_TYPE.TERMINATE or
      GR_UNKNOWN_TYPE.CLEAR_STACK
        do display_mode GRbehe
        do display_constructed
        do delete_element                            state start
        

state have_created_element
   prompt_key    GR_P_EntNextPt
   execute get_channel_count( sts, 0 ) /* NULL ptr indicates const_chansel */
   on RETURN_CODE != 1
        do status_key GR_E_MnpObjLost                   state start
   execute const_dynamics ( sts, DYrborthpoly )
/*   dynamics      DYrborthpoly */
   filter        get_event
   on EX_DATA.GRst_ANGLE_TO      or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_TO    or
      EX_DATA.GRst_TANGENT_FROM  or
      EX_DATA.GRst_PERPEND_TO    or
      EX_DATA.GRst_PERPEND_FROM
        do status_key  GR_E_InvDtTyp                 state .
   on EX_DATA
        do store_event_by_index( sts, 1 )
        do add_point
         on ERROR                                      state start
        do display_mode GRbd
        do display_constructed
        do reload_last_point
        do store_event_by_index( sts, 0 )            state have_created_element

   on EX_RJT_MOVEON  or
      EX_RESTART or
      GR_UNKNOWN_TYPE.TERMINATE or
      GR_UNKNOWN_TYPE.CLEAR_STACK
	do display_mode GRbe
        do display_constructed
        do close_ortho_polygon
           on ERROR           
              do display_mode GRbe
              do display_constructed
              do delete_element                      state start
        do display_mode GRbd
        do display_constructed                       state start

   on EX_BACK_UP
        do display_mode GRbe
        do display_constructed
        do delete_point
           on INFORMATION 
              do display_mode GRbe
              do display_constructed
              do delete_element
              do copy_event_by_index( sts, 0, 2 )    state have_first_event
        do display_mode GRbd
        do display_constructed
        do reload_last_point
	do store_event_by_index( sts, 0 )            state .
