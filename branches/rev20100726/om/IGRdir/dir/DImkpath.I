/*
  ABSTRACT :
  --------

   This file constains the make path facility.

  HISTORY :
  -------

   04/11/1988 : SRH - Created
   05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX
*/

class implementation DIrectory;

#define DEBUG

#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DIomac.h"
#include "DIprims.h"


/*
    Abstract

       This routine adds an entry in a directory and creates any directories
       in the entry's path spec that do not already exist.  


    Synopsis

       DIint  DImkpath( objid,
                      pathname,
                      p_osnum )


    Arguments

       GRobjid   objid

          object id of newly created entry in directory 


       char *pathname;

          the full path name of the new entry to by added:  for example,
          :usr1:lines:line1  


       OMuword  *p_osnum
       
          the object space number of the directory where the
          entry was made


    Returns

       DIint

          DIR_S_SUCCESS  : successful (directories and entry created)
          DIR_E_NAME_DUP : entry name duplicated ( cannot overwrite entry )
          DIR_E_SYNTAX   : syntax error ( badly formatted path )
          DIR_E_ABORT    : general failure

    History

       04/11/88  srh  -  created
       08/31/88  srh  -  if pathname has terminal dir separator, then
			 di$add_name is not called and the directories
			 are made the last of which is empty.

    Caveats

       If the code  fails while creating directories in the full pathname
       or when adding the name to last directory, then any directories 
       created by the command will remain!  Code to cleanup the directories
       will be added at a later date.  In the meantime, be very carefull
       about the use of this routine.  (srh)

 */


DImkpath( objid, pathname, p_osnum )
          DIobjid    objid					/* IN  */;
          DIchar     *pathname					/* IN  */;
          DIspacenum *p_osnum					/* OUT */; 
/*.DImkpath */
{
    DIint
       MemoryAllocated = FALSE,
       Count,
       NbrItemsInList, 
       RetCode = DIR_S_SUCCESS;

    DIchar
      **DirPartsList,
       ObjectName[DI_PATH_MAX],
       DirName[DI_PATH_MAX],
       SubDirName[DI_PATH_MAX];

    DIboolean
       is_a_name; /* FALSE if pathname specifies a directory; TRUE otherwise */


    /*
     * Step 0:  validate arguments
     */
    is_a_name = ( pathname [ ( strlen( pathname ) - 1 ) ] != DIR_G_car_dir );

    if ( !is_a_name && ( objid != NULL_OBJID ) )
    {
      RetCode = DIR_E_INVARG;
      goto quit;
    }


    /*
     * -------------------------------------------------------------------
     *   Step 1:  Break directory path into it's constituent parts: 
     *            the Directory List and the Object Name.
     * -------------------------------------------------------------------
     */
    di$split( pathname = pathname,
              dirname  = DirName,        /* always succeeds  */
              name     = ObjectName );

    if ( DirName[0] == '\0') 
    {
       RetCode = DIR_E_SYNTAX;
       goto quit;
    }

    /*
     * DIparse_dir() only considers directories - terminal name ignored 
     */
    RetCode = DIparse_dir( pathname, &DirPartsList, &NbrItemsInList );
    MemoryAllocated = TRUE;

    /* if syntax error in pathname, abort */
    if ( !( RetCode & 1 ) ) goto quit; 


    /*
     * -------------------------------------------------------------------
     *   Step 2:  Make each directory named in the full path name 
     * -------------------------------------------------------------------
     */
    strcpy( SubDirName, DIR_G_str_dir);
    /*"count : %d\n", Count */
    for ( Count = 0; Count < NbrItemsInList; Count++ )
    {
       /* build directory path from root, creating directories as needed */
       strcat( SubDirName, DirPartsList[Count] );

       /*
        *  we don't care about the objid or object space number of the
        *  new directory
        */
       /*"making '%s'\n", SubDirName */
       RetCode = di$mkdir ( dirname = SubDirName );

       /*
        * If the directory already exists, we ignore the error code 
        * DIR_E_DIR_DUP ( dupplicate directory ) and procede; if some
        * other error occurs in mkdir, abort 
        */
       if ( ( !( RetCode & 1 ) && ( RetCode != DIR_E_DIR_DUP ) ) )
       {
          goto quit;
       }

       strcat( SubDirName, DIR_G_str_dir );

    }

    /*
     * -------------------------------------------------------------------
     *   Step 3:  Add the entry ( last item in DirPartsList ) to the
     *            last directory made
     * -------------------------------------------------------------------
     */
    /*"add : '%s'\n", pathname */
    if ( is_a_name )
    {
       RetCode = di$add_name( objname = pathname, 
			      objid   = objid,
			      p_osnum = p_osnum );
    }

/*
    if ( RetCode == DIR_E_NAME_DUP )
    {
        *  ( TBD )
        *  We want to backtrack through the pathname and remove all of the
        *  directories that we created 
        *
    }
*/


quit:
    /*
     * -------------------------------------------------------------------
     *   Step 4:  Free the memory used to build the direcotry parts 
     *            list on exit
     * -------------------------------------------------------------------
     */
    if ( MemoryAllocated )  di$free ( lines = DirPartsList,
                                      count = NbrItemsInList );

    return RetCode;

}

end implementation DIrectory;
