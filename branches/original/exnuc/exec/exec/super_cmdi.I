class implementation super_cmd;
#include <string.h>
#include <OMerrordef.h>
#include <exmacros.h>
#include <igewindef.h>
#include <igewindow.h>
#include <igewinmacros.h>
#include <exproto.h>

#ifdef SUNOS5
%undef sleep
#endif

extern int EX_help_proc_exist;
/*helpnt*/
extern int Help_topic();

method init(int type;char *str_ptr)
{
    ME.super_cmd->state = 0;
    ME.super_cmd->mytype = type;

    return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
    return(OM_S_SUCCESS);
}

method help()
{

    if( !ige$SR_active() ) 
    {
       if ( EX_help_proc_exist == 0 ) ex$help_init();
       if (strcmp(ME.super_cmd->cmd_key,"CIAcPPCm"))
            Help_topic(ME.super_cmd->cmd_key);/*send help unless COci*/
    }   

    return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
    return(OM_S_SUCCESS);
}

method pre_sleep(int (**dyn_function)();char **additional_info)
{
    *dyn_function = 0;
    *additional_info = 0;
    return(OM_S_SUCCESS);
}

method pre_wakeup(int (*dyn_function)();char *additional_info)
{
    return(OM_S_SUCCESS);
}

method undo()
{
    return(OM_S_SUCCESS);
}

method abort()
{
    return(OM_S_SUCCESS);
}


method execute(int *response;char *response_data; int pos)
{
    return(OM_S_SUCCESS);
}

method help_topic(int flag; char *helptop)
{
  char topic[60];

   strncpy( topic, helptop,40);   /* help limitation */
   topic[40] = '\0';

   /* set help topic  flag = 0 ; inquire flag = 1 */
   if (flag == 0) /* set */
   {
      strncpy(ME.super_cmd->cmd_key,topic,10);
      ME.super_cmd->cmd_key[10] = '\0';
   }
   else if(flag == 1)  /*inq*/
   {
      strcpy(helptop,ME.super_cmd->cmd_key);
   }
   return(OM_S_SUCCESS);
}


/* cmdserver send this message to top cmd to set up cmd 
       name used for help */
method cmd_name( char *cmdname;  char *cmdkey; char *path; int execflag)
{
      /*  - added just for help to use cmdname as help index */
      /*  will be deleted when help use cmd_key as index into help_file */
/*
  int i;

      for(i = 0; i < strlen(cmdname); i++)
      {
         if (cmdname[i] == ' ')   cmdname[i] = '_';
      }
*/
      strcpy(ME.super_cmd->cmd_name,cmdname);
      strncpy(ME.super_cmd->cmd_key,cmdkey,10);
      ME.super_cmd->cmd_key[10] = '\0';
      strcpy(ME.super_cmd->path,path);
      ME.super_cmd->exec_flag = execflag;
      
   return(OM_S_SUCCESS);
}


method form_input( IGRint form_label; IGRchar *value )

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

form_label - an identifier given to the form by the command
             when the form is initialized (FIinit)

value - The value being returned by the form to the command.
gadget_label is in the value structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
{
  return(OM_S_SUCCESS);
}

method status_disp()
{
    ME.super_cmd->form_requested = 1;
    return(OM_S_SUCCESS);
}


method get_command_info( char *cmdname; char *cmdkey; char *path; int *cmdtype; 
                         int *execflag; OM_S_OBJID *form_id; OMuword *form_os)
{
   if( cmdname ) strncpy(cmdname, ME.super_cmd->cmd_name,53);
   if( cmdkey )  strncpy(cmdkey,ME.super_cmd->cmd_key,10);
   if( path )    strncpy(path,ME.super_cmd->path,80);
   if( cmdtype ) *cmdtype = ME.super_cmd->mytype; 
   if( execflag) *execflag =  ME.super_cmd->exec_flag;
   if( form_id ) *form_id  =  ME.super_cmd->form_id;
   if( form_os ) *form_os  =  ME.super_cmd->form_os;      

   return(OM_S_SUCCESS);
}

end implementation super_cmd;
