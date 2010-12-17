#include "machine.h"
#include "MEMstruct.h"
#include "MEMproto.h"
#include "NFMerrordef.h"
#include "NFMschema.h"
#include "DEBUG.h"
#include "ERR.h"
#include <sys/utsname.h>
#include <errno.h>

long _NFMget_wa_system_info (nodename, username, pathname, node_info, sa_info)
  char    *nodename;   /*  o - Nodename of this machine                      */
  char    *username;   /*  o - CLIX username currently logged in             */
  char    *pathname;   /*  o - Current CLIX working directory                */
  MEMptr  *node_info;  /*  o - Node info for NFMadd_default_working_area     */
  MEMptr  *sa_info;    /*  o - Storage info for NFMadd_default_working_area  */
  {
    auto    long    status;
    auto    char    value[3], s[80];
    auto    char    row_of_data[25];
    auto    char    *p = NULL;
    auto    FILE    *infile = NULL;
    auto    short   defaulting = FALSE;
    auto    struct  utsname name;
    static  char    *fname = "_NFMget_wa_system_info";

    /*  Build the node and storage area info buffers  */

    if ((status = MEMopen (node_info, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    if ((status = MEMwrite_format
        (*node_info, "n_name", "char(18)")) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (node_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    if ((status = MEMwrite_format
        (*node_info, "n_value", "char(1)")) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (node_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    if ((status = MEMopen (sa_info, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        MEMclose (node_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    if ((status = MEMwrite_format
        (*sa_info, "n_name", "char(18)")) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    if ((status = MEMwrite_format
        (*sa_info, "n_value", "char(1)")) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Open the network configuration file  */

    if ((infile = fopen ("/usr/ip32/nfm/config/products", "r")) == NULL)
      {
        _NFMdebug ((fname,
            "unable to open configuration file; defaulting ...\n"));
        defaulting = TRUE;
      }

    /*  Find out if XNS is available (look for INC)  */
/*
    status = system ("dates | grep SS01636 >/dev/null 2>/dev/null");
    _NFMdebug ((fname, "status of XNS (INC) lookup = <%d>\n", status));
*/
    if (defaulting == FALSE)
      {
        if ((fgets (s, sizeof (s), infile)) == NULL)
          {
            _NFMdebug ((fname,
                "error reading configuration file; defaulting XNS to YES\n"));
            defaulting = TRUE;
            strcpy (value, "Y");
          }

        s[1] = NULL;
        strcpy (value, s);
      }
    else
      {
        _NFMdebug ((fname, "defaulting XNS to YES\n"));
        strcpy (value, "Y");
      }

    sprintf (row_of_data, "n_xns\1%s", value);

    if ((status = MEMwrite (*node_info, row_of_data)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Find out if TCPIP is available  */
/*
    status = system ("dates | grep SS01066 >/dev/null 2>/dev/null");
    _NFMdebug ((fname, "status of TCPIP lookup = <%d>\n", status));
*/
    if (defaulting == FALSE)
      {
        if ((fgets (s, sizeof (s), infile)) == NULL)
          {
            _NFMdebug ((fname,
                "error reading configuration file; defaulting TCP to YES\n"));
            defaulting = TRUE;
            strcpy (value, "Y");
          }

        s[1] = NULL;
        strcpy (value, s);
      }
    else
      {
        _NFMdebug ((fname, "defaulting TCP to YES\n"));
        strcpy (value, "Y");
      }

    sprintf (row_of_data, "n_tcpip\1%s", value);

    if ((status = MEMwrite (*node_info, row_of_data)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Default DECNet and NetWare for now  */

    strcpy (row_of_data, "n_decnet\1N");

    if ((status = MEMwrite (*node_info, row_of_data)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    strcpy (row_of_data, "n_netware\1N");

    if ((status = MEMwrite (*node_info, row_of_data)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Find out if NFS is available  */
/*
    status = system ("dates | grep SS01081 >/dev/null 2>/dev/null");
    _NFMdebug ((fname, "status of NFS lookup = <%d>\n", status));
*/
    if (defaulting == FALSE)
      {
        if ((fgets (s, sizeof (s), infile)) == NULL)
          {
            _NFMdebug ((fname,
                "error reading configuration file; defaulting NFS to NO\n"));
            defaulting = TRUE;
            strcpy (value, "N");
          }

        s[1] = NULL;
        strcpy (value, s);
      }
    else
      {
        _NFMdebug ((fname, "defaulting NFS to NO\n"));
        strcpy (value, "N");
      }

    if (infile) fclose (infile);

    sprintf (row_of_data, "n_nfs\1%s", value);

    if ((status = MEMwrite (*node_info, row_of_data)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Put the same value in for the storage area info  */

    if ((status = MEMwrite (*sa_info, row_of_data)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    /*  Get the name of the client (this machine)  */

    if ((status = uname (&name)) < 0)
      {
        _NFMdebug ((fname, "uname = <%d>\n", status));
        _NFMdebug ((fname, "errno = <%d>\n", errno));
        ERRload_struct (NFM, NFM_E_SYSTEM_CALL, "%s", "uname");
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", NFM_E_SYSTEM_CALL));
        return (NFM_E_SYSTEM_CALL);
      }

    strcpy (nodename, name.nodename);

    /*  Get the CLIX username of this user  */

    if ((p = (char *) getenv ("LOGNAME")) == NULL)
      {
        _NFMdebug ((fname, "getenv(LOGNAME) returned NULL\n"));
        ERRload_struct (NFM, NFM_E_SYSTEM_CALL, "%s", "getenv");
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", NFM_E_SYSTEM_CALL));
        return (NFM_E_SYSTEM_CALL);
      }

    strcpy (username, p);

    /*  Get the current working directory  */

    if ((getcwd (pathname, NFM_PATHNAME + 2)) == NULL)
      {
        _NFMdebug ((fname, "getcwd() returned NULL\n"));
        _NFMdebug ((fname, "errno = <%d>\n", errno));
        ERRload_struct (NFM, NFM_E_SYSTEM_CALL, "%s", "getcwd");
        MEMclose (node_info);
        MEMclose (sa_info);
        _NFMdebug ((fname, "returning FAILURE <0x%.8x>\n", NFM_E_SYSTEM_CALL));
        return (NFM_E_SYSTEM_CALL);
      }

    _NFMdebug ((fname, "nodename = <%s>\n", nodename));
    _NFMdebug ((fname, "username = <%s>\n", username));
    _NFMdebug ((fname, "pathname = <%s>\n", pathname));

    _NFMdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }
