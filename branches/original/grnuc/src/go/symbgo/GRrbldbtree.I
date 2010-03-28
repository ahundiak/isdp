/*
Name
        GRrebuild_cell_lib_btree
        GRrebuild_btree

Description
        The function GRrebuild_cell_lib_btree blows away and rebuilds the
        OMbtree used to store cell definition names.  It is intended to be
        used when the original OMbtree is believed to be corrupt.  The
        function GRrebuild_btree is a helper function used during an object
        space pass to actually add each cell definition to the btree.

History
        mrm     10/20/92    creation
                10/26/92    added save option
*/

class implementation GRsmdfhdr;

#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "vardef.h"
#include "grsymdef.h"
#include "grmsg.h"

extern OMuword OPP_GRsmdfhdr_class_id;
extern unsigned int OM_Gf_verbose_warning;

from OMObjSpace import pass;

struct GRrebuild_info
{
    int n_found;
    int n_added;
    char name[MAX_SYMBOL_DEF_NAME];
    long bytes_returned;
    struct GRvar_list varlist[2];
};

int GRrebuild_btree(msg, celdef, rebuild_info)
long *msg;
struct GRid *celdef;
struct GRrebuild_info *rebuild_info;
{
    int sts;

    rebuild_info->n_found++;

    /* get the cell definition name */
    sts = om$send(msg = message GRsymbol.GRset_inq_symbol
                       (msg, 0, rebuild_info->varlist),
                  senderid = NULL_OBJID,
                  targetid = celdef->objid,
                  targetos = celdef->osnum);

    if (!(sts & *msg & 1))
    {
        if (OM_Gf_verbose_warning)
        {
            printf("Failed to get name for cell definition ");
            printf("(%d, %d): %#x, %#x\n", 
                   celdef->osnum, celdef->objid, sts, *msg);
        }
    }
    else
    {
        /* add the cell definition name to the btree */
        sts = GRbtreeadd(msg, 1, &celdef->osnum, GR_SD_BTREE_NAME, 
                         rebuild_info->name, &celdef->objid);
        if (!(sts & *msg & 1))
        {
            if (OM_Gf_verbose_warning)
            {
                printf("Failed to add name to btree for cell definition ");
                printf("(%d, %d): %#x, %#x\n", 
                       celdef->osnum, celdef->objid, sts, *msg);
            }
        }
        else
            rebuild_info->n_added++;
    }
    return(TRUE);
}

static void GRreport_btree_error(filename)
char *filename;
{
    ex$message(msgnumb = GR_F_InvalidCellLib,
               type = "%s",
               var = `filename`);
}

int GRrebuild_cell_lib_btree(filename, osnum, filenum)
char *filename;
OMuword osnum;
int filenum;
{
    int sts, n_headers;
    long msg;
    OM_S_OBJID btree, os_objid;
    OM_S_CLASSLIST classlist;
    struct GRrebuild_info rebuild_info;

    /*
        Get a count of the cell definitions in the library.
    */
    if (!((OM_GA_OSDs[osnum]->OSCO_list[OPP_GRsmdfhdr_class_id]) && 
          (n_headers = 
           OM_GA_OSDs[osnum]->OSCO_list[OPP_GRsmdfhdr_class_id]->i_refcnt)))
    {
        if (OM_Gf_verbose_warning)
            printf("No cell definitions in library\n");
        GRreport_btree_error(filename);
        return(FALSE);
    }

    /* 
        get the existing btree id - don't use GRget_btree; it would create one
        if it doesn't already exist
    */
    sts = GRget_global_mgr_id (&msg, GR_SD_BTREE_NAME, osnum, &btree);
    if (!(sts & msg & 1))
    {
        if (OM_Gf_verbose_warning)
            printf("No btree in library\n");
        GRreport_btree_error(filename);
        return(FALSE);
    }

    /* remove the name from the Named Object Directory */
    sts = ex$remove_name_from_NOD(NODname = "IGENOD",
                                  objname = GR_SD_BTREE_NAME,
                                  mod_osnum = osnum);

    /* 
        delete the old btree, using Root.delete to prevent any access to the
        object's instance data (which is very likely corrupt now)
    */
    sts = om$send(msg = message Root.delete(0),
                  senderid = NULL_OBJID,
                  targetid = btree, 
                  targetos = osnum);

    /* now create a new OMbtree */
    sts = GRget_btree(&msg, GR_SD_BTREE_NAME, osnum, &btree);
    if (!(sts & msg & 1))
    {
        if (OM_Gf_verbose_warning)
            printf("Failed to create new btree\n");
        GRreport_btree_error(filename);
        return(FALSE);
    }

    /*
        Use an object space pass to get a message to each cell definition.
        The message will invoke a function that adds the definition to the new
        btree.  Some data is initialized here to minimize the time spent in
        the callback function.
    */

    sts = om$osnum_to_oso_objid(osnum = osnum, p_objid = &os_objid);
    if (!(sts & 1))
    {
        if (OM_Gf_verbose_warning)
            printf("Failed to find object space id\n");
        GRreport_btree_error(filename);
        return(FALSE);
    }
    classlist.w_count = 1;
    classlist.w_flags = 0;
    classlist.p_classes = &OPP_GRsmdfhdr_class_id;
    rebuild_info.n_found = 0;
    rebuild_info.n_added = 0;
    rebuild_info.varlist[0].var = GR_SYMBOL_NAME;
    rebuild_info.varlist[0].var_ptr = rebuild_info.name;
    rebuild_info.varlist[0].num_bytes = MAX_SYMBOL_DEF_NAME;
    rebuild_info.varlist[0].bytes_returned = &rebuild_info.bytes_returned;
    rebuild_info.varlist[1].var = END_PARAM;
    sts = om$send(msg = message OMObjSpace.pass(&classlist,
                                                OM_e_wrt_message,
                                                message GRgraphics.GRfunction
                                                  (&msg,
                                                   GRrebuild_btree,
                                                   (IGRchar *)&rebuild_info)),
                  senderid = NULL_OBJID,
                  targetid = os_objid,
                  targetos = osnum);
    if (!(sts & msg & 1))
    {
        if (OM_Gf_verbose_warning)
            printf("Object space pass failed\n");
        GRreport_btree_error(filename);
        return(FALSE);
    }

    /*
        Check whether any cell definitions failed to get added to the btree
    */

    if ((rebuild_info.n_found != n_headers) ||
        (rebuild_info.n_found != rebuild_info.n_added))
    {
        if (OM_Gf_verbose_warning)
            printf("Some cell definitions not added to new btree\n");
        GRreport_btree_error(filename);
        return(FALSE);
    }

    /*
        Offer to write out the repaired file.
    */

    if (GRconfirm(GR_P_SaveValCellLib) == TRUE)
        ex$save_module(index = filenum);

    return(TRUE);
}

end implementation GRsmdfhdr;
