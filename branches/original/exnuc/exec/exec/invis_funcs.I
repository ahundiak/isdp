class implementation exec;
#if defined( NT )
#include <io.h>
#endif
#include <string.h>
#include <expriv.h>
#include <exdef.h>
#include <OMerrordef.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <exproto.h>

#ifdef SUNOS5
%undef sleep
#endif

from module    import mod_init, wake_up, sleep, execute_mod;
from OMFiledOS import write, set_state;
from cmdserver import wakeup_cs;


#define debug 0
extern int FEI_set_form_icon_path();
extern struct module_params **module_data;
extern struct EX_invisible_module *invisible_table;
extern struct EX_visible_module *module_table;
extern OM_S_OBJID EX_exec_id;
extern char CS_path_name[];
extern char EX_runname[];
extern uword EX_ACTINV_OS_num;
extern uword EX_dup_os_occured;
extern OM_S_OBJID EX_cmdserver_id;
extern int EX_process_unknowns;
extern int EX_force_product_dload();

int Retrieve_OS(
char  *in_filename,
int   flags, int *file_no,int type,int *msg,
char  *mount_name)
{
   OM_S_FILEDOS_CONSTRUCT_ARGS   os_args;
   OM_S_OBJID                    module_id,
                                 filed_id;
   long Msg;
   int                           status, i, j,
                                 notfound, temp_index,
                                 omflag,
                                 read_only; /* specified flag =
                                               (EX_read_write | EX_read_only)
                                               but file is read only */
   char                          *dilog,
                                 *tttmp;
   uword                         os_num;
   char                          tmp_file[256],
                                 filename[256],
                                 pathn[256],
                                 col[2];
   int                           local_msg;

   strcpy(filename, in_filename);

   os_args.s_name = NULL;                /* pointer to name string */
   os_args.i_initsize = 0;            /* NULL =>use default */
   os_args.i_extsize = 0;             /* negative number=>no extension */
   os_args.i_init_number_objects = 0; /* NULL =>use default */
   os_args.i_extcount = 0;            /* negative number => no extend
                                            total object count */
   os_args.i_number_objs = 0;         /* number of objects in space after
                                            construct. 1=> "fresh OS" */
   read_only = 0;
   omflag = (flags == EX_read_only) ? OM_e_loados_ro : 0;

   if (msg != NULL)
      *msg = EX_erro;

   for (i=0; i<EX_MAX_INVIS_MODULES; i++)
      if (invisible_table[i].obj_space_num == 0)
         break;

   if (i < EX_MAX_INVIS_MODULES)
   {
      module_build_path(filename);
      os_args.s_name = filename;
      dilog = NULL;
      ex$get_cur_mod(osnum = &os_num);
      status = di$give_pathname(osnum = os_num, pathname = tmp_file);
      if (status == DIR_W_NAME_NOT_FOUND)
	printf(" Retrieve_OS di$give_pathname name not found\n");
      else if ( ! (1 & status))
      {
         di$report_error(sts = status, comment = " IN Retrieve_OS");
         return(0);
      }
      else
      {
         col[0] = tmp_file[0];
         col[1] = '\0';
         strcat(tmp_file ,col);
         tttmp = (char *)strrchr(filename,'/');
         if ( type == EX_ref )
            dilog = NULL;
	 else if ( type == EX_cell)
	 {
	    strcat( tmp_file,"cell");
            strcat(tmp_file, col);
            if (tttmp) strcat(tmp_file, tttmp+1);
            dilog = &tmp_file[0];
	 }
      }

      status = om$construct_os(classname = "OMFiledOS",
                                   osnum = &os_num,
                                 p_objid = &filed_id,
                             resultcount = &os_args.i_number_objs,
                                loadmode = omflag,
			       initcount = 1024,
				extcount = 64,
                                  osname = os_args.s_name,
				  sameosflag = 1,
				  di_logical = mount_name);

      if (status==OM_W_OBJSPACE_EXISTS)
      {
/*
         status = om$os_name_to_number(osname = os_args.s_name,
	                              p_osnum = &os_num);
         if( ! (1 & status) )
	 {
	   printf(" Retrieve OS -- OS name to num error\n");
           printf(" OS name = %s\n",os_args.s_name);
           om$report_error(sts = status); 
	   return(0);
         }

         status = om$osnum_to_oso_objid(osnum = os_num, p_objid = &filed_id);
         if( ! (1 & status) )
	 {
	   printf(" Retrieve OS -- OS num to oso objid error\n");
           printf(" OS num = %d\n",os_num);
           om$report_error(sts = status); 
	   return(0);
         }
*/
          notfound = TRUE;
         /* check if in invisible already  */
	  
          for(i=0;i<EX_MAX_INVIS_MODULES;i++)
           if(invisible_table[i].obj_space_num == os_num) break;
    
          if( i != EX_MAX_INVIS_MODULES ) /* in invisible table */
	  {

             if(invisible_table[i].permis_flag != flags)
	     {
	         if( msg != NULL) *msg = EX_flag;
	     	 return(0);
	     }
             else
             {
                if (type != EX_cell) invisible_table[i].numof_opens++;
                *file_no = i;
	        notfound = FALSE;
		if (msg != NULL)
		{
		     *msg = EX_succ;
#ifndef NT
	        if ( access(os_args.s_name,2) != 0 )
                           *msg = EXi_read_from_RO_file;
#else
	        if ( _access(os_args.s_name,2) != 0 )
                           *msg = EXi_read_from_RO_file;
#endif
		}
                if ( (type & EX_ACTINV) == EX_ACTINV ) EX_ACTINV_OS_num = os_num;
                return(1);
	     }
	  }

       /* check file name is in visible table or not                    */
       /* reference file may attach master file as ref file             */
       
         for(i = 0; i< EX_MAX_MODULES && notfound; i++)
         {
            if (!module_data[module_table[i].obj_space_num]) continue;
            if( !strcmp(module_data[module_table[i].obj_space_num]->CS_OS_name, 
                os_args.s_name))   /* same name */
            {
                notfound = FALSE;
      
                for(j=0;((j<EX_MAX_INVIS_MODULES)&&(invisible_table[j].obj_space_num!=0));j++);

                invisible_table[j].obj_space_num=os_num;
                invisible_table[j].module_my_id=module_data[module_table[i].obj_space_num]->module_id;
                invisible_table[j].filed_id = filed_id;
                invisible_table[j].permis_flag=flags;
                invisible_table[j].numof_opens =2; /* put 2 here ,for close_os
		         we do not want to close the master file */
                invisible_table[j].ref_flag = type;
                *file_no = j;
		if (msg != NULL)
		{
		     *msg = EX_succ;
#ifndef NT
		     if ( access(os_args.s_name,2) != 0 )
                                *msg = EXi_read_from_RO_file;
#else
     		     if ( _access(os_args.s_name,2) != 0 )
                                *msg = EXi_read_from_RO_file;
#endif
		}
                if ( (type & EX_ACTINV) == EX_ACTINV ) EX_ACTINV_OS_num = os_num;
		return(1);
            }
         }
         if ( notfound )
	 {
             if (msg != NULL) *msg = EX_nofile;
	     return(0);
	 }
      }
      else if ( status == OM_E_INACCESSABLE_FILE )
      {
         if ( !IGEsractive() )
         {
             printf("Retrieve_OS construct_os <%s>, error\n",os_args.s_name);
             om$report_error(sts = status);
         }
         if (msg != NULL) *msg = EX_inacc_file;
         return(0);
      }
      else
      {
          if (!(1&status))
          {
            if ( !IGEsractive() )
            {
              printf("Retrieve_OS construct_os <%s>, error\n",os_args.s_name);
              om$report_error(sts = status);
            }
            if (msg != NULL) *msg = status;
            return(0);
          }

          if (status != OM_I_READ_FROM_FILE )
          {
	     if( (status == OM_I_DUPLICATE_OS_RO ) ||
	         (status == OM_I_DUPLICATE_OS    )    )	  
             {
                 EX_dup_os_occured = 1;
	     }
             if( ( (status == OM_I_READ_FROM_RO_FILE) || 
	           (status == OM_I_DUPLICATE_OS    )  ||
	           (status == OM_I_DUPLICATE_OS_RO )   )
               &&( (flags & EX_read_only) == EX_read_only ) )
             {
                /* someone specified flag=(EX_read_only | EX_read_write) */
		  if( (flags & EX_read_write) == EX_read_write ) 
		  {
		      read_only = 1;
		  }
	     }
	     else /* we have error */
	     {
                status = om$send(mode = OM_e_wrt_object,
                               msg = message OMFiledOS.set_state(0),
                               senderid = EX_exec_id,
                               targetid = filed_id,
                               targetos = os_num);
                check_error_status(status,
                          "In Retrieve_OS (module.set_state) error");
                if (!(1&status)) return(0);
        
                status = om$send(mode = OM_e_wrt_object,
                               msg = message OMFiledOS.delete(0),
                               senderid = EX_exec_id,
                               targetid = filed_id,
                               targetos = os_num);
                check_error_status(status,
                          "In Retrieve_OS (module.delete) error");
                if (!(1&status)) return(0);
                return(0);
	     }
          } /* if number_objs<=1  */
       if (EX_process_unknowns)
          {
             /* Make sure we've dloaded every product that had
              * an application version stamp in the file we just
              * retrieved.
              */
             if (EX_force_product_dload(&status) && status)
             {
                /* 'status' = count of products we just dloaded --
                 * if 0, we can skip this block of code.
                 */

                ms$init();
/*helpnt*/
                FEI_set_form_icon_path();
                EX_cmddetach( &Msg , -1);
                /* command table */
                local_msg = om$send(mode = OM_e_wrt_object,
                              msg = message cmdserver.wakeup_cs(),
                              senderid = EX_exec_id,
                              targetos = OM_Gw_TransOSnum_0,
                              targetid = EX_cmdserver_id);
            }
          }

	  status = di$give_pathname(osnum = os_num, pathname= pathn);
	  if (! (1&status) )
	  {
	     printf("In Retrieve_OS get di path error osnum =<%d>\n",os_num);
	     di$report_error(sts = status);
	     return(0);
	  }
          DIstrcat(pathn,"IGENOD");
	  DIstrcat(pathn,"MODULE");
	  status = di$translate(objname = pathn, p_objid=&module_id);
          if (!(1&status))
	  {
              di$report_error(sts=status, comment="In Retrieve_OS (translate module id) error");
	      return(0);          
	  }
     
         /* set up before wake up, if wake up failed  clean it up */

          for(i=0;((i<EX_MAX_INVIS_MODULES)&&(invisible_table[i].obj_space_num!=0));i++);
          temp_index = i;
          invisible_table[i].obj_space_num=os_num;
          invisible_table[i].module_my_id=module_id;
          invisible_table[i].filed_id = filed_id;
          invisible_table[i].permis_flag=flags;
          invisible_table[i].numof_opens ++;
          invisible_table[i].ref_flag = type;     

          if ( (type & EX_ACTINV) == EX_ACTINV ) EX_ACTINV_OS_num = os_num;     

          status=om$send(mode = OM_e_wrt_object,
                        msg = message module.wake_up(EX_invisible),
                         senderid = EX_exec_id,
                         targetid = module_id,
                         targetos = os_num);
          check_error_status(status,
                    "In Retrieve_OS (module.wake_up) error");
      
          if( ! ( 1& status) ) /* wake up failed, clean up table */
	  {
              invisible_table[temp_index].obj_space_num=0;
              invisible_table[temp_index].module_my_id=NULL_OBJID;
              invisible_table[temp_index].filed_id = NULL_OBJID;
              invisible_table[temp_index].permis_flag=0;
              invisible_table[temp_index].numof_opens --;
              invisible_table[i].ref_flag = 0;
              EX_ACTINV_OS_num = EX_active_OS_num;
              return(0);
          }
          *file_no = i;
       }
   } /* if(i<EX_MAX_INVIS_MODULES) */
   else 
   {
      printf("Retrieve_OS, Maximum number of modules open \n");
      return(0);
   }
   if (msg != NULL)
   {
       if( read_only ) *msg = EXi_read_from_RO_file;
       else     *msg = EX_succ;
   }
   return(1);
} /* Retrieve_OS */


int Retrieve_new_OS(in_filename, flags, mod_type, file_no, type, msg,
   mount_name)
char  *in_filename;
int   flags, mod_type, *file_no, type, *msg;
char  *mount_name;
{
   OM_S_FILEDOS_CONSTRUCT_ARGS os_args;
   OM_S_OBJID module_id;
   OM_S_OBJID filed_id;
   uword os_num;
   int omflag;
   long Msg;
   int local_msg;
   int status, i, temp_index, numof_supers=0;
   char cmdsvr_class[13], module_class[13],
        tmp_file[256], *listof_supers=NULL;
   char filename[256];
   char *dilog;
   char col[2];
   char *tttmp;
  
   strcpy(filename, in_filename);
   if (flags == EX_read_only)
   {
      omflag = OM_e_loados_ro;
   }
   else
   {
      omflag = 0;
   }

   if( msg != NULL ) *msg = EX_erro;
   for(i=0; i<EX_MAX_INVIS_MODULES; i++)
      if(invisible_table[i].obj_space_num==0)break;

   if (i<EX_MAX_INVIS_MODULES)
   {
      module_build_path(filename);
      os_args.s_name=filename;

      for(i=0;i<13;i++)cmdsvr_class[i]='\0';
      strcpy(cmdsvr_class, "cmdserver");
      get_modtype_data(EX_runname,NULL,module_class,NULL,NULL,NULL);

      dilog = NULL;
      ex$get_cur_mod( osnum = &os_num);
      status = di$give_pathname(osnum = os_num, pathname = tmp_file);
      if( status == DIR_W_NAME_NOT_FOUND )
      {
         printf(" Retrieve_new_OS di$give_pathname name not found\n");
      }
      else if( ! (1 & status) )
      {
         di$report_error(sts = status, comment = " IN Retrieve_new_OS");
         if ( msg != NULL ) *msg = EX_erro;
         return(0);
      }
      else
      {
         col[0] = tmp_file[0];
         col[1] = '\0';
         strcat(tmp_file ,col);
         tttmp = (char *)strrchr(filename,'/');
         if ( type == EX_ref )
         {
	    strcat(tmp_file,"ref");
            strcat(tmp_file, col);
	    if (tttmp) strcat(tmp_file, tttmp+1);
	 }
	 else if ( type == EX_cell)
	 {
	    strcat( tmp_file,"cell");
            strcat(tmp_file, col);
	    if (tttmp) strcat(tmp_file, tttmp+1);
	 }
         dilog = &tmp_file[0];
      }

      status = om$construct_os(classname = "OMFiledOS",
                                 osnum = &os_num,
                               p_objid = &filed_id,
                              loadmode = omflag,
                           resultcount = &os_args.i_number_objs,
			       initcount = 1024,
				extcount = 64,
                                osname = os_args.s_name,
				sameosflag = 1,
				di_logical = mount_name);
      if ( status == OM_E_INACCESSABLE_FILE )
      {
         printf("Retrieve_OS construct_os <%s>, error\n",os_args.s_name);
         om$report_error(sts = status);
         if (msg != NULL) *msg = EX_inacc_file;
         return(0);
      }
      else  if (!(1&status))
      {
         printf(" Retrieve_new_OS construct_os <%s>, error\n",os_args.s_name);
         om$report_error(sts = status);
         if( msg != NULL ) *msg = EXe_os_construct;
         if( status == OM_F_VERSION_MISMATCH)
         {
            if( msg != NULL ) *msg = EXe_ver_mis;
         }
         return(0);
      }

      if (status == OM_I_READ_FROM_FILE )
      {
         status = om$send( mode = OM_e_wrt_object,
                          msg = message OMFiledOS.set_state(0),
                     senderid = EX_exec_id,
                     targetid = filed_id,
                     targetos = os_num);
         check_error_status(status,"IN Retrieve_new_OS (module.set_state) error");
         if (!(1&status))
         {
            if( msg != NULL ) *msg = EX_erro;
            return(0);
         }

         status = om$send(mode = OM_e_wrt_object,
                         msg = message OMFiledOS.delete(0),
                       senderid = EX_exec_id,
                       targetid = filed_id,
                       targetos = os_num);
         check_error_status(status,
                  "In Retrieve_new_OS (module.delete) error");
         if (!(1&status))
         {
            if( msg != NULL ) *msg = EX_erro;
            return(0);
         }

         printf("Retrieve_new_OS, file already exists \n");
         if( msg != NULL ) *msg = EX_erro;
         return(0);
      } /* if number_objs>1  */

      if (EX_process_unknowns)
      {
         if (EX_force_product_dload(&status) && status)
         {
            ms$init();
            FEI_set_form_icon_path();
            EX_cmddetach( &Msg , -1);
            /* command table */
            local_msg = om$send(mode = OM_e_wrt_object,
                          msg = message cmdserver.wakeup_cs(),
                  senderid = EX_exec_id,
                  targetos = OM_Gw_TransOSnum_0,
                  targetid = EX_cmdserver_id);
         }
      }
      status = om$construct(osname = os_args.s_name,
                       classname = module_class,
                         p_objid = &module_id,
                        neighbor = OM_GS_NULL_NEIGHBOR);

      check_error_status(status,"IN Retrieve_new_OS (module.construct) error");
      if (!(1&status))
      {
         if( msg != NULL ) *msg = EXe_mod_construct;
         return(0);
      }

      status = om$send(mode = OM_e_wrt_object,
                     msg = message module.mod_init(mod_type,cmdsvr_class,
		            numof_supers,listof_supers,EX_invisible),
                     senderid = EX_exec_id,
                     targetid = module_id,
                     targetos = os_num);
      check_error_status(status,"IN Retrieve_new_OS (module.init) error");
      if (!(1&status))
      {
         if( msg != NULL ) *msg = EXe_module_init;
         return(0);
      }

      /* set up before wake up, if wake up failed  clean it up */

      for(i=0;((i<EX_MAX_INVIS_MODULES)&&(invisible_table[i].obj_space_num!=0));i++);
      temp_index = i;
      invisible_table[i].obj_space_num=os_num;
      invisible_table[i].module_my_id=module_id;
      invisible_table[i].filed_id = filed_id;
      invisible_table[i].permis_flag=flags;
      invisible_table[i].numof_opens++;
      invisible_table[i].ref_flag = type;

      if ((type & EX_ACTINV) == EX_ACTINV)
         EX_ACTINV_OS_num = os_num;     

      status=om$send(mode = OM_e_wrt_object,
                   msg = message module.wake_up(EX_invisible),
                   senderid = EX_exec_id,
                   targetid = module_id,
                   targetos = os_num);
      check_error_status(status, "IN Retrieve_new_OS (module.wake_up) error");

      if( ! ( 1& status) ) /* wake up failed, clean up table */
      {
         invisible_table[temp_index].obj_space_num = 0;
         invisible_table[temp_index].module_my_id = NULL_OBJID;
         invisible_table[temp_index].filed_id = NULL_OBJID;
         invisible_table[temp_index].permis_flag = 0;
         invisible_table[temp_index].numof_opens--;
         invisible_table[i].ref_flag = 0;
         if (msg != NULL)
            *msg = EXe_module_wakeup;
         EX_ACTINV_OS_num = EX_active_OS_num;
         return(0);
      }
      *file_no = i;
   } /* if(i<EX_MAX_INVIS_MODULES) */
   else 
   {
      printf("Retrieve_new_OS, Maximum number of modules open \n");
      if (msg != NULL)
         *msg = EXe_max_module;
      return(0);
   }
   if (msg != NULL)
      *msg = EX_succ;
   return(1);
} /* Retrieve_new_OS */


int Close_OS(mod_num, flag)
 int mod_num;   /* index of invisible table */
 int flag;	/* 0 = don't write   1 = write   4 = EX_ACTINV */
 {
    int status;
    int notfound,i;
    int local_flag;
    char tmp_file[OM_K_MAXOSNAME_LEN];

    notfound = TRUE;

   if (( mod_num < 0 ) || (mod_num >= EX_MAX_INVIS_MODULES))
     {
     return(0);
     }

   local_flag = flag & ~EX_ACTINV; 


  /* check file name is in visible table or not                    */
  /* reference file may attach master file as ref file             */
  
    for(i = 0; i< EX_MAX_MODULES && notfound; i++)
    {
       if( module_data[module_table[i].obj_space_num] && 
            !strcmp(module_data[module_table[i].obj_space_num]->CS_OS_name, 
            module_data[invisible_table[mod_num].obj_space_num]->CS_OS_name))
       {
           notfound = FALSE;
           if(invisible_table[mod_num].numof_opens > 2) 
	   {
              invisible_table[mod_num].numof_opens--;
	   }
           else
           {
              invisible_table[mod_num].obj_space_num = 0;
              invisible_table[mod_num].filed_id = NULL_OBJID;
              invisible_table[mod_num].module_my_id = NULL_OBJID;
              invisible_table[mod_num].permis_flag = 0;
              invisible_table[mod_num].numof_opens = 0;
              invisible_table[mod_num].ref_flag = 0;
	   }
           return(1);
       }
    }
   


  if(invisible_table[mod_num].numof_opens > 1) 
  {
     invisible_table[mod_num].numof_opens--;
  }
  else
  {
    status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.set_state(local_flag),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].filed_id,
                     targetos = (uword)invisible_table[mod_num].obj_space_num);
    check_error_status(status,
                "IN Close_OS (module.set_state) error");
    if (!(1&status)) return(0);

    strcpy(tmp_file,
           module_data[invisible_table[mod_num].obj_space_num]->CS_OS_name);

    status=om$send(mode = OM_e_wrt_object,
                   msg = message module.sleep(0),
                   senderid = EX_exec_id,
                   targetid = invisible_table[mod_num].module_my_id,
                   targetos = invisible_table[mod_num].obj_space_num);
    check_error_status(status,"IN Close_OS (module.sleep) error");

    if ( (flag & EX_ACTINV) == EX_ACTINV ) EX_ACTINV_OS_num = EX_active_OS_num;

    if (!(1&status)) return(0);
  
    if( local_flag == 1 ) /* write */
    {
        status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.write(tmp_file),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].filed_id,
                     targetos = invisible_table[mod_num].obj_space_num);
        check_error_status(status,
                "IN Close_OS (module.write) error");
/*       if (!(1&status)) return(0);   TR 119420336   -Mohan  */
       local_flag = 0; 
       status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.set_state(local_flag),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].filed_id,
                     targetos = invisible_table[mod_num].obj_space_num);
       check_error_status(status,
                "IN Close_OS (module.set_state) error");
       if (!(1&status)) return(0);
         
    }
    status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.delete(0),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].filed_id,
                     targetos = invisible_table[mod_num].obj_space_num);
    check_error_status(status,
                "IN Close_OS (module.delete) error");
    if (!(1&status))
    {
       status=om$send(mode = OM_e_wrt_object,
                     msg = message module.wake_up(EX_invisible),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].module_my_id,
                     targetos = invisible_table[mod_num].obj_space_num);
       check_error_status(status,"IN Close_OS (module.wake_up) error");
       if (!(1&status)) return(0);
    }
    invisible_table[mod_num].obj_space_num = 0;
    invisible_table[mod_num].filed_id = NULL_OBJID;
    invisible_table[mod_num].module_my_id = NULL_OBJID;
    invisible_table[mod_num].permis_flag = 0;
    invisible_table[mod_num].numof_opens = 0;
    invisible_table[mod_num].ref_flag = 0;    
  }

  return(1);
} /* Close_OS */


int Save_OS(mod_num)
 int mod_num;
 {
  int status;
  char tmp_file[OM_K_MAXOSNAME_LEN];
  
  if(invisible_table[mod_num].permis_flag != EX_read_only) 
  {
     strcpy(tmp_file,
         module_data[invisible_table[mod_num].obj_space_num]->CS_OS_name);

     status=om$send(mode = OM_e_wrt_object,
                   msg = message module.sleep(1),
                   senderid = EX_exec_id,
                   targetid = invisible_table[mod_num].module_my_id,
                   targetos = invisible_table[mod_num].obj_space_num);
     check_error_status(status, "IN Save_OS (module.sleep) error");
     if (!(1&status)) return(0);
     status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.write(tmp_file),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].filed_id,
                     targetos = invisible_table[mod_num].obj_space_num);
     check_error_status(status,
                "IN Save_OS (module.write) error");
     if (!(1&status))
     {
          /*UI_status("File not saved");*/
          ex$message(msgnumb = EX_S_FileNotSave);
     }
     status=om$send(mode = OM_e_wrt_object,
                   msg = message module.wake_up(2),
                   senderid = EX_exec_id,
                   targetid = invisible_table[mod_num].module_my_id,
                   targetos = invisible_table[mod_num].obj_space_num);
     check_error_status(status, "IN Save_OS (module.wake_up) error");
     if (!(1&status)) return(0);
   }
   else
   {
       printf("Save_OS,flag = read_only\n");
       return(0);
   }
   return(1);
 } /* Save_OS */
 

int Save_As_OS(mod_num,filename)
 int mod_num;
 char *filename;
 {
  int result,status;
  char string[OM_K_MAXOSNAME_LEN];
  char fname[OM_K_MAXOSNAME_LEN];


  strcpy(string,filename);
  module_build_path(string);
  
  result=file_exists(string,0,0,fname);
  if( ((!result)&&(invisible_table[mod_num].permis_flag == EX_overwrite)) ||
       ((result)&&(invisible_table[mod_num].permis_flag != EX_read_only)) )
  {


    status=om$send(mode = OM_e_wrt_object,
                   msg = message module.sleep(1),
                   senderid = EX_exec_id,
                   targetid = invisible_table[mod_num].module_my_id,
                   targetos = invisible_table[mod_num].obj_space_num);
    check_error_status(status,
             "IN Save_As_OS (module.sleep) error");
    if (!(1&status)) return(0);
  
    status = om$change_os_name( osnum = invisible_table[mod_num].obj_space_num,
                           new_osname = string,
                            overwrite = OM_e_overwrite);

    check_error_status(status, "OM_change_OS_name error");
    if (!(1&status)) return(0);

    status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.write(string),
                     senderid = EX_exec_id,
                     targetid = invisible_table[mod_num].filed_id,
                     targetos = invisible_table[mod_num].obj_space_num);
    check_error_status(status, "IN Save_As_OS (module.write) error");

    /* change name back to original */
    status = om$change_os_name( osnum = invisible_table[mod_num].obj_space_num,
                 new_osname = module_data[invisible_table[mod_num].obj_space_num]->CS_OS_name,
                            overwrite = OM_e_overwrite_rrr);

    check_error_status(status, "OM_change_OS_name error");


    status=om$send(mode = OM_e_wrt_object,
                   msg = message module.wake_up(EX_invisible),
                   senderid = EX_exec_id,
                   targetid = invisible_table[mod_num].module_my_id,
                   targetos = invisible_table[mod_num].obj_space_num);
    check_error_status(status,"IN Save_As_OS (module.wake_up) error");
    if (!(1&status)) return(0);
  } /* EX_overwrite */
  else 
  {
     printf("Save_As _OS, flag != overwrite\n");
     return(0);
  }

  return(1);
 } /* Save_As_OS */


int EX_retrieve_os (
char  *in_filename,
int   flag, int mod_type,int *file_no, int f_stat,int  type,int *msg,
char  *mount_name)


/****************************************************************************/
/* type can be EX_ref, EX_cell or EX_ACTINV                                 */
/* EX_ACTINV for pdu to retrieve invisible file but treat it as master file */
/* for cyclic reference file stuff   *                                      */
/****************************************************************************/
{
   int   status, notfound, i;
   char  new_string[OM_K_MAXOSNAME_LEN],
         filename[256];

   strcpy(filename, in_filename);
   mod_type = -1; 
   module_build_path(filename); 
   notfound = TRUE;

   status = file_exists(filename, 0, 0, new_string);
   if (status >= 0) /* file exists */
   {
      if (f_stat == EX_new_module)
      {
         status = 0;
         goto wrapup;
      }
      status = Retrieve_OS(filename, flag, file_no, type, msg, mount_name);
   }
   else  /* file is not on disk */
   {
      if (f_stat == EX_old_module)
      {

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*        these code were add because of attach new master file as    */
/*        ref file, but the master file is not written out yet        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

         /* check if in master file table */
         for (i = 0; i< EX_MAX_MODULES && notfound; i++)
         {
            if(!module_data[module_table[i].obj_space_num]) continue;
            if (!strcmp(module_data[module_table[i].obj_space_num]->CS_OS_name, 
                filename ))   /* same name */
            {
               notfound = FALSE;
               status = Retrieve_OS(filename, flag, file_no, type, msg,
                  mount_name);
               return(status);
            }
         }

	 /* check if in invisible table */
         for (i=0; ((i<EX_MAX_INVIS_MODULES) &&
            (invisible_table[i].obj_space_num!=0)); i++)
	 {
            if(!module_data[invisible_table[i].obj_space_num]) continue;
            if (!strcmp(module_data[invisible_table[i].obj_space_num]->
                  CS_OS_name, filename ))   /* same name */
            {
               notfound = FALSE;
               status = Retrieve_OS(filename, flag, file_no, type, msg,
                  mount_name);
               return(status);
            }
         }
         status = 0; 
	 if (msg)
	    *msg = EX_nofile; 
      }
      else 
          status = Retrieve_new_OS(filename, flag, mod_type, file_no,
            type, msg, mount_name);
   }
    
wrapup:
   return(status);
}


print_invis()
{
   int j, num;
   extern char *getenv();
   extern int atoi();
   char *temp,NA[10];

   num = 3;
   temp = getenv("EX_INVIS");
   if( temp != 0)
   {
      strcpy( NA,temp);
      num = atoi(NA);
   }
   for( j = 0; j<num; j++)
   {
     printf("\ninvisible_table[%d].obj_space_num=%d\n",j,invisible_table[j].obj_space_num);
     printf("invisible_table[%d].filed_id =%d\n",j,invisible_table[j].filed_id);
     printf("invisible_table[%d].permis_flag=%d\n",j,invisible_table[j].permis_flag);
     printf("invisible_table[%d].numof_opens=%d\n",j,invisible_table[j].numof_opens);
     printf("invisible_table[%d].ref_flag =%d\n",j,invisible_table[j].ref_flag);
   }
   return(1);
}


end implementation exec;
