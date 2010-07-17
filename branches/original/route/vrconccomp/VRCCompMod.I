/*
     CLASS  NAME: VRConcComp
     METHOD NAMES: 	VRConnect

     Abstract: 
		
     CHANGE HISTORY:
 *      03/08/01   law          dbg prints

***********************************************************************/

class implementation VRConcComp;

#define AS_DEBUG	1
#include "vrdbgmacros.h"


/***********************************************************************/

method VRConnect(IGRlong 		*msg;
		  struct GRid		*SegId;
		  IGRshort		nIndex;
		  IGRshort		nCptNum;
		  struct GRmd_env	*md_env  )
{
	IGRlong         retmsg;
	IGRint		status;
	OM_p_CHANSELECT	ToFather,ToChildren;
	struct GRid	MyId;

*msg 	= MSFAIL;
status 	= OM_E_ABORT;

if ( me->nNbTopo < me->nNbCpts )
{
	/* ------------------------------- */
	/* -- Connect via assoc channel -- */
	/* ------------------------------- */

	status = NDget_channel( &ToFather, &ToChildren );
	as$status(action = RET_STATUS);

	status =
	om$send( msg = message Root.connect
				(*ToFather,OM_K_MAXINT,SegId->objid,SegId->osnum,
				 *ToChildren, OM_K_MAXINT ),
		targetid = my_id);
	as$status(action = RET_STATUS);

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	om$send( msg = message NDnode.NDnotify_connect
				( MyId ),
		targetid = SegId->objid,
		targetos = SegId->osnum );

	/* ---------------------- */
	/* -- Update instances -- */
	/* ---------------------- */

        status =
        om$send (msg = message VRConcComp.VRSetMEIX
                                           (&retmsg, me->nNbTopo, nIndex),
            targetid = my_id);

	me->nNbTopo 		+= 1;
	*msg		 	= MSSUCC;
	status		 	= OM_S_SUCCESS;

}/* end connection proceeded */

return ( status );

}/* end VRConnect */
/***********************************************************************/

method VRDisconnect(	IGRlong 		*msg;
			struct GRid		*SegId;
			struct GRmd_env		*md_env  )
{
	IGRlong		retmsg;
	IGRshort	ii,jj;
	IGRshort	i;
	IGRint		status;
	IGRuint		SegIndex;
	OM_S_CHANSELECT	father;

*msg 	= MSFAIL;

	/*| -- Get Segment's index -- */

	father.type = OM_e_name;
	father.u_sel.name = "father";

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &father,
			objid		= SegId->objid,
			indexaddr	= &SegIndex  );
	as$status ( action = RET_STATUS );

        /*"My New TempIndex is %d\n", SegIndex */


	/*| -- Disconnect the segment -- */

	status= om$send (
		msg 	 = message NDnode.NDdisconnect ( 1, SegId ),
		targetid = my_id );
	as$status ( action = RET_STATUS );


	/* ---------------------- */
	/* -- Update instances -- */
	/* ---------------------- */

	/* erase index on this segment in my index list */
	for ( i = (SegIndex+1); i < me->nNbTopo ; i++ )
        {
           ii = i-1;

          status =
          om$send (msg = message VRConcComp.VRGetMEIX (&retmsg, i, &jj),
              targetid = my_id);

          status =
          om$send (msg = message VRConcComp.VRSetMEIX (&retmsg, ii, jj),
              targetid = my_id);
        }

	/* decrement my number of topology */
	me->nNbTopo 		-= 1;


*msg = MSSUCC;
return OM_S_SUCCESS;

}/* end VRDisconnect */


/***********************************************************************/

method VRChgSupport ( IGRlong *msg ; IGRdouble MyNewOrient;
                      IGRshort MyNewIndex; struct GRid *OldSupportId;
                      struct GRid *NewSupportId )
{
	IGRshort                ii;
        IGRlong                 retmsg;
	IGRint 			status;
	IGRuint			TempIndex;
	OM_S_CHANSELECT		father;

SetProc( VRConcComp_VRChgSupport ); Begin
*msg = MSSUCC;
father.type = OM_e_name;
father.u_sel.name = "father";

__DBGpr_com("calling NDnodein.NDchange_connect from OldSupportId,NewSupportId");
__DBGpr_obj("OldSupportId",*OldSupportId);
 __DBGpr_obj("NewSupportId",*NewSupportId);
	status = om$send( mode     = OM_e_wrt_message,
       			  msg      = message NDnodein.NDchange_connect
                                     ( 1, OldSupportId, NewSupportId ),
	                  targetid = my_id );
	as$status( action = RET_STATUS );

 __DBGpr_obj("NewSupportId after NDchange_connect",*NewSupportId);
	/* -- get specified template index -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &father,
			objid		= NewSupportId->objid,
			indexaddr	= &TempIndex  );
	as$status ( action = RET_STATUS );

        /*"My New TempIndex is %d\n", TempIndex */
__DBGpr_int("My New TempIndex ", TempIndex);

	/* -- Compute segment index -- */

	TempIndex = TempIndex - me->nNbAttr - me->nNbCpts*3 ;
        /*" This is my %dth segment\n", TempIndex */

	/* -- Update my array of position on my segments -- */

__DBGpr_int("My New TempIndex ", TempIndex);
        ii = TempIndex;

__DBGpr_int("index sent to VRSetMEIX",ii);
        status =
        om$send (msg = message VRConcComp.VRSetMEIX (&retmsg, ii, MyNewIndex),
            targetid = my_id);

__DBGpr_com("components sending MyNewOrient to instance here");
__DBGpr_int("My orients 00", me->nOrienToPlanes[0]);
__DBGpr_int("My orients 01", me->nOrienToPlanes[1]);
__DBGpr_int("My orients 02", me->nOrienToPlanes[2]);
__DBGpr_int("My orients 10", me->nOrienToPlanes[3]);
__DBGpr_int("My orients 11", me->nOrienToPlanes[4]);
__DBGpr_int("My orients 12", me->nOrienToPlanes[5]);

__DBGpr_int("cpt0 index on segment",me->nIndex[0]);
__DBGpr_int("cpt1 index on segment",me->nIndex[1]);
        
return ( OM_S_SUCCESS );

}/* end VRChgSupport */

/***********************************************************************/

end implementation VRConcComp;
