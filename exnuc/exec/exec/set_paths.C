#include "exsysdep.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <OMminimum.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <exproto.h>
#include <string.h>
#include <wl.h>

#define debug 0
extern char *getenv();
extern char CS_path_name[];
extern char EX_filename[];
extern char EX_seedfile[];
extern char *EX_firstcmd;
extern int  EX_mod_type;
extern int  EX_create;
extern struct EX_global EX_global_var;
extern int EX_process_unknowns;
extern int EX_hilite;
extern int EX_double_buffer;
extern int EX_context_depth;
extern int EX_context_type;
extern char  EX_proddata_file[];

static char  EX_executable_path[256];
static char  EX_user_srch_path[256];

#ifdef X11
extern char EX_runname[];
extern char EX_display_name[];
#endif

module_build_path(path_name)
char *path_name;
{
  char temp_path[256];

#  if debug
      printf("module_build_path in,  path_name=%s\n",path_name);
#  endif
   if(path_name[0]=='/')
   {
       fix_directory(path_name);
   }
   else
   {
       strcpy(temp_path,EX_global_var.working_dir);
       strcat(temp_path,path_name);
       fix_directory(temp_path);
       strcpy(path_name,temp_path);
   }
#  if debug
      printf("module_build_path out,  path_name=%s\n",path_name);
#  endif
return(1);
 } /* module_build_path */


module_set_pathname(string)
char  *string;
{
   register int   i;
   int            return_val;
   char           path_name[256], *ptr, *temp;

   if ((return_val = EX_check_stat(string, 0)) == 1)
      strcpy(path_name, string);
   else
   {
      if (temp = getenv("PATH"))
      {
         if (temp[0] == ':')
            ptr = &temp[1];
         else
            ptr = temp;
         while (*ptr)
         {
            if (temp = strchr(ptr, ':'))
            {
               strncpy(path_name, ptr, i = temp - ptr);
               path_name[i] = '/';
               path_name[i+1] = 0;
               ptr = temp + 1;
            }
            else
            {
               sprintf(path_name, "%s/", ptr);
               ptr += strlen(ptr);
            }
            strcat(path_name,string);
            return_val = EX_check_stat(path_name, 0);
            if (return_val == 1)
               break;
         }
      }
   } /* if(return_val==0) */

   module_build_path(path_name);
   strcpy(CS_path_name, path_name);
   strcpy(EX_executable_path, path_name);
   for(i = 0; i < 3; i++)
   {
      if (ptr = strrchr(CS_path_name, '/'))
         *ptr = 0;
      else
      {
         CS_path_name[0] = 0;
         break;
      }
   }
   if (ptr)
      strcat(CS_path_name, "/");
   strcpy(EX_global_var.support_dir, CS_path_name);   /* "/usr/ip32/" */
   return(1);
} /* module_set_pathname */


module_set_def_dir()
{
  char *pwd;
  char local_pwd[OM_K_MAXOSNAME_LEN];

    EX_global_var.working_dir[0] = '\0';
    pwd = getenv("PWD");
    if( pwd == NULL) 
    {
       EXgetcwd(local_pwd, OM_K_MAXOSNAME_LEN -1);
       strncpy(EX_global_var.working_dir,local_pwd,OM_K_MAXOSNAME_LEN-2);
       local_pwd[OM_K_MAXOSNAME_LEN-2] = 0;
       strcat(EX_global_var.working_dir ,"/");
    }
    else
    {
       strcpy(EX_global_var.working_dir,pwd);
       strcat(EX_global_var.working_dir ,"/");
    }

#     if debug
         printf("module_set_def_dir out, EX_global_var.working_dir = %s\n",EX_global_var.working_dir);
#     endif
return(1);
} /* module_set_def_dir */


fix_directory(string)
char *string;
{
  char temp[256];
  register int i,j;
  int k;
 
  temp[0] = '\0';
# if debug
     printf("fix_directory in, string =%s\n",string);
# endif
  k = strlen(string);
  for(i = 0,j = (-1); i < k;)
  {
     switch(string[i])
     {
       case '/': 
         temp[++j]=string[i++];
         while(string[i]=='/')i++;
         break;
       case '.':
         switch(string[++i])
         {
            case '/':
              while(string[i]=='/')i++;
              break;
            case '.':
              if( (string[++i]=='/') && (j>0) )
              {
                 while(string[i]=='/')i++;
                 do
                  temp[j]='\0';
                 while(temp[--j]!='/');
              }
              else
              {
                 temp[++j]=string[i-2];
                 temp[++j]=string[i-1];
                 temp[++j]=string[i++];
              }
              break;
           default:
              temp[++j]=string[i-1];
              temp[++j]=string[i++];
              break;
         } /* switch */
         break;
       default:
          temp[++j]=string[i++];
          break;
     } /* switch */
   } /* for loop */ 
   if (j > 0 ) temp[++j] = '\0';
   strcpy(string,temp);
#  if debug
      printf("fix_directory out, string =%s\n",string);
#  endif
return(1);
 } /* fix_directory */

static EX_use_def_dir = 0;

module_get_def_dir(argc,argv)
int argc;
char *argv[];
{
    extern char *optarg;
    extern int optind;

    int i;
    int errflag = 0;
    optind = 1;
    EX_filename[0] = '\0';
    EX_proddata_file[0] = '\0';
    EX_context_type =  WL_UNDEFINED_VALUE;
    EX_hilite = 1;
    EX_double_buffer =  WL_UNDEFINED_VALUE;
    EX_context_depth = WL_UNDEFINED_VALUE;
    EX_mod_type = -1;
    EX_create = FALSE;
    EX_user_srch_path[0] = '\0';
    EX_seedfile[0] = '\0';
#ifdef X11
    EX_display_name[0] = '\0';
#endif

    for ( i= 1; i< argc; i++ )
    {
        char *arg = argv[i];
        if ( arg[0] == '-' )
        {
            if ( !(strcmp(argv[i],"-window_depth")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    EX_context_depth = atoi(argv[i]);
                }
            }
            else if  ( !(strcmp(argv[i],"-window_type")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    if (!(strcmp(argv[i],"truecolor")))
                        EX_context_type = WL_CMAP_TRUE_COLOR;
                    else if (!(strcmp( argv[i], "indexed")))
                        EX_context_type = WL_CMAP_INDEXED;
 
                }
            }
            else if  ( !(strcmp(argv[i],"-double_buffer")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    if (!(strcmp(argv[i],"true")))
                        EX_double_buffer = 1;
                    else if (!(strcmp(argv[i],"false")))
                        EX_double_buffer = 0;
                }
            }
            else if  ( !(strcmp(argv[i],"-pd")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    strncpy(EX_proddata_file,argv[i],512);
                }
            }

            else if  ( !(strcmp(argv[i],"-num_wm_colors")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    WLset_num_wm_colors(atoi(argv[i]));
                }
            }

            else if  ( !(strcmp(argv[i],"-num_ingr_colors")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    WLset_num_ingr_colors(atoi(argv[i]));
                }
            }

  #ifdef X11
            else if  ( !(strcmp(argv[i],"-display")))
            {
                if(++i >= argc)++errflag;
                else
                {
                    strcpy(EX_display_name,argv[i]);
                }
            }
  #endif
            else
            {
      
                switch (arg[1])
                {
                  case 'd':
                    switch (arg[2])
                    {
#ifdef X11
                      case 'i':
		
                        if( ++i >= argc )  ++errflag;
                        else
                        {
                            strcpy(EX_display_name,argv[i]);
                        }
                        break;
#endif
                      case '\0': 		     
                        if( ++i >= argc )  ++errflag;
                        else
                        {
                          if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-2)
                            ++errflag;
                          else
                          {
                            strcpy(EX_global_var.working_dir,argv[i]);
                            strcat(EX_global_var.working_dir,"/");
                            fix_directory(EX_global_var.working_dir);
                            EX_use_def_dir = 1; 
                          }
                        }
                        break;
                    }
                    break;

                  case 'f':
                    if( ++i >= argc )  ++errflag;
                    else
                        if ( strncmp(argv[i],"OMipcl=",7) )
                        {
                          if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-1)
                            ++errflag;
                          else
                            strcpy(EX_filename,argv[i]);
                        }
                    break;
                  case 'c':
                    EX_create = TRUE;
                    switch( arg[2] )
                    {
                      case 'b':
                        break;  
                      case 'd':
                        switch (arg[3])
                        {
#ifdef X11
                          case 'i':
                            if( ++i >= argc )  ++errflag;
                            else
                            {
                                strcpy(EX_display_name,argv[i]);
                            }
                            break;
#endif
                          case '\0':                   
                            if( ++i >= argc )  ++errflag;
                            else
                            {
                             if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-2)
                                ++errflag;
                             else
                              {
                                strcpy(EX_global_var.working_dir,argv[i]);
                                strcat(EX_global_var.working_dir,"/");
                                fix_directory(EX_global_var.working_dir);
                                EX_use_def_dir = 1; 
                              }
                            }
                            break;
                        }
                        break;

                      case 'f':
                        if( ++i >= argc )  ++errflag;
                        else
                            if ( strncmp(argv[i],"OMipcl=",7) )
                            {
                             if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-1)
                                ++errflag;
                             else 
                                strcpy(EX_filename,argv[i]);
                            }
                        break;
                      case 'C':
                        if( ++i >= argc ) ++errflag;
                        else
                            EX_cmdgetptr(argv[i],&EX_firstcmd);
                        break; 

                      case 's':
                        if( ++i >= argc ) ++errflag;
                        else
                        {
                          if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-1)
                            ++errflag;
                          else
                            strcpy(EX_seedfile,argv[i]);
                        }
                        break;

                      case 'S':
                        if( ++i >= argc ) ++errflag;
                        else
                            strcpy(EX_user_srch_path,argv[i]);              
                        break;
#ifdef X11
                      case 'Z':
                        EX_set_sync(); 
                        break;  
#endif
                    }
                    break; 
                  case 'C':
                    if( ++i >= argc ) ++errflag;
                    else
                        EX_cmdgetptr(argv[i],&EX_firstcmd);
                    break; 
                  case 'b':
                    switch( arg[2] )
                    {
                      case 'c':
                        EX_create = TRUE;
                        break;  
                      case 'd':
                        switch (arg[3])
                        {
#ifdef X11
                          case 'i':
                         
                            if( ++i >= argc )  ++errflag;
                            else
                            {
                                strcpy(EX_display_name,argv[i]);
                            }
                            break;
#endif
                          case '\0':                   
                            if( ++i >= argc )  ++errflag;
                            else
                            {

                             if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-2)
                                ++errflag;
                             else
                             {
                                strcpy(EX_global_var.working_dir,argv[i]);
                                strcat(EX_global_var.working_dir,"/");
                                fix_directory(EX_global_var.working_dir);
                                EX_use_def_dir = 1; 
                             }
                            }
                            break;
                        }
                        break;

                      case 'f':
                        if( ++i >= argc )  ++errflag;
                        else
                            if ( strncmp(argv[i],"OMipcl=",7) )
                            {
                              if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-1)
                                ++errflag;
                              else
                                strcpy(EX_filename,argv[i]);
                            }
                        break;
                      case 'C':
                        if( ++i >= argc ) ++errflag;
                        else
                            EX_cmdgetptr(argv[i],&EX_firstcmd);
                        break; 

                      case 's':
                        if( ++i >= argc ) ++errflag;
                        else
                        {
                          if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-1)
                            ++errflag;
                          else
                            strcpy(EX_seedfile,argv[i]);
                        }
                        break;

                      case 'S':
                        if( ++i >= argc ) ++errflag;
                        else
                            strcpy(EX_user_srch_path,argv[i]);              
                        break;
#ifdef X11
                      case 'Z':
                        EX_set_sync(); 
                        break;  
#endif
                    }
                    break;  
                  case 's':
                    if( ++i >= argc ) ++errflag;
                    else
                    {
                      if ( strlen(argv[i]) > OM_K_MAXOSNAME_LEN-1)
                        ++errflag;
                      else
                        strcpy(EX_seedfile,argv[i]);
                    }
                    break;
                  case 'S':
                    if( ++i >= argc ) ++errflag;
                    else
                        strcpy(EX_user_srch_path,argv[i]);              
                    break;
                  case '?':
                    errflag++;
                    break;
#ifdef X11
                  case 'Z':
                    EX_set_sync(); 
                    break;
#endif
                  case 'U':
                    EX_process_unknowns = 1;
                    break;
                }               /* switch */
            }
        }
    }
    if(errflag)
    {
        fprintf(stderr, "usage: %s -c [-f file-name ] [-s seed-file-name] [-C first cmd ] [-p product name] [-S user search path ]\n [-display nodename:0.0] [-rn resource-name] [-U]\n",argv[0]);
        exit(1);
    }
    return(1);
}                               /* module_get_def_dir */


valid_filename(str, path)
char *str, *path;
{
   register int   len;
   char           *ptr;

   if (str[len = strlen(str)-1] == '/')
      str[len] = '\0';
   if (ptr = (char *) strrchr(str, '/'))
   {
      strncpy(path, str, ++ptr - str);
      path[ptr - str] = '\0';
   }
   else
   {
      *path = '\0';
      ptr = str;
   }
   if ((len = strlen(ptr)) > 10)
      ptr[10] = '\0';
   if (ptr != str)
      strcpy(str, ptr);
return(1);     
}


int EX_check_stat (path,ftype)
char *path;
int *ftype;
{
#ifndef NT
    struct stat buf;
#else
    struct _stat buf;
#endif
#ifndef NT
    if ( stat (path, &buf) == 0)
#else
    if ( _stat (path, &buf) == 0)
#endif
    {
        if( ftype )
	{
#ifndef NT	    
           if ((buf.st_mode & S_IFDIR) == S_IFDIR ) *ftype = S_IFDIR;
           if ((buf.st_mode & S_IFCHR) == S_IFCHR ) *ftype = S_IFCHR;
           if ((buf.st_mode & S_IFBLK) == S_IFBLK ) *ftype = S_IFBLK;
           if ((buf.st_mode & S_IFIFO) == S_IFIFO ) *ftype = S_IFIFO;	   
           if ((buf.st_mode & S_IFREG) == S_IFREG ) *ftype = S_IFREG;
#else
           if ((buf.st_mode & _S_IFDIR) == _S_IFDIR ) *ftype = _S_IFDIR;
           if ((buf.st_mode & _S_IFREG) == _S_IFREG ) *ftype = _S_IFREG;
#endif           
	   return(1);
        }
        else
	{
#ifndef NT	    
           return( ((buf.st_mode & S_IFREG) == S_IFREG ) ? 1 : 0 );
#else
           return( ((buf.st_mode & _S_IFREG) == _S_IFREG ) ? 1 : 0 );
#endif           
	}
    }
    else
    {
        return (0);
    }
}


int  EX_use_default_dir()
{
   return(    EX_use_def_dir  );
}



int EX_get_executable_path( path )
char *path;
{
    if ( path != NULL )
    {
       strcpy(path,EX_executable_path);
    }
    return(1);
}
int EX_get_user_srch_path( path )
char *path;
{
    if ( path != NULL )
    {
       strcpy(path,EX_user_srch_path);
    }
    return(1);
}

