/* $Id: VDct1Post.h,v 1.1 2001/01/09 22:17:57 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Post.h
 *
 * Description: Posting Controls Collector
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Post.h,v $
 *      Revision 1.1  2001/01/09 22:17:57  art
 *      ah
 *
 * Revision 1.1  2000/04/21  19:05:04  pinnacle
 * Created: vds/include/VDct1Post.h by pnoel for Service Pack
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/29/00  pn      Creation
 *
 ***************************************************************************/
#ifndef   VDatMaster_include
#include "VDatMaster.h"
#endif

#ifndef   VDvla_include
#include "VDvla.h"
#endif

//#ifndef   VDct1Post_include
//#include "VDct1Post.h"
//#endif


// prototypyes from $VDS/vdct1/post/VDct1Post.I
#if 0
/* ------------------------------------------
 * Convert field list to an insert statement
 */
extern IGRstar  VDct1POSTInsertFlds __((TVDatFld *flds, 
					IGRint    cnt, 
					IGRchar  *tableName
					));
#omdef vdct1$POSTInsertFlds(flds, 
			    cnt, 
			    tableName)

VDct1POSTInsertFlds((flds), 
		    (cnt), 
		    (tableName))
#endomdef

/* -----------------------------------------------
 * Posts a given set
 */
extern IGRstar VDct1POSTSet __((TVDatPDMInfo *info, 
				TGRid        *setID,
				TGRid        *postID));
#omdef vdct1$POSTSet(info, 
		     setID
		     postID = NULL)
VDct1POSTSet((info), 
	     (setID),
	     (postID))
#endomdef

/* -----------------------------------------------
 * Deletes all "file_key" entries from a table
 */
extern IGRstar VDct1POSTDeleteFileKey __((IGRchar *tblName, 
					  IGRkey   fileKEY));

#omdef vdct1$POSTDeleteFileKey(tblName, 
			       fileKEY)
VDct1POSTDeleteFileKey((tblName), 
		       (fileKEY))
#endomdef

/* -----------------------------------------------
 * Deletes anything previously posted from this file
 */
extern IGRstar VDct1POSTDeleteAll __((TVDatPDMInfo *info,TGRid *postID));
#omdef vdct1$POSTDeleteAll(info,
			   postID = NULL)
VDct1POSTDeleteAll((info),
		   (postID))
#endomdef
#endif
/* -----------------------------------------------
 * This routine starts up the posting process
 * for the active file
 */
extern IGRstar VDct1POSTAll __((TGRid *postID));
#omdef vdct1$POSTAll(postID       = NULL)
VDct1POSTAll((postID))
#endomdef
