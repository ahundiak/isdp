/* $Id: VDdir.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatDir.h
 *
 * Description: Files for using directory system
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdir.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/10/11  13:48:26  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/11/98  ah      Creation
 ***************************************************************************/

#ifndef VDdir_include
#define VDdir_include

#ifndef   didef
#include "DIdef.h"
#endif

#ifndef   DItypedef_include
#include "DItypedef.h"
#endif

#ifndef   diglob
#include "DIglob.h"
#endif

#ifndef   DIprims
#include "DIprims.h"
#endif

/* ----------------------------------
 * PPL's don't like this include file
 * strcat is the only one used anyways
 * So just copied the defination
 */
#ifndef   DImacros
#omdef di$strcat( to, from )
       DIstrcat ( to, from )
#endomdef
#endif

#endif

