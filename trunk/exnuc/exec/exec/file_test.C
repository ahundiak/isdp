#include "exsysdep.h"
#include <errno.h>
#if defined( NT )
#include <io.h>
#endif
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <execmsg.h>
#include <stdlib.h>
#include <exproto.h>
#include <string.h>

#define debug 0

extern char CS_path_name[];
/*helpnt getuid*/
extern uid_t getuid();
extern uid_t geteuid();

int file_exists(fname,env,path_dir,ret_fname)
char *fname,*env,*path_dir,*ret_fname;
{
    
    
      int return_val;
#ifdef CLIX
      struct statl buf;
#elif defined (NT)
      struct _stat buf;      
#else
      struct stat buf;
#endif
      char *temp,buffer[256],default_path[256];
    
      strcpy(default_path,fname);
      module_build_path(default_path);
#ifdef CLIX
      return_val = statl(default_path,&buf);
#elif defined (NT)
      return_val = _stat(default_path,&buf);
#else
      return_val = stat(default_path,&buf);
#endif
#if debug
      printf("file_exists,  default_path=%s\n",default_path);
      printf("file_exists,  return_val=%d\n",return_val);
#endif
      if(return_val == 0)
      {
         strcpy(ret_fname,default_path);
         return(0);
      }
      
      if(env != 0)
      {
          temp = (char *)getenv(env);
          if(temp != 0)
          {
               strcpy(buffer,temp);
               strcat(buffer,"/");
               strcat(buffer,fname);
#ifdef CLIX
               return_val = statl(buffer,&buf);
#elif defined (NT)
               return_val = _stat(buffer,&buf);
#else
               return_val = stat(buffer,&buf);
#endif
#if debug
               printf("file_exists,  buffer=%s\n",buffer);
               printf("file_exists,  return_val=%d\n",return_val);
#endif
               if(return_val == 0)
               {
                  strcpy(ret_fname,buffer);
                  return(1);
               }
           } 
       } /* if(env!=0) */
    
      if(path_dir != 0)
      {
            strcpy(buffer,CS_path_name);
            strcat(buffer,path_dir);
            strcat(buffer,"/");
            strcat(buffer,fname);
#ifdef CLIX
            return_val = statl(buffer,&buf);
#elif defined (NT)
               return_val = _stat(buffer,&buf);
#else
            return_val = stat(buffer,&buf);
#endif
#if debug
            printf("file_exists,  buffer=%s\n",buffer);
            printf("file_exists,  return_val=%d\n",return_val);
#endif
            if(return_val == 0)
            {
                strcpy(ret_fname,buffer);
                return(2);
            }
       } /* if(path_dir!=0) */
      
      if((return_val == ENOTDIR) || (return_val == ENOENT))
      {
          *ret_fname = 0;
          return(-1);
      }
      else if(return_val == EACCES)
      {
          *ret_fname = 0;
          return(-2);
      }
      else
      {
          *ret_fname = 0;
          return(-3);
      }

 } /* file_exists */



filetest()
{
#ifdef CLIX
    struct statl stat1;
#elif defined (NT)
    struct _stat stat1;
#else
    struct stat stat1;
#endif
    int ii;
    
    printf("\n");
    for (ii = 0; ii < 24; ii++)
    {
#ifdef CLIX
        if (fstatl(ii, &stat1) == 0)
#elif defined (NT)
        if (_fstat(ii, &stat1) == 0)
#else
        if (fstat(ii, &stat1) == 0)
#endif
        {
          printf ("file descriptor = %d, i-node = %d, dev= %d, file size = %d\n",ii,
stat1.st_ino,stat1.st_dev,stat1.st_size);
        }
        else
        {
            printf ( "errno on file %d = %d", ii, errno);
            perror("file test");
        }
    }   
    return(1); 
}



 int EX_check_file( filename,   print_flag  )
   char *filename;
   int print_flag;
/* this routine return 0 if file is valid , -1 if file not exist  */
/* and msg number if file is not valid                            */
/*   return -1 if file not exist                                  */
/*           0 if file is old . with good permission              */
/*          >0 if error                                           */
{
#ifdef CLIX
    struct statl fbuf;
#elif defined (NT)
    struct _stat fbuf;
#else
    struct stat fbuf;
#endif
    FILE *fp;
    int result, ret;
    int uid,euid; 
 
/*helpnt getuid geteuid*/
    ret = 0;
    uid = getuid();
    euid = geteuid();

#ifdef CLIX
   result = statl(filename,&fbuf);
#elif defined (NT)
   result =  _stat(filename,&fbuf);
#else
   result = stat(filename,&fbuf);
#endif
   if( result == -1 )
   {
       if (errno == ENOENT)
       {
	   fp = fopen(filename,"a");
	   if( !fp )
	   {
               if ( (uid == 0) || (euid == 0) ) return(0); /* super user */  
	       ret = EX_S_BadDir;
	       if (print_flag) printf("EX_check_file: Bad directory specified in file name <%s>\n",filename);
	   }
	   else
	   {
	     /* if we reached here, file does not exist. */
#ifndef NT
	      unlink(filename);
#else
	      _unlink(filename);
#endif
	      fclose(fp); 
	      ret = -1;
	   }
       }
#ifndef NT
       else if ( errno == ENOTDIR )
       {  
           ret = EX_S_NotDir;
	   if (print_flag) printf("EX_check_file: A component of the path is not a directory. <%s>\n",filename);
       }
#endif
       else if ( errno == EACCES )
       {  
           if ( (uid == 0) || (euid == 0) ) return(0); /* super user */  
	   ret = EX_S_Access;
	   if (print_flag) printf("EX_check_file: Search permission is denied for a component of the path. <%s>\n",filename);
       }
#ifndef NT
       else if ( errno == ENOLINK )
       {  
	   ret = EX_S_NoLink;
	   if (print_flag) printf("EX_check_file: Path points to a remote machine, but link is not active. <%s>\n",filename);
       }
       else if ( errno == EMULTIHOP )
       {  
	   ret = EX_S_MultiHop;
	   if (print_flag) printf("EX_check_file: Require hopping to multiple remote machines. <%s>\n",filename);
       }
#endif
       else
       {
	   ret = 1;
	   if (print_flag) printf("EX_check_file : Generic error1 on file <%s>.\n",filename);
       }
   }
   else /* stat return good , file is there*/
   {
       fp = fopen(filename,"r");
       if (!fp)
       {
	  ret = EX_S_NoReadPerm;
	  if (print_flag) printf("EX_check_file: No read permission on file <%s>.\n", filename);
       }
       else /* we opened the file , protection is correct */
       {
	 ret = 0;
	 fclose(fp);
       }
   }
   return(ret);
}

int EX_is_reg_file( filename )
char *filename;
{
#ifdef CLIX
    struct	statl s1;
#elif defined (NT)
    struct	_stat s1;
#else
    struct	stat s1;
#endif

    /* stat will get the link file information */

#ifdef CLIX
    if (statl(filename, &s1) < 0) return(0);
#elif defined (NT)
    if (_stat(filename, &s1) < 0) return(0);
#else
    if (stat(filename, &s1) < 0) return(0);
#endif
/*helpnt*/
#ifndef NT
    if( (s1.st_mode & S_IFMT) == S_IFREG )
    {
	return(1);
    }
    else
#endif    
    {
        return(0);
    }
}


