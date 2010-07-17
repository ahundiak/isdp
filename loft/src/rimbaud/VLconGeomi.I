class implementation VLcoToAlCmd;


#include "math.h"
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
#include "EMSdpb.h"
#include "vlmsg.h"
#include "vlplatejig.h"
/* #include "lsapprox.h" **/

#include <time.h>		/* to get today's date		*/

#include "madef.h"
#include "maidmx.h"		
#include "matypemx.h" 		/* extern IGRboolean MAtypemx */
#include "mainvmx.h"		
#include "marang2vc.h" 		/* extern IGRboolean MArang2vc*/
#include "maarendpt.h"		/* arc end points */
#include "maarxform.h"		/* arc xfrom */
#include "bstrfrhommx.h" 	/* extern void	BSptsoldtnw */
#include "bsptsoldtnw.h" 	/* extern void	BSptsoldtnw */
#include "bsdotp.h"		/* extern IGRdouble BSdotp */
#include "bscrossp.h"
#include "bslenvec.h"
#include "bspartofcv.h"		/* extern IGRboolean BSpartofcv(), */
#include "bsfreecv.h"		/* 		BSfreecv();	   */
#include "bsalloccv.h"		/* extern void	BSalloccv(),	   */
#include "bscveval.h"		/* 		BScveval();	   */
#include "bstrans1.h"		/* extern IGRboolean BStrans1();   */
#include "bscvoton.h"
#include "bschrdlkts.h"

/* #include "VLcirptype.h"		 extern GFcir_app()		   */

extern double fabs __((double));

/************************** internal definitions************************/

#include "vlalma.h"

#define MARQUAGE        31	/* Mark on plate or surface		*/
#define COUPE_DROITE    1	/* Linear cut				*/
#define COUPE_V         21	/* Cut along V				*/
#define COUPE_X         22	/* Cut along X axis			*/

#define BAD_MATRIX	99	/* Problem with located object's matrix */

#define TYPE            "type"
#define ANGLE1          "angle1"
#define ANGLE2          "angle2"

#define	MATL_SIZE	20	/* no of characters as defined by Alma   */
#define	GRADE_SIZE	20	/* no of characters as defined by Alma   */
#define MAXOFILES	20	/* no of ini files open at one time	 */
#define NUMMARKS	10	/* no of marks on either the top/bot of plate */

#define DELETE		0	/* options for status */
#define ADD		1
#define MODIFY		2

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif
#define RADDEG 180.0/M_PI

/************************** internal definitions************************/

/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUGSPLINE 1 
#define CONVTOALDEBUGJIG 1
#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vsmiscmacros.h"
#include "vldbgmacros.h"

/*c     External Functions ****/
/*c defined in include files */

/*c *************** External Methods ***********************/

from  NDmacro           import  ACgive_structure;
from  NDnode            import  NDget_objects,
				ASreturn_go;
from  GRgraphics        import  GRdelete;
from  GRowner		import  GRget_number_components;
from  GRowner		import  GRget_components;
from  GRlinear		import  GRgetpolyline;
from  GRconic		import  GRgetarc;
from  GRcurve		import  GRendpts;
from  GRvg		import  GRgetsize,
				GRgetgeom,
				GRgenabsg,
				GRpostabsg;
from  GRcoords		import	GRcvt_to_lcl_coords;
from  GRbcsubbc		import	EMcurve_by_poles;

/*c     Extern variables ***/

/*c  ***********   external vars.. ***/

	extern	GRclassid	OPP_GRlinestr_class_id ,
				OPP_GRcompcurve_class_id ,
				OPP_GRlineseg_class_id ,
				OPP_GRcirarc_class_id ,
				OPP_GRcircle_class_id ,
				OPP_GRellarc_class_id ,
				OPP_GRbspline_class_id ,
				OPP_ACpretend_class_id ,
				OPP_nci_macro_class_id ;

/*c  ***********   one global external func.. ***/

/*c     Define the state transitions... *****/


#define _GETFILENAME 0
#define _GETCIRCLESTATE 1
#define _GETCOMPONENTS 2

//=========================================================================*/
//            compute the angle between two vectors                        */
//                                                                         */
// AngleBet2Vecs( v1, v2, vz, angle )                                      */
//           I , I , I , O                                                 */
//=========================================================================*/


method AngleBet2Vecs (
	IGRdouble	*v1;
	IGRdouble	*v2;
	IGRdouble 	*vz;
	IGRdouble 	*angle )
{
  int		  status = OM_S_SUCCESS;


	IGRlong		retmsg;
	IGRdouble	cosinus,sinus,kz;
	IGRdouble	normal[3];

	/* -- compute angle's ( cosinus * length ) -- */
	cosinus = BSdotp ( &retmsg, v1, v2 );

	/* -- compute angle's ( sinus * length ) -- */
	BScrossp ( &retmsg, v1, v2, normal);

	sinus = BSlenvec ( &retmsg, normal );

	/* -- compute angle -- */
	*angle = atan2(sinus,cosinus);

	/* angle or M_PI - angle depending upon vz value */

	kz = BSdotp ( &retmsg, normal, vz );

	/* -- if kz < 0 => take the complementary angle -- */
	if (kz < 0) *angle = 2*M_PI - *angle;
		modulo( angle, 2*M_PI ); 

  return status;
}

method TranslateLine ( 
			struct GRid	GraphicObj /* object to convert */ )
{

#include "csdef.h"		/* coord sys defines are in this file	*/
 IGRint		action;		/* return points or their number	*/
 IGRint		ret = MSFAIL; 	/* int return for message sends		*/
 IGRlong	l_ret = MSFAIL;	/* long return for argument returns	*/
 BSrc		bsrc = BSSUCC;	/* maths return code			*/
 IGRint		j;		/* simple loop counter			*/
 IGRint		n_pnts=4;       /* number of points for getpolyline	*/
 struct IGRpolyline wpoly;      /* Structure for linear elements	*/
 struct IGRpolyline lpoly;      /* local struct for linear elements	*/
 struct IGRpolyline * ppoly;    /* pointer to coords in world or local	*/

	SetProc(TranslateLine);  Begin

	wpoly.points = lpoly.points = NULL;

        action = 0;    /* return # points */

        ret = om$send(msg=message GRlinear.GRgetpolyline(&l_ret,
                                    &(me->RefMatType ),
                                    me->RefMatrix,
                                    &action,
                                    &wpoly),
			senderid = NULL_OBJID,
                        targetid = GraphicObj.objid,
                       targetos = GraphicObj.osnum);
         __CheckRC( ret, l_ret, "GRgetpolyline", wrapup );
	 __DBGpr_int( "poly has points", wpoly.num_points );
  
         n_pnts = wpoly.num_points;
         if (wpoly.points) { om$dealloc(ptr=wpoly.points); wpoly.points = NULL;}

         if (lpoly.points) { om$dealloc(ptr=lpoly.points); lpoly.points = NULL;}
         wpoly.points = (IGRdouble *) om$malloc(size = 
						(n_pnts*3)* sizeof(IGRdouble) );
         lpoly.points = (IGRdouble *) om$malloc(size = 
						(n_pnts*3)* sizeof(IGRdouble) );

         action = 1;    /* return points */
         ret = om$send(msg = message GRlinear.GRgetpolyline(&l_ret, 
                                    &(me->RefMatType ),
                                    me->RefMatrix,
                                    &action,
                                    &wpoly),
			senderid = NULL_OBJID,
                       targetid = GraphicObj.objid,
                       targetos = GraphicObj.osnum);
	 __CheckRC( ret, l_ret, "GRgetpoly's points", wrapup );

	 if ( me->Coord.objid == NULL_OBJID ) {
		__DBGpr_com( "no coord id" );
		BSptsoldtnw( me->transv, (IGRpoint*)me->tmat, me->scale, n_pnts,
		    (IGRboolean)FALSE, (IGRpoint*)wpoly.points, NULL,
				(IGRpoint*)lpoly.points, &bsrc );

		if ( bsrc != BSSUCC ) __DBGpr_com( "trans err at NSPLINEPTS\n");
	 }
	 else {
	 	/* convert to local coord system of macro if one */
         ret = om$send( msg = message GRcoords.GRcvt_to_lcl_coords(
								&l_ret,
								Rectangular,
								n_pnts,
								wpoly.points,
								lpoly.points
								),
		senderid = NULL_OBJID,
                targetid = me->Coord.objid,
                targetos = me->Coord.osnum);
		CheckRC( ret, l_ret );
         }

         if ( !(ret&1&l_ret) || bsrc != BSSUCC ) {
		ppoly = &wpoly;		/* use world coords	*/
		__DBGpr_com( "world to local conversion failed\n" );
	}
	else {
		ppoly = &lpoly;		/* use local coords	*/
	}

#ifdef CONVTOALDEBUG
          printf("world %d %-6.2f %-6.2f\n",me->tooling,
               		wpoly.points[0], wpoly.points[1] ) ;
	  __DBGpr_vec( "world end ", &wpoly.points[3] );
          printf("local %d %-6.2f %-6.2f\n",me->tooling,
               		lpoly.points[0], lpoly.points[1] ) ;
	  __DBGpr_vec( "local end ", &lpoly.points[3] );
#endif

         if (n_pnts == 1 )                 		/* a POINT */
         {
           if (fprintf((FILE*)me->ini_fileid,"2 %d %-6.2f %-6.2f\n",me->tooling,
               		ppoly->points[0], ppoly->points[1] ) <0 ) {
						ret=OM_E_WRITE_ERROR;
	   }
         }
         else
         {
           for (j=0; j< (n_pnts -1); ++j )
             {
              if (fprintf((FILE*)me->ini_fileid,
			  "0 %d %-6.2f %-6.2f %-6.2f %-6.2f",
			  me->tooling,
              		  ppoly->points[j*3], ppoly->points[j*3+1],
              		  ppoly->points[j*3+3],ppoly->points[j*3+4] ) >= 0 ){

	          ret =om$send( msg = message VLcoToAlCmd.WriteAttrib(GraphicObj),
			    targetid = my_id);
	      }
	      else 
		ret=OM_E_WRITE_ERROR;

           }/* for n_pnts **/

         }/* close else not a point*/

	ret = OM_S_SUCCESS;
wrapup:
       if (wpoly.points) { om$dealloc (ptr=wpoly.points); wpoly.points = NULL; }
       if (lpoly.points) { om$dealloc (ptr=lpoly.points); lpoly.points = NULL; }
	
	End	
       return (ret);
}

method TranslateArc ( 

struct GRid	GraphicObj )
{

#define CW                    1
#define CCW                   0
 IGRint			sts	=	OM_E_INVARG,
			direction = CCW;    /*Counter Clockwise Arc direction */

 IGRlong		l_ret	=	MSFAIL;
 BSrc			bsrc	=	BSFAIL;

 IGRdouble   		endpts[9];	/* arc end pts on xy plane */

 struct IGRarc		TArc;            /* Structure for mapped arc */

 struct IGRbsp_curve	*  tspline = NULL ;

    __DBGpr_obj("enter TranslateArc GraphicObj ",GraphicObj );

   TArc.rot_matrix[10] = 0.;


     if ( me->Coord.objid != NULL_OBJID ) {

	struct IGRarc		Arc;            /* Structure for arc */
	struct IGRlbsys	*	lbs = NULL;	/* absg of cs */
	IGRmatrix		wtl ;		/* world to local matrix */
	IGRshort		mxtype ,	/* matrix type for wtl */
				si	= 4 ;


         sts = om$send( msg = message GRconic.GRgetarc(&l_ret, 
						&(me->RefMatType ),
						me->RefMatrix,
						 &Arc),
			senderid = NULL_OBJID,
                  targetid = GraphicObj.objid,
                  targetos = GraphicObj.osnum);
	__CheckRC( sts, l_ret, "GRconic.GRgetarc", wrapup );

	__DBGpr_vec("oldarc centre", Arc.origin );
	__DBGpr_vec("arc matrix normal(Zvector)", Arc.rot_matrix+8 );
	__DBGpr_dbl("arc sweep angle", Arc.sweep_angle );

	// get the local to world matrix of the coordinate system

         sts = om$send( msg = message GRvg.GRgenabsg(	&l_ret, 
					 &(me->Loc_env.mod_env._MATRIX_TYPE),
					 me->Loc_env.mod_env._MATRIX ,
						 (IGRchar**)&lbs ),
			senderid = NULL_OBJID,
                targetid = me->Coord.objid,
                targetos = me->Coord.osnum);
	__CheckRC( sts, l_ret, "GRcoords.GRgenabsg", wrapup );
 
	__DBGpr_mat("lbs matrix", lbs->matrix );

	si = 4 ;

	sts = MAinvmx ( &l_ret, &si, lbs->matrix, wtl) ;  /*ltw->wtl*/

	__CheckRC( sts, l_ret, "invert matrix failed", wrapup );

	sts = MAtypemx ( &l_ret, wtl, &mxtype);
	__CheckRC( sts, l_ret, "matrix type failed", wrapup );

	__DBGpr_int("world to local matrix type", mxtype );
	__DBGpr_mat("wtl matrix", wtl );

	sts = MAarxform( &l_ret, &Arc, wtl, &TArc ) ;
	__CheckRC( sts, l_ret, "Arc xform", wrapup );
 

    }		/* if coordinate system defined */
    else { /* no cs, so use manipulate the arc in bs form */

	struct IGRbsp_curve  *	BSArc   = NULL ;  /* arc in bs form */

	__DBGpr_com( "no coord id" );
         sts = om$send( msg = message GRvg.GRgenabsg(&l_ret, 
						&(me->RefMatType ),
						me->RefMatrix,
						 (IGRchar**)&BSArc ),
			senderid = NULL_OBJID,
                  targetid = GraphicObj.objid,
                  targetos = GraphicObj.osnum);
	__CheckRC( sts, l_ret, "arc genabsg", wrapup );

	__DBGpr_vec("oldarc start", BSArc->poles );

	BSalloccv(   BSArc->order, BSArc->num_poles, BSArc->rational,
			BSArc->num_boundaries, &tspline, &bsrc );
	if ( bsrc != BSSUCC ) {
		__DBGpr_int("BSALLOCV failed ",bsrc );
		sts 	= OM_E_NODYNMEM;
		goto wrapup;
	}

	BScvoton(	&bsrc,
			me->transv,     	/* translation vector */
			(IGRpoint*)me->tmat,    /* translation matrix */
			&me->scale,     /* scale to be applied */
			BSArc,         /* Arc in 3 space */
			tspline );      /* spline mapped to xy plane */

	if ( bsrc != BSSUCC ) {
			__DBGpr_int("BSCVOTON failed ",bsrc );
			sts  =  MSFAIL ;
			goto wrapup ;
	}

	__DBGpr_vec("newarc start", tspline->poles );

	/* convert bs -> arc to find center */

	sts = MAbctoar( &l_ret, tspline, &TArc ) ;
	__CheckRC( sts, l_ret, "spline->arc ", wrapup );

    } /* else no cs */

    __DBGpr_vec("Newarc centre", TArc.origin );
    __DBGpr_dbl("new arc sweep angle", TArc.sweep_angle );
    __DBGpr_vec("arc matrix Z", TArc.rot_matrix+8 );


    sts = MAarendpts( &l_ret, &TArc, endpts ) ;
    __CheckRC( sts, l_ret, "arc end points", wrapup );


          // Calculate arc direction
	

         //WriteElement                            *fprintf an ARC_ELE * 

	if ( TArc.rot_matrix[10] < 0. ) {
		direction = CW;
		__DBGpr_int(" Clockwise dir", direction );
		if (me->LogFileId)
		   fprintf((FILE*)me->LogFileId, "clockwise arc\n" );
		
	}
	else{
		__DBGpr_int(" CounterClockwise dir", direction );
		if (me->LogFileId)
		   fprintf((FILE*)me->LogFileId, "counterclockwise arc\n" );
	}

	if (fprintf((FILE*)me->ini_fileid,
		"1 %d %-6.2f %-6.2f %-6.2f %-6.2f %-6.2f %-6.2f %d",
		me->tooling,
           	endpts[0], endpts[1], endpts[3], endpts[4],	 /* endpts */
           	TArc.origin[0], TArc.origin[1], direction ) < 0 ) /* origin */
		 sts = OM_E_WRITE_ERROR;
	else {
	  sts = om$send( msg = message VLcoToAlCmd.WriteAttrib(GraphicObj),
		    targetid = my_id);
	}


wrapup:

	if (tspline)   { BSfreecv(&bsrc,tspline);	   tspline = NULL; }

	return (sts);

} /* decode arc */

method TranslateEllipse ( 

struct GRid	GraphicObj )
{


 IGRint			ret = OM_S_SUCCESS;
 IGRlong		l_ret;
  int	 kk, jj;
  double x_model[3], 	   /* it's realy the xaxis( 1,0,depth ) 	   */
	 x_local[3], 	   /* x axis of the rotation matrix     	   */
	 z_local[3],       /* z axis of the rotation matrix     	   */
	 ang_model_local,  /* angle between x_model and x_local 	   */
         ang_end;	   /* we have the sweep angle they ask for the end */
 struct IGRarc      arc;          /* Structure for arc data */

#ifdef CONVTOALDEBUG
printf("enter TranslateEllipse\n");
#endif
         ret = om$send( msg = message GRconic.GRgetarc(&l_ret, 
						&(me->RefMatType ),
						me->RefMatrix ,
						 &arc),

			senderid = NULL_OBJID,
                  targetid = GraphicObj.objid,
                  targetos = GraphicObj.osnum);

	__CheckRC( ret, l_ret, "GRgetarc", wrapup ) ;


         /* 
          * Calculate angle between MODEL X AXIS(1,0,0) LOCAL X AXIS
          */

	 for(kk=0;kk<3;kk=kk+1){
		jj = 4*kk;
		x_local[kk] = arc.rot_matrix[jj];
	 }


	 x_model[0] = 1.0;
	 x_model[1] = 0.0;
	 x_model[2] = x_local[2];

	 z_local[0] = 0.0;
	 z_local[1] = 0.0;
	 z_local[2] = 1.0;


#ifdef CONVTOALDEBUG
		printf("x_model =%f %f %f\n",x_model[0],x_model[1],x_model[2]);
		printf("x_local =%f %f %f\n",x_local[0],x_local[1],x_local[2]);
		printf("z_local =%f %f %f\n",z_local[0],z_local[1],z_local[2]);
#endif

//	 om$send( msg = message VLcoToAlCmd.AngleBet2Vecs( x_model, x_local, 
//					  z_local, &ang_model_local ),
//	     targetid = my_id );

	ret = MArang2vc	( &l_ret, x_model, x_local,z_local, &ang_model_local );
	__CheckRC( ret, l_ret, "MArang2vc", wrapup ) ;

	__DBGpr_dbl("ell-- ang_model_local ", ang_model_local);

 	 ang_model_local = ang_model_local * RADDEG;
         ang_end = arc.start_angle + arc.sweep_angle;
	 ang_end = ang_end * RADDEG;
	 arc.start_angle = arc.start_angle * RADDEG;

#ifdef CONVTOALDEBUG
	  printf("RADDEG = %f\n",RADDEG);
	  printf("ell-- ang_model_local = %f\n",ang_model_local);
	  printf("ell-- start_ang = %f sweep_ang%f\n",
			arc.start_angle,arc.sweep_angle);
#endif
	 
	  
	//WriteElement*                         *fprintf ELL_ELE *

	if (fprintf((FILE*)me->ini_fileid,
		"6 %d %-6.2f %-6.2f %-6.2f %-6.2f %-6.4f %-6.4f %-6.4f",
		me->tooling,
		arc.origin[0], arc.origin[1], 
		arc.prim_axis, arc.sec_axis,
		ang_model_local, arc.start_angle, ang_end ) < 0 )
			ret = OM_E_WRITE_ERROR;
	else {
	  ret = om$send( msg = message VLcoToAlCmd.WriteAttrib(GraphicObj),
	            targetid = my_id);
	}

wrapup:

	return (ret);

}	// translate ellipse

method TranslateEllipArc ( 

struct GRid	GraphicObj )
{


 IGRint			ret = OM_S_SUCCESS;
 IGRlong		l_ret;
  int	 kk, jj;
  double x_model[3], 	   /* it's realy the xaxis( 1,0,depth ) 	   */
	 x_local[3], 	   /* x axis of the rotation matrix     	   */
	 z_local[3],       /* z axis of the rotation matrix     	   */
	 ang_model_local,  /* angle between x_model and x_local 	   */
         ang_end,	   /* we have the sweep angle they ask for the end */
	 st_a[3], sw_a[3];
 IGRdouble   		pts[9];       
 struct IGRarc      arc;          /* Structure for arc data */

#ifdef CONVTOALDEBUG
printf("enter TranslateEllipArc\n");
#endif
         ret = om$send( msg = message GRconic.GRgetarc(&l_ret, 
						&(me->RefMatType ),
						me->RefMatrix ,
						 &arc),
			senderid = NULL_OBJID,
                  targetid = GraphicObj.objid,
                  targetos = GraphicObj.osnum);
         if ( !(ret&1) ){
		#ifdef CONVTOALDEBUG
			printf("ellipse GRgetarc ret = ",ret,"\n");
		#endif
		return ret;
	 }
         ret = om$send( msg = message GRcurve.GRendpts(&l_ret, 
						&(me->RefMatType ),
						me->RefMatrix,
                                                 &pts[0], &pts[6]),
			senderid = NULL_OBJID,
                       targetid = GraphicObj.objid,
                       targetos = GraphicObj.osnum);

         /* 
          * Calculate angle between MODEL X AXIS(1,0,0) LOCAL X AXIS
          */

	 for(kk=0;kk<3;kk=kk+1){
		jj = 4*kk;
		x_local[kk] = arc.rot_matrix[jj];
		st_a[kk]     = pts[kk]- arc.origin[kk];
		sw_a[kk]     = pts[kk+6] - arc.origin[kk];
	        z_local[kk] = arc.rot_matrix[jj+2];
	 }

	 x_model[0] = 1.0;
	 x_model[1] = 0.0;
	 x_model[2] = x_local[2];

	 #ifdef CONVTOALDEBUG
		printf("x_model =%f %f %f\n",x_model[0],x_model[1],x_model[2]);
		printf("x_local =%f %f %f\n",x_local[0],x_local[1],x_local[2]);
		printf("z_local =%f %f %f\n",z_local[0],z_local[1],z_local[2]);
	 #endif

	ret = MArang2vc	( &l_ret, x_model, x_local,z_local, &ang_model_local );
	__CheckRC( ret, l_ret, "MArang2vc", wrapup ) ;

	__DBGpr_dbl("ell-- ang_model_local ", ang_model_local);

//was	 om$send( msg = message VLcoToAlCmd.AngleBet2Vecs( x_model, x_local, 
//					  z_local, &ang_model_local ),
//	     targetid = my_id );

 	 ang_model_local = ang_model_local * RADDEG;

	ret = MArang2vc	( &l_ret, x_local, st_a, z_local, &arc.start_angle );
	__CheckRC( ret, l_ret, "MArang2vc", wrapup ) ;
	__DBGpr_dbl("ell-- arc.start ang", arc.start_angle );

//was	 om$send( msg = message VLcoToAlCmd.AngleBet2Vecs( x_local, st_a, 
//					  z_local, &arc.start_angle ),
//	     targetid = my_id );

	ret = MArang2vc	( &l_ret, st_a, sw_a, z_local, &arc.sweep_angle );
	__CheckRC( ret, l_ret, "MArang2vc", wrapup ) ;
	__DBGpr_dbl("ell-- arc.start ang", arc.sweep_angle );

//was	 om$send( msg = message VLcoToAlCmd.AngleBet2Vecs( st_a, sw_a, 
//					  z_local, &arc.sweep_angle ),
//	     targetid = my_id );


#ifdef CONVTOALDEBUG
	  printf("pts[1] = %f %f %f\n",pts[0],pts[1],pts[2]);
	  printf("pts[2] = %f %f %f\n",pts[6],pts[7],pts[8]);
	  printf(" dir z axis = %f\n",z_local[2]);
#endif
 
         ang_end = arc.start_angle + arc.sweep_angle;
	 ang_end = ang_end * RADDEG;
	 arc.start_angle = arc.start_angle * RADDEG;
	 arc.sweep_angle = arc.sweep_angle * RADDEG;

#ifdef CONVTOALDEBUG
	  printf("ell-- ang_model_local = %f\n",ang_model_local);
	  printf("ell-- start_ang = %f sweep_ang%f\n",
					arc.start_angle,arc.sweep_angle);
	  printf("ell-- ang_end = %f\n",ang_end);
#endif
	  
         //WriteElement*                          fprintf an ELL_ARC_ELE * 

     fprintf((FILE*)me->ini_fileid,
	     "6 %d %-6.2f %-6.2f %-6.2f %-6.2f %-6.4f %-6.4f %-6.4f",
	     me->tooling,
             arc.origin[0], arc.origin[1], 
	     arc.prim_axis, arc.sec_axis,
	     ang_model_local, arc.start_angle, ang_end );

	ret = om$send( msg = message VLcoToAlCmd.WriteAttrib( GraphicObj ),
			targetid   = my_id);
	CheckRC( ret, 1 ) ;

 wrapup:
	return ret;

}	// translate ellipse

method TranslateCircle ( 

struct GRid	GraphicObj )
{

 IGRint			ret = OM_S_SUCCESS;
 IGRlong		l_ret;
 struct IGRarc		arc;          /* Structure for arc data */
 BSrc			bsrc = BSFAIL;	/* BS return code 		      */

 SetProc( TranslateCircle );  Begin

  ret = om$send( msg = message GRconic.GRgetarc(&l_ret, 
						&(me->RefMatType ),
						me->RefMatrix,
						 &arc),
	senderid = NULL_OBJID,
	targetid = GraphicObj.objid,
	targetos = GraphicObj.osnum);

  __CheckRC( ret, l_ret, "GRgetarc", wrapup ) ;
  
         /*WriteElement*/ 

  __DBGpr_vec( "circle origin before conversion", arc.origin );
  __DBGpr_dbl( "circle primary axis", arc.prim_axis );
  __DBGpr_dbl( "circle secondary axis", arc.sec_axis );
  __DBGpr_dbl( "circle start angle", arc.start_angle );
  __DBGpr_dbl( "circle sweep angle", arc.sweep_angle );

  if ( me->Coord.objid == NULL_OBJID ) {
	BSptsoldtnw( me->transv, (IGRpoint*)me->tmat, me->scale,
				     1,(IGRboolean)FALSE,
					(IGRpoint*)arc.origin, NULL,
					(IGRpoint*)arc.origin, &bsrc );

	if ( bsrc != BSSUCC ) {
				__DBGpr_int( "trans err at NSPLINEPTS", bsrc);
	}
  }
  else {
	 	/* convert to local coord system of macro if one */
	ret = om$send( msg = message GRcoords.GRcvt_to_lcl_coords(
								&l_ret,
								Rectangular,
								1,
								arc.origin,
								arc.origin ),
		senderid = NULL_OBJID,
                targetid = me->Coord.objid,
                targetos = me->Coord.osnum);
	CheckRC( ret, l_ret );
  }


  fprintf((FILE*)me->ini_fileid,"6 %d %-6.2f %-6.2f %-6.2f %-6.2f 0 0 %-2.6f",
		 me->tooling,
                 arc.origin[0], arc.origin[1],
                 arc.prim_axis, arc.prim_axis,2*M_PI );

  ret = om$send( msg = message VLcoToAlCmd.WriteAttrib(GraphicObj),
			targetid   = my_id);
  __CheckRC( ret, l_ret, "GRgetarc", wrapup ) ;

wrapup:
	End
	return ret;

} // translate circle

method TranslateBSCurve ( 
struct GRid  *	GraphicObj; 		// the objid of the spline to convert
struct IGRbsp_curve * inspline		// or the geometry of the spline
)
{

 IGRlong		l_ret = MSFAIL;	//used to check which fn/method failed
 BSrc			bsrc = BSFAIL;	// BS return code
 IGRint			ret0 = MSFAIL,	// OM message return codes
		*	spn_ind = NULL;

 struct GRobj_env	TEMP;
 struct GRmd_env	md_info = me->Loc_env.mod_env;

				// below vars used with approx circulaire
 struct IGRbsp_curve  	*spline = NULL,
			*bezier = NULL,
			*tspline = NULL;

 IGRdouble		*coeff	 = NULL,
			*spline_pnts	=	NULL,
			*spline_params  =	NULL;

 SetProc( TranslateBSCurve ); Begin

 if ( !inspline &&  !GraphicObj ) goto ret_error_exit;


 if ( me->circleapprox  ) {

	if ( inspline ) {

	   __DBGpr_int( "inspline num_pole ", inspline->num_poles );
	   __DBGpr_int( "inspline order", inspline->order );
	   __DBGpr_vec( "inspline start pole ", inspline->poles );
	   __DBGpr_vec( "inspline end pole ", 
		&inspline->poles[(inspline->num_poles-1)*3] );

	   if ( inspline->order == 2 && inspline->num_poles > 3 ) {

	  	ret0 = om$send( msg = message VLcoToAlCmd.LineStrToCurve (
									NULL,
								     inspline ),
				targetid = my_id );
		__CheckRC( ret0, 1, "LineStrToCurve", ret_error_exit );

	   }		// if large linestring

		
	   else {	// convert curve to arcs

		if (me->LogFileId)
		   fprintf((FILE*)me->LogFileId,
			"using circular approx of curves\n" );

		ret0 = om$send( msg = message VLcoToAlCmd.ApplyCirApprox(
								NULL,
								inspline ),
				targetid = my_id );
		__CheckRC( ret0, 1, "applyArcApprox", ret_error_exit );
	   }	// convert to arcs

	}	// if inspline defined

	else {

		TEMP.obj_id  = *GraphicObj;
		TEMP.mod_env = md_info;

		__DBGpr_obj( "TEMP ",TEMP.obj_id );

		ret0 = om$send( msg = message VLcoToAlCmd.ApplyCirApprox(
								&TEMP,
								NULL ),
				targetid = my_id );
		__CheckRC( ret0, 1, "ApplyCirApprox", ret_error_exit );
	}

  }

  else 	//c no approximation

  {
  IGRshort    		ratio, num_b;
  IGRint		j,kk,jj,ii,
			num_ndeg,
			n_spline_pnts;
  IGRlong               size, num_pol;
  IGRdouble		u_st, u_mid, u_end;
  IGRpoint		line_begin,
			line_end;


    if ( me->LogFileId )
		   fprintf((FILE*)me->LogFileId,
			"Not using circular approx of curves\n" );

    if ( inspline == NULL ) {
         ret0 = om$send (msg = message GRvg.GRgetsize(&l_ret,
						&(me->RefMatType ),
						me->RefMatrix,
                                   &size),
			senderid = NULL_OBJID,
                          targetid = GraphicObj->objid, 
                          targetos = GraphicObj->osnum); 
	 __CheckRC( ret0, l_ret, "dec_spl:GRgetsize", ret_error_exit );

         spline = (struct IGRbsp_curve *) om$malloc ( size = size);
         ret0 = om$send (msg = message GRvg.GRgetgeom(	&l_ret,
							&(me->RefMatType ),
							me->RefMatrix,
							(IGRchar *) spline),
			senderid = NULL_OBJID,
                          targetid = GraphicObj->objid, 
                          targetos = GraphicObj->osnum); 
	 __CheckRC( ret0, l_ret, "dec_spl:GRgetgeom", ret_error_exit );
   }
   else {
	spline = inspline;
   }

   __DBGpr_int("spline->rational = ", spline->rational);
 #ifdef CONVTOALDEBUGSPLINE
		for(ii=0;ii<3*spline->num_poles;ii=ii+3)
		printf("spline[%d]%f %f %f\n",(ii/3),spline->poles[ii],
					spline->poles[ii+1],
					spline->poles[ii+2]);
 #endif


	 if( spline->rational != FALSE ){
         	BSchtptstcv ( spline, &n_spline_pnts, &spline_pnts, 
                      	     &spline_params,&bsrc);
#ifdef CONVTOALDEBUGSPLINE
		__DBGpr_int(" RATIONAL n_spline_pnts ",n_spline_pnts);
		printf(" spline_pnts = %f %f\n",spline_pnts[0],spline_pnts[1]);
#endif
	 	if ( me->Coord.objid == NULL_OBJID ) {
			BSptsoldtnw( me->transv, (IGRpoint*)me->tmat, me->scale,
				     n_spline_pnts,(IGRboolean)FALSE,
					(IGRpoint*)spline_pnts, NULL,
					(IGRpoint*)spline_pnts, &bsrc );

			if ( bsrc != BSSUCC ) {
				__DBGpr_int( "trans err at NSPLINEPTS", bsrc);
			}
		}
		else {
	 	/* convert to local coord system of macro if one */
		     ret0 = om$send( msg = message GRcoords.GRcvt_to_lcl_coords(
								&l_ret,
								Rectangular,
								n_spline_pnts,
								spline_pnts ,
								spline_pnts 
								),
				senderid = NULL_OBJID,
                		targetid = me->Coord.objid,
                		targetos = me->Coord.osnum);
				CheckRC( ret0, l_ret );
         	}


         	if (n_spline_pnts == 1)
         	{
           		/*WriteElement*/             /*fprintf a line segment */
       			fprintf((FILE*)me->ini_fileid,
					"2 %d %-6.2f%-6.2f\n",me->tooling,
              				spline_pnts[0], spline_pnts[1] );
         	}
         	else
         	{
           		for (j=0; j< (n_spline_pnts - 1 ); j=j+1)
           		{
             		    /*WriteElement*/      /*fprintf a line segment */
			    jj = 3*j;
         		    fprintf((FILE*)me->ini_fileid,
					"0 %d %-6.2f %-6.2f %-6.2f %-6.2f\n",
			    		me->tooling,
              		    		spline_pnts[jj], spline_pnts[jj+1],
              		    		spline_pnts[jj+3], spline_pnts[jj+4] );
           		}
         	}

	}/* for the time being if rational we stroke with the active cht */
	else {

		BSalloccv(   spline->order, spline->num_poles, spline->rational,
				spline->num_boundaries, &tspline, &bsrc );
		if ( bsrc != BSSUCC ) {
				__DBGpr_int("BSALLOCV failed ",bsrc );
				goto ret_error_exit;
		}

	 	if ( me->Coord.objid == NULL_OBJID ) {
		     __DBGpr_dbl( "NON rational before map:scale ",me->scale );

			BScvoton(	&bsrc,
				me->transv,     	/* translation vector */
				(IGRpoint*)me->tmat,    /* translation matrix */
				&me->scale,     /* scale to be applied */
				spline,         /* spline in 3 space */
				tspline );      /* spline mapped to xy plane */

			if ( bsrc != BSSUCC ) {
				__DBGpr_int("BSCVOTON failed ",bsrc );
				ret0 =  MSFAIL ;
				goto ret_error_exit;
			}
		}
		else {
		     ret0 = om$send( msg = message GRcoords.GRcvt_to_lcl_coords(
								&l_ret,
								Rectangular,
							spline->num_poles,
							spline->poles,
							tspline->poles
								),
				senderid = NULL_OBJID,
                		targetid = me->Coord.objid,
                		targetos = me->Coord.osnum);
				CheckRC( ret0, l_ret );
			__DBGpr_com( "COORDS MAY BE GLOBAL" );

			tspline->order = spline->order;
			tspline->num_poles = spline->num_poles;
			tspline->num_knots = spline->num_knots;
			BSmemcpy( sizeof( IGRdouble)*spline->num_knots,
				  spline->knots,
				  tspline->knots );
		}
		bezier = NULL;

		/* find the start poles of each Bezier arcs */

		size = ( tspline->num_poles -  tspline->order + 2) 
							* (sizeof(IGRint) );
		spn_ind = (IGRint *) om$malloc ( size = size); 
		BScvndegspn( tspline, &num_ndeg, spn_ind, &bsrc);
		if( bsrc != BSSUCC )
			 { ret0 = MSFAIL; l_ret=7;goto ret_error_exit;}
		spn_ind[num_ndeg] = tspline->num_knots - tspline->order;
#ifdef CONVTOALDEBUGSPLINE
			for(j=0;j<tspline->num_knots; ++j )
				printf("knot[%d] = %f",j,tspline->knots[j]);
			__DBGpr_int("number of arcs",num_ndeg );
			__DBGpr_int("size ",size );
			for( j=0;j<=num_ndeg; ++j ) {
			    printf("span[%d] = %f", j,spn_ind[j]);
			    __DBGpr_dbl("knot ",tspline->knots[spn_ind[j]] );
			}
#endif
		// for each arcs convert in the polynomial base and print 

		coeff = (double *) om$malloc ( size = tspline->num_poles * 24 );
 		num_pol = tspline->order;
		num_b   = 0;
		ratio   = tspline->rational;
		jj = tspline->order;
  		BSalloccv((IGRshort)jj,num_pol,ratio,num_b,&bezier,&bsrc);
		if( bsrc != BSSUCC ) 
			{ ret0 = MSFAIL; l_ret=8;goto ret_error_exit;}

		kk = 3;
		
		for(j=0;j<num_ndeg; ++j ){

		    u_st  = tspline->knots[spn_ind[j]];
		    u_end = tspline->knots[spn_ind[j+1]];
		    u_mid = 0.75*u_st + 0.25*u_end;		     

  		    BSpartofcv( &bsrc, 
				tspline, 
				u_st,
		                u_mid,
				u_end,
				bezier );

		    if( bsrc != BSSUCC ){ 
			__DBGpr_com( "BSpartofcv failed" );
			ret0 = MSFAIL;	l_ret=9;	goto ret_error_exit;
		    }
/* modif PPC */
/* Alma ne suporte pas les bezier de degres 1 */

		    __DBGpr_int( "Bezier order",bezier ->order );

		    if (bezier ->order!=2) {
		    	om$send( msg = message VLcoToAlCmd.pococv_pcr(kk,
							&(bezier->poles[0]),jj,
							coeff),
			    targetid = my_id );
		    
		    	fprintf( (FILE*)me->ini_fileid,
			      "5 %d %d %-13.6f %-13.6f %-13.6f %-13.6f 0.0 1.0",
				me->tooling,
		      	jj, coeff[0], coeff[1], bezier->poles[kk*(jj-1)],
		      	bezier->poles[kk*(jj-1)+1]);
			if ( GraphicObj ) {
			     om$send( msg = message VLcoToAlCmd.WriteAttrib(
								     *GraphicObj),
				targetid   = my_id);
			}
			else
		    		fprintf( (FILE*)me->ini_fileid,"\n" );

		    	for(ii=0;ii<kk*jj;ii=ii+kk)
/* modif PPC */
/* ajout de 5 * dans la ligne */
				fprintf((FILE*)me->ini_fileid,"5 %d %d %-13.6f %-13.6f\n",
					me->tooling,
					(ii/kk+1),coeff[ii],coeff[ii+1]);
			}
/* modif PPC */
      /*Write Line Element*/
		     else {  /* just use endpoints of each subcurve */

			BScveval(bezier,0.,0,(IGRpoint*)line_begin,&bsrc);

			BScveval(bezier,1.,0,(IGRpoint*)line_end,&bsrc);

			__DBGpr_vec( "line_begin",line_begin );
			__DBGpr_vec( "line_end",line_end );

        		fprintf((FILE*)me->ini_fileid,
					     "0 %d %-6.2f %-6.2f %-6.2f %-6.2f",
						me->tooling,
               		 			line_begin[0],line_begin[1],
			 			line_end[0],line_end[1]);
			 if ( GraphicObj ) {
			    ret0 = om$send(msg = message VLcoToAlCmd.WriteAttrib(
								     *GraphicObj),
				targetid   = my_id);
		         }	/* if spline object */
			else
		    		fprintf( (FILE*)me->ini_fileid,"\n" );

		} /* else write linear */
		
	} /* for ndeg */

    }/* end of non rational case; we generate Bezier arcs */

 } /* else no circular approximation */ 

 l_ret = ret0 = OM_S_SUCCESS;

ret_error_exit:		/*===	ret_error_exit	get out and cleanup	=====*/

         if (spn_ind)  { om$dealloc(ptr=spn_ind);          spn_ind  = NULL; }
         if (coeff)    { om$dealloc(ptr=coeff);            coeff    = NULL; }
	 if (bezier)   { BSfreecv(&bsrc,bezier);	   bezier   = NULL; }
	 if (tspline)   { BSfreecv(&bsrc,tspline);	   tspline = NULL; }
       	 if (spline && (inspline==NULL)) {
			om$dealloc(ptr=spline);           spline   = NULL; }
         if (spline_pnts)  {
			om$dealloc(ptr=spline_pnts);   spline_pnts = NULL; }
         if (spline_params){
			om$dealloc(ptr=spline_params); spline_params = NULL; }

	__DBGpr_int( "ret is ",ret0 );
	__DBGpr_int( "l_ret", l_ret );



	End
	return ( ret0 );

}	// translate bs curve

method ConvertCompCurve ( 
	struct GRid  *	GraphicObj;	// composite curve to convert
	IGRint  	FindAttrs 		// attribute for special case
			)
{

 IGRint		ret = OM_E_INVARG,
		kc		=0,
		loc_crv_count	=0;
 IGRlong	l_ret	= MSFAIL;
struct GRid     *crv_ids = NULL;    // array of IDs for comp curve components
struct GRmd_env	md_info;


  SetProc( ConvertCompCurve ); Begin

  if ( ! GraphicObj ) goto wrapup;

  md_info = me->Loc_env.mod_env;

  if ( FindAttrs != 2 ) {
       ret = om$send (msg = message GRowner.GRget_number_components(&l_ret,
								&loc_crv_count),
			senderid = NULL_OBJID,
                      targetid = GraphicObj->objid, targetos = GraphicObj->osnum);

	__CheckRC( ret, l_ret, "GRowner.GRget_number_components",wrapup );
	__DBGpr_int(" ccv nb comp", loc_crv_count );

       if ( !loc_crv_count  )
       {
	 __DBGpr_com("Unable to locate composite curve components ");
	 goto wrapup;
       }


        //  Allocate an array for the components' ids


       crv_ids = (struct GRid *) om$malloc( size = 
					loc_crv_count * sizeof( struct GRid ) );

        // Get the component's ids


	__DBGpr_int(" FindAttrs : ", FindAttrs );
       ret = om$send (msg = message GRowner.GRget_components(&l_ret, &md_info,
								crv_ids, 
								loc_crv_count, 
								&loc_crv_count,
								0, OM_K_MAXINT),
		senderid = NULL_OBJID,
                targetid = GraphicObj->objid,
		targetos = GraphicObj->osnum);

	__CheckRC( ret, l_ret, "GRowner.GRget_number_components",wrapup );
  }

  else {	// just one object?
	crv_ids = (struct GRid *) om$malloc( structure =  struct GRid  );
	crv_ids[0] 	= *GraphicObj;
	loc_crv_count	= 1;
  }


  for ( kc=0; kc<loc_crv_count; ++kc ){

	__DBGpr_obj(" current crv ", crv_ids[kc] );

	if( FindAttrs && FindAttrs != 2 ) {
	   int NumAtts = 0 ;
	   om$send( msg = message VLcoToAlCmd.GetAttribOfObj( crv_ids[kc],
								&NumAtts ),
		     targetid = my_id );
	}


        // Find then process geometry 

	ret=om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(&crv_ids[kc],
								   0 ),
		     	targetid = my_id );

	__CheckRC( ret, 1, "findType..", wrapup );

   } // end for on kc<loc_crv_count

wrapup:
	End
	if( crv_ids ) { om$dealloc(ptr=crv_ids); crv_ids = NULL ; }

	return (ret);
}	// convert composite curve

//===========================================================================*
//		check type of object, then call appropriate conversion method*
//===========================================================================*

method FindTypeThenConvert( 
	struct GRid	*InputObj ;		// object to look at
	IGRint		FindAttrs 		// look for special attributes
			)
{


 IGRint		ret0 = OM_E_INVARG;
 IGRlong	l_ret= MSFAIL;
 OMuword	ids_cl;		// classe id of the current object

 struct	IGRbsp_curve  *	tmpCurv	=	NULL;	// geom of curve to find cusps

 struct GRid GraphicObj ;

 SetProc( FindTypeThenConvert); Begin

	if ( !InputObj ) goto ret_error_exit;

	__DBGpr_obj( "trying to convert", (* InputObj) );

#ifdef vsDEBUG
	{
        IGRchar classname[80];
        	ret0 = om$get_classname( osnum        =   InputObj->osnum,
                        objid           =   InputObj->objid,
                        classname       = classname ) ;
        __CheckRC( ret0, 1, "get_classname", ret_error_exit );
        __DBGpr_str( "classname", classname );
	}
#endif

	if( FindAttrs ) { 
	   int	NumAtts = -1 ;			// just the attributes
	   ret0 = om$send( msg = message VLcoToAlCmd.GetAttribOfObj( *InputObj,
								     &NumAtts ),
		     targetid = my_id );
		CheckRC( ret0, 1 );
	}


   {	// get the real graphic object

	  GRclassid InputClass ;
 	  ret0 = om$get_classid( osnum		=   InputObj->osnum,
				objid		=   InputObj->objid,
				p_classid	= &InputClass ) ;
	  __CheckRC( ret0, 1, "FT:input get_classid", ret_error_exit);

 	  if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id ,
			      	      subclassid =InputClass) == OM_S_SUCCESS) {

		struct GRid TmpObj ;

	     __DBGpr_obj( "FindType before return_go ", *  InputObj );

             ret0 = om$send( msg = message NDnode.ASreturn_go(
                                        &TmpObj ,
 					&(me->RefMatType),
 					me->RefMatrix ),
                       senderid = NULL_OBJID,
                       targetid =   InputObj->objid,
                       targetos =   InputObj->osnum );

	     if( !( 1 & ret0 ) ){
			CheckRC( ret0, 1 ) ;
			ids_cl = InputClass ;
   			GraphicObj = *InputObj ;	// work on copy of input
	     }
	     else {
		GraphicObj = TmpObj ;
     		ret0 = om$get_classid(	osnum		= GraphicObj . osnum,
					objid		= GraphicObj . objid,
					p_classid	= &ids_cl	) ;
		__CheckRC( ret0, 1, "obj get_classid", ret_error_exit);
	     }

	  } // if its a pretend

	  else {
		__DBGpr_obj( " obj is not a subclass of ACpretend", *InputObj);
		ids_cl = InputClass ;
   		GraphicObj = *InputObj ;	// work on copy of input
	  }

	} // end else get real graphic object 


        // Process geometry 

     	if( 	om$is_ancestry_valid( superclassid = OPP_GRlinestr_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS){

		 __DBGpr_com( "Its a LINESTRING " );

	   ret0 = om$send(msg = message GRvg.GRgenabsg(	&l_ret, 
							&(me->RefMatType ),
							me->RefMatrix,
							(IGRchar**)&tmpCurv ),
			senderid = NULL_OBJID,
                       targetid = GraphicObj .objid,
                       targetos = GraphicObj .osnum);
	   __CheckRC( ret0, l_ret, "GRgenabs", ret_error_exit );

	   if ( !me->circleapprox || tmpCurv->num_poles < 3 ) {

		ret0=om$send(msg = message VLcoToAlCmd.TranslateLine(GraphicObj),
		     	targetid = my_id );
		 __CheckRC( ret0, 1, "TranslateLine", ret_error_exit );

	   }
	   else { // if approximation circulaire

	  	ret0 = om$send( msg = message VLcoToAlCmd.LineStrToCurve (
								    &GraphicObj,
								    NULL ),
				targetid = my_id );
		__CheckRC( ret0, 1, "LineStrToCurve", ret_error_exit );

	   } 		// if approximation

        }  	// if linestring
     	else if( om$is_ancestry_valid( superclassid = OPP_GRcompcurve_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS){

	       ret0=om$send(msg = message VLcoToAlCmd.ConvertCompCurve(&GraphicObj,
									0     ),
		     targetid = my_id );

		 __CheckRC( ret0, 1, "ConvertCompCurve", ret_error_exit );
        }
     	else if(  om$is_ancestry_valid( superclassid = OPP_GRlineseg_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS){

	     ret0=om$send( msg = message VLcoToAlCmd.TranslateLine(GraphicObj ),
		     	targetid = my_id );

		 __CheckRC( ret0, 1, "TranslateLine", ret_error_exit );
        }
        else if(om$is_ancestry_valid( superclassid = OPP_GRcirarc_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS){


	  ret0 = om$send( msg = message VLcoToAlCmd.TranslateArc(GraphicObj  ),
		     targetid = my_id );

	  __CheckRC( ret0, 1, "TranslateArc", ret_error_exit );
        }
        else if(om$is_ancestry_valid( superclassid = OPP_GRcircle_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS){

	 ret0 = om$send( msg = message VLcoToAlCmd.TranslateCircle(GraphicObj  ),
		    targetid = my_id );

	  __CheckRC( ret0, 1, "TranslateCircle", ret_error_exit );
        }
        else if(om$is_ancestry_valid( superclassid = OPP_GRellarc_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS ){

	  ret0=om$send(msg = message VLcoToAlCmd.TranslateEllipArc( GraphicObj ),
		    	targetid = my_id );

	  __CheckRC( ret0, 1, "TranslateEllipArc", ret_error_exit );
        }
        else if(om$is_ancestry_valid( superclassid = OPP_GRbspline_class_id ,
				      subclassid   = ids_cl ) == OM_S_SUCCESS){

	  ret0 = om$send( msg = message VLcoToAlCmd.TranslateBSCurve(
						&GraphicObj  ,
						(struct IGRbsp_curve *) NULL ),
		     targetid = my_id );

	  __CheckRC( ret0, 1, "TranslateBSCurve ", ret_error_exit );
       	}
        else{
/*
         sprintf(me->status,"Unknown element type %d\n",GraphicObj . objid);
	 ret0 = om$send( msg = message VLcoToAlCmd.status(me->status ),
		targetid = my_id );
	 __DBGpr_str( "UNKNOWN", me->status ) ;
	 if (me->LogFileId) {
		   fprintf((FILE*)me->LogFileId,"%s\n", me->status );
	 }
*/

       }	// else unknown element type 


ret_error_exit :

	End
	return ret0;

}	// find type then convert

method ProducePascalForm ( 

IGRint		order;
IGRdouble	*tpas )
{
  int		  status = OM_S_SUCCESS;


	IGRdouble RO, RI;
	IGRint	  i;


	tpas[0] = 1.0E0;

	if( order == 2 ) goto wrapup;

	RO = order;

	for(i=2;i<=order-1;i=i+1){
           RI = i-1;
	   tpas[i-1] = tpas[i-2] * ( RO - RI ) / RI;
	}

wrapup:

	tpas[order-1] = 1.0E0;

#ifdef CONVTOALDEBUG
	for(i=0;i<order;i=i+1)
			printf("ProducePascalForm[",i,"] = ", tpas[i],"\n");
#endif
	

  return status;
}	// Pascal form

method pococv_pcr ( 

IGRint		idim;
IGRdouble	*poles;
IGRint		order;
IGRdouble	*coefs )
{
  int		  status = OM_S_SUCCESS;


	IGRint		i, j, k, deg, kst, ked;
	IGRdouble	t_ProducePascalForm[31];

SetProc( popocv );	Begin

	if ( !poles || !coefs ) goto wrapup;

	deg = order - 1;
	ked = idim * order;

#ifdef CONVTOALDEBUG
		for(i=0; i<idim*order; i=i+idim ){
		   printf("poles[%d]:",i/idim);
		   for(k=i;k<(i+idim);k=k+1)
			printf("%f",poles[k] );
		   printf("\n");
		}
#endif

	for(j=0;j<ked;j=j+1) coefs[j] = poles[j];

	for(i=0;i<idim;i=i+1){

	   for(j=0;j<deg;j=j+1){

	      kst = deg * idim + i;
		__DBGpr_int(" kst = ",kst );

	      for(k=j;k<deg;k=k+1){
		coefs[kst] = coefs[kst] - coefs[kst-idim];
		kst = kst - idim;
	      }
	   }
	}

	if( order <= 2 ) goto wrapup;
	
	status = om$send ( msg = message VLcoToAlCmd.ProducePascalForm(order,
							   t_ProducePascalForm),
	     targetid = my_id );

	for(i=1;i<deg;i=i+1){
		k = idim * i;
		ked = k + idim;
		for(j=k;j<ked;j=j+1)
				coefs[j] = coefs[j] * t_ProducePascalForm[i]; 
	}
	
/*
		for(i=0; i<idim*order; i=i+idim ){
		   printf("coef[",i/idim,"] = ");
		   for(k=i;k<(i+idim);k=k+1)
			printf("%f",coefs[k] );
		   printf("\n");
		}
*/

wrapup:
	End
	return status ;
}	// pole convert

//===========================================================================* 
//	given a lineString as a data structure or object id, try to approximate
//	with a bspline of the active order, then break the curve at any cusps
//	( knuckles ) and process each subcurve.	*/
//===========================================================================* 

method LineStrToCurve (
	struct GRid *		inLineString;	// IN:	lineString id or
	struct IGRbsp_curve  *	inLSbyGeom	// IN:	lineString by geom
			)

{

	BSrc		retbs = BSFAIL;
	IGRint		ii,			// incremental integer
			ret0  = OM_E_INVARG,
			num_cusps = 0,

		*	cusps	  = NULL;	// list of cusp indexes

	IGRuchar	buffer; // for EMSdpb functions
	IGRboolean	polesAligned = FALSE,
			u_periodic;

	IGRlong 	u_order = 0, // was short
			n_poles = 0,
			size = 0,
			l_ret	= MSFAIL;

	IGRdouble	tol	= 1.0;	// current chord height tolerance

	IGRpoint      *	poles	=	NULL;	// list of poles for curve
struct GRlc_info	lineString,		// linestring to create curve
		      *	LSptr	=	NULL;	// linestring ptr to above
struct GRvg_construct	cnst_list ;		// for construct of curve

struct	IGRbsp_curve  *	tmpCurv	=	NULL,	// geom of curve to find cusps
		      * subCurve=	NULL;	// a sub curve between cusps
		     
 struct GRid 		curv;			//used approximate linestring

	SetProc( LineStrToCurve );	Begin

	curv.objid	=	NULL_OBJID;

	if ( !inLineString && !inLSbyGeom ) goto ret_error_exit;

	ret0= EMdpb_get(
			&l_ret,
			EMSdpb_props,
			&buffer);
	__CheckRC(ret0, l_ret, "EMSdpb_props:u_period",ret_error_exit);

	if ((buffer & EMDPB_U_PERIODIC) && (u_order > 2))
			u_periodic = TRUE;
	else
			u_periodic = FALSE;

	curv.osnum = me->Current.md_id.osnum;
	curv.objid = NULL_OBJID;

        ret0= om$construct(
                                classname       = "GRbcsubbc",
                                osnum           = curv.osnum,
                                p_objid         = &curv.objid ) ;

        __DBGpr_obj( "ConGeom constructed curv ", curv );
        __CheckRC(ret0, 1, "OMconstruct curv", ret_error_exit ) ;

	if ( inLSbyGeom ) {
		if (inLSbyGeom->rational) {
			__DBGpr_com( "Rational lineString?" );
			ret0 =	BSunwght_p(
					&retbs,
					inLSbyGeom->poles,
					inLSbyGeom->weights,
					&inLSbyGeom->num_poles,
					inLSbyGeom->poles);
			retbs_test;
		} // if (inLSbyGeom->rational)
		n_poles = inLSbyGeom->num_poles;
		poles   = (IGRpoint *) inLSbyGeom->poles;
	}

	else {		// by object
		lineString.located_obj	= *inLineString;
		lineString.module_info	= me->Loc_env.mod_env;
		LSptr			= &lineString;
	}

	cnst_list		= me->cst;
	cnst_list.geometry	= NULL;
	u_order			= 3 ;
	ret0 = om$send(msg = message GRbcsubbc.EMcurve_by_poles(
								u_order,
								u_periodic,
								n_poles,
								poles,
								LSptr,
								&cnst_list ),
			senderid = NULL_OBJID,
                       targetid = curv.objid,
                       targetos = curv.osnum);
	__CheckRC( ret0, *cnst_list.msg , "EMcurve_by_poles:", ret_error_exit );

	ret0 = om$send(msg = message GRvg.GRgetsize(	&l_ret, 
							&(me->RefMatType ),
							me->RefMatrix,
							&size ),
			senderid = NULL_OBJID,
                       targetid = curv.objid,
                       targetos = curv.osnum);
	__CheckRC( ret0, l_ret, "GRgetsize", ret_error_exit );

	tmpCurv = (struct IGRbsp_curve *) om$malloc( size = size );
	if ( !tmpCurv ) {
		ret0	= OM_E_NODYNMEM;
		goto ret_error_exit;
	}
	ret0 = om$send(msg = message GRvg.GRgetgeom(	&l_ret, 
							&(me->RefMatType ),
							me->RefMatrix,
							(IGRchar*)tmpCurv ),
			senderid = NULL_OBJID,
                       targetid = curv.objid,
                       targetos = curv.osnum);
	__CheckRC( ret0, l_ret, "GRgenabs", ret_error_exit );

		// once we have the geometry with transfomation matrix applied
		// it should not be used again, so set to identity

	if ( me->RefMatType != MAIDMX ) {
		ret0 = MAidmx( &l_ret, me->RefMatrix ) ;
		me->RefMatType = MAIDMX ;
	}

     	BSxtractpar(&retbs, BSTOLCHRDHT, &tol );
	retbs_test;
	tol *= tol;
  	__DBGpr_dbl("tolerance ",tol );

	POcvFndCusps(tmpCurv, tol, &num_cusps, &cusps, &polesAligned, &retbs );
		//	retbs_test;
	__DBGpr_int( "cusps gave ", num_cusps  );
	__DBGpr_int( "polesAligned", polesAligned );
	__DBGpr_int( "retBS", retbs );
	__DBGpr_int( "cusps", cusps );

	if ( retbs != BSSUCC || polesAligned || !cusps ) {

		__DBGpr_int( "FndCusps failed", inLSbyGeom );

//		if ( inLSbyGeom ) {

			ret0=om$send(msg = message VLcoToAlCmd.TranslateBSCurve(
								NULL,
								tmpCurv ),
				targetid = my_id );
			__CheckRC(ret0, 1, "TranslateBSCurve", ret_error_exit );

//		}
//		else {		// by object
//			ret0= om$send( msg = message VLcoToAlCmd.TranslateLine(
//								*inLineString ),
//				  targetid = my_id );
//			__CheckRC( ret0, 1, "TranslateLine", ret_error_exit );
//		}
	}
	else { 		// found the cusps

	__DBGpr_int( "found cusps", inLSbyGeom );

		BSalloccv(	tmpCurv->order, tmpCurv->num_poles, //IN
				tmpCurv->rational,
				tmpCurv->num_boundaries,
			   	&subCurve, &retbs );		 //OUT

		retbs_test;

	__DBGpr_int( "after BSalloc", retbs );

		for ( ii=0; ii<=num_cusps ; ++ii ) {

		    POcvFrmPoles( tmpCurv, (IGRshort) 1, (cusps[ii]),
					(cusps[ii+1]), subCurve, &retbs );
		    retbs_test;

	__DBGpr_int( "after POcvFrmPoles", retbs );

	  	    ret0 = om$send( msg = message VLcoToAlCmd.TranslateBSCurve(
								NULL,
								subCurve ),
				targetid = my_id );
		    __CheckRC( ret0, 1, "TranslateBSCurve", ret_error_exit );

		}	// for cusps

	} // else found cusps

	ret0 = OM_S_SUCCESS;

ret_error_exit:

	if ( tmpCurv ) om$dealloc( ptr = tmpCurv );
	if ( subCurve ) BSfreecv( &retbs, subCurve );
	_FREE( cusps );

#ifndef vsDEBUG
	if ( curv.objid != NULL_OBJID ) {
	   retbs = om$send(msg = message GRgraphics.GRdelete(	&l_ret,
							&me->Current ),
			senderid = NULL_OBJID,
			targetid = curv.objid,
			targetos = curv.osnum );
	    CheckRC( 1, l_ret );
	}
#endif

	End
	return ( ret0 );

}	// end method LineStrToCurve


//===========================================================================*
//	given a bsp_curve as a data structure or object id, try to approximate
//	with a series of arcs and lines within the active c.h.t.	*
//===========================================================================*

method ApplyCirApprox ( 
  struct GRobj_env  *	TEMP;		// obj env of incoming curve or
  struct IGRbsp_curve * inspline	// geom of incoming curve
			)
{
  IGRint		nb_arcs = 0,
			ii	= 0,
			ret0	= OM_E_INVARG;		// OM return code

  IGRlong		rtmsg	= MSFAIL;		// parameter rc
  BSrc			retbs	= BSFAIL;		// bs rc
  
  IGRdouble		err_max = 0.01,			// error to work to
  			min_len = 1.0E30 ,		// smallest size
  			tol = 1.0E6;			// working tolerance

  struct GRid	*	COMP = NULL;	// the list of arcs etc
  struct GRid		EdgeMacId;



	SetProc( ApplyCirApprox );	Begin

	if ( !TEMP && !inspline ) goto ret_error_exit ;

     	BSxtractpar(&retbs, BSTOLCHRDHT, &tol );
	retbs_test;
  	__DBGpr_dbl("tolerance ",tol );

	GFnew_cir_app(&rtmsg, inspline, TEMP, tol, &me->cst, &COMP, 
		   	&nb_arcs, &err_max, &min_len );

	if( rtmsg == MANONPLANAR ) {
		__DBGpr_com( "VLNONPLANAR" );
		if (me->LogFileId) {
		   fprintf((FILE*)me->LogFileId,"found a non-flat curve\n" );
		}
		goto ret_error_exit;
	}
	else if ( !nb_arcs || !COMP ){
	   __DBGpr_int( "GFCIR_APP FAILED! num \n", nb_arcs );
	   __DBGpr_str( "failed on plate",me->name );
	   if (me->LogFileId)
	      fprintf((FILE*)me->LogFileId,"circular approximation failed\n" );
	   goto ret_error_exit;
	}
	else {
		__DBGpr_int( "GF produced ", nb_arcs );
		__DBGpr_int( "rtmsg", rtmsg );
	}

          EdgeMacId = me->edgeAt.macOcId ; 

	for ( ii=0; ii< nb_arcs; ++ii ) {
		
	  __DBGpr_obj( "GF's comp", COMP[ii] );

	  me->edgeAt.macOcId =  EdgeMacId;

	  ret0 =om$send(msg = message VLcoToAlCmd.FindTypeThenConvert(&COMP[ii],
									0 ),
			targetid = my_id );
	  CheckRC( ret0, 1 );

#ifndef vsDEBUG
	  ret0 =	om$send(msg = message GRgraphics.GRdelete( &rtmsg,
							&me->Current ),
			senderid = NULL_OBJID,
			targetid = COMP[ii].objid,
			targetos = COMP[ii].osnum );
	  CheckRC( ret0, rtmsg );
#endif

	} // for all sub curves

ret_error_exit:

	if ( COMP )   {om$dealloc(ptr= COMP );            COMP    = NULL; } 

	End
	return ret0;

}		// end circular approximation 

end implementation VLcoToAlCmd;
