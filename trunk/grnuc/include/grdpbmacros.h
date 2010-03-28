/*
Name
        grdpbmacros.h

Description
        This file contains macros used to communicate with the Default
        Parameter Block (DPB). 

Synopsis
        Most macros have only one argument, buffer, which must be
        specified. It should point to the data structure to be
        retrieved from / deposited to the DPB, depending on whether a
        'get'  or 'put' was requested.  All other values may be
        defaulted to NULL.  Note that, if specified, sizbuf must be a
        pointer.  The type of data structure expected is specified in
        the comments with each macro definition.

        Retrieval macros:

        IGRint gr$get...()  <   TRUE/FALSE
        IGRint *msg         <   MSSUCC/MSFAIL
        IGRint *sizbuf      >   size (in bytes) of the input buffer
        IGRchar *buffer     <   the requested value
        IGRint *nret        <   number of bytes written into buffer
                                (if specified, sizbuf must also be
                                specified)

        Depositing macros:

        IGRint gr$put...()  <   TRUE/FALSE
        IGRint *msg         <   MSSUCC/MSFAIL
        IGRint *sizbuf      >   size (in bytes) of the input buffer
        IGRchar *buffer     >   the value to be deposited in the DPB

Dependencies
        grnuc/include/grdpbdef.h
        grnuc/proto_include/GRdpbfunc.h
        grnuc/proto_include/GRsetinq.h
History
        pth     09/08/87    creation
        mrm     05/01/91    allow defaults on unnecessary arguments
        scw     08/02/91    added macros for auto accept
        scw     08/06/91    added macros for change acs type flag
        scw     02/02/92    added macros for reference plane lock
*/

#ifndef grdpbmacros_include
#define grdpbmacros_include



/* 
    chord height tolerance - IGRdouble

    This tolerance is mainly used for surface type intersections.
    Note that the tolerance is specified in database units, NOT user units.
*/

#omdef gr$get_chord_height_tolerance(msg = NULL,
                                     sizbuf = NULL,
                                     buffer,
                                     nret = NULL)

       GRdpb_get(msg, grdpb_chord_height_tolerance, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_chord_height_tolerance(msg = NULL,
                                     sizbuf = NULL,
                                     buffer)

       GRdpb_put(msg, grdpb_chord_height_tolerance, sizbuf, buffer)

#endomdef


/*
     active angle in radians - IGRdouble
*/

#omdef gr$get_active_angle(msg = NULL,
                           sizbuf = NULL,
                           buffer,
                           nret = NULL)

       GRdpb_get(msg, grdpb_active_angle, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_angle(msg = NULL,
                           sizbuf = NULL,
                           buffer)

       GRdpb_put(msg, grdpb_active_angle, sizbuf, buffer)

#endomdef

/*
    offset tolerance - IGRdouble

    This tolerance is used when an offset curve/surface is performed.
    Note that the tolerance is specified in database units, NOT user units.
*/

#omdef gr$get_offset_tolerance(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_offset_tolerance, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_offset_tolerance(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_offset_tolerance, sizbuf, buffer)

#endomdef

/*
    crosshatch spacing - IGRdouble
*/

#omdef gr$get_xhatch_spacing(msg = NULL,
                             sizbuf = NULL,
                             buffer,
                             nret = NULL)

       GRdpb_get(msg, grdpb_xhatch_spacing, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_xhatch_spacing(msg = NULL,
                             sizbuf = NULL,
                             buffer)

       GRdpb_put(msg, grdpb_xhatch_spacing, sizbuf, buffer)

#endomdef

/*
    crosshatch angle - IGRdouble
*/

#omdef gr$get_xhatch_angle(msg = NULL,
                             sizbuf = NULL,
                             buffer,
                             nret = NULL)

       GRdpb_get(msg, grdpb_xhatch_angle, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_xhatch_angle(msg = NULL,
                             sizbuf = NULL,
                             buffer)

       GRdpb_put(msg, grdpb_xhatch_angle, sizbuf, buffer)

#endomdef

/*
    arclength tolerance - IGRdouble

    This tolerance is used when creating equally spaced points
    along an element or when the computing arclength of a curve.
    Note that the tolerance is specified in database units, NOT user units.
*/

#omdef gr$get_arclength_tolerance(msg = NULL,
                                  sizbuf = NULL,
                                  buffer,
                                  nret = NULL)

       GRdpb_get(msg, grdpb_arclength_tolerance, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_arclength_tolerance(msg = NULL,
                                  sizbuf = NULL,
                                  buffer)

       GRdpb_put(msg, grdpb_arclength_tolerance, sizbuf, buffer)

#endomdef

/*
    basis tolerance - IGRdouble

    This tolerance defines when two points are close enough to be
    considered identical.  It affects a lot of internal tolerances such
    as cross product, dot product, and parametric tolerances.  BE
    EXTREMELY CAREFUL ABOUT CHANGING THIS TOLERANCE AS IT AFFECTS THE
    ENTIRE SYSTEM GREATLY! Note that the tolerance is specified in
    database units, NOT user units. 
*/

#omdef gr$get_basis_tolerance(msg = NULL,
                              sizbuf = NULL,
                              buffer,
                              nret = NULL)

       GRdpb_get(msg, grdpb_basis_tolerance, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_basis_tolerance(msg = NULL,
                              sizbuf = NULL,
                              buffer)

       GRdpb_put(msg, grdpb_basis_tolerance, sizbuf, buffer)

#endomdef

/*
    maximum step size - IGRdouble

    This tolerance defines the maximum step size that can occur during
    the intersection process. 
    Note that the tolerance is specified in database units, NOT user units.
*/

#omdef gr$get_maximum_step_size(msg = NULL,
                                sizbuf = NULL,
                                buffer,
                                nret = NULL)

       GRdpb_get(msg, grdpb_maximum_step_size, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_maximum_step_size(msg = NULL,
                                sizbuf = NULL,
                                buffer)

       GRdpb_put(msg, grdpb_maximum_step_size, sizbuf, buffer)

#endomdef

/*
    edge pattern delta - IGRdouble
*/

#omdef gr$get_patrn_edge_delta(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_patrn_edge_delta, sizbuf, buffer, nret)
#endomdef

#omdef gr$put_patrn_edge_delta(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_patrn_edge_delta, sizbuf, buffer)

#endomdef

/* 
    area pattern delta - struct Patrn_area_deltas
*/

#omdef gr$get_patrn_area_deltas(msg = NULL,
                                sizbuf = NULL,
                                buffer,
                                nret = NULL)

       GRdpb_get(msg, grdpb_patrn_area_deltas, sizbuf, buffer, nret)
#endomdef

#omdef gr$put_patrn_area_deltas(msg = NULL,
                                sizbuf = NULL,
                                buffer)

       GRdpb_put(msg, grdpb_patrn_area_deltas, sizbuf, buffer)

#endomdef


/*
    unit lock - struct GRunit_lock
*/

#omdef gr$get_unit_lock(msg = NULL,
                        sizbuf = NULL,
                        buffer,
                        nret = NULL)

       GRdpb_get(msg, grdpb_unit_lock, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_unit_lock(msg = NULL,
                        sizbuf = NULL,
                        buffer)

       GRdpb_put(msg, grdpb_unit_lock, sizbuf, buffer)

#endomdef

/*
    raster info - struct GRrgdpb
*/

#omdef gr$get_raster_graphics(msg = NULL,
                              sizbuf = NULL,
                              buffer,
                              nret = NULL)

       GRdpb_get(msg, grdpb_raster_graphics, sizbuf, buffer, nret)
#endomdef

#omdef gr$put_raster_graphics(msg = NULL,
                              sizbuf = NULL,
                              buffer)

       GRdpb_put(msg, grdpb_raster_graphics, sizbuf, buffer)

#endomdef


/*
    hidden surface symbology - IGRlong
*/

#omdef gr$get_hidden_surf_sym(msg = NULL,
                              sizbuf = NULL,
                              buffer,
                              nret = NULL)

       GRdpb_get(msg, grdpb_hidden_surf_sym, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_hidden_surf_sym(msg = NULL,
                              sizbuf = NULL,
                              buffer),

       GRdpb_put(msg, grdpb_hidden_surf_sym, sizbuf, buffer)

#endomdef

/*
    locate levels - IGRlong[32]
*/

#omdef gr$get_locate_levels(msg = NULL,
                            sizbuf = NULL,
                            buffer,
                            nret = NULL)

       GRdpb_get(msg, grdpb_locate_levels, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_locate_levels(msg = NULL,
                            sizbuf = NULL,
                            buffer)

       GRdpb_put(msg, grdpb_locate_levels, sizbuf, buffer)

#endomdef

/*
    locate properties - IGRlong
*/

#omdef gr$get_locate_properties(msg = NULL,
                                sizbuf = NULL,
                                buffer,
                                nret = NULL)

       GRdpb_get(msg, grdpb_locate_properties, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_locate_properties(msg = NULL,
                                sizbuf = NULL,
                                buffer)

       GRdpb_put(msg, grdpb_locate_properties, sizbuf, buffer)

#endomdef

/* 
    active display - struct IGRdisplay
*/

#omdef gr$get_active_display(msg = NULL,
                             sizbuf = NULL,
                             buffer,
                             nret = NULL)

       GRdpb_get(msg, grdpb_active_display, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_display(msg = NULL,
                             sizbuf = NULL,
                             buffer)

       GRdpb_put(msg, grdpb_active_display, sizbuf, buffer)

#endomdef

/*
    model mode - IGRchar
*/

#omdef gr$get_model_mode(msg = NULL,
                         sizbuf = NULL,
                         buffer,
                         nret = NULL)

       GRdpb_get(msg, grdpb_model_mode, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_model_mode(msg = NULL,
                         sizbuf = NULL,
                         buffer)

       GRdpb_put(msg, grdpb_model_mode, sizbuf, buffer)

#endomdef

/*
    projection angle - IGRchar
*/

#omdef gr$get_projection_angle(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_projection_angle, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_projection_angle(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_projection_angle, sizbuf, buffer)

#endomdef

/*
    change active coordinate system type - IGRboolean
*/

#omdef gr$get_change_acs_type(msg = NULL,
                              sizbuf = NULL,
                              buffer,
                              nret = NULL)

       GRdpb_get(msg, grdpb_change_acs_type, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_change_acs_type(msg = NULL,
                              sizbuf = NULL,
                              buffer)

       GRdpb_put(msg, grdpb_change_acs_type, sizbuf, buffer)

#endomdef

/*
    auto accept flag - IGRboolean
*/

#omdef gr$get_auto_accept_flag(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_auto_accept_flag, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_auto_accept_flag(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_auto_accept_flag, sizbuf, buffer)

#endomdef

/*
    associative flag - IGRboolean
*/

#omdef gr$get_associative_flag(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_associative_flag, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_associative_flag(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_associative_flag, sizbuf, buffer)

#endomdef

/*
    dynamics on/off flag - IGRboolean
*/

#omdef gr$get_dynamics_on(msg = NULL,
                          sizbuf = NULL,
                          buffer,
                          nret = NULL)

       GRdpb_get(msg, grdpb_dynamics_on, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_dynamics_on(msg = NULL,
                          sizbuf = NULL,
                          buffer)

       GRdpb_put(msg, grdpb_dynamics_on, sizbuf, buffer)

#endomdef

/*
    dynamics in all/one window[s] - IGRboolean
*/

#omdef gr$get_dynamics_all_windows(msg = NULL,
                                   sizbuf = NULL,
                                   buffer,
                                   nret = NULL)

       GRdpb_get(msg, grdpb_dynamics_all_windows, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_dynamics_all_windows(msg = NULL,
                                   sizbuf = NULL,
                                   buffer)

       GRdpb_put(msg, grdpb_dynamics_all_windows, sizbuf, buffer)

#endomdef

/*
    dynamics copy flag - IGRboolean

    This flag indicates whether dynamics involving an existing element
    in the file should create a copy to manipulate or operate on the
    existing element by modifying the display matrix.
*/

#omdef gr$get_dynamics_copy_flag(msg = NULL,
                                 sizbuf = NULL,
                                 buffer,
                                 nret = NULL)

       GRdpb_get(msg, grdpb_dynamics_copy_flag, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_dynamics_copy_flag(msg = NULL,
                                 sizbuf = NULL,
                                 buffer)

       GRdpb_put(msg, grdpb_dynamics_copy_flag, sizbuf, buffer)

#endomdef

/*
    local/absolute measurement - IGRboolean
*/

#omdef gr$get_local_abs_flag(msg = NULL,
                             sizbuf = NULL,
                             buffer,
                             nret = NULL)

       GRdpb_get(msg, grdpb_local_abs, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_local_abs_flag(msg = NULL,
                             sizbuf = NULL,
                             buffer)

       GRdpb_put(msg, grdpb_local_abs, sizbuf, buffer)

#endomdef

/*
    active scale -  struct GRdpb_scale
*/

#omdef gr$get_active_scale(msg = NULL,
                           sizbuf = NULL,
                           buffer,
                           nret = NULL)

       GRdpb_get(msg, grdpb_active_scale, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_scale(msg = NULL,
                           sizbuf = NULL,
                           buffer)

       GRdpb_put(msg, grdpb_active_scale, sizbuf, buffer)

#endomdef

/*
    active properties - unsigned short
*/

#omdef gr$get_active_prop(msg = NULL,
                          sizbuf = NULL,
                          buffer,
                          nret = NULL)

       GRdpb_get(msg, grdpb_active_prop, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_prop(msg = NULL,
                          sizbuf = NULL,
                          buffer)

       GRdpb_put(msg, grdpb_active_prop, sizbuf, buffer)

#endomdef

/*
    arc direction (TRUE for ccw, FALSE for cw) - IGRboolean
*/

#omdef gr$get_arc_direction(msg = NULL,
                            sizbuf = NULL,
                            buffer,
                            nret = NULL)

       GRdpb_get(msg, grdpb_arc_direction, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_arc_direction(msg = NULL,
                            sizbuf = NULL,
                            buffer)

       GRdpb_put(msg, grdpb_arc_direction, sizbuf, buffer)

#endomdef

/*
    apparent/true mode - IGRboolean

    This flag is used to determine whether intersections must be true
    or apparent.
*/

#omdef gr$get_apparent_flag(msg = NULL,
                            sizbuf = NULL,
                            buffer,
                            nret = NULL)

       GRdpb_get(msg, grdpb_apparent_flag, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_apparent_flag(msg = NULL,
                            sizbuf = NULL,
                            buffer)

       GRdpb_put(msg, grdpb_apparent_flag, sizbuf, buffer)

#endomdef

/*
    radius - IGRdouble
*/

#omdef gr$get_active_radius(msg = NULL,
                            sizbuf = NULL,
                            buffer,
                            nret = NULL)

       GRdpb_get(msg, grdpb_active_radius, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_radius(msg = NULL,
                            sizbuf = NULL,
                            buffer)

       GRdpb_put(msg, grdpb_active_radius, sizbuf, buffer)

#endomdef

/*
    database type - char[]
*/

#omdef gr$get_database_type(msg = NULL,
                            sizbuf = NULL,
                            buffer,
                            nret = NULL)

       GRdpb_get(msg, grdpb_database_type, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_database_type(msg = NULL,
                            sizbuf = NULL,
                            buffer)

       GRdpb_put(msg, grdpb_database_type, sizbuf, buffer)

#endomdef

/* 
    text symbology - struct GRdpb_text_symb
*/

#omdef gr$get_text_symb(msg = NULL,
                        sizbuf = NULL,
                        buffer,
                        nret = NULL)

       GRdpb_get(msg, grdpb_text_symb, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_text_symb(msg = NULL,
                        sizbuf = NULL,
                        buffer)

       GRdpb_put(msg, grdpb_text_symb, sizbuf, buffer)

#endomdef

/* 
    coordinate system type - IGRchar[MAX_CS_TYPE]
*/

#omdef gr$get_cs_type(msg = NULL,
                      sizbuf = NULL,
                      buffer,
                      nret = NULL)

       GRdpb_get(msg, grdpb_active_cs_type, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_cs_type(msg = NULL,
                      sizbuf = NULL,
                      buffer)

       GRdpb_put(msg, grdpb_active_cs_type, sizbuf, buffer)

#endomdef

/*
    layer (level) - IGRshort
*/

#omdef gr$get_active_layer(msg = NULL,
                           sizbuf = NULL,
                           buffer,
                           nret = NULL)

       GRdpb_get(msg, grdpb_active_level, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_layer(msg = NULL,
                           sizbuf = NULL,
                           buffer)

       GRdpb_put(msg, grdpb_active_level, sizbuf, buffer)

#endomdef

#omdef gr$get_active_level(msg = NULL,
                           sizbuf = NULL,
                           buffer,
                           nret = NULL)

       GRdpb_get(msg, grdpb_active_level, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_active_level(msg = NULL,
                           sizbuf = NULL,
                           buffer)

       GRdpb_put(msg, grdpb_active_level, sizbuf, buffer)

#endomdef

/*
    boreline/point locate - IGRboolean
*/

#omdef gr$get_bore_locate(msg = NULL,
                          sizbuf = NULL,
                          buffer,
                          nret = NULL)

       GRdpb_get(msg, grdpb_bore_locate, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_bore_locate(msg = NULL,
                          sizbuf = NULL,
                          buffer)

       GRdpb_put(msg, grdpb_bore_locate, sizbuf, buffer)

#endomdef

/*
    dit tolerance for locate - IGRdouble
*/

#omdef gr$get_dit_tolerance(msg = NULL,
                            sizbuf = NULL,
                            buffer,
                            nret = NULL)

       GRdpb_get(msg, grdpb_dit_tolerance, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_dit_tolerance(msg = NULL,
                            sizbuf = NULL,
                            buffer)

       GRdpb_put(msg, grdpb_dit_tolerance, sizbuf, buffer)

#endomdef

/*
    last data point entered - struct EX_button
*/

#omdef gr$get_last_point(msg = NULL,
                         sizbuf = NULL,
                         buffer,
                         nret = NULL)

       GRdpb_get(msg, grdpb_last_point, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_last_point(msg = NULL,
                         sizbuf = NULL,
                         buffer)

       GRdpb_put(msg, grdpb_last_point, sizbuf, buffer)

#endomdef

/*
    construction environment - struct GRmd_env

    point is pointer to a struct EX_button, other arguments may be ignored.
*/

#omdef gr$get_construct_env(msg,
                            point,
                            sizbuf,
                            buffer,
                            nret)

       GRgetactenv(msg,point,sizbuf,buffer,nret)

#endomdef

/*
    master file module environment - struct GRmd_env
*/

#omdef gr$get_module_env(msg = NULL,
                         sizbuf = NULL,
                         buffer,
                         nret = NULL)

       GRdpb_get(msg, grdpb_module_env, sizbuf, buffer, nret)

#endomdef

/*
    model environment - struct GRmd_env
*/

#omdef gr$get_model_env(msg = NULL,
                        sizbuf = NULL,
                        buffer,
                        nret = NULL)

       GRdpb_get(msg, grdpb_model_env, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_model_env(msg = NULL,
                        sizbuf = NULL,
                        buffer)

       GRdpb_put(msg, grdpb_model_env, sizbuf, buffer)

#endomdef

/*
    locate environment (obsolete) - struct GRmd_env
*/

#omdef gr$get_locate_env(msg = NULL,
                         sizbuf = NULL,
                         buffer,
                         nret = NULL)

       GRdpb_get(msg, grdpb_locate_env, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_locate_env(msg = NULL,
                         sizbuf = NULL,
                         buffer)

       GRdpb_put(msg, grdpb_locate_env, sizbuf, buffer)

#endomdef

/*
    display environment (obsolete) - struct GRmd_env
*/

#omdef gr$get_display_env(msg = NULL,
                         sizbuf = NULL,
                         buffer,
                         nret = NULL)

       GRdpb_get(msg, grdpb_display_env, sizbuf, buffer, nret)

#endomdef

/*  
    name mode - IGRboolean
*/

#omdef gr$get_name_mode(msg = NULL,
                        sizbuf = NULL,
                        buffer,
                        nret = NULL)

       GRdpb_get(msg, grdpb_name_mode, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_name_mode(msg = NULL,
                        sizbuf = NULL,
                        buffer)

       GRdpb_put(msg, grdpb_name_mode, sizbuf, buffer)

#endomdef

/*  
    hidden edge symbology override data - struct GRhesym
*/

#omdef gr$get_hidden_edge_sym(msg = NULL,
                              sizbuf = NULL,
                              buffer,
                              nret = NULL)

       GRdpb_get(msg, grdpb_hesym, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_hidden_edge_sym(msg = NULL,
                              sizbuf = NULL,
                              buffer)

       GRdpb_put(msg, grdpb_hesym, sizbuf, buffer)

#endomdef

/*  
    visible edge symbology override data - struct GRhesym
*/

#omdef gr$get_visible_edge_sym(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_visible_edge_sym, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_visible_edge_sym(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_visible_edge_sym, sizbuf, buffer)

#endomdef

/*
Name
        gr$set_inq

Description
        This macro provides an interface to the DPB for class locate
        eligibility information.

Synopsis
        IGRint *msg                 <   Return code
        struct var_list *var_list   ><  Array of data structures; the
                                        var field indicates what type
                                        of structure the var_ptr points
                                        to.  Legal var values are
                                        specified in grdpbdef.h.  The
                                        num_bytes and bytes_returned
                                        fields are ignored.
        IGRint set_inq              >   DPB_INQ => inquire from dpb;
                                        DPB_SET => change dpb value
*/

#omdef gr$set_inq(msg,
                  var_list,
                  set_inq = DPB_INQ)
                   
       GRsetinq((msg), (var_list), (set_inq))

#endomdef

/*  
    display of invisible symbology overrides on/off flag - IGRboolean
*/

#omdef gr$get_invis_so_on(msg = NULL,
                          sizbuf = NULL,
                          buffer,
                          nret = NULL)

       GRdpb_get(msg, grdpb_invis_so_on, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_invis_so_on(msg = NULL,
                          sizbuf = NULL,
                          buffer)

       GRdpb_put(msg, grdpb_invis_so_on, sizbuf, buffer)

#endomdef

/*  
    display of hidden symbology overrides on/off flag - IGRboolean
*/

#omdef gr$get_hidden_so_on(msg = NULL,
                           sizbuf = NULL,
                           buffer,
                           nret = NULL)

       GRdpb_get(msg, grdpb_hidden_so_on, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_hidden_so_on(msg = NULL,
                           sizbuf = NULL,
                           buffer)

       GRdpb_put(msg, grdpb_hidden_so_on, sizbuf, buffer)

#endomdef


/*
    change model reference plane lock flag - IGRboolean
*/

#omdef gr$get_mrp_lock(msg = NULL,
                       sizbuf = NULL,
                       buffer,
                       nret = NULL)

       GRdpb_get(msg, grdpb_mrp_lock, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_mrp_lock(msg = NULL,
                       sizbuf = NULL,
                       buffer)

       GRdpb_put(msg, grdpb_mrp_lock, sizbuf, buffer)

#endomdef

/*
 * Smart Sketch ON/OFF
 */
#omdef gr$get_ss_lock(msg = NULL,
                      sizbuf = NULL,
                      buffer,
                      nret = NULL)

       GRdpb_get(msg, grdpb_smart_sketch_on, sizbuf, buffer, nret)
#endomdef

#omdef gr$put_ss_lock(msg = NULL,
                       sizbuf = NULL,
                       buffer)

       GRdpb_put(msg, grdpb_smart_sketch_on, sizbuf, buffer)
#endomdef

/*
 * Elligible Smart Sketch constraints
 */
#omdef gr$get_ss_constraints(msg = NULL,
                             sizbuf = NULL,
                             buffer,
                             nret = NULL)

       GRdpb_get(msg, grdpb_smart_sketch_constraints, sizbuf, buffer, nret)
#endomdef

#omdef gr$put_ss_constraints(msg = NULL,
                             sizbuf = NULL,
                             buffer)

       GRdpb_put(msg, grdpb_smart_sketch_constraints, sizbuf, buffer)
#endomdef

/*
    TRUE if the necessary elements should be created so that the file can
    be used as an associative read-only reference file, FALSE otherwise;
    buffer => IGRboolean
*/

#omdef gr$get_assoc_ro_reffile(msg = NULL,
                               sizbuf = NULL,
                               buffer,
                               nret = NULL)

       GRdpb_get(msg, grdpb_assoc_read_only_reffile, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_assoc_ro_reffile(msg = NULL,
                               sizbuf = NULL,
                               buffer)

       GRdpb_put(msg, grdpb_assoc_read_only_reffile, sizbuf, buffer)

#endomdef

/*
     TRUE if the reference files are shrink/wrapped, FALSE otherwise.
*/

#omdef gr$get_reffile_shrink_wrap(msg = NULL,
                                  sizbuf = NULL,
                                  buffer,
                                  nret = NULL)

       GRdpb_get(msg, grdpb_ref_shrink_wrap_flag, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_reffile_shrink_wrap(msg = NULL,
                                  sizbuf = NULL,
                                  buffer)

       GRdpb_put(msg, grdpb_ref_shrink_wrap_flag, sizbuf, buffer)

#endomdef

/*
     TRUE if the reference files are attached background (nesting off),
     FASLE otherwise.
*/

#omdef gr$get_reffile_background(msg = NULL,
                                 sizbuf = NULL,
                                 buffer,
                                 nret = NULL)

       GRdpb_get(msg, grdpb_ref_background_flag, sizbuf, buffer, nret)

#endomdef

#omdef gr$put_reffile_background(msg = NULL,
                                 sizbuf = NULL,
                                 buffer)

       GRdpb_put(msg, grdpb_ref_background_flag, sizbuf, buffer)

#endomdef

#endif
