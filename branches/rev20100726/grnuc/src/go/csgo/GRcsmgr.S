/*
Name
        GRcsmgr - coordinate system manager

Description
        This class of objects manages all coordinate system objects.  One
        coordinate system manager (csmgr) exists in each object space,
        and is connected to all coordinate system objects via the
        GRcomp_owner.to_components - GRconnector.to_owners channel.  An 
        "active" coordinate system is also connected to the csmgr via
        the GRcsmgr.to_active - GRgencs.to_csmgr channel.

        This object also supports the methods that are required to interface
        with the 'XY= ' keyin command.

History
        Kumar Talluri   11/08/86    Design and Implementation.
        mrm             08/05/87    added get_active_cs_info method
        mrm             10/01/87    union with GRcmpowner
        mrm             07/26/88    override GRrigid_connecting
        dhm             08/06/91    added argument type to GRget_acs_info
        mrm             11/16/93    removed wakeup override
*/

class specification GRcsmgr (2:0) of global_class, GRcmpowner;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

instance GRcsmgr
{
    IGRboolean                  display_status; /* on or off */
    channel
    {
        (one_to_one)
        GRgencs.to_csmgr;
    }                           to_active;      /* to active coordinate sys */
};

/*
 *  message declarations
 */

/*
Name
        GRconstruct_new_cs

Description
        This method constructs a coordinate system of the specified class
        and makes it active.  The name and description are optional and
        may be NULLed out.
*/

message GRconstruct_new_cs (IGRlong                 *msg;          /* output */
                            IGRchar                 *classname;    /* input  */
                            struct GRvg_construct   *cnst_lis;     /* input  */
                            IGRchar                 *csname;       /* input  */
                            IGRchar                 *csdesc);      /* input  */

/*
Name
        GRset_active_cs

Description
        This method makes the specified coordinate system active.
*/

message GRset_active_cs (IGRlong           *msg;                   /* output */
                         struct GRmd_env   *module_info;           /* input  */
                         GRobjid           CSobjid);               /* input  */

/*
Name
        GRcstoggle_display

Description
        This method toggles the displayability/locatability of all coordinate
        systems.   On exit display_on contains the current display status.

Return Values
        msg         MSSUCC if successful
                    MSFAIL if unsuccessful
        display_on  1 if on
                    0 if off
*/

message GRcstoggle_display (IGRlong         *msg;                  /* output */
                            struct GRmd_env *module_info;          /* input  */
                            IGRint          *display_on);          /* output */

/*
Name
        GRget_query_info

Description
        This method accepts a coordinate system type and returns information
        necessary for user input in the specified type, i.e. the number of
        user inputs required and a pointer to an array of input information
        structures.  Each input information structure has a prompt, its
        corresponding input mask, and a default value.  This input information
        is stored at the individual coordinate system class level (e.g.
        GRgencs).  If a coordinate system id is specified, the information is
        obtained from it; otherwise the active cs is used.

Synopsis
        msg         output      MSSUCC if successful
        csname      input       name of the coord sys (NULL => use active)
        cstype      input       type of coord sys. ex: rect,sph,cyl
        num_inputs  output      number of input values required by the user
        query_info  output      ptr to query information 
        csobj       output      object queried for information
*/

message GRget_query_info (IGRlong               *msg;              /* output */
                          IGRchar               *csname;           /* input  */
                          IGRchar               *cstype;           /* input  */
                          IGRshort              *num_inputs;       /* output */
                          struct GRcsquery_info **query_info;      /* output */
                          struct GRid           *csobj);           /* output */

/*
Name
        GRget_acs_info

Description
        This method returns the name, description, type and the id of the
        active coordinate system.  Any parameter may be excluded
        by sending a NULL pointer for that parameter.

Return Values
        msg     MSSUCC - successful completion
                NAME_TRUNC - truncated name returned
                DESC_TRUNC - truncated description returned
                BOTH_TRUNC - truncated name and description returned
*/

message GRget_acs_info (IGRlong       *msg;                        /* output */
                        IGRint         namebuf_size;               /* input  */
                        IGRchar       *name;                       /* output */
                        IGRint        *namebytes_ret;              /* output */
                        IGRint         descbuf_size;               /* input  */
                        IGRchar       *desc;                       /* output */
                        IGRint        *descbytes_ret;              /* output */
                        IGRshort      *type;                       /* output */
                        struct GRid   *id);                        /* output */

/*
 *  message overrides
 */

override super_construct,       /* create the base coordinate system */
         GRrigid_connecting;    /* allow rigid owners to connect */

end specification GRcsmgr;
