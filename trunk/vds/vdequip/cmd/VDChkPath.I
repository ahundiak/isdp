/* $Id: */
/* -------------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdequip/cmd / VDChkPath.I
 *
 * Description:
 *
 *	Checks if the macro library is mounted
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDChkPath.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/21  14:44:30  pinnacle
# Created: vdequip/cmd/VDChkPath.I by kddinov for vds.240
#
 *
 * History:
 *
 *      05/10/96	KDD	Creation date
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#       include "OMminimum.h"
#       include "OMmacros.h"
#       include "OMlimits.h"
#       include "OMprimindex.h"
#       include "OMprimitives.h"
#       include "OMerrordef.h"
#       include "igrtypedef.h"
#       include "igetypedef.h"
#       include "godef.h"
#       include "codef.h"
#       include "ex.h"
#       include "exdef.h"
#       include "grerr.h"
#       include "gr.h"
#       include "igr.h"
#       include "igrdp.h"
#       include "grdpbdef.h"
#       include "grdpb.h"
#       include "go.h"
#       include "griodef.h"
#       include "grio.h"
#       include "dp.h"
#       include "lcdef.h"
#       include "lc.h"
#       include "griomacros.h"
#include "exmacros.h"

#include <string.h>

#include "parametric.h"
#include "expression.h"
#include "expmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "asbox.h"
#include "AS_status.h"
#include "acdef.h"
#include "acmacros.h"
#define AS_DEBUG


#ifdef  ASSOC_ORIGINAL

%safe
/******   INFORMATION ABOUT WOKING DIRECTORY FOR MACRO  *****/


char ACwd[DI_PATH_MAX];          /* name of the file                  */

struct GRid AC_construct_id = {0,(OM_S_OBJID)-1};        /* grid of the working
directory*/

/******   INFORMATION ABOUT PATH DIRECTORY FOR MACRO  *****/

struct GRid *ACpath_grid = NULL;   /* list of grid for path directory       */
int  *ACpath_in_open = NULL;       /* corresponding index in open list      */
int  ACpath_gr_number = 0;         /* number of directory in the path       */
int  ACpath_gr_total = 0;          /* allocated size of ACpath_grid         */

/******   INFORMATION ABOUT OPEN LIB FOR MACRO  *****/

int ACopen_number = 0;             /* number of open OS for macro lib       */
int ACopen_size = 0;               /* size of ACopen_struct                 */

struct ACopen_struct
   {
    int osnum;                     /* open osnum                            */
    int name;                      /* index of name in name_array           */
   };

struct ACopen_struct
           *ACopen_info = NULL;    /* allocated place for info              */

int ACopen_name_used = 0;          /* size used to store open file name     */
int ACopen_name_size = 0;          /* size allocated to store open file name*/

char *ACopen_name_array = NULL;     /* allocated space for name             */



/*******   DEFAULT NAME AND SEPARATOR *********/

char *ACdefault_constructs = "constructs";
char *ACdefault_constructs_lib = "constructs_lib";

%endsafe

#endif

#define SEPAR_PATH ','
#define SEPAR_DIR  ':'


struct ACopen_struct
   {
    int osnum;                     /* open osnum                            */
    int name;                      /* index of name in name_array           */
   };

extern struct ACopen_struct
           *ACopen_info;    /* allocated place for info             */

extern char ACwd[DI_PATH_MAX];     /* name of the file                */
extern struct GRid AC_construct_id; /* grid of the working directory*/
extern struct GRid *ACpath_grid;   /* list of grid for path directory       */
extern int  *ACpath_in_open;       /* corresponding index in open list      */
extern int   ACpath_gr_number;     /* number of directory in the path       */
extern int   ACpath_gr_total;      /* allocated size of ACpath_grid         */
extern int   ACopen_number;        /* number of open OS for macro lib       */
extern int   ACopen_size;          /* size of ACopen_struct                 */
extern int   ACopen_name_used;     /* size used to store open file name     */
extern int   ACopen_name_size;     /* size allocated to store open file name*/
extern char *ACopen_name_array;    /* allocated space for name              */
extern char *ACdefault_constructs;
extern char *ACdefault_constructs_lib;


/*************************************************************************
*
*  VDCheck_Lib_Path function checks if the macro library is mounted
*
*               The code is taken from ACactivate ($VDS/vdassoc/dir_macto.I)
*------------------------------------------------------------------------
*
*       PARAMETERS
*
* (I)   file_name       = library name
*------------------------------------------------------------------------
*
* (O)   RETURN CODE
*
*  1    = OK   (the macro library is mounted)
*  0    = Fail (the macro library can not be reached)
*------------------------------------------------------------------------
*
*       05/96   KDD
*
**************************************************************************/
int VDCheck_Lib_Path ( char *file_name)
{

        int     return_code ;

        IGRchar full_file_name[DI_PATH_MAX],full_dir_name[DI_PATH_MAX];
        IGRlong rc,status;
        struct GRid lib;
        GRspacenum cur_os;
        OM_S_OBJID cur_id;

return_code       = 1;
full_file_name[0] = '\0';

ASsuper_construct();

status = ex$get_cur_mod( id = &cur_id, osnum = &cur_os);

rc = di$give_pathname(osnum = cur_os,
                      pathname = full_dir_name);

   strcat(full_dir_name,":");
   strcat(full_dir_name,ACdefault_constructs_lib);

   status = ACtran_or_make(cur_os,full_dir_name,&lib);
   if(status != DIR_S_SUCCESS) {
        printf("mkdir of %s failed\n",full_dir_name);
        return_code = 0;
        goto wrapup;
   }

/*******
*       Check the existance of the macro library
*******/
   ACpath_to_file(file_name,full_file_name);

   if(access(full_file_name,00) != 0) return_code = 0;

wrapup:

   return (return_code);
}

end implementation Root;

