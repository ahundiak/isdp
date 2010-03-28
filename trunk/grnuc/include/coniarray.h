#ifndef coniarray_include
#define coniarray_include


extern IGRlong ( *CO_GA_ni_funcs[])();


/*
#omdef co$ni_place_func(
                func_index = 0,
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object, properties,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
Abstract
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong           func_index
        index into the non-interactive function array

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  


Example call

co$ni_place_func(
                func_index = OM_ni_place_cr_diam,
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                grid = &CircleGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dcircle" );

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$ni_place_func(
                func_index = 0,
                msg,
                events = NULL,
                mode = GRbd,
                newflag = FALSE,
                module,
                symbology = NULL,
                level = NULL,
                attr = NULL,
                name = NULL,
                display_obj = NULL,
                classname = NULL ^
                classid = OM_K_NOTUSING_CLASSID,
                grid,
                neighbor = OM_GS_NULL_NEIGHBOR,
                cob_id = my_id,
                cob_os = OM_Gw_current_OS,
                p_co_chansel = NULL,
                co_index = NULL )
                                                                            
CO_GA_ni_funcs[(func_index)](
                (msg),
                (events),
                (mode),
                (newflag),
                (module),
                (symbology),
                (level),
                (attr),
                (name),
                (grid),
                (display_obj),
                (classname),
                (classid),
                (neighbor),
                (cob_id),
                (cob_os),
                (p_co_chansel),
                (co_index) );
#endomdef


/*
Name
#omdef co$ni_modify_func(
                func_index = 0,
                msg,
                events,
                module,
                mode = GRbdhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

Abstract
        This macro modifys an object.
                                                                            
Arguments

    IGRlong           func_index
        index into the non-interactive function array

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

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

 co$ni_modify_func(
                func_index = 0,
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
#omdef co$ni_modify_func(
                func_index = 0,
                msg,
                events,
                module,
                mode = GRbdhd,
                display_obj = NULL,
                cob_id = my_id,
                p_chanselect = NULL ^
                    grid = NULL )

CO_GA_ni_funcs[(func_index)](
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
    co$ni_modify_two_elements_func(
                func_index = 0,
                msg,
                events,
                modules,
                mode = GRbd,                
                display_obj,
                cob_id = my_id,
                cob_os = OM_Gw_current_OS,
                p_chanselect,
                from = 0,
                to = OM_K_MAXINT,
                objects )

Abstract
        This macro modifys two objects.
                                                                            
Arguments

    IGRlong           func_index
        index into the non-interactive function array

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

    struct GRmd_env   *module[]
        context of located object

    GRobjid           cob_id
        object id of calling object, or at least some object

    GRspacenum        cob_os
        object space number of calling object, or at least some object

    struct GRid       *display_obj
        id of object to display located object

    struct GRid      *grids[]
        array of located objects

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

*/
#omdef co$ni_modify_two_elements_func(
                func_index = 0,
                msg,
                events,
                modules,
                mode = GRbd,
                display_obj,
                objects,
                cob_id = my_id,
                p_chanselect = NULL,
                cob_os = OM_Gw_current_OS )

CO_GA_ni_funcs[(func_index)](
                (msg),
                (events),
                (modules),
                (mode),
                (display_obj),
                (cob_id),
                (cob_os),
                (p_chanselect),
                (objects) );

#endomdef


#omdef co$ni_locate_two_and_construct(
                func_index = 0,
                msg,
                events = NULL,
                construct_mode = GRbd,
                newflag = FALSE,
                construct_module,
                symbology = NULL,
                level = NULL,
                attr = NULL,
                name = NULL,
                display_obj = NULL,
                classname = NULL ^
                classid = OM_K_NOTUSING_CLASSID,
                grid,
                neighbor = OM_GS_NULL_NEIGHBOR,
                cob_id = my_id,
                cob_os = OM_Gw_current_OS,
                p_co_chansel = NULL,
                co_index = NULL,
                modules,
                locate_mode = GRbd,
                objects )

CO_GA_ni_funcs[(func_index)](
                (msg),
                (events),
                (construct_module),
                (newflag),
                (symbology),
                (level),
                (attr),
                (name),
                (grid),
                (classname),
                (classid),
                (neighbor),
                (cob_id),
                (cob_os),
                (p_co_chansel),
                (co_index),
                (locate_mode),
                (construct_mode),
                (display_obj),
                (modules),
                (objects) );

#endomdef

#omdef co$ni_construct_xhatch(func_index = 0,
                              msg,
                              events = NULL,
                              level = NULL,
                              attr = NULL,
                              grid,
                              cob_id = my_id,
                              cob_os = OM_Gw_current_OS,
                              p_co_chansel = NULL,
                              modules,
                              objects,
                              xhatch_color, 
                              xhatch_spacing,
                              xhatch_angle,
                              xhatch_pattern)
                              

CO_GA_ni_funcs[(func_index)]((msg),
                             (events),
                             (level),
                             (attr),
                             (grid),
                             (cob_id),
                             (cob_os),
                             (p_co_chansel),
                             (modules),
                             (objects),
                             (xhatch_color),
                             (xhatch_spacing),
                             (xhatch_angle),
                             (xhatch_pattern));

#endomdef


#define NUMBER_OF_EVENTS 7

#define set_up_event_array \
    events[0] = &ME.COnpt->first_event; \
    events[1] = &ME.COnpt->second_event; \
    events[2] = &ME.COnpt->third_event; \
    events[3] = &ME.COnpt->fourth_event; \
    events[4] = &ME.COnpt->fifth_event; \
    events[5] = &ME.COnpt->sixth_event; \
    events[6] = &ME.COnpt->seventh_event;

#define declare_multi \
    struct GRmd_env   *modules[3]; \
    struct GRid       *grids[3]; \
    struct GRid        FirstGrid; \
    struct GRid        SecondGrid; \
    struct GRid        ThirdGrid;

#define set_up_multi \
    set_up_event_array; \
    grids[0] = &FirstGrid; \
    grids[1] = &SecondGrid; \
    grids[2] = &ThirdGrid; \
    modules[0] = &ME.COnpt->FirstContext; \
    modules[1] = &me->ModuleInfo; \
    modules[2] = &ME.COnpt->SecondContext;
#define set_up_multi2 \
    set_up_event_array; \
    grids[0] = &FirstGrid; \
    grids[1] = &SecondGrid; \
    grids[2] = &ThirdGrid; \
    modules[0] = &ME.COnpt->FirstContext; \
    modules[1] =  &ME.COnpt->SecondContext; \
    modules[2] = &me->ModuleInfo; 

#endif /* coniarray_include */

