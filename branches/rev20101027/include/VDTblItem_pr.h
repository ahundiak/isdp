/* $Id */
/*************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDTblItem_pr.h
 *
 * Description:
 *      This code includes following functions which used for item-table
 *      connection
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/17/95          YZ            include file to define item-table
 *                                      connection
 *************************************************************************/

#ifndef  VDTblItem_pr.h
#define  VDTblItem_pr.h

/* ------------------------------------------------------------------------ */
extern IGRlong VD_get_id_env_list(
                           IGRlong  *msg,
                           IGRint   list_size,
                           IGRchar  *dirname,
                           IGRchar  *superClassName,
                           struct   GRid    *id_list,
                           struct   GRmd_env *md_env_list,
                           IGRint   *count,
                           struct   deg_name *Fn_o,
                           IGRint   ref_file);

/* :::
  Abstract
     This function is used to get id and env of given directory in current and
     ref files

  Arguments
     IGRlong            *msg,                 O return code
     IGRint             list_size;            I list size limit
     IGRchar            *dirname;             I given directory name for search
     IGRchar            *superClassName       I super class name of objects
                                                = NULL, (no restrict)
     struct GRid        *id_list;             O object id list
     struct GRmd_env    *md_env_list;         O object env list
     IGRint             *count,               O number of name
     struct deg_name    *Fn_o,                O design file and path name
                                                vdandef.h
     IGRint             ref_file              I =1 for ref / = 0 no ref file

  Example:
        IGRlong                 msg;
        IGRint                  list_size;
        IGRchar                 *dirname;
        IGRchar                 *superClassName,
        struct GRid             *idlist;
        struct GRmd_env         *envlist;
        IGRint                  count;
        struct deg_name         *Fn_o; 
        IGRint                  ref_file = TRUE;

        strcpy(dirname, BOM_str_Dir_name);

        * first to get list_size *
        status =
        VD_get_id_env_list(&msg,
                           0,
                           dirname,
                           superClassName,
                           NULL,
                           NULL,
                           &count,
                           NULL,
                           ref_file);

        list_size = count ;
        * allocate id_list and envlist *

        idlist = (struct GRid *)
                  BSmalloc( count * sizeof(struct GRid));
        envlist = (struct GRmd_env *)
                  BSmalloc( count * sizeof(struct GRmd_env));
        Fn_o = (struct deg_name *)
                  BSmalloc( count * sizeof(struct deg_name));

        *  to get idlist and envlist *
        status =
        VD_get_id_env_list(&msg,
                           list_size,
                           dirname,
                           superClassName,
                           idlist,
                           envlist,
                           &count,
                           Fn_o,
                           ref_file);

         *
         * user need to free islist and envlist after using it
         * here we used the BSmalloc, so user need use BSdealloc
         * also need to include "bsmalloc.h"
         *

        if( idlist ) { BSdealloc((char *) idlist ); }
        if( envlist ) { BSdealloc((char *) envlist ); }
        if( Fn_o ) { BSdealloc((char *) Fn_o ); }

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error

------------------------------------------------------------------------ */
extern IGRlong VD_get_tableName(
                         IGRlong *msg,
                         IGRchar *dirname,
                         IGRchar *superClassName,
                         IGRint  *count,
                         IGRint  ref_file,
                         struct  VD_id_name **IdName);

/* :::
  Abstract
     This function is used to get id and env of BOM table name in current and
     ref files

  Arguments
     IGRlong            *msg,                 O return code
     IGRint             *count,               O number of name
     IGRchar            *dirname,             I direct name table exists
     IGRchar            *superClassName,      I super class name needed to
                                                search
     IGRint             ref_file,             I = 1 has ref file, = 0 no ref
     struct VD_id_name  **IdName              O data struct vdandef.h

  Example:
        IGRlong            msg;
        IGRlong            status;
        IGRint             count;
        IGRchar            dirname[80];
        IGRchar            superClassName[80];
        IGRint             ref_file;
        struct VD_id_name  *IdName;

        strcpy( dirname, "drw_tables");
        strcpy( superClassName, "VDdrwTbl");

        ref_file = 1;
        IdName = NULL;
        count  = 0;

        status =
        VD_get_tableName(&msg, dirname, superClassName, &count,
                                         ref_file, &IdName);

        * free memory *
        if( IdName ) { BSdealloc((char *) IdName ); }

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
#endif
