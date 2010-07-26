/*
  ABSTRACT :
  --------

  This file contains the necessary entry points to read the config file
  of the directory sub-system.

  HISTORY :
  -------

   05/10/1988 : HGB - Design Date
   05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX
*/

class implementation DIrectory;

#include <string.h>
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"

#define DEBUG

#include "DIdef.h"
#include "DIomac.h"
#include "DIprims.h"

#define NB_CHOICE 7

#define COM 0
#define SEP 1
#define HOM 2
#define BCK 3
#define DIR 4
#define LOD 5
#define PWD 6
#define TRL 7
#define UND 99


DIget_choice ( line )
               DIchar *line;
/* this routine finds out the number of the command that starts the line;
   it returns COM for a comment line and UND for an undefined command. */
/*.DIget_choice */
{
  DIint i;
  static DIchar *choice_table [NB_CHOICE] = { "sep", "hom", "bck", "dir",
                                              "lod", "pwd", "trl" };

  if (*line == '#') return COM;
  for (i = 0; i < NB_CHOICE; i++)
      if (strncmp ( choice_table [i], line, 3) == 0) return ( i + 1 );
  
  return UND;
}



DIinit ( DIchar sep, DIchar current, DIchar home, DIchar back )
/*
   This function attempts to find a configuration file for the directory
   sub-system.  If a file can be found (in the directory given by $DIPATH)
   then it is read and executed.
*/
/*.DIconfig */
{
  FILE   *fet;
  DIchar *dipath;
  extern char  *getenv (); 
  DIchar filepath[512]	/* absolute name for ldpath, or the source */;
  DIint  status;

  if (!(dipath = getenv( "DIPATH" ))) dipath = "./";

  /*"DIPATH : '%s'\n", dipath */
  strcpy ( filepath, dipath );
  strcat ( filepath, "/IGRdir.cfg" );

  if (fet = (FILE *) fopen ( filepath, "r" ))
  {
    status = DIexec_config ( fet );

    fclose ( fet );
  }
  else
  {
    status = DIboot ();
  }

  return ((sep | current | home | back) && 
          (status == DIR_S_SUCCESS)) ? DIR_W_NOT_IMPL : status;
}



char DIread_line ( fet, line )
                   FILE   *fet;
                   DIchar *line;
/* This routine reads a line on the file specified by fet */
{
  DIchar not_eof, *ptr = line;

  do
   not_eof = fread ( line++, 1, 1, fet );
  while (not_eof && (*(line - 1) != '\n'));
  *(line - 1) = '\0';

  return *ptr != '\0';
}



DIexec_config ( fet )
FILE *fet;
/*.DIexec_config */
{
  DIchar     line [2 * DI_PATH_MAX];
  DIchar     sep = 0;
  DIint      status = DIR_S_SUCCESS;
  DIobjid    objid;
  DIspacenum osnum;

  if (fet != NULL)
     while ((status == DIR_S_SUCCESS) && DIread_line ( fet, line ))
     {
       DIclean ( line );

       switch (DIget_choice ( line ))
       {
         case SEP : if (sep)
                      fprintf ( stderr, "IGRdir : sep command misplaced - ignored\n" );
                    else
                    {
                      status = DIboot ();

                      fprintf ( stderr, "IGRdir : sep is NOT yet implemented\n" );
                      sep = 1;
                    }
                    break;
         case DIR : if (!sep)
                    {
                      status = DIboot ();
                      sep = 1;
                    }
                    status = di$mkdir ( dirname = &line[4] );
                    break;
         case HOM : 
                    fprintf ( stderr, "WARNING - hom command not implemented\n" );
                    break;
         case BCK : 
                    fprintf ( stderr, "WARNING - bck command not implemented\n" );
                    break;
         case PWD : if (!sep)
                    {
                      status = DIboot ();
                      sep = 1;
                    }
                    status = di$cd ( dirname = &line [4] );
                    DIstrcpy ( DIR_G_home_name , &line [4] );
                    break;
         case LOD : if (!sep)
                    {
                      status = DIboot ();
                      sep = 1;
                    }
                    if (status == DIR_S_SUCCESS)
                    {
                      DIchar *tmp = strchr ( line, ',' );

                      *tmp = '\0';
                      status = DIload ( &(line [4]), &osnum, &objid, ++tmp );
                    }
                    break;
         case TRL : 
                    DInew_trailer ( line );
                    break;
         case COM : 
                    break;
         default  : fprintf ( stderr, "IGRdir : Unrecognised command\n" );
       }
     }
   else
     fprintf ( stderr,
               "Directory Configuration ERROR\n" );
   if (!sep)
     status = DIboot ();
  return status;
} 


DIload ( file_name, p_osnum, p_objid, logical_name )
         DIchar     *file_name;
         DIspacenum *p_osnum;
         DIobjid    *p_objid;
         DIchar     *logical_name;
/*.DIload */
{
  DIint  om_status;

  om_status = om$construct_os ( classname = "OMFiledOS", osnum     = p_osnum,
                                p_objid   = p_objid, osname    = file_name );
  if ((om_status != OM_S_SUCCESS) && (om_status != OM_I_READ_FROM_FILE))
  {
    fprintf ( stderr, "loading '%s' : ", file_name );
    om$report_error ( sts = om_status );
  }

  return di$mount ( logical = logical_name, osnum = *p_osnum );
}

end implementation DIrectory;
