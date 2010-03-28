/*
Name
        GRgencs

Description
        This class defines the generic coordinate system. The coordinate
        system types supported for this class are rectangular, spherical,
        and cylindrical.  This class of objects can convert local 
        coordinates to world or vice versa.  Other coordinate system
        types may be supported by subclassing from GRgencs.

History
        Kumar Talluri   10/15/86    design and implementation
        mrm             08/05/87    added GRget_cs_info method
                        06/28/88    changed GRgetmatrix to copy its matrix
                                    into a buffer rather than returning
                                    a pointer into instance data
                        08/01/88    added GRcssetscale and GRcsgetscale
                                    messages and scale matrix, overrode
                                    GRxform to filter out scale
                        10/19/90    add GRcsgetscale to I/MDS
        dhm             08/06/91    add type to instance data, GRget_cs_info,
                                    and added new method GRchange_type
*/

class specification GRgencs (1:0) of GRcoords;

instance GRgencs
{
    variable IGRchar        description[];  /* description of cs    */
    IGRdouble               matrix[16];     /* local-to-world transformation */
    IGRdouble               scale[3];       /* local-to-world scale vector */
    IGRshort                type;           /* cs type defined in csdef.h:
                                               rectangular, cylindrical,
                                               spherical  */
    channel
    {
        (one_to_one)
        GRcsmgr.to_active;
    }                       to_csmgr;       /* connected when active */
};

/*
 *  method overrides
 */

override GRdisyourself,         /* display and label the cs triad */
         GRgenabsg,             /* generate the abstract geometry */
         GRpostabsg,            /* post the abstract geometry */
         GRconstruct,           /* initialize newly constructed object */
         GRxform,               /* filter scale out of transformation */
         GRinitialize,          /* new code should call GRconstruct */
         GRget_oid_from_name,   /* return id if names match */
         GRget_query_info,      /* returns prompts & masks given cs type */
         GRcvt_to_wld_coords,   /* convert input point to world coordinates */
         GRcvt_to_lcl_coords,   /* convert input point to local coordinates */
         GRcopy,                /* copy and link to csmgr */
         GRgetobjinfo;          /* return object information */

override GRanalyze_element;     
/*
 *  message declarations
 */

/*
Name
        GRgetmatrix

Description
        This method copies its local-to-world transformation matrix into
        the buffer pointed to by matrix.

Synopsis
        IGRlong     *msg        o return code - always MSSUCC
        IGRdouble   *matrix     o the cs's transformation matrix
*/

message GRgetmatrix (IGRlong *msg; IGRdouble *matrix);

/*
Name
        GRget_cs_info

Description
        This method returns the name, the description, and or 
        the id of the coordinate system.  Any parameter may be excluded
        by sending a NULL pointer for that parameter

Synopsis
        IGRlong     *msg            o return code
                                        MSSUCC - successful completion
                                        NAME_TRUNC - information, truncated
                                            name returned
                                        DESC_TRUNC - information, truncated
                                            description returned
                                        BOTH_TRUNC - information, truncated
                                            name and description returned
        IGRint       namebuf_size   i size of name buffer
        IGRchar     *name           o buffer for cs name
        IGRint      *namebytes_ret  o number of bytes written to name
        IGRint       descbuf_size   i size of description buffer
        IGRchar     *desc           o buffer for cs description
        IGRint      *descbytes_ret  o number of bytes written to desc
        IGRshort    *type           o type of cs: rectangular, spherical,
                                      or cylindrical
        struct GRid *id             o cs objid and osnum
*/

message GRget_cs_info (IGRlong     *msg;
                       IGRint       namebuf_size;
                       IGRchar     *name;
                       IGRint      *namebytes_ret;
                       IGRint       descbuf_size;
                       IGRchar     *desc;
                       IGRint      *descbytes_ret;
                       IGRshort    *type;
                       struct GRid *id);

/*
Name
        GRcssetscale

Description
        This message allows the coordinate system scale vector to be
        altered.  The caller specifies whether the input scale vector
        is to replace the scale vector in the coordinate system instance
        date (absolute) or be combined with it (relative).  Flags are
        defined in csdef.h for the abs_rel argument.

Synopsis
        IGRlong     *msg        o return code
                                    MSSUCC - successful completion
                                    MSFAIL - unsuccessful completion
                                    MSINARG - invalid value for abs_rel
        IGRint       abs_rel    i CS_ABSOLUTE or CS_RELATIVE
        IGRdouble   *scale      i array of 3 scale factors
*/

message GRcssetscale (IGRlong *msg; IGRint abs_rel; IGRdouble *scale);


/*
Name
        GRcsgetscale

Description
        This message allows the user to retrieve the scale vector
        of the coordinate system.

Synopsis
        IGRlong     *msg        o return code - always MSSUCC
        IGRdouble   *scale      o array of 3 scale factors
*/

message GRcsgetscale (IGRlong *msg; IGRdouble *scale);

/*
Name
        GRchange_type

Description
        This message allows the user to change the type associated with the
        coordinate system.

Synopsis
        IGRlong    *msg      o return code
        IGRshort   *type      i one of the defines in csdef.h for rectangular,
                               spherical, or cylindrical. NULL if passing in
                               type_string.
        IGRchar    *type_st  i string for rectangular, spherical, or cylindrical                               defined in csdef.h. NULL if passing in type.
*/

message GRchange_type (IGRlong *msg; IGRshort *type; IGRchar *type_string);

end specification GRgencs;
