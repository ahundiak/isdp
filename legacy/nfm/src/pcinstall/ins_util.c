#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <io.h>
#include "pcinst.h"
#include <memory.h>
#include <malloc.h>
#include "ins_proto.h"
#include <sys\types.h>
#include <sys\stat.h>
#include <direct.h>


/****** EXTERNALS *****/
extern char pcid[] ;
extern char host_path[] ;
extern int  nfs_package ;
extern char nfm_path[];
extern CLIptr CLImsg_ptr ;


void _CLI_num (str, var)
char  *str;  /* i - input string */
long  var;   /* i - long variable for input string */
{
    FILE   *CLIdbg_ptr, *fopen ();

    if (CLImsg_ptr.debug_on)
    {
        CLIdbg_ptr = fopen (CLImsg_ptr.debug_file, "a");
        if (CLIdbg_ptr)
        {
            fprintf (CLIdbg_ptr, "CLI : ");
            fprintf (CLIdbg_ptr, str, var);
            fprintf (CLIdbg_ptr, "\n");
            fclose  (CLIdbg_ptr);
        }
    }
}
 
void _CLI_str (str, var)
char  *str;  /* i - input string */
char  *var;  /* i - string variable for input string */
{
    FILE   *CLIdbg_ptr, *fopen ();

    if (CLImsg_ptr.debug_on)
    {
        CLIdbg_ptr = fopen (CLImsg_ptr.debug_file, "a");
        if (CLIdbg_ptr)
        {
            fprintf (CLIdbg_ptr, "CLI : ");
            fprintf (CLIdbg_ptr, str, var);
            fprintf (CLIdbg_ptr, "\n");
            fclose  (CLIdbg_ptr);
        }
    }
}

/******************************************************************************
  
 SOURCE FILE: ins_md.c
  
 AUTHOR: Melania M Seward
  
 DATE: 09/03/92
  
 SDM NUMBER:
  
 DESCRIPTION: This routine creates a directory, if it doesn't
 				already exist.
  
   FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT: 0 = ok, -1 = couldn't make directory
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/
long MakeDir(path_name)
char *path_name;
{
  int i;
  
  _CLI_str("  starting MakeDir <%s>",path_name) ;
  
  /* is the directory there */
  if (access(path_name,0)!=0)
    {
      /* make the directory */
      i = mkdir(path_name);
      if (i !=0)
	{
	  _CLI_str("  ending MakeDir",0);
	  return(CLI_E_FAILURE) ;
	}
    }
  
  _CLI_str("  ending MakeDir",0);
  return(CLI_S_SUCCESS) ;
} /* MakeDir */

/******************************************************************************
  
 SOURCE FILE: ins_auto.c
  
 AUTHOR: Melania M Seward
  
 DATE: 09/03/92
  
 SDM NUMBER:
  
 DESCRIPTION: This routine updates the autoexec.bat file with the nfm
 				path.
  
   FUNCTIONS INVOKED:
   						str_pos(rtns.c)
						copy(rtns.c)
						AddPath(di_path.c)

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/

long UpdateAutoexec()
{
  FILE *old_file,*new_file;
  char dataline[255],oldpath[255], newpath[255];
  int i, j,path_there,comment_there=0;
  long status ;
  char title[80], *getenv(), *value;
  
  _CLI_str("  starting UpdateAutoexec",0);
  path_there = 0;
  
  /* has the path been updated and has the environment been set */
  new_file = fopen("c:\\AUTOEXEC.BAT","r");
  
  fgets(dataline,255,new_file);
  while (!feof(new_file))
    {
      if (str_pos("rem ", dataline, 1) !=0)
	goto bypass;	/* a comment */
      if (str_pos("path=%path%", dataline, 1) ==0)
	{
	  if (str_pos(nfm_path, dataline, 1) !=0)
	    {
	      path_there = 1;				
	      goto bypass;
	    }
	}
      if (str_pos("path=", dataline, 1) ==0)
	goto bypass;	/* not path line */
      
      /* path line */
      i = str_pos("path=", dataline, 1);
      copy(dataline, i+5, 255, oldpath);
      oldpath[strlen(oldpath)-1] = '\0';
      _CLI_str ("oldpath= [%s]", oldpath);
      j = strlen(oldpath) + 5 + strlen(nfm_path) +1;
      if (j > 127)
	{
	  _CLI_str ("  ending UpdateAutoexec -1",0);
	  return(CLI_E_FAILURE) ;
	}	
      
    bypass:
      
      fgets(dataline,255,new_file);
    }/* while */
  fclose(new_file);
  
  if (path_there ==1)
    {
      _CLI_str("  path there",0);
      goto just_add_env;
    }
  
  /* back up autoexec.bat */
  status =SystemCall ("copy c:\\AUTOEXEC.BAT c:\\AUTOEXEC.DMD > NUL");
  if (status != CLI_S_SUCCESS)
    {
      fprintf (stderr, "Unable to back up autoexec.bat\n") ;
      return (CLI_E_FAILURE) ;
    }
  
  /* update the path line */
  old_file = fopen("c:\\AUTOEXEC.DMD","r");
  new_file = fopen("c:\\AUTOEXEC.BAT","w");
  
  fgets(dataline,255,old_file);
  while (!feof(old_file))
    {
      j=str_pos("rem ", dataline, 1);
      i=str_pos("path=", dataline, 1);
      
      if (j !=0 || i==0)
	{
	  fprintf(new_file,"%s",dataline);
	}
      else		
	{
	  fprintf(new_file,"%s",dataline);/* path line */
	  sprintf(newpath,"PATH=%s;%%path%%",nfm_path);
	  fprintf(new_file,"%s\n",newpath);
	  dataline[strlen(dataline)-1] = '\0';
	  sprintf(newpath,"%s;%s", dataline, nfm_path);
	  _CLI_str("env newpath=[%s]", newpath);
	}
      fgets(dataline,255,old_file);
    }/* while */
  fclose(old_file);
  fclose(new_file);
  
  
 just_add_env:
  /* add nfm path to current environment */
  value = getenv("PATH");
  if (value != (char *)0)
    strcpy(oldpath, value);
  
  _CLI_str("currentpath= [%s]", oldpath);
  
  if (str_pos(nfm_path, oldpath, 1) ==0)
    {
      sprintf(newpath, "PATH=%s;%s", nfm_path, oldpath);
      AddPath(newpath);
    }
  
  _CLI_str("  ending UpdateAutoexec",0);
  return(CLI_S_SUCCESS) ;
} /* UpdateAutoexec */


/******************************************************************************
  
 SOURCE FILE: ins_zip.c
  
 AUTHOR: Melania M Seward
  
 DATE: 09/03/92
  
 SDM NUMBER:
  
 DESCRIPTION: This routine unzips the nfm product.
  
   FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT: 0=ok, -1=errors
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/

long InstallProduct()
{
  char wrk [255] ;
  char work[128];
  long status ;
  struct stat filestatus ;
  
  _CLI_str ("  starting InstallProduct",0);
  _CLI_str ("starting to unzip",0) ;

  if (stat (".\\CNFM.EXE", &filestatus) != 0)
    {
      fprintf (stderr, "CNFM.EXE is not in current directory\n") ;
      return (CLI_E_FAILURE) ;
    }
  
  sprintf(wrk,"\\CNFM -o %s\\bin nfmpc.exe >NUL",nfm_path);
  status = SystemCall(wrk);
  if (status != CLI_S_SUCCESS)
    {
      fprintf (stderr, "%s : failed\n", wrk) ;
      _CLI_str ("%s : failed", wrk) ;
      return(CLI_E_FAILURE);
    }

  sprintf(wrk,"\\CNFM -o %s\\bin nremove.exe >NUL",nfm_path);
  status = SystemCall(wrk);
  if (status != CLI_S_SUCCESS)
    {
      fprintf (stderr, "%s : failed\n", wrk) ;
      _CLI_str ("%s : failed", wrk) ;
      return(CLI_E_FAILURE);
    }

  sprintf(wrk,"\\CNFM -o %s\\bin README >NUL",nfm_path);
  SystemCall(wrk);

  sprintf(wrk,"\\CNFM -o %s\\cfg ai_def >NUL",nfm_path);
  SystemCall(wrk);


  /* if it is installed & nfmpc.exe is there, ok */
  sprintf(wrk,"%s\\bin\\NFMPC.EXE",nfm_path);
  if (access(wrk,0)!=0)
    {
      fprintf (stderr, "%s : failed\n", wrk) ;
      _CLI_str ("%s : failed", wrk) ;
      return(CLI_E_FAILURE);
    }

  strcpy(wrk,"\\README");
  if (access(wrk,0)==0)
    {
      sprintf(work, "copy \\readme %s\\readme >NUL", nfm_path);
      SystemCall(work);
    }
  
  _CLI_str ("  ending InstallProduct\n",0);
  return(CLI_S_SUCCESS) ;
} /* InstallProduct */

/******************************************************************************
  
 SOURCE FILE: ins_host.c
  
 AUTHOR: Melania M Seward
  
 DATE: 09/03/92
  
 SDM NUMBER:
  
 DESCRIPTION: This routine verifies the pc id in the global variable pc_id
               to exist in the host file 
  
   FUNCTIONS INVOKED:
						str_pos(rtns.c)
						trim_lead(rtns.c)
 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT: -900=could not find hosts file, else number of hosts
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/

long VerifyHost()
{
  FILE *hosts;
  char dataline[133],wrk[128], dummy[100],work[128],config_path[100];
  long match ;
  char	*getenv(),*value;
  char	srvname[80] ;
  char	cmd[100];
  FILE *new_file;
  
  _CLI_str ("  starting ReadHosts",0);
  strcpy(dummy, "Host table (hosttable): ");
  strcpy(host_path, "");
  
  /* find hosts file */
  if (nfs_package == PC_NFS)
    {
      strcpy(work, "C");
      value = getenv("NFSDRIVE");
      if (value != (char *)0)
	strcpy(work, value);
      sprintf(host_path, "%s:\\nfs\\hosts",work);	
      _CLI_str ("work=[%s]", work) ;
      _CLI_str ("path=%s", host_path);
    }
  else if (nfs_package == FTP)
    {
      _searchenv("IPCONFIG.EXE", "PATH", config_path);
      if (config_path[0] == '\0')
	{
	  _CLI_str ("File <IPCONFIG.EXE> Not Found %s", "") ;
	  fprintf (stderr, "File <IPCONFIG.EXE> Not Found %s", "") ;
	  return(CLI_E_FAILURE) ;
	}
      config_path[strlen(config_path) - strlen("\\IPCONFIG.EXE") ] = '\0';
      _CLI_str ("config_path= [%s]", config_path);
      
      sprintf(cmd, "%s\\ipconfig %s\\ipcust.sys show >\\nfm.tmp",
	      config_path, config_path);
      SystemCall(cmd);
      
      strcpy(cmd, "\\nfm.tmp");
      new_file = fopen(cmd,"r");
      if (new_file == NULL)
	{
	  fprintf (stderr, "Failure to open <%s>\n", cmd) ;
	  return (CLI_E_FAILURE) ;
	}
      
      dataline[0] = '\0';
      fgets(dataline,255,new_file);
      _CLI_str ("search for 'Host table (hosttable): ' in file <%s>",
		cmd) ;

      while (dataline[0] != '\0')
	{
	  if (str_pos(dummy, dataline, 1) !=0)
	    {
	      sscanf(dataline, "%s %s %s %s", work,work,work,host_path);
	      _CLI_str ("dummy=%s ", dummy) ;
	      _CLI_str ("host_path = %s", host_path);
	      break;
	    }
	  dataline[0] = '\0';
	  fgets(dataline,255,new_file);
	}/* while */
      fclose(new_file);	
/*      unlink ("\\nfm.tmp") ; */
    } 
  else if (nfs_package == WOLLENGONG)
    {
    }
  
  if (! strlen(host_path))
    {
      _CLI_str ("  Could not find the hosts file %d", "") ;
      fprintf (stderr, "Could not find the hosts file\n") ;
      return(CLI_E_FAILURE) ;
    }
  
  _CLI_str ("host_path=[%s]", host_path);

  _CLI_str ("verify that pc id <%s> is in file", pcid) ;
  hosts = fopen(host_path,"r");
  if (hosts==0)
    {
      _CLI_str ("  ending ReadHosts -1\n",0);
      fprintf (stderr, "Can not open <%s>", host_path) ;
      return(CLI_E_FAILURE) ;
    }

  dataline[0] = '\0';
  fgets(dataline,132,hosts);
  match = 0 ;
  while (dataline[0] !='\0') 
    {
      if (strlen(dataline) >6)
	{
	  memset(srvname, '\0', 80);
	  sscanf(dataline, "%s %s",wrk, srvname);
	  _CLI_str ("Comparing with srvname=%s", srvname);
	  if (strcmp (srvname, pcid) == 0)
	    {
	      _CLI_str ("Host Name <%s> Exists in host file", pcid) ;
	      match = 1 ;
	      break ;
	    }
	}/* if */
      dataline[0] = '\0';
      fgets(dataline,132,hosts);
    }/* while */
  fclose(hosts);

  if (! match) 
    {
      fprintf (stderr, "Host Name does not exist in host file\n") ;
      return (CLI_E_FAILURE) ;
    }
  _CLI_str ("  ending VerifyHost",0);
  return(CLI_S_SUCCESS) ;
} /* VerifyHost */

/******************************************************************************
  
   SOURCE FILE: getfree.c
  
   DATE: 09/03/92
  
   SDM NUMBER:
  
   DESCRIPTION: Determines the available disk space.
  
   FUNCTIONS INVOKED:
  
   PARAMETERS:
  
      ON ENTRY:
  
      ON EXIT:	Returns the number of available bytes on the default disk drive.
  
   EXTERNAL VARIABLES:
  
   CHANGE HISTORY:
  
******************************************************************************/

long GetFreeSpace(free_space)
     unsigned long *free_space;
{
  unsigned long bytes_per_cluster;/* number of bytes per cluster */
  struct diskfree_t dfinfo;		/* structure for free space */
  int drive;						/* drive for determining default drive */
  
  _dos_getdrive(&drive);
  if (_dos_getdiskfree(0,&dfinfo)!=0)
    {
      return(0);
    }
  bytes_per_cluster = dfinfo.sectors_per_cluster * dfinfo.bytes_per_sector;
  *free_space = dfinfo.avail_clusters * bytes_per_cluster;
  return (0);
} /* GetFreeSpace*/

/******************************************************************************
  
 SOURCE FILE: ni_path.c
  
 AUTHOR: Rick Kramer
  
 DATE: 02/20/1992
  
 SDM NUMBER:
  
 DESCRIPTION: This routine update the master environmant for the new path.
  
   FUNCTIONS INVOKED:
						GetEnv(di_env.c)
 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/

long AddPath(newpath)
     char *newpath;
{
  char far *Env ;
  unsigned EnvSize ;
  char wrk[255];
  
  _CLI_str ("  starting AddPath\n",0);

  strcpy(wrk, newpath);
  /*
   *  Locate the Master Table
   */
  Mstr_FindEnvironment ( &Env, &EnvSize ) ;
  
  /*
   *  Search for LOCATION of PATH
   */
  Mstr_getenv ( Env , "PATH=" );
  
  /*
   *  Add new PATH to the environment
   */
  Mstr_putenv ( Env , EnvSize , wrk) ;
  
  _CLI_str ("path = [%s]\n", wrk);
  _CLI_str("  ending AddPath\n",0);
} /* AddPath */

/******************************************************************************
  
 SOURCE FILE: ni_env.c
  
 AUTHOR: Rick Kramer
  
 DATE: 02/20/1992
  
 SDM NUMBER:
  
 DESCRIPTION: This module contains the routines that  updates the master
 				environment with the path that now contains NFM.
  
   FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/
/****
#include <dos.h>
#include <stdio.h> / * MS-C requires this * /
#include <stdlib.h> / * MS-C requires this * /
#include <malloc.h> / * MS-C uses this instead of alloc.h * /
******/

/*
 *   Mstr_FindEnvironment:
 *     Scans for the "Master" Environment area, and returns
 *     a pointer to it, and the size of the environment.
*/
void Mstr_FindEnvironment ( char far **Env , unsigned *EnvSize )
{
  unsigned int far *CommandSeg, far *TempSeg ;
  char far *BlockSeg ;
  
  /*
   *  Scan through PSP's looking for a block that is its own father.
   *  This block is the PSP of COMMAND.COM
   */
  TempSeg = _psp*0x10000; /* Convert to a far pointer, replaces MK_FP */
  do
    {
      CommandSeg = TempSeg ;
      TempSeg = *(TempSeg+8)*0x10000; /* Replaces MK_FP in turbo C */
    }
  while ( TempSeg != CommandSeg ) ;
  
  /*
   *  Scan forward through memory looking for the correct MSB.
   *  This will have COMMAND.COM's PSP as owner, and begin with
   *  the character M
   */
  BlockSeg = (char far *)CommandSeg ;
  do
    {
      BlockSeg = (FP_SEG(BlockSeg)+1)*0x10000; /* Replaces MK_FP */
    }
  while ( ( *(unsigned int far *)(BlockSeg+1) != FP_SEG ( CommandSeg ) ) ||
	 ( *BlockSeg != 'M' ) ) ;

  /*
    *  The environment is the NEXT segment of memory
    *  and bytes 4 and 5 are the size in paragraphs
    */
  *Env = (FP_SEG(BlockSeg)+1)*0x10000; /* Replaces MK_FP */
  *EnvSize = 16 * *(unsigned int far *)(BlockSeg+3) ;
}

/*
 *   Mstr_getenv:
 *     Scans the "Master" Environment for a given "sub string"
 *     and returns a pointer to it.
 *     Similar to Turbo routine "getenv" but uses the Master copy of the
 *     environment table.
 */
char far *Mstr_getenv (char far *Env , char far *name)
{
  char far *Sub_Env, far *str1, far *str2 ;
  
  /*
   *  Start at the beginning of the environment
   */
  Sub_Env = Env ;
  
  /*
   *  While the "sub string" we're looking at is non-zero
   */
  for ( ; *Sub_Env ; )
    {
      /*
       *  Simulate a "strcmp" on the "sub string" of the environment
       *  and the string we're looking for
       */
      for ( str1 = Sub_Env , str2 = name ;
           (*str1) && (*str2) && ( *str1 == *str2) ;
           str1++ , str2++ ) ;
      /*
       *  If we reached the end of the string we're looing for
       *  we've found the correct portion of the environment.
      *  Return the ptr to the start of this "sub string"
      */
      if ( !*str2 )
	return ( Sub_Env ) ;
      
      /*
       *  Otherwise, advance to the next "sub string" in the environment
       *  by performing a "strchr" function
       */
      for ( ; *(Sub_Env++) ; ) ;
    }
  
  /*
   *  Obviously, the string is not present in the environment.
    *  Return this fact.
    */
  return ( NULL ) ;
}

/*
 *   Mstr_delenv:
 *     Scans the "Master" Environment for a given "sub string"
 *     and removes it.
*/
int Mstr_delenv (char far *Env , unsigned EnvSize , char far *name)
{
   char far *Sub_Env , far *New_Env ;
   char huge *Dest , far *Src , huge *End_Env ;

   int Done  ;
   unsigned Ctr ;

   /*
    *  Allocate a chunk of storage to act as a "working" copy of
    *  the Environment table
   */
   New_Env = _fmalloc ( EnvSize ) ;

   /*
    *  Copy the data from the Master to Working copy of the
    *  Environment table.
    *  Simulates a "memcpy" function.
   */
   for ( Src = Env , Dest = (char far *)New_Env , Ctr = 0 ;
         Ctr < EnvSize ;
         *(Dest++) = *(Src++) , Ctr++ ) ;

   /*
    *  Scan the working copy of the environment for the desired
    *  sub string
   */
   Sub_Env = Mstr_getenv ( New_Env , name ) ;

   if ( Sub_Env == NULL )
   {
     /*
      *  If not found, do nothing
     */
     Done = -1 ;
   } else {
     /*
      *  Locate the end of the string to delete
      *  Simulate a "strchr" call
     */
     for ( Src = Sub_Env ; *(Src++) ; ) ;

     /*
      *  Move the rest of the environment back over the "sub string"
      *  being deleted.
      *  Simulated "memcpy" function.
      *  Huge pointers used for pointer comparison purposes.
     */
     for ( Dest = (char huge *)Sub_Env , End_Env = (char huge *) (New_Env + EnvSize ) ;
         ( Dest < End_Env ) ;
         *(Dest++) = *(Src++) ) ;

     /*
      *  Copy the data from the Working to Master copy of the
      *  Environment table.
      *  Simulates a "memcpy" function.
     */
     for ( Src = New_Env , Dest = (char huge *)Env , Ctr = 0 ;
         Ctr < EnvSize ;
         *(Dest++) = *(Src++) , Ctr++ ) ;

     /*
      *  Signal all done
     */
     Done = 0 ;
   }

   /*
    *  Free all working storage
   */
   _ffree ( New_Env ) ;

   return ( Done ) ;
}

/*
 *   Mstr_putenv:
 *     Adds/Replaces a given "sub string" in the Master Environment.
 *     Similar to Turbo routine "putenv" but uses the Master copy of the
 *     environment table.
*/
int Mstr_putenv (char far *Env , unsigned EnvSize , char far *name )
{
   char far *Sub_Env , far *Temp_Name ;
   char huge *Dest , far *Src , huge *End_Env ;
   int Done ;

   /*
    *  Allocate a chunk of storage to create the Variable name to add
    *  to the Environment table
   */
   Temp_Name = _fmalloc ( 256 ) ;

   /*
    *  Extract only the Name portion of the data to add to the Environment
   */
   for ( Src = name , Dest = Temp_Name ;
         *Src && ( *Src != '=' ) ;
        *(Dest++) = *(Src++) ) ;

   /*
    *  Ensure that the resulting name is well formed.
   */
   *(Dest++) = '=' ;
   *Dest = 0 ;

   /*
    *  Delete this sub string if found in the environment
   */
   Mstr_delenv ( Env , EnvSize , Temp_Name ) ;

   /*
    *  Locate the END of the Master table by locating a zero length
    *  String in it
   */
   Sub_Env = Env ;
   for ( ; *Sub_Env ; )
   {
     for ( ; *(Sub_Env++) ; ) ;
   }

   /*
    *  Add the new string to the END of the existing environment, with
    *  trincation IF needed
   */
   for ( Dest = (char huge *)(Sub_Env) , Src = name , End_Env = (char huge *) (Env + EnvSize ) ;
         ( Dest < End_Env ) && (*Src) ;
         *(Dest++) = *(Src++) ) ;

   Done = -1 ;
   if ( !*Src )
   {
     /*
      *  If the string to add was FULLY added, ensure that the
      *  newly updated environment is properly finished
     */
     Done = 0 ;
     *(Dest++) = 0 ;
     *Dest = 0 ;
   }

   /*
    *  As a real safety measure, ensure that the FINAL two bytes of the
    *  Environment are both 0. This will finish the last string AND
    *  ensure that a zero length string is also present
   */
   *(End_Env-1) = 0 ;
  *(End_Env-2) = 0 ;

   /*
    *  Free all working storage
   */
   _ffree ( Temp_Name ) ;
   
   return ( Done ) ;
 }

/******************************************************************************
  
  SOURCE FILE: ni_sys.c
  
  AUTHOR: Rick Kramer
  
  DATE: 02/20/1992
  
  SDM NUMBER:
  
  DESCRIPTION: This routine issues the system call.
  
  FUNCTIONS INVOKED:
  
  PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT: result of the system call
  
  EXTERNAL VARIABLES:
  
  CHANGE HISTORY:
  ******************************************************************************/
long SystemCall(command)
     char *command;
{
  int i;
  
  _CLI_str ("  starting SystemCall - %s",command);
  i = system(command);
  if (i != 0)
    {
      _CLI_num ("System Call returned <%d>", i) ;
      return (CLI_E_FAILURE) ;
    }
  _CLI_str("  ending SystemCall",0);
  return(CLI_S_SUCCESS);
} /* SystemCall */


/******************************************************************************
  
 SOURCE FILE: ni_del.c
  
 AUTHOR: Rick Kramer
  
 DATE: 02/20/1992
  
 SDM NUMBER:
  
 DESCRIPTION: This program deletes the installation file if no errors
 				have occurred.
  
 FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/
void DeleteFiles()
{
  char wrk[128] ;
  
  _CLI_str ("  starting DeleteFiles %s", "");
	
  strcpy(wrk, ".\\nfmpc.tak");
  _CLI_str ("delete %s", wrk);
  if (access(wrk,0)==0)
    remove(wrk);	
  
  strcpy(wrk, ".\\CNFM.EXE");
  _CLI_str ("delete %s\n", wrk);
  if (access(wrk,0)==0)
    remove(wrk);				
  
  strcpy(wrk, ".\\nfm.temp");
  _CLI_str ("delete %s", wrk);
  if (access(wrk,0)==0)
    remove(wrk);				
  
  strcpy(wrk, ".\\README");
  _CLI_str ("delete %s", wrk);
  if (access(wrk,0)==0)
    remove(wrk);				
  
  strcpy(wrk, ".\\nremove.exe");
  _CLI_str ("delete %s", wrk);
  if (access(wrk,0)==0)
    remove(wrk);	
  
  _CLI_str ("  ending DeleteFiles",0);
}/*DeleteFiles */

/******************************************************************************
  
 SOURCE FILE: rem_dir.c
  
 AUTHOR: Rick Kramer modified by Melania M Seward 09/09/92
  
 DATE: 02/25/1992
  
 SDM NUMBER:
  
 DESCRIPTION: This program will delete NFMPC programs, files and directories.
  
   FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT: 0=ok, -1 = errors
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/

long RemoveDir_Files (dir_name)
char *dir_name;
{
  char binpath[128], cfgpath[128], dpath[128];
  char temppath[128];
  
  strcpy(dpath, dir_name);
  sprintf(binpath, "%s\\bin", dpath);
  sprintf(cfgpath, "%s\\cfg", dpath);
  sprintf(temppath, "%s\\temp", dpath);
  
  _CLI_str ("removing files from <%s>", binpath) ;
  if (DeleteFiles(binpath) !=0)
    {
      return (CLI_E_FAILURE) ;
    }
  
  _CLI_str ("removing files from <%s>", cfgpath) ;
  if (DeleteFiles(cfgpath) !=0)
    {
      return (CLI_E_FAILURE) ;
    }
  if (access(temppath, 0) ==0)	
    {
      _CLI_str ("removing files from <%s>", temppath) ;
      if (DeleteFiles(temppath) !=0)
	{
	  return (CLI_E_FAILURE) ;
	}
    }
  
  /* remove files in nfm directory */
  _CLI_str ("removing files from <%s>", dpath) ;
  if (DeleteFiles(dpath) !=0)
    {
      return (CLI_E_FAILURE) ;
    }
  
  /* remove directories */
  _CLI_str ("removing directory <%s>", binpath) ;
  if (rmdir(binpath) !=0)
    {
      return (CLI_E_FAILURE) ;
    }	

  _CLI_str ("removing directory <%s>", cfgpath) ;
  if (rmdir(cfgpath) !=0)
    {
      return (CLI_E_FAILURE) ;
    }	

  if (access(temppath, 0) ==0)	
    {
      _CLI_str ("removing directory <%s>", temppath) ;
      if (rmdir(temppath) !=0)
	{
	  return (CLI_E_FAILURE) ;
	}	
    }

  _CLI_str ("removing directory <%s>", dpath) ;
  if (rmdir(dpath) !=0)
    {
      return (CLI_E_FAILURE) ;
    }	
  return (CLI_S_SUCCESS) ;
}/* RemoveDir_FIles */

/******************************************************************************
					DeleteFiles
******************************************************************************/
long DeleteFiles_inPath(path)
char *path;
{
  struct find_t fileinfo;
  int result;
  char wrk[128];
  
  sprintf(wrk, "%s\\*.*", path);
  result = _dos_findfirst(wrk, 0, &fileinfo);
  if (result !=0)
    return(CLI_S_SUCCESS) ;
  
  while (!result)
    {
      sprintf(wrk, "%s\\%s", path, fileinfo.name);
      if (remove(wrk))
	return (CLI_E_FAILURE) ;
      result = _dos_findnext(&fileinfo);
    }
  return(CLI_S_SUCCESS) ;
}/* DeleteFiles */

/******************************************************************************
  
 SOURCE FILE: rem_path.c
  
 AUTHOR: Rick Kramer
  
 DATE: 02/25/1992
  
 SDM NUMBER:
  
 DESCRIPTION: This routine removes the NFMPC path from the autoexec.bat file
 				 and from the current environment.
  
   FUNCTIONS INVOKED:
   						str_pos(rtns.c)
						copy(rtns.c)
						AddPath(di_path.c)

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/

long RemovePath_auto(path_name)
char *path_name;
{
  FILE *old_file,*new_file;
  char dataline[255],oldpath[255], newpath[255];
  char left[130], right[130];
  int i,j;
  char *getenv(), *value;
  
  _CLI_str ("  Starting RemovePath\n",0);
  
  /* back up autoexec.bat */
  i=system ("copy c:\\AUTOEXEC.BAT c:\\AUTOEXEC.DMD > NUL");

  /* update the path line */
  old_file = fopen("c:\\AUTOEXEC.DMD","r");
  new_file = fopen("c:\\AUTOEXEC.BAT","w");
  
  fgets(dataline,255,old_file);
  while (!feof(old_file))
    {
      if (str_pos("rem ", dataline, 1)!=0)
	{
	  fprintf(new_file,"%s",dataline);
	  goto bypass;
	}

      i=str_pos("%path%", dataline, 1);
      if (i <=0)
	{
	  fprintf(new_file,"%s",dataline);
	}
      else
	{
	  i = str_pos(path_name, dataline);
	  _CLI_num ("i=%d",i);
	  _CLI_str ("path=%s", path_name) ;
	  if (i ==0)
	    {
	      fprintf(new_file,"%s",dataline);
	    }
	}
    bypass:
      fgets(dataline,255,old_file);
    }/* while */
  fclose(old_file);
  fclose(new_file);
  
  /* remove nfm path to current environment */
  value = getenv("PATH");
  if (value != (char *)0)
    strcpy(oldpath, value);
  
  i =str_pos(path_name, oldpath, 1);
  if (i !=0);
  {
    j = strlen(path_name);
    copy (oldpath, 1, i-1,left);/* left side */
    copy (oldpath, i+1+j,200, right);/* right side */
    sprintf(newpath, "PATH=%s%s", left,right);		
    _CLI_str ("path [%s]\n", newpath);
    AddPath(newpath);
  }

  _CLI_str ("  Ending RemovePath\n",0);
  return (CLI_S_SUCCESS) ;
} /* RemovePath */


