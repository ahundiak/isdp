/* #######################    APOGEE COMPILED   ######################## */
/*
Name
   GRretrieve_cell_library

Description
   The purpose of this function is to retreive a cell library.  If
   a cell library exists this function checks to insure that the 
   retreived file has the application string set for a cell library.
   If a new file is created this function sets the application string in
   the cell library.

Arguments
   These arguments are identical to the arguments to ex$retreive_module 
   macro.

   filename[]     IGRchar           The file name to be retreived.
   *file_no       IGRint            The file number
   fstat          IGRint            Type of retreival
                                       EX_old_module
                                       EX_new_module
                                       EX_default
   flag           IGRint            Type of read   
                                       EX_read_only
                                       EX_read_write
                                       EX_read_only | EX_read_write
   *file_access   IGRint            Type of file access granted
                                       GR_SL_READ_ACCESS
                                       GR_SL_READ_WRITE_ACCESS
   *mod_osnum     GRspacenum        The osnum of the retreive cell lib.   
      
Notes 
   The mod_osnum is optional.
   The file_access is optional.

Return Values
   EX_erro              -  failure
   EX_succ              -  success
   GR_E_NO_FILE         -  file did not exist
   GR_E_NO_PREMISSION   -  no premission for operation
   GR_E_NOT_CELL_LIB    -  File was not a cell library

History
   Gray Winn   03/11/88    Creation date
   jhw         12/29/89    Close the old cell lib if old and new 
                           names are the same.
   mrm         10/20/92    add check for possible cell lib corruption on Sun
                           caused by EXNUC bug in 2.0.*
   mrm         10/28/92    removed corruption check - EXNUC is handling it now
   sudha       04/26/94    Purify fix - initialize old_asl_file 
*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "exdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"

#define MAX_APP_STRING  15

extern IGRchar *strrchr();

IGRint   GRretrieve_cell_library ( filenamex, 
                                   file_no, 
                                   fstat, 
                                   flag, 
                                   file_access, 
                                   mod_osnum )
IGRchar     filenamex[];
IGRint      *file_no;
IGRint      fstat;
IGRint      flag;
IGRint      *file_access;
GRspacenum  *mod_osnum;
{
IGRlong     om_msg;
IGRlong     ret_msg;
IGRlong     msg;
IGRchar     app_string[MAX_APP_STRING];
IGRchar     path[DI_PATH_MAX];
GRspacenum  osnum;
GRspacenum  tosnum;
GRobjid     tobjid;
IGRchar     *old_asl_file_name, *new_file_name;
struct GRsymbol_lib_file old_asl_file;
IGRint      old_asl_file_detached = 0;

IGRchar filename[256];
IGRchar *p;

strcpy(filename,filenamex);

p = strstr(filename,"pca4420");
if (p) memcpy(p,"ZZZ",3);

printf(">>>  GRretrieve_cell_library %s\n",filename);
if (1) return EX_erro;

   /* initialize old_asl_file */
   old_asl_file.file_name[0] = NULL;
   old_asl_file.file_no = -1;
   old_asl_file.file_access = FALSE;

   /*
    * Get the new lib's filename (less path).
    */
   if (new_file_name = strrchr(filename, '/') )
   {
     ++new_file_name;
   }
   else 
   {
      new_file_name = filename;
   }
    
   /*
    * If the active cell lib has the same filename as this
    * file the retrieve_cell_library will fail when attempting
    * to create two dir entries with the same name. To avoid 
    * this the active cell lib must be closed.
    */
   om_msg = gr$symget_asl_info ( msg = &ret_msg,
                                 file = &old_asl_file );

   /*
    * If there is an active cell lib.
    */
   if ( om_msg & ret_msg & 1 )
   {
      /*
       * If the new file and old active file's paths are not the same.
       */
      if ( strcmp(old_asl_file.file_name, filename) )
      {
         /*
          * Get the old active lib's filename (less path).
          */
         if (old_asl_file_name = strrchr(old_asl_file.file_name, '/') )
         {
            ++old_asl_file_name;
         }
         else 
         {
            old_asl_file_name = old_asl_file.file_name;
         }

         /*
          * If the filenames are the same.
          */
         if ( !strcmp(old_asl_file_name, new_file_name) )
         {
            /*
             * Close the old cell library.
             */
	    if(old_asl_file.file_no >= 0) /* TR 90N2249 */
	            gr$symclose_cell_library ( file_no = old_asl_file.file_no,
                                       flag = 0 );

            /*
             * Note that the old cell lib was detached.
             */
            old_asl_file_detached = 1;
         }
      }
   }

   if ((fstat == EX_old_module) || (fstat == EX_default))
   {
      /* 
       *  Retrieve the given file if it exists.
       */
      ex$get_cur_mod ( id = &tobjid, osnum = &tosnum);

      DIstmocpy (path, "cell", new_file_name, 0, tosnum);
printf("==> ex$retrieve_module\n");
      om_msg = ex$retrieve_module ( ftype = EX_invisible, 
                                    filename = filename, 
                                    flag = flag, 
                                    msg = (int *)&ret_msg, 
                                    file_no = file_no, 
                                    fstat = EX_old_module, 
                                    type = EX_cell,
                                    mount_name = path );
printf("==< ex$retrieve_module\n");

      if (om_msg & 1)
      {
         if ((ret_msg == EXi_read_from_RO_file) &&
             (flag & EX_read_only))
         {
            if (file_access) *file_access = GR_SL_READ_ACCESS;
         }else
         {
            if (file_access) *file_access = GR_SL_READ_WRITE_ACCESS;
         }

         /* 
          *  The file existed and has been retrived.
          */

         om_msg = ex$get_invis_info_by_index ( index = *file_no,
                                               mod_osnum = &osnum );

         om_msg = ex$mod_info ( mod_osnum = osnum, 
                                mode = EX_INQ, 
                                app = app_string, 
                                applen = MAX_APP_STRING );

         if (mod_osnum) *mod_osnum = osnum;

         if (strcmp (app_string, GR_SYM_LIB_APP_STRING))
         {
            /*
             *  The file was not a cell library.
             */
            ex$close_module (ftype = EX_invisible, index = *file_no);

            ret_msg = GR_E_NOT_CELL_LIB;
         }
         else
         {
#if ValidateBtree
            /* check for (and repair) possible call lib corruption */
            GRvalidate_cell_lib_btree(filename, osnum, *file_no);
#endif

            return(EX_succ);
         }
      }
      else if ((ret_msg == EX_flag) || (ret_msg == EX_inacc_file))
      {
         ret_msg = GR_E_NO_PREMISSION;
      }
      else if (ret_msg == EX_nofile)
      {
         ret_msg = GR_E_NO_FILE;
      }
      else
      {
         ret_msg = EX_erro;
      }

      goto error_occured;
   }

   /*
    *  The file did not exist.
    */

   if ((fstat == EX_new_module) || (fstat == EX_default))
   {
      ex$get_cur_mod ( id = &tobjid, osnum = &tosnum);

      DIstmocpy (path, "cell", new_file_name, 0, tosnum);

      om_msg = ex$retrieve_module ( ftype = EX_invisible,
                                    filename = filename, 
                                    flag = flag, 
                                    msg = (int *)&ret_msg,
                                    file_no = file_no, 
                                    fstat = EX_new_module, 
                                    type = EX_cell,
                                    mount_name = path);

      if ((ret_msg == EXi_read_from_RO_file) &&
          (flag & EX_read_only))
      {
         if (file_access) *file_access = GR_SL_READ_ACCESS;
      }else
      {
         if (file_access) *file_access = GR_SL_READ_WRITE_ACCESS;
      }

      if (om_msg & 1)
      {
         /* 
          *  A new file has been created.
          */
      
         om_msg = ex$get_invis_info_by_index ( index = *file_no,
                                               mod_osnum = &osnum );

         om_msg = ex$mod_info ( mod_osnum = osnum, 
                                mode = EX_SET, 
                                app = GR_SYM_LIB_APP_STRING, 
                                applen = MAX_SYM_LIB_APP_STRING );

         if (mod_osnum) *mod_osnum = osnum;

         if (!(om_msg & 1))
         {
            ex$close_module (ftype = EX_invisible, index = *file_no);
            ret_msg = EX_erro;
         }else
         {
            return(EX_succ);
         }
      }else if ((ret_msg == EX_flag) || (ret_msg == EX_inacc_file))
      {
         ret_msg = GR_E_NO_PREMISSION;
      }

      goto error_occured;      
   }

   ret_msg = EX_erro;

error_occured :

  /*
   * At this point there is an error and the file could not
   * be created or retrieved as a cell lib. The error message
   * is in ret_msg.
   */

  /*
   * Reattach the active cell library if it was detached and
   * make it active.
   */
  if ( old_asl_file_detached )
  {
     msg = gr$symretrieve_cell_library (
                    filename = old_asl_file.file_name,
                    file_no = &old_asl_file.file_no,
                    flag = EX_read_write | EX_read_only,
                    file_access = &old_asl_file.file_access,
                    fstat = EX_old_module );

     om_msg = gr$symput_asl ( msg = &msg,
                              file = &old_asl_file );
  }  
printf("<<<  GRretrieve_cell_library %s\n",filename);

  return (ret_msg);
}

/*\
Name
   GRclose_cell_library

Description
   This function closes a cell library.

Arguments
   file_no     IGRint         The file number
   flag        IGRint         Indicates whether your want to write the
                              object space out to disk.
                                 0  -  do not write
                                 1  -  write

Return Values
   OM_S_SUCCESS         -  success
   OM_E_ABORT           -  failure

History
   Gray Winn   06/13/88    Creation date
\*/

IGRint   GRclose_cell_library (file_no, flag)
IGRint      file_no;
IGRint      flag;
{
IGRlong  om_msg;

   om_msg = ex$close_module (ftype = EX_invisible, index = file_no, 
            flag = flag);
   
   return(om_msg);
}

/*\
Name
   GRsave_cell_library

Description
   This function saves a cell library.

Arguments
   file_no     IGRint         The file number

Return Values
   OM_S_SUCCESS         -  success
   OM_E_ABORT           -  failure

History
   Gray Winn   06/13/88    Creation date
\*/

IGRint   GRsave_cell_library (file_no)
IGRint      file_no;
{
IGRlong  om_msg;

   om_msg = ex$save_module (index = file_no);
   
   return(om_msg);
}
