/*
Name
        GRget_cell_def_info

Description
        This function retrieves information about all cell definitions in the
        active cell library.

Synopsis
        int *p_count
                Optional output.  If specified, the total number of cell
                definitions.

        struct GRid **p_defs
                Optional output.  If specified, the ids of the cell
                definitions.  See Notes below for memory information.

        char **p_names
                Optional output.  If specified, the names of the cell
                definitions.  See Notes below for memory information.

        char **p_descs
                Optional output.  If specified, the descriptions of the cell
                definitions.  See Notes below for memory information.

        time_t **p_timestamps
                Optional output.  If specified, the creation timestamps of the
                cell definitions.  See Notes below for memory information.

Return Values
        See grmsg.h for definitions of following return codes.

        GR_S_Success - success, count may be zero if no cells are defined in
        the active library.

        GR_F_NoActCelLibDfn - failure, no active cell library

        GR_E_Error - failure

Notes
        All of the arguments are optional.  Passing a NULL pointer for any
        argument suppresses its return.

        Most of the output arguments (except p_count) allow the caller to
        either pass in the memory, or allow the function to malloc the memory.
        If an argument is specified and does not contain NULL, then the
        function assumes that the caller has allocated sufficient memory to
        contain the output data.  Passing a pointer initialized to NULL causes
        the function to malloc the memory (using malloc()); it is then the
        responsibility of the caller to free the memory (using free()).  Note
        that the argument should *always* be initialized to either NULL or to
        memory allocated by the caller; otherwise the function will likely
        overwrite memory at random.

        This function corresponds to the macro gr$get_cell_def_info in
        grsymmacros.h.

Examples
        This example illustrates retrieving the names and descriptions of all
        cell definitions, allowing the function to allocate the memory.

            int sts, i, count;
            char *names, *descs;

            names = NULL;
            descs = NULL;
            sts = GRget_cell_def_info(&count, NULL, &names, &descs, NULL);
            printf("sts = %#x\n", sts);
            printf("count = %d\n", count);
            for (i = 0; i < count; i = i + 1)
            {
                printf("def[%d] = ", i);
                printf("\t%s", &names[MAX_SYMBOL_DEF_NAME * i]);
                printf("\t%s", &descs[MAX_SYMBOL_DEF_DESC * i]);
                printf("\n");
            }
            free(names);
            free(descs);

        This example illustrates retrieving the id and creation timestamp of
        all cell definitions, allocating the memory locally.

            int sts, i, count, *timestamps;
            struct GRid *ids;

            sts = GRget_cell_def_info(&count, NULL, NULL, NULL, NULL);
            timestamps = (int *)alloca(sizeof(int) * count);
            ids = (struct GRid *)alloca(sizeof(struct GRid) * count);
            sts = GRget_cell_def_info(&count, &ids, NULL, NULL, &timestamps);
            printf("sts = %#x\n", sts);
            printf("count = %d\n", count);
            for (i = 0; i < count; i = i + 1)
            {
                printf("def[%d] = ", i);
                printf("\t[%d, %d]", ids[i].osnum, ids[i].objid);
                printf("\t%d", timestamps[i]);
                printf("\n");
            }

History
        mrm     06/04/93    creation
*/

class implementation GRlslmgr;

#include <time.h>
#include <alloca.h>
#include "OMindex.h"
#include "grsymmacros.h"
#include "var.h"
#include "vardef.h"
#include "grmessage.h"

from GRsymbol import GRset_inq_symbol;

int GRget_cell_def_info(int *p_count,           // optional output
                        struct GRid **p_defs,   // optional output
                        char **p_names,         // optional output
                        char **p_descs,         // optional output
                        time_t **p_timestamps)  // optional output
{
    char name[MAX_SYMBOL_DEF_NAME + 1];
    char desc[MAX_SYMBOL_DEF_DESC + 1];
    int sts, msg, i;
    int count = 0;
    long bytes;
    time_t time_stamp;
    struct GRmd_env cell_mod;
    struct GRvar_list list[4];
    OM_S_BTREE_CONTENTS *cell_defs;

    // get information about the active cell library
    sts = gr$symget_asl_env (msg = &msg, asl_env = &cell_mod);
    if (!(sts & msg & 1))
        return(GR_F_NoActCelLibDfn);

    // get a count of the cell definitions in the library
    sts = GRbtreecount(&msg, cell_mod.md_id.osnum, GR_SD_BTREE_NAME, &count);
    if (!(sts & msg & 1))
        return(GR_E_Error);

    // set the output count
    if (p_count)
        *p_count = count;

    if (count < 1)
        return(GR_S_Success);   // no need to go any further

    // check whether the caller is interested in any more info
    if ((p_names == NULL) && (p_descs == NULL) && (p_timestamps == NULL))
        return(GR_S_Success);

    // get a list of all the cell definition objects
    cell_defs = 
        (OM_S_BTREE_CONTENTS *)alloca(sizeof(OM_S_BTREE_CONTENTS) * count);
    sts = GRbtreelocate_all(&msg, cell_mod.md_id.osnum, GR_SD_BTREE_NAME,
                            cell_defs, 0, count, &count);
    if (!(sts & msg & 1))
        return(GR_E_Error);

    // allocate memory if the caller requested the function to do so
    if (p_defs && (*p_defs == NULL) &&
        (*p_defs = (struct GRid *)malloc(sizeof(struct GRid) * count)) == NULL)
        return(GR_E_Error);
    if (p_names && (*p_names == NULL) &&
        (*p_names = 
         (char *)malloc(sizeof(char) * MAX_SYMBOL_DEF_DESC * count)) == NULL)
        return(GR_E_Error);
    if (p_descs && (*p_descs == NULL) &&
        (*p_descs =
         (char *)malloc(sizeof(char) * MAX_SYMBOL_DEF_DESC * count)) == NULL)
        return(GR_E_Error);
    if (p_timestamps && (*p_timestamps == NULL) &&
        (*p_timestamps = (time_t *)malloc(sizeof(time_t) * count)) == NULL)
        return(GR_E_Error);

    // format the data structures used to retrieve the cell definition info
    list[0].var = GR_SYMBOL_NAME;
    list[0].var_ptr = name;
    list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
    list[0].bytes_returned = &bytes;
    list[1].var = GR_SYMBOL_DESC;
    list[1].var_ptr = desc;
    list[1].num_bytes = MAX_SYMBOL_DEF_DESC;
    list[1].bytes_returned = &bytes;
    list[2].var = GR_TIME_STAMP;
    list[2].var_ptr = (IGRchar *) &time_stamp;
    list[2].num_bytes = sizeof (IGRlong);
    list[2].bytes_returned = &bytes;
    list[3].var = END_PARAM;
 
    // loop through the list of cell definitions
    for (i = 0; i < count; i++)
    {
        if (p_defs)
        {
            // add this definition id to the output list
            (*p_defs)[i].osnum = cell_mod.md_id.osnum;
            (*p_defs)[i].objid = cell_defs[i].objid;
        }

        sts = om$send(msg = message GRsymbol.GRset_inq_symbol((IGRlong *)&msg,
                                                              0, list),
                      senderid = NULL_OBJID,
                      targetos = cell_mod.md_id.osnum,
                      targetid = cell_defs[i].objid);

        if (sts & msg & 1)
        {
            // add the info to the output data
            if (p_names) strcpy(&(*p_names)[MAX_SYMBOL_DEF_NAME * i], name);
            if (p_descs) strcpy(&(*p_descs)[MAX_SYMBOL_DEF_NAME * i], desc);
            if (p_timestamps) (*p_timestamps)[i] = time_stamp;
        }
        else
        {
            // return something semi-valid to prevent boo-boos
            if (p_names) (*p_names)[MAX_SYMBOL_DEF_NAME * i] = NULL;
            if (p_descs) (*p_descs)[MAX_SYMBOL_DEF_NAME * i] = NULL;
            if (p_timestamps) (*p_timestamps)[i] = 0;
        }
    }

    return(GR_S_Success);
}

end implementation GRlslmgr;
