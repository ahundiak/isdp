/****************************************************************/
/*								*/
/*		PcTools library		         		*/
/*								*/
/*	contains functions for common PPL tasks		        */
/*								*/
/*		Maciej Jablkowski 				*/
/*								*/
/*		Intergraph, February 2000			*/
/*								*/
/****************************************************************/
/*
   02-03-2000	error_service
                ctl_status
                set_value
                get_value
                open_vds_file
                get_env_var

*****************************************************************/

#ifndef MJPPL_H_INCLUDED
#define MJPPL_H_INCLUDED 1

#include "vdsmacros.h"

//#define TOOLS_DEBUG


/*
=========================================================
void error_service( char   *format, 
                   int     _exit );
=========================================================

    This function is used to print the 'format' message
    and exit if '_exit':

    char        *format  I : format to be printed

    int          _exit   I : 1 - exit,  0 - do not exit
*/
void error_service( format, _exit )
char    *format;
int      _exit;
{
  printf(format);
  if( _exit )
    exit;
}
/*
=========================================================
int set_value( char   	*name,
               void   	*ptr,
               int     	 size,
               GRobj  	 file );
=========================================================

    This function is used to transfer variable value from
    current file to another PPL loaded file.

    char        *name  I : variable name in target PPL file

    void        *ptr   I : variable pointer in current file

    int          size  I : size of variable in bytes

    GRobj        file  I : target file objid
*/
set_value( name, ptr, size, file )
char  *name;
char  *ptr;
int    size;
GRobj  file;
{
  IGRlong stat;

  ci$set_value( name   = name,
                p_val  = ptr,
                size   = size,
                file   = file,
                stat   = &stat );
  if( stat == CI_E_OBJCT_EMPTY ) 	// *** Error in cierrordef.h
  {
    printf("Target PPL file not loaded\n");
    return(1);
  }
  if( stat == CI_W_NO_SUCH_VAR )
  {
    printf("Target PPL variable : %s - does not exist\n", name);
    return(1);
  }
  return(0);
}
/*
=========================================================
int get_value( char   	*name,
               void   	*ptr,
               int     	 size,
               GRobj  	 file );
=========================================================

    This function is used to transfer variable value to
    current file from another PPL loaded file.

    char        *name  I : variable name in target PPL file

    void        *ptr  I/O: variable pointer in current file

    int          size  I : size of variable in bytes

    GRobj        file  I : target file objid
*/
get_value( name, ptr, size, file )
char  *name;
char  *ptr;
int    size;
GRobj  file;
{
  IGRlong stat;

  ci$set_value( name   = name,
                p_val  = ptr,
                size   = size,
                file   = file,
                stat   = &stat );
  if( stat == CI_E_OBJCT_EMPTY )	// *** Error in cierrordef.h
  {
    printf("Target PPL file not loaded\n");
    return(1);
  }
  if( stat == CI_W_NO_SUCH_VAR )
  {
    printf("Target PPL variable : %s - does not exist\n", name);
    return(1);
  }
  return(0);
}

void ctl_status( status, string )
int   status;
char *string;
{
  if( !(status&1) )
  {
    printf("%s \n", (string) );
    om$report_error( sts = status );
    exit; 
  }
}


/*-------------------------------------------------------------------------------------
 * Function opens a file in VDS directories looking at SearchPath and ProdPath
 *-------------------------------------------------------------------------------------*/

FILE * open_vdsfile( SearchPath, ProdPath, Filename )
  char *SearchPath;
  char *ProdPath;
  char *Filename;
{
  char filestat[80], path[80];
  FILE *file;
  int msg;
  
#ifdef DEBUG
  printf("Opening file %s in directory %s\n", Filename, SearchPath);
#endif
  
  vd$file_path(	msg                          = &msg,
                fileToFind                   = Filename,
                dirToSearchFirst             = SearchPath,
                dirInProdPathToSearchThen    = ProdPath,
                absPathName		     = path );


#ifdef DEBUG
  printf("\nData file: %s\n", path );
#endif

  file = fopen( path, "rt" );
  if( file == NULL ) {
    strcpy( filestat, "Could not open " );
    strcat( filestat, Filename );
    strcat( filestat, " for reading." );
    status( filestat );
    return(NULL);
  }
  else
    return( file );
}


  
/*----------------------------------------------------------------------------
 * Function returns path to $HOME directory of current user
 *----------------------------------------------------------------------------*/

char * get_env_var( env_var )
  char *env_var;  
{
  char env_val[80];
  
  strcpy( env_val, getenv( env_var ) );

#ifdef TOOLS_DEBUG
  printf("Got: %s\n", env_val );
#endif

  return(env_val);
  
}



#endif
