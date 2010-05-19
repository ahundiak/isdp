/* $Id: VDatBasei.I,v 1.2 2001/03/22 20:50:54 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatBasei.I
 *
 * Description: Base Method Implementation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatBasei.I,v $
 *      Revision 1.2  2001/03/22 20:50:54  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "v_dbgmacros.h"

/* -----------------------------------------------
 * Generic get attribute by name
 */
method getAttrByName(IGRchar *name; TVDatFld *fld) 
{
  IGRstat retFlag = 0;
  IGRuint i;
  IGRuint cnt;
  
  if (fld == NULL) goto wrapup;
  memset(fld,0,sizeof(TVDatFld));

  cnt = om$dimension_of(varray = me->flds);

  for(i = 0; i < cnt; i++) {

    //printf("%2d '%s' '%s'\n",i,name,me->flds[i].name);
    
    if (!strcmp(name,me->flds[i].name)) {
      *fld = me->flds[i];
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic get attribute by index
 */
method getAttrByIndex(IGRlong index; TVDatFld *fld) 
{
  IGRstat retFlag = 0;
  IGRuint i;
  IGRuint cnt;

  if (fld == NULL) goto wrapup;
  memset(fld,0,sizeof(TVDatFld));

  cnt = om$dimension_of(varray = me->flds);
  for(i = 0; (i < cnt) && (index != me->flds[i].index); i++);
  if (i == cnt) goto wrapup;

  *fld = me->flds[i];

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic get attributes
 */
method getAttrs(TVDatFld *flds; IGRlong *cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  *cnt = om$dimension_of(varray = me->flds);
  if (flds == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < *cnt; i++) {
    flds[i] = me->flds[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Generic set attributes
 */
method setAttrs(TVDatFld *flds; IGRlong cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  om$vla_set_dimension(varray = me->flds, size = cnt);
  
  if (flds == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < cnt; i++) {
    me->flds[i] = flds[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Update attributes with same name
 * Need to support adding new attributes as well
 */
method updAttrs(TVDatFld *flds; IGRlong updCNT) 
{
  IGRstat   retFlag = 0;
  IGRuint   fldCNT,fldCNTx;
  IGRuint   updI,fldI;
  TVDatFld *fld;

  if (flds == NULL) goto wrapup;

  fldCNT  = om$dimension_of(varray = me->flds);
  fldCNTx = fldCNT;

  for(updI = 0; updI < updCNT; updI++) {

    fld = &flds[updI];

    for(fldI = 0; 
       (fldI < fldCNT) && (strcmp(fld->name,me->flds[fldI].name)); 
        fldI++);

    if (fldI != fldCNT) me->flds[fldI] = *fld;
    else {
      // Append new attribute
      fldCNTx++;
      om$vla_set_dimension(varray = me->flds, size = fldCNTx);
      me->flds[fldI] = *fld;
    }
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Delete all attributes
 * needs to support selective deleting as well
 */
#argsused
method delAttrs(TVDatFld *a_flds; IGRlong a_cnt) 
{
  IGRint l_cnt = 0;

  om$vla_set_dimension(varray = me->flds, size = l_cnt);
  return 1;
}
  
method getType(IGRlong *type)
{
  *type = me->type;
  return 1;
}
method setType(IGRlong type)
{
  me->type = type;
  return 1;
}
method getFlag(IGRlong *flag)
{
  *flag = me->flag;
  return 1;
}
method setFlag(IGRlong flag)
{
  me->flag = flag;
  return 1;
}
method getName(IGRchar *name)
{
  strcpy(name,me->name);
  return 1;
}
method setName(IGRchar *name)
{
  strcpy(me->name,name);
  return 1;
}

method getMisc(IGRchar *misc)
{
  strcpy(misc,me->misc);
  return 1;
}
method setMisc(IGRchar *misc)
{
  strcpy(me->misc,misc);
  return 1;
}

/* ----------------------------------------------
 * Standard isdp interface methods
 */
method ASreturn_go(TGRid *objID; IGRshort *mat_type; IGRdouble *matrix)
{
  IGRstat    retFlag = 0;
  TGRid      meID;
  TGRobj_env objOE;

  // Init
  if (objID) objID->objid = NULL_OBJID;

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
wrapup:
  return retFlag;
}

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

  TVDatFld fld;
  TGRid    myID;
  
  // Avoid unused arg message
  if (directIndex);  // Not used
  if (env);          // Not used

  // Arg Check
  if (rs == NULL)       goto wrapup;
  if (footName == NULL) goto wrapup;

  // Init
  memset(rs,0,sizeof(Tret_struct));

  myID.objid	= my_id ;
  myID.osnum	= OM_Gw_current_OS ;

  // Check for smart attributes
  if (!strncmp(footName,"SA_",3)) {
    retFlag = VDsaGiveStructure(suc,directIndex,footName,rs,env,&myID);
    return retFlag;
  }

  // Break out into class specific processing
  sts = VDatGetStruct(&myID,footName,rs);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Get the attribute
  *fld.name = 0;
  om$send(
    msg = message VDatBase.getAttrByName(footName,&fld),
    targetid = my_id
  );
  if (*fld.name == 0) goto wrapup;

  // Need to convert to rs struct
  switch(fld.type) {

  case VDAT_FLD_TYPE_CHAR: {
    rs->type = text_type;
    VDatFldValidateTxt(fld.valueTxt);
    strcpy(rs->var.text_st.text_string,fld.valueTxt);
    break;
  }

  case VDAT_FLD_TYPE_DOUBLE: {
    rs->type = double_type;
    rs->var.root_pm_st.value = fld.valueDbl;
    break;
  }

  case VDAT_FLD_TYPE_INT: {
    rs->type = double_type;
    rs->var.root_pm_st.value = (IGRdouble)fld.valueInt;
    break;
  }

  } // switch

  retFlag = 1;

wrapup:
  if (suc) *suc = retFlag;
  return retFlag;
}

method NDdelete(TGRmd_env *env)
{
  TGRid   myID;

  if (env);

  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;

  printf("NDdelete Called\n");
  VDbroPrintObj(&myID);

  return OM_S_SUCCESS;
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

  // printf("NDdisconnect for %d\n",my_id);
  
  // Pass it up to NDnodein to tlet it do the work
  sts = om$send(msg      = message NDnodein.NDdisconnect(rootNUM,rootID),
		mode 	 = OM_e_wrt_message,
		targetid = my_id );

  if (!(sts & 1)) {
    printf("Warning: Bad status from NDdisconnect\n");
  }
  
  // Branch off to different handlers for different classes
  switch(me->type) {

  case VDAT_CLASSI_LEAF:
    VDatLeafNDdisconnect(&myID);
    break;

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
  TGRid myID;

  // Make object
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;

  // Branch off to different handlers for different classes
  switch(me->type) {

  case VDAT_CLASSI_LEAF:
    VDatLeafNDcompute_node(&myID);
    break;

  }

#if 0
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

/* -----------------------------------------------
 * Generic get doubles
 */
method getDbls(IGRdouble *items; IGRlong *cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  *cnt = om$dimension_of(varray = me->dbls);
  if (items == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < *cnt; i++) {
    items[i] = me->dbls[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Generic set doubles
 */
method setDbls(IGRdouble *items; IGRlong cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  om$vla_set_dimension(varray = me->dbls, size = cnt);
  
  if (items == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < cnt; i++) {
    me->dbls[i] = items[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic get longs
 */
method getLongs(IGRlong *items; IGRlong *cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  *cnt = om$dimension_of(varray = me->longs);
  if (items == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < *cnt; i++) {
    items[i] = me->longs[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Generic set longs
 */
method setLongs(IGRlong *items; IGRlong cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  om$vla_set_dimension(varray = me->longs, size = cnt);
  
  if (items == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < cnt; i++) {
    me->longs[i] = items[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic get chars
 */
method getChars(IGRchar *items; IGRlong *cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  *cnt = om$dimension_of(varray = me->chars);
  if (items == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < *cnt; i++) {
    items[i] = me->chars[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Generic set char
 */
method setChars(IGRchar *items; IGRlong cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  om$vla_set_dimension(varray = me->chars, size = cnt);
  
  if (items == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  for(i = 0; i < cnt; i++) {
    me->chars[i] = items[i];
  }

  retFlag = 1;

wrapup:
  return retFlag;
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

end implementation VDatBase;
