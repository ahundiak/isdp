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

  extern OMuword        OPP_VSimgFeature_class_id,
			OPP_VSbeam_class_id,
			OPP_VLunwrap_class_id;


/*c     External Functions ****/

//c defined in include files */

//c *************** External Methods ***********************

from	GRvg	  import	GRgetattr ;
from	VSfeature import	VSgetResultType ;
from	ACcpx	  import	find_macro ;
from	ACcpx_defn import	ACgive_name ;

//c  ***********   no global external func..

//c     Define the methods...



int VLrimbActHandler (	MyArg, entry, args, action )
        char			* MyArg;	//I Private argument : module
	struct  GRlc_info       * entry;	//I Located object
	struct  LC_action_args  * args;		//I NOT USED
	enum    GRlocate_action * action;	//I locate action state

		   
{

  int		  status = OM_E_INVARG,		// method return code
  		  sts = LC_RELOCATE;		// locate return code

  struct	GRid	* BeamOrNci = NULL ;	// located beam or nci macro


  IGRlong               msg = MSFAIL;           // method argument return code

  VSpartAttr              part ;		// beam's part attributes
  VSbeamAttr              myAttr ;		// beam's beam attributes


  SetProc( AlmaActH ) ;	Begin

        //c Check if transitional locate action

        if( *action == start_transition || *action == end_transition ) {
                sts = LCptlocact( MyArg, entry, args, action ) ;
                goto wrapup ;
        }

	BeamOrNci = &(entry->located_obj) ;

	if ( (  (int)(*MyArg) & Flattened ) &&
             ( vs$is_ancestry_valid ( object  = BeamOrNci  ,
                               classid = OPP_VLunwrap_class_id) )  ){
		__DBGpr_com( "flatttened plate " ) ;

	}

	if ( ! ( (int)(*MyArg) & FlatBars ) 	) {

		__DBGpr_int( "not looking for flat bars, leaving..",*MyArg) ;
		goto CallLocate ;
	}

        if ( vs$is_ancestry_valid ( object  = BeamOrNci  ,
                               classid = OPP_VSimgFeature_class_id ) == FALSE) {
        unsigned long type  = 0;
        IGRlong         msg = MSFAIL;

        status = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                &msg,
                                                                &type ),
                        senderid= NULL_OBJID,
                        targetid= BeamOrNci->objid,
                        targetos= BeamOrNci->osnum ) ;
        __CheckRC( status, msg, "ActH:getResult", CallLocate );

        if( type & VS_m_BEAM  ) {
                __DBGpr_com( "Beam Image" ) ;
        }
	else  goto CallLocate ;

      } // if image

      else if ( vs$is_ancestry_valid ( object  = BeamOrNci  ,
                                   classid = OPP_VSbeam_class_id ) == FALSE) {
		__DBGpr_int( "not a stiffener",*MyArg) ;
		goto CallLocate ;
      }
			

         //	Retrieve attribute to find if beam is offset in x direction.

        part.Iwant=  VS_m_MbrType | VS_m_PartFam | VS_m_MatGrade | VS_m_MatType;
        part.specific   = (void *) &myAttr      ;

        status = om$send(  msg  = message GRvg.GRgetattr( &msg, (char *)&part ),
                        senderid= NULL_OBJID,
                        targetid= BeamOrNci->objid,
                        targetos= BeamOrNci->osnum ) ;

        __CheckRC( status, msg, "Mrk: GRvg.GRgetattr", CallLocate ) ;

	if(   part.info.memberType != 2 ) {

	   if ( !strcmp( part.info.family, "PL" ) || 
	        !strcmp( part.info.family, "rectangle" ) || 
	        !strcmp( part.info.family, "plaskow1" ) ) {

		__DBGpr_obj( "flat BeamOrNci", *BeamOrNci );
		__DBGpr_str( "mat", part.info.material );
		__DBGpr_str( "grade", part.info.grade );

	   }
	   else {
		__DBGpr_str( "family", part.info.family );
		__DBGpr_int( "type", part.info.memberType );
		__DBGpr_obj( "NOT a flat bar", *BeamOrNci );
		sts = LC_RELOCATE;
		goto wrapup ;
	   }
       }
       else {
		__DBGpr_obj( "twisted ", *BeamOrNci );
       }

CallLocate:
		sts = LCptlocact ( MyArg,
                                   entry,
                                   args,
                                   action );

wrapup:

	End

	return ( sts );

}	// end alma action handler

end implementation VLcoToAlCmd;
