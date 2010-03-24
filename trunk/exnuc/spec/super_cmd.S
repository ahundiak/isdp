
class specification super_cmd (1:1) of Root;

#include <OMerrordef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>

instance super_cmd
 {
  short state;
  char path[80];
  int mytype;
  int prompt_msg_ind;
  int cmd_msg_ind;
  int status_msg_ind;
  int exec_flag;
  int form_requested;        /* flag indicate status display form requested */
  OM_S_OBJID form_id;        /* status display form object id               */
  OMuword    form_os;        /* aos os number                               */
  char cmd_name[53];       
  char cmd_key[11];     
  char active_form_name[80]; /* name for status display form                */
  channel { (many_to_one, initial=1,increment=5)} cmd;
 };

message init(int type;char *str_ptr);
message wakeup(int pos);
message help();
message sleep(int pos);
message pre_wakeup(int (*dyn_function)();char *additional_info);
message pre_sleep(int (**dyn_function)();char **additional_info);
message undo();
message abort();
message execute(int *response; char *response_data; int pos);
message cmd_name( char *cmdname;  char *cmdkey; char *path; int execflag);
message help_topic(int flag; char *helptop);

message form_input( IGRint form_label;  IGRchar *value );

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

form_label - an identifier given to the form by the command
             when the form is initialized (FIinit) 

value - The value being returned by the form to the command.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

message status_disp();  /* for status display form   */

message get_command_info( char *cmdname; char *cmdkey; char *path; int *cmdtype;
                          int *execflag; OM_S_OBJID *form_id; OMuword *form_os);

reject sleep, wakeup, execute, form_input; 

reject  undo, abort;

end specification super_cmd;
