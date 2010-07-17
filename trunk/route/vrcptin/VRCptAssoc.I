/* $Id: VRCptAssoc.I,v 1.2 2001/02/20 01:13:32 build Exp $  */
 
/***************************************************************************
 * I/ROUTE
 *
 * File:        vrcptin/VRCptAssoc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRCptAssoc.I,v $
 *      Revision 1.2  2001/02/20 01:13:32  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:50  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/31  11:14:56  pinnacle
# Replaced: vrcptin/VRCptAssoc.I for:  by apazhani for route
#
# Revision 1.3  1998/03/29  10:37:06  pinnacle
# Replaced: vrcptin/VRCptAssoc.I for:  by apazhani for route
#
# Revision 1.2  1998/03/29  10:32:52  pinnacle
# Replaced: vrcptin/VRCptAssoc.I for:  by apazhani for route
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      name            description
 *
 *	03/29/98	Alwin		Modified the NDmove_to_root method
 *					place dangle when the Components in the
 *					reference file.
 *
 ***************************************************************************/

/***********************************************************************
     CLASS  NAME: 	VRCptIn

     METHOD NAMES: 	VRGetDefName
			VRSetInstance
			ACconstruct_feet
			ASreturn_go

     Abstract: This file contains the method for placement and computation.
		

     CHANGE HISTORY:

	* 09-DEC-91	1.4.3.14	
		Bruno
		- Creation.

***********************************************************************/

class implementation VRCptIn;

#include "nddef.h"
#include "ndmacros.h"
#include "VRprivmacros.h"
#include "VRcordef.h"
#include "VRmacros.h"
#include "VRsketchdef.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"

from  VRProduct       import  VRGetProduct;
from  VRCnrlSeg       import  VRget_terminators;

#define AS_DEBUG	1

/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{
	*msg = MSSUCC;

	strcpy ( sMacroName, "VRCptIn" );

	return ( OM_S_SUCCESS );

}/* end VRGetDefName */

/**************************************************************************/

method VRSetInstance	(IGRlong *msg; struct VRGenInfo *Instance)

{
	*msg = MSSUCC;

	me->Status = 0;

	/* -- set Cpt number -- */
	me->nCpNum = Instance->nJustif;

	/* -- set Index -- */
	me->nIndex = Instance->Attr.Comp.nIndex[0];

return ( OM_S_SUCCESS );

}/* end VRSetInstance */

/**************************************************************************/

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *fcount; struct GRid  *feet_list)
{
	*msg = MSSUCC;

	/* -- No graphic is built -- */
	*fcount	=0;

	return OM_S_SUCCESS ;

}/* end ACconstruct_feet */

/**************************************************************************/

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{

	/* -- Send message back to the pretendin I am attached to (template 0) -- */
	OM_S_CHANSELECT chansel;
	IGRint		status;

	chansel.type       = OM_e_name;
	chansel.u_sel.name = "father";

	status= om$send ( 
		msg = message ASnode.ASreturn_go( go, mat_type, matrix),
		p_chanselect= &chansel,
		from	    = 0,
		to	    = 0);
	
	return ( status );

}/* end ACconstruct_feet */

/**************************************************************************/

method ACget_NV_rep(unsigned char *rep)
{
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/* -- Get real component id -- */

	status= om$send (
		msg = message ASnode.ASreturn_go
			( &CompId, &NewEnv.md_env.matrix_type, NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- Send message back to real component -- */

	status=
	om$send ( msg = message VRGeneric.ACget_NV_rep ( rep ),
	targetid = CompId.objid,
	targetos = CompId.osnum);

return (status);

}/* end ACget_NV_rep */

/**************************************************************************/

method VRGetStatus (IGRlong *msg; IGRshort *StatusValue)

{
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/* -- Get real component id -- */

	status= om$send (
		msg = message ASnode.ASreturn_go
			( &CompId, &NewEnv.md_env.matrix_type, NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- Send message back to real component -- */

	status=
	om$send ( msg = message VRGeneric.VRGetStatus ( msg, StatusValue ),
	targetid = CompId.objid,
	targetos = CompId.osnum);

return (status);

}/* end VRGetStatus */

/**************************************************************************/

method GRgetsymb(IGRlong *msg; struct GRsymbology *symb)

{
	IGRint			status;
	struct GRid		CompId;
	struct GRmd_env		NewEnv;

	/* -- Get real component id -- */

	status= om$send (
		msg = message ASnode.ASreturn_go
			( &CompId, &NewEnv.md_env.matrix_type, NewEnv.md_env.matrix),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/* -- Send message back to real component -- */

	status=
	om$send ( msg = message VRGeneric.GRgetsymb ( msg, symb ),
	targetid = CompId.objid,
	targetos = CompId.osnum);

return (status);

}/* end GRgetsymb */

/**************************************************************************/
/*
 * The control will come here, when the Object in a Reference file is deleted.
 * Once the object in the refenrence file is deleted this Object gets message
 * to Delete itself. Before doing so, it's this Component's duty to place  a
 * 'dangle' and die peacefully. Previously this was not done and it has been
 * found and implemented. Alwin fixed along with TR179800791
 *
 ****************************************************************************/

method NDmove_to_root ( IGRlong *msg; struct GRid *src_grid;
                        struct GRmd_env *md_env )

{
    IGRint              cn_type, i, wait_index;
    IGRlong             retmsg, status=OM_S_SUCCESS;
    struct GRid 	MyId;
    IGRint 		NbRoots=0;
    struct GRid 	*buffer, CnrlSegId;
    extern		NDis_waiting();

    SetProc( Md NDmove_to_root of VRCptIn ); Begin
 
    *msg = MSSUCC;
    src_grid->objid = NULL_OBJID;
 
    MyId.objid = my_id;
    MyId.osnum = OM_Gw_current_OS;
 
    status =
    om$send( msg = message NDnode.NDget_objects
                                    (ND_ROOT | ND_IN_BUF, NULL, 0,
                                     &buffer, 0, OM_K_MAXINT, &NbRoots ),
                  targetid = my_id);
    as$status( action = RET_STATUS );
    __DBGpr_int( " Nb of Parents ", NbRoots );
 
    for( i=0; i<NbRoots; i++ )
    {
        GRclassid obj_classid;
        extern GRclassid OPP_VRCnrlSeg_class_id;
 
        __DBGpr_obj( " Parent Id ", buffer[i] );
 
        om$get_classid( objid     = buffer[i].objid,
                        osnum     = buffer[i].osnum,
                        p_classid = &obj_classid );
 
        if( om$is_ancestry_valid( subclassid   = obj_classid,
                                 superclassid = OPP_VRCnrlSeg_class_id )
                                              == OM_S_SUCCESS )
        {
           __DBGpr_com( " Found the Line Segment " );
           CnrlSegId = buffer[i];
           break;
        }
    }

    wait_index = -1;
    NDis_waiting( GR_DELETED, 0, &CnrlSegId, &wait_index, NULL, NULL, 1 );
    __DBGpr_int( " Waiting Index ", wait_index );
 
    if( wait_index >= 0 )
    {
        cn_type    = ND_COMP;
        nd$wait_batch(  type       = GR_DELETED,
                        l_object   = &MyId,
                        l_obj_info = &cn_type,
                        nb_obj     = 1 );
        End
        return OM_S_SUCCESS;
    }

    if( CnrlSegId.objid != NULL_OBJID )
    {
        IGRint nb_cmp=0;
        IGRint cmp_index[3];
        IGRshort Product;
        IGRdouble CmpPts[6];
        struct GRid CmpId[2];
 
        /* Get the end components connected to Line Segment */
        status =
        om$send ( msg = message VRCnrlSeg.VRget_terminators(
                                      &retmsg, &nb_cmp, md_env,
                                      CmpPts, CmpId ),
                      targetid = CnrlSegId.objid,
                      targetos = CnrlSegId.osnum );
        as$status( action = RET_STATUS );
 
        for( i=0; i<nb_cmp; i++ )
        {
          __DBGpr_obj( " Component Id ", CmpId[i] );
 
          if( ( CmpId[i].objid != MyId.objid ) &&
              ( CmpId[i].objid != MyId.osnum ) )
          {
             /* This is the component I'm interested in. So that I can
             grab the "System & User" Collection from this guy and use
             the same for "Dangle" which I'm going to place for VRCptIn */
 
             IGRdouble dAngle=0.0;
             struct GRid SysParamId, UserParamId;
             struct GRsymbology mySymb;
             struct GRvg_construct  cmp_const_list;
 
             status =
             om$send ( msg = message VRGeneric.VRGetParams( &retmsg,
                                  &SysParamId, &UserParamId, NULL ),
                            targetid = CmpId[i].objid,
                            targetos = CmpId[i].osnum );
             as$status( action = RET_STATUS );
             __DBGpr_obj( " System Params Id ", SysParamId );
             __DBGpr_obj( " User Params Id ", UserParamId );
 
             /* To call the macro "VR$PlaceCmpByItemName" we need to set
             the ConstructionList argument correctly. */
 
             /* Get the Symbology from Component */
             __DBGpr_com( " Getting the Symbology from component " );
             status =
             om$send(  msg  = message GRvg.GRgetsymb( &retmsg, &mySymb ),
                             targetid = CmpId[i].objid,
                             targetos = CmpId[i].osnum );
             as$status( action = RET_STATUS );
 
             /*| update component construction list */
             VRGetConstructionList( &retmsg, md_env, NULL, &mySymb,
                                    NULL, NULL, &cmp_const_list );
 
             /* Get the product */
             status =
             om$send ( msg = message VRProduct.VRGetProduct(
                                                &Product, NULL ),
                             targetid = CmpId[i].objid,
                             targetos = CmpId[i].osnum );
             as$status( action = RET_STATUS );
 
             cmp_index[0] = ( i == 1 ) ? 0 : 1;
             __DBGpr_int( " Component Index on Segment ", cmp_index[0] );
 
             /* I've obtained all the information from the VRCptIn object to
             place a dangle at the same location. Now I can delete this VRCptIn
             and place the Dangle at the same location */
             status =
             om$send ( msg = message VRGeneric.NDdelete( md_env ),
                             targetid = my_id );
             as$status( action = RET_STATUS );

             __DBGpr_com( " Calling VR$PlaceCmpByItemName " );
             status = VR$PlaceCmpByItemName (
                      p_retmsg                = &retmsg,
                      PlacementTime           = VR_NEW_COMP,
                      p_CmpAngle              = &dAngle,
                      Product                 = Product,
                      TopoParentsNum          = 1,
                      p_TopoParentsList       = &CnrlSegId,
                      p_CmpIndexOnTopo        = cmp_index,
//                          p_CmpOrientSection      = p_orient_section,
                      p_MdEnv                 = md_env,
                      p_ActParamId            = &SysParamId,
                      p_UserParamId           = &UserParamId,
                      p_CmpCstList            = &cmp_const_list
                               );
              /* Place the correction between the two Components */
              status = VR$ComputeCorrection(  p_retmsg          = &retmsg,
                                              p_SegmentId       = &CnrlSegId,
                                              p_MdEnv           = md_env );
              as$status( action = RET_STATUS );
          }
        } // End loop on Nb of Components
    } // End loop on CnrlSegId
 
End
return ( OM_S_SUCCESS );

}/* end NDmove_to_root */

/***********************************************************************/

end implementation VRCptIn;
