/* $Id: VDbtBase1.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/imp/VDbtBase1.I
 *
 * Description: Base Method Implementation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtBase1.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/07  14:33:40  pinnacle
# ah
#
# Revision 1.2  1998/04/02  21:22:22  pinnacle
# ah
#
# Revision 1.1  1998/03/29  14:13:54  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/27/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDbt.h"

/* ----------------------------------------------
 * Standard isdp interface methods
 */
#argsused
method ASreturn_go(TGRid *objID; IGRshort *mat_type; IGRdouble *matrix)
{
  IGRstat    retFlag = 0;
//  TGRid      meID;
//  TGRobj_env objOE;

  // Init
  if (objID) objID->objid = NULL_OBJID;
  if (1) goto wrapup;

#if 0

  // Only defined for leafs
  if (me->type != VDAT_CLASSI_LEAF) goto wrapup;

  // Kind of loopy but it works
  meID.objid = my_id;
  meID.osnum = OM_Gw_current_OS;  // Work if leaf in ref file?
  VDatGetLeafObject(&meID, &objOE);
  if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Xfer
  if (objID)    *objID      = objOE.obj_id;
  if (mat_type) *mat_type   = objOE.mod_env.md_env.matrix_type;
  if (matrix)   memcpy(matrix,objOE.mod_env.md_env.matrix,sizeof(IGRmatrix));
 
  retFlag = 1;
#endif

wrapup:
  return retFlag;
}

#argsused
method ACgive_structure(
  IGRint      *suc;
  IGRint      *directIndex;
  IGRchar     *footName;
  Tret_struct *rs;
  TGRmd_env   *env;
)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;
  TVDfld   fld;

  TGRid    objID;

  // Arg Check
  if (rs == NULL)       goto wrapup;
  if (footName == NULL) goto wrapup;

  objID.objid = my_id;
  objID.osnum = OM_Gw_current_OS;

  // Init
  memset(rs,0,sizeof(Tret_struct));

  // Branch for different types of objects
  switch(me->fldx[0].type) {

  case VDBT_TYPE_SET_TYPE:

    sts = VDbtGetStructSetType(&objID,env,footName,rs);

    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
    break;

  }

  // Get the attribute
  memset(&fld,0,sizeof(fld));
  om$send(
    msg = message VDbtBase.getAttrBy(1,-1,footName,&fld),
    targetid = my_id
  );
  if (*fld.name == 0) goto wrapup;

  retFlag = vdrs$ToRS(fld = &fld, rs = rs);

wrapup:
  if (suc) *suc = retFlag;
  return retFlag;
}

/* --------------------------------------------------------
 * Standard way to delete
 */
method NDdelete(TGRmd_env *env)
{
  IGRstat sts;

  sts = om$send(msg      = message NDnodein.NDdelete(env),
		mode 	 = OM_e_wrt_message,
		targetid = my_id );

  return sts;
}

/* ---------------------------------------------------
 * This gets called for leafs when the model object
 * has been deleted
 * I think (based on NDnodein code) that this only
 * applys to the father channel.
 *
 * Just have the node delete itself if its model
 * object disconnects.
 *
 * May want to move this down to the VDatLeaf class or
 * put in a check and verify it is a leaf before deleting
 */
method NDdisconnect(int rootNUM; TGRid *rootID)
{
  
  TGRid   myID;
  int sts;
  
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;

  // Pass it up to NDnodein to let it do the work
  sts = om$send(msg      = message NDnodein.NDdisconnect(rootNUM,rootID),
		mode 	 = OM_e_wrt_message,
		targetid = my_id );

  if (!(sts & 1)) {
    printf("Warning: Bad status from NDdisconnect\n");
  }
#if 0
  // Now delete Myself
  if (me->type == VDAT_CLASSI_LEAF) {
    
    VDatDeleteBase(&myID);
  }
  
  else {
    
    int i;
    
    printf("============================================\n");
    printf("NDdisconnect Called %d\n",rootNUM);
    VDbroPrintObj(&myID);

    for(i = 0; i < rootNUM; i++) {
      VDbroPrintObj(&rootID[i]);
    }
  }
#endif

  return OM_S_SUCCESS;
}

/* ------------------------------------------------
 * The leafs method gets called when a plate
 * recomputes.  However, even if the leaf ignores it
 * All leaf parents also get this message
 *
 * So basically that is actually pretty good since after
 * The leaf extracts info from the plates, we know
 * That each of its parents will also ge the message
 *
 * This sort of implies that all node classes capable of
 * reomputing should override this but 
 * wont get into that for now
 */
method NDcompute_node (
		       IGRlong *msg;
		       IGRint cn_type;
		       IGRint count;
		       struct GRid list [];
		       struct GRmd_env *md_env;
		       )
{

#if 0  
  TGRid   myID;
  int sts;
  
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;
  
{
  int i;
    
  printf("============================================\n");
  printf("NDcompute_node Called %d %d\n",cn_type,count);
  VDbroPrintObj(&myID);

  for(i = 0; i < count; i++) {
    VDbroPrintObj(&list[i]);
  }
}
#endif

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* -------------------------------------------------------------
 * This was basically copied from the ASsource object
 * It gets called by any objects on the listener channel
 * and then redirects the message accordingly
 *
 * For the most part, any thing that changes the object being
 * listened to will cause this object to disconnect and delete itself
 * The next time the piece needs rdb info, it will be fetched again
 */ 
extern IGRboolean ASbroadcast_in_progress;

#arsgused
method GRnotifylis( 
		   IGRlong *msg;               // Not used
		   IGRlong *OMmsg;             // Not used
		   IGRlong *mask;              // Indicates type of operation
		   OM_S_MESSAGE *graphics_msg  // Not used
		   )
{
  TGRid myID;
  IGRlong op = *mask;
  
  //printf("Entered GRnotifylis %08x ",op);
  
  if(ASbroadcast_in_progress) {
    //printf("Broadcast\n");
    return(OM_S_SUCCESS);
  }
  if (1) return OM_S_SUCCESS;
  
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;

  // ASsuper_construct(); need to find out what this does sometime

  switch(op)
  {
  case GR_GEOM_XFORMED :
   /*| source xform */
     om$send( msg = message NDnode.NDchange_node(NULL),
    	      targetid = my_id );
     //printf("Listener.GeomXformed\n");

     break;

  case GR_GEOM_MODIFIED :
   /*| source modify */
      om$send( msg = message NDnode.NDchange_node(NULL),
    	       targetid = my_id );
      printf("Listener.GeomModified\n");
      break;

  case GR_GEOM_POSTED :
   /*| source postabsg */
   om$send( msg = message NDnode.NDchange_node(NULL),
    	    targetid = my_id );

   //printf("Listener.GeomPosted\n");
   break;

  case  GR_DELETED :
    //printf("Listener.Deleted\n");
    
    break;


 
 case GR_ATTR_MODIFIED :
   //printf("Listener.AttrModified\n");
   break;

  default:
    //printf("Listener.Other\n");
   break;

  } /* end of switch */

  
 return( OM_S_SUCCESS );
}

end implementation VDbtBase;
