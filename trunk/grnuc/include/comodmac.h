#ifndef comodmacros_include
#define comodmacros_include



/*
Name
    co$modify_element(
                msg,
                events,
                module,
                mode = GRhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

Abstract
        This macro modifys an object.
                                                                            
Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        events[0] is the from point
        events[1] is the to point

    struct GRmd_env   *module
        context of located object

    GRobjid           cob_id
        object id of calling object, or at least some object

    enum GRdpmode     mode
        how the element is to be redrawn after being modified
        for example GRhd or GRbd.

    struct GRid       *display_obj
        id of object to display located object

    OM_S_CHANSELECTOR *p_chanselect
        pointer to a chanselect structure for located object on channel

Example call

 co$modify_element(
                msg = &msg,
                events = event_array,
                module = &ME.my_command->module,
                display_obj = &ME.my_command->module.md_id,
                p_chanselect );

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

*/
#omdef co$modify_element(
                msg,
                events,
                module,
                mode = GRhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

CO_ni_modify_element(
                (msg),
                (events),
                (module),
                (mode),
                (display_obj),
                (cob_id),
                (p_chanselect),
                (grid) );

#endomdef



/*
Name
    co$extend_element(
                msg,
                events,
                module,
                mode = GRhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

Abstract
        This macro (dis)extends an open element by a distance or to a point.
                                                                            
Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        events[0] is the point identifying the end of the open
                element to be extended
        events[1] is the value the element should be extended.
                if the value is negative, then the element will be
                disextended.
                if events[1] is a point, then the element will be
                (dis)extended to that point

    struct GRmd_env   *module
        context of located object

    GRobjid           cob_id
        object id of calling object, or at least some object

    enum GRdpmode     mode
        how the element is to be redrawn after being modified
        for example GRhd or GRbd.

    struct GRid       *display_obj
        id of object to display located object

    OM_S_CHANSELECTOR *p_chanselect
        pointer to a chanselect structure for located object on channel

Example call

 co$extend_element(
                msg = &msg,
                events = events_array,
                module = &ME.my_command->module,
                display_obj = &ME.my_command->module.md_id,
                p_chanselect );

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

*/
#omdef co$extend_element(
                msg,
                events,
                module,
                mode = GRhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

CO_ni_extend_element(
                (msg),
                (events),
                (module),
                (mode),
                (display_obj),
                (cob_id),
                (p_chanselect),
                (grid) );

#endomdef



/*
Name
    co$delete_vertex(
                msg,
                events,
                module,
                mode = GRhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

Abstract
        This macro deletes a vertex from a linear object.
                                                                            
Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        events[0] is the point near the vertex to be deleted.

    struct GRmd_env   *module
        context of located object

    GRobjid           cob_id
        object id of calling object, or at least some object

    enum GRdpmode     mode
        how the element is to be redrawn after being modified
        for example GRhd or GRbd.

    struct GRid       *display_obj
        id of object to display located object

    OM_S_CHANSELECTOR *p_chanselect
        pointer to a chanselect structure for located object on channel

Example call

 co$delete_vertex(
                msg = &msg,
                events = event_array,
                module = &ME.my_command->module,
                display_obj = &ME.my_command->module.md_id,
                p_chanselect );

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

*/
#omdef co$delete_vertex(
                msg,
                events,
                module,
                mode = GRhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

CO_ni_delete_vertex(
                (msg),
                (events),
                (module),
                (mode),
                (display_obj),
                (cob_id),
                (p_chanselect),
                (grid) );

#endomdef



#endif /* comodmacros_include */
