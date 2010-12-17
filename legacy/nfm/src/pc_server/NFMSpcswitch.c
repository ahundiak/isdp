#include "machine.h"
#include <stdio.h>
#include <errno.h>

#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "UTIstruct.h"
#include "ERR.h"
#include "DEBUG.h"
#include "pc.h"

#if UNIX
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#include "NETstruct.h"
#include "NFMpcproto.h"

long NFMpc_switch_command (in_buffer, out_list)
    char   *in_buffer;
    char   *out_list;
{
  long    status;
  static  char *fname = "NFMSswitch";
  int     in_command ;
  char    *in_list ;
  struct  NETbuffer_info *buffer_info ;
  
  buffer_info = (struct NETbuffer_info *) in_buffer ;
  in_command = buffer_info->request ;

  _NFMSdebug((fname, "ENTER : command : %ld\n", in_command));

  in_list = (char *) ( in_buffer + sizeof (struct NETbuffer_info)) ;
  
/*  _NFMdebug ((fname, "sizeof of header %ld : address of in_buffer %ld: address of in_list is %ld\n",
	      sizeof (struct NETbuffer_info), in_buffer, in_list)) ; */
  
  switch (in_command)
    {
    case PC_LOGIN :
      _NFMSdebug((fname, "NFM_LOGIN = <%ld>\n", in_command));
      status = NFMSpc_log_in (in_list, out_list);
      _NFMSdebug((fname, "NFM_LOGIN DONE : status = <0x%.8x>\n", status));
      break;
      
    case PC_POST_LOGIN :
      _NFMSdebug((fname, "PC_POST_LOGIN = <%ld>\n", in_command));
      status = NFMSpc_post_log_in (in_list, out_list);
      _NFMSdebug((fname, "PC_POST_LOGIN : status = <0x%.8x>\n", status));
      break;
      
    case PC_LOGOUT :
      _NFMSdebug((fname, "NFM_LOGOUT = <%ld>\n", in_command));
      status = NFMSpc_logout (in_list, out_list);
      _NFMSdebug((fname, "NFM_LOGOUT DONE : status = <0x%.8x>\n", status));
      break;

    case PC_COPY_ITEM :
      _NFMSdebug ((fname, "PC_COPY_ITEM = <%ld>\n", in_command)) ;
      status = NFMSpc_copy_item (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_COPY_ITEM : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CHECKOUT_ITEM :
      _NFMSdebug ((fname, "PC_CHECKOUT_ITEM = <%ld>\n", in_command)) ;
      status = NFMSpc_co_item (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CHECKOUT_ITEM : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_CO_ITEM :
      _NFMSdebug ((fname, "PC_CANCEL_CO_ITEM = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_co_item (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_CO_ITEM : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CHECKIN_ITEM :
      _NFMSdebug ((fname, "PC_CI_ITEM = <%ld>\n", in_command)) ;
      status = NFMSpc_ci_item (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CI_ITEM : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_COPY_SET :
      _NFMSdebug ((fname, "PC_COPY_SET = <%ld>\n", in_command)) ;
      status = NFMSpc_copy_set (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_COPY_SET : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CHECKOUT_SET :
      _NFMSdebug ((fname, "PC_CO_SET = <%ld>\n", in_command)) ;
      status = NFMSpc_co_set (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CO_SET : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_CO_SET :
      _NFMSdebug ((fname, "PC_CANCEL_CO_SET = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_co_set (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_CO_SET : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CHECKIN_SET :
      _NFMSdebug ((fname, "PC_CI_SET = <%ld>\n", in_command)) ;
      status = NFMSpc_ci_set (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CI_SET : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_FLAG_ITEM_ARCHIVE :
      _NFMSdebug ((fname, "PC_FLAG_ITEM_ARCHIVE = <%ld>\n", in_command)) ;
      status = NFMSpc_flag_item_archive (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_FLAG_ITEM_ARCHIVE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_FLAG_ITEM_BACKUP :
      _NFMSdebug ((fname, "PC_FLAG_ITEM_BACKUP = <%ld>\n", in_command)) ;
      status = NFMSpc_flag_item_backup (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_FLAG_ITEM_BACKUP : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_FLAG_ITEM_RESTORE :
      _NFMSdebug ((fname, "PC_FLAG_ITEM_RESTORE = <%ld>\n", in_command)) ;
      status = NFMSpc_flag_item_restore (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_FLAG_ITEM_RESTORE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_FLAG_SET_ARCHIVE :
      _NFMSdebug ((fname, "PC_FLAG_SET_ARCHIVE = <%ld>\n", in_command)) ;
      status = NFMSpc_flag_set_archive (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_FLAG_SET_ARCHIVE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_FLAG_SET_BACKUP :
      _NFMSdebug ((fname, "PC_FLAG_SET_BACKUP = <%ld>\n", in_command)) ;
      status = NFMSpc_flag_set_backup (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_FLAG_SET_BACKUP : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_FLAG_SET_RESTORE :
      _NFMSdebug ((fname, "PC_FLAG_SET_RESTORE = <%ld>\n", in_command)) ;
      status = NFMSpc_flag_set_restore (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_FLAG_SET_RESTORE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_ITEM_ARCHIVE :
      _NFMSdebug ((fname, "PC_CANCEL_ITEM_ARCHIVE = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_item_archive(in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_ITEM_ARCHIVE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_ITEM_BACKUP :
      _NFMSdebug ((fname, "PC_CANCEL_ITEM_BACKUP = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_item_backup(in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_ITEM_BACKUP : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_ITEM_RESTORE :
      _NFMSdebug ((fname, "PC_CANCEL_ITEM_RESTORE = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_item_restore(in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_ITEM_RESTORE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_SET_ARCHIVE :
      _NFMSdebug ((fname, "PC_CANCEL_SET_ARCHIVE = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_set_archive (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_SET_ARCHIVE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_SET_BACKUP :
      _NFMSdebug ((fname, "PC_CANCEL_SET_BACKUP = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_set_backup (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_SET_BACKUP : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_CANCEL_SET_RESTORE :
      _NFMSdebug ((fname, "PC_CANCEL_SET_RESTORE = <%ld>\n", in_command)) ;
      status = NFMSpc_cancel_set_restore (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_CANCEL_SET_RESTORE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_VALIDATE_USER_ACCESS :
      _NFMSdebug ((fname, "PC_VALIDATE_USER_ACCESS = <%ld>\n", in_command)) ;
      status = NFMSpc_validate_user_access (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_VALIDATE_USER_ACCESS : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_SET_TO_STATE :
      _NFMSdebug ((fname, "PC_SET_TO_STATE = <%ld>\n", in_command)) ;
      status = NFMSpc_set_to_state (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_SET_TO_STATE : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_ADD_ITEM :
      _NFMSdebug ((fname, "PC_ADD_ITEM = <%ld>\n", in_command)) ;
      status = NFMSpc_add_item (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_ADD_ITEM : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_QUERY_ADD_ITEM :
      _NFMSdebug ((fname, "PC_QUERY_ADD_ITEM = <%ld>\n", in_command)) ;
      status = NFMSpc_query_add_item_attributes (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_QUERY_ADD_ITEM : status = <0x%.8x>\n",
		   status)) ;
      break ;

    case PC_DISPLAY_ITEMS :
      _NFMSdebug ((fname, "PC_DISPLAY_ITEMS = <%ld>\n", in_command)) ;
      status = NFMSpc_display_items (in_list, out_list) ;
      _NFMSdebug ((fname, "PC_DISPLAY_ITEMS : status = <0x%.8x>\n",
		   status)) ;
      break ;

      default :
        _NFMSdebug((fname, "Default = <%ld>\n", in_command));
      _NFMSdebug((fname, "Bad Command : status = <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_BAD_COMMAND, NULL, NULL );
      break;
    }
  
  if (status != NFM_S_SUCCESS )
    {
      _NFMSdebug((fname, "Command Status = <0x%.8x>\n", status));
      return (status);
    }
  
  _NFMSdebug((fname, "SUCCESS : Command Status = <0x%.8x>\n", status));
  return (NFM_S_SUCCESS);
}
 


