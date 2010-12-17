#include "machine.h"
#define INCLUDE_EXTERN	1
#include "NETnet_inc.h"

int NETfmu_con_send(node_name,user_name,passwd , src_file , dst_file,attribute,file_size)
  char  *node_name;
  char  *user_name;        /* decrypted user_name */
  char  *passwd;           /* decrypted password  */
  char  *src_file ;
  char *dst_file ;
  char *attribute;
  int *file_size ;
  {
    char *fname="NETfmu_con_send ";
    int     status;

    _NETCdebug ((fname,"NodeName <%s> Username <%s> password <%s>\n\
src_file <%s> dst_file <%s> attribute <%s> file_size <%d>\n", node_name,user_name,"NOT PRINTED",src_file,dst_file,attribute,*file_size));
    _NETSdebug ((fname,"NodeName <%s> Username <%s> password <%s>\n\
src_file <%s> dst_file <%s> attribute <%s> file_size <%d>\n", node_name,user_name,"NOT PRINTED",src_file,dst_file,attribute,*file_size));

    status = NETfmu_connect(node_name,user_name,passwd);
    if(status != NET_S_SUCCESS) return(status);
    status = NETfmu_send(src_file,dst_file,attribute,file_size);
    if(status != NET_S_SUCCESS) return(status);
    status = NETfmu_disconnect();
    if(status != NET_S_SUCCESS) return(status);
    _NETCdebug((fname,"SUCCESSFUL status = <0x%.8x>\n",NET_S_SUCCESS));
    _NETSdebug((fname,"SUCCESSFUL status = <0x%.8x>\n",NET_S_SUCCESS));
    return(NET_S_SUCCESS);
  }
int NETfmu_con_receive(node_name,user_name,passwd , src_file , dst_file,attribute,file_size)
  char  *node_name;
  char  *user_name;        /* decrypted user_name */
  char  *passwd;           /* decrypted password  */
  char  *src_file ;
  char *dst_file ;
  char *attribute;
  int *file_size ;
  {
    char *fname="NETfmu_con_receive ";
    int     status;

    _NETCdebug ((fname,"NodeName <%s> Username <%s> password <%s>\n\
src_file <%s> dst_file <%s> attribute <%s> file_size <%d>\n", node_name,user_name,"NOT PRINTED",src_file,dst_file,attribute,*file_size));
    _NETSdebug ((fname,"NodeName <%s> Username <%s> password <%s>\n\
src_file <%s> dst_file <%s> attribute <%s> file_size <%d>\n", node_name,user_name,"NOT PRINTED",src_file,dst_file,attribute,*file_size));
	
    status = NETfmu_connect(node_name,user_name,passwd);
    if(status != NET_S_SUCCESS) return(status);
    status = NETfmu_receive( src_file , dst_file,attribute,file_size);
    if(status != NET_S_SUCCESS) return(status);
    status = NETfmu_disconnect();
    if(status != NET_S_SUCCESS) return(status);
    _NETCdebug((fname,"SUCCESSFUL status = <0x%.8x>\n",NET_S_SUCCESS));
    _NETSdebug((fname,"SUCCESSFUL status = <0x%.8x>\n",NET_S_SUCCESS));
    return(NET_S_SUCCESS);
  }

int NETfmu_connect(node_name,user_name,passwd )
  char  *node_name;
  char  *user_name;        /* decrypted user_name */
  char  *passwd;           /* decrypted password  */
  {
    char *fname="NETfmu_connect";
    int     status;
    char    *c_status;
    char    connect_string[128];

    _NETCdebug ((fname,"NodeName <%s> Username <%s> password <%s>\n",
node_name,user_name,"NOT PRINTED"));
    _NETSdebug ((fname,"NodeName <%s> Username <%s> password <%s>\n",
node_name,user_name,"NOT PRINTED"));

    if (strlen (passwd))
      sprintf (connect_string, "%s.%s.%s", node_name, user_name, passwd);
    else
      sprintf (connect_string, "%s.%s", node_name, user_name);


    c_status = (char *) fmu_connect (connect_string);
    if (c_status)
     {
       status = NET_E_FMU_CONNECT;
	ERRload_struct(NETS,status,"%s",c_status);
       _NETCdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       _NETSdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       return (status);
     }
     status = NET_S_SUCCESS ;
       _NETCdebug ((fname,"Successful : status <0x%.8x>\n",status));
       _NETSdebug ((fname,"Successful : status <0x%.8x>\n",status));
    return(status);
}
NETfmu_disconnect()
{
	char *c_status;
        long status;
        char *fname="NETfmu_disconnect";

       _NETCdebug ((fname,"Entry : \n"));
       _NETSdebug ((fname,"Entry : \n"));


    c_status = (char *) fmu_disconnect ();
    if (c_status)
     {
       status = NET_E_FMU_DISCONNECT;
	ERRload_struct(NETS,status,"%s",c_status);
       _NETCdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       _NETSdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       return (status);
     }
	status = NET_S_SUCCESS ;
       _NETCdebug ((fname,"Successful : status <0x%.8x>\n",status));
       _NETSdebug ((fname,"Successful : status <0x%.8x>\n",status));

    return (NET_S_SUCCESS);
}

NETfmu_rcmd(command)
char *command;
{
	char *c_status ;
	int status ;
	FILE *fp_devnull,*fp_dummy;
	int fd_save,fd_dummy;
	char *fname="NETfmu_rcmd";
       _NETCdebug ((fname,"Entry : command <%s> \n",command));
       _NETSdebug ((fname,"Entry : command <%s> \n",command));

/* Save the stdout and reset it to /dev/null temporarily */
    fd_save = dup(1);
    if(fd_save < 0 )
    {
	_NETCdebug((fname,"dup(1) return status <%d>\n",fd_save));
	_NETSdebug((fname,"dup(1) return status <%d>\n",fd_save));
        status = NET_E_FMU_RCMD;
        ERRload_struct(NETS,status,"%s","Cannot reset stdout to /dev/null temporarily");
        return (status);
    }
    else
    {
	_NETCdebug((fname,"dup(1) return status <%d>\n",fd_save));
	_NETSdebug((fname,"dup(1) return status <%d>\n",fd_save));
    }
    if((fp_devnull = freopen("/dev/null","w",stdout)) == (FILE *)0)
    {
	_NETCdebug((fname,"freopen Call failed to set stdout to /dev/null\n"));
	_NETSdebug((fname,"freopen Call failed to set stdout to /dev/null\n"));
        status = NET_E_FMU_RCMD;
        ERRload_struct(NETS,status,"%s","Cannot reset stdout to /dev/null temporarily");
	close(fd_save);
        return (status);
    }

    c_status = (char *) fmu_rcmd (command);
    fclose(fp_devnull);
    fd_dummy=dup2(fd_save,1);
    close(fd_save);
    if(fd_dummy < 0 )
    {
	_NETCdebug((fname,"dup2(fd_save,1) return status <%d>\n",fd_dummy));
	_NETSdebug((fname,"dup2(fd_save,1) return status <%d>\n",fd_dummy));
	_NETCdebug((fname,"CATASTROPHIC ERROR STDOUT NOT RESET. THIS WILL\
 CAUSE ALL STDOUT TO GO TO /DEV/NULL\n"));
	_NETSdebug((fname,"CATASTROPHIC ERROR STDOUT NOT RESET. THIS WILL\
 CAUSE ALL STDOUT TO GO TO /DEV/NULL\n"));
        status = NET_E_FMU_RCMD;
        ERRload_struct(NETS,status,"%s","Cannot reset stdout to original setting");
        return (status);
    }
    else
    {
	_NETCdebug((fname,"dup2(fd_save,1) return status <%d>\n",fd_dummy));
	_NETSdebug((fname,"dup2(fd_save,1) return status <%d>\n",fd_dummy));
    }
/* KT - 8/11/92  Must type fdopen */
    if((fp_dummy = (FILE *) fdopen(1,"w")) == (FILE *)0)
    {
	_NETCdebug((fname,"fdopen(1,w) failed\n"));
	_NETSdebug((fname,"fdopen(1,w) failed\n"));
	_NETCdebug((fname,"CATASTROPHIC ERROR STDOUT NOT RESET. THIS WILL\
 CAUSE ALL STDOUT TO GO TO /DEV/NULL\n"));
	_NETSdebug((fname,"CATASTROPHIC ERROR STDOUT NOT RESET. THIS WILL\
 CAUSE ALL STDOUT TO GO TO /DEV/NULL\n"));
        status = NET_E_FMU_RCMD;
        ERRload_struct(NETS,status,"%s","Cannot reset stdout to original setting");
        return (status);
    }
    if(c_status)
    {
        status = NET_E_FMU_RCMD;
        _NETCdebug ((fname,"fmu_rcmd (rm) : <%s> status = <0x%.8x>\n", c_status,status));
        _NETSdebug ((fname,"fmu_rcmd (rm) : <%s> status = <0x%.8x>\n", c_status,status));
        ERRload_struct(NETS,status,"%s",c_status);
        return (status);
    }
	status = NET_S_SUCCESS ;
       _NETCdebug ((fname,"Successful : status <0x%.8x>\n",status));
       _NETSdebug ((fname,"Successful : status <0x%.8x>\n",status));

    return (NET_S_SUCCESS);
}
int NETfmu_send( src_file , dst_file,attribute,file_size)
  char  *src_file ;
  char *dst_file ;
  char *attribute;
  int *file_size ;
  {
    char *fname="NETfmu_send ";
    int     status;
    char    *c_status;
    struct stat  fbuff ;

    _NETCdebug ((fname,"src_file <%s> dst_file <%s> attribute <%s> file_size\
 <%d>\n", src_file,dst_file,attribute,*file_size));
    _NETSdebug ((fname,"src_file <%s> dst_file <%s> attribute <%s> file_size\
 <%d>\n", src_file,dst_file,attribute,*file_size));

    if (strlen (attribute))
     {
       status = NETfmu_set (attribute);
       if (status != NET_S_SUCCESS)
        {
          _NETCdebug ((fname,"NETfmuset failed  status = <0x%.8x>\n", status));
          _NETSdebug ((fname,"NETfmuset failed  status = <0x%.8x>\n", status));
          return (status);
        }
     }
    c_status = (char *) fmu_send (src_file, dst_file);
    if (c_status)
     {
       status = NET_E_FMU_SEND;
        ERRload_struct(NETS,status,"%s",c_status);
       _NETCdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       _NETSdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       return (status);
     }

    if (strlen (attribute))
     {
       status = NETfmu_unset (attribute);
       if (status != NET_S_SUCCESS)
        {
          _NETCdebug ((fname,"FMU_UNSET FAILED: status = <0x%.8x>\n", status));
          _NETSdebug ((fname,"FMU_UNSET FAILED: status = <0x%.8x>\n", status));
          return (status);
        }
     }

/* 12/9/92 - KT - Replace 'Stat' with 'stat'
    status = Stat (src_file, &fbuff);
*/
    status = stat (src_file, &fbuff);
    if (status) /* OK */
     {
       status = NET_E_STAT;
        ERRload_struct(NETS,status,"%s",src_file);
       _NETCdebug ((fname,": Stat Failed : status = <0x%.8x>\n", status));
       _NETSdebug ((fname,": Stat Failed : status = <0x%.8x>\n", status));
       return (status);
     }

    *file_size = fbuff.st_size;
    _NETCdebug ((fname,"SUCCESSFUL : File Size = <%d>\n", *file_size));
    _NETSdebug ((fname,"SUCCESSFUL : File Size = <%d>\n", *file_size));

    return (NET_S_SUCCESS);
}
int NETfmu_receive( src_file , dst_file,attribute,file_size)
  char  *src_file ;
  char *dst_file ;
  char *attribute;
  int *file_size ;
  {
    char *fname="NETfmu_receive ";
    int     status;
    char    *c_status;
    struct stat fbuff ;

    _NETCdebug ((fname,"src_file <%s> dst_file <%s> attribute <%s> file_size\
 <%d>\n", src_file,dst_file,attribute,*file_size));
    _NETSdebug ((fname,"src_file <%s> dst_file <%s> attribute <%s> file_size\
 <%d>\n", src_file,dst_file,attribute,*file_size));

    if (strlen (attribute))
     {
       status = NETfmu_set (attribute);
       if (status != NET_S_SUCCESS)
        {
          _NETCdebug ((fname,"NETfmuset failed  status = <0x%.8x>\n", status));
          _NETSdebug ((fname,"NETfmuset failed  status = <0x%.8x>\n", status));
          return (status);
        }
     }
    c_status = (char *) fmu_receive (src_file, dst_file);
    if (c_status)
     {
       status = NET_E_FMU_RECEIVE;
        ERRload_struct(NETS,status,"%s",c_status);
       _NETCdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       _NETSdebug ((fname,"INC Error: <%s>\n status <0x%.8x>\n", c_status,status));
       return (status);
     }

    if (strlen (attribute))
     {
       status = NETfmu_unset (attribute);
       if (status != NET_S_SUCCESS)
        {
          _NETCdebug ((fname,"FMU_UNSET FAILED: status = <0x%.8x>\n", status));
          _NETSdebug ((fname,"FMU_UNSET FAILED: status = <0x%.8x>\n", status));
          return (status);
        }
     }

/* 12/9/92 - KT - Replace 'Stat' with 'stat'
    status = Stat (dst_file, &fbuff);
*/
    status = stat (dst_file, &fbuff);
    if (status) /* OK */
     {
       status = NET_E_STAT;
        ERRload_struct(NETS,status,"%s",dst_file);
       _NETCdebug ((fname,": Stat Failed : status = <0x%.8x>\n", status));
       _NETSdebug ((fname,": Stat Failed : status = <0x%.8x>\n", status));
       return (status);
     }

    *file_size = fbuff.st_size;
    _NETCdebug ((fname,"SUCCESSFUL : File Size = <%d>\n", *file_size));
    _NETSdebug ((fname,"SUCCESSFUL : File Size = <%d>\n", *file_size));

    return(NET_S_SUCCESS);
}



int NETfmu_set (attribute)
  char *attribute;
{
char *fname="NETfmu_set ";
  int status;
  char mode[16];
  char *c_status;

  _NETCdebug ((fname," Attribute = <%s>\n", attribute));
  _NETSdebug ((fname," Attribute = <%s>\n", attribute));
  mode[0] = 0;

/* KT - August 16, 1990. Added this section of code. */

  switch (attribute[0])
  {
     case 'I': 
     case 'i':
               strcpy (mode, "igds");
     break;

     case 'C': 
     case 'c':
               strcpy (mode, "contiguous");
     break;

     case 'F': 
     case 'f':
               strcpy (mode, "fixed");
     break;

     default:
              /*
               _NETCdebug ((fname,"NET FMU SET : <%s>\n", "invalid set option"));
               _NETSdebug ((fname,"NET FMU SET : <%s>\n", "invalid set option"));
               status = NET_E_INVALID_MODE;
	   ERRload_struct(NETS,status,"",NULL);
               _NETCdebug ((fname,"NET FMU SET : status = <0x%.8x>\n", status));
               _NETSdebug ((fname,"NET FMU SET : status = <0x%.8x>\n", status));
               return (status);
              */
              status = NET_S_SUCCESS;
              _NETCdebug ((fname,"HIT DEFAULT: SUCCESSFUL : status = <0x%.8x>\n", status));
              _NETSdebug ((fname,"HIT DEFAULT: SUCCESSFUL : status = <0x%.8x>\n", status));
              return (status);
  }

  c_status = (char *) fmu_set (mode); 
  if (c_status)
  {
     _NETCdebug ((fname,"NET FMU SET : <%s>\n", c_status));
     _NETSdebug ((fname,"NET FMU SET : <%s>\n", c_status));
     status = NET_E_FMU_SET;
	   ERRload_struct(NETS,status,"%s",c_status);
     _NETCdebug ((fname,"FMU SET Failed INC Error <%s>\n : status = <0x%.8x>\n",c_status, status));
     _NETSdebug ((fname,"FMU SET Failed INC Error <%s>\n : status = <0x%.8x>\n",c_status, status));
     return (status);
  }

  status = NET_S_SUCCESS;
  _NETCdebug ((fname,"NET FMU SET : SUCCESSFUL : status = <0x%.8x>\n", status));
  _NETSdebug ((fname,"NET FMU SET : SUCCESSFUL : status = <0x%.8x>\n", status));
  return (status);
}


int NETfmu_unset (attribute)
  char *attribute;
{
char *fname="NETfmu_unset ";
  int status;
  char mode[16];
  char *c_status;

  mode[0] = 0;
  _NETCdebug ((fname," Attribute = <%s>\n", attribute));
  _NETSdebug ((fname," Attribute = <%s>\n", attribute));

  switch (attribute[0])
  {
     case 'I': 
     case 'i':
               strcpy (mode, "noigds");
     break;

     case 'C': 
     case 'c':
               strcpy (mode, "nocontiguous");
     break;

     case 'F': 
     case 'f':
               strcpy (mode, "nofixed");
     break;

     default:
               /*
               _NETCdebug ((fname,"NET FMU UNSET : <%s>\n", "invalid set option"));
               _NETSdebug ((fname,"NET FMU UNSET : <%s>\n", "invalid set option"));
               status = NET_E_INVALID_MODE;
	       ERRload_struct(NETS,status,"",NULL);
               _NETCdebug ((fname,"NET FMU UNSET : status = <0x%.8x>\n", status));
               _NETSdebug ((fname,"NET FMU UNSET : status = <0x%.8x>\n", status));
               return (status);
               */
              status = NET_S_SUCCESS;
              _NETCdebug ((fname,"HIT DEFAULT : SUCCESSFUL : status = <0x%.8x>\n", status));
              _NETSdebug ((fname,"HIT DEFAULT : SUCCESSFUL : status = <0x%.8x>\n", status));
              return (status);
  }

  c_status = (char *) fmu_set (mode); 
  if (c_status)
  {
     _NETCdebug ((fname,"Failed INC error : <%s>\n", c_status));
     _NETSdebug ((fname,"Failed INC error : <%s>\n", c_status));
     status = NET_E_FMU_UNSET;
	   ERRload_struct(NETS,status,"%s",c_status);
     _NETCdebug ((fname," FMU SET : status = <0x%.8x>\n", status));
     _NETSdebug ((fname," FMU SET : status = <0x%.8x>\n", status));
     return (status);
  }

  status = NET_S_SUCCESS;
  _NETCdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", status));
  _NETSdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", status));
  return (status);
}

