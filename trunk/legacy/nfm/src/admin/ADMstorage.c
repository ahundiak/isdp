#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "NETstruct.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include "DEBUG.h"


 ADMget_adm_file_in(user_id, d_sano)
    long       user_id;
    long       d_sano;
       
  {
    FILE        *fopen(), *in_file;
    char        user_path[100];
    char        msg[200];
    char        str[512];
    char        in_ch[40];
    long	    status;
    int         i;
    long        sa_no;
    char        node_name[50], user_name[50], passwd[50];
    char        path_name[50], device_type[10];
    char        mach_id[20], op_sys[20];
    char        net_xns[10], net_tcp [10], net_dec [10];
    char        sql_str[1024];  
    char        **data_ptr;
    char        **data;
    char        **column_ptr;
    MEMptr	out_list   = NULL;
    MEMptr      list = NULL ;

    static char *fname = "ADMget_adm_file_in";    

    _NFMdebug(( fname, "Enter ADMget_file_in\n " ));

    
    status = NFMget_sa_no(user_id, "NFMFILES", &sa_no);
    if (status != NFM_S_SUCCESS)
     {
       ERRload_struct(NFM, NFM_E_FAILURE, "%d",sa_no);
       _NFMdebug ((fname, "No Such Sa No :status = <0x%.8x>\n", NFM_E_FAILURE));
       return(NFM_E_FAILURE);
     }

    status = NFMget_sa_no_info(user_id,sa_no,node_name,user_name,passwd,
                                path_name,device_type, mach_id, 
                                op_sys,net_tcp,net_xns,net_dec );

    if( status != NFM_S_SUCCESS )
    {
      _NFMdebug((fname,"NFMget_sa_no_info 0x%.8x\n", status));
      ERRload_struct(NFM, NFM_E_FAILURE, "%s%s", "VALIDATE", "Failed");
    	return( NFM_E_FAILURE);
    }

    sprintf(user_path, "%s",path_name);
    strcat(user_path,"/NFMtestfile");
      
    if((in_file = fopen (user_path, "w"))==NULL)
     {
       unlink (user_path);
       status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
       _NFMdebug ((fname, "fopen : errno  = <%d>\n", errno));
       _NFMdebug ((fname, "fopen : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
       return (NFM_E_OPEN_FILE);
     }
    
     fprintf(in_file,"This is a test of the validating storage area.\n");
     fclose(in_file);

    status = NFMget_move_files_list(user_id, &list );
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&list);   /**/
       _NFMdebug((fname," NFMget_move_files_list : <0x%.8x>", status));
    	return( NFM_E_FAILURE );
    }
  

/*  Set up buffer to transfer file
 */
    strcpy( str, "0" );                   /* file number not used */
    strcat( str, "\1" );
    sprintf(in_ch,"%d", sa_no);
    strcat( str, in_ch);
    strcat( str, "\1" );
    strcat( str, node_name );      /* node name */
    strcat( str, "\1" );
    strcat( str, user_name );      /* user name */
    strcat( str, "\1" );
    strcat( str,passwd );	    /* password */
    strcat( str,"\1" );
    strcat( str, path_name );	    /* path */
    strcat( str, "\1" );	
    strcat( str, device_type );   /* device type */
    strcat( str, "\1" );
    strcat( str, mach_id );  	    /* machine id */
    strcat( str, "\1" );
    strcat( str, op_sys );	    /* op_sys */
    strcat( str, "\1" );
    strcat( str, net_tcp );		    /* tcp protocol */
    strcat( str, "\1" );	
    strcat( str, net_xns );		    /* xns protocol */
    strcat( str, "\1" );			 
    strcat( str, net_dec );		    /* dec protocol */
    strcat( str, "\1" );	
    strcat( str, user_path );		    /* ci filename */
    strcat( str, "\1" );	
    strcat( str, "NFMoutfile");		    /* co filename */
    strcat( str, "\1" );
    strcat( str, "\1" );
    strcat( str, "-1" );		    /* file size not used */
    strcat( str, "\1" );
    strcat( str, "move" );		    /* file action */
    strcat( str, "\1" );

    status = MEMwrite( list, str);
/*    MEMprint_buffers("list_sa", list, "/dev/console");*/
    if( status != MEM_S_SUCCESS )
    {
       MEMclose(&list);
       ERRload_struct(NFM, NFM_E_MEM, "",NULL);  /**/
      _NFMdebug((fname, " MEMwrite : <0x%.8x>" ,NFM_E_MEM ));
      return(NFM_E_MEM );
    }
 

    status = NFMmove_files_in(user_id, d_sano, "", &list );
    
    /*MEMprint_buffers("list3_sa", list, "/dev/console");*/

       if( status != NFM_S_SUCCESS )
        {
/*        ERRload_struct( NFM, NFM_E_FAILURE, "<0x%.8x>\n",status);*/

/*          ERRload_struct( NFM, status,"%s",);*/
          sprintf(msg,"NFM: Validation for storage area failed.");
          SCdisplay_msg(msg);
          _NFMdebug((fname," Bad transfer file in :<0x%.8x>", status));
          return(status);
         }
     status = NFMundo_move_files_in (user_id, d_sano, "", &list);
     if(status != NFM_S_SUCCESS)
      {
        return (NFM_E_FAILURE);
      }
     status =MEMclose(&list);
     if (status != MEM_S_SUCCESS)
      {
         _NFMdebug((fname,"MEMclose :status = <0x%.8x>\n",status));
         ERRload_struct (NFM, NFM_E_MEM, "%s%s", "VALIDATE", "MEMclose");
         return(status);
      }
 
    _NFMdebug((fname, "%s", "Exit ADMget_adm_file_in : " ));
    
    return( NFM_S_SUCCESS);
}
