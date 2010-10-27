/* $Id: vdxmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/****************************************************************************
 * I/VDS
 *
 * File:	$VDS/include/vdxmacros.h
 *
 * Description: Misc macro definitions. 
 *
 * Dependencies:
 *
 * Reference
 *	$Log: vdxmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  14:08:00  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ****************************************************************************/

#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "OMparameters.h"

/*************************************************************************
*
* Macro definition: vdx$objectID_list ()
*
* This macro provides the interface to the VDXobjectID_list function.
* The function VDXobjectID_list returns the list of IDs for the components
* of the input object.
*
*---------------------------------------------------------------------
*
*       PARAMETERS
*
* (I)   osnum           = active object space number
*
* (I)   *directory      = pathname to the active object space.
*
* (I)   objid           = object ID in the object space osnum.
*                         Valid ONLY IF sub_dir = NULL.
*
* (I)   *sub_dir        = name of the subdirectory to extract objects from.
*
* (I/O) *list      VDS!    = pointer to the list of object IDs.
*                         Caller must secure the storage space (array, malloc).
*
* (O)   *count     !    = number of objects in the output list.
*
*---------------------------------------------------------------------
*
*               RETURN STATUS
*
* (long)   1    = Always.
*---------------------------------------------------------------------
*
*               EXAMPLE
*
*   Here [2,226] == ":xxxx:models_lib"
*   Note: the extra word ":IGENOD" provides the correct osnum.
*   Note: The caller allocates and frees memory for the pointer list.
*
*        char            *xxxx          = ":xxxx";
*        char            *models_lib    = ":models_lib";
*        GRspacenum      osnum          = 2;
*        IGRint          i              = 226;
*        GRobjid         *list          = NULL;
*        int             count;
*
*        list = (GRobjid *) malloc (maxObj * sizeof (GRobjid ));
*        if (list) free(list);
*
*        status = vdx$objectID_list(   osnum   = osnum,
*                                     sub_dir = models_lib,
*                                     list    = list,
*                                     count   = &count);
*
*        status = vdx$objectID_list(   osnum   = osnum,
*                                     objid   = (GRobjid) i,
*                                     list    = list,
*                                     count   = &count);
*
*        xxxx = ":xxxx:IGENOD";
*        status = vdx$objectID_list( directory = xxxx,
*                                     sub_dir = models_lib,
*                                     list    = list,
*                                     count   = &count);
*
*        xxxx = ":xxxx:usr";
*        status = vdx$objectID_list( directory = xxxx,
*                                     objid   = (GRobjid) i,
*                                     list    = list,
*                                     count   = &count);
*
********************************************************************/
#omdef  vdx$objectID_list( osnum        = (GRspacenum) 0 ,
                           directory    = NULL,
                           objid        = (GRobjid)    0 ,
                           sub_dir      = NULL,
                           list         = NULL,
                           count        = NULL)

    VDXobjectID_list(     (osnum), (directory), (objid), (sub_dir),
                               (list), (count))
#endomdef

