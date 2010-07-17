class implementation VLcoToAlCmd;



#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "maerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlmark.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vsbeamdef.h"
#include "vsbeam.h"
#include "vssectiondef.h"
#include "vsmiscmacros.h"


/************************** internal definitions************************/

#include "vlalma.h"

/************************** internal definitions************************/

/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"


/*c     External Variables ****/

/*	none */

/*c     External Functions ****/
/*c defined in include files */

//c *************** External Methods ***********************

from	NDmacro	import	ACreturn_foot,
			ACgive_structure;
from	text_exp import  NDgive_structure ;
from	GRvg	 import	GRgetattr ;

//c  ***********   no global external func..

//c     Define the methods...



method ProcessFlatBar (	struct GRid *	bar )	// incoming flat bar

		   
{

  int		  status = OM_E_INVARG;		// method return code

  struct GRobj_env 	locObj,		//ptr to the located obj, for env info
			BarObjEnv ;

  struct GRid		FootGrid;	// contour and line ie output from bar
  GRobjid	*	LoopIds = NULL ;
  IGRlong               msg = MSFAIL;           // method argument return code

  IGRchar		facename [40],
			LogMessage[50] ;        // message to put in log file


  VSpartAttr              part ;		// beam's part attributes
  VSbeamAttr              myAttr ;		// beam's beam attributes

  IGRint		index   = 0 ,		// counters
			NumLoops= 0 ,
                        suc     = OM_E_INVARG;

struct ret_struct       ret_struct;		//struct to hold return attribut


       if (me->LogFileId)			// log file enabled, set message
	       strcpy( LogMessage, "Problem converting the flat bar" ) ;

         //	Retrieve attribute to find if beam is offset in x direction.

        part.Iwant=  VS_m_MbrType | VS_m_PartFam | VS_m_MatGrade | VS_m_MatType;
        part.specific   = (void *) &myAttr      ;

        status = om$send(  msg  = message GRvg.GRgetattr( &msg, (char *)&part ),
                        targetid= bar->objid,
                        targetos= bar->osnum ) ;

	__CopyLogMessage( status, msg, "could not get the bar's attributes" );
        __CheckRC( status, msg, "Mrk: GRvg.GRgetattr", wrapup ) ;

    if(   part.info.memberType != 2 ) {

	if ( !strcmp( part.info.family, "PL" )		|| 
	     !strcmp( part.info.family, "rectangle" )	|| 
	     !strcmp( part.info.family, "F" )		|| 
	     !strcmp( part.info.family, "plaskow1" ) ) {

		__DBGpr_obj( "flat bar", *bar );
		__DBGpr_str( "mat", part.info.material );
		__DBGpr_str( "grade", part.info.grade );
		strcpy( me->material, part.info.material );
		strcpy( me->grade,    part.info.grade );

	}
	else {
		__DBGpr_str( "family", part.info.family );
		__DBGpr_int( "type", part.info.memberType );
		__DBGpr_obj( "NOT a flat bar", *bar );
		status = OM_S_SUCCESS ;
		goto wrapup ;
	}
    }
    else {
		__DBGpr_obj( "twisted ", *bar );
    }

    status = om$send( msg = message VLcoToAlCmd.ProcessName( "bar", bar ),
              targetid =   my_id );
    CheckRC( status, 1 );

    strcpy( facename, "beam:body:" );
    strcat( facename, VS_K_nmWebL );
    status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        facename, /* see VLflate_bar.h */
                                        &FootGrid,
                                        &(locObj.mod_env.md_env.matrix_type),
                                        locObj.mod_env.md_env.matrix ),
		senderid = NULL_OBJID,
		targetid =   bar->objid,
		targetos =   bar->osnum ) ;

    __CopyLogMessage( status, msg, "could not get the bar's VS_K_nmWebL " );
    __CheckRC( status, msg, "pbar:ACreturn_foot", wrapup );
    locObj.obj_id = FootGrid ;

    status = om$send( msg    = message NDmacro.ACgive_structure(
                                        &suc,
                                        &index,
                                        VS_K_bmWebThkAttr ,
                                        &ret_struct,
                                        &locObj.mod_env ),
                  senderid = NULL_OBJID,
                  targetid = bar->objid,
                  targetos = bar->osnum ) ;

     CheckRC( status, suc );
     if( !( status   & 1 & suc ) ){
                me->epaisseur = 1. ;		// 1/10th of a mm
        }
     else		// geoform reads mm as .1 of mm
                me->epaisseur = ret_struct.var.root_pm_st.value * 10. ;

     __DBGpr_dbl( "thickness", me->epaisseur );

    status = om$send( msg = message VLcoToAlCmd.RangeToxyPlane( &FootGrid ),
		 targetid   = my_id);

    __CheckRC( status, 1, "pbars:RangeToxyPlane", wrapup );

    if ( me->autofile ) {
	sprintf( me->fileprefix, "%.4s_%dmm", me->grade,(int)me->epaisseur/10 );
    }

    status=om$send( msg = message VLcoToAlCmd.SaveFilename( &msg ),
                 targetid   = my_id );

    __CheckRC( status, msg, "pbars:SaveFilename", wrapup );

    status = om$send( msg = message VLcoToAlCmd.EcritDansFichierINI( me->name,
								  FootGrid ),
		targetid   = my_id);

    __CheckRC( status, 1, "ProcessFlatBar:EcritDansFichierINI ", wrapup );

    status = om$send( msg = message VLcoToAlCmd.GetSurfLoops(    &FootGrid,
                                                                &LoopIds,
                                                                &NumLoops ),

                        targetid = my_id);

    if ( NumLoops ) {

        struct GRid     Boundary ;
	struct	mise_a_plat	FlatSurf ;
        double          XExpn = 0.0 ,
                        YExpn = 0.0 ;
        int             TypeOfExpn = 0 ;
        IGRmatrix       ScaleMatrix ;
	IGRlong		l_sts	=	MSFAIL ;

        Boundary.objid = LoopIds[0] ;
        Boundary.osnum = me->Current.md_id.osnum ;
	BarObjEnv.obj_id = *bar ;
	BarObjEnv.mod_env= me->Current ;

        /* to be compatible with the unwrap functions, the method that finds
           the orientation and scales the plate, requires the mise_a_plat
           structure as an argument **/

        l_sts = VLinitDev(&FlatSurf);
        FlatSurf.surf_id.obj_id = FootGrid;
        FlatSurf.surf_id.mod_env= locObj.mod_env ;
        FlatSurf.res_id = FlatSurf.surf_id.obj_id;
        l_sts  = VLgetGeometry(&FlatSurf.surf_id, (IGRboolean) TRUE, NULL_OBJID,
                       (IGRchar ** )&FlatSurf.surface, &msg );
        FlatSurf.devsrf = FlatSurf.surface;

        status = om$send( msg = message VLcoToAlCmd.VLOrientScaleFlatPlate(
                                                                &BarObjEnv ,
                                                                &FlatSurf ,
                                                                ScaleMatrix ,
                                                                TypeOfExpn ,
                                                                XExpn ,
                                                                YExpn ,
                                                                &me->Current ,
                                                                &me->cst ),
                        targetid = my_id);

        __CopyLogMessage( status, msg, "problem placing orientation macro" );
        __CheckRC( status, 1, "plate OrientScale ", wrapup );

    }

    status = om$send( msg = message VLcoToAlCmd.ProcessSurf(    &FootGrid,
                                                                LoopIds,
                                                                NumLoops ),

                        targetid = my_id);

   __CopyLogMessage( status, msg, "problem processing bar's surface" );
   __CheckRC( status, 1, "plate ProcessSurfGrid", wrapup );


    if ( me->LogFileId )	// all's well, so say so in the log file
	strcpy( LogMessage, "bar conversion completed" );

wrapup:

   if ( me->LogFileId )
	   fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );

	return ( status );

}	// end process flat bar

end implementation VLcoToAlCmd;
