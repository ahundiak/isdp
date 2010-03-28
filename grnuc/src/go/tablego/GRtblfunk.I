/*
 * Function File
 *
 *      GRtblfunk
 *
 * Abstract :
 *
 *      This file defines functions for creating and using GRtables.
 *
 * History :
 *
 *      Jay Wallingford     9/22/93  Creation date.
 *
 */
class implementation GRtable;

#include <OMerrordef.h>
#include <msdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <nddef.h>
#include <ndmacros.h>
#include <expression.h>
#include <expmacros.h>
#include <ex.h>
#include <igrdp.h>
#include <igetypedef.h>
#include <gr.h>
#include <dpdef.h>
#include <dp.h>
#include <grdpbdef.h>
#include <GRdpbfunc.h>
#include <GRsetinq.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <parametric.h>

extern OMuword OPP_expression_class_id;

from NDnode     import NDselect_copy, NDgive_structure;
from GRgraphics import GRgetname, GRchgname;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: GRget_table                                                     |
 |                                                                           |
 | This function returns the table for the input feature.                    |
 |                                                                           |
 | Input:   struct GRid     * feature_id       Associative object.           |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          struct GRid     * table_id         Default table.                |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Catostrophic error.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
IGRlong GRget_table (IGRlong        * msg,
                     struct GRid    * feature_id,
                     struct GRid    * table_id)
{
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRchar           pathname[DI_PATH_MAX], name[DI_PATH_MAX];
    struct GRid       dir_id;
    
    *msg = MSSUCC;

    name[0] = '\0';
    pathname[0] = '\0';
    
    /*
     * Get the path to the table directory.
     */
    di$give_pathname (osnum = feature_id->osnum,
                      pathname = pathname);
    
    strcat (pathname, ":tables");

    /*
     * Make sure that directory is there.
     */
    if (di$translate (objname = pathname,
                      p_osnum = &dir_id.osnum,
                      p_objid = &dir_id.objid) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    /*
     * See if the graphic is named in the tables directory.
     */
    if (di$untranslate (objid = feature_id->objid,
                        osnum = feature_id->osnum,
                        path = pathname,
                        objname = name) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    /*
     * Get the table that cooresponds to the feature.
     */
    strcat (name, "_tbl");
    
    if (di$translate (objname = name,
                      p_objid = &table_id->objid,
                      p_osnum = &table_id->osnum) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;

        /*
         * Remove the feature's name in the tables directory.
         */
        di$rm_name (regexp = name);

        goto quit;
    }
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: GRdelete_table                                                  |
 |                                                                           |
 | This function deletes the table.                                          |
 |                                                                           |
 | Input:   struct GRid     * table_id         Table object.                 |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Catostrophic error.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
IGRlong GRdelete_table (IGRlong        * msg,
                        struct GRid    * table_id)
{
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRchar           pathname[DI_PATH_MAX], name[DI_PATH_MAX], * cp;
    IGRchar         * strrchr ();
    struct GRid       dir_id;
    
    *msg = MSSUCC;

    name[0] = '\0';
    pathname[0] = '\0';
    
    /*
     * Get the path to the table directory.
     */
    di$give_pathname (osnum = table_id->osnum,
                      pathname = pathname);
    
    strcat (pathname, ":tables");

    /*
     * Make sure that directory is there.
     */
    if (di$translate (objname = pathname,
                      p_osnum = &dir_id.osnum,
                      p_objid = &dir_id.objid) != DIR_S_SUCCESS)
    {
        goto quit;
    }
    
    /*
     * See if the table is named in the tables directory.
     */
    if (di$untranslate (objid = table_id->objid,
                        osnum = table_id->osnum,
                        path = pathname,
                        objname = name) != DIR_S_SUCCESS)
    {
        goto quit;
    }
    
    /*
     * Remove the table name.
     */
    di$rm_name (regexp = name);

    /*
     * Now remove the feature name.
     */
    if (cp = strrchr(name, '_'))
    {
        *cp = '\0';
    }

    di$rm_name (regexp = name);
    
 quit:

    om_msg = om$send (msg = message Root.delete (0),
                      senderid = NULL_OBJID,
                      targetid = table_id->objid,
                      targetos = table_id->osnum);
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: GRcreate_default_table                                          |
 |                                                                           |
 | This function creates a default table for an object.                      |
 |                                                                           |
 | Input:   struct GRid     * feature_id   Associative object.               |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          struct GRid     * table_id         Default table.                |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Catostrophic error.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
IGRlong GRcreate_default_table (IGRlong        * msg,
                                IGRchar        * name,
                                struct GRid    * feature_id,
                                struct GRid    * table_id)
{
    IGRlong               om_msg = OM_S_SUCCESS;
    IGRint                i, num_columns, size, roots_size = 50, * roots_info;
    struct GRid         * roots, dir_id;
    GRtable_column_info * columns;
    GRtable_row_info      row;
    GRtable_cell_info   * cells;
    struct GRmd_env       mod_env;
    struct ret_struct     ret_data;
    OMuword               classid;
    IGRchar               pathname[DI_PATH_MAX];
    IGRboolean            table_created = FALSE;

    pathname[0] = '\0';
    
    om_msg = GRget_table (msg, feature_id, table_id);
    
    if (om_msg & *msg & 1)
    {
        goto quit;
    }
    else
    {
        om_msg = OM_S_SUCCESS;
        *msg = MSSUCC;
    }
    
    gr$get_module_env (buffer = (IGRchar *)&mod_env);
    
    roots = (struct GRid *)om$malloc(size = roots_size * sizeof(struct GRid));
    roots_info = (IGRint *)om$malloc(size = roots_size * sizeof(IGRint));

    for (i=0; i<roots_size; ++i)
    {
        roots_info[i] = ND_ROOT | ND_BODY;
    }
    
    om_msg = om$send (msg = message NDnode.NDselect_copy (msg,
                                                          0,
                                                          roots,
                                                          roots_info,
                                                          roots_size,
                                                          &size),
                      senderid = NULL_OBJID,
                      targetid = feature_id->objid,
                      targetos = feature_id->osnum);

    if (!(om_msg & *msg & 1) || (size == 0))
    {
        goto quit;
    }

    size = (size > roots_size) ? roots_size : size;

    columns = (GRtable_column_info *)om$malloc(size = size * sizeof(GRtable_column_info));
    cells = (GRtable_cell_info *)om$malloc(size = size * sizeof(GRtable_cell_info));
    strcpy (row.name, "Default");

    for (num_columns = 0, i=0; i<size; ++i)
    {
        om$get_classid (objid = roots[i].objid,
                        osnum = roots[i].osnum,
                        p_classid = &classid);
        
        if ((roots_info[i] & ND_ROOT) &&
            (om$is_ancestry_valid (superclassid = OPP_expression_class_id,
                                   subclassid = classid) == OM_S_SUCCESS))
        {
            columns[num_columns].expression_id = roots[i];
            
            mod_env.md_id.osnum = roots[i].osnum;

            om_msg = om$send (msg = message NDnode.NDgive_structure (msg,
                                                                     &ret_data,
                                                                     &mod_env),
                              senderid = NULL_OBJID,
                              targetid = roots[i].objid,
                              targetos = roots[i].osnum);

            if (!(om_msg & *msg & 1))
            {
                om_msg = OM_S_SUCCESS;
                *msg = MSSUCC;
                continue;
            }
            
            cells[num_columns].d = ret_data.var.root_pm_st.value;
            
            if (di$untranslate (objid = roots[i].objid,
                                osnum = roots[i].osnum,
                                objname = pathname) == DIR_S_SUCCESS)
            {
                di$split (pathname = pathname,
                          name = columns[num_columns++].name);
            }
            else
            {
                sprintf (columns[num_columns++].name, "exp%d", num_columns);
            }
        }
    }
    
    /*
     * Construct the table.
     */
    om_msg = om$construct (classname = "GRtable",
                           osnum = (table_id->osnum = feature_id->osnum),
                           p_objid = &table_id->objid,
                           msg = message GRtable.GRcreate (msg,
                                                           num_columns,
                                                           columns,
                                                           1,
                                                           &row,
                                                           cells));

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    table_created = TRUE;

    /*
     * Get the path to the table directory.
     */
    di$give_pathname (osnum = table_id->osnum,
                      pathname = pathname);
    
    strcat (pathname, ":tables");
    
    if (di$translate (objname = pathname,
                      p_osnum = &dir_id.osnum,
                      p_objid = &dir_id.objid) != DIR_S_SUCCESS)
    {
        strcat (pathname, ":");
        
        if (di$mkpath (pathname = pathname,
                       p_osnum = &dir_id.osnum) != DIR_S_SUCCESS)
        {
            *msg = MSFAIL;
            goto quit;
        }
        
        pathname[strlen(pathname)] = '\0';
    }
    
    /*
     * Name the graphic object.
     */
    strcat (pathname, ":");
    strcat (pathname, name);
 
   if (di$add_name (objname = pathname,
                     objid = feature_id->objid,
                     osnum = feature_id->osnum) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
    }
    
    /*
     * Name the table.
     */
    strcat (pathname, "_tbl");
    
    if (di$add_name (objname = pathname,
                     objid = table_id->objid,
                     osnum = table_id->osnum) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
    }
    
 quit:
    
    if (!(om_msg & *msg & 1) && table_created)
    {
        IGRlong ok;
        
        GRdelete_table (&ok, table_id);
    }
    
    return om_msg;
}
                      
end implementation GRtable;



