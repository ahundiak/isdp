/* $Id: VDlnk.h,v 1.2 2001/01/10 15:47:25 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDcol.h
 *
 * Description: VDcol.S Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDlnk.h,v $
 *      Revision 1.2  2001/01/10 15:47:25  art
 *      sp merge
 *
 * Revision 1.1  2000/12/08  15:31:32  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/07/00  ah      c friendly, added header
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef VDlnk_include
#define VDlnk_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// Pair indexes
#define VDLNK_NTH_PAIR0 0
#define VDLNK_NTH_PAIR1 1
#define VDLNK_NTH_PAIR2 2
#define VDLNK_NTH_PAIR3 3
#define VDLNK_NTH_PAIR4 4
#define VDLNK_NTH_PAIR5 5
#define VDLNK_NTH_PAIR6 6
#define VDLNK_NTH_PAIR7 7

// Channel indexes
#define VDLNK_NTH_TO_RIGHT0  0
#define VDLNK_NTH_TO_LEFT0   1
#define VDLNK_NTH_TO_RIGHT1  2
#define VDLNK_NTH_TO_LEFT1   3
#define VDLNK_NTH_TO_RIGHT2  4
#define VDLNK_NTH_TO_LEFT2   5
#define VDLNK_NTH_TO_RIGHT3  6
#define VDLNK_NTH_TO_LEFT3   7
#define VDLNK_NTH_TO_RIGHT4  8
#define VDLNK_NTH_TO_LEFT4   9
#define VDLNK_NTH_TO_RIGHT5 10
#define VDLNK_NTH_TO_LEFT5  11
#define VDLNK_NTH_TO_RIGHT6 12
#define VDLNK_NTH_TO_LEFT6  13
#define VDLNK_NTH_TO_RIGHT7 14
#define VDLNK_NTH_TO_LEFT7  15

// Channel names
#define VDLNK_NAME_TO_RIGHT0 "VDlnk.to_right0"
#define VDLNK_NAME_TO_LEFT0  "VDlnk.to_left0"
#define VDLNK_NAME_TO_RIGHT1 "VDlnk.to_right1"
#define VDLNK_NAME_TO_LEFT1  "VDlnk.to_left1"
#define VDLNK_NAME_TO_RIGHT2 "VDlnk.to_right2"
#define VDLNK_NAME_TO_LEFT2  "VDlnk.to_left2"
#define VDLNK_NAME_TO_RIGHT3 "VDlnk.to_right3"
#define VDLNK_NAME_TO_LEFT3  "VDlnk.to_left3"
#define VDLNK_NAME_TO_RIGHT4 "VDlnk.to_right4"
#define VDLNK_NAME_TO_LEFT4  "VDlnk.to_left4"
#define VDLNK_NAME_TO_RIGHT5 "VDlnk.to_right5"
#define VDLNK_NAME_TO_LEFT5  "VDlnk.to_left5"
#define VDLNK_NAME_TO_RIGHT6 "VDlnk.to_right6"
#define VDLNK_NAME_TO_LEFT6  "VDlnk.to_left6"
#define VDLNK_NAME_TO_RIGHT7 "VDlnk.to_right7"
#define VDLNK_NAME_TO_LEFT7  "VDlnk.to_left7"

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDlnkGet __((TGRid  *objID,     /* I - Target                       */
			    IGRint  chn,       /* I - Channel Number               */
			    IGRint  nth,       /* I - Which Object on Channel      */
			    IGRint *cnt,       /* O - Number of Obejcts on Channel */
			    TGRid  *outID));   /* O - Requested Object             */

extern IGRstat VDlnkConnect    __((IGRint  pair,      /* I - Channel to connect     */
				   TGRid  *leftID,    /* I - Object to be connected */
				   TGRid  *rightID)); /* I - Obejct to be connected */

extern IGRstat VDlnkDisconnect __((IGRint  pair,    
				   TGRid  *leftID, 
				   TGRid  *rightID));
#ifndef c_ONLY
#omdef vdlnk$Get(it_objID = NULL,
		 ic_NUM ,
		 ic_NTH ,
		 or_CNT = NULL,
		 or_objID  = NULL
)

VDlnkGet((it_objID), (ic_NUM),  (ic_NTH),  (or_CNT), (or_objID))
#endomdef

#omdef vdlnk$Connect(ic_PAIR,
		     il_objID = NULL,
		     ir_objID = NULL
)

VDlnkConnect ((ic_PAIR), (il_objID), (ir_objID))
#endomdef

#omdef vdlnk$Disconnect(ic_PAIR,
			il_objID = NULL,
			ir_objID = NULL
)

VDlnkDisconnect ((ic_PAIR), (il_objID), (ir_objID))

#endomdef

/* Wonder why these are duplicated in VDct.h? */

#omdef vdct$GetMgrParent(objID,       // I - Input Object
			 nth   = 0,   // I - Which Object on Channel
			 cnt   = NULL, // O - Number of Parents
			 outID = NULL // O - Returned Parent
)

VDlnkGet ((objID), (VDCT_CHN_MGR_TO_PARENT), (nth), (cnt), (outID))

#endomdef
  
#omdef vdct$GetMgrChild( objID,       // I - Input Object
			 nth   = 0,   // I - Which Object on Channel
			 cnt   = NULL, // O - Number of Children
			 outID = NULL // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_MGR_TO_CHILD), (nth), (cnt), (outID))

#endomdef

#omdef vdct$GetTree1Parent( objID,       // I - Input Object
			    nth   = 0,   // I - Which Object on Channel
			    cnt   = NULL, // O - Number of Children
			    outID = NULL // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE1_TO_PARENT), (nth), (cnt), (outID))

#endomdef
#omdef vdct$GetTree1Child( objID,       // I - Input Object
			   nth   = 0,   // I - Which Object on Channel
			   cnt   = NULL, // O - Number of Children
			   outID = NULL // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE1_TO_CHILD), (nth), (cnt), (outID))

#endomdef

#omdef vdct$GetTree2Parent( objID,       // I - Input Object
			    nth   = 0,   // I - Which Object on Channel
			    cnt   = NULL, // O - Number of Children
			    outID = NULL // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE2_TO_PARENT), (nth), (cnt), (outID))

#endomdef
#omdef vdct$GetTree2Child( objID,        // I - Input Object
			   nth   = 0,    // I - Which Object on Channel
			   cnt   = NULL, // O - Number of Children
			   outID = NULL  // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE2_TO_CHILD), (nth), (cnt), (outID))

#endomdef

#omdef vdct$ConnectMgrChild( mgrID,    // I - ManagerID
			     childID   // I - ObjectID of Child
)

VDlnkConnect((VDCT_CHN_MGR), (mgrID), (childID))

#endomdef

#omdef vdct$DisConnectMgrChild( mgrID,    // I - ManagerID
				childID   // I - ObjectID of Child
)

VDlnkDisconnect((VDCT_CHN_MGR), (mgrID), (childID))

#endomdef

#omdef vdct$ConnectTree1Child( treeID,  // I - TreeID
			       childID  // I - ObjectID of Child
)

VDlnkConnect((VDCT_CHN_TREE1), (treeID), (childID))

#endomdef

#omdef vdct$DisConnectTree1Child( treeID,  // I - TreeID
				  childID  // I - ObjectID of Child
)

VDlnkDisconnect((VDCT_CHN_TREE1), (treeID), (childID))

#endomdef

#omdef vdct$ConnectTree2Child( treeID,  // I - TreeID
			       childID  // I - ObjectID of Child
)

VDlnkConnect((VDCT_CHN_TREE2), (treeID), (childID))

#endomdef

#omdef vdct$DisConnectTree2Child( treeID,  // I - TreeID
				  childID  // I - ObjectID of Child
)

VDlnkDisconnect((VDCT_CHN_TREE2), (treeID), (childID))
#endomdef
#endif


#if defined(__cplusplus)
}
#endif

#endif
















