/*
Class
        GRcoords

Description
        This is the root class for all the coordinate system
        graphics objects. The methods supported at this level
        are the minimum methods needed to communicate with the
        GRcsmgr object.

History
        Kumar Talluri   10/10/86    Design and Implementation.
        mrm             10/01/87    reject all methods declared here
                        06/28/88    add npts argument to both cvt methods
                        06/14/89    add Synopsis to each message header
*/

class specification GRcoords (1:0) of GRlbsys;

/*
Message
        GRinitialize

Description
        This method initializes the instance data of the newly
        constructed coordinate system object. This message is
        sent after the object is constructed.

Notes
        New code should reference the GRconstruct method overridden
        on GRgencs.  This method will eventually be removed.
*/

message GRinitialize (IGRlong *msg;
                      IGRchar *csname;
                      IGRchar *csdesc;
                      struct GRvg_construct *p_arglist);

/*
Message
        GRget_query_info

Description
        This method checks whether the cstype is valid and then returns
        a pointer to the input prompts and the number of inputs required
        by the required 'cstype'.

Synopsis
        IGRlong *msg                        o   return code
                                                MSSUCC - successful completion
                                                MSINARG - invalid cstype
        IGRchar *cstype                     i   type of coord sys, e.g.
                                                "rectangular", "spherical",
                                                or "cylindrical"
        IGRshort *num_inputs                o   number of input values required
        struct GRcsquery_info **query_info  o   ptr to query information
*/

message GRget_query_info (IGRlong *msg;
                          IGRchar *cstype;
                          IGRshort *num_inputs;
                          struct GRcsquery_info **query_info);

/*
Message
        GRcvt_to_wld_coords

Description
        This method converts points in the local coordinate system
        to world coordinates. The input values must correspond to the cstype.

Synopsis
        IGRlong     *msg            o   completion status
                                        MSSUCC  success; conversion complete
                                        MSFAIL  failed conversion
                                        MSINARG invalid coordinate system type
        IGRchar     *cstype         i   type of coord system, i.e.
                                        rectangular, spherical, cylindrical
        IGRint       npts           i   number of points to convert
        IGRdouble   *input_values   i   coordinates to convert
        IGRdouble   *wld_coords     o   world coordinates
*/

message GRcvt_to_wld_coords (IGRlong *msg;
                             IGRchar *cstype;
                             IGRint npts;
                             IGRdouble *input_values;
                             IGRdouble *wld_coords);

/*
Message
        GRcvt_to_lcl_coords

Description
        This method converts points in world coordinates to the
        local coordinate system of the corresponding cstype.

Synopsis
        IGRlong     *msg            o   completion status
                                        MSSUCC   success, conversion complete
                                        MSFAIL   failed conversion
                                        MSINARG  invalid coordinate system type
        IGRchar     *cstype         i   type of coord system, i.e.
                                        rectangular, spherical, cylindrical
        IGRint       npts           i   number of points to convert
        IGRdouble   *input_values   i   coordinates to convert
        IGRdouble   *lcl_coords     o   local coordinates
*/

message GRcvt_to_lcl_coords (IGRlong *msg;
                             IGRchar *cstype;
                             IGRint npts;
                             IGRdouble *input_values;
                             IGRdouble *lcl_coords);
/*
Message
        GRget_oid_from_name

Description
        This method may be used to find the id of a coordinate system
        with a given name.  If the input name and the coordinate system's
        name match, OM_I_STOP_SENDING is returned as the method's
        exit status, so that this message may be passed down a channel
        containing several coordinate systems to find one with a
        particular name.

Synopsis
        IGRlong *msg        o   return code
                                MSSUCC  the specified name matches the cs name
                                MSFAIL  the names do not match
        IGRchar *csname     i   the name to compare against the cs's name
        GRobjid *csobjid    o   the cs's object id, if the names match
*/

message GRget_oid_from_name (IGRlong *msg;
                             IGRchar *csname;
                             GRobjid *csobjid);

/*
 *  rejected methods
 */

reject  GRget_query_info,
        GRinitialize,
        GRget_oid_from_name,
        GRcvt_to_wld_coords,
        GRcvt_to_lcl_coords;

end specification GRcoords;
