/* $Id: VRPreDrop.I,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRPreDrop.I
 *
 * Description:
 *		This file contains functions that are used for
 *		reporting pressure drop calculations.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPreDrop.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/17  19:30:52  pinnacle
# Replaced: vrprdcmp/VRPreDrop.I for:  by r240_int for route240
#
# Revision 1.2  1995/12/17  18:08:10  pinnacle
# Replaced: ./vrprdcmp/VRPreDrop.I for:  by azuurhou for route240
#
 *
 * History:
 *	05/24/95    Manyam	reporting pressure drop calculations.
 *	01/17/96    tlb		Add prototypes
 *				Change VRCalPreDrop to ANSII style
 *
 ***************************************************************************/

class implementation	Root;

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>
#include	<alloca.h>
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"OMprimitives.h"
#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"gr.h"
#include 	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"AS_status.h"
#include	"VRdimdef.h"
#include	"VRdef.h" 
#include	"VRstructs.h"
#include	"VRStSect.h"
#include	"VRDbStruct.h"
#include	"VRcompdef.h"
#include	"vrparameters.h"
#include	"vrprdcmp_pto.h"
#include	"vrflow_pto.h"
#include	"vrpdu_pto.h"


/*TBD
stabilize
	Define VRWritePDHeader();
	Define VRWriteSectHeader();
	Define VRWriteSectTerminator();
	Define VRWriteSectError();
	Move pre drop cal to define file

	Documentation for the function VRCalPreDrop()

NR	EquiDiam for OVAL and othr sections
*/

#define		VR_PRE_DROP_CAL		1

from	VRHComp		import	VRWriteAnalRes;
from	ACncpx		import	ACgive_structure;
from	VRGeneric	import	VRGetSysType, VRGetStatus;

/**********************************************************************

   Doc: VRRepPreDropInfo

   Abstract: Given the number of sections ,section information and file
        to write into, this function writes the predrop information for
        the respective sections.

   History:
        24 Mar 94       Manyam  Creation

   Return Status:
        OM_S_SUCCESS    success
        OM_E_INVARG     Invalid arguments
        OM_E_ABORT      Error during processing

   Future Scope :

***********************************************************************/

IGRint  VRRepPreDropRes( pSection, NbSections, pcFileName, pMdEnv )
        
        struct  VRSection       *pSection;      /* I : Section details  */
        IGRint                  NbSections;     /* I : Nb of Sections   */
        IGRchar                 *pcFileName;    /* I : File to write into*/
        struct  GRmd_env        *pMdEnv;        /* I : Mod Env of Cmp   */

/* start VRRepPreDropRes */
{
        FILE                    *FilePtr;
        IGRint                  status = OM_S_SUCCESS, Section, Elem;
        IGRlong                 retmsg;
        struct  VRSectInfo      *pSectInfo=NULL;
        IGRshort                nCptNum;

        /*C validate the arguments */
        if ( !pSection || !pMdEnv || NbSections <0 || 
                !NbSections  || !pcFileName )
                        return  OM_E_INVARG;

        /*A allocate the memory for the SectInfo structure */
        pSectInfo = ( struct VRSectInfo *)
                alloca( NbSections * ( sizeof(struct VRSectInfo) ) );
        
        if ( !pSectInfo )
        {
          printf( " VRRepPreDropRes : Could not allocate dynamic memory\n");
          return OM_E_ABORT;
        }

        /*A get the section information */
        status =
        VRGetSectInfo( pSection, NbSections, pSectInfo, pMdEnv );
        as$status( action = RET_STATUS );

        /*C open the file */
        if ( FilePtr = (FILE *)fopen( pcFileName, "w+" ) )
                ;
        else
        {
                fprintf( stderr, "Can not open file %s \n", pcFileName );
                return  OM_E_INVARG;
        }

        /*C write the header file */
        VRWritePDHeader( FilePtr );

        /*C process each section */
        for ( Section = 0; Section < NbSections; Section++ )
        {
          /*C write the section info if needed */
          VRWriteSectHeader( FilePtr, Section+1 );

          /*C process elements in each section */
          for ( Elem=0; Elem < pSectInfo[Section].NbCmps; Elem++ )
          {
            /*C check for validity and write the error message */
            if ( !pSectInfo[Section].pCmpIds )
            {
                VRWriteSectError( FilePtr );
                continue;
            }

            /*C set the cpt num for the element to be processed */
            if ( pSectInfo[Section].pCmpIds[Elem].objid ==
                  pSection[Section].StartId.objid &&
                    pSectInfo[Section].pCmpIds[Elem].osnum ==
                        pSection[Section].StartId.osnum )
                                nCptNum = pSection[Section].nStartCpt;
            else if ( pSectInfo[Section].pCmpIds[Elem].objid ==
                  pSection[Section].EndId.objid &&
                    pSectInfo[Section].pCmpIds[Elem].osnum ==
                        pSection[Section].EndId.osnum )
                                nCptNum = pSection[Section].nEndCpt;
            else nCptNum = -1;  /* do not check */

            /*C ask the component to report by itself */
            status = 
            om$send( msg        = message VRHComp.VRWriteAnalRes(
                        &retmsg, VR_PRE_DROP_CAL, FilePtr, nCptNum ),
                senderid = NULL_OBJID,
                targetid = pSectInfo[Section].pCmpIds[Elem].objid,
                targetos = pSectInfo[Section].pCmpIds[Elem].osnum );
            as$status();
                        
          } /* end processing for elements in the section */

          /*C write any info needed */
          VRWriteSectTerminator( FilePtr );

        }/*end processing Section */

        /*C close the file */
        fclose( FilePtr );

        /*C free the memory that has been allocated */
        for ( Section = 0; Section < NbSections; Section++ )
                if ( pSectInfo[Section].pCmpIds )
                        free( pSectInfo[Section].pCmpIds );

        return OM_S_SUCCESS;

}/* end VRRepPreDropRes */

IGRint  VREquiDiam( Shape, dWidth, dDepth, dEquiDiam )
        IGRint          Shape;          /* I : Shape of the Section */
        IGRdouble       dWidth;         /* I : width of the section */
        IGRdouble       dDepth;         /* I : depth of the section */
        IGRdouble       *dEquiDiam;             /* I : Equi Diam of the section */
{
        IGRint  status = OM_S_SUCCESS;

        switch( Shape )
        {
                case VR_RECT:
                status =
                VREquiDiamWD( dWidth, dDepth, dEquiDiam );
                break;

                case VR_CIRC:
/*KLUDGE : do we need to get the sect area and calculate the equi dia
  does it make a diff ?
*/
                *dEquiDiam = dWidth;
                break;

                case VR_OVAL:
                default:
                /* not yet supported */
                break;
        }
        return  status;
}

IGRint  VRWriteSectHeader( FilePtr, Section )
        FILE            *FilePtr;       /* I : File pointer */
        IGRint          Section;        /* I : section number */
{
        /*C write the section number */ 
        fprintf( FilePtr, "\n" );
        fprintf( FilePtr, "%-8d\n", Section );

        return  OM_S_SUCCESS;
}

IGRint  VRWriteSectTerminator( FilePtr )
        FILE            *FilePtr;       /* I : File pointer */
{
        /*C put a new line after writing the predrop info */    
        fprintf( FilePtr, "\n" );

        return  OM_S_SUCCESS;
}


IGRint  VRWriteSectError( FilePtr )
        FILE            *FilePtr;       /* I : File pointer */
{
        /*C put a new line after writing the predrop info */    
        fprintf( FilePtr, "NO COMPONENTS FOUND IN THIS SECTION" );

        return  OM_S_SUCCESS;
}

IGRint  VRWritePDHeader( FilePtr )
        FILE            *FilePtr;       /* I : File pointer */
{
        /*C put a new line after writing the predrop info */    
        fprintf( FilePtr, "=============================================================================================================\n");
        fprintf( FilePtr,
        "%-8s %-15s %-8s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
        "SECTION","CMPTAG-NUMBER","CMP-CODE"," AIR FLOW",
        "EQUIVALENT","VELOCITY","VELOCITY"," DUCT",
        "   LOSS","  TOTAL");

        fprintf( FilePtr,
        "%-8s %-15s %-8s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
        "NUMBER","","","   RATE"," DIAMETER",
        "","PRESSURE","LENGTH","COEFFICIEN","PRE LOSS");
 
        switch( VRenq_proj_units() )
        {
          case VR_IMPERIAL_UNITS:
                fprintf( FilePtr,
                "%-8s %-15s %-8s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
                "","",""," ( cfm )","   ( in )",
                "( ft/min )","in water","( ft )","","in water");
                break;

          case VR_METRIC_UNITS:
          case VR_MIXED_UNITS:
                fprintf( FilePtr,
                "%-8s %-15s %-8s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
                "","","","( m3/min )","   ( mm )",
                "( m/min )","mm water","( metres )","","in water");
                break;
        }

        fprintf( FilePtr, "=============================================================================================================\n");

        return  OM_S_SUCCESS;
}

/*D
        Extend to support diff types of fluids and metric units
*/
double  VRGetVelPre( dVelocity )
        IGRdouble       dVelocity;      /* I : Upstream Velocity of the fluid */
{
        IGRdouble       dVelPre=0.;

        switch( VRenq_proj_units() )
        {
          case VR_IMPERIAL_UNITS:
                dVelPre = pow ((dVelocity/4005), 2 );
                break;

          case VR_METRIC_UNITS:
          case VR_MIXED_UNITS:
                /*TBD : find out formulae and put it here */
                break;
        }

        return  dVelPre;
}

/**********************************************************************

   Doc: VRCalPreDrop

   Abstract:

   History:
        18 Apr 94       Manyam  Creation

   Return Status:
        OM_S_SUCCESS    success
        OM_E_INVARG     Invalid arguments
        OM_E_ABORT      Error during processing

   Future Scope :

***********************************************************************/

IGRint  VRCalPreDrop(
        struct  GRid            *pCmpId,        /* I : CmpId            */
        IGRshort                nCptNum,        /* I : Cpt Num at which to
                                                calculate               */
        IGRdouble               *pdPreDrop,     /* O : pre drop of the cmp*/
        struct  GRmd_env        *pMdEnv         /* I : Mod Env of Cmp   */
	)

/* start VRCalPreDrop */
{
        IGRshort        	nSysType, nStatus;
        IGRint          	status = OM_S_SUCCESS;
	IGRint			FootIndex = -1;
	IGRlong			msg;
	struct ret_struct	AttrSt;

	/*A validate the arguments */
	if ( !pCmpId || nCptNum > VR_MAX_CPTS ||
		nCptNum < -1 || !pdPreDrop || !pMdEnv )
			return 	OM_E_INVARG;

	/*A get the cmp's item number */
	status = 
  	om$send( msg      = message VRGeneric.VRGetSysType(
				&msg, &nSysType ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
	as$status( action = RET_STATUS );

	/*A get the cmp's status */
	status = 
  	om$send( msg      = message VRGeneric.VRGetStatus(
				&msg, &nStatus ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
	as$status( action = RET_STATUS );
	    
	/*A check whether the cmp is a duct or not */
	if ( nSysType == VR_PIPE && 
		nStatus & VR_CORRECTION )
	{
		IGRdouble	dFriFactor, dWidth, dDepth, dEquiDiam;
		IGRdouble	dLength, dVelocity, dVelPre;
		IGRint		Shape;

		/*C get the friction factor */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_FRICTION_FACT_DB, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		dFriFactor = (IGRdouble) AttrSt.var.root_pm_st.value;

		/*C get the length of the component */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_DUCT_LNG_DB, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		
		switch( VRenq_proj_units() )
		{
		  case VR_METRIC_UNITS:
		  case VR_MIXED_UNITS:
		  /*C system gives in mm */
		  dLength = AttrSt.var.root_pm_st.value/1000;
		  break;

		  case VR_IMPERIAL_UNITS:
		  /*C system gives in in */
		  dLength = AttrSt.var.root_pm_st.value/12;
		  break;
		}

		/*C get the shape of the section */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_SHAPE_IN, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		Shape = (IGRint) AttrSt.var.root_pm_st.value;

		/*C get the width of the section */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_WIDTH1_DB, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		dWidth = (IGRdouble) AttrSt.var.root_pm_st.value;

		/*C get the depth of the section */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_DEPTH1_DB, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		dDepth = (IGRdouble) AttrSt.var.root_pm_st.value;
			
		/*C get the equivalent dia */
		status =
		VREquiDiam( Shape, dWidth, dDepth, &dEquiDiam );

		/*C calculate the velocity pressure( dependent on the
		    fluid, units ) */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_MAX_VELOC_DB, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );

		/*C system gives pre sec : convert it to min */
		dVelocity = (AttrSt.var.root_pm_st.value)*60;

		dVelPre	= VRGetVelPre( dVelocity );

		/*C calculate the frictional predrop */
		if ( pdPreDrop ) 
			*pdPreDrop =
			( ( (12*dFriFactor*dLength)/dEquiDiam ) * dVelPre );

	} else {
		/*C calculate the dynamic pressure */

		IGRdouble	dLossCoeft, dVelPre,
				dVelocity;
		IGRchar		*cFootName=NULL;
		
		/*C get the fitting loss coefficient */
		if ( nCptNum > 1 )
		  cFootName = VR_N_BRANCH_COEFT_DB;
		else cFootName = VR_N_LOSS_COEFT_DB;
 
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				cFootName, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		dLossCoeft = (IGRdouble) AttrSt.var.root_pm_st.value;

		/*C calculate the velocity pressure */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&msg, &FootIndex, 
				VR_N_MAX_VELOC_DB, &AttrSt, pMdEnv ),
			senderid	= NULL_OBJID,
	   		targetid	= pCmpId->objid,
	   		targetos	= pCmpId->osnum );
		as$status ( action = RET_STATUS );
		
		dVelocity = (AttrSt.var.root_pm_st.value)*60;

		/*C this is for imperial units and air as the fluid*/
		dVelPre = VRGetVelPre( dVelocity );
		
		/*C calculate the dyn pre loss */
		if ( pdPreDrop )
			*pdPreDrop = dLossCoeft * dVelPre;

	}

	return	OM_S_SUCCESS;
}
end implementation	Root;

