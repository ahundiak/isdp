#ifndef comiscmacros_include
#define comiscmacros_include

                                                                            
/*
#omdef co$construct_object(
                msg,
                mode = NULL,
                newflag = FALSE,
                properties = 0,
                geometry,
                module,
                symbology = NULL,
                level = NULL,
                attr = NULL,
                name = NULL,
                display_obj = NULL,
                classname = NULL ^
                    classid = OM_K_NOTUSING_CLASSID ^
                    objid = NULL_OBJID ^
                    object = NULL,
                grid,
                neighbor = OM_GS_NULL_NEIGHBOR,
                cob_id = my_id,
                cob_os = OM_Gw_current_OS,
                p_co_chansel = NULL,
                co_index = NULL )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong         *msg
                return codes

    enum GRdpmode    *mode
                mode the object is displayed in ( if it is displayed ).
                defaults to GRbd if NULL is passed in

    IGRboolean      newflag
                defaults to false.

    short unsigned   properties
                properties of the new graphics object
                                                                            
    IGRchar          *geometry
                pointer to the geometry

    struct GRmd_env  *module
                module of the object space that the object in which the object
                is to be constructed

    struct IGRdisplay   *symbology
                symbology of the new object
                if this pointer is NULL, then the active symbology
                from the dpb will be used.
                                                                            
    IGRshort            *level        
                level new object is to be placed on
                if this pointer is NULL, then the active level
                from the dpb will be used.
                      
    IGRchar          *attr
                class attributes of the new object

    IGRchar          *name
                name of the new object

    struct GRid      *grid
                GRid of the new object

    struct GRid           *display_obj
                object that will display the new object (i.e. the
                module or a window)
                                                                            
classname ^ classid ^ objid ^ object 
                                                                            
    IGRchar               *classname
                class name of the new object

    GRclassid              classid
                class id of the new object
                                                                            
    GRobjid                objid
                object id of an old object

    GRobjecthdr            object
                pointer to an object header

    OM_S_NEIGHBOR          neighbor
                a structure for neighbor near whom the object will be
                created   ( OM_GS_NULL_NEIGHBOR )

    OM_S_OBJID             cob_id
                command object's object id

    GRspacenum             cob_os
                command object's OS

    OM_S_CHANSELECT     *p_co_chansel
                pointer to a channel structure in command object

    IGRint               co_index
                index on command object


Example call

co$construct_object(
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                geometry = &bspline,
                symbology = &ME.COconst->ActiveDisplay,
                level = &ME.COconst->ActiveLevel,
                grid = &CircleGrid,
                display_obj = &DisplayGrid,
                classname = classname );

Status returns

    om return codes that deal with constructs/connects
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$construct_object(
                msg,
                mode = NULL,
                newflag = FALSE,
                properties = 0,
                geometry,
                module,
                symbology = NULL,
                level = NULL,
                attr = NULL,
                name = NULL,
                display_obj = NULL,
                classname = NULL ^
                    classid = OM_K_NOTUSING_CLASSID ^
                    objid = NULL_OBJID ^
                    object = NULL,
                grid,
                neighbor = OM_GS_NULL_NEIGHBOR,
                cob_id = my_id,
                cob_os = OM_Gw_current_OS,
                p_co_chansel = NULL,
                co_index = NULL )
                                                                            
#if om$specified( p_co_chansel ) && om$specified( cob_id ) && om$equal( cob_id, NULL_OBJID )

#omerror "cob_id may not be NULL_OBJID"

#else
                                                                            
COConstructObject( 
                (msg),
                (mode),
                (newflag),
                (properties),
                (geometry),
                (module),
                (symbology),
                (level),
                (attr),
                (name),
                (grid),
                (display_obj),
                (classname),
                (classid),
                (objid),
                (object),
                (neighbor),
                (cob_id),
                (cob_os),
                (p_co_chansel),
                (co_index) );

#endif


#endomdef

/*
    [7m[1mco$erase_send_draw[0m(
                msg,
                matrix_type,
                matrix,
                erase_mode = GRbe,
                erase_obj = NULL,
                mesg,
                draw_mode = GRhd,
                draw_obj = NULL,
                cob_id = my_id,
                grid = NULL,
                p_chanselect,
                from = NULL,
                to = OM_K_MAXINT )
                                                                            
[7m[1mAbstract[0m
        This macro sends a display message, intended to be an erase message,
        then sends a message supplied by the command object, then
        sends another message, intended to redraw the element.

        1).  display.
        2).  user supplied message.
        3).  display.
                                                                            
[7m[1mArguments[0m

    IGRlong             *msg
        return codes

    IGRmatrix            matrix
        context of element

    IGRshort            *matrix_type

    enumb GRdpmode       erase_mode
        Mode the object is displayed in ( if it is displayed ).
        Defaults to GRbe.  intended to be used to erase the object.

    struct GRid         *erase_obj
        Object used in the first display message.  If this parameter
        is not specified, then the first display message will
        not be sent.



    OM_S_MESSAGE         mesg
        Message to be sent to object.  user specified.
                                                                            
    enum GRdpmode        draw_mode
        Mode the object is displayed in ( if it is displayed ).
        Defaults to GRhd.  intended to be used to draw the object.

    struct GRid         *draw_obj
        Object used in the second display message.  If this parameter
        is not specified, then the second display message will
        not be sent.

    GRobjid              cob_id
        Command object's id.

        struct GRid         *grid
            Object to whom the message will be sent.

        OM_S_CHANSELECT     *p_chanselect
            pointer to a channel structure in command object

    IGRint               from
        from index on channel

    IGRint               to
        to index on channel


[7m[1mExample call[0m

co$erase_send_draw(
                msg,
                matrix_type = &ME.COtest->LocateContext.md_env.matrix_type,
                matrix = ME.COtest->LocateContext.md_env.matrix, 
                mesg = message GRgraphics.some_msg( ),
                erase_obj = ModuleInfo.md_id,
                draw_obj = ModuleInfo.md_id,
                p_chanselect = &MyChannelStruct )
                                                                            

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_ABORT
        OM_I_INVARG
                                                                            
[7m[1mCaveats[0m
    The object must be on a channel.
*/
                                                                            
#omdef co$erase_send_draw(
                msg,
                matrix_type,
                matrix,
                erase_mode = GRbe,
                erase_obj = NULL,
                mesg,
                draw_mode = GRhd,
                draw_obj = NULL,
                cob_id = my_id,
                grid = NULL,
                p_chanselect = NULL,
                from = NULL,
                to = OM_K_MAXINT )
                                                                            
COEraseSendRedraw( 
                (msg),
                (matrix_type),
                (matrix),
                (erase_mode),
                (erase_obj),
                (mesg),
                (draw_mode),
                (draw_obj),
                (cob_id),
                (p_chanselect),
                (from),
                (to),
                (grid) );
                                                                            
#endomdef




/*
    [7m[1mco$project_event[0m(
                msg,
                event,
                module,
                point = NULL,
                parms = NULL,
                cob_id = my_id,
                p_chanselect = NULL,
                grid = NULL )
                                                                            
[7m[1mAbstract[0m
    This macro takes a data event and projects the point in the
    event onto the element.  The projected point and the parms are
    returned

[7m[1mArguments[0m

    IGRlong            *msg
        return codes

    struct GRmd_env     module
        context of object

    IGRpoint            point
        point on the element

    struct GRparms     *parms
        geometric parameters of the point on the element

    GRobjid             cob_id
        Command object's id.


    struct GRid         *grid
        Object to whom the message will be sent.

    OM_S_CHANSELECT     *p_chanselect
        pointer to a channel structure in command object

        either grid or p_chanselect can be specified


[7m[1mExample call[0m

#omdef co$project_event(
                msg,
                event = &ME.COtest->LocateEvent,
                module = &ME.COtest->LocateContext,
                point = ProjectedPoint,
                p_chanselect = &MyChannelStruct )
                                                                            

[7m[1mStatus returns[0m
    om return codes
*/
                                                                            
#omdef co$project_event(
                msg,
                event,
                module,
                point = NULL,
                parms = NULL,
                cob_id = my_id,
                p_chanselect = NULL,
                grid = NULL )
                                                                            
COproject_event( 
                (msg),
                (event),
                (module),
                (point),
                (parms),
                (cob_id),
                (p_chanselect),
                (grid) )
                                                                            
#endomdef

/*

 co$build_event( msg,
                 event_response = EX_DATA,
                 event_nbytes = sizeof( struct EX_button ),
                 button = NULL   ^
                    keyin = NULL ^
                    value = NULL,
                 subtype = GRst_REGULAR,
                 num_id = 0,
                 num_val = 0,
                 values_1 = 0.0,
                 values_2 = 0.0,
                 located_object_1 = NULL,
                 located_object_2 = NULL,
                 event )


 Arguments:

  *msg              IGRlong           
     return status message
        MSSUCC
        MSFAIL - if arguments are correct, this should never be returned.

   event_response   IGRint  
      response type of event to be assigned to the event->response field.

   event_nbytes     IGRint
      number of bytes allocated in event buffer; this value is assigned to 
      the event->nbytes field.

  *button           EX_button
      data point buffer; this information is put in the event->event.button
      field.

  *keyin            IGRchar
      text character buffer of length event_nbytes; note that a text string in
      the event->event.keyin buffer may contain non-terminal NULL characters.
      It is thus important that event_nbytes be set to the exact length of the
      string ( including any terminal NULL characters ).

  *value            IGRdouble
      double precision floating point value for value events; this information
      is put in the event->event.value field.

   subtype          IGRint
      subtype of this event

   num_id           IGRshort
      number of objid's found in the event->located_objects array; this value
      is stored in event->num_id field.

   num_val          IGRshort
      number of numeric values in the event->values array; this value is 
      stored in event->num_val field.

   values_1   IGRdouble
      first value in event->values array 

   values_2   IGRdouble
      first value in event->values array 

  *located_object_1   struct GRlc_info 
      first located object structure in the event->locate_object array
      
  *located_object_2   struct GRlc_info 
      second located object structure in the event->locate_object array

  *event            struct GRevent    
      event structure to be constructed with the infromation described above




 Examples:


   size = ( strlen( my_string ) + 1 );  
   status = co$build_event( msg            = &my_msg,
                            event_response =  STRING,
			    event_size     =  size,
                            keyin          =  my_string,
                            event          = &my_event );
   -----------------------------------------------------------------

   status = co$build_event( msg            = &my_msg,
                            event_response =  VALUE,
                            event_size     =  sizeof( IGRdouble ),
                            value          = &my_value,
                            event          = &my_event );
   -----------------------------------------------------------------

   status = co$build_event( msg     = &my_msg,
                            button  = &my_button,
                            subtype =  GRst_KEYPOINT,
                            event   = &my_event );
                            

 Returns:

   MSSUCC - always

 Caveats:

  Defaults were chosen to simplify the generation of data points.

  If located_objects ptr is NULL then the fields of these structures are
  cleared out and are thus not usable.


*/

#omdef  co$build_event( msg,
                        event_response = EX_DATA,
                        event_nbytes = sizeof( struct EX_button ),
                        button = NULL   ^
                           keyin = NULL ^
                           value = NULL,
                        subtype = GRst_REGULAR,
                        num_id = 0,
                        num_val = 0,
                        values_1 = 0.0,
                        values_2 = 0.0,
                        located_object_1 = NULL,
                        located_object_2 = NULL,
                        event )

    CObuild_event( (msg),
                   (event_response),
                   (event_nbytes),
                   (button),
                   (keyin),
                   (value),
                   (subtype),
                   (num_id),
                   (num_val),
                   (values_1),
                   (values_2),
                   (located_object_1),
                   (located_object_2),
                   (event ) )


#endomdef


/*

 co$build_button( msg,
                  x = 0.0,
                  y = 0.0,
                  z = 0.0,
                  window = 0,
                  objid = NULL,
                  osnum = OM_CURRENT_OS,
                  numb = 0,
                  clicks = 0,
                  button_down = 0,
                  button );



  This OM macro fills in the fields of an EX_button structure as used in
  IGE based applications to represent data buttons.


 Arguments:

   *msg            IGRlong
       return status message
          MSSUCC
          MSFAIL

    x              IGRdouble
       x coord. for button inputs

    y              IGRdouble
       y coord. for button inputs

    z              IGRdouble
       z coord. for button inputs

    window         IGRlong
       hardware window nbr for button input

    objid          OM_S_OBJID
       gragad objid for button inputs

    osnum          uword
       object space number of window

    numb           IGRshort
       button number

    clicks         IGRshort
       number of button clicks

    button_down    IGRshort
       1 = down; 0 = up

   *button         struct EX_button
      EX_button structure to be filled


 Example:

    status = co$build_button( msg    = &MyMsg,
                              x      = 100.0,
                              y      = 200.0,
                              window = MyWindowHarwareNumber,
                              objid  = MyWindowObjid,
                              osnum  = MyWindowOsnum,
                              button = &MyButton );
 Return Status :  
    
  MSSUCC  -  Always successful

 Caveats:


*/

#omdef co$build_button( msg,
                        x = 0.0,
                        y = 0.0,
                        z = 0.0,
                        window = 0,
                        objid = 0,
                        osnum = 0,
                        numb = 0,
                        clicks = 1,
                        button_down = 0,
                        button )

      CObuild_button( (msg),
                      (x),
                      (y),
                      (z),
                      (window),
                      (objid),
                      (osnum),
                      (numb),
                      (clicks),
                      (button_down),
                      (button) )

#endomdef

#endif 
