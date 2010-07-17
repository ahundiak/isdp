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
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbmaxisdef.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlplatejig.h"
#include "vlmark.h"
#include "vsdrwapi.h"
#include "vsdrwmacros.h"
#include "vlstructure.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "vledgeattr.h"

#include "bstrans1.h"		// extern IGRboolean BStrans1();
#include "bsnorvec.h"


/************************** internal definitions************************/

#include "vlalma.h"
#define		FINDTEMPS	2
#define		FINDPLATE	1
#define		FINDMARKS	0

/************************** internal definitions************************/

/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"

//c     External Functions ****/
//c defined in include files */

//c *************** External Methods ***********************/

from  VSfeature		import	VSgetResultType;
from  NDmacro		import	ACgive_structure,
				ACreturn_foot;
from  NDnode            import  ASreturn_go,
				NDget_objects;
from  ACcpx             import  find_macro,
				ACfind_exp_temp_obj,
				ACfind_temp_obj;
from  ACcpx_defn        import  ACgive_name;
from  GRgraphics        import  GRgetrang,
				GRgetname;
from  VLmrkLine		import	WhichSide;
from	ACpretend	import	ACfind_parent ;

//c     Extern variables ***/

  extern OMuword	OPP_VSimgFeature_class_id,
			OPP_VSplate_class_id,
			OPP_VSbeam_class_id,
			OPP_ACpretend_class_id,
			OPP_nci_macro_class_id,
			OPP_VLunwrap_class_id,
			OPP_VLpltJig_class_id ,
			OPP_VLmrkLine_class_id ,
			OPP_VLstfnrTpl_class_id ,
			OPP_VLtplMgr_class_id ;

//c  ***********   one global external func.. ***/

//c     Define the methods... *****/


method EcritDansFichierINI (
IGRchar		*dpr_name;
struct GRid	UnWrap_id )
{
  int		  status = OM_S_SUCCESS;


	SetProc( ecrit_fichier );	Begin

 
// printf header information out for the Rimbaud interface

	if ( me->ini_fileid && dpr_name  ) {
		if ( me->curfile ) {	// just got / from fget of file

		   if (	fprintf((FILE*)me->ini_fileid,"PA\n" ) <0 ) {
			status = OM_E_WRITE_ERROR;
			goto ret_error_exit;
		   }
			me->curfile = FALSE;
		}
		else {
		   if ( fprintf((FILE*)me->ini_fileid,"/PA\n" ) <0 ) {
			status = OM_E_WRITE_ERROR;
			goto ret_error_exit;
		   }
		}

		fprintf((FILE*)me->ini_fileid,"*ID\n%.40s\n",dpr_name);
		fprintf((FILE*)me->ini_fileid,"*RE\n%.40s\n",dpr_name);
		fprintf((FILE*)me->ini_fileid,"*TH\n%f\n",me->epaisseur );
		fprintf((FILE*)me->ini_fileid,"*GR\n%.20s\n",me->grade);
		fprintf((FILE*)me->ini_fileid,"*MA\n%.20s\n",me->material);
		fprintf((FILE*)me->ini_fileid,"*ST\n%d\n",me->aStatus );
//		fprintf((FILE*)me->ini_fileid,"*GE\n" );

	  if (me->LogFileId )
		fprintf((FILE*)me->LogFileId, "processing %s\n", dpr_name ) ;

	}	// if file.ini and have a name

	else {
		__DBGpr_int( " no INI fileid !!\n ", me->ini_fileid );
		__DBGpr_int( " 		or no name", dpr_name );
		if (me->LogFileId )
		    fprintf((FILE*)me->LogFileId, "no name or no ini file\n" ) ;
	}

	status = OM_S_SUCCESS;

ret_error_exit:

	End
	return status;

}	// end write to file.ini

method writeToMaster ( IGRchar * objectName /* I: name of object to convert */ )
{
  int		  status = OM_S_SUCCESS;

	// write each entry with default values to master file
   IGRchar temp[33];

   SetProc ( writeToMaster );	Begin

   status = OM_E_INVARG;
   if ( !objectName || !me->master_fileid ) goto wrapup;

	temp[0] = temp[32] = '\0';
	strncpy( temp, objectName, (size_t)28 );
	strcat( temp, ".dpr" );

/* next line is the output of the part parameters and values tabulated the way
   the Alma file reads the data about each part in the master file.
*/
// header for part
	 if ( fprintf((FILE*)me->master_fileid,"%-32s %22s %22s \n",
					     temp,objectName,objectName ) <0 ) {
		status = OM_E_WRITE_ERROR;
		goto wrapup;
	 }
// then the entry
	fprintf((FILE*)me->master_fileid,
					"%4d%4d%4d%2d%2d%2d%2d%2d%2d",
					   1, 1, 1, 1, 1, 1, 1, 0, 0 );
	fprintf((FILE*)me->master_fileid,
					"%4d %4d%2d%2d",
					  1, 100, 1, 2 );
	fprintf((FILE*)me->master_fileid,
					 "%9d%9d%9d%9d%2d%2d\n",
					(int)me->epaisseur,(int)me->epaisseur,
					(int)me->epaisseur,(int)me->epaisseur,
					1,1 );
	fprintf((FILE*)me->master_fileid,
					"%4d%4d%4d\n",
					   0, 0, 0);

 /* if ( me->init_fileid )
			     fprintf((FILE*)me->init_fileid,"%s\n",objectName);
*/

    status = OM_S_SUCCESS;
wrapup:

    End
    return (status);

}	// end write to file.rin

method VLcoToAlCmdma ( IGRlong *l_ret )
{

OMuword		TEMP_cl;			// class id of located obj
IGRint   	i	=	0 ,		// current object index 
		suc	= OM_E_INVARG,
		status  = OM_S_SUCCESS;

struct	GRid	RefObj,		// temp object in for return_go
	     *	ids	=	NULL;		// list from GetEdges


VLsdlContext * CtxCast = &(((VLsdlContext*)(me->SdlContexts))[0]) ;

  SetProc( VLcoToAlCmd );	Begin

  ex$message(  msgnumb = VL_S_PROCESS,
			buff = me->status );

  om$send( msg = message VLcoToAlCmd.status( me->status ),
			targetid   = my_id);

  if ( !l_ret ) { status = OM_E_INVARG;	goto wrapup ;	}

 for(i=0; i<me->Cnt1; i++ ){		// process list of objects located

       // check to see from which class the object is and then process 
	//  accordingly 

   __DBGpr_obj( "got id\n",me->Lst1[i].obj_id );

   status = om$get_classid( osnum   = me->Lst1[i].obj_id.osnum  ,
			 objid   = me->Lst1[i].obj_id.objid  ,
		 p_classid       = &TEMP_cl      ) ;

   if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id ,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

   	__DBGpr_obj( "got reference object before ret_go",me->Lst1[i].obj_id );
	RefObj.objid = NULL_OBJID;
	status = om$send( msg  = message NDnode.ASreturn_go( &RefObj,
							     &(me->RefMatType),
							     me->RefMatrix ),
                        senderid = NULL_OBJID,
                        targetid = me->Lst1[i].obj_id.objid,
                        targetos = me->Lst1[i].obj_id.osnum );

	__CheckRC( status, 1, "CTA:return_go", next_object );

	status = om$get_classid( osnum   = RefObj.osnum  ,
                                 objid   = RefObj.objid  ,
                                 p_classid       = &TEMP_cl      ) ;
	__CheckRC( status, 1, "CTA:get_classid", next_object );

    }  // end if its a reference object
    else {
		RefObj = me->Lst1[i].obj_id;
    }

   if( (me->TransTypes & ( FlatPlates|FlatBars) ) &&
	om$is_ancestry_valid( superclassid  = OPP_VSimgFeature_class_id,
                             subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
	unsigned long type  = 0;
	IGRlong		msg = MSFAIL;

        status = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                &msg,
								&type ),
                    	senderid= NULL_OBJID,
                        targetid= RefObj.objid,
                        targetos= RefObj.osnum ) ;
	__CheckRC( status, msg, "CTA:getResult", next_object );

        if( type & VS_m_PLATE ) {
                __DBGpr_com( "Plate Image" ) ;
		TEMP_cl = OPP_VSplate_class_id;
		if ( me->LogFileId ) {
		   fprintf( (FILE*)me->LogFileId, "Plate image selected\n" );
		}
	}
	// else should fall through to next object
   } // if image

	// Now find out what the real object is a sub class of

   if( (me->TransTypes & (FlatPlates) ) &&
  	 om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id ,
                             subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

	   if ( me->LogFileId ) {
		fprintf( (FILE*)me->LogFileId, "Converting the plate\n" );
	   }

	   status=om$send( msg = message VLcoToAlCmd.ProcessName( "plate",
								 &RefObj ),
			targetid = my_id);
	   CheckRC( status, 1 );

	    status = om$send( msg = message VLcoToAlCmd.ProcessPlate( &RefObj,
									i ),
		    targetid   = my_id);
	    __CheckRC( status, 1, "CTA:process plate", next_object );
   }

   else if( (me->TransTypes & FlatBars) &&
		om$is_ancestry_valid( superclassid  = OPP_VSbeam_class_id, 
                             	      subclassid = TEMP_cl ) == OM_S_SUCCESS ) {

	   if ( me->LogFileId ) {
		fprintf( (FILE*)me->LogFileId, "Converting the bar\n" );
	   }

	    status = om$send( msg = message VLcoToAlCmd.ProcessFlatBar(&RefObj),
		    targetid   = my_id);
	    __CheckRC( status, 1, "CTA:process jig", next_object );
   }

   else if( (me->TransTypes & PinJigs) &&
		om$is_ancestry_valid( superclassid  = OPP_VLpltJig_class_id ,
                             	      subclassid = TEMP_cl ) == OM_S_SUCCESS ) {

	   if ( me->LogFileId ) {
		fprintf( (FILE*)me->LogFileId, "Converting the jig\n" );
	   }
	    status = om$send( msg = message VLcoToAlCmd.ProcessJig( &RefObj,i ),
		    targetid   = my_id);
	    __CheckRC( status, 1, "CTA:process jig", next_object );
   }

   else if( (me->TransTypes & StiffTempls) &&
		om$is_ancestry_valid( superclassid  = OPP_VLstfnrTpl_class_id ,
                             	      subclassid = TEMP_cl ) == OM_S_SUCCESS ) {

	__DBGpr_com( "object is a stiffener template" ) ;

	if ( me->LogFileId ) {
		fprintf( (FILE*)me->LogFileId, 
				"Converting the stiffener template\n" );
	}

	me->Lst1[i].obj_id = RefObj ;
	status = om$send( msg = message VLcoToAlCmd.ProcessStiffTemplate(
								&me->Lst1[i] ),
		    targetid   = my_id);
	__CheckRC( status, 1, "CTA:process stiffener template", next_object );

   }

   else if( (me->TransTypes & PlateTempls ) &&
  	 om$is_ancestry_valid( superclassid  = OPP_VLtplMgr_class_id,
                             subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

	__DBGpr_com( "object is a plate template" ) ;

	if ( me->LogFileId ) {
		fprintf( (FILE*)me->LogFileId, 
				"Converting the plate template\n" );
	}
	status = om$send( msg = message VLcoToAlCmd.ProcessTemplMgr(
                                                        &RefObj ),
                        targetid = my_id);

        __CheckRC( status, 1, "plate ProcessTemplMgr", next_object );
   }

   else if( (me->TransTypes & Flattened) &&
		om$is_ancestry_valid( superclassid  = OPP_VLunwrap_class_id,
                             	      subclassid = TEMP_cl ) == OM_S_SUCCESS ) {

	struct GRid		currentUnWrap;	// current unw object in list
	struct  GRobj_env       Go3DSrf;	// 3D surface of the unwrap macr
	int			topmarks = 0,	//used in call to FindSuccessors
				botmarks = 0;	// to find plate from surface


					// strudel structure 

        __DBGpr_obj("found unwrap", RefObj );

	   if ( me->LogFileId ){
	      fprintf( (FILE*)me->LogFileId,"Converting the flattened plate\n");
	   }

	   currentUnWrap = RefObj ;
	
	   status = om$send ( msg = message ACcpx.ACfind_temp_obj(
								&suc,
								"ref",
								&me->Coord
								),
		  senderid = NULL_OBJID,
                  targetid = currentUnWrap.objid,
                  targetos = currentUnWrap.osnum);
	   __CheckRC( status, suc, "CTA:ACfind_temp Ref ", next_object );

	   status = om$send ( msg = message ACcpx.ACfind_temp_obj( &suc,
								"BaseSurface",
								&Go3DSrf.obj_id
								),
		  senderid = NULL_OBJID,
                  targetid = currentUnWrap.objid,
                  targetos = currentUnWrap.osnum);

	   __CheckRC( status, suc, "CTA:ACfind_temp Base", next_object );

	 status=om$send(msg= message VLcoToAlCmd.FindSuccessors(&Go3DSrf.obj_id,
								FINDPLATE,
								&topmarks,
								&botmarks ),
		    targetid = my_id);

         CheckRC( status, 1 );

	   status=om$send( msg = message VLcoToAlCmd.FindPlate(&Go3DSrf.obj_id),
			targetid = my_id);
	   __CheckRC( status, suc, "CTA:FindPlate", next_object );


	   status=om$send( msg = message VLcoToAlCmd.ProcessName( "plate",
							      &Go3DSrf.obj_id ),
			targetid = my_id);
	   CheckRC( status, 1 );

	   status=om$send( msg = message VLcoToAlCmd.GetPlateAttribs( 
								&Go3DSrf.obj_id,
								i ),
			targetid = my_id);
	   __CheckRC( status, suc, "CTA:GetPlateAttribs", next_object );


	   if ( me->master_fileid ){  // if master_file open

	     status = om$send(msg = message VLcoToAlCmd.writeToMaster(me->name),
				targetid = my_id);
	     __CheckRC( status, 1, "writeToMaster", next_object );
	   }


	if ( CtxCast->systTxt.out ) {		// if using strudel file
						// write out plate attributes
	   VSdrwOutputData *outPutInit = NULL ;

	   struct IGRplane	Plane ;
	   struct IGRlbsys	LBSys ;
	   IGRvector	Vector ;
	   IGRlong		msg = MSFAIL;

	   status =  vs$drwExecConfig (      msg             = &msg ,
                                elmId           = &Go3DSrf.obj_id ,
                                elmEnv          = &me->Lst1[i].mod_env ,
                                drwPlane        = &Plane ,
                                viewPlane       = &Plane ,
                                viewVector      = Vector,
                                drwEnv          = &me->Current ,
                                drwLbsys        = &LBSys ,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = "AlmaIni" ,
                                appData         = CtxCast ,
                                output          =  &outPutInit );
	   CheckRC( status , msg ) ;

	}		// if strudel active
	else { 
	   status = om$send(msg = message VLcoToAlCmd.EcritDansFichierINI( 
								       me->name,
								Go3DSrf.obj_id),
				targetid = my_id );
	   if ( !(status&1) ) {
		sprintf( me->status,"Unable to convert flattened plate %d ",i);
		om$send( msg = message VLcoToAlCmd.status( me->status ),
			targetid   = my_id);
		if (me->LogFileId) {
			fprintf( (FILE*)me->LogFileId, me->status, "\n" ) ;
		}

		// if debug print out failure
		__CheckRC( status, 1, "CTA:ecrit_fichier", next_object );

     	   }	// if manual write failed

        }	// else strudel file not active

      {
	 int 	NumEdges=	0;		// numb from GetEdges

           status = VLwritePRsection (  &currentUnWrap,
                                        &me->Loc_env.mod_env,
                                        me->ini_fileid,
					CtxCast 	);

	status = om$send( msg = message VLcoToAlCmd.GetEdges( currentUnWrap,
							  &ids,
							  &NumEdges ),
		targetid   = my_id);
	CheckRC( status, 1 );
	__DBGpr_int( "found edges", NumEdges );

      }

	if (me->LogFileId) {
		fprintf( (FILE*)me->LogFileId,
			  "conversion of flattened plate completed\n\n" );
	}


   } // end processing for unwrap objects 

   else   {
	if (me->LogFileId) {
		fprintf( (FILE*)me->LogFileId,
			  "conversion failed unsupported element\n\n" );
	}
	__DBGpr_com( "NOT SURE what we've got !!\n" );
	__DBGpr_int( "TransTypes",me->TransTypes ) ;
	__DBGpr_int( "TransTypes&Flattened",me->TransTypes&Flattened ) ;
	__DBGpr_int( "TransTypes&FlatPlate",me->TransTypes&FlatPlates ) ;
	__DBGpr_int( "TransTypes&FlatBars ",me->TransTypes&FlatBars ) ;
	__DBGpr_int( "TransTypes&PinJigs  ",me->TransTypes&PinJigs  ) ;
	__DBGpr_int( "TransTypes&PlateTemp",me->TransTypes&PlateTempls );
	__DBGpr_int( "TransTypes&StiffTemp",me->TransTypes&StiffTempls );
   }

   if ( CtxCast->systTxt.out ) {		// if using strudel file
						// write out any client specific
						// stuff for this object, even
						// if not supported internally

	   VSdrwOutputData *outPutInit = NULL ;

	   struct IGRplane	Plane ;
	   struct IGRlbsys	LBSys ;
	   IGRvector	Vector ;
	   IGRlong		msg = MSFAIL;

	   status =  vs$drwExecConfig (      msg             = &msg ,
                                elmId           = &RefObj ,
                                elmEnv          = &(me->Lst1[i].mod_env) ,
                                drwPlane        = &Plane ,
                                viewPlane       = &Plane ,
                                viewVector      = Vector,
                                drwEnv          = &me->Current ,
                                drwLbsys        = &LBSys ,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = "AlmaObj" ,
                                appData         = CtxCast ,
                                output          =  &outPutInit );
	   CheckRC( status , msg ) ;

    }		// if strudel active


next_object:
	me->Coord.objid   = NULL_OBJID;

 } // end for on list of located objects

    
 status = OM_S_SUCCESS ;

wrapup:

  if ( ids ) { om$dealloc( ptr = ids ); ids = NULL; }
  End
  return status ;

}	// end verify and process object





/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	map the range of a flat object to the global XY plane
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

method RangeToxyPlane ( 
	struct GRid * graphic		// planar graphic object to convert
		)
{ 
  int		  status = OM_E_INVARG ;

  IGRmatrix		matrix;			 /* matrix defining range   */
  short			mat_type;		 /* type of range matrix    */
  GRrange		range;			 /* range of locate obj	    */
  IGRboolean		world;			/* range in world or local  */
  IGRint                ii;                     /* incremental counters     */
  IGRlong		msg;			/* procedure return code    */

  if ( !graphic ) goto wrapup ;

	for (ii=0;ii<16;++ii ) matrix[ii]=0;  /*  matrice nulle*/
	 matrix[0]      = 1;
	 matrix[5]      = 1;
	 matrix[10]     = 1;
	 matrix[15]     = 1;
	 world    	= FALSE;
	status  = om$send ( msg = message GRgraphics.GRgetrang(
                                                &msg,
						&mat_type,
						matrix,
                                                &world,
						range
                                                ),
		senderid = NULL_OBJID,
		targetid = graphic->objid,
		targetos = graphic->osnum  );

	if ( !( (msg)&status&1) ) {

		__DBGpr_com( "getrange gave errors" );
		CheckRC( status, msg ) ;	

		me->transv[0] = me->transv[1] = me->transv[2] = 0.0;
		me->scale = 1.0;
		for ( ii = 0; ii<3; ++ii )
			me->tmat[ii*3]=me->tmat[ii*3+1]=me->tmat[ii*3+2] = 1.0;

	}
	else {
		IGRvector	vect;
		IGRvector	xy;
		IGRint		ind;
		IGRdouble	origin[3];
		BSrc		bsrc = BSSUCC;

		for ( ind=0; ind<3; ++ind )
			vect[ind] = range[ind+3] - range[ind];
#ifdef CONVTOALDEBUG
	printf( "%dst range gave %f %f %f\n",ind, *range, range[1],range[2]);
	printf( "%dst range gave %f %f %f\n",ind, range[3],range[4],range[5]);
	printf( "vec is %f %f %f\n",vect[0],vect[1],vect[2] );
#endif
		/* got the range vector, don't bother normalising just define
		   the unit plane in which the plate is oriented, then pass
		   this to the math translation function with the 1st range
		   point as its origin. **/

		__DBGpr_vec( "plane vec before", vect );

		if ( ( vect[0] > 0.001 ) && ( vect[1] > 0.001 ) 
		&& ( vect[2] > 0.001 ) ) {
			IGRboolean bool;
		   bool = BSnorvec( &bsrc, vect );
		   if ( !bool ) __DBGpr_int( "BSnorvec", bsrc );
		}
		else {
			if ( vect[0] > 0.001 ) vect[0] = 1.0; 
			if ( vect[1] > 0.001 ) vect[1] = 1.0; 
			if ( vect[2] > 0.001 ) vect[2] = 1.0; 
		}
		__DBGpr_vec( "plane vec after", vect );

		origin[0] = origin[1] = origin[2] = xy[2] = 0.0;
		xy[0] = xy[1] = 1.0 ;
		BStrans1( &bsrc, range, vect, origin, xy,  /* in */
			me->transv, (IGRpoint*)me->tmat, &me->scale);  /* out */

		if ( bsrc != BSSUCC ) {
			__DBGpr_int( "Error with transformation calculn",bsrc );
			status = OM_E_ABORT ;
		}

#ifdef CONVTOALDEBUG

		printf( "transvec is %f %f %f\n",me->transv[0],
					me->transv[1],me->transv[2]);
		printf( "scale is %f \n",me->scale );
		for ( ii = 0; ii<3; ++ii )
			printf( "matrix %f %f %f\n", me->tmat[ii*3],
			me->tmat[ii*3+1],me->tmat[ii*3+2]);
#endif

	} // else got range

wrapup:
	return( status );

}	// end rangetoxyplane


method FindSuccessors (

struct GRid *	plate;		/*I:	id of plate/surface to interrogate */
int	    	whichType;	/*I:	looking for marks=0 otherwise plates */
int	    *	topmarks;	/*0:	no of marks on top surface	*/
int	    *   botmarks	/*0:	no of marks on bottom surface	*/ )
{

  int		  status = OM_E_INVARG;

  IGRboolean	add	= TRUE ;		/*result of make source tolist*/
  IGRint	ind	= 0,
 		numSuccessors = 0;		/* number of dependents       */

  int		TypeSide;			/* which side of plate is mark*/
  OMuword	child_cl;			/* class of plate's dependent*/

  struct GRid *	lchild  = NULL,			/* list of dependents	      */
	      *	lToProcess = NULL,		/* total list to process */
		objInThisOs;

 #ifdef vsDEBUG
	IGRchar classname[80];
 #endif 

 if ( !plate || !topmarks || !botmarks ) goto wrapup;

     /* navigate from located object */

	  as$make_source( go_grid  = *plate,
			  mod_env = &me->ModuleInfo,
			  as_grid =   &objInThisOs);
				

 *topmarks = *botmarks = 0;
 __DBGpr_obj( "get_objects on", *plate );

 status = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_CHILDREN,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &numSuccessors ),
                targetid        = plate->objid,
                targetos        = plate->osnum,
                senderid        = NULL_OBJID );

   __CheckRC( status, 1, "NDnode.NDget_objects fd", wrapup );
   __DBGpr_int( "fd: plateside has this many dependents", numSuccessors );

   if ( !numSuccessors || !lchild ) goto wrapup ;

				/* copy the buffer before its reused */
   lToProcess =  _MALLOC( numSuccessors+1, struct GRid );

   for ( ind=0; ind<numSuccessors; ++ind ) {
	lToProcess[ind] = lchild[ind];
	if ( lToProcess[ind].objid == objInThisOs.objid ) add = FALSE;
   }

   if ( plate->objid != objInThisOs.objid && add ) {
			/* make sure to check plate's marker */
	lToProcess[ind] = objInThisOs ;
	numSuccessors++ ;
   }

   for ( ind=0; ind<numSuccessors; ++ind ) {

	__DBGpr_obj( "successor", lToProcess[ind] );	
   	status = om$get_classid( osnum	= lToProcess[ind].osnum,
			objid		= lToProcess[ind].objid,
			p_classid	= &child_cl	) ;
   	__CheckRC( status, 1, "get_classid", next_child );

	#ifdef vsDEBUG
   	status = om$get_classname( osnum	= lToProcess[ind].osnum,
			objid		= lToProcess[ind].objid,
			classname	= classname ) ;
   	__CheckRC( status, 1, "get_classname", next_child );
	__DBGpr_str( "classname", classname );
	#endif

	if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                      subclassid =child_cl ) == OM_S_SUCCESS) {
	 	int botMarks = 0,
		    topMarks = 0;

		__DBGpr_obj( "findp pretend: recurvsive", lToProcess[ind] );

		status = om$send( msg = message VLcoToAlCmd.FindSuccessors(
					&lToProcess[ind],
					whichType,
					&topMarks,
					&botMarks ),
				targetid = my_id );

		__CheckRC( status, 1, "find_dep:find_dep", wrapup );
		__DBGpr_int( "recur find_d top", topMarks );
		__DBGpr_int( "recur find_d bot", botMarks );
		*botmarks += botMarks;
		*topmarks += topMarks;

	} /* if a pretend */

        if ( whichType == FINDMARKS )  {
	   if( om$is_ancestry_valid( superclassid = OPP_VLmrkLine_class_id ,
				     subclassid   = child_cl ) == OM_S_SUCCESS){

		__DBGpr_obj( "its a mark",lToProcess[ind] );

		status= om$send ( msg = message VLmrkLine.WhichSide(&TypeSide),
			senderid = NULL_OBJID,
			targetid 	= lToProcess[ind].objid,
			targetos 	= lToProcess[ind].osnum);

		__CheckRC( status, 1, "vlmark.hichSide", next_child );
		__DBGpr_int( "side of plate", TypeSide );

		if ( TypeSide == VS_K_baOnTopOfPlate ) {
		   int i = 0;
			while ( me->topMarks[i].objid != NULL_OBJID ) ++i ;

			me->topMarks[i] = lToProcess[ind];
			++(*topmarks);

			if ( *topmarks >= me->numTopMarks ) {
				__DBGpr_com( "REALLOC on topMarks" );
				me->numTopMarks *= 2;
				me->topMarks = (struct GRid *)
					om$realloc( ptr  = (char *)me->topMarks,
						    size = me->numTopMarks );
			}
			me->topMarks[i+1].objid = NULL_OBJID;
		}
		else {
		   int i = 0;
			while ( me->botMarks[i].objid != NULL_OBJID ) ++i ;

			__DBGpr_obj( "adding to list", lToProcess[ind] );
			me->botMarks[i] = lToProcess[ind];
			__DBGpr_obj( "added  to list", me->botMarks[*botmarks]);
			++(*botmarks);

			if ( *botmarks >= me->numBotMarks ) {
				__DBGpr_com( "REALLOC on botMarks" );
				me->numBotMarks *= 2;
				me->botMarks = (struct GRid *)
					om$realloc( ptr	 = (char *)me->botMarks,
						    size = me->numBotMarks );
			}
			me->botMarks[i+1].objid = NULL_OBJID;
		} /* mark on bottom */
	      }	  /* if its a mark */
	   } /* if looking for marks */

           else if ( whichType == FINDPLATE )  {
		if(om$is_ancestry_valid(superclassid = OPP_VSplate_class_id ,
				     subclassid   = child_cl ) == OM_S_SUCCESS){

			__DBGpr_obj("one dependent is a plate",lToProcess[ind]);

			__DBGpr_com( "Returning plate " );
			*plate = lToProcess[ind];
		} /* if it's a plate */
	   } /* looking for marks */

           else if ( whichType == FINDTEMPS )  {

	       if (om$is_ancestry_valid(superclassid = OPP_VLtplMgr_class_id,
				     subclassid   = child_cl ) == OM_S_SUCCESS){
			__DBGpr_obj( "a DEPENDENT is a template mgr",
							lToProcess[ind] );
			*plate = lToProcess[ind] ;
			*topmarks = 1;
			break ;
		} /* if it's a template manager */
	   } /* if looking for the template manager of a plate */

   next_child: 
	status = OM_S_SUCCESS;

   } /* for all the successors in the graph from this object downwards */

	__DBGpr_int( "find_dep: no tops", *topmarks );
	__DBGpr_int( "find_dep: no bots", *botmarks );
	__DBGpr_int( "find_dep: no bot mark", me->numBotMarks );
	__DBGpr_int( "find_dep: no top mark", me->numTopMarks );
wrapup:

  _FREE( lToProcess );

  return ( status );

}	// end find successors in the graph from this object downwards

method ProcessName ( IGRchar * typeName;      /* I: TypeName for formatting */
		    struct GRid * plate	      /* I: plate/object with name */
						/* given a plate or similar,
						find its name or build one from
						the object id */ )
{
  int		  status = OM_E_INVARG;

IGRlong		msg	=	MSFAIL;
IGRchar		pathName[DI_PATH_MAX];	/* full pathname of located object   */
DIint		distatus=	MSFAIL;	/* why is DI DIfferent?	    */

    if ( !plate ) goto wrapup ;

    if ( !typeName ) typeName = "unknown" ;
    pathName[0] = '\0';

    status = om$send( msg = message GRgraphics.GRgetname( &msg,
							   pathName ),
              senderid = NULL_OBJID,
              targetid = plate->objid,
              targetos = plate->osnum ) ;
    CheckRC( status, msg );

    if( pathName[0] == '\0') {

	sprintf(me->name,"%.4s%.6d",typeName,plate->objid);
    }
    else {
 	  distatus = di$split (pathname = pathName,
			name = me->name);
    	  CheckRC( distatus, 1 );
    }

    __DBGpr_str( "NAME is now:", me->name );

   if ( me->LogFileId ) {
	fprintf( (FILE*)me->LogFileId, "Its name is %s\n", me->name );
   }

wrapup:
	return status;

} // end ProcessName 


/*d**************************************************************
        Given an object see and return the edge attributes associated with it
	in the global structure me->edgeAt for a single edge attribute object
	or process the object to see if there are any edges with edge
	attributes attached then process each edge of along with its attributes.
*******************************************************************/


method GetAttribOfObj (	struct GRid ObjId;	// I:object to check for attribs
			int	*   NumEdges	// O:  num edge atts found
			)
{


char 			*	theMacroName	= NULL ;
IGRint				numObjects	= 0,
				i		= 0,
				suc	=	OM_E_INVARG,
				sts	=	OM_E_INVARG;

IGRlong				msg	=	OM_E_INVARG ;

struct GRid 			EdgeMacId,
				MacroDefId,
				EdgeId ,
				*GridBuffer	= NULL ,
				AssocGrid;

struct GRmd_env			MOD_ENV;
OMuword				ids_cl;	       //classe id of the current object

IGRboolean			JustAttributes = FALSE ,
				TempTooling    = me->tooling ;

SetProc ( GetAttribs ) ;   Begin

 if ( !NumEdges || ObjId.objid == NULL_OBJID ) goto wrapup ;

 if ( *NumEdges == -1 ) JustAttributes = TRUE ;

 __DBGpr_obj( "get attributes of ", ObjId ) ;

 strcpy(me->edgeAt.type,"R");	// set back to defaults ie cut with no offset
 me->edgeAt.angle1	= 0.0;
 me->edgeAt.angle2	= 0.0;

 MOD_ENV = me->Loc_env.mod_env;

			// make sure have the assoc object = subclass of NDnode
 sts = as$make_source(	go_grid	= ObjId,
			mod_env	= &MOD_ENV,
			as_grid	= &AssocGrid );
 CheckRC( sts, 1 );
 __DBGpr_obj(" object from make_source: ", AssocGrid );

 sts = om$send ( msg =  message NDnode.NDget_objects( ND_IN_BUF | ND_CHILDREN,
			(struct GRid *)NULL,
			0,
			&GridBuffer,
		        0,
			OM_K_MAXINT,
			&numObjects),
			senderid = NULL_OBJID,
		targetid 	= AssocGrid.objid,
		targetos 	= AssocGrid.osnum);

  __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
  __DBGpr_int( "num from get_objects", numObjects ) ;

	// if no successors and need attributes means should be an edge attrib 

 if ( (!numObjects || !GridBuffer) && !JustAttributes )	goto wrapup;

 else if ( (!numObjects || !GridBuffer) && JustAttributes ) {
	numObjects = 1 ;	GridBuffer = &ObjId ;
  } 

  __DBGpr_objlist( "NDget_objects gave", numObjects, GridBuffer ) ;

 	// keep the nci_macros

 *NumEdges	= 0;
 i		= 0;

 do   {
 	sts = om$get_classid(	osnum		= GridBuffer[i].osnum,
				objid		= GridBuffer[i].objid,
				p_classid	= &ids_cl	) ;
  
	__CheckRC( sts, 1, "get_classid", NextSuccessor );

 	sts = om$is_ancestry_valid( superclassid = OPP_nci_macro_class_id,
			      	  subclassid   =ids_cl  ) ;
	__CheckRC( sts, 1, " it's not a nci_macro", NextSuccessor );

	  sts   = om$send ( msg = message ACcpx.find_macro( &MacroDefId ),
			senderid = NULL_OBJID,
			targetid 	= GridBuffer[i].objid,
			targetos 	= GridBuffer[i].osnum);
	  __CheckRC( sts, 1, "find_macro", NextSuccessor );

	  sts  = om$send ( msg = message ACcpx_defn.ACgive_name(&theMacroName),
			senderid = NULL_OBJID,
			targetid 	= MacroDefId.objid,
			targetos 	= MacroDefId.osnum);
	  __CheckRC( sts, 1, "ACgive_name", NextSuccessor );

#ifdef CONVTOALDEBUG 
		printf("nci %d %d <%s>\n",
			GridBuffer[i].objid,MacroDefId.objid,theMacroName);
		om$report_error( sts = sts );
#endif

 		 // keep only the 'edge_att' nci_macro
		 // MACRO_NAME  is  "edge_att" in vledgeattr.h

	if (!strcmp( theMacroName, MACRO_NAME ))	{
		EdgeMacId.objid 	=  GridBuffer[i].objid;
		EdgeMacId.osnum 	=  GridBuffer[i].osnum;
		++(*NumEdges) ;
	}
	else if (!strcmp(theMacroName,"edge2D_att"))	{

		__DBGpr_com( "** find the 3D edge_att ***" );
	  	  sts   = om$send ( msg = message ACcpx.ACfind_exp_temp_obj(
								&suc,
								0,
								&EdgeMacId ),
			senderid = NULL_OBJID,
			targetid 	= GridBuffer[i].objid,
			targetos 	= GridBuffer[i].osnum);
	  	__CheckRC( sts, 1, "ACfind_exp_temp", NextSuccessor );

		++(*NumEdges)  ;

	}  // if 2D edge_att 


		// Assigning the 3d edge macro id to Global value for use later
	me->edgeAt.macOcId	= EdgeMacId; 

	if ( !(*NumEdges) ){
		strcpy(me->edgeAt.type,"R");
		me->edgeAt.angle1	= 0.0;
		me->edgeAt.angle2	= 0.0;

		__DBGpr_obj(" Attributes not found for object", ObjId ) ; 
		goto NextSuccessor ;
	}


	if (!strcmp(me->edgeAt.type,"M"))	me->tooling = 1;
	else 					me->tooling = 0; 

			// if don't want just the attribs, must want edge as wel
	if ( !JustAttributes ) {

	   sts = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        "edge_3d",
                                        &EdgeId ,
                                        &(me->RefMatType) ,
                                        me->RefMatrix ),
                        senderid = NULL_OBJID,
                        targetid = EdgeMacId.objid,
                        targetos = EdgeMacId.osnum ) ;

	   __CheckRC( sts, msg, "ACreturn_foot edge_3d", NextSuccessor );

				// translate the edge with attributes 

	   sts = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
								&EdgeId ,
								FALSE ),
			targetid   = my_id);

	   __CheckRC( sts, 1, "FindTypeThenConvert", NextSuccessor );

	}  // need graphic edge and attributes

NextSuccessor :

  theMacroName="";
	++i ;


 }	 while ( i<numObjects );

wrapup:

   if ( !JustAttributes ) {		// set back to the default values
	__DBGpr_com( "resetting globals" ) ;
	me->edgeAt.angle1	= 
	me->edgeAt.angle2	= 0. ;
	me->edgeAt.macOcId.objid= NULL_OBJID ;
	strcpy(me->edgeAt.type,"R");
	me->tooling		= TempTooling ; 
   }

   End
   return sts;

}  // end get edge attributes on object 

//***+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//        Given some attributes, write the information into the neutral file
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


method WriteAttrib (struct GRid ObjToConv)
{

   int	type = 1 ,		// type of attribute
	angle1 = 0 ,		// 1st angle or value
	angle2 = 0 ,		// 2nd angle or value
	status = OM_E_INVARG ;

   long	msg = MSFAIL ;
				// global value containing strudel info

   VLsdlContext * CtxCast = &(((VLsdlContext*)(me->SdlContexts))[0]) ;

   char *	StrudelFileName = NULL ;

#ifdef CONVTOALDEBUG
	printf (" starting WriteAttrib type is %c\n",me->edgeAt.type[0]);
	__DBGpr_obj( "attributes for object", ObjToConv ) ;
	__DBGpr_obj( "3d attributes for this object",me->edgeAt.macOcId ); 
	__DBGpr_dbl( "angle1",   me->edgeAt.angle1 ) ;
#endif

switch ( me->edgeAt.type[0]) {


 case 'M' :				// this is attached to a mark 

	if ( CtxCast->systTxt.out ) {		// if using strudel file
		StrudelFileName = "AlmaMark" ;
	}
	else {
	   type        = MARQUAGE;
	   angle1      = 0;
	   angle2      = 0;

	   if (me->LogFileId ) {
		fprintf((FILE*)me->LogFileId, "transfered a mark\n" ) ;
		fprintf((FILE*)me->LogFileId, "no strudel file for marks\n" ) ;
	   }

	   if ( me->ini_fileid ) {
		fprintf((FILE *)me->ini_fileid,
					" -1 %d %d %d\n",type,angle1,angle2);
		status = OM_S_SUCCESS ;
	   }

    	}	// else no strudel file

	if (me->LogFileId ) {
		fprintf((FILE*)me->LogFileId, "transfered a mark\n" ) ;
	}

    break;		// for marks 

 default : {				// anything else is a cut 


	if ( CtxCast->systTxt.out ) {		// if using strudel file
		StrudelFileName = "AlmaEdge" ;
	     __DBGpr_obj( "strudel file for edge attrib", me->edgeAt.macOcId ) ;
	}
        else 	
	{
	   if (me->LogFileId ) {
		fprintf((FILE*)me->LogFileId, "no strudel file for edges\n" ) ;
	   }
	   if ( me->ini_fileid ) {
		fprintf((FILE *)me->ini_fileid,"\n" );
		status = OM_S_SUCCESS ;
	   }
	   __DBGpr_obj( "no strudel file for edge attrib", me->edgeAt.macOcId );

        } // else no strudel file

    	if (me->LogFileId ) {
		fprintf((FILE*)me->LogFileId, "transfered an edge (cut)\n" ) ;
    	}

    }	// end default setting 

 }	// end switch


 if ( CtxCast->systTxt.out ) {		// if using strudel file

	VSdrwOutputData *outPutInit = NULL ;

	struct IGRplane	Plane ;
	struct IGRlbsys	LBSys ;
	IGRvector	Vector ;

	struct GRid StrudelObj ;

	 if ( NULL_OBJID != me->edgeAt.macOcId.objid ) {
		StrudelObj = me->edgeAt.macOcId ;
	 }
	 else { // due to problem in loft function to find all edges & marks,
		// mark objects only pass the graphic information, but for 
		// strudel the mark macro (mark,roll etc) is more useful for
		// annotation.
		struct GRid ACpretendObj ;	// temporary prentend object

	     status = as$make_source( go_grid  = ObjToConv ,
			  	mod_env = &me->ModuleInfo,
			  	as_grid =   &ACpretendObj );
		CheckRC( status, 1 ) ;

	     __DBGpr_obj( "pretend obj ", ACpretendObj ) ;
	     status = om$send( msg = message ACpretend.ACfind_parent ( 
						&StrudelObj ,
						&(me->ModuleInfo._MATRIX_TYPE),
						(me->ModuleInfo._MATRIX ) ) ,
			targetid   = ACpretendObj.objid,
			targetos   = ACpretendObj.osnum );
	     CheckRC( status, 1 ) ;

	 }	// else no edge macro, just a graphic element

	   __DBGpr_obj( "strudel obj ", StrudelObj ) ;
	   __DBGpr_str( "strudel filename ", StrudelFileName ) ;

	   status =  vs$drwExecConfig (      msg             = &msg ,
                                elmId           = &StrudelObj ,
                                elmEnv          = &(me->Current),   // ref file?
                                drwPlane        = &Plane ,
                                viewPlane       = &Plane ,
                                viewVector      = Vector,
                                drwEnv          = &(me->Current) ,
                                drwLbsys        = &LBSys ,
                                selCount        = 0 ,
                                selList         = NULL,
                                filename        = StrudelFileName, 
                                appData         = CtxCast ,
                                output          =  &outPutInit );
	   CheckRC( status , msg ) ;

  }		// if strudel active

		// finished with object reset globals

  me->edgeAt.macOcId.objid	= NULL_OBJID ;

#ifdef CONVTOALDEBUGATT
 __DBGpr_int( "type", type );
 __DBGpr_int( "angle1", angle1 );
 __DBGpr_int( "angle2", angle2 );
#endif

 return  status ;

}  // end write attributes

end implementation VLcoToAlCmd;
