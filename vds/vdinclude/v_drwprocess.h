/* $Id: v_drwprocess.h,v 1.8 2002/02/14 22:55:24 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/v_drwprocess.h
 *
 * Description:
 *              Macro definition for drawing process.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: v_drwprocess.h,v $
 *      Revision 1.8  2002/02/14 22:55:24  ylong
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/11/14 17:10:06  ylong
 *      CR5779
 *
 *      Revision 1.6  2001/10/26 20:25:07  ylong
 *      CR5658 and CR5643
 *
 *      Revision 1.5  2001/08/29 21:03:54  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/08/14 19:37:46  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/02/22 22:56:52  ylong
 *      Added vd$tbl_get_hdr
 *
 *      Revision 1.1  2001/01/10 16:49:18  art
 *      sp merge
 *
 * Revision 1.10  2000/09/07  21:15:04  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.9  2000/08/29  21:57:06  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.8  2000/08/11  16:17:38  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.7  2000/08/09  19:26:08  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.6  2000/08/07  18:30:50  pinnacle
 * ylong
 *
 * Revision 1.5  2000/08/03  22:11:04  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by rchennup for Service Pack
 *
 * Revision 1.4  2000/08/03  20:12:32  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.3  2000/08/03  00:16:38  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.2  2000/08/02  04:31:34  pinnacle
 * Replaced: vds/vdinclude/v_drwprocess.h for:  by mdong for Service Pack
 *
 * Revision 1.1  2000/08/01  21:55:54  pinnacle
 * Created: vds/vdinclude/v_drwprocess.h by rchennup for Service Pack
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/25/00        Jayadev         Creation 
 *	08/01/00	Ming		Add API routines
 *      01/10/00        ah              sp merge
 ***************************************************************************/

/* The following are the possible changes the model object of a  drawing can 
 * undergo
 */
 
#define 	UNCHANGED 	0
#define 	MODIFY  	1	// new model object
#define		DELETE	  	2	// model object deleted
#define 	MIGRATE		3	// model object consumed
#define		NEW_MODEL	4	// model object changed its properties
#define		CONNECT		5	// model object unconsumed

/* Process cases */
#define DRW_SELECT_BY_STAGE     0
#define DRW_SELECT_BY_OBJECT    1
#define TBL_SELECT_BY_STAGE     2
#define TBL_SELECT_BY_INDEX     3
#define TBL_SELECT_BY_OBJECT	4
#define TBL_SELECT_BY_ITEM	5

/* The following are the different cases of objects that will be handled */

#define		UNDEFINED	0
#define		DRAWING		1
#define		TABLE		2

/* Option flags */

#define	VD_TBL_USR_VAL		0x0001	/*keep user value for row cells */
#define	VD_TBL_APP_NEW		0x0002	/*append newly added objects to table*/
#define	VD_TBL_ITEMNO_OVERW	0x0004	/*overwrite item number*/
#define	VD_TBL_ITEMNO_MANUAL	0x0008	/*overwrite item number*/
#define	VD_TBL_ITEMNO_AUTO	0x0010	/*overwrite item number*/

struct PrcInfo{
        struct GRobj_env model;
        struct GRobj_env modelNew;
        struct GRobj_env drwtbl;      // objid
        struct GRid      pretend;
        struct GRid      VDdrwSet;
        int              application; //(table or drawing)
        int              process;     //(new, delete,migrate, connect, ....)
        char             path[128];   // object path in the tree
        char             pcmk[10];
        char             type[128];   // object type
};

struct RowItemInfo {
	struct	GRid	rowId;
	IGRint		nbObjs;
	IGRint		startIndex;
	IGRint		itemNo;
	IGRshort	flag;
};


/******************************************************************************
 * Reviews the drawing objects and supply the necessary action for 
 * drawing update
 */  
extern  IGRint VDreviewDrawing   __((
        struct PrcInfo *curList,
        int   	       curCnt,
        struct GRobj_env *newList,
        int   	       newCnt,
	struct PrcInfo **outList,
        int            *outCnt));
#omdef vd$review_drawing(       curList,
                                curCnt,
                                newList,
                                newCnt,
                                outList,
                                outCnt)
        VDreviewDrawing(       (curList),
                                (curCnt),
                                (newList),
                                (newCnt),
                                (outList),
                                (outCnt))
#endomdef
/******************************************************************************/

/******************************************************************************
 * Updates the drawing objects w.r.t latest changes in the model
 */

extern  IGRint VDprocessDrawing   __((
	struct GRid    refId,
        struct PrcInfo *procList,
        int   	       procCnt));

#omdef vd$drw_process(          refId,
                                procList,
                                procCnt)
        VDprocessDrawing(       (refId),
                                (procList),
                                (procCnt))
#endomdef

/******************************************************************************/

/*+M
Macro vd$tbl_getObjects

Abstract
        Retrieve all the objects contained in a table.
Arguments
        OUT     long                *msg           Completion code.
        IN      struct GRid         *tblId         table ID
        OUT     int                 *count         No. of total objects.
        OUT     struct PrcInfo      **objectList   total object list.
Note
        The objectList are allocated inside this macro and it is
        the user's resposibility to free the memory by using _FREE().
-M*/

extern IGRlong
VDdrw_getObjectsFromTable       __((    long                  *msg,
                                        struct GRid           *tblId,
                                        int                   *count,
                                        struct PrcInfo        **objectList ));

#omdef vd$tbl_getObjects(               msg,
                                        tblId,
                                        count,
                                        objectList = NULL )
       VDdrw_getObjectsFromTable(       (msg),
                                        (tblId),
                                        (count),
                                        (objectList) )
#endomdef

/*+M
Macro vd$review_table

Abstract
        Detects the changes made to the model objects for the table and
        directs the course of action for the vd$tbl_process macro
Arguments
        OUT     long                   *msg       Completion code.
        IN      struct PrcInfo         *curList   existing object list
        IN      int                    curCnt
        IN      struct GRobj_env       *newList   new object list
        IN      int                    newCnt
        OUT     struct PrcInfo         **outList  old+updated new list
        OUT     int                    *outCnt
Note
        The outList is allocated inside this macro and it is
        the user's resposibility to free the memory by using _FREE()
-M*/

extern IGRlong
VDdrw_reviewTable       __((    long             *msg,
                                struct PrcInfo   *curList,
                                int              curCnt,
                                struct GRobj_env *newList,
                                int              newCnt,
                                struct PrcInfo   **outList,
                                int              *outCnt ));

#omdef vd$review_table(         msg,
                                curList = NULL,
                                curCnt,
                                newList = NULL,
                                newCnt,
                                outList = NULL,
                                outCnt)
        VDdrw_reviewTable(      (msg),
                                (curList),
                                (curCnt),
                                (newList),
                                (newCnt),
                                (outList),
                                (outCnt))
#endomdef

/*+M
Macro vd$tbl_process

Abstract
        Function will add new objects list to the existing table.  And table
        will be recomputed.
Arguments
        OUT     long		*msg		Completion code.
        IN      struct GRid	*tableId	ID of the existing table
        IN      struct GRid	*nodeID		ID of root node
        IN      struct PrcInfo	*newList	new object list
        IN      int		newCnt
	IN	short		usrValOpt	maintain overwritten 
						attributes option
	IN	struct GRid	*xtblId		xml table
-M*/

extern IGRlong VDdrw_processTableObjects __((    
				long		*msg,
				struct GRid	*tblId,
				struct GRid	*nodeIds,
				IGRint		nbNodes,
				struct PrcInfo	*newList,
				int		newCnt,
				long		usrOpt,
				struct GRid	*xtblId ));

#omdef	vd$tbl_process (	msg,
				tblId,
				nodeIds	   = NULL,
				nbNodes	   = 1,
				newList    = NULL,
				newCnt,
				usrOpt  = 0,
				xtblId     = NULL )

	VDdrw_processTableObjects (
				(msg),
				(tblId),
				(nodeIds),
				(nbNodes),
				(newList),
				(newCnt),
				(usrOpt),
				(xtblId) )
#endomdef

/*+M
Macro vd$tbl_getAttributes

Abstract
        Function will retrieves attributes from the existing table header
Arguments
        OUT     long                *msg         Completion code.
        IN      struct GRid         *tableId     ID of the existing table
        IN	struct GRid	    *nodeId	 node id
        IN	IGRchar		    *attrName	 specified attribute's name.
						 optional
        OUT	IGRint		    *attrCnt     No. of attributes
        OUT     struct ACrg_coll    **attrList   attributes list
Note
        The attrList is allocated inside this macro and it is
        the user's resposibility to free the memory by using _FREE()
-M*/

extern IGRlong
VDdrw_getTableHeaderAttr       __((   long             *msg,
                                      struct GRid      *tblId,
				      char	       *attrName,
				      int	       *attrCnt,
                                      struct ACrg_coll **attrList,
				      int	       *nodeCnt,
        			      struct GRid      **nodeIds));

#omdef vd$tbl_getAttributes(    msg,
                                tblId,
				attrName = NULL,
				attrCnt  = NULL,
                                attrList = NULL,
				nodeCnt  = NULL,
				nodeIds	 = NULL)
       VDdrw_getTableHeaderAttr( (msg),
                                 (tblId),
				 (attrName),
                                 (attrCnt),
                                 (attrList),
                                 (nodeCnt),
				 (nodeIds))
#endomdef

/*+M
Macro vd$tbl_setAttributes

Abstract
        Function will add attributes into the table header
Arguments
        OUT     long                *msg         Completion code.
        IN      struct GRid         *tableId     ID of the existing table
        IN	IGRint		    attrCnt      No. of attributes
        IN      struct ACrg_coll    *attrList    attributes list
-M*/

extern IGRlong
VDdrw_setTableHeaderAttr       __((   long             *msg,
                                      struct GRid      *tblId,
				      int	       attrCnt,
                                      struct ACrg_coll *attrList ));

#omdef vd$tbl_setAttributes(    msg,
                                tblId,
				attrCnt,
                                attrList )
       VDdrw_setTableHeaderAttr( (msg),
                                 (tblId),
                                 (attrCnt),
                                 (attrList))
#endomdef

/*+M
Macro vd$tbl_get_hdr

Abstract
        get table header for a given table row
Arguments
        OUT     long                *msg	Completion code.
        IN      struct GRid         *rowID	table row id
        OUT     struct GRid	    *hdrID	table header id
        OUT     struct GRid	    *tblID	table id
-M*/
extern IGRlong  VDtbl_get_hdrtbl ( IGRlong         *msg,
                                   struct  GRid    *rowID,
                                   struct  GRid    *hdrID,
                                   struct  GRid    *tblID);

#omdef  vd$tbl_get_hdrtbl  (    msg,
                                rowID,
                                hdrID = NULL,
				tblID = NULL )

        VDtbl_get_hdrtbl ((msg), (rowID), (hdrID), (tblID));
#endomdef

