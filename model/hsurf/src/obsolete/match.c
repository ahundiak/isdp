
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include <stdio.h>
#include <tools.h>
#include <EG.h>
#include "dpgraphics.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSpr_co_func.h"

#define ERROR	1
#define DEBUG	0
#define DEBUG2	0

#define SIGNAL_RECEIVED		-1

/*
 * HSfork() forks a child process from Ems rather than drive. It waits for the child to finish
 * before returning in the parent process. The child process begins and ends here within this function.
 *
 * HISTORY: 07/17/90	Created.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	int HSfork( int num_entries,
		   char *argstr[],
		    int wait_flag )
#else
	int HSfork( num_entries, argstr, wait_flag )
	int num_entries;
	char *argstr[];
	int wait_flag;
#endif

{
	int stat_loc, pid, wt, rc;

#if DEBUG
	fprintf( stderr, "Passing to execvp() %s %s and %s\n", argstr[0], argstr[0], argstr[1] );
#endif
	/* The child process */
	if( (pid = vfork()) == 0 )
	{
#if DEBUG
		fprintf( stderr, "Inside the child, pid = %d\tgetpid = %d\n", pid, getpid() );
#endif
		argstr[2] = (char *)NULL;
		rc = execvp( argstr[0], argstr );
#if DEBUG2
		fprintf( stderr, "%s %s returns %d\n", argstr[0], argstr[1], rc );
#endif
	}
	else /* parent process */
	{
		/* wait for the child process to finish and return */
#if DEBUG
		fprintf( stderr, "Waiting in the parent, pid = %d\tgetpid = %d\n", pid, getpid() );
#endif
		if( wait_flag )
		{
			do
			{
				wt = wait( &stat_loc );
#if DEBUG2
				fprintf( stderr, "Inside the parent\twt = %d\tstat_loc = %x\n",
					wt, stat_loc );
#endif
			}
			while( stat_loc && wt != SIGNAL_RECEIVED );
		}
#if DEBUG
		fprintf( stderr, "Inside the parent, finished waiting.\twt = %d\tstat_loc = %x\n",
			wt, stat_loc );
#endif
	}

	return (0);

} /* HSfork */

#if defined(__STDC__) || defined(__cplusplus)
	int HSget_file_o_files( char file_name[],
				FILE **name_file_ptr,
				char *file_o_files )
#else
	int HSget_file_o_files( file_name, name_file_ptr, file_o_files)
	char file_name[], *file_o_files;
	FILE **name_file_ptr;
#endif

{
	int len, test, ret;
	char ch, *temp_fname1, *temp_fname2;
	char *argstr[3];
	char comm_str[40];
	FILE *datfile1,*datfile2;

	len = strlen(file_name);
	test = strspn("*", file_name);
	ch = file_name[len-1];
	if( test != 0 )
		ch = '*';

	if ( (ch != '*') && (ch != '~') )/* user used a simple file name */
	{
		temp_fname2 = tmpnam(NULL);
		datfile2 = fopen ( temp_fname2, "w");
		fprintf(datfile2,"%s\n",file_name);
		fclose(datfile2);
		chmod( temp_fname2, 0777);

		*name_file_ptr = fopen( temp_fname2, "r");
		if( *name_file_ptr == NULL )
			return(ERROR);
		else
			strcpy( file_o_files, temp_fname2 );
		return(0);
	}
	else if( ch == '*' ) /* user used a wild card in file name */
	{
		temp_fname1 = tmpnam(NULL);
		temp_fname2 = tmpnam(NULL);

		datfile1 = fopen (temp_fname1, "w");
		datfile2 = fopen (temp_fname2, "w");

		fprintf (datfile1, "ls $1 > %s", temp_fname2);

		fclose (datfile1);
		fclose (datfile2);

		chmod (temp_fname1, 0777);
		chmod (temp_fname2, 0777);

		argstr[0] = comm_str; strcpy (comm_str, temp_fname1);
		argstr[1] = file_name;

		ret = HSfork( 2, argstr, 1 );
/*		ret = ex$fork( num_entry = 2, argu = argstr, wait_flag = 1); */

		switch ( ret >> 8 )
		{
		case 0:
			/* Forked ls was successful */
			break;
		case 2:
			/* Forked ls failed		*/
			return(ERROR);
		}/* end case	*/

		*name_file_ptr = fopen(temp_fname2 , "r" );
		if( *name_file_ptr == NULL )
			return(ERROR);

		strcpy( file_o_files, temp_fname2 );
		return(0);
	}
	else /* user used a tilde file containing the names of rle files */
	{
		*name_file_ptr = fopen(file_name, "r");
		if( *name_file_ptr == NULL )
			return(ERROR);
		else
			return(0);
	}

} /* HSget_file_o_files */

/*****************************************************************************

#include <sys/param.h>
#include <sys/types.h>
#include <sys/dir.h>
#include <stdio.h>


#if defined(__STDC__) || defined(__cplusplus)
	HSget_list_o_files( char filename[],
			    FILE *f_ptrs[],
			     int *num,
			     int max_files )
#else
	HSget_list_o_files( filename, f_ptrs, num, max_files )

	char filename[];
	FILE *f_ptrs[];
	int  *num;
	int  max_files;
#endif

  
  {
   FILE *dirf;
   char dir[100], files[20];
   char name[20], *np, *fp, t_dir[100];
   char temp_name[132];
   struct direct dentry;
   int i, tname, y_o_n, cnt, find_slash, go=1;
   int no_slash;  	

   dir[0] = '\0';
  
   find_slash = strchr(filename, '/');

   if ( find_slash == 0 )
     { 
      strcat( dir,"./");
      strcpy( files, filename);
     }
   else
     {
      tname = find_slash + 1;
      strcpy( t_dir, tname);

      while ( go == 1 )
       {
        find_slash = strchr(  t_dir, '/');
        if ( find_slash == 0 )
          {
           go=0;       
           strcpy( files, t_dir );
           no_slash = strlen( filename );
           while ( no_slash != 0)
             {
             	if ( filename[no_slash] == '/' )
             	  no_slash = 0;
             	else
             	   filename[no_slash--] = ''; 
              }
            strcpy( dir, filename);
           }   
      else
        {
         tname = find_slash + 1;
         strcpy( t_dir, tname );
        }
     }
} 
   cnt = -1;
   *num = 0;

   if ((dirf = fopen(dir,"r")) == NULL)
     return (5);
   else
     {
      for (;;)
        {
         if ( fread( (char *) &dentry, sizeof(dentry), 1, dirf) != 1)
           break;  
         if ( dentry.d_ino == 0 ||
              dentry.d_name[0] == '.' && ( dentry.d_name[1] == '\0' ||
              dentry.d_name[1] == '.' && dentry.d_name[2] == '\0'))
           continue;
         fp = dentry.d_name;
         np = name;
         for ( i=0; i<DIRSIZ; i++)
           *np++ = *fp++;
         *np = '\0';

         y_o_n = HSmatch ( files, name );
         if ( y_o_n == 1)
          {
	   cnt++;
	   if ( cnt == max_files )
	      {
	      HSfile_error(7);
	      cnt--;
	      break;
	      }
	   strcpy( temp_name, dir);
           strcat( temp_name, name );
	   f_ptrs[cnt] = fopen( temp_name, "r" );
	   if (f_ptrs[cnt] == NULL)
	      return(1);
          }
        }
     }
     *num = cnt + 1;
     return(0);
  }                

#if defined(__STDC__) || defined(__cplusplus)
	HSmatch( char *str1, char *str2 )
#else
	HSmatch( str1, str2)
	char *str1, *str2;
#endif

  {
   char cb,ce;

   if ( !(*str1) && ! ( *str2))
      return(1);

   if ( ! (*str1) || !(*str2))
          return(0);

   if ( *str1 == '*')
      return (( HSmatch(str1+1, str2+1)) || (HSmatch(str1, str2+1))||(HSmatch(str1+1,str2)));

   if ((*str1 == *str2) || (*str1 == '?'))
     {
        *str1++; *str2++;
     	if ((*str1 == '*') && !(*str2 ))
     	  return(1);
     	else
          return(HSmatch(str1, str2));
      }
   if ( *str1 == '[')
     {
       	if ( * (str1+2) == '-')
       	  {
    	   cb = *(str1+1) - 1;
           ce = *(str1+3);
           while ( ce> cb++)
             {
              if (cb == *str2) return (HSmatch(str1+5, str2+1));
             }
           return(0);
          }
        while ( *str1++ != ']')
          {
           if (*str1 == *str2)
             {
          	while ( *(++str1) != ']');
            	return(HSmatch(str1+1, str2+1));
             }
          }
        return(0);
       }
     return(0);
}

**************************************************************************/
