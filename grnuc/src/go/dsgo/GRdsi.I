/* #######################    APOGEE COMPILED   ######################## */
class implementation GRds;

#include "grimport.h"
#include "dsdef.h"
#include "ds.h"
#include "dsmacros.h"
#include "msdef.h"

/*
 * Method:     super_construct
 * Purpose:    Sets the default standard to the first index.
 * Return:     success - OM_S_SUCCESS;
 *             failure - OM_E_ABORT;
 */
method super_construct()
{
     /*
      * Delete myself. Only GRdsnew supers should be created now!
      */
     om$send (msg = message Root.delete (0),
              targetid = my_id);
     
     return OM_E_ABORT;
}

method dump()
{
  return (1);
}


/*
 * Method:     get_grds
 * Purpose:    fetches data particular to the drawing sheet manager object.
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method get_grds(IGRlong            *msg;
                IGRlong             type;
                IGRchar             *buffer)
{
    *msg = MSFAIL;

     /*
      * Delete myself. Only GRdsnew supers should be created now!
      */
     om$send (msg = message Root.delete (0),
              targetid = my_id);
     
    return OM_E_ABORT;
}



/*
 * Method:     put_grds
 * Purpose:    updates/adds data particular to the drawing sheet manager object.
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method put_grds(
          IGRlong             *msg;
          IGRlong             type;
          IGRchar             *buffer1;
          IGRchar             *buffer2)
{
    *msg = MSFAIL;

     /*
      * Delete myself. Only GRdsnew supers should be created now!
      */
     om$send (msg = message Root.delete (0),
              targetid = my_id);
     
    return OM_E_ABORT;
}

/*
 * Method:     del_grds
 * Purpose:    deletes data particular to the drawing sheet manager object.
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method del_grds(
          IGRlong             *msg;
          IGRlong             type;
          IGRchar             *buffer;
          IGRlong             num_ndxs)
{
    *msg = MSFAIL;

     /*
      * Delete myself. Only GRdsnew supers should be created now!
      */
     om$send (msg = message Root.delete (0),
              targetid = my_id);
     
    return OM_E_ABORT;
}

/*
 * Method:     auto_convert
 * Purpose:    converts a GRds super to a GRdsnew super then deletes itself.
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method auto_convert (IGRlong     * msg;
                     struct GRid * GRdsnew_super_id)
{
    IGRlong     om_msg, ok;
    OM_S_OBJID  mod_id, super_id;
    OMuword     mod_osnum;
    IGRint      count, i;
    struct GRid loc_super_id;
    
    om_msg = OM_S_SUCCESS;
    
    *msg = MSSUCC;

    /*
     * If a id wasn't supplied use a local one.
     */
    if (GRdsnew_super_id == NULL)
    {
        GRdsnew_super_id = &loc_super_id;
    }
    
    /*
     * Create the new drawing standards super object.
     */
    om_msg = ex$get_cur_mod (id = &mod_id, osnum = &mod_osnum);

    if (!(om_msg & 1) || (mod_osnum != OM_Gw_current_OS))
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    om_msg = ex$get_super (mod_id = mod_id,
                           mod_osnum = mod_osnum,
                           super_name = DS_SUPER_NAME,
                           create = TRUE,
                           super_class = "GRdsnew",
                           super_id = &super_id);
    
    if (!(om_msg & 1) || (super_id == NULL_OBJID))
    {
        *msg = MSFAIL;
        goto quit;
    }

    /*
     * Set the new super id.
     */
    GRdsnew_super_id->objid = super_id;
    GRdsnew_super_id->osnum = mod_osnum;
    
    /*
     * Add the standards to the new super.
     */
    count = om$dimension_of (varray = me->standard_tab);
    
    for (i=0; i<count; ++i)
    {
        gr$add_standard (msg = &ok, standard = &me->standard_tab[i]);
    }

    /*
     * Set the default standard.
     */
    if ((me->default_standard >= 0) && (me->default_standard < count))
    {
        gr$set_default_standard (msg = &ok,     
                                 standard = &me->standard_tab[me->default_standard]);
    }
    
    /*
     * Add the sheets to the new super.
     */
    count = om$dimension_of (varray = me->sheet_tab);
    
    for (i=0; i<count; ++i)
    {
        gr$add_sheet (msg = &ok, sheet = &me->sheet_tab[i]);
    }

quit:
    
    /*
     * Delete the old super.
     */
    om$send (msg = message Root.delete (0),
             targetid = my_id);
                             
    return om_msg;
}

end implementation GRds;
