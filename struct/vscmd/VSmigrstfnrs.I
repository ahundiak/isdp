/* $Id: VSmigrstfnrs.I,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        source_directory_filename
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmigrstfnrs.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/10/06  11:15:42  pinnacle
# Created: vscmd/VSmigrstfnrs.I by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 * 			suresh		some of the functionalities were given
 *                      manoj           creation
 ***************************************************************************/
/*
        I/STRUCT
*/
class implementation  VSstfBeam ;
#include <stdio.h>
#include <limits.h>
#include <math.h>
#include "OMminimum.h"
#include "nddef.h"
#include "ndmacros.h"
#include "OMmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrdef.h"
#include "dpstruct.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "vsdef.h"
#include "vsdbgmacros.h"
#include "vsmiscpplmac.h"
#include "vsplatedef.h"
#include "vsstfnrdef.h"
#include "msmacros.h"

#define  EPSILON       1.E-07

extern OMuword	OPP_VSfeature_class_id ;

from ACpretend	import ACfind_parent ;

/*
 * Gets a plate for migration. The criterion for selection is that 
 * the stiffener must COMPLETELY lie on a single Plate surface. In other 
 * words, stiffener is never been split into two or more if it lies on more 
 * than one surface to make migration possible.
 */
/*----------------------------------------------------------------------------*/
long  VSgetPlateForMigration( 	msg, 
				axis, 
				sideName, 
				nbPlates, 	
				subPlates, 
				toPlate, 
				migrate ) 
long 		 *msg ;		/* O: return code			     */
struct GRobj_env axis ;		/* I: axis of the stiffener	  	     */
char		 *sideName ;	/* I: plate side of stiffener	  	     */
int		 nbPlates ;	/* I: number of plates to be checked	     */
struct GRid	 *subPlates ;	/* I: plates to be checked for migration     */
struct GRid	 *toPlate ;	/* O: plate to which it needs to be migrated */
int		 *migrate ;	/* O: can it be migrated ?		     */
{
        long            	sts;
	int			i ;
	struct GRobj_env	plateSf ;
	IGRboolean 		world = TRUE ;
	GRrange 		rngAxis, rngPlate;

	*migrate = FALSE ;
	toPlate->objid = NULL_OBJID;
	/*
	 * Get the range of the axis 
	 */
        sts = om$send( msg = message GRgraphics.GRgetrang( 
						msg,
						&axis.mod_env.md_env.matrix_type, 
						axis.mod_env.md_env.matrix,
						&world, 
						rngAxis),
                        senderid = axis.obj_id.objid,
                        targetid = axis.obj_id.objid,
                        targetos = axis.obj_id.osnum);

	for ( i=0; i< nbPlates ; i++ )
	{
	        world = TRUE ;
		/*
		 * get the plate surface from the name  of the surface
		 */
		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							msg,
							sideName,
							&plateSf._grid,
							&plateSf._matrix_type,
							plateSf._matrix ),
				senderid= subPlates[i].objid,
				targetid= subPlates[i].objid,
				targetos= subPlates[i].osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		/*
	 	 * Get the range of the plate surface 
	 	 */
		sts = om$send( msg = message GRgraphics.GRgetrang ( 
							msg, 
							&plateSf._matrix_type,
							plateSf._matrix,
                                                        &world, 
							rngPlate ),
				senderid = subPlates[i].objid,
				targetid = subPlates[i].objid,
				targetos = subPlates[i].osnum);
		/*
		 * Check if the axis range is within the plate surface range
		 */
		if( (rngPlate[0]< rngAxis[0] 
			|| fabs( rngPlate[0] - rngAxis[0])<EPSILON )
	       	      		&&(rngAxis[0]< rngPlate[3]
			|| fabs(  rngAxis[0]  - rngPlate[3] ) < EPSILON)
			     &&( rngPlate[1] < rngAxis[1] 
               		|| fabs(  rngPlate[1] - rngAxis[1]  ) < EPSILON)
			     &&( rngAxis[1]  < rngPlate[4]
               		|| fabs(  rngAxis[1]  - rngPlate[4] )  < EPSILON)
               		      &&( rngPlate[2] < rngAxis[2] 
               		|| fabs(  rngPlate[2] - rngAxis[2]  ) < EPSILON)
               		      &&( rngAxis[2]  < rngPlate[5]
               		|| fabs(  rngAxis[2]  - rngPlate[5] ) < EPSILON)
               		      &&( rngPlate[0] < rngAxis[3]  
               		|| fabs(  rngPlate[0] - rngAxis[3]  ) < EPSILON)
               		      &&( rngAxis[3]  < rngPlate[3] 
               		|| fabs(  rngPlate[3] - rngAxis[3]  ) < EPSILON)
			     &&( rngPlate[1] < rngAxis[4] 
               		|| fabs(  rngAxis[1]  - rngPlate[4] )  < EPSILON)
			     &&( rngAxis[4]  < rngPlate[4]
               		|| fabs(  rngAxis[4]  - rngPlate[4] )  < EPSILON)
               		      &&( rngPlate[2] < rngAxis[5] 
               		|| fabs(  rngPlate[2] - rngAxis[5]  ) < EPSILON)
               		      &&( rngAxis[5]  < rngPlate[5]
               		|| fabs(  rngAxis[5]  - rngPlate[5] ) < EPSILON)
			 )
		{
                       /* 
			* The stiffner range box is contained within plate box
			*/ 
                        
			*toPlate = subPlates[i] ;
			*migrate = TRUE ;
			break ;
		}
	} /* for loop ends */
wrapup: 
    return  sts;

}/* VSgetPlateForMigration */
/*----------------------------------------------------------------------------*/
long VSmigStfToPlate( axis, stiffener, fromPlate, toPlate )
struct GRobj_env	axis ;		/* I: stiffener axis to be migrated   */
					/*   computation of axis aotumatically*/
					/*   computes stiffener	              */
struct GRobj_env	stiffener ;	/* I: stiffener axis to be migrated   */
					/*   computation of axis aotumatically*/
					/*   computes stiffener	              */
struct GRid		fromPlate ;	/* I: disconnect axis from this plate */
struct GRid		toPlate ;	/* I: connect axis to this plate      */
{
	int		cn_type = ND_COMP ;
	int		nb_change = 1;
        long            sts;

	/*	
	 * Change the connection of the axis from 'fromPlate' to 'toPlate'
	 */
        sts = om$send( msg = message NDnode.NDchange_connect( 
						nb_change,
						&fromPlate,
						&toPlate ),
			senderid = axis._objid,
			targetid = axis._objid,
			targetos = axis._osnum ) ;
	__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;

	/*	
	 * Change the connection of the stiffener from 'fromPlate' to 'toPlate'
	 */
        sts = om$send( msg = message NDnode.NDchange_connect( 
						nb_change,
						&fromPlate,
						&toPlate ),
			senderid = stiffener._objid,
			targetid = stiffener._objid,
			targetos = stiffener._osnum ) ;
	__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;

	nd$mod_batch( 	request  = ND_SET,
 			req_mode = ND_IMMEDIATE );

	nd$wait_batch(  type 		= GR_GEOM_POSTED,
			l_object	= &axis._grid,
			l_obj_info	= &cn_type,
			nb_obj          = 1 ) ;	
wrapup:

	return ( sts & 1 ) ? OM_S_SUCCESS : OM_W_ABORT ;

}/* VSmigStfToPlate */
/*----------------------------------------------------------------------------*/
long VSmigrateStiffeners( msg, nbStiff, stfList )
long			*msg ;	    /* O:return code			     */
int			nbStiff;    /* I:number of stiffeners to be migrated */
struct GRobj_env	*stfList ;  /* I:stiffeners to be migrated	     */
{
	long 		sts,amConsumed;
        int 		i, nbRoots=0, nbSubPlates=0;
	struct GRid 	plate, toPlate, parents[2]; 
        struct GRid     *subPlates = NULL;
	char            *sideName ;     /* Name of plate side surface   */
	int             mySide;         /* Which side am I on ?         */
        IGRchar         name[64];/* Gets the name of the stiffner       *
                                  * in case the stiffener is not migrated
                                  * to display message */	
        int             migrate= FALSE;         /* migrate or not ?    */
        struct GRobj_env axis ;		/* axis of the stiffener */
        struct GRobj_env axis_go ;	/* axis graphic obj of the stiffener */
        struct GRobj_env stfAxis ;
	

	__DBGpr_int("Number Of Stiffeners", nbStiff );
        /* 
	 * For each given stiffener 
	 */

	for( i = 0; i < nbStiff; i++ ) {

                /* 
		 * Get the two parents of stiffener: axis and plate
		 */

		sts = om$send( msg = message  NDnode.NDget_objects( 
						ND_ROOT,
						parents,
						2,
						NULL,
						VS_K_ConsumedIx,
						1,
                	                  	&nbRoots),
	                        senderid = stfList[i]._objid,
				targetid = stfList[i]._objid,
				targetos = stfList[i]._osnum ) ;
		__CheckRC( sts, 1, "NDmacro.NDget_objects", wrapup ) ;


		plate = parents[0];
		axis._grid = parents[1];

                /* 
		 * Find whether the plate is consumed
		 */
		sts = om$send(  msg = message NDmacro.ACtest_consumed(
						&amConsumed),
				senderid= plate.objid,
				targetid= plate.objid,
				targetos = plate.osnum ) ;
		__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
		if( ! (amConsumed & 1 ) )
		{
			/*
			 * An unconsumed plate can not have children plates.
                         * So no need to migrate this stiffener.
			 */
			continue ;
		}
		/*
		 * Free the subPlates if already filled.
		 */
		_FREE( subPlates ) ;
	
		/*
		 * Get all the subfeatures(subPlates) of the consumed plate.
		 */
		sts = om$send( msg = message VSfeature.VSgetVisDivRes(
						msg,
						&nbSubPlates,	
						&subPlates ),
			senderid = plate.objid,
			targetid = plate.objid,
			targetos = plate.osnum ) ;
		__CheckRC( sts, *msg,"VSfeature.VSgetVisDivRes", wrapup ) ;

		/*
	         * Now find which side we are on.
        	 */
	        sts = om$send(  msg     = message VSstfBeam.VSgetPlateSide(
                                                                msg, &mySide ),
				senderid = stfList[i]._objid,
				targetid = stfList[i]._objid,
				targetos = stfList[i]._osnum );
		__CheckRC( sts, *msg,"VSstfBeam.VSgetPlateSide", wrapup ) ;

		switch( mySide ) {
			default                  :
			case VS_K_stOnTopOfPlate :
				sideName = VS_K_plTopSfPathABS ; break ;
			case VS_K_stOnBotOfPlate :
				sideName = VS_K_plBotSfPathABS ; break ;
        	}
		/*
	         * Get the Beam Axis ( graphical object which has the same 
		 * environment of the VSbeamAxis )
 		 */
	        sts = om$send ( msg =  message VSbeam.VSgetSupportAxis(
                                                        msg,
							&stfList[i].mod_env,
                                                        &axis_go ),
                	        senderid = stfList[i]._objid,
				targetid = stfList[i]._objid,
				targetos = stfList[i]._osnum );
		__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ); 

		/*
                 * Get beam axis from ACpretend #1.
                 */
                sts = om$send( msg      = message ACpretend.ACfind_parent(
                                                        &stfAxis._grid,
                                                        NULL,
                                                        NULL ),
                               senderid = axis._objid,
                               targetid = axis._objid,
                               targetos = axis._osnum ) ;
                __CheckRC( sts, 1, "ACpretend.ACfind_parent", wrapup ) ;

		stfAxis.mod_env = axis_go.mod_env ;

		sts = VSgetPlateForMigration( 	msg, 
						stfAxis, 
						sideName, 
                                                nbSubPlates,
						subPlates, 
						&toPlate, 
						&migrate ) ;

		__CheckRC( sts, *msg, "VSgetPlateForMigration", wrapup ) ;

                if(!migrate){

			IGRchar	mesg[200];

                	sts= om$send( msg =  message GRgraphics.GRgetname( msg,
                                                                   name),
                	        senderid = stfList[i]._objid,
				targetid = stfList[i]._objid,
				targetos = stfList[i]._osnum );
			sprintf (mesg,"Stiffener %s can not be migrated. \n",name);
			/*
			 * "field" indicates where the message will be displayed
                         * justification : Text justification when the text 
                         * is displayed.
                         */
			ex$message( field         = ERROR_FIELD,
                        	    justification = CENTER_JUS,
			    	    in_buff	  = mesg );
			VS_Wait_timer( 50 ) ;
		}
		
		if(migrate){
			sts = VSmigStfToPlate( stfAxis, stfList[i], plate, toPlate );
			__CheckRC( sts, 1 , "VSmigStfToPlate", wrapup );
		}

	}

	nd$exec_batch() ; 

wrapup :
	_FREE( subPlates ) ;

	return ( *msg & sts & 1 ) ? OM_S_SUCCESS : OM_W_ABORT ;

}/* VSmigrateStiffeners */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ; 
