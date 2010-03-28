#ifndef coplcmacros_include
#define coplcmacros_include
                                                                            


/*
    co$place_circle_by_diameter(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first diameter point.
        event[1] is the second diameter point.


[7m[1mExample call[0m

co$place_circle_by_diameter(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &CircleGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dcircle" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$place_circle_by_diameter(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_circle_by_diameter(
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
                (co_index) )
#endomdef

/*
#omdef co$place_linear(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first point, and
        event[1] is the second point.

    only two point linestrings can be constructed


[7m[1mExample call[0m

co$place_linear(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &CircleGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dlinestr" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$place_linear(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_linear(
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
                (co_index) )
#endomdef

/*
#omdef co$place_circle_by_center(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the center point, and
        event[1] is the radius point.

        OR,

        event[0] is the center point, and
        event[1] is the radius value.


[7m[1mExample call[0m

co$place_circle_by_center(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &CircleGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dcircle" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$place_circle_by_center(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_circle_by_center(
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
                (co_index) )
#endomdef

/*
#omdef co$place_block(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first diagonal point.
        event[1] is the second diagonal point.


[7m[1mExample call[0m

co$place_block(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &BlockGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dorthpoly" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$place_block(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_block(
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
                (co_index) )
#endomdef

/*
#omdef co$place_rotblk(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is point one.
        event[1] is point two.
        event[1] is point three.


[7m[1mExample call[0m

co$place_rotblk(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &RotblkGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dorthpoly" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$place_rotblk(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_rotblk(
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
                (co_index) )
#endomdef

/*
#omdef co$place_point(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the point.

[7m[1mExample call[0m

co$place_point(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &PointGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dpoint" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
                                                                            
#omdef co$place_point(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_point(
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
                (co_index) )
#endomdef

/*
#omdef co$place_ellcnt(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is center point.
        event[1] is axis point.
        event[2] is point on the curve.


[7m[1mExample call[0m

co$place_ellcnt(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &EllipseGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dellipse" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
#omdef co$place_ellcnt(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_el_cnt(
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
                (co_index) )
#endomdef

/*
#omdef co$place_ellaxis(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is axis point 1.
        event[1] is axis point 2.
        event[2] is point on the curve.


[7m[1mExample call[0m

co$place_ellaxis(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &EllipseGrid,
                display_obj = &DisplayGrid,
                classname = "GR3dellipse" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
#omdef co$place_ellaxis(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_el_axis(
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
                (co_index) )
#endomdef

/*
#omdef co$place_halfell(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is axis point 1.
        event[1] is axis point 2.
        event[2] is point on the curve.


[7m[1mExample call[0m

co$place_halfell(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &ell_arc,
                display_obj = &DisplayGrid,
                classname = "GR3dellarc" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/

#omdef co$place_halfell(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_hael_axis(
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
                (co_index) )
#endomdef

/*
#omdef co$place_qrtell(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )
                                                                            
[7m[1mAbstract[0m
        This macro constructs and optionally displays an object.
        If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is axis point 1.
        event[1] is point on along axis.
        event[2] is axis point 2.


[7m[1mExample call[0m

co$place_qrtell(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &ell_arc,
                display_obj = &DisplayGrid,
                classname = "GR3dellarc" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
#omdef co$place_qrtell(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_qrtel_axis(
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
                (co_index) )
#endomdef


/* 
co$place_arc_by_center(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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

[7m[1mAbstract[0m
    This function constructs a bspline representation of a circular arc, then
     constructs and optionally displays a elliptical arc object.
    If the display_obj is specified, then the object is displayed.
                                                                            
[7m[1mArguments[0m

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] axis point 1.
        event[1] axis point 2.
        event[2] center point.
        event[3] arc direction Event[3]->event.value.value = 0 clockwise or 
                   Event[3]->event.value.value = 1 forcounterclockwise.

    The rest of the arguments are exactly as specified in co$construct_object.
    Except that object, and objid are not allowed.

Sample Call:

co$place_arc_by_center(
                events = EventArray,
                msg = &msg,
                module = &ME.COroot->ModuleInfo,
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &cir_arc,
                display_obj = &DisplayGrid,
                classname = "GR3dcirarc" );

[7m[1mStatus returns[0m

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
[7m[1mCaveats[0m
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/
#omdef co$place_arc_by_center(
                msg,
                events = NULL,
                mode = NULL,
                newflag = (IGRboolean) FALSE,
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
                                                                            
CO_ni_place_arc_cent(
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
                (co_index) )
#endomdef
/* 
co$place_fillet(
                events = NULL,
                .
                .
                .
                the rest of the arguments
                are the same as co$construct_object,
                except for objid, object,
                and geomtry which are not allowed
                .
                .
                . )

Abstract
    This function constructs a bspline representation of a circular arc, then
     constructs and optionally displays a circular arc object.
     If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] tangent point on element 1
        event[1] tangent point on element 2
        event[2] center point
        event[3] radius
        event[4] end of element 1
        event[5] end of element 2
        event[6] trim flag 
                 event.event.value.value = 0 trim neither curve.
                 event.event.value.value = 1 manual trim first curve
                 event.event.value.value = 2 manual trim second curve
                 event.event.value.value = 3 manual trim both curve
                 event.event.value.value = 4 auto trim both curve
                 event.event.value.value = 5 auto trim first curve
                 event.event.value.value = 6 auto trim second curve

Sample Call:

co$place_fillet(
                events = EventArray,
                msg = &msg,
                module = &ModuleInfo[0],
                symbology = &ME.COconst->ActiveDisplay,
                level = ME.COconst->ActiveLevel,
                grid = &cir_arc,
                display_obj = &DisplayGrid,
                classname = "GR3dcirarc",
                objectsgrid = &objects[0] );

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

#omdef co$place_fillet(
                msg,
                events = NULL,
                newflag = (IGRboolean) FALSE,
                mode = NULL,
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
                co_index = NULL,
                mychannelstruct = NULL,
                objectsgrid = NULL )
                                                                            
CO_ni_place_fillet(
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
                (co_index),
                (mychannelstruct),
                (objectsgrid) )
#endomdef

	
#endif /* coplcmacros_include */
