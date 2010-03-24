/* find_file.C */

#include <stdio.h>
#include <exmacros.h>

#ifdef VERBOSE 
#define _verbose(x) x
#else
#define _verbose(x)
#endif

char * find_file ( name, med_level_dirs, found_flag )
  char * name;
  char * med_level_dirs;
  int  * found_flag;	/* used to see if an individual file */
			/*   pathname exists */
{
  int		ii, jj;
  static char	file_name[300];
  static char	path_name[500];
  char		first_dir[50];
  char	      *	ch;
  FILE  * fp;
  extern char * expand_shell_vars();
  extern char * strrchr(), * strchr();

  * found_flag = 0;

  _verbose(fprintf(stderr,"find_file name :%s:\n",name);)  
  /*** first, expand any shell variables in the name ***/
  strcpy ( file_name, expand_shell_vars(name) );
  _verbose(fprintf(stderr,"find_file exp name :%s:\n",file_name);)  
#ifndef NT
  if ( file_name[0] == '/' )
#else
  if(file_name[0] == '\\')
#endif
	/** the filename begins with a '/', **/
    {				/**   indicating it's a hard-coded  **/
      fp = fopen ( file_name, "r" );	/**   pathname	 	    **/
      if ( fp )
	{
	  * found_flag = 1;
	  if (fp != NULL) fclose(fp);
          _verbose(fprintf(stderr,"find_file / ret name :%s: found %d\n",
              file_name,*found_flag);)  
	  return ( file_name );
	}
      else
	  return NULL ;
    }
#ifndef NT
  ch = strrchr ( file_name, '/' );
#else
  ch = strrchr (file_name, '\\');
#endif
  if ( ch == NULL )	/*** the name is only a file name w/o any  ***/
    {			/***   sort of path spec in front	   ***/
			/*** so, loop thru all possible search	   ***/
			/***   paths, using the "medium_level_dirs" **/
      for ( jj = 0, ii = 1; ii ; jj++ )
	{
	  if ( ii = ex$get_path ( index = jj, path = path_name,
			     len = sizeof(path_name) ) )
	    {
	      /*** see if the file exists in this search path ***/
	      /* strcat ( pathname, "config/forms/" ); */
	      strcat ( path_name, med_level_dirs );
	      strcat ( path_name, file_name );
	      if ( fp = fopen ( path_name, "r" ) )
		{
                 if(fp != NULL)	          fclose(fp);
	          * found_flag = 1;	/*** don't look any further ***/
                  _verbose(fprintf(stderr,
                      "find_file get_path ret name :%s: found %d\n",
                      path_name,*found_flag);)  
		  return( path_name );
		}
	    }
	}
    }
  else	/*** the file name given contains a '/' somewhere other	    ***/
    {	/***   than the front (such as "ems/config/forms/myform" )  ***/
#ifndef NT
      for ( ch = file_name, ii = 0; * ch != '/' ; ii++, ch++ )
#else
 for ( ch = file_name, ii = 0; * ch != '\\' ; ii++, ch++ )
#endif
	{
	  first_dir[ii] = *ch;
	}
#ifndef NT
      first_dir[ii++] = '/';
#else
      first_dir[ii++] = '\\';
#endif
      first_dir[ii] = '\0'; /* now first_dir is 'ems/' for */
			    /*  file_name = 'ems/config/forms/myform' */

      for ( jj = 0, ii = 1; ii ; jj++ )
	{
	  if ( ii = ex$get_path ( index = jj, path = path_name,
			     len = sizeof(path_name) ) )
	    {
	      ch = strrchr (path_name, '/');	/** gets the end '/' **/

	      if ( ! strcmp ( ++ ch , first_dir ) )
		{
#ifndef NT
		  ch = strchr ( file_name, '/' );
#else
                  ch = strchr (file_name,'\\');
#endif
 		  strcat ( path_name,  ++ ch );
	          /*** see if the file exists in this search path ***/
	          if ( fp = fopen ( path_name, "r" ) )
		    {
	              if (fp != NULL) fclose(fp);
	              * found_flag = 1;	/*** don't look any further ***/
                      _verbose(fprintf(stderr,
                          "find_file get_path ret name :%s: found %d\n",
                          path_name,*found_flag);)  
		      return( path_name );
		    }
		}
	    }
	}
    }

/*quit:*/		    /*** at this point, the file search has failed, ***/
  _verbose(fprintf(stderr,"find_file fail name :%s: found %d\n",file_name,
      *found_flag);)  
  return file_name; /***   but return the file name anyway	    ***/
}

