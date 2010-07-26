/*
 *   griomacros.h
 *
 *   Dependencies:
 *      ex.h
 *      griodef.h
 *      grio.h
 */

#ifndef griomacros_include
#define griomacros_include



/*
 * --------------------------------------------------------------------------
 *   -----------------------------  C macros  -----------------------------
 * --------------------------------------------------------------------------
 */


/* 
 *  macros to check status of the vsd and/or the software event queue 
 */
#   define  queue_not_empty      ( EX_peek_event_queue( NULL ) )
#   define  queue_empty          ( ! queue_not_empty )
#   define  vsd_empty            ( COvsd_empty() )
#   define  vsd_not_empty        ( ! vsd_empty )
#   define  vsd_and_queue_empty  ( vsd_empty && queue_empty )
#   define  clear_vsd            ( COclear_vsd() )


/*
 * --------------------------------------------------------------------------
 *   ----------------------------  OM macros  -----------------------------
 * --------------------------------------------------------------------------
 */

/*----------------------- co$getevent ------------------------------

#omdef  co$getevent( msg,
                     scale_flag = GRIO_X_SCALE,
                     event_mask,
                     event_size=sizeof(struct GRevent),
                     prompt = NULL,
                     msgnum = GRIO_NO_MSG,
                     msgname = NULL,
                     value_type = GRIO_SCALAR,
                     mode,
                     nbytes=NULL,
                     response,
                     response_data,
                     event )

 Abstract:

   Event oriented input filter with expression evaluation capabilities and 
   UNITS subsystem interface; this filter was written to be THE input filter
   for GRNUC application commands to assure a uniform syntax for value
   expressions.


 Arguments:

  *msg             IGRlong   Return message:
                               MSSUCC - success
                               MSFAIL - severe error
                               GRw_ev_trunc - data truncated
                               GRw_no_value - user entered NULL value
                               CO_e_syntax - syntax error in expression 
                               CO_e_divide_by_zero - division by 0 attempted

   scale_flag      IGRlong   A Flag specifying what kind of scaling ( if any ) 
                             should be applied to values returned in 
                             Event->event.value.
                               GRIO_NO_SCALE : no scaling is desired
                               GRIO_X_SCALE  : use X scale of ACS (default)
                               GRIO_Y_SCALE  : use Y scale of ACS 
                               GRIO_Z_SCALE  : use Z scale of ACS
                               N {0,1,2,...} : use Nth scale of ACS

   event_mask      IGRlong   A mask specifying events that are wanted.

   event_size      IGRlong   Size of event buffer passed.

  *prompt          IGRchar   Prompt displayed before input solicited.
                             If NULL, then the prompt field is not
                             effected ).

   msgnum          IGRint    Index in Message subsystem for prompt; if set to
                             GRIO_NO_MSG, then msgnum is not used to generate 
                             a prompt.

  *msgname         IGRchar   If not equal to NULL, this is used to specify 
                             the ascii key used to find the the prompt string
                             in the message subsystem.

  ****************************************************************************
  NOTE:  no more than one of the above three arguments should be used to
         specify a prompt.  If no prompt is wanted, then Prompt and MsgName
         should be set to NULL and MsgNumber should be set to GRIO_NO_MSG.
         These are the defaults assigned by the macro.
  ****************************************************************************

  *value_type      IGRchar   If mask includes GRm_VALUE, then the 
                             value type is generated from this string.
                             Otherwise this parameter is ignored.
                             This allows a useful interface with the
                             unit of measure ( UOM ) subsystem since
			     applications will have their own value types.
			     Standard value types ( in griodef.h ) are:

                                GRIO_SCALAR   -- scalar value type  (default)
                                GRIO_ANGLE    -- angle value type 
                                GRIO_DISTANCE -- distance value type 
                                GRIO_AREA     -- area value type

                             Others may be defined by applications and defined
                             locally.

   mode           IGRlong    mode used to get keyboard input; 
                                EX_LINE_MODE ( default )
                                EX_ALL_CHAR_MODE

   *nbytes        IGRint     The number of bytes returned in the response_data 
                             buffer; this is very useful if data stored in the
                             GRevent structure is truncated and must be 
                             retrieved manually from this buffer.  If NULL, 
                             this argument is ignored.  Thus it is optional.

  *response       IGRlong    Executive response.

  *response_data  IGRchar    Executive response_data.

  *event   struct GRevent    The event returned.


 Sample Call:
 
   status = co$getevent( msg = &msg,
                         event_mask = ( GRm_RJT_MOVEON | GRm_DATA ),
                         prompt = "Enter Point 1",
                         response = response, 
                         response_data = response_data,
                         event = &event );

   status = co$getevent( msg = &msg,
                         event_mask = ( GRm_RJT_MOVEON | GRm_VALUE ),
                         value_type = GRIO_DISTANCE,
                         msgnum = GR_P_EntRadius,
                         response = response, 
                         response_data = response_data,
                         evnet = &event );

 Return Status :  
    
  MSSUCC -  Success
  MSFAIL -  Failure

 Notes:

   The Event Mask:

     The event mask indicates the type of event(s) needed by the command.

     Example:  if a command wants to recognize a data point, or a reject/
               moveon event, then the mask should be set to 
               ( GRm_RJT_MOVEON | GRm_DATA ).

     Mask bits that the getevent filters recognize are:

        GRm_DATA - for data points

        GRm_RESTART -  EX_RESTART events

        GRm_BACK_UP - for EX_BACK_UP events

        GRm_RJT_MOVEON - for reset events

        GRm_CHAR - when used in conjunction with mode = EX_ALL_CHAR_MODE 
           it allows EX_CHAR events to be generated. Note: GRm_CHAR should
           never be in the same mask as GRm_VALUE, GRm_TEXT_VALUE, or 
           GRm_STRING.  They are incompatable and results are unpredictable.

        GRm_STRING - for raw ( uninterpreted ) text input 

        GRm_TEXT_VALUE  ( lots to discuss here )
           
           For text strings ( delimiters recognized for separating 
           arguments )  Set this mask bit if you want to be able to
           enter more than one argument in a single keyin.  
           
           For example, if we are writing a command called Delete Windows
           we may want an interface where a user can specify several
           windows by name in a single keyin.  

                delete window = window1,window2,window3

           Here, a comma separates three text strings: "window1", 
           "window2", and "window3".  

           By setting the GRm_TEXT_VALUE bit in the event mask and 
           iteratively calling the getevent filter each of the three 
           strings can extracted separately.

           Unless raw text is wanted, use GRm_TEXT_VALUE as the mask
           for getting text string.

           Note:  Do NOT set both the GRm_STRING and GRm_TEXT_VALUE
           bits in the event mask!  The results are not predictable.

        GRm_MOVE_ON - for MOVE_ON events

        GRm_OBJID - special purpose event for locate interface

        GRm_VALUE - used in conjunction with the unit_type argument in 
                    co$getevent, this can specify any unit value
                    supported by the application ( scalar, distance, 
                    angle, etc. )

        A note about precedence:  It is possible for there to be more than
        one way to interpret an input.  The most common example of this is
        when the event mask requests a value OR a text string ( e.g. 
        mask = GRm_VALUE | GRm_TEXT_VALUE ).  Because a value can be keyed in
        as text, a precedence has to exist.  If the user keys in a string such 
        as "150" then is this a string ( EX_STRING ) or a numeric ( EX_VALUE )? 

        GRm_FORM_FINISHED - used to signal that a form is finished
      

     The getevent filter always places a higher precedence on EX_VALUE than on
     text!  Thus, if the event mask is set to recognize a scalar value or a
     text string, and the user keys in "150", then the value 150 is returned
     in the event and event->response is set to EX_VALUE.  If the user had 
     keyed in "150A", which is not a proper scalar expression, then the 
     EX_STRING "150A" is returned in the event and event->response is set to 
     EX_STRING.
                    
     When a software event is found that is of a type requested in the
     event mask, then the event structure is loaded with appropriate
     information.  On return, event->response indicates the format of 
     data which is stored in the event->event ( union ) buffer.  It will
     have one of the following values:

        EX_RJT_MOVEON
           The event mask included GRm_RJT_MOVEON and an EX_RJT_MOVEON event
           was found ( the event->event buffer is NOT loaded ) 

        MOVE_ON 
           The event_mask included GRm_MOVE_ON and an MOVE_ON event
           was found ( the event->event buffer is NOT loaded )

        EX_OBJID 
           The event_mask included GRm_OBJID and an EX_OBJID event was
           found ( the event->event.button buffer is loaded with window
           information from the "specified object" )

        EX_DATA 
           The event_mask included GRm_DATA and an EX_DATA event was 
           found ( the event->event.button buffer is loaded )

        EX_VALUE 
           The event_mask included GRm_VALUE and an EX_VALUE event was returned
           ( the event->event.value buffer is loaded )

        EX_CHAR
           The event_mask included GRm_CHAR, mode was set to EX_ALL_CHAR_MODE,
           and an EX_CHAR event was found ( the event->event.keyin buffer is
           loaded with one or more characters which are NOT NULL TERMINATED;
           event->nbytes contains the number of these characters ).

        EX_STRING 
           The event_mask included GRm_STRING or GRm_TEXT_VALUE and 
           an EX_STRING event was found ( the event->event.keyin buffer
           is loaded )

        EX_RESTART
           The event_mask included GRm_RESTART and an EX_RESTART event
           was found

        EX_BACK_UP
           The event_mask included GRm_BACK_UP and an EX_BACK_UP event
           was found 

        EX_FORM_FINISHED
           The event_mask included GRm_FORM_FINISHED and an EX_FORM_FINISHED
           event was found ( the event->event buffer is NOT loaded ).

        GR_UNKNOWN_TYPE 
           The event found did not match any of the types indicated in
           the event mask.  This usually flags the command to exit, 
           returning response and response_data to the Command Server
           for evaluation.


      On return, *response indicates the format of data which is returned in
      response_data ( NOT the event!!!).  For example, if the getevent filter
      is called with a request for a value ( e.g. an angle ) and the value is
      keyed in by the user ( e.g. "45 degrees" ) then *response will be 
      EX_STRING (not EX_VALUE), because response_data will contain the keyed 
      in string.

      WARNING:  do not check *response to find out what kind of event was
      returned!  Instead, check event->response.

      Documentation on the use of the co$getevent can be found in the include
      file "griomacros.h", which is delivered in the GRIO package.


 Caveats:
    
   If a prompt is specified, it will only be displayed if both the Software
   Event Queue and the Variable String Descriptor ( VSD ) buffer are empty.
   This is called "smart" prompting.  ( If for some reason you need to prompt
   when it is not necessary, the command must manually issue the prompt and 
   then call co$getevent with no prompt specified ).

   For those converting from the GRgetevent filter make sure that your 
   masks for values ( GRm_ANGLE, GRm_DIST and GRm_SCALAR ) are changed to
   GRm_VALUE and the appropriate value_type is provided ( GRIO_ANGLE, 
   GRIO_DISTANCE, and GRIO_SCALAR ).


 History:

   08/21/87  srh  Also added recognition of two new response types: 
                  EX_RESTART and EX_BACK_UP; The EventMask bits for
                  these two event types are GRm_RESTART and GRm_BACK_UP,
                  respectively.

   08/27/87  srh  Added Variable Support.  Also added recognition of two
                  new response types:  EX_RESTART and EX_BACK_UP.

   09/04/87  srh  Added mode argument to support GRm_CHAR mask setting.

   10/27/87  srh  Added msgname argument to support promps specified by 
                  message names; also made prompt, msgnum, and msgname
                  NOT mutually exclusive.

   03/22/88  jsd  Added recognition of the new response type
                  EX_FORM_FINISHED to co$getevent(). The EventMask bit
                  for this event type is GRm_FORM_FINISHED.

   04/20/88  srh  Added nbytes argument to co$getevent().  This returns the
                  number of bytes in response_data.

   04/18/89  srh  Added scale_flag argument for scaling values with respect
                  to the Active Coordinate System.

 */

#omdef  co$getevent( msg,
                     scale_flag = GRIO_X_SCALE,
                     event_mask,
                     event_size=sizeof(struct GRevent),
                     prompt = NULL,
                     msgnum = GRIO_NO_MSG,
                     msgname = NULL,
                     value_type = GRIO_SCALAR,
                     mode = EX_LINE_MODE,
                     nbytes=NULL,
                     response,
                     response_data,
                     event )

   COgetevent( (msg),
               (scale_flag),
               (event_mask),
               (event_size),
               (prompt ),
               (msgnum),
               (msgname),
               (value_type),
               (mode),
               (nbytes),
               (response),
               (response_data),
               (event) )

#endomdef


/*----------------------- co$expreval ------------------------------

#omdef co$expreval( msg,
                    scale_flag = GRIO_X_SCALE,
                    expression,
                    unit_type=GRIO_SCALAR,
                    result ) 



 Abstract:  
 
    Numeric expression evaluator macro that interfaces with UNITS subsystem
    This is the same expression evaluator used by co$getevent.

    This macro takes an expression ( text string ) and the "context" in which
    it is to be evaluated and, if the expression meets the parsing criteria
    for the specified value, then a floating point value in the specified 
    units is returned.  The "context" mentioned above pertains to:
  
       1) a unit type, such as "distance" or "angle"
  
       2) implied units of the type specified in 1 ( e.g.  foot/inch/mil ).  
          These are used when for interpretation of implicit expressions . 
          If the implied units are feet/inches/mils then the expressions
          "6 6 2" and "6 feet + 6 inches + 2 mils" are equivalent.  The 
          implied units are not used if the unit_type is GRIO_SCALAR.
  

 Arguments:

   *msg         IGRlong    Returned status message:
                             MSSUCC       - success
                             MSFAIL       - severe error
                             GRw_no_value - expression was NULL or all
                                            white space
                             CO_e_syntax  - syntax error in expression
                             CO_e_divide_by_zero - division by 0 attempted

   scale_flag   IGRlong    A Flag specifying what kind of scaling ( if any ) 
                           should be applied to values returned in 
                           Event->event.value.
                               GRIO_NO_SCALE : no scaling is desired
                               GRIO_X_SCALE  : use X scale of ACS (default)
                               GRIO_Y_SCALE  : use Y scale of ACS 
                               GRIO_Z_SCALE  : use Z scale of ACS
                               N {0,1,2,...} : use Nth scale of ACS

   *expression  IGRchar    Expression to be evaluated

   *unit_type   IGRchar    Unit type portion of the context

   *result      IGRdouble  Result of the expression


 Sample calls:

        status = co$expreval( msg = &msg,
                              expression = "1.0 meters + 3.5 feet",
                              unit_type  = GRIO_DISTANCE,
                              result     = &MyResult );

        status = co$expreval( msg = &msg,
                              scale_flag = GRIO_Z_SCALE,
                              expression = my_expression,
                              unit_type  = ELEVATION,
                              result     = &MyResult );

 Return status:

  MSSUCC - Success
  MSFAIL - Failure


 Caveats:
   
   o  The expression is assumed to be NULL terminated!  If it is not, a 
      syntax error is most likely.

 */

#omdef co$expreval( msg,
                    scale_flag = GRIO_X_SCALE,
                    expression,
                    unit_type = GRIO_SCALAR,
                    result ) 

  COexpreval( (msg),
              (scale_flag),
              (expression),
              (unit_type),
              (result) ) 
#endomdef



/*----------------------- co$cvt_imp_to_alias  ------------------------------

       co$cvt_imp_to_alias(msg,
                           unit_type,
                           osnum,
                           working_units,
                           num_alias,
                           num_conversions,
                           readout_spec,
                           field_size,
                           inverse_scale_flag,
                           fraction_mode,
                           cvt_list)
                 
       ABSTRACT:
       ---------   
          This macro will convert from a number of working units to the
       number of default output units.  This number will be place in cvt_list
       postfixed by the alias of that unit.  All conversions will be based
       upon what is stored in the unit of measurement object as the default
       output alias. Therefore, if only a primary unit is stored for output
       conversion only one string will be returned in cvt_list.

 Arguments:

   *msg            IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *unit_type      IGRchar       Indicates what type of unit conversion is
                                 performed.  For example,
                                   GRIO_DISTANCE converts to distance
                                   GRIO_ANGLE    converts to angle
                                   GRIO_AREA     converts to area
                                  
    osnum          OMuword        object space conversion is to occur in.

   *working_units  IGRdouble      number of working units to convert.
   
   *num_alias      IGRshort       number of default aliases to process to
                                  (i.e if default output aliases were
                                  set to yards, feet, and inches via the
                                  MD=, and num_alias was passed equal to
                                  2. The results would be calc. in yards
                                  and feet.)
                                  
    num_conversions IGRshort      several conversions can occur with 
                                  only one call.  This variable indicates
                                  how many conversions are to occur.
                                  If num_conversions is greater than 1, 
                                  working_units should be an array of doubles,
                                  and cvt_list should be an array of pointers
                                  to character.
    
    *readout_spec  struct GRIOreadout_spec
                                  If the calling program does not wish to 
                                  use the currently defined readout spec
                                  a overriding readout spec can be passed in.
                                                              
    *field_size    IGRshort       size of field returned string will fix in,
                                  required for proper justification of text.

    inverse_scale_flag IGRshort   indicates whether or not to apply the
                                  inverse scaling factor.  If the unit type
                                  is not scalable this argument is ignored.
                                  The flag is an index that detremines which
                                  of the ACS scales (x,y,z,etc) is inverted an
                                  applied to the results.

    *fraction_mode IGRshort       the fractional part of the returned value may
                                  be returned as a decimal, as ascii characters
                                  representing a fraction or as a single 
                                  fractional character.  If this variable is not
                                  null, it specifies the mode, otherwise the
                                  dpb value is used.
                                   
    *cvt_list      IGRchar        an array of characters to place ascii text in.
   

 Sample Call:
 
   status = co$cvt_imp_to_alias(msg =  &msg,
                                unit_type = GRIO_DISTANCE,
                                working_units = &working_units,
                                num_alias = &num_alias,
				cvt_list = output_string);

 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:
*/
#omdef co$cvt_imp_to_alias(msg,
                           unit_type,
                           osnum = OM_Gw_current_OS,                           
                           working_units,
                           num_alias,
                           num_conversions = (short) 1,
                           readout_spec = NULL,
                           field_size = NULL,
                           inverse_scale_flag = (short) GRIO_X_SCALE,
                           fraction_mode = NULL,
                           cvt_list)

      GRcvt_imp_to_alias((msg),
                         (unit_type),
                         (osnum),
                         (working_units),
                         (num_alias),
                         (num_conversions),                        
                         (readout_spec),
                         (field_size),
                         (inverse_scale_flag),
                         (fraction_mode),
                         (cvt_list) )

#endomdef


/*-------------------------- co$cvt_exp_to_alias ----------------------------

        co$cvt_exp_to_alias(msg,
                       unit_type,
                       osnum,
                       num_def,
                       output_alias,
                       working_units,
                       readout_spec,
                       field_size,
                       inverse_scale_flag,
                       fraction_mode,
                       cvt_list)


       ABSTRACT:
       ---------   
          This macro will convert from a number of working units to the
       number of output units.  This number will be place in cvt_list
       postfixed by the alias of that unit.  All conversions will be based
       upon whatis passed in the output_alias array.  Therefore, if only a 
       primary unit is passed in output_alias only one string will be 
       returned in cvt_list.

 Arguments:

   *msg            IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *unit_type           IGRchar   Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

    osnum          OMuword        object space conversion is to occur in.
                                      
   *num_def        IGRshort       number of output aliases
   
   *output_alias   IGRchar[]      an array of aliases to be used in conversions
    
   *working_units  IGRdouble      number of working units to convert.
   
   *readout_spec  struct GRIOreadout_spec                       
                                  If the calling program does not wish to 
                                  use the currently defined readout spec
                                  a overriding readout spec can be passed in.
                                  
   *field_size    IGRshort        size of field returned string will fix in,
                                  required for proper justification of text.

   inverse_scale_flag IGRshort    indicates whether or not to apply the
                                  inverse scaling factor.  If the unit type
                                  is not scalable this argument is ignored.
                                  The flag is an index that detremines which
                                  of the ACS scales (x,y,z,etc) is inverted an
                                  applied to the results.

   *fraction_mode IGRshort        the fractional part of the returned value may
                                  be returned as a decimal, as ascii chars
                                  representing a fraction or as a single 
                                  fractional character.  If this variable is not
                                  null, it specifies the mode, otherwise the
                                  dpb value is used.
                                   
   *cvt_list       IGRchar        an array of characters to place ascii text in.

 Sample Call:
 
   status = co$cvt_exp_to_alias(msg =  &msg,
                                unit_type = GRIO_DISTANCE,
                                num_def = &num_def,
                                output_alias = output_alias_list,
                                working_units = &working_units,
                                cvt_list = output_string);

 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:

*/

#omdef co$cvt_exp_to_alias(msg,
                           unit_type,
                           osnum = OM_Gw_current_OS,
                           num_def,
                           output_alias,
                           working_units,
                           readout_spec = NULL,
                           field_size = NULL,
                           inverse_scale_flag = (short) GRIO_X_SCALE,
                           fraction_mode = NULL,
                           cvt_list)

        GRcvt_exp_to_alias((msg),
                           (unit_type),
                           (osnum),
                           (num_def),
                           (output_alias),
                           (working_units),
                           (readout_spec),
                           (field_size),
                           (inverse_scale_flag),
                           (fraction_mode),
                           (cvt_list) )

#endomdef



/*------------------------ co$cvt_imp_to_wrk ---------------------------------

   status = co$cvt_imp_to_wrk(msg,
                              unit_type,
                              osnum,
                              primary,
                              secondary,
                              tertiary,
                              result);


  ABSTRACT:
  --------- 
     This macro will return to the caller the sum total of working
   units in the primary, secondary, and tertiary arguments.
   all conversions will be based on the default units stored
   in the unit of measurement object.  

  ARGUMENTS:
  ----------   

   *msg            IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *unit_type       IGRchar       Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area
                                  
    osnum          OMuword        object space conversion is to occur in.
    
    primary         IGRdouble     num of primary units

    secoundary      IGRdouble     num of secondary units

    tertiary        IGRdouble     num of tertiary units

   *result          IGRdouble     number of working units
                                  returned.
   

 Sample Call:
 
   status = co$cvt_imp_to_wrk(msg =  &msg,
                              unit_type = GRIO_DISTANCE,
                              primary = 100.0,
                              result = &result_cvt);


 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:

*/

#omdef      co$cvt_imp_to_wrk(msg, 
                              unit_type,
                              osnum = OM_Gw_current_OS,
                              primary,
                              secondary = 0.0,
                              tertiary  = 0.0,
                              result)

             GRcvt_imp_to_wrk((msg),
                              (unit_type),
                              (osnum),
                              (primary),
                              (secondary),
                              (tertiary),
                              (result) )
#endomdef

/*--------------------------- co$cvt_exp_to_wrk --------------------------

   status = co$cvt_exp_to_wrk(msg,
                              unit_type,
                              osnum,
                              units,
                              alias,
                              result);


  ABSTRACT:
  --------- 
     This macro will return to the caller the number of working
   units after units is converted.
   all conversions will be based on the default units passed
   to the unit of measurement object.  

  ARGUMENTS:
  ----------   

   *msg            IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *unit_type       IGRchar       Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

    osnum          OMuword        object space conversion is to occur in.
                                          
    units           IGRdouble     num of units to convert

   *alias           IGRchar       name of alias

   *result          IGRdouble     number of working units
                                  returned.
   

 Sample Call:
 
   status = co$cvt_exp_to_wrk(msg =  &msg,
                              unit_type = GRIO_DISTANCE,
                              units = 12.0
                              alias = "feet"
                              result = &result);


 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:

*/

#omdef      co$cvt_exp_to_wrk(msg, 
                              unit_type,
                              osnum = OM_Gw_current_OS,
                              units,
                              alias,
                              result)

             GRcvt_exp_to_wrk((msg),
                              (unit_type),
                              (osnum),
                              (units),
                              (alias),
                              (result) )
#endomdef

/*--------------------------- co$cvt_value_to_value--------------------------

   status = co$cvt_value_to_value(msg,
                                  unit_type,
                                  osnum,
                                  alias_to_cvt_from,
                                  alias_to_cvt_to,
                                  num_vals,
                                  values_in,
                                  values_in);


  ABSTRACT:
  --------- 
     This macro will convert values in a specified unit to a value of
   another unit type.  Any number of values may be converted in one call. 
   All unit conversions are performed in DPFP arithmethic.


  ARGUMENTS:
  ----------   

   *msg               IGRlong     o - Return message:
                                      MSSUCC - success
                                      MSFAIL - conversion failed.

   *unit_type         IGRchar     i - Indicates what type of unit conversion is
                                      performed.  For example,
                                         GRIO_DISTANCE converts to distance
                                         GRIO_ANGLE    converts to angle
                                         GRIO_AREA     converts to area

    osnum             OMuword     i -  object space conversion is to occur in.
                                          
   *alias_to_cvt_from IGRchar     i -  This describes the unit type of the 
                                       input values.  If NULL, then we assume
                                       the conversion is from working units.

   *alias_to_cvt_to   IGRchar     i -  This describes the unit type of the 
                                       output values.  If NULL, then we assume
                                       the conversion is to working units.
                                      
    num_vals          IGRint      i - The number of values to convert.
    
   *values_in         IGRdouble[] i - The array of values to convert.
   
   *values_out        IGRdouble[] o - The array of converted values.  May
                                      occupy the same sapce as values_in.
    
 Sample Call:
 
   status = co$cvt_value_to_value(msg =  &msg,
                                  unit_type = GRIO_DISTANCE ,
                                  alias_to_cvt_to = output_alias,
                                  values_in = &values_in[0],
                                  values_out = &values_out[0]);


 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:

*/

#omdef      co$cvt_value_to_value(msg, 
                                  unit_type,
                                  osnum = OM_Gw_current_OS,
                                  alias_to_cvt_from = NULL,
                                  alias_to_cvt_to = NULL,
                                  num_vals,
                                  values_in,
                                  values_out)

             GRcvt_value_to_value((msg),
                                 (unit_type),
                                 (osnum),
                                 (alias_to_cvt_from),   
                                 (alias_to_cvt_to),
                                 (num_vals),
                                 (values_in),
                                 (values_out))
#endomdef


/*-------------------------- co$is_unit_scalable ----------------------------

  co$is_unit_scalable( msg,
                       unit_type,
                       osnum,
                       is_scalable)
  Abstract:
     This method sets a user-supplied boolean flag to indicate if the
     units of this object can be scaled.

   Arguments:

     IGRlong      *msg          o   Return message:
                                       MSSUCC - success
                                       MSFAIL - unit type does not exist

     IGRchar      *unit_type    i   type of unit object.  For example,
                                      GRIO_DISTANCE ( distance )
                                      GRIO_ANGLE    ( angle )
                                      GRIO_AREA     ( area )
                                  
     OMuword       osnum        i   object space unit object is in.
                                    defaults to OM_Gw_Current_OS.
   
     IGRboolean   *is_scalable  o  flag indicates if unit is scalable
                                    TRUE  - unit is scalable.
                                    FALSE - unit is not scalable.
    Sample Call:
 
      IGRboolean  is_scalable;
      IGRlong     msg;
      status = co$is_unit_scalable( msg =  &msg,
                                    unit_type = GRIO_DISTANCE,
                                    is_scalable = &is_scalable );

    Return Status :  
    
     OM_S_SUCCESS  -  Success
     OM_E_ABORT    -  Failure

*/
#omdef      co$is_unit_scalable(msg, 
                                unit_type,
                                osnum = OM_Gw_current_OS,
                                is_scalable)
                                   

            GRis_unit_scalable((msg), 
                               (unit_type),
                               (osnum),
                               (is_scalable))
#endomdef



/*--------------------------- co$update_readout_spec ---------------------

 status = co$update_readout_spec(msg,
                                 unit_type,
                                 osnum,
                                 update_flag,
                                 readout_spec)
  ABSTRACT:
  --------- 
          This macro will either extract from the unit object the default
       readout specs, or load them depending on the value of update_flag.


  ARGUMENTS:
  ----------   

   *msg            IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - failed

   *unit_type       IGRchar       Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

    osnum          OMuword        object space conversion is to occur in.
    
    update_flag    IGRboolean     true: update with contents in readout_spec
                                  false: retrieve contents into readout_spec
    
    readout_spec  struct GRIOreadout_spec  

 Sample Call: To update readout spec
 
   status = co$update_readout_spec(msg = &msg,
                                   unit_type = GRIO_DISTANCE,
                                   readout_spec = &readout_spec);

 Sample Call: To retrieve readout spec
 
   status = co$update_readout_spec(msg = &msg,
                                   unit_type = GRIO_ANGLE,
                                   update_flag = FALSE;
                                   readout_spec = &readout_spec);


 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:

*/

#omdef      co$update_readout_spec(msg, 
                                   unit_type,
                                   osnum = OM_Gw_current_OS,
                                   update_flag = (IGRboolean) TRUE,
                                   readout_spec)
                                   

            GRupdate_readout_spec((msg), 
                                  (unit_type),
                                  (osnum),
                                  (update_flag),
                                  (readout_spec))
#endomdef

/*--------------------------- co$get_default_units --------------------------
       co$get_default_units(msg,
                            table_name,
                            osnum,
                            flag,
                            num_defaults,
                            default_units)

       ABSTRACT:
       --------- 
                 This macros will retrieve from the unit object the currrently
              defined input or output default units.    

 Arguments:

   *msg             IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *table_name      IGRchar       Indicates what type of unit conversion is 
				  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

     osnum          OMuword       Object space variable is to be stored in.
    
    *flag           short         Which defaults are to be retrieved.
                                  0 retrieve input defaults
                                  1 retrieve output defaults 
    
    *num_defaults   short         Indicates how many defaults are currently 
                                  defined.
                                  
    *default_units  char          address of character array to store strings
                                  in.
 Sample Call:
        char   return_array[3][40];
        flag = 0;
        status = co$get_default_units(msg = &msg,
                                      table_name = GRIO_DISTANCE,
                                      flag = &flag,
                                      num_defaults = num_default,
                                      default_units = return_array)

 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:
 
*/

#omdef        co$get_default_units(msg,
                                   table_name,
                                   osnum = OM_Gw_current_OS,
                                   flag,
                                   num_defaults,
                                   default_units)

                       
              GRget_default_units( (msg),
                                   (table_name),
                                   (osnum),
                                   (flag),
                                   (num_defaults),
                                   (default_units))
                  
#endomdef

/*--------------------------- co$put_default_units --------------------------
       co$put_default_units(msg,
                            table_name,
                            osnum,
                            flag,
                            num_defaults,
                            default_units)

       ABSTRACT:
       --------- 
                 This macros will retrieve from the unit object the currrently
              defined input or output default units.    

 Arguments:

   *msg             IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *table_name      IGRchar       Indicates what type of unit conversion is 
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

     osnum          OMuword       Object space variable is to be stored in.
    
    *flag           short         Which defaults are to be retrieved.
                                  0 retrieve input defaults
                                  1 retrieve output defaults 
    
    *num_defaults   short         Indicates how many defaults are currently 
                                  defined.
                                  
    *default_units  char          address of character array to store strings
                                  in.
 Sample Call:
        char   return_array[3][40];
        flag = 0;
        status = co$put_default_units(msg = &msg,
                                      table_name = GRIO_DISTANCE,
                                      flag = &flag,
                                      num_defaults = num_default,
                                      default_units = return_array)

 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:
 
*/

#omdef        co$put_default_units(msg,
                                   table_name,
                                   osnum = OM_Gw_current_OS,
                                   flag,
                                   num_defaults,
                                   default_units)

                       
              GRput_default_units( (msg),
                                   (table_name),
                                   (osnum),
                                   (flag),
                                   (num_defaults),
                                   (default_units))
                  
#endomdef

/*------------------------------- co$addvar ----------------------------------
       co$addvar(msg,
                 input_alias,
                 osnum,
                 input_variable)

       ABSTRACT:
       ---------   
          This macro will add a variable to the internal variable table.
      The variable name will be what is contained in input_alias.
      The contents of the variable will either be stored as a integer,
      float, or ascii string.


 Arguments:

   *msg             IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

    *input_alias    IGRchar        alias to be associated with input string.

     osnum          OMuword        object space variable is to be stored in.
    
    *input_variable GRIOvar_def    variable structure to be saved.
    
 Sample Call:
       status = co$addvar(msg = &msg,
                          input_alias = "PI",
                          input_variable = &input_variable)
 
 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:
 
*/

#omdef       co$addvar(msg,
                       input_alias,
                       osnum = OM_Gw_current_OS,
                       input_string)
                       
             GRaddvar((msg),
                      (input_alias),
                      (osnum),
                      (input_string))
#endomdef


/*------------------------------- co$delvar ----------------------------------
       co$delvar(msg,
                 num_alias,
                 osnum,
                 input_alias)



       ABSTRACT:
       ---------   
          This macro will delate one or more variables from the internal
      variable table.

 Arguments:

   *msg            IGRlong        Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *num_alias      IGRshort       number of aliases to delete.
   
    osnum          OMuword        object space variable deleted from.

   *input_alias    GRIOalias_name list of aliases to be deleted.
    

 Sample Call:
       status = co$delvar(msg = &msg,
                          num_alias = &num_alias,
                          input_alias = alias_list);
 
 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:
 
*/
#omdef co$delvar(msg,
                 num_alias,
                 osnum = OM_Gw_current_OS,
                 input_alias)

       GRdelvar((msg),
                (osnum),
                (num_alias),
                (input_alias) )
#endomdef



/*------------------------------- co$cvtvar ----------------------------------
       co$cvtvar(msg,
                 alias,
                 osnum,
                 var)

       ABSTRACT:
       ---------   
          This macro will convert a alias to its stored value.
      this value will be placed in var

 Arguments:

   *msg            IGRlong         Return message:
                                     MSSUCC - success
                                     MSFAIL - conversion failed.

   *alias         IGRchar          alias to be converted.
   
    osnum          OMuword         object space variable is to be 
                                   converted from.   
    
    *var        struct GRIOvar_def  variable after translation
    
 Sample Call:
       status = co$cvtvar(msg = &msg,
                          alias = "PI",
                          var = &var_struct)
 
 Return Status :  
    
  OM_S_SUCCESS  -  Success
  OM_E_ABORT -  Failure

 Caveats:
 
*/

#omdef       co$cvtvar(msg,
                       alias,
                       osnum=OM_Gw_current_OS,
                       var)
                       
             GRcvt_to_var((msg),
                          (alias),
                          (osnum),
                          (var))
#endomdef


/* ----------------------- co$update_current_point_form() ----------------------

  Macro:  co$update_current_point_form( msg,
                                        flag = UPDATE_ONLY_IF_DISPLAYED )


  Abstract: This OM macro sends an update message to the Current Point 
            Form, if one exists.  This causes information about the DPB's
            Last Point parameter to be displayed in the form.  Any software 
            that updates the DPB's last point or the default coordinate 
            system type or the active coordinate system, should call this
            macro after doing so.

  Example:
                                 
     status = CO_update_current_point_form( msg = &ReturnMsg );

  Arguments:

     *ReturnMsg                    IGRlong  

           Always returns MSSUCC


      flag  IGRint

           values ( from griodef.h ):

              UPDATE_ONLY_IF_DISPLAYED  ( default )
              UPDATE_UNCONDITIONALLY
           

      Returns IGRlong
           Always returns MSSUCC


  Notes:

    If the "Current point" form does not exist, it will exit.  If the
    form exists but is not displayed, then the flag  determines if the 
    form is updated.  If the form is displayed, then it will be 
    unconditionally updated.
 
    This flag indicates whether the "Current point" form's fields are 
    udpated only when the form is displayed.  This flag is usually set to
    UPDATE_ONLY_IF_DISPLAYED;  It is set to UPDATE_UNCONDITIONALLY in
    cases where the form needs to be updated just before being displayed.


  History: 
  
    srh   06/15/87   - created
    srh   11/17/87   - added flag to the arglist


 */


#omdef co$update_current_point_form( msg,
                                     flag = UPDATE_ONLY_IF_DISPLAYED )

       COupdate_current_point_form( (msg),
                                    (flag) )

#endomdef


/* ------------------------------- co$epp() ------------------------------

   Macro:  co$epp()
   
   Abstract:
   
      Expression preprocessor for expanding string variables in an 
      expression; its primary use is as a preprocessor for co$expreval
      ( the numeric expression evaluator )

   Arguments:

      msg          *IGRlong        return code
                                     MSSUCC
                                     MSFAIL
      string       *IGRchar        input expression to be parsed
      sizebuf       IGRint         size of NewString buffer
      buffer       *IGRchar        where resulting expression is placed

   Returns:
      MSSUCC
      MSFAIL

   Example Call:

     Status = co$epp( msg     = &ReturnCode,
                      string  =  Expression,
                      sizebuf =  132,
                      buffer  =  NewExpression );

     . . . where  NewExpression is an array of 132 IGRchar's

   Caveats:

     string and buffer pointers should never be set to NULL

   History:
     
 */

#omdef co$epp ( msg,
                string,
                sizebuf,
                buffer )


  COexpression_preprocessor( msg,
                             string,
                             sizebuf,
                             buffer )

#endomdef

/*
 *  Macro :  co$unit_database_type
 *
 *  Abstract:  give an object space number, this function determines
 *             if the DISTANCE data base units of the the OS are 
 *             english, metric, or other.  If other, this is not a
 *             design file that the I/EMS product will support.
 *
 *  Arguments: 
 *
 *    OMuword  osnum    I  object space tested
 *    IGRint  *eng_met  O  type of units (in griodef.h):
 *                           GRIO_UNITS_ARE_UNKNOWN - not supported 
 *                           GRIO_UNITS_ARE_ENGLISH - 1 internal DBU = 1 inch
 *                           GRIO_UNITS_ARE_METRIC  - 1 internal DBU = 1 mm 
 *                                 
 *  Returns: IGRint 
 *    MSSUCC - If the DISTANCE element is found in the specified object space
 *    MSFAIL - If the DISTANCE element is NOT found in the specified OS
 *      
 *  History:
 *    Shelley R. Heard  10/18/91 - created
 */
#omdef co$unit_database_type( osnum, db_type )

   GRunit_database_type( osnum, db_type )

#endomdef       

#endif 

