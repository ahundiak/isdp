/*
Name
        comnmacros.h
        
Description
        This file contains macros used by the I/DRAFT generic manipulation
        commands.  These macros may be used to duplicate or simulate the
        behavior of the manipulation commands.

Return Values
        IGRint ()       TRUE - success
                        FALSE - failure
        IGRlong *msg    MSSUCC - success
                        MSFAIL - failure
                        some macros may return other values in this field;
                        these will be specified in the macro header
History
        mrm     08/18/88    creation
*/

#ifndef comnmacros_include

#define comnmacros_include

#include "gr.h"
#include "comn.h"


/* 
Macro
        co$move_mx

Description
        This macro builds a matrix for translation from the point
        in events[0] to the point in events[1].

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - from point
                                       [1] - destination point
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$move_mx (msg,
                   caller_id = my_id,
                   caller_os = OM_Gw_current_OS,
                   events,
                   matrix)

       COmn_move ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$align_mx

Description
        This macro builds a matrix to move and rotate an element
        through space from a reference position and orientation to a new
        position and orientation.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - origin of first orientation
                                       [1] - 2nd pt defining 1st orientation
                                       [2] - 3rd pt defining 1st orientation
                                       [3] - origin of 2nd orientation
                                       [4] - 2nd pt defining 2nd orientation
                                       [5] - 3rd pt defining 2nd orientation
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$align_mx (msg,
                    caller_id = my_id,
                    caller_os = OM_Gw_current_OS,
                    events,
                    matrix)

       COmn_align ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$mirrorv_mx

Description
        This macro builds a matrix to reflect objects about a vertical
        line (actually a plane extending out of and into the view).  The
        macro assumes that the first event contains a valid data point
        and window info.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - pt defining reflection line (plane)
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$mirrorv_mx (msg,
                      caller_id = my_id,
                      caller_os = OM_Gw_current_OS,
                      events,
                      matrix)

       COmn_mirrorv ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$mirrorh_mx

Description
        This macro builds a matrix to reflect objects about a horizontal
        line (actually a plane extending out of and into the view).  The
        macro assumes that the first event contains a valid data point
        and window info.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - pt defining reflection line (plane)
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$mirrorh_mx (msg,
                      caller_id = my_id,
                      caller_os = OM_Gw_current_OS,
                      events,
                      matrix)

       COmn_mirrorh ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$mirrorl_mx

Description
        This macro builds a matrix to reflect objects about a line in
        space (actually a plane extending out of and into the view).  The
        second event is used to determine the plane of the view and the
        plane of the reflection.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - first point of mirror line
                                       [1] - second point of mirror line
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$mirrorl_mx (msg,
                      caller_id = my_id,
                      caller_os = OM_Gw_current_OS,
                      events,
                      matrix)

       COmn_mirrorl ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$rotate_aa_mx

Description
        This macro builds a rotation matrix to rotate at the active
        angle about the point in events[0], with the rotation taking
        place in the plane of the view in which the point was entered.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - point to rotate about; use plane
                                             of view in which the point was
                                             entered
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$rotate_aa_mx (msg,
                        caller_id = my_id,
                        caller_os = OM_Gw_current_OS,
                        events,
                        matrix)

       COmn_rotate_aa ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$rotate_ax_mx

Description
        This macro builds a matrix which will rotate objects about
        the axis in space specified by the points in events[0] and [1].

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - point one of axis to rotate about
                                       [1] - point two of axis to rotate about
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$rotate_ax_mx (msg,
                        caller_id = my_id,
                        caller_os = OM_Gw_current_OS,
                        events,
                        matrix)

       COmn_rotate_ax ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$rotate_3pts_mx

Description
        This macro builds a matrix which defines a rotation by the
        angle between the vectors events[0]->events[1] and
        events[0]->events[2].  The rotation takes place in the plane
        derived from the view of events[0].

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - origin of rotation
                                       [1] - defines first vector
                                       [2] - defines second vector
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$rotate_3pts_mx (msg,
                          caller_id = my_id,
                          caller_os = OM_Gw_current_OS,
                          events,
                          matrix)

       COmn_rotate_3pts ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$scale_as_mx

Description
        This macro builds a matrix for scaling at the active scale.  The
        point in events[0] is assumed to contain valid window information.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - origin of scale
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$scale_as_mx (msg,
                       caller_id = my_id,
                       caller_os = OM_Gw_current_OS,
                       events,
                       matrix)

       COmn_scale_as ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$scale_3pts_mx

Description
        This macro builds a matrix which scales by the ratio of the
        vectors from events[0] (origin) -> events[1] (reference point 1)
        and events[0] -> events[2] (reference point 2).  The scale takes
        place in the plane of the view of the origin.

Synopsis
        IGRlong        *msg;        o  return code
        OM_S_OBJID      caller_id;  i  calling object id
        OMuword         caller_os;  i  calling object osnum
        struct GRevent *events[];   i  array of pointers to events;
                                       [0] - origin
                                       [1] - reference point 1
                                       [2] - reference point 2
        IGRdouble      *matrix;     o  transformation matrix
*/

#omdef co$scale_3pts_mx (msg,
                         caller_id = my_id,
                         caller_os = OM_Gw_current_OS,
                         events,
                         matrix)

       COmn_scale_3pts ((msg), (caller_id), (caller_os), (events), (matrix))

#endomdef


/*
Macro
        co$cptform

Description
        This macro erases, copies, transforms, and highlights graphic objects.
        The function assumes that all operations are to be performed through
        a graphic set channel.  The resulting copy will reside in the module
        environment of the last point from the dpb.

Synopsis
        IGRlong         *msg;           o  return code
        struct GRmd_env *module;        i  current module environment
        IGRdouble       *matrix;        i  matrix to apply to graphic object
        GRobjid          caller_id;     i  calling object's id
        OMuword          caller_os;     i  calling object's osnum
        OM_S_CHANSELECT *gschan;        i  channel the graphic set is on
*/

#omdef co$cptform (msg,
                   module,
                   matrix,
                   caller_id = my_id,
                   caller_os = OM_Gw_current_OS,
                   gschan)

       COcptform ((msg), (module), (matrix), (caller_id), (caller_os), 
                  (gschan))

#endomdef


/*
Macro
        co$tform

Description
        This macro erases, transforms, and highlights graphic object(s).
        The macro assumes that all operations are to be performed through a
        graphic set channel.

Synopsis
        IGRlong         *msg;           o  return code
        struct GRid     *module;        i  current module environment
        IGRdouble       *matrix;        i  matrix to apply to graphic object
        GRobjid          caller_id;     i  calling object's id
        OMuword          caller_os;     i  calling object's osnum
        OM_S_CHANSELECT *gschan;        i  channel the graphic set is on
*/

#omdef co$tform (msg,
                 module,
                 matrix,
                 caller_id = my_id,
                 caller_os = OM_Gw_current_OS,
                 gschan)

       COtform ((msg), (module), (matrix), (caller_id), (caller_os), (gschan))

#endomdef


/*
Macro
        co$delete

Description
        This macro passes the located object(s) to the Undo object, which
        either deletes or saves the object(s), depending on whether undelete
        is on or off.  The object(s) should be erased prior to calling this
        macro.

Synopsis
        IGRlong         *msg;       o  return code
        OM_S_OBJID       caller_id  i  calling object's id
        OMuword          caller_os  i  calling object's id
        struct GRmd_env *module     i  current module information
        struct GRevent  *events[]   i  array of pointers to events
                                       [0] - locate event; unused
                                       [1] - accept event; unused
                                       [2] - gr$gslocate argument locate_event
        OM_S_CHANSELECT *gschan     i  channel pointing to object(s) to
                                       work with
*/

#omdef co$delete (msg,
                  caller_id = my_id,
                  caller_os = OM_Gw_current_OS,
                  module,
                  events,
                  gschan)

       COch_delete ((msg), (caller_id), (caller_os), (module), (events),
                    (gschan))

#endomdef


/*
Macro
        co$undelete

Description
        This macro invokes the undo method on the undo manager.

Synopsis
        IGRlong         *msg;       o  return code
                                       MSSUCC - object undeleted
                                       MSFAIL - cannot undelete object
                                       GR_F_UndelOff - undelete off
                                       GR_F_NothUndel - nothing to undelete
        OM_S_OBJID       caller_id  i  calling object's id
        OMuword          caller_os  i  calling object's id
        struct GRmd_env *module     i  current module information
*/

#omdef co$undelete (msg,
                    caller_id = my_id,
                    caller_os = OM_Gw_current_OS,
                    module)

       COch_undelete ((msg), (caller_id), (caller_os), (module),
                      (NULL), (NULL))

#endomdef


/*
Macro
        co$undel_toggle

Description
        This macro toggles the state of undelete.

Synopsis
        IGRlong         *msg;       o  return code
                                       TRUE - undelete on
                                       FALSE - undelete off
        OM_S_OBJID       caller_id  i  calling object's id
        OMuword          caller_os  i  calling object's id
        struct GRmd_env *module     i  current module information
*/

#omdef co$undel_toggle (msg,
                        caller_id = my_id,
                        caller_os = OM_Gw_current_OS,
                        module)

       COch_undel_toggle ((msg), (caller_id), (caller_os), (module),
                          (NULL), (NULL))

#endomdef


/*
Macro
        co$dymove

Description
        This routine causes the indicated object to go into move, or drag,
        dynamics, i.e. the object will be dragged by the cursor.  According
        to the dpb parameter indicating dynamics type, the routine will
        either create a copy of the indicated object and repeatedly
        transform that copy, or combine the necessary transformation with
        the original object's environment matrix so that the dynamic display
        appears to make the necessary translation.

Notes
        The input arguments gschan and event are used to determine what
        object to drag.  If not NULL, gschan is expected to point to a
        channel containing the results of a call to gr$gslocate.  If gschan
        is NULL, then event is expected to point to an event with the
        information about located_object[0] filled in, such as the
        accept event from lc$locate.

        The temporary copy, or clone, is created in the current module space
        as defined in the dpb.  A NULL_OBJID is placed in the module
        environment structure to indicate to the graphics object methods that
        no R-tree manipulations are to be performed.

Synopsis
        IGRlong            *msg;         o  return code
        GRobjid             caller_id;   i  caller id
        OMuword             caller_os;   i  caller's object space
        struct EX_button   *from_point;  i  move from point
        struct GRmd_env    *module;      i  current module
        OM_S_CHANSELECT    *gschan;      i  channel located containing object
        struct GRevent     *event;       i  containing located object
*/

#omdef co$dymove (msg,
                  caller_id = my_id,
                  caller_os = OM_Gw_current_OS,
                  from_point,
                  module,
                  gschan = NULL ^ event = NULL)

       DYmove ((msg), (caller_id), (caller_os), (from_point), (module),
               (gschan), (event))

#endomdef


/*
Macro
        co$dymirror

Description
        This routine implements dynamics for the mirror vertical and
        horizontal commands. The indicated object will be mirrored about the
        vertical or horizontal axis formed by the cursor location in the
        window.  Bit 4 (from 0) in add_info->flags specifies whether to use
        vertical or horizontal mirroring; set implies vertical.  According to
        the dpb parameter indicating dynamics type, the routine will either
        create a copy of the indicated object and repeatedly transform that
        copy, or combine the necessary transformation with the original
        object's environment matrix so that the dynamic display appears to
        make the necessary transformation.

Notes
        The input add_info arguments gschan and event are used to determine
        what object to drag.  If not NULL, gschan is expected to point to a
        channel containing the results of a call to gr$gslocate.  If gschan
        is NULL, then event is expected to point to an event with the
        information about located_object[0] filled in, such as the
        accept event from lc$locate.

        The temporary copy, or clone, is created in the current module space
        as defined in the dpb.  A NULL_OBJID is placed in the module
        environment structure to indicate to the graphics object methods that
        no R-tree manipulations are to be performed.

Synopsis
        struct GRid       *mirr_object;  i  object to mirror
        struct GRevent    *event;        i  locate event; also has obj info
        struct COmnlcdyn  *add_info;     i  data from command object
*/

#omdef co$dymirror (mirr_object,
                    event,
                    add_info)

       DYmirror ((mirr_object), (event), (add_info))

#endomdef


/*
Macro
        co$dymirrorl

Description
        This routine implements dynamics for the mirror about line command.
        The indicated object will be mirrored about the line formed by the
        input point and the cursor location.  According to the dpb parameter
        indicating dynamics type, the routine will either create a copy of
        the indicated object and repeatedly transform that copy, or combine
        the necessary transformation with the original object's environment
        matrix so that the dynamic display appears to make the necessary
        transformation.

Notes
        The input arguments gschan and event are used to determine what
        object to drag.  If not NULL, gschan is expected to point to a
        channel containing the results of a call to gr$gslocate.  If gschan
        is NULL, then event is expected to point to an event with the
        information about located_object[0] filled in, such as the
        accept event from lc$locate.

        The temporary copy, or clone, is created in the current module space
        as defined in the dpb.  A NULL_OBJID is placed in the module
        environment structure to indicate to the graphics object methods that
        no R-tree manipulations are to be performed.

Synopsis
        IGRlong            *msg;        o   return code
        GRobjid             caller_id;  i   caller id
        OMuword             caller_os;  i   caller's object space
        struct EX_button   *point1;     i   of mirror line
        struct GRmd_env    *module;     i   current module
        OM_S_CHANSELECT    *gschan;     i   channel located containing object
        struct GRevent     *event;      i   containing located object
*/

#omdef co$dymirrorl (msg,
                     caller_id = my_id,
                     caller_os = OM_Gw_current_OS,
                     point1,
                     module,
                     gschan = NULL ^ event = NULL)

       DYmirrorl ((msg), (caller_id), (caller_os), (point1), (module),
                  (gschan), (event))

#endomdef


/*
Macro
        co$dyrotate

Description
        This routine implements dynamics for the Rotate by 3 Points
        command.  The indicated object will be dynamically displayed
        as rotating around the input origin by an angle defined by the
        input handle and the cursor position.

Notes
        The input arguments gschan and event are used to determine what
        object to drag.  If not NULL, gschan is expected to point to a
        channel containing the results of a call to gr$gslocate.  If gschan
        is NULL, then event is expected to point to an event with the
        information about located_object[0] filled in, such as the
        accept event from lc$locate.

        The temporary copy, or clone, is created in the current module space
        as defined in the dpb.  A NULL_OBJID is placed in the module
        environment structure to indicate to the graphics object methods that
        no R-tree manipulations are to be performed.

Synopsis
        IGRlong            *msg;        o   return code
        GRobjid             caller_id;  i   caller id
        OMuword             caller_os;  i   caller's object space
        struct EX_button   *origin;     i   of rotation
        struct EX_button   *handle;     i   used to define angle
        IGRdouble          *radius;     i   length of rb lines; 0 -> calculate
                                            from origin & handle
        struct GRmd_env    *module;     i   current module
        OM_S_CHANSELECT    *gschan;     i   channel located containing object
        struct GRevent     *event;      i   containing located object
*/

#omdef co$dyrotate (msg,
                    caller_id = my_id,
                    caller_os = OM_Gw_current_OS,
                    origin,
                    handle,
                    radius,
                    module,
                    gschan = NULL ^ event = NULL)

       DYrotate ((msg), (caller_id), (caller_os), (origin), (handle),
                 (radius), (module), (gschan), (event))

#endomdef


/*
Macro
        co$dyscale

Description
        This routine implements dynamics for the Scale by 3 Points
        command.  The indicated object will be dynamically displayed
        as being scaled from the input origin by factors determined
        from the reference point and the cursor position.

Notes
        The input arguments gschan and event are used to determine what
        object to drag.  If not NULL, gschan is expected to point to a
        channel containing the results of a call to gr$gslocate.  If gschan
        is NULL, then event is expected to point to an event with the
        information about located_object[0] filled in, such as the
        accept event from lc$locate.

        The temporary copy, or clone, is created in the current module space
        as defined in the dpb.  A NULL_OBJID is placed in the module
        environment structure to indicate to the graphics object methods that
        no R-tree manipulations are to be performed.

Synopsis
        IGRlong            *msg;        o   return code
        GRobjid             caller_id;  i   caller id
        OMuword             caller_os;  i   caller's object space
        struct EX_button   *origin;     i   origin of scale
        struct EX_button   *ref_pt;     i   reference point
        struct GRmd_env    *module;     i   current module
        OM_S_CHANSELECT    *gschan;     i   channel located containing object
        struct GRevent     *event;      i   containing located object
*/

#omdef co$dyscale (msg,
                   caller_id = my_id,
                   caller_os = OM_Gw_current_OS,
                   origin,
                   ref_pt,
                   module,
                   gschan = NULL ^ event = NULL)

       DYscale ((msg), (caller_id), (caller_os), (origin), (ref_pt), (module),
                (gschan), (event))

#endomdef

#endif
