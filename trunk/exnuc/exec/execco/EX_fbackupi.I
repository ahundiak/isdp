/***********************************************************/
/*                                                         */
/*         file_backup                                     */
/*                                                         */
/***********************************************************/

class implementation EX_fbackup;

#include <OMerrordef.h>
#include <OMlimits.h>
#include <exdef.h>
#include <execmsg.h>
#include <exmacros.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <stdio.h>
#include <string.h>
#include <exproto.h>

#ifdef SUNOS5
%undef sleep
#endif

from module    import sleep,wake_up;
from OMFiledOS import write;

#define debug 0
#define rm_debug 0

 
extern struct EX_visible_module *module_table;
extern struct module_params **module_data;
extern OM_S_OBJID EX_exec_id;

method execute ( int *response; char *response_data; int pos)
{       
  char    file[OM_K_MAXOSNAME_LEN],
          nfile[OM_K_MAXOSNAME_LEN],
          fname[OM_K_MAXOSNAME_LEN];
   int  status, i, write_stat, result;

  if(module_table[0].obj_space_num != 0)
  {
     /*** move _BK files to _bk files ***/

      for(i = 0;((i < EX_MAX_MODULES) && (module_table[i].obj_space_num != 0))
                                                                    ;i++ )
      {
          ex$message(msgnumb = EX_M_Backup); 
          backup_filenames(i,nfile,file);
          result = file_exists(file,0,0,fname);
          if( !result )
          {
             EX_mv(file,nfile);
          }

        /*** backup files into _BK files ***/

          ex$message(msgnumb = EX_S_BackupInProg);    	  
/*          ex$message(msgnumb = EX_F_WaitBackup, buff = msgtext);    */
/*          start_waitmsg(msgtext);*/

          status=om$send(mode = OM_e_wrt_object,
                          msg = message module.sleep(1),
                     senderid = EX_exec_id,
                     targetid = module_table[i].module_my_id,
                     targetos = module_table[i].obj_space_num);
          check_error_status(status,
                "IN EXEC file_backup (module.sleep) error");

          write_stat = om$send(mode = OM_e_wrt_object,
                                msg = message OMFiledOS.write(file),
                               senderid = EX_exec_id,
                               targetid = module_table[i].filed_id,
                               targetos = module_table[i].obj_space_num);


          if (!( 1 & write_stat))
          {
              printf("IN EXEC file_backup (OMFiledOS.write) error\n");
              om$report_error(sts = write_stat);
              EX_mv(nfile,file);
              /*UI_error("Backup failed");*/
              ex$message(msgnumb = EX_F_BackupFail);
          }
/*          end_waitmsg();  moved to here to solve white screen problem */
          status=om$send(mode = OM_e_wrt_object,
                          msg = message module.wake_up(2),
                     senderid = EX_exec_id,
                     targetid = module_table[i].module_my_id,
                     targetos = module_table[i].obj_space_num);
          check_error_status(status,
                "IN EXEC file_backup (module.wake_up) error");

          if (1 & write_stat)
          {
             /*** remove _bk files ***/
             result = file_exists(nfile,0,0,fname);
             if( !result )
             {
                EX_rm(nfile);
             }
          } /* if(1&write_stat) */

     } /* for loop */
  
    /* restart journal */ 

    ex$message(msgnumb = EX_S_Clear);    	  

  } /* if(module_table[0].obj_space_num!=0) */
  
  *response = TERMINATE;
  return(1);    
 } /* module_backup */

backup_filenames(mod_num,nfile,file)
 int mod_num;
 char *nfile,*file;
{
    char path[OM_K_MAXOSNAME_LEN],temp[2];
    char os_name[OM_K_MAXOSNAME_LEN];

    strcpy(file,module_data[module_table[mod_num].obj_space_num]->CS_OS_name);
    strcpy(os_name,file);

    valid_filename(file,path);
    if( path[0] != 0 ) 
    {
       strcat(path,file);
       strcpy(file,path);
    }
    strcpy(nfile,file);
    strcat(nfile,"_bk");
    strcat(file,"_BK");
    sprintf(temp,"%d",mod_num);
    strcat(file,temp);
    strcat(nfile,temp);
    return(1);
} /* backup_filenames */


remove_backup(file)
char *file;
{
   int result;
   char fname[OM_K_MAXOSNAME_LEN];


#  if rm_debug
      printf("remove_backup,  does file %s exist?\n",file);
#  endif

   result = file_exists(file,0,0,fname);
   if( !result )
   {

#     if rm_debug 
         printf("remove_backup,  fname  = %s\n",fname );
         printf("remove_backup,  string = %s\n",string);
#     endif
      EX_rm(fname);
   } /* if(!result) */
   return(1);
} /* remove_backup */

end implementation EX_fbackup;
