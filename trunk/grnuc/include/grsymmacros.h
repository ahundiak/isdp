/*
Name
        grsymmacros.h

Description
        This include file defines macros for the symbol package.

History
        hgw     01/01/88    creation
        mrm     06/07/93    added gr$get_cell_def_info
*/

#ifndef  grsymmacros_include
#define  grsymmacros_include



/*
 *  #defines used to describe which function is being invoked.
 */

#define  GRGET_ACTIVE_SYMBOL    0
#define  GRGET_ASL_ENV          1
#define  GRGET_SL_TYPE          2
#define  GRGET_SL_ENV_FROM_OS   3
#define  GRGET_SL_OS_ARRAY      4
#define  GRPUT_ACTIVE_SYMBOL    5
#define  GRPUT_ASL              6
#define  GRSAVE_ASL             7
#define  GRGET_ASL_INFO         8


/*
Name
        gr$sym_sm_place

Description
        This macro is used to place a symbol.

Synopsis
        IGRlong *msg                    return code 
        IGRint num_symbols              the number of symbols to be constructed
        IGRpoint origin[]               the origins of the symbol
        IGRdouble *angle                the angle (in radians)
        IGRdouble scale[]               an array of x,y,z scales
        IGRmatrix rot_matrix            matrix defining the way the symbol
                                        is viewed. (View rotation)
        IGRchar name[]                  the name of the symbol
        unsigned short properties       the properties of the symbol
        struct IGRdisplay *display      ptr to display attributes
        IGRchar *class_attr             class specifiec attributes
        IGRshort level                  the level of the symbol
        struct GRmd_env *symbol_env     original symbol environment
        struct GRmd_env *target_env     environment to construct objects in
        IGRchar *classname              the class name of the symbol
        struct GRid *sdh_id             the symbol definition header
        struct GRid sm_id[]             the new symbol id's

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$sym_sm_place (msg, 
                        num_symbols = 1,
                        origin,
                        angle,
                        scale,
                        rot_matrix,
                        name = NULL,
                        properties = GRIS_NEW | GRIS_DISPLAYABLE |
                                     GRIS_LOCATABLE,
                        display = NULL,
                        class_attr = NULL,
                        level = NULL,
                        symbol_env,
                        target_env,
                        classname = "GRsmhdr",
                        sdh_id,
                        sm_id)         

    GRsmplace ((msg), (num_symbols), (origin), (angle), (scale),
               (rot_matrix), (name), (properties), (display), (class_attr),
               (level), (symbol_env), (target_env), (classname), 
               (sdh_id), (sm_id))
#endomdef


/*
Name
        gr$sym_cl_place

Description
        This macro is used to place a cell.

Synopsis
        IGRlong *msg                    return code 
        IGRint num_cells                the number of cells to be constructed
        IGRpoint origin[]               the origins of the cells
        IGRdouble *angle                the angle (in radians)
        IGRdouble scale[]               an array of x,y,z scales
        IGRmatrix rot_matrix            matrix defining the way the cell
                                        is viewed. (View rotation)
        IGRchar name[]                  the name of the cell
        unsigned short properties       the properties of the cell
        struct IGRdisplay *display      ptr to display attributes
        IGRchar *class_attr             class specifiec attributes
        IGRshort level                  the level of the cell
        struct GRmd_env *symbol_env     original symbol environment
        struct GRmd_env *target_env     environment to construct objects in
        IGRchar *classname              the class name of the cell
        struct GRid *sdh_id             the cell definition header
        struct GRid cl_id[]             the new cell id's

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$sym_cl_place (msg, 
                        num_cells = 1,
                        origin,
                        angle,
                        scale,
                        rot_matrix,
                        name = NULL,
                        properties = GRIS_NEW | GRIS_DISPLAYABLE |
                                     GRIS_LOCATABLE,
                        display = NULL,
                        class_attr = NULL,
                        level = NULL,
                        symbol_env,
                        target_env,
                        classname = "GRclhdr",
                        sdh_id,
                        cl_id)         

    GRclplace ((msg), (num_cells), (origin), (angle), (scale),
               (rot_matrix), (name), (properties), (display), 
               (class_attr), (level), (symbol_env), (target_env),
               (classname), (sdh_id), (cl_id))
#endomdef


/*
Name
        gr$sym_gg_place

Description
        This macro is used to place a graphic group from a cell library.

Synopsis
        IGRlong *msg                    return code 
        IGRint num_gg                   the number of gg to be constructed
        IGRpoint origin[]               the origins of the graphic groups
        IGRdouble *angle                the angle (in radians)
        IGRdouble scale[]               an array of x,y,z scales
        IGRmatrix rot_matrix            matrix defining the way the graphic
                                        group is viewed. (View rotation)
        IGRchar name[]                  the name of the graphic group
        unsigned short properties       the properties of the graphic group
        struct IGRdisplay *display      ptr to display attributes for comp
        IGRchar *class_attr             class specifiec attributes
        IGRshort level                  the level of the graphic group comp
        struct GRmd_env *symbol_env     original symbol environment
        struct GRmd_env *target_env     environment to construct objects in
        IGRchar *classname              the class name of the graphic group
        struct GRid *sdh_id             the graphic group definition header
        struct GRid cl_id[]             the new graphic group id's

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$sym_gg_place (msg, 
                        num_gg = 1,
                        origin,
                        angle,
                        scale,
                        rot_matrix,
                        name = NULL,
                        properties = GRIS_NEW | GRIS_DISPLAYABLE |
                                     GRIS_LOCATABLE,
                        display = NULL,
                        class_attr = NULL,
                        level = NULL,
                        symbol_env,
                        target_env,
                        classname = "GRgrgrp",
                        sdh_id,
                        gg_id)         

    GRggplace ((msg), (num_gg), (origin), (angle), (scale),
               (rot_matrix), (name), (properties), (display), 
               (class_attr), (level), (symbol_env), (target_env),
               (classname), (sdh_id), (gg_id))
#endomdef


/*
Name
        gr$symget_active_symbol

Description
        This macro is used to retreive the active symbol definition.

Synopsis
        IGRlong *msg                                    return code
        struct GRactive_symbol_def *act_symbol_def      the active symbol and
                                                        its environment

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symget_active_symbol (msg, act_symbol_def)

    GRlslmgr_fun ((msg), GRGET_ACTIVE_SYMBOL,
                  (act_symbol_def), GR_ACTIVE_SYMBOL)
#endomdef


/*
Name
        gr$symget_asl_env

Description
        This macro is used to retrieve the active symbol library
        environment.

Synopsis
        IGRlong *msg                return code 
        struct GRmd_env *asl_env    the active symbol library env

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symget_asl_env (msg, asl_env)

    GRlslmgr_fun ((msg), GRGET_ASL_ENV, (asl_env))
#endomdef


/*
Name
        gr$symget_sl_type

Description
        This macro is used to retrieve the symbol library type.
        there are two types of libraries, MULTIPLE LIBRARY TYPE allows
        multiple copies of symbols with the same name, SINGLE LIBRARY
        TYPE allows only one copy of a symbol with a given name.

Synopsis
        IGRlong *msg            return code 
        GRspacenum *sl_osnum    the space number of symbol library
        IGRint *type            the type of symbol library
                                    TRUE  - SINGLE LIBRARY TYPE
                                    FALSE - MULTIPLE LIBRARY TYPE
 
Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symget_sl_type (msg, sl_osnum, type)

    GRlslmgr_fun ((msg), GRGET_SL_TYPE, (sl_osnum), (type))
#endomdef


/*
Name
        gr$symget_sl_env_from_OS

Description
        This macro is used to retrieve the symbol library environment
        of a given object space.

Synopsis
        IGRlong *msg                return code 
        GRspacenum *sl_osnum        the symbol library OS number
        struct GRmd_env *sl_env     the environment of that symbol library
 
Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symget_sl_env_from_OS (msg, sl_osnum, sl_env)

    GRlslmgr_fun ((msg), GRGET_SL_ENV_FROM_OS, (sl_osnum), (sl_env))
#endomdef


/*
Name
        gr$symget_sl_OS_array

Description
        This macro is used to retrieve an array of OS numbers of the attached
        symbol libraries.

Synopsis
        IGRlong *msg                return code 
        GRspacenum *os_array        the array of OS numbers
        IGRint *num_os_array        the number of OS numbers
 
Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symget_sl_OS_array (msg, os_array, num_os_array)

    GRlslmgr_fun ((msg), GRGET_SL_OS_ARRAY, (os_array), (num_os_array))
#endomdef


/*
Name
        gr$symput_active_symbol

Description
        This macro is used to put the active symbol.

Synopsis
        IGRlong *msg                return code 
        IGRchar *symbol_name        the name of the symbol
        struct GRid *symbol_id      the symbol definition id
        struct GRmd_env *asl_env    the active symbol library environment

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symput_active_symbol (msg,
                                symbol_name,
                                symbol_id,
                                asl_env)

    GRlslmgr_fun ((msg), GRPUT_ACTIVE_SYMBOL, (symbol_name),
                  (symbol_id), (asl_env), GR_ACTIVE_SYMBOL)
#endomdef


/*
Name
        gr$symput_asl

Description
        This macro is used to put the active symbol library.

Synopsis
        IGRlong *msg                        return code 
        struct GRsymbol_lib_file *file      the file information structure

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symput_asl (msg, file)

    GRlslmgr_fun ((msg), GRPUT_ASL, (file))
#endomdef


/*
Name
        gr$symsave_asl

Description
        This macro is used to save the active symbol library.

Synopsis
        IGRlong *msg            return code 

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symsave_asl(msg)

    GRlslmgr_fun ((msg), GRSAVE_ASL)
#endomdef


/*
Name
        gr$symget_asl_info

Description
        This macro is used to get information about the active cell library.

Synopsis
        IGRlong *msg                        return code 
        struct GRsymbol_lib_file *file      the file information structure

Return Values
        MSSUCC      -  successful completion
        GR_I_NOSL   -  No active cell library
*/

#omdef gr$symget_asl_info (msg, file)

    GRlslmgr_fun ((msg), GRGET_ASL_INFO, (file))
#endomdef


/*
Name
        gr$symsd_locate_in_all_sl

Description
        This macro is used to perform the locate operation in all symbol 
        libraries.

Synopsis
        IGRlong *msg                return code 
        IGRchar *sd_name            the name of the symbol def to locate
        struct GRmd_env *sl_env     the environment of the located symbol
        struct GRid *sd_id          the object id of the symbol def

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symsd_locate_in_all_sl (msg, sd_name, sl_env, sd_id)

    GRsd_locate_in_all_sl ((msg), (sd_name), (sl_env), (sd_id))
#endomdef


/*
Name
        gr$symsd_locate_in_asl

Description
        This macro is used to perform the locate operation in the active
        symbol library.

Synopsis
        IGRlong *msg                return code 
        IGRchar *sd_name            the name of the symbol def to locate
        struct GRmd_env *sl_env     the environment of the located symbol
        struct GRid *sd_id          the object id of the symbol def

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symsd_locate_in_asl (msg, sd_name, sl_env, sd_id)

   GRsd_locate_in_asl ((msg), (sd_name), (sl_env), (sd_id))
#endomdef


/*
Name
        gr$symsd_locate

Description
        This macro is used to perform the locate operation in any OS.
        This macro requires an ordered array of OS's to search for
        symbol definition in.

Synopsis
        IGRlong *msg                return code 
        IGRint num_OS               the number of OS in the OS array
        GRspacenum *p_OS            the array OS numbers
        IGRchar *sd_name            the name of the symbol def to locate
        OM_S_OBJARRAY *p_OBJARRAY   the array of located symbols from
                                    the first symbol library containing
                                    a symbol def by that name
        GRspacenum *p_loc_OS        the OS number of the symbol
                                    library containing the symbol def

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symsd_locate (msg,
                        num_OS,
                        p_OS,
                        sd_name,
                        p_OBJARRAY,
                        p_loc_OS)

    GRsd_locate ((msg), (num_OS), (p_OS), (sd_name), (p_OBJARRAY),
                 (p_loc_OS))
#endomdef


/*
Name
        gr$symdsd_add

Description
        This macro is used to add a symbol definition to the symbol btree.

Synopsis
        IGRlong *msg                return code 
        GRspacenum sl_osnum         the symbol library object space number
        IGRchar *sd_name            the name of the symbol def
        GRobjid sd_objid            the symbol def objid

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symsd_add (msg,
                     sl_osnum = OM_Gw_current_OS,
                     sd_name,
                     sd_objid)

    GRsd_add ((msg), (sl_osnum), (sd_name), (sd_objid))
#endomdef


/*
Name
        gr$symsd_remove

Description
        This macro is used to remove a symbol definition from the symbol btree

Synopsis
        IGRlong *msg                return code 
        GRspacenum sl_osnum         the symbol library object space number
        IGRchar *sd_name            the name of the symbol def
        GRobjid sd_objid            the symbol def objid

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symsd_remove (msg,
                        sl_osnum = OM_Gw_current_OS,
                        sd_name,
                        sd_objid)

    GRsd_remove ((msg), (sl_osnum), (sd_name), (sd_objid))
#endomdef


/*
Name
        gr$symget_active_point_cell

Description
        This macro is used to retreive the active point cell definition.

Synopsis
        IGRlong *msg                                return code
        struct GRactive_symbol_def *act_cell_def    the active point cell and
                                                    its environment

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symget_active_point_cell (msg, act_cell_def)

    GRlslmgr_fun ((msg), GRGET_ACTIVE_SYMBOL, (act_cell_def), 
                   GR_ACTIVE_POINT_CELL)
#endomdef


/*
Name
        gr$symput_active_point_cell

Description
        This macro is used to put the active point cell.

Synopsis
        IGRlong *msg                    return code 
        IGRchar *cell_name              the name of the new active point cell
        struct GRid *cell_id            the cell definition id
        struct GRmd_env *acl_env        the active cell library environment

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$symput_active_point_cell (msg, cell_name, cell_id, acl_env)

    GRlslmgr_fun ((msg), GRPUT_ACTIVE_SYMBOL, (cell_name),
                  (cell_id), (acl_env), GR_ACTIVE_POINT_CELL)
#endomdef


/*
Name
        gr$symretrieve_cell_library

Description
        This macro is used to retrieve a cell library file.

Synopsis
        IGRchar filename[]          the file name to be retreived
        IGRint *file_no             the file number
        IGRint fstat                type of retreival
                                        EX_old_module
                                        EX_new_module
                                        EX_default
        IGRint flag                 type of read   
                                        EX_read_only
                                        EX_read_write
                                        EX_read_only | EX_read_write
        IGRint *file_access         type of file access granted
                                        GR_SL_READ_ACCESS
                                        GR_SL_READ_WRITE_ACCESS
        GRspacenum *mod_osnum       the osnum of the retreive cell lib.   
      
Notes 
        These arguments are identical to the arguments to the
        ex$retreive_module macro.

        The mod_osnum and file_access args are optional.
      
Return Values
        EX_erro              -  failure
        EX_succ              -  success
        GR_E_NO_FILE         -  file did not exist
        GR_E_NO_PREMISSION   -  no premission for operation
        GR_E_NOT_CELL_LIB    -  File was not a cell library
*/

#omdef gr$symretrieve_cell_library (filename,
                                    file_no,
                                    fstat,
                                    flag,
                                    file_access = NULL,
                                    mod_osnum = (GRspacenum *)NULL)

    GRretrieve_cell_library ((filename), (file_no), (fstat), (flag),
                             (file_access), (mod_osnum))
#endomdef


/*
Name
        gr$symclose_cell_library

Description
        This macro closes a cell library.

Synopsis
        IGRint file_no          the file number
        IGRint flag             indicates whether your want to write the
                                object space out to disk
                                    0  -  do not write
                                    1  -  write

Return Values
        OM_S_SUCCESS         -  success
        OM_E_ABORT           -  failure
*/

#omdef gr$symclose_cell_library (file_no, flag = 0)

    GRclose_cell_library ((file_no), (flag))
#endomdef


/*
Name
        gr$symsave_cell_library

Description
        This macro saves a cell library.

Synopsis
        IGRint file_no          the file number

Return Values
        OM_S_SUCCESS         -  success
        OM_E_ABORT           -  failure
*/

#omdef gr$symsave_cell_library (file_no)

    GRsave_cell_library ((file_no))
#endomdef


/*
Name
        gr$get_cell_def_info

Description
        This function retrieves information about all cell definitions in the
        active cell library.

Synopsis
	int gr$get_cell_def_info(p_count = NULL,
                                 pp_ids = NULL,
                	         pp_names = NULL,
                                 pp_descs = NULL,
                                 pp_timestamps = NULL)

        int *p_count
                Optional output.  If specified, the total number of cell
                definitions.

        struct GRid **pp_ids
                Optional output.  If specified, the ids of the cell
                definitions.  See Notes below for memory information.

        char **pp_names
                Optional output.  If specified, the names of the cell
                definitions.  See Notes below for memory information.

        char **pp_descs
                Optional output.  If specified, the descriptions of the cell
                definitions.  See Notes below for memory information.

        time_t **pp_timestamps
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

Examples
        This example illustrates retrieving the names and descriptions of all
        cell definitions, allowing the function to allocate the memory.

            int sts, i, count;
            char *names, *descs;

            names = NULL;
            descs = NULL;
            sts = gr$get_cell_def_info(p_count = &count,
                                       pp_names = &names, 
                                       pp_descs = &descs);
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

            sts = gr$get_cell_def_info(p_count = &count);
            timestamps = (int *)alloca(sizeof(int) * count);
            ids = (struct GRid *)alloca(sizeof(struct GRid) * count);
            sts = gr$get_cell_def_info(pp_ids = &ids,
                                       pp_timestamps = &timestamps);
            printf("sts = %#x\n", sts);
            printf("count = %d\n", count);
            for (i = 0; i < count; i = i + 1)
            {
                printf("def[%d] = ", i);
                printf("\t[%d, %d]", ids[i].osnum, ids[i].objid);
                printf("\t%d", timestamps[i]);
                printf("\n");
            }
*/

#omdef  gr$get_cell_def_info(p_count = NULL,
                             pp_ids = NULL,
                             pp_names = NULL,
                             pp_descs = NULL,
                             pp_timestamps = NULL)

        GRget_cell_def_info((p_count), (pp_ids),
                            (pp_names), (pp_descs), (pp_timestamps))
#endomdef


#endif
