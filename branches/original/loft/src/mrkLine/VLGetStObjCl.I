
class implementation VLmrkLine;

//+*****************************************************************************
//
//	Function to get the object and type of an (normally) I/STRUCT object.
//		   
//===========================================================================***

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "madef.h"
#include "ma.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "asmacros.h"
#include "emssfintdef.h"
#include "graph.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsglobalmsg.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsbmaxisdef.h"
#include "vssectiondef.h"
#include "vsstfnrdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsattr.h"
#include "vsbeam.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmsg.h"

/********************************** DEBUG flags	***********************

#ifndef MARKERDEBUG

#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1

#endif

*********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vlmark.h"

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

//   *********c	External Functions


//********************c  External Methods

from  VSfeature	import	VSgetResultType;

// from	GRgraphics	import GRgetname;

// External variables

extern	GRclassid
			OPP_VSplate_class_id ,
			OPP_VSfeature_class_id ,
			OPP_VSimgFeature_class_id,
			OPP_VSbeam_class_id ,
			OPP_ACpretend_class_id ;


//----------------------------------------------------------------------------
//	Get the class of an object and its module, if its a struct object set
//	its type.
//----------------------------------------------------------------------------

int	VLGetObjAndClass(
		IGRlong		 *	Msg ,		
		struct GRobj_env *	TheStructObj ,
		struct GRmd_env  *	MdEnv ,
		GRclassid	 *	ObjClassId )

{

  int	sts	=	OM_E_INVARG ;


  SetProc ( VLGetObjAndClass ); Begin

  if ( ! TheStructObj || ! ObjClassId || ! MdEnv || ! Msg ) goto wrapup ;

        //c  get objects class, if pretend find underlying object

  sts = om$get_classid(	osnum		= TheStructObj->_osnum ,
			objid		= TheStructObj->_objid ,
			p_classid	= ObjClassId	) ;
  __CheckRC(sts,1,"Mark: get classid on plate to be marked",wrapup);

  if( om$is_ancestry_valid( superclassid  = OPP_ACpretend_class_id,
                            subclassid    = *ObjClassId ) == OM_S_SUCCESS ){

	sts = om$send( msg = message NDmacro.ACreturn_foot(
						Msg,
						"",
                                                &(TheStructObj->obj_id)	,
						&(TheStructObj->_matrix_type),
						TheStructObj->_matrix 	),
                       senderid = NULL_OBJID,
                       targetid = TheStructObj->_objid,
                       targetos = TheStructObj->_osnum );

	__CheckRC(sts,*Msg,"Mark:.ASreturn_go object to check",wrapup);
	__DBGpr_obj( "pretend pts to", TheStructObj->obj_id ) ;

                //c  retrieve the support surface of the plate

       sts = om$get_classid(	osnum           = TheStructObj->_osnum  ,
				objid           = TheStructObj->_objid  ,
				p_classid       = ObjClassId      ) ;
	CheckRC( sts, 1 ) ;

  } // if pretend

  else {				// if it's in the active file
	if ( TheStructObj->_osnum == MdEnv->_MD_OS )
					TheStructObj->mod_env = *MdEnv;  

	else {				// just set the module 
		sts = ex$get_modid ( mod_osnum= TheStructObj->_osnum ,
					mod_id= &(TheStructObj->_md_id) );
		__CheckRC( sts , 1, "get_modid", wrapup ) ;
		TheStructObj->_md_os = TheStructObj->_osnum ;
		__DBGpr_obj( "mod id of ref obj",TheStructObj->mod_env.md_id );
	}

  }		// else not a pretend


   if( om$is_ancestry_valid( superclassid  = OPP_VSimgFeature_class_id,
                             subclassid    = *ObjClassId ) == OM_S_SUCCESS ) {
        unsigned long type  = 0;
        *Msg = MSFAIL;

        sts = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                Msg,
                                                                &type ),
			senderid= NULL_OBJID,
		targetid = TheStructObj->_objid,
		targetos = TheStructObj->_osnum );

        __CheckRC( sts,*Msg, "Mrk:getResult", wrapup );

        if( type & VS_m_PLATE ) {
                __DBGpr_com( "Plate Image" ) ;
                *ObjClassId = OPP_VSplate_class_id;
        }
        else if( type & VS_m_BEAM  ) {
                __DBGpr_com( "Beam  Image" ) ;
                *ObjClassId = OPP_VSbeam_class_id;
        }

   } // if an image

	*Msg = sts = OM_S_SUCCESS ;
wrapup:

	End
	return sts ;


}  	// end fn get object and type 

end implementation VLmrkLine  ;
