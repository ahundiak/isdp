/*
Name
        plotmacros.h

Description
        This file contains macros used for plotting.

Dependencies
        pidef.h

History
        mrm     04/11/88    creation
                09/12/91    added filter arguments to create_plotfile
*/

#ifndef plotmacros_include

#define plotmacros_include



/*
Macro
        plot$get_window_range

Description
        This macro returns the range of the specifed window in both world
        and view coordinates.  The window may be specified in the event by
        either the window name or a data button.

Synopsis
        IGRlong *msg            O   return code
                                    MSSUCC - success
                                    PI_F_NOWINDOW - failure
                                    PI_F_BADWINDOW - failure
        struct GRevent *event   I   to identify window
        struct GRid *window     O   window id and os
        IGRdouble *world        O   range in world coordinates
        IGRdouble *view         O   range in view coordinates
*/

#omdef  plot$get_window_range (msg, event, window, world, view)

        COplot_get_window_range ((msg), (event), (window), (world), (view))
#endomdef


/*
Macro
        plot$get_fence_range

Description
        This macro returns the range of the active fence in view and world
        coordinates.

Notes
        The cvprism pointer is set to point to memory allocated in this
        macro using om$malloc.  It is the caller's responsibility to free
        this memory with om$dealloc.

Synopsis
        IGRlong *msg                    O   return code
                                            MSSUCC - success
                                            MSFAIL - failure
        struct GRmd_env *module         I   current module information
        struct GRid *fence              O   fence id and os
        struct GRid *window             O   id and os associated with the fence
        IGRdouble *world                O   range in world coordinates
        IGRdouble *view                 O   range in view coordinates
        struct IGRcv_prism **cvprism    O   prism corresponding to the fence
*/

#omdef  plot$get_fence_range (msg, module, fence, window, world, view, cvprism)

        COget_fence_range ((msg), (module), (fence), (window),
                           (world), (view), (cvprism))
#endomdef


/*
Macro
        plot$create_plotfile

Description
        This macro produces a plotfile containing elements visible in
        the specified range.

Synopsis
        IGRlong *msg                O  return code
                                       MSSUCC - successful
                                       MSINARG - invalid filetype
                                       GUREAD_ERROR - cannot create plot file
                                       GUNOFILE - cannot open plot file
                                       GUNOSEEDFILE - cannot open seedfile
                                       GUWRITE_ERROR - cannot create plot file
                                       GUELEMENT_OVERFLOW - integer overflow;
                                         elements skipped
                                       GUVIEW_OVERFLOW - integer overflow;
                                         view not converted
        IGRint filetype             I  PI_IGDS_FILE - see pidef.h
        struct GRmd_env *mod        I  current module information
        IGRchar *dbtype             I  current database type (usually "3d")
        IGRdouble *range            I  range to plot - a 12-element array
                                         containing the range in both world and
                                         view coordinates (world first)
        struct GRid *window         I  window associated with plot
        struct IGRcv_prism *cvprism I  prism associated with a fence; send
                                         NULL when using a window
        IGRchar *filename           I  name for plotfile
        IGRchar *seedfile           I  plotting seedfile to use (IGDS only);
                                         the default seedfile will be used if
                                         the pointer is NULL or points to a
                                         NULL string
        IGRchar *color_table        I  color table file to insert (IGDS only);
                                         the default seedfile will be used if
                                         the pointer is NULL or points to a
                                         NULL string
        IGRint flood_index          I  obselete argument
        IGRint (*filter_function)() I  pointer to a function which will
                                       be called prior to placing each element
                                       in the plotfile (see Notes)
        IGRchar *filter_data        I  pointer to data to be passed to the
                                       filter function
        IGRchar *status             O  string suitable for displaying to the
                                         user to indicate degree of success

Notes
        The arguments filter_function and filter_data may be used to
        decide whether each graphic object should be placed in the
        plotfile.  The function will be called to verify each object,
        with its return value determining to proceed with plotting the
        object.  The function will be called with the following argument
        list:

            IGRint filter_function(object, mod, props, sym, filter_data)
            struct GRid *object;        Object id and space number
            struct GRmd_env *mod;       Object module information
            IGRshort props;             GRgraphics->properties
            struct GRsymbology *sym;    Object display and level info
            IGRchar *filter_data;       Caller-supplied pointer

        The function should return one of the following codes (defined
        in transdef.h):

            GU_PROCESS_ELEMENT  Place the element in the plotfile
            GU_SKIP_ELEMENT     Do not place the element in the plotfile
            GU_TERMINATE_PLOT   Used to signal a fatal error that should
                                result in the termination of the create
                                plotfile process.
*/

#omdef  plot$create_plotfile(msg,
                             filetype = PI_IGDS_FILE,
                             module, 
                             dbtype,
                             range,
                             window,
                             cvprism = NULL,
                             plotfile,
                             seedfile = NULL,
                             color_table = NULL,
                             flood_index = -1,
                             filter_function = NULL,
                             filter_data = NULL,
                             status = NULL)

        COcreate_plotfile((msg), (filetype), (module), (dbtype), (range),
                          (window), (cvprism), (plotfile), (seedfile),
                          (color_table), (flood_index), (filter_function),
                          (filter_data), (status))
#endomdef

#endif /* plotmacros_include */
