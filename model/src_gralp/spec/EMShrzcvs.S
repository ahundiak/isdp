/* ###################   APOGEE COMPILED   ################## */
class specification EMShrzcvs (2:0) of EMSagrp;

/*
Name

    EMShrzcvs

Abstract

        This class was created to serve as the associative owner of horizon
    curves for a surface with respect to a specific orientation.

History

    05-26-93 : WBC : Creation date.

*/


/*
 Message EMplanar_to_view

 Description

    This message is used to determine if the horizon curves are planar to
    the specified view or z-vector.

 Arguments

    Type                   Name          I/O          Description
    ---------------------- ------------- --- -------------------------------
    IGRlong                *EMmsg         O  Return code.
                                              - EMS_S_Success => The horizon
                                                  curves are planar to the
                                                  view.
                                              - EMS_I_NotFound => The
                                                  horizon curves are not
                                                  planar to the view.
                                              - EMS_E_Fail => Failure.
    IGRint                  options       I  Options bitmask.  Definitions
                                             are in EMShrzcvs.h.
    struct  GRmdenv_info   *mdenv_info;   I  The module environment info of
                                             the horizon curve's surface.
    IGRvector               z_vector      I  The z-vector with which to
                                             compare the horizon curves.
                                             If this argument is NULL,
                                             the window id must be specified.
                                             If both are specified, only
                                             z_vector is used.
    struct GRid            *window_grid   I  Window id of the view with
                                             which to compare the horizon
                                             curves.  Either this argument
                                             or the view z-vector needs to
                                             be specified.
    GRspacenum             *osnum         I  Only horizon curves in this
                                             object space will be checked.
                                             If this argument is NULL,
                                             horizon curves in all objects
                                             spaces will be checked.
    struct GRid            *curve_id      O  The object id and object space
                                             number of a matching horizon
                                             curve, if any.  Optional argument;
                                             may send in NULL if information
                                             is not needed.
*/

message EMplanar_to_view(IGRlong *EMmsg; IGRint options;
                         struct GRmdenv_info *mdenv_info; IGRvector z_vector;
                         struct GRid *window_grid; GRspacenum *osnum;
                         struct GRid *curve_id);


/*
 Message EMdisplay

 Description

    This message is used to display the horizon curves for a paticular
    view.

 Arguments

    Type                   Name          I/O          Description
    ---------------------- ------------- --- -------------------------------
    IGRlong                *EMmsg         O  Return code.
    IGRint                  options       I  Display options which are
                                             defined in EMShrzcvs.h.
    IGRshort               *matrix_type   I  Matrix type.
    IGRmatrix               matrix        I  Matrix to use when displaying
                                             the horizon curves.
    enum GRdpmode          *mode          I  Display mode.
    struct IGRaltdisplay   *alt_symb      I  Alternate display symbology.
    struct DP_information  *sp_info       I  Display specific information.
    OM_p_KEY_DESC           key           I  Range key.
*/

message EMdisplay(IGRlong *EMmsg; IGRint options; IGRshort *matrix_type;
                  IGRmatrix matrix; enum GRdpmode *mode;
                  struct IGRaltdisplay *alt_symb;
                  struct DP_information *sp_info;
                  OM_p_KEY_DESC key);

/*
 Message EMlocate

 Description

    This message is used to determine if any of the horizon curves would be
    located using the input locate information.

 Arguments

    Type                   Name          I/O          Description
    ---------------------- ------------- --- ---------------------------------
    IGRlong                *EMmsg         O  Return code.
    struct GRlc_cvl        *cvl           I  Locate information.
    struct GRid            *window_grid   I  Id of the window in which the
                                             locate is taking place.
    IGRlong                *prism_rel     I  Prism relation desired (for prism
                                             locate only).  Optional argument,
                                             may be set to NULL.
    IGRboolean             *inside       I/O Indicates if the element is
                                             inside the prism.  Only valid for
                                             prism locates.  May be NULL
                                             otherwise.
    IGRboolean             *outside      I/O Indicates if the element is
                                             outside the prism.  Only valid
                                             for prism locates.  May be NULL
                                             otherwise.
    IGRboolean             *overlap      I/O Indicates if the element
                                             overlaps the prism.  Only valid
                                             for prism locates.  May be NULL
                                             otherwise.
    struct GRlc_info       *loc_parms     O  Locate parameters.  A NULL
                                             pointer may be passed in if this
                                             information is not needed. 
    IGRboolean             *was_located   O  Set to TRUE if one of the
                                             horizon curves was hit.
*/

message EMlocate(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                 struct GRid *window_grid; IGRlong *prism_rel;
                 IGRboolean *inside; IGRboolean *outside; IGRboolean *overlap;
                 struct GRlc_info *loc_parms; IGRboolean *was_located);


/*
 Message EMbdrylocate

 Description

    This message is used to locate horizon curves.

 Arguments

    Type                   Name          I/O          Description
    ---------------------- ------------- --- ---------------------------------
    IGRlong                *EMmsg         O  Return code.
    struct GRlc_cvl        *cvl           I  Locate information.
    range_key               OM_p_KEY_DESC I  Range key.
*/

message EMbdrylocate(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                     OM_p_KEY_DESC range_key);


/*
 Message EMexecuteCurveFunction

 Description

    This message is used to execute the specified function on the horizon
    curves.

 Arguments
    ---------------------- ------------- --- ---------------------------------
    IGRlong                *EMmsg         O  Return code.
    IGRint                  options       I  Options which are
                                             defined in EMShrzcvs.h.
    IGRshort               *matrix_type   I  Matrix type.
    IGRmatrix               matrix        I  The surface's environment matrix.
    IGRint                 (*f)()         I  The function to be executed on
                                             the horizon curves.
    IGRchar                *args          I  Pointer to the argument structure
                                             to be passed to f().
*/

message EMexecuteCurveFunction(IGRlong *EMmsg;
                               IGRint   options;
                               IGRshort *matrix_type;
                               IGRmatrix matrix;
                               IGRint (*f)();
                               IGRchar *args);


/*
 Message EMfind_hrzcvs

 Description

    This message helps determine if any horizon curves exist in an object
    space.  

 Arguments
    ---------------------- ------------- --- ---------------------------------
    IGRlong                *EMmsg         O  Return code.  Set to
                                             EMS_I_Found if sent to a horizon
                                             curve.
*/

message EMfind_hrzcvs(IGRlong *EMmsg);


/*
 Message EMpasson

 Description

    This message is used to pass on a message to horizon curve objects.
    It is useful when a message needs to be sent from a surface to only
    its horizon curves via the notification channel.

 Arguments

    Type                   Name          I/O          Description
    ---------------------- ------------- --- -------------------------------
    OM_p_MESSAGE            pass_msg      I  Pointer to message to pass to
                                             the horizon curve elements.
    
*/

message EMpasson(OM_p_MESSAGE pass_msg);

override EMconstruct_associative,
         EMget_parent_type,
         GRget_locate_properties,
         NDparent_deleted,
         NDparent_rf_detached,
         GRdisyourself,
         NDupdate;

end specification EMShrzcvs;
