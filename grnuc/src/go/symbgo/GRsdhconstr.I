/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRsmdfhdr.GRconstruct

Description
        This method is used to perform the initilization of the symbol
        definition header. 

Synopsis
        struct GRvg_construct *arglist      standard argument list

Algorithm
        An empty symbol definition header object has already been
        created by OM. This method initializes the symbol definition header
        object by filling in the instance data and then posting the object.

History
        HGW/DEM 06/06/86    Design date and Creation date.
        HGW     08/14/86    Changed terminology
        HGW     11/02/87    Changed for version 1.1
*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymmacros.h"
#include "OMmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "vardef.h"

method GRconstruct (struct GRvg_construct *arglist)
{
    IGRlong              sts, msg; /* return codes */
    IGRlong               size;
    IGRlong               temp;
    GRobjid              new_id;   /* for post method     */
    struct GRnamdesc     *symb;    /* class attributes    */
    struct GRvar_list    list[3];
    struct GRpost_info   post_info;/* flags for post      */

    *arglist->msg = MSSUCC;        /* initialize success  */

    /*
     *  Set the properties word.
     */

    me->properties = arglist->properties | GRIS_NEW;

    /*
     *  Set the symbol name and description
     */

    symb = (struct GRnamdesc *) arglist->class_attr;

    size = strlen (symb->name_symbol) + 1;
    list[0].var = GR_SYMBOL_NAME;
    list[0].var_ptr = symb->name_symbol;
    list[0].num_bytes = size;
    list[0].bytes_returned = &temp;
    size = strlen (symb->desc_symbol) + 1;
    list[1].var = GR_SYMBOL_DESC;
    list[1].var_ptr = symb->desc_symbol;
    list[1].num_bytes = size;
    list[1].bytes_returned = &temp;
    list[2].var = END_PARAM;

    sts = om$send (msg = message GRsymbol.GRset_inq_symbol (&msg, 1, list),
                   targetid = my_id);

    if (sts & msg & 1)
    {
        /*
         *  Post the geometry
         */

        post_info.construct_flag = TRUE; 
        sts = om$send (msg = message GRvg.GRpostabsg
                            (arglist->msg, arglist->env_info,
                             &post_info, arglist->geometry, &new_id),
                       targetid = my_id);

        if (sts & msg & 1)
        {
            /*
             * add symbol to symbol btree
             */

            sts = gr$symsd_add (msg = &msg,
                                sl_osnum = arglist->env_info->md_id.osnum,
                                sd_name = me->symbol_name,
                                sd_objid = my_id);
        }
    }

    /*
     * see if we succeeded, and if not, delete object
     */

    if (!(sts & msg & 1))
    {
        om$send (msg = message Root.delete (NULL), targetid = my_id);
        *arglist->msg = msg;
        sts = OM_E_ERROR;
    }
    return (sts);
}
end implementation GRsmdfhdr;
