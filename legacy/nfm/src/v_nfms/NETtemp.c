#include <stdio.h>
#include "machine.h"
#include "UNIX_or_VMS.h"
#include "DEBUG.h"

#if OS_UNIX
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <pwd.h>
#endif

#include <sys/stat.h>
#if VMS
#include <types.h>
#include <stat.h>
#endif

/* for vms with use of SYS$GETUAI().  not currently needed.  we assume that
   the user will give an absolute file path if it is a VMS machine.
#include <ssdef.h>
#include <descrip.h>

#define UAI$_DEFDEV 13
#define UAI$_DEFDIR 14
#endif
*/

#include "NETstruct.h"
#include "NETerrordef.h"
#include "MSGstruct.h"
#include "ERR.h"


 struct NETuser_struct NETusr_info;

 int    NETod_status;

/*                Not needed at this time.
#if VMS 
int SYS$GETUAI ();
#endif

struct NETitem {
  short buffer_length1;
  short code1;
  int   desc1;
  int   length1;
  short buffer_length2;
  short code2;
  int   desc2;
  int   length2;
  int   terminator;
}; 
*/

int NETload_user_info (user_name)
  char  *user_name;
  {
char *fname="NETload_user_info ";
    int   status;

    /* the line below was copied here by B.W. 10-18-91 Due to compilation */
         struct  passwd *pswd_ptr;

/*  commented out by B.W. 10/18/91 Due to compiler not accepting this 
#if UNIX 
         struct  passwd *pswd_ptr;
         void    setpwent();
         void    endpwent();
         struct  passwd *getpwnam();
         struct  passwd *getpwuid();
#endif 
*/

    _NETCdebug ((fname,"User Name = <%s>\n", user_name));
    _NETSdebug ((fname,"User Name = <%s>\n", user_name));


/*	if UNIX is been changed to OS_UNIX -- naidu 1/27/95 */
#if OS_UNIX

     if (! strlen (user_name))
      {
        pswd_ptr = getpwuid (getuid ());
        if (! pswd_ptr)
         {
           status = NET_E_GETPWNAM_FAILED;
	   ERRload_struct(NETS,status,"%s%s","getpwuid",user_name);
           _NETCdebug ((fname,"Get Pw Name Failed : status = <0x%.8x>\n", status));
           _NETSdebug ((fname,"Get Pw Name Failed : status = <0x%.8x>\n", status));
           return (status);
         }
      }
     else
      {
        pswd_ptr = getpwnam (user_name);
        if (! pswd_ptr)
         {
           status = NET_E_GETPWNAM_FAILED;
	   ERRload_struct(NETS,status,"%s%s","getpwnam",user_name);
           _NETCdebug ((fname,"Get Pw Name Failed : status = <0x%.8x>\n",
           status));
           _NETSdebug ((fname,"Get Pw Name Failed : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     NETusr_info.uid = pswd_ptr -> pw_uid;
     NETusr_info.gid = pswd_ptr -> pw_gid;
     sprintf (NETusr_info.name, "%s", pswd_ptr -> pw_name);
     sprintf (NETusr_info.dir,  "%s", pswd_ptr -> pw_dir);

     status = setgid (pswd_ptr -> pw_gid);
     if (status) /* OK */
      {
        status = NET_E_SETGID_FAILED;
	   ERRload_struct(NETS,status,"",NULL);
        _NETCdebug ((fname,"Set Uid Failed : status = <0x%.8x>\n", status));
        _NETSdebug ((fname,"Set Uid Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     status = setuid (pswd_ptr -> pw_uid);
     if (status) /* OK */
      {
        status = NET_E_SETUID_FAILED;
	   ERRload_struct(NETS,status,"",NULL);
        _NETCdebug ((fname,"Set Uid Failed : status = <0x%.8x>\n", status));
        _NETSdebug ((fname,"Set Uid Failed : status = <0x%.8x>\n", status));
        return (status);
      }
     status = chdir (pswd_ptr -> pw_dir);
     if (status) /* OK */
      {
        status = NET_E_CHDIR_FAILED;
	   ERRload_struct(NETC,status,"%s%s",pswd_ptr->pw_dir,pswd_ptr->pw_name);
	   ERRload_struct(NETS,status,"%s%s",pswd_ptr->pw_dir,pswd_ptr->pw_name);
        _NETCdebug ((fname,"Change directory failed:Dir <%s> status = <0x%.8x>\n", pswd_ptr->pw_dir,status));
        _NETSdebug ((fname,"Change directory failed:Dir <%s> status = <0x%.8x>\n", pswd_ptr->pw_dir,status));
        return (status);
      }

     setpwent();  /* rewind passwd file to the beginning. */ 
     endpwent();  /* close the passwd file. */ 
#endif

#if VMS
     NETusr_info.uid = getuid ();
     NETusr_info.gid = getgid ();    

     sprintf (NETusr_info.dir, "%s", "");

/* Not used at this time.  
     if (! strlen (user_name))
        sprintf (NETusr_info.dir, "%s", "");
     else
      {
        status = NETget_vms_pwd (user_name, NETusr_info.dir);
        if (status != NET_S_SUCCESS)
         {
           _NETCdebug ((fname," Get VMS Pw Dir Failed : status = <0x%.8x>\n",
           status));
           _NETSdebug ((fname," Get VMS Pw Dir Failed : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
*/ 
#endif

    _NETCdebug((fname,"Name <%s> dir <%s> Uid <%d> Gid <%d>\n",NETusr_info.name,
NETusr_info.dir,NETusr_info.uid,NETusr_info.gid));
    _NETSdebug((fname,"Name <%s> dir <%s> Uid <%d> Gid <%d>\n",NETusr_info.name,
NETusr_info.dir,NETusr_info.uid,NETusr_info.gid));

    _NETCdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }

int NETget_file_name (file_name, full_name)
  char    *file_name;
  char    *full_name;
  {
char *fname="NETget_file_name ";
    int     status,i;

    full_name [0] = 0;

    _NETCdebug ((fname,"FILE NAME : File Name = <%s> Full name <%s>\n  ", file_name,full_name));
    _NETSdebug ((fname,"FILE NAME : File Name = <%s> Full name <%s>\n  ", file_name,full_name));

    if (! strlen (file_name))
     {
       status = NET_E_INVALID_FILE_NAME;
	   ERRload_struct(NETS,status,"%s",file_name);
       _NETCdebug ((fname,"FILE NAME : INVALID : status = <0x%.8x>\n", status));
       _NETSdebug ((fname,"FILE NAME : INVALID : status = <0x%.8x>\n", status));
       return (status);
     }

#if OS_UNIX
    if (file_name [0] == '/')        sprintf (full_name, "%s", file_name);
    else if (file_name [0] == ':')   sprintf (full_name, "%s", file_name);
    else
     {
       sprintf (full_name, "%s/%s", NETusr_info.dir, file_name);
     }
#endif

#if VMS   /* will the filename always contain an absolute path????? */
    sprintf (full_name, "%s", file_name);
#endif

    _NETCdebug ((fname,"SUCCESSFUL:Full Name = <%s>\n", full_name));
    _NETSdebug ((fname,"SUCCESSFUL:Full Name = <%s>\n", full_name));

    return (NET_S_SUCCESS);
  }


int NETset_file_mode (filename, file_info)
 char    *filename;
 struct  NETfile_info  *file_info;
 {
char *fname="NETset_file_mode ";
    int     status;
    struct  utimebuf times;

    _NETCdebug ((fname," File Name = <%s>\n", filename));
    _NETSdebug ((fname," File Name = <%s>\n", filename));

#if OS_UNIX
    times.actime  = file_info -> atime; 
    times.modtime = file_info -> mtime; 

     status = utime (filename, &times);
     if (status) /* OK */
      {
        status = NET_E_UTIME;
	   ERRload_struct(NETS,status,"",NULL);
        _NETCdebug ((fname," UTIME failed Failed : status = <0x%.8x>\n", status));
        _NETSdebug ((fname," UTIME failed Failed : status = <0x%.8x>\n", status));
        return (NET_E_UTIME);
      }
#endif

     /* set the mode of the filename to that of the srcfile. */

     status = chmod (filename, file_info -> mode);
     if (status) /* OK */
      {
        status = NET_E_CHMOD;
	   ERRload_struct(NETS,status,"",NULL);
        _NETCdebug ((fname," Change MODE failed Filename <%s> : status = <0x%.8x>\n", filename,status));
        _NETSdebug ((fname," Change MODE failed Filename <%s> : status = <0x%.8x>\n", filename,status));
        return (NET_E_CHMOD);
      }

     /* set the uid and gid of the file to be the same as the users. */

     status = chown (filename, NETusr_info.uid, NETusr_info.gid);
     if (status) /* OK */
      {
        status = NET_E_CHOWN;
	   ERRload_struct(NETS,status,"",NULL);
        _NETCdebug ((fname,"Change Owner Failed filename <%s> : status = <0x%.8x>\n",filename, status));
        _NETSdebug ((fname,"Change Owner Failed filename <%s> : status = <0x%.8x>\n",filename, status));
        return (NET_E_CHOWN);
      }


   _NETCdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
   _NETSdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
   return (NET_S_SUCCESS);
 } 

int NETverify_file_info (file_name, fbuff, file_info)
  char                    *file_name;
  struct    stat          *fbuff;
  struct    NETfile_info  *file_info;
  {
char *fname="NETverify_file_info ";
    int    status;

    _NETCdebug ((fname,"File Name = <%s>\n", file_name));
    _NETSdebug ((fname,"File Name = <%s>\n", file_name));

    status = NET_S_SUCCESS;

    if (strcmp (file_info -> name, file_name))
     {
       status = NET_E_FILENAME_MISMATCH;
	   ERRload_struct(NETS,status,"%s%s",file_info->name,file_name);
       _NETCdebug ((fname,"Mismatch File Name file1 <%s> file2 <%s> : status = <0x%.8x>\n",
       file_info->name,file_name,status));
       _NETSdebug ((fname,"Mismatch File Name file1 <%s> file2 <%s> : status = <0x%.8x>\n",
       file_info->name,file_name,status));
       return (status);
     }
    else if (file_info -> size != ((struct stat *) fbuff)->st_size)
     {
       if (file_info -> size == -2)
        {
          status = file_info -> mode;
	   ERRload_struct(NETS,status,"",NULL);
          _NETCdebug ((fname,": Server Info : status = <0x%.8x>\n",
          status));
          _NETSdebug ((fname,": Server Info : status = <0x%.8x>\n",
          status));
          return (status);
        }

       status = NET_E_FILESIZE_MISMATCH;
	   ERRload_struct(NETS,status,"%d%d",file_info->size,fbuff->st_size);
       _NETCdebug ((fname,"Mismatch File Size filesize1 <%d> filesize2 <%d> : status = <0x%.8x>\n",
       file_info->size,fbuff->st_size,status));
       _NETSdebug ((fname,"Mismatch File Size filesize1 <%d> filesize2 <%d> : status = <0x%.8x>\n",
       file_info->size,fbuff->st_size,status));
       return (status);
     }

    _NETCdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n",
    NET_S_SUCCESS));
    _NETSdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n",
    NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }




/************
int NETfmu_set (attribute)
  char *attribute;
{
char *fname="NETfmu_set ";
  int status;
  char mode[16];
#if VMS
  char *c_status;
#endif

  _NETCdebug ((fname," Attribute = <%s>\n", attribute));
  _NETSdebug ((fname," Attribute = <%s>\n", attribute));
  mode[0] = 0;

/ * KT - August 16, 1990. Added this section of code. * /

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
              / *
               _NETCdebug ((fname,"NET FMU SET : <%s>\n", "invalid set option"));
               _NETSdebug ((fname,"NET FMU SET : <%s>\n", "invalid set option"));
               status = NET_E_INVALID_MODE;
	   ERRload_struct(NETS,status,"",NULL);
               _NETCdebug ((fname,"NET FMU SET : status = <0x%.8x>\n", status));
               _NETSdebug ((fname,"NET FMU SET : status = <0x%.8x>\n", status));
               return (status);
              * /
              status = NET_S_SUCCESS;
              _NETCdebug ((fname,"HIT DEFAULT: SUCCESSFUL : status = <0x%.8x>\n", status));
              _NETSdebug ((fname,"HIT DEFAULT: SUCCESSFUL : status = <0x%.8x>\n", status));
              return (status);
  }

#if VMS
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
#endif

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
               / *
               _NETCdebug ((fname,"NET FMU UNSET : <%s>\n", "invalid set option"));
               _NETSdebug ((fname,"NET FMU UNSET : <%s>\n", "invalid set option"));
               status = NET_E_INVALID_MODE;
	       ERRload_struct(NETS,status,"",NULL);
               _NETCdebug ((fname,"NET FMU UNSET : status = <0x%.8x>\n", status));
               _NETSdebug ((fname,"NET FMU UNSET : status = <0x%.8x>\n", status));
               return (status);
               * /
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

************************/

/*  This function is used to get the users absolute login directory on a
    VAX machine.  It is not being used as of now because NFM currently
    assumes that a VMS file path will be absolute.  12/4/89  B.W.  */

/*  int NETget_vms_pwd (user_name, def_path)
  char *user_name;
  char *def_path;
{
char *fname="NETget_vms_pwd ";
  int          status;
  int          i;
  short        length1 = 0; 
  short        length2 = 0; 
  char         def_dir[65];
  char         def_dev[20];
  struct NETitem item_list;

#if VMS 
  $DESCRIPTOR (usrname, user_name);
#endif

  _NETCdebug ((fname,"GET VMS PWD : User Name = <%s>\n", user_name));
  _NETSdebug ((fname,"GET VMS PWD : User Name = <%s>\n", user_name));
  def_path[0] = 0;

#if VMS 
  item_list.code1 = UAI$_DEFDEV;  
  item_list.buffer_length1 = 16;
  item_list.desc1 = &def_dev;
  item_list.length1 = &length1; 
  item_list.code2 = UAI$_DEFDIR; 
  item_list.buffer_length2 = 64;
  item_list.desc2 = &def_dir;
  item_list.length2 = &length2;
  item_list.terminator = 0; 

  status = SYS$GETUAI (0,0, &usrname, &item_list, 0, 0, 0);
  if (status != SS$_NORMAL)
  {
     _NETCdebug ((fname,"NET GET VMS PWD : <0x%.8x>\n", status));
     _NETSdebug ((fname,"NET GET VMS PWD : <0x%.8x>\n", status));
     status = NET_E_GETUAI_FAILED;
	   ERRload_struct(NETS,status,"",NULL);
     _NETCdebug ((fname,"NET GET VMS PWD : SYS$GETUAI : status = 0x%.8x>\n", status));
     _NETSdebug ((fname,"NET GET VMS PWD : SYS$GETUAI : status = 0x%.8x>\n", status));
     return (status);
  }

  / * SYS$GETUAI returns the string as a counted string. * /
  length1 = def_dev[0];   / * get the length of the def_dev string * /
  length2 = def_dir[0];   / * get the length of the def_dir string * /

  for (i = 1; i < length1 + 1; ++i)  / * shift string by 1 character. * /
    def_dev[i - 1] = def_dev[i];
  def_dev[length1] = '\0';           / * add terminating null. * /

  for (i = 1; i < length2 + 1; ++i)  / * shift string by 1 character. * /
    def_dir[i - 1] = def_dir[i];
  def_dir[length2] = '\0';           / * add terminating null. * /

  sprintf (def_path, "%s%s", def_dev, def_dir);
#endif

  status = NET_S_SUCCESS;  / * set status to successfull * / 
  _NETCdebug ((fname,"NET GET VMS PWD : Dir = <%s>\n", def_path));
  _NETSdebug ((fname,"NET GET VMS PWD : Dir = <%s>\n", def_path));
  _NETCdebug ((fname,"NET GET VMS PWD : SUCCESSFUL : status = <0x%.8x>\n", status));
  _NETSdebug ((fname,"NET GET VMS PWD : SUCCESSFUL : status = <0x%.8x>\n", status));
  return (status);
}
*/
