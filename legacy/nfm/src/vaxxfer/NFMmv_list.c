#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMget_move_files_list (user_id, list)
   long       user_id;
   MEMptr    *list;
   {
char *fname="NFMget_move_files_list ";
     long      status;

     _NFMdebug ((fname,"User Id = <%d>\n", user_id));

     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Open : status = <0x%.8x>\n", status));
	ERRload_struct(NFM,status,"%s","MEMopen");
        return (status);
      }

     status = MEMwrite_format (*list, "n_fileno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_sano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_nodename", "char(30)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_username", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_passwd", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_pathname", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_devicetype", "char(2)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_machid", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_opsys", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_tcpip", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_xns", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_decnet", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilename", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_filetype", "char(15)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilesize", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     status = MEMwrite_format (*list, "n_status", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }
