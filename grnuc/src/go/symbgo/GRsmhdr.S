/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRsmhdr - symbol header class

Description
        The class GRsmhdr defines how a symbol definition is placed.  This
        object references a symbol definition.  GRsmhdr has the following
        properties:

        o   Symbol headers are on the Primary channel via range or name.

        o   Symbol headers are located directly from the Primary channel.

        o   Symbol headers are related to a symbol definition header as
            flexible owners via the "to_components" channel.

        o   The difference between other elements and symbols is that even
            though the user sees many copies of a particular grouping, in 
            reality there is only one copy of the group of objects in the
            local cell library.

Notes
        Classes which do not wish to inherit the 3-d double instance data
        should reject the instance data of this class and override the 
        GRgenabsg, GRpostabsg, GRchg_owner_properties, and 
        GRget_owner_properties methods.

History
        HGW/DKM     05/30/86    Creation date
        HGW         10/05/87    Changed for version 1.1
        mrm         01/13/89    override GRadd_to_active_owner
*/

class specification GRsmhdr (1:0) of GRlbsys, GRowner;

instance GRsmhdr
{
    IGRshort owner_properties;  /* Bit  Description                      */
                                /* 0    GR_ORPHAN - if set defines the   */
                                /*      group as an orphan               */
                                /* 1    GR_SYM_COLOR - if set color is   */
                                /*      defined; if clear do not use     */
                                /* 2    GR_SYM_WEIGHT - if set weight is */
                                /*      defined; if clear do not use     */
                                /* 3    GR_SYM_STYLE - if set style is   */
                                /*      defined; if clear do not use     */
                                /* 4-15 For subclass use.                */
    IGRdouble matrix[9];        /* transformation from local to world    */
    IGRdouble origin[3];        /* symbol origin                         */
};

from GRvg    inherit GRaddwrng,
                     GRremwrng,
                     GRchgprops,
                     GRgetprops,
                     GRchglevel;
         
from GRlbsys inherit GRprismrel,
                     GRgetrang,
                     GRptproject,
                     GRlnproject,
                     GRkeypoint,
                     GRgetsize,
                     GRgetgeom,
                     GRdetplane,
                     GRinplane,
                     GRlocate; 
override
        GRdisyourself,              /* GRgraphics - display comp            */
        GRclip,                     /* GRgraphics - perform clip for symbol */
        GRcopy,                     /* GRgraphics - special copy of sdh     */
        GRlocate_processing,        /* GRgraphics - locate processing       */
        GRgetobjinfo,               /* GRgraphics - class specific          */
        GRconstruct,                /* GRgraphics - class specific          */
        GRchgcolor,                 /* GRvg       - set display property    */
        GRchgdp,                    /* GRvg       - set display property    */
        GRchgstyle,                 /* GRvg       - set display property    */
        GRchgweight,                /* GRvg       - set display property    */
        GRputsymb,                  /* GRvg       - set display property    */
        GRgetsymb,                  /* GRvg       - check display property  */
        GRpostabsg,                 /* GRvg       - class specific          */
        GRgenabsg,                  /* GRvg       - class specific          */
        GRownaddwrng,               /* GRcmpowner - DO NOT ADD COMPONENTS   */
        GRownremwrng,               /* GRcmpowner - DO NOT ADD COMPONENTS   */
        GRdrop,                     /* GRowner    - copy comp to module     */
        GRdelete_owner,             /* GRowner    - remove from r-tree      */
        GRxform_owner,              /* GRowner    - transform geometry      */
        GRget_locate_properties,    /* GRowner    - class specific          */
        GRget_channel_type,         /* GRowner    - class specific          */
        GRget_context,              /* GRowner    - modify context          */
        GRget_matrix,               /* GRowner    - modify matrix           */
        GRchg_owner_properties,     /* GRowner    - class specific          */
        GRget_owner_properties,     /* GRowner    - class specific          */
        GRadd_to_active_owner,      /* GRowner    - add symhdr to owner     */
        GRreplace,                  /* GRowner    - replace symbol          */
	GRformatele,
	GRplotyourself;

reject GRremove_components;

/*
Name
        GRmv_sh_to_new_sdh

Description
        This method is used to move a symbol reference header to a new
        symbol definition header.  

Synopsis
        IGRlong *msg                return code 
        struct GRmd_env *mod_env    the module environment
        struct GRid *new_sdh_id     the symbol definition to connect to

Return Values
        MSSUCC   -  if successful.
        MSFAIL   -  if failure.
*/

message GRmv_sh_to_new_sdh (IGRlong *msg;
                            struct GRmd_env *mod_env;
                            struct GRid *new_sdh_id);
/*
Name
        GRcp_symbol_to_cell

Description
        This method is used to convert a symbol to a cell.

Synopsis
        IGRlong *msg                    completition code
        struct GRmd_env *mod_env        the originial module environment
        struct GRmd_env *target_env     the target environment
        struct GRid *cell_id            the new cell id

Return Values
        MSSUCC  -- successful completion
        MSFAIL --  if failure
*/

message GRcp_symbol_to_cell (IGRlong *msg;
                             struct GRmd_env *mod_env;
                             struct GRmd_env *target_env;
                             struct GRid *cell_id);
end specification GRsmhdr;
