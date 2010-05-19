/* $Id: VDTbl_Item.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vdtbl/func/VDTbl_Item.I
 *
 * Description:
 *   VDTbl_Item.I includes the functions used for item-table connection
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDTbl_Item.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1995/08/31  17:19:38  pinnacle
# Replaced: vdannot/func/VDTbl_Item.I for:  by yzhu for vds.240
#
# Revision 1.8  1995/08/29  21:25:42  pinnacle
# Replaced: vdannot/func/VD[ApTgsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/08/25  21:18:06  pinnacle
# Replaced: vdannot/func/VDTbl_Item.I for:  by yzhu for vds.240
#
# Revision 1.6  1995/08/18  23:04:08  pinnacle
# Replaced: vdannot/func/*.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/07/25  22:44:58  pinnacle
# Replaced: vdannot/func/VDTbl_Item.I for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/07/13  17:47:18  pinnacle
# Replaced: vdannot/func/VDTbl_Item.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/07/13  13:54:24  pinnacle
# Replaced: vdannot/func/VDTbl_Item.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/06/23  20:43:42  pinnacle
# Replaced: vdannot/func/VDTbl_Item.I for:  by yzhu for vds.240
#
# Revision 1.1  1995/05/18  21:48:48  pinnacle
# Created: vdannot/func/VDTbl_Item.I by yzhu r#
# rno
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/15/95        yzhu            creation date
 ************************************************************************/
class implementation Root;

#include <stdlib.h>
#include <string.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"

#include "exmacros.h"
#include "msmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "growner.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "vdrefmacros.h"

#include "AS_status.h"
#include "vdandef.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"

#define BOM_str_DIR_NAME   "drw_tables"
#define VD_get_S_CanCrea    0x09f78199
#define namelen             80

/* #define DEBUG              1 */


from    ACrg_collect       import  ACgive_structure;

/*  qsort function---------------------------------------------------------*/
int my_strcmp2 ( p_st1, p_st2 )
char **p_st1, **p_st2;
{
        return strcmp ( *p_st1, *p_st2 );
}

/* ---------------------------------------------------------------------------
  Public Function: VD_get_id_env_list

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

        idlist	= _MALLOC ( count , struct GRid );
        envlist = _MALLOC ( count , struct GRmd_env );
        Fn_o	= _MALLOC ( count , struct deg_name );

        *  to get idlist and envlist *
        status =
        VD_get_id_env_list(&msg,
                      list_size,
                      dirname,
                      superClassName,
                      idlist,
                      envlist,
                      &count0,
                      Fn_o,
                      ref_file);

        _FREE ( idlist );
        _FREE ( envlist );
        _FREE ( Fn_o );


 Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
IGRlong VD_get_id_env_list(IGRlong  *msg,
                           IGRint   list_size,
                           IGRchar  *dirname,
                           IGRchar  *superClassName,
                           struct   GRid    *id_list,
                           struct   GRmd_env *md_env_list,
                           IGRint   *count,
                           struct   deg_name *Fn_o, 
                           IGRint   ref_file)
{
IGRlong                 status = OM_S_SUCCESS;
IGRint                  i,j, nb_obj, objAlloc, objCount;
GRname                  classname,
                        curFile,
                        objname;
struct  GRid           *objDump = NULL;
struct  GRid           *objList = NULL;
struct GRmd_env        *objenvList = NULL;
GRspacenum              cur_os = 0;
IGRint                  NbOs;
GRspacenum             *osList  = NULL;
struct GRmd_env        *envList = NULL;
IGRchar                 refFile[DI_PATH_MAX];
IGRlong                 NumberOfBytes,
                        BytesReceived;
struct GRmd_env         mod_env;
struct deg_name        *tem_Fname = NULL; 
IGRchar                *ptr = NULL, *ptr1 = NULL;

        SetProc( VD_get_id_env_list ); Begin
        
        /* initialize */
        *msg = MSSUCC;

        *count = 0;
        objCount = 0;

        /*
         * find the existing BOM objects in current file.
         */
        status =
        ex$get_cur_mod( osnum   = &cur_os );

        di$give_pathname( osnum = cur_os, pathname = curFile );

        __DBGpr_str("pathname", curFile);

        sprintf( objname, "%s:usr:%s:*", curFile, dirname );

        /* allocat objDump in di$dump */
        nb_obj = 0 ;

        status =
        di$dump(        regexp = objname,
                        grids  = (DIgrid **)&objDump,
                        ptr    = &nb_obj );

        NumberOfBytes = sizeof(mod_env);
        BytesReceived = 0;
        gr$get_module_env(      msg    = msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &mod_env,
                                nret   = &BytesReceived);

        if( nb_obj != 0 && status == DIR_S_SUCCESS )
        {
          objList    = _MALLOC ( nb_obj , struct GRid );
          objenvList = _MALLOC ( nb_obj , struct GRmd_env );
          tem_Fname  = _MALLOC ( nb_obj, struct deg_name );

                for(i = 0; i < nb_obj; i ++)
                {
                        objList[i] = objDump[i];
                        objenvList[i] = mod_env;
                        strcpy( tem_Fname[i].fname, &(curFile[1]));
                        sprintf(tem_Fname[i].pname,
                                "%s:usr:%s", curFile, dirname );
                }

                objCount = nb_obj;

                _FREE ( objDump );
        }

        /*
         * osList and envList are  allocated in vd$get_ref_os_list.
         * find the os and env list in the reference file
        */
        if( ref_file ) {
                NbOs = 0 ;
                status = vd$get_ref_os_list(
                                msg             =  msg,
                                main_os         =  &cur_os,
                                num_ref_os      =  &NbOs,
                                ref_os_list     =  &osList,
                                ref_env_list    =  &envList);

                for( j = 0; j < NbOs; j++ ) {
                        /* find ref file path */
                        di$give_pathname( osnum = osList[j],
                                          pathname = refFile );

                        ptr1 = &refFile[0];
                        ptr  = strrchr(ptr1, ':');
                        ptr1 = &ptr[1];

                        /* find ref file  */
                        sprintf( objname , "%s:usr:%s:*",
                                                &(refFile[0]),
                                                dirname );
                        nb_obj = 0 ;
			_FREE ( objDump );

                        status =
                        di$dump(regexp = objname,
                                grids  = (DIgrid **)&objDump,
                                ptr    = &nb_obj );

                        if( nb_obj == 0 || status != DIR_S_SUCCESS ){
				_FREE ( objDump );
                                continue;
                        }

                        objAlloc = objCount + nb_obj;

                        if( objList )
                        {
                          objList = _REALLOC ( objList, objAlloc, struct GRid );
                        }
                        else
                        {
                          objList = _MALLOC ( objAlloc, struct GRid );
                        }

                        if( objenvList )
                        {
                          objenvList = _REALLOC ( objenvList, objAlloc, struct GRmd_env );
                        }
                        else
                        {
                          objenvList = _MALLOC ( objAlloc, struct GRmd_env );
                        }

                        if( tem_Fname )
                        {
                          tem_Fname = _REALLOC ( tem_Fname, objAlloc, struct deg_name );
                        }
                        else
                        {
                          tem_Fname = _MALLOC ( objAlloc, struct deg_name );
                        }

                        for( i = objCount; i < objAlloc; i ++ )
                        {
                                objList[i] = objDump[i - objCount];
                                objenvList[i] = envList[j];
                        	strcpy(tem_Fname[i].fname, ptr1 );
                                sprintf(tem_Fname[i].pname, "%s:usr:%s", refFile, dirname );
                        }

                        objCount += nb_obj;

			_FREE ( objDump );

                } /* for(j < NbOs) */
         } /* if */

        for( i=0 ; i<objCount ; i++ ){
               if( superClassName != NULL) { 
                   /*
                   * test object class. only keep objects their parent is 
                   * superClassName
                   */
                   om$get_classname(    osnum   = objList[i].osnum,
                                        objid   = objList[i].objid,
                                        classname = classname );
                   if( om$is_ancestry_valid(
                        subclassname   = classname,
                        superclassname = superClassName) != OM_S_SUCCESS ){
                        /*
                         * inproper class.
                         */
                        continue;
                   }
                }

                if( id_list ){
                        id_list[*count].objid = objList[i].objid ;
                        id_list[*count].osnum = objList[i].osnum ;
                }


                if( md_env_list ){
                        md_env_list[*count] = objenvList[i] ;
                }

                if( Fn_o ){
                        Fn_o[*count] = tem_Fname[i] ;
                }

                (*count) ++ ;

                if( id_list && ( *count >= list_size ))
                        break;
        }
        
        /*
         * free allocated memory.
         */
	_FREE ( objList );
	_FREE ( objenvList );
	_FREE ( tem_Fname );

	_FREE ( objDump );
	_FREE ( osList );
	_FREE ( envList );

        End
        return status ;

}/*  VD_get_id_env_list */

/* ---------------------------------------------------------------------------
  Public Function: VD_get_tableName

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
  

  	* set up parameters *
  	strcpy( dirname, "drw_tables");
  	strcpy( superClassName, "VDdrwTbl");
  	ref_file = 1;

  	IdName = NULL;
        count  = 0;   

  	status =
  	VD_get_tableName(&msg, dirname, superClassName,
                   &count,ref_file, &IdName);

        * free memory *
        _LOOPFREE ( tablename, count );
        _FREE ( IdName );


  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/

IGRlong VD_get_tableName(IGRlong *msg,
                         IGRchar *dirname, 
     			 IGRchar *superClassName, 
                         IGRint  *count,
                         IGRint  ref_file,
                         struct  VD_id_name **IdName) 
{
IGRlong                 status = OM_S_SUCCESS;
GRspacenum              cur_os;
IGRint                  i, ii, num = 0,j,k;
IGRint                  num1, len;
IGRint                  tflag = FALSE;
IGRint                  list_size, count0;
GRname                  pathName;
struct GRid             dirId;
struct GRid            *idlist  = NULL;
struct GRmd_env        *envlist = NULL;
IGRchar               **tempname = NULL;
IGRchar                 entire_name[80];
struct deg_name        *Fn_o = NULL;
struct VD_id_name      *tem_IdName = NULL; 

   SetProc( VD_get_tableName ); Begin

   *msg = MSSUCC ;
   *count = 0;
   /*
    * check if the directory drw_table is there
    */
   status =
   ex$get_cur_mod( osnum   = &cur_os );

   di$give_pathname( osnum = cur_os, pathname = pathName );

   strcat( pathName, ":usr:" );
   strcat( pathName, dirname );

   __DBGpr_str(" pathname ", pathName );

   dirId.objid = NULL_OBJID;

   /* get director Id */
   status = di$translate(  objname = pathName,
                           p_objid = &dirId.objid,
                           p_osnum = &dirId.osnum );

   if( !(status&1) || dirId.objid == NULL_OBJID ){
                dirId.objid = NULL_OBJID;
                /* make a director Id */
                status = di$mkdir(      dirname = pathName,
                                        p_dirid = &dirId.objid,
                                        p_osnum = &dirId.osnum );

                if( !(status&1 )||( dirId.objid == NULL_OBJID )){
                        ex$message(     msgnumb = VD_get_S_CanCrea,
                                        type = "%s",
                                        var = `pathName` );
                        return( OM_E_ABORT );
                }
   }

   /*
    * create list of it
    */

      /* first to get list_size */
      status =
      VD_get_id_env_list(msg,
                      0,
                      dirname,
                      superClassName,
                      NULL,
                      NULL,
                      &count0,
                      NULL,
                      ref_file);

      if(  count0 == 0 )  goto wrapup; 
      list_size = count0 ;

      /* allocate id_list and envlist */

      idlist	= _MALLOC ( count0 , struct GRid );
      envlist	= _MALLOC ( count0 , struct GRmd_env );
      Fn_o	= _MALLOC ( count0 , struct deg_name );

      /*  to get idlist and envlist */
      status =
      VD_get_id_env_list(msg,
                      list_size,
                      dirname,
                      superClassName,
                      idlist,
                      envlist,
                      &count0,
                      Fn_o,
                      ref_file);

    /* 
     * get name from ID 
    */

    ii=0;
    num = count0;
    
    status= 
    VDmalloc_str_list( &tempname, num, namelen);
    if(!(status&1)) goto wrapup;
    
    tem_IdName = _MALLOC ( num, struct VD_id_name );

    /* get tem_IdName and table name */  
    for( i=0 ; i<num ; i++ )
    {
    	status = 
    	di$untranslate (objname = entire_name,
                        path    = Fn_o[i].pname,    
                        objid   = idlist[i].objid,
                        osnum   = idlist[i].osnum);
    	if(status != DIR_S_SUCCESS){
                        printf("object %d has no name \n", idlist[i].objid);
                        continue;
    	}
    	tempname[ii][0] = '\0';  
    	len = strlen(Fn_o[i].pname);
    	strcpy( tempname[ii], &entire_name[len + 1]);
        tem_IdName[ii].tbl_id = idlist[i];
    	strcpy( tem_IdName[ii].tbl_name, tempname[ii]);
    	strcpy( tem_IdName[ii].deg_file.fname, Fn_o[i].fname);
    	strcpy( tem_IdName[ii].deg_file.pname, Fn_o[i].pname);
    	ii ++;
    }       

    /* allocat  VD_id_name */ 
    num1 = ii;
    (*IdName) = _MALLOC ( num1 , struct VD_id_name );

    /* sort tem_IdName */
    qsort ( tempname, num1, sizeof ( char * ),
                  (int (*) ())my_strcmp2);

    /* set  VD_id_name */ 
    ii = 0;
    for( i=0 ; i<num1 ; i++ ){
       for( j=0 ; j<num1 ; j++ ){
         tflag = FALSE;
         for( k=0 ; k<i ; k++ ){
           if((*IdName)[k].tbl_id.objid == tem_IdName[j].tbl_id.objid &&
              (*IdName)[k].tbl_id.osnum == tem_IdName[j].tbl_id.osnum) 
           {
             tflag = TRUE;
             break;
           } 
         }
         if(!strcmp(tempname[i], tem_IdName[j].tbl_name) && tflag == FALSE) {
              (*IdName)[ii] = tem_IdName[j]; 
              ii = ii + 1;
              break;
         }
      }
    }

    *count = ii; 
    __DBGpr_int( " *count ", *count);

wrapup:

   /* free memory */

   VDfree_str_list( tempname, num );

   _FREE ( envlist );
   _FREE ( idlist );
   _FREE ( Fn_o );
   _FREE ( tem_IdName );

   End
   return status;

} /* VD_get_tableName */
end implementation Root;

