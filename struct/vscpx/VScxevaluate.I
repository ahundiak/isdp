/*
	I/STRUCT
*/ 
/*
 * History:
 *    Date            Who             Desc
 *    5/20/96         msm             Notify PME whenever any PME enabled
 *                                    element is modified or deleted.
 *
 */

class implementation VScpx ;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdlib.h>
#include "exdef.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

#include "v_miscmacros.h"
#include "vsdbgmacros.h"
#include "v_datamacros.h"

#include "nddef.h"

/*----------------------------------------------------------------------------*/
method VSevaluate(	long			*msg ;
			int			count ;
			struct GRid		list[] ;
			struct GRmd_env		*my_env ;
			short			level ;
			struct IGRdisplay	*display )  {

	int		sts,		/* OM return code	*/
			outpCount ;	/* Count of my outputs	*/
        struct GRid	*myOutputs ;	/* My computed feet	*/
	VSobjDef	myDef ;		/* My definition	*/
	int		i;
	IGRboolean	flag=FALSE;
	struct GRid	MyID;
	OMuword         curOs;
	IGRlong		status;

	__DBGpr_com ( "In VScpx: VSevaluate ");

	myOutputs = NULL ;
	ex$get_cur_mod( osnum = &curOs );

	MyID.objid = my_id;
	MyID.osnum = curOs;

	/*
	 * Get count of feet.
	 */
	sts = om$send(	msg	= message VScpx.VSgetObjDef( msg, &myDef ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSgetObjDef", wrapup ) ;

	outpCount = myDef.output.count ;

	if( outpCount ) {
		int i ;

		if( !( myOutputs = _MALLOC( outpCount, struct GRid ) ) ) {
			vs$mem_fail() ;
		}
		for( i = 0 ; i < outpCount ; i++ )
				myOutputs[i].objid = NULL_OBJID ;
	}

	if( display ) {

		struct GRsymbology	mySymb ;

		mySymb.display_attr	= *display ;
		mySymb.level		= level ;

		/*
		 * Sending wrt message because complex is a GRowner and
		 * therefore GRputsymb will be fowarded to components (feet)
		 * that it does not yet have. This must be done before
		 * ACconstruct_feet.
		 */
		sts = om$send(	msg	= message GRvg.GRputsymb( msg, &mySymb),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRvg.GRputsym", wrapup ) ;
	}

	/*
	 * `VS_K_InitialPlacement' means this is object creation, and not
	 * a recompute.
	 */
	sts = om$send( msg	= message ACncpx.ACconstruct_feet(
							msg,
							VS_K_InitialPlacement,
							count,
							list,
							my_env,
							&outpCount,
							myOutputs ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "ACncpx.ACconstruct_feet", wrapup ) ;

	sts = om$send(	msg	= message ACncpx.ACchange_feet(	outpCount,
        							myOutputs,
        							my_env ), 
               	        targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACchange_feet", wrapup ) ;

	/* The Original source object is modified and new children are created.
	 * PME needs to be notified accordingly.
	 */

	if( IsPmeEnabled() == TRUE )
	{
	  __DBGpr_obj ( "Parent List ", list[0] );

	  /*  Verify if the parent is PME enabled */

	  VDPisObjPmeEnabled( msg, list[0], &flag );
	  __DBGpr_int ( "Flag ", flag );

	  if (flag == TRUE )
	  {
	    /* Pme delete parent.
	    status = VDPPmeDelete( msg, list[0], FALSE );
	    CheckRC( status, *msg );

	    /* Pme enable myself */
	    status = VDPPmeEnable ( msg, MyID, NULL );
	    CheckRC( status, *msg );
	  }
	  else
	  {
	    IGRint		nb_child=0;
	    struct GRid 	*list_child=NULL;

	    __DBGpr_com ("Flag is FALSE, Parent is not PME enabled");
	    /* Get Children.
	    /* See if children are Pmeenabled
	    /* If yes, enable myself
	     */
	    sts = om$send (msg = message NDnode.NDget_objects 
				 (ND_CHILDREN | ND_IN_BUF , NULL, 0, 
				  &list_child, 0, OM_K_MAXINT, &nb_child),
		  targetid = list[0].objid,
		  targetos = list[0].osnum );
	    __CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;
	    __DBGpr_int ( "nb_child ", nb_child );
	    for ( i=0; i < nb_child; i++ )
	    {
		__DBGpr_obj ( "Children ", list_child[i] );
		flag = FALSE;
		VDPisObjPmeEnabled( msg, list_child[i], &flag );
		if (flag == TRUE )
		{
		    __DBGpr_com("Child is PME enabled");
		    status = VDPPmeEnable ( msg, MyID, NULL );
		    CheckRC( status, *msg );
		    continue;
		}
	    }
	  }
	}

        wrapup :
        	_FREE( myOutputs ) ;
                return sts ;

} /* method VSevaluate */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
