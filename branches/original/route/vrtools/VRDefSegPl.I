/* $Id: VRDefSegPl.I,v 1.7 2002/04/10 20:44:44 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRDefSegPl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDefSegPl.I,v $
 *	Revision 1.7  2002/04/10 20:44:44  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.6  2001/10/29 17:47:33  anand
 *	Normalise the vector before taking its dot product with
 *	another (Less error prone when testing for orthogonality).
 *	
 *	Revision 1.5  2001/10/25 19:30:34  anand
 *	JTS TRs 5649, 5651 and 5652.
 *	
 *	Revision 1.4  2001/03/08 23:42:58  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.3  2001/02/20 01:17:40  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:15  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:31:36  pinnacle
# Created: route/vrtools/VRDefSegPl.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/11  06:09:42  pinnacle
# Replaced: vrtools/VRDefSegPl.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/18  00:30:14  pinnacle
# Replaced: vrtools/VRDefSegPl.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb		Add prototypes
	03/11/98   Alwin	Forced to form VRcompoint object having six
				planes as it's parent. To ensure the proper
				propagation of the plane movement's to the
				neighbouring segments. TR179800618, TR179800044
 *      03/08/01   law          dbg prints
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
class implementation Root;


#include <math.h>
#include <malloc.h>
#include <stdio.h>
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "AS_status.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "vrdbgmacros.h"

#include "VRMath.h"

#define AS_DEBUG


from	GRvg		import GRdetplane;
from	GRgencs		import GRgetmatrix;
from	NDnode		import NDplace;

extern IGRint		GRabsg_del_by_objid();

extern GRclassid OPP_VRcompoint_class_id;


/******************************************************************************/

VRDefineSegPlanes
	( sts, end_stat, GRid_end_pl, str0, str1, ext_flag, ext_cre_flag, md_env, GRid_new_pl )
              

IGRlong	*sts;		   /* return code *sts = 1 SUCCES	      	*/

IGRshort end_stat;	   /* argument to tell if the GRid_end_pl are 	*/
			   /* coming from a true nozle or dangling.   	*/
			   /*					      	*/
                           /* end_stat = 0:		              	*/
			   /*   start from free space                 	*/
			   /*					      	*/
			   /* end_stat = 2:			      	*/
			   /*   start = planes, end free              	*/
			   /*					      	*/
			   /* end_stat = 4:			      	*/
			   /*   start = free, end planes              	*/
			   /*					      	*/
                           /* end_stat = 5:                           	*/
                           /*   strat = planes, end = planes          	*/
			   /*						*/
struct 	GRid *GRid_end_pl; /* GRids of the planes wich define the left	*/
			   /* and right segment and its boundary.     	*/
			   /* for the right end:                      	*/

IGRdouble	*str0;     /* segment end points		      	*/
IGRdouble	*str1;     /* segment end points		      	*/


IGRboolean	ext_flag;  /* boolean to inform if we share planes or 	*/
			   /* we create constrains. FALSE means constrain */
			   /* no shared planes.                    	*/

IGRboolean	ext_cre_flag; 
			   /* needed for connected component          	*/
			   /* TRUE : given planes are complex component */
			   /* planes.					*/

struct 	GRmd_env *md_env;  /* module info			      	*/

struct 	GRid		*GRid_new_pl; 
			   /* list of new constructed planes 	      	*/

/*.VRDefineSegPlanes */
{
  IGRint		i, rc;
  IGRboolean      	free_dang_flag=FALSE;
  IGRdouble		string[6];
  IGRdouble		xx;	
  struct 	GRid	GRid_dum;

  SetProc( Fn VRDefineSegPlanes ); Begin 

  *sts = MSSUCC;

  /*"end_stat = %d\n", end_stat */

  for(i=0; i<3; i++ )
  {
  	string[i]   = str0[i];
  	string[i+3] = str1[i];
  }
  
  /*^ for(i=0; i<6; i=i+3 ) printf("str = %f %f %f\n", string[i],string[i+1], string[i+2] ); */

  for( i=0; i<4; i++ )
  {
    	GRid_new_pl[i].objid = NULL_OBJID;
	GRid_new_pl[i].osnum = md_env->md_id.osnum;
  }			

  switch( end_stat )
  {
	case 0:	/*| Free .. Free */
 
		__DBGpr_com( " Reached Free .. Free case " );

        	/*"end_pl = %d\n", GRid_end_pl[0].objid */
		free_free( &rc, GRid_end_pl, md_env, string, GRid_new_pl );
		break;

	case 4:	/*| Free .. Planes */

		__DBGpr_com( " Reached Free .. Planes case " );

		for(i=0;i<3;i=i+1)
		{
	    		xx          = string[i];
	    		string[i]   = string[i+3];
	    		string[i+3] = xx;
		}
        
		free_dang_flag = TRUE;

	case 2: 	
		__DBGpr_obj("Case 2-endplane0",GRid_end_pl[0]);
		__DBGpr_obj("Case 2-endplane1",GRid_end_pl[1]);
		__DBGpr_obj("Case 2-endplane2",GRid_end_pl[2]);
        	/*^
            	printf("end_pl = %d %d %d\n", 	GRid_end_pl[0].objid,
                                          	GRid_end_pl[1].objid,
                                          	GRid_end_pl[2].objid  );
        	*/

		dang_free( &rc, GRid_end_pl, md_env, string, ext_flag, GRid_new_pl );

		if( free_dang_flag == TRUE )
		{
                	/*| free_dang_flag is TRUE */

			GRid_dum = GRid_new_pl[0];
			GRid_new_pl[0] = GRid_new_pl[3];
			GRid_new_pl[3] = GRid_dum ;
        	}

		break;

	case 5:	/*| plane .. Plane */

		__DBGpr_com( "  Reached Plane .. Plane " );

        	/*^
            		printf("end_pl = %d %d %d\n", 	GRid_end_pl[0].objid,
                                          		GRid_end_pl[1].objid,
                                          		GRid_end_pl[2].objid  );
            		printf("end_pl = %d %d %d\n", 	GRid_end_pl[3].objid,
                                          		GRid_end_pl[4].objid,
                                          		GRid_end_pl[5].objid  );
        	*/

		for( i=4; i<10; i++ )
  		{
    			GRid_new_pl[i].objid = NULL_OBJID;
			GRid_new_pl[i].osnum = md_env->md_id.osnum;
  		}			

		dang_dang( &rc, GRid_end_pl, md_env, string, GRid_new_pl, ext_flag, ext_cre_flag );
		break;
		   
	default: *sts = MSFAIL;
  }

  End
  return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* given an origin and a normal of a plane, this function create the assoc 
/* VRplane object
/*
/**/

cre_plan( origin, normal, md_env, GRid_plan )

IGRdouble 		*origin;	/* origin of the plane		*/
IGRdouble 		*normal;	/* normal of the plane		*/
struct 	GRmd_env	*md_env;      	/* the module info		*/
struct 	GRid		*GRid_plan;	/* objid and osnum of the plan  */

/*.cre_plan */
{
  IGRlong     			status=OM_S_SUCCESS;
  IGRdouble			PlaneData[6];
  struct	GRas		assoc_list;
  SetProc( Fn cre_plan ); Begin 

  /*"origin = %f %f %f\n", origin[0], origin[1], origin[2] */
  /*"normal = %f %f %f\n", normal[0], normal[1], normal[2] */

  PlaneData[0] = origin[0];
  PlaneData[1] = origin[1];
  PlaneData[2] = origin[2];
  PlaneData[3] = normal[0];
  PlaneData[4] = normal[1];
  PlaneData[5] = normal[2];

  assoc_list.as_attr = ( IGRchar * ) PlaneData;

  GRid_plan->osnum = md_env->md_id.osnum;
  status = om$construct(	classname 	= "VRplane", 
	                	p_objid   	= &GRid_plan->objid, 
         	        	osnum     	= GRid_plan->osnum,
                        	msg 		= message NDnode.NDplace( &assoc_list, md_env, NULL ) );

  /*"cre_plan = %d\n", GRid_plan->objid */
  End
  return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* Given num_equi_pl template ( VRplanes ), this function create the assoc 
/* VRcompoint object.  The VRcompoint constrain planes to go throught the same 
/* point.
/*
/**/

place_cons( sts, GRid_end_pl, md_env, num_equi_pl, equi_pl )


IGRlong			*sts;
struct GRid		*GRid_end_pl;
struct GRmd_env		*md_env;
IGRint			num_equi_pl;
IGRint			*equi_pl;

/*.place_cons */
{
	IGRboolean	SharedPlane;
	IGRint		ind_found;
	IGRint		i, j;
	IGRlong		status;
	struct	GRas	assoc_list;
	struct	GRid	plane_list[6];
	struct  GRid	ConstId;

	SetProc( Fn place_cons ); Begin 

	*sts = MSSUCC;

	__DBGpr_int( " Nb of Planes being shared ", num_equi_pl );

	if( equi_pl == NULL )
	{
	       	assoc_list.num_parents = num_equi_pl;
	       	assoc_list.parents     = GRid_end_pl;	
	}
	else
	{
		if( num_equi_pl == 0 )
		{
			/*| --- We place a constraint on the 6 planes	--- */
  	       		assoc_list.num_parents = 6;
	       		assoc_list.parents     = GRid_end_pl;
		}
		else if( num_equi_pl == 1 )
		{
	        	assoc_list.num_parents = 0;

			for( i=0; i<3; i++ )
			{
			   	is_founded( equi_pl, 0, num_equi_pl, i, &ind_found );
		   		if( ind_found == -1 )
				{
		       			plane_list[assoc_list.num_parents ] = GRid_end_pl[i];
		       			assoc_list.num_parents = assoc_list.num_parents + 1;
		   		}
			}

	        	for( i=3; i<6; i++ )
			{
		        	for( j=0, SharedPlane=FALSE; j<3; j++ )
				{
					if( GRid_end_pl[i].objid == GRid_end_pl[j].objid )
					{
						SharedPlane = TRUE;
						break;
					}
				}

				if( !SharedPlane )
				{					
					plane_list[assoc_list.num_parents] = GRid_end_pl[i];
					assoc_list.num_parents = assoc_list.num_parents + 1;
				}
			}

			/*"We place a constraint on %d planes\n", assoc_list.num_parents */

	        	assoc_list.parents = plane_list;
		}
		else
		{
			/*| more than one shared plane ==> all planes can be shared */
			__DBGpr_com( " more than one shared plane " );
			End
			return OM_S_SUCCESS;
		}
	}

	/*^ 
		for(j=0; j<assoc_list.num_parents; j++)
      				printf("list plane = %d\n", assoc_list.parents[j].objid );
	*/

       	ConstId.osnum = md_env->md_id.osnum;
       	status = om$construct(	classid = OPP_VRcompoint_class_id,
   		       		p_objid = &ConstId.objid,
		                osnum   = ConstId.osnum,
                                msg     = message NDnode.NDplace( &assoc_list, NULL, NULL ) );
	as$status( action = RET_STATUS ); 

        __DBGpr_obj( " created constraint ", ConstId );

	End
	return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* given two array of planes' structures, this function check plane's 
/* coincidence. Two planes are coincident if their normals are colinear and 
/* thier origins are in the same plane.
/*
/**/

check_coin( sts, num_pl, master_pl, slave_pl, num_com_pl, ind_com_pl ) 

IGRlong		*sts;	     /* return code success if rc = BSSUCC 	     */
IGRint		num_pl;      /* number of planes to test		     */
struct IGRplane *master_pl;  /* list of master planes 		  	     */
struct IGRplane *slave_pl;   /* list slave planes  			     */
IGRint 		*num_com_pl; /* number of common planes 		     */
IGRint          *ind_com_pl; /* table containing the index                   */

/*.check_coin*/
{
    IGRint		i,k;
    IGRdouble	vec[3];
    IGRlong		retcode;

    SetProc( Fn check_coin ); Begin 
	*sts = MSSUCC;
    __DBGpr_int("number planes to check",num_pl);

    *num_com_pl = 0;

    for( i=0; i<num_pl; i++ )
    {
//	printf("\tmaster_pl[%d] = %lf %lf %lf\n",i,master_pl[i].normal[0],master_pl[i].normal[1], master_pl[i].normal[2] );
//	printf("\tmaster_pt[%d] = %lf %lf %lf\n",i,master_pl[i].point[0],master_pl[i].point[1], master_pl[i].point[2] );

	ind_com_pl[*num_com_pl*2]   = -1;
	ind_com_pl[*num_com_pl*2+1] = -1;

	for( k=0; k<num_pl; k++ )
	{
//	    printf("\tslave_pl[%d] = %lf %lf %lf\n",k,slave_pl[k].normal[0],slave_pl[k].normal[1],slave_pl[k].normal[2] );
//	    printf("\tslave_pt[%d] = %lf %lf %lf\n",k,slave_pl[k].point[0],slave_pl[k].point[1], slave_pl[k].point[2] );

	    BScrossp( &retcode, &master_pl[i].normal[0], &slave_pl[k].normal[0], vec );
	    __DBGpr_vec(" Cross Prd of normals", vec );
	    if( BSlenvec( &retcode, vec ) < VRGetTol(VR_LENGTH_TOL) )
	    {
		BSmkvec( &retcode, vec, &master_pl[i].point[0], &slave_pl[k].point[0] );
		__DBGpr_vec("a vector between points on master and slave planes", vec );
		BSnorvec( &retcode, vec );
		/*"vec = %f %f %f\n", vec[0], vec[1], vec[2] */
//		printf("\nDOT PRODUCT %le\n",BSdotp( &retcode, vec, &master_pl[i].normal[0] ) ); 

		if( fabs( BSdotp( &retcode, vec, &master_pl[i].normal[0] ) ) <= VRGetTol(VR_DOTPROD_TOL) )
		{
		    __DBGpr_com("above vector is perpendicular to master's normal");
		    ind_com_pl[*num_com_pl*2] = i;
		    __DBGpr_int(" Index of master plane", i);
		    ind_com_pl[*num_com_pl*2+1] = k;
		    __DBGpr_int(" Index of slave plane", k);
		    *num_com_pl = *num_com_pl + 1;
		    /*"nombre de plans communs : %d\n", *num_com_pl */
		    break;
		}
	    }
	}
    }

    /*"nombre de plans communs : %d\n", *num_com_pl */
    __DBGpr_int("Number of common planes",*num_com_pl);
    End
	return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* given the two end points of a segment and an array of planes' structures, 
/* this function check if this segment is belong one or more given planes
/*
/**/

seg_belong_planes( str, num_planes, planes, WitchPlanes )

IGRdouble	*str;	  	/* the xyz coordinates end points of the line*/
IGRint		num_planes;  	/* number of planes used to check	*/
struct IGRplane   *planes;     	/* the plane data			*/
IGRint		*WitchPlanes;  	/* switch stat				*/

/*.seg_belong_planes */
{
	IGRint		i;
        IGRlong		rc;
	IGRdouble	vt[3];
	SetProc( Fn seg_belong_planes ); Begin 

	*WitchPlanes  = 0;

	for ( i=0; i<num_planes; i++ )
	{
		/*"pl %d pt = %f %f %f\n", i, planes[i].point[0],planes[i].point[1],planes[i].point[2] */

	     	BSmkvec( &rc, vt, &str[0], &planes[i].point[0] );

	     	if( fabs( BSdotp( &rc, vt, &planes[i].normal[0] ) ) < VRGetTol(VR_DOTPROD_TOL) )
		{
	     		BSmkvec( &rc, vt, &str[3], &planes[i].point[0] );

			if( fabs( BSdotp(&rc, vt, &planes[i].normal[0] ) ) < VRGetTol(VR_DOTPROD_TOL) )
			{
			    __DBGpr_int(" Both seg end points lie on plane with index", i);
		  		if( i == 0 ) *WitchPlanes = 1;
		  		else         *WitchPlanes = *WitchPlanes + 2*i;
			}
	     	}
	}

        End
	return OM_S_SUCCESS;
}


/******************************************************************************/
/* 
/* Given an index, this function search if it is in the given array 
/*
/**/

is_founded( array, start_search, end_search, ind_to_search, ind_founded )

IGRint	*array;		/* array where to search 			     */ 
IGRint  start_search;   /* start search loop				     */
IGRint  end_search;     /* end of the loop				     */
IGRint	ind_to_search;  /* integer to search in this aaray                   */
IGRint  *ind_founded;   /* index of the founded element modulo 2             */
			/* -1 if nothing founded			     */

{
IGRint i;

	*ind_founded = -1;

	for( i=start_search; i<2*end_search; i=i+2)
	{
	   	if( array[i] == ind_to_search )
		{
			*ind_founded = i;
			break;
	   	}
	}

	return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* given a referential, this function calcul the correcponding three planes 
/*
/**/

free_free( sts, GRid_end_pl, md_env, string, GRid_new_pl )

IGRlong			*sts;		/* return code *rc = 1 SUCCES 	     */
struct GRid	        *GRid_end_pl;   /* GRids of the coordinate system    */
struct GRmd_env		*md_env;	/* construction list		     */
IGRdouble		*string;   	/* xyz coordinates of the string     */
struct GRid	        *GRid_new_pl;   /* list of new constructed plans     */
/*.free_free*/
{
	IGRint		i;
	IGRlong		msg, rc=MSSUCC;
	IGRdouble	vecn[3], vcou[3], vcros[3];
	IGRmatrix	cs_matrix;

	/* ---  retrieve the matrix of the active coordinate system --- */
        SetProc( Func_free_free ); Begin
	*sts = MSSUCC;

  	om$send( msg      = message GRgencs.GRgetmatrix( &msg, cs_matrix ),
                 senderid = NULL_OBJID,
	  	 targetid = GRid_end_pl[0].objid,
	  	 targetos = GRid_end_pl[0].osnum );

	/*^
	   for( i=0; i<16; i=i+4 )
		     printf("m[%d] = %f ..m[%d] = %f .. m[%d] = %f .. m[%d] = %f\n",
					             i, cs_matrix[i], i+1, cs_matrix[i+1], i+2,
	             cs_matrix[i+2], i+3, cs_matrix[i+3] );
	*/

	BSmkvec( &rc, vcou, &string[0], &string[3] );
	BSnorvec( &rc, vcou );

	/*| ---  creation of the start boundary plane  --- */
	cre_plan( string, vcou, md_env, &GRid_new_pl[0] );

	/*| ---  creation of the end boundary plane  --- */
	cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

	/*| calcul normal of common and vertical planes */
	for ( i=0; i<16; i=i+4)
	{
  	     	BScrossp( &rc, vcou, &cs_matrix[i], vcros );
	     	if( BSdotp( &rc, vcros, vcros) > VRGetTol(VR_DOTPROD_TOL) )
		{
        		BScrossp( &rc, vcros, vcou, vecn );
			if( BSdotp( &rc, vecn, vecn ) > VRGetTol(VR_DOTPROD_TOL) ) break;
	     	}
	}

	BSnorvec( &rc, vcros );
	BSnorvec( &rc, vecn );

	/*| ---  creation of the common plane  --- */
	cre_plan( string, vcros, md_env, &GRid_new_pl[1] );

	/* ---  creation of the vertical plane  --- */
	cre_plan( string, vecn, md_env, &GRid_new_pl[2] );

        End
	return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* given two point and three planes, this function calcul the new four planes 
/* to create the next segment
/*
/**/

dang_free( sts, GRid_end_pl, md_env, string, cre_flag, GRid_new_pl )
	   
IGRlong			*sts;		/* return code *rc = 1 SUCCES 	     */
struct GRid	        *GRid_end_pl;   /* GRids of the coordinate system    */
struct GRmd_env		*md_env;	/* construction list		     */
IGRdouble		*string;   	/* xyz coordinates of the string     */
IGRboolean		cre_flag;       /* flag to tell if we create new     */
					/* or we do postabs		     */
struct GRid	        *GRid_new_pl;   /* list of new constructed plans     */

/*.dang_free */
{
	IGRint		 	i, BelongPlanesSwitch;
	IGRlong			msg, status, rc=MSSUCC;
	IGRdouble	 	vcou[3], vcros[3], vecn[3], vint[3], t_plan[18]; 
	struct GRid		plane_list[6];
	struct IGRplane		n_plans[3]; 

	SetProc( Fn dang_free ); Begin 

	*sts = MSSUCC;

	/*| ---  get the normal of the 3 GRid_end_pl  --- */
	for( i=0; i<3; i++ )
	{
		n_plans[i].point  = &t_plan[6*i];
		n_plans[i].normal = &t_plan[6*i+3];
  		om$send( msg      = message GRvg.GRdetplane
					( &msg, &md_env->md_env.matrix_type,
					  md_env->md_env.matrix, &n_plans[i] ),
                 	 senderid = NULL_OBJID,
		 	 targetid = GRid_end_pl[i].objid,
		 	 targetos = GRid_end_pl[i].osnum );
	}

	BSmkvec(&rc,vcou,&(string[0]), &(string[3]));
        BSnorvec( &rc, vcou );
	/*"vcou = %f %f %f\n", vcou[0], vcou[1], vcou[2] */

	/*| --- check if the new segment belongs one of the three planes  --- */

	seg_belong_planes( string, 3, &n_plans[0], &BelongPlanesSwitch );

        /*"BelongPlanesSwitch = %d\n", BelongPlanesSwitch */

	switch( BelongPlanesSwitch )
	{
		case 0:
			/*|====================================*/
			/*| we are in the skweed configuration */
			/*|====================================*/

			__DBGpr_com( " we are in the skewed configuration " );

			/*| ---  create the new start boundary plane  --- */
			cre_plan( string, vcou, md_env, &GRid_new_pl[0] );

			/*| ---  create the new common plane  --- */
	        	BScrossp( &rc, &n_plans[1].normal[0], &n_plans[2].normal[0],vint );
        		BScrossp(&rc,vint,vcou,vecn);
			BSnorvec(&rc,vecn);
			cre_plan( string, vecn, md_env, &GRid_new_pl[1] );

			/*| ---  create the new vertical plane  --- */
	        	BScrossp(&rc,vcou,vecn,vcros);
			BSnorvec(&rc,vcros);
			cre_plan( string, vcros, md_env, &GRid_new_pl[2] );

			/*| ---  create the end boundary plane  --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			if( cre_flag == FALSE )
			{
				/*| ---  we place the constraint to have six 
				planes passing by one point --- */

      				/* set assoc_list */

		       		for(i=0;i<3;i=i+1)
				{
			    		plane_list[i]   = GRid_end_pl[i];
					plane_list[i+3] = GRid_new_pl[i];
		       		}
  
				status = place_cons( &msg, plane_list, md_env, 6, (IGRint * ) NULL );
				as$status();
			}

			End
			return OM_S_SUCCESS;

		case 1:
			/*|====================================*/
			/*|  seg belongs the boundary plane   */
			/*|====================================*/

			__DBGpr_com( " seg belongs the boundary plane " );

			/*| ---  create the new start boundary plane  --- */
			cre_plan( string, vcou, md_env, &GRid_new_pl[0] );

			/*| ---  create the  new common plane  --- */
	        	BScrossp(&rc,vcou,&(n_plans[0].normal[0]),vecn);
			BSnorvec(&rc,vecn);
			cre_plan( string, vecn, md_env, &GRid_new_pl[1] );

			/*| ---   share start boundary plane with the new vertical plane  --- */
			GRid_new_pl[2] = GRid_end_pl[0];

			/*| ---  create the end boundary plane  --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			if( cre_flag == FALSE )
			{
				/*| ---  we place the constraint to have four planes passing by one point --- */

			       	plane_list[0] = GRid_end_pl[1];
		       		plane_list[1] = GRid_end_pl[2];
		       		plane_list[2] = GRid_new_pl[0];
		       		plane_list[3] = GRid_new_pl[1];
  
				status = place_cons( &msg, plane_list, md_env, 4, ( IGRint * ) NULL );
				as$status();
			}

			End
			return OM_S_SUCCESS;

		case 2:
			/*|====================================*/
			/*|   seg belongs the common plane     */
			/*|====================================*/

			__DBGpr_com( " seg belongs the common plane " );

			/*| ---  create the new start boundary plane  --- */
			cre_plan( string, vcou, md_env, &GRid_new_pl[0] );

			/*| ---  share the common plane with new common plane  --- */
			GRid_new_pl[1] = GRid_end_pl[1];

			/*| ---  create the new vertical plane  --- */
	        	BScrossp( &rc, vcou, n_plans[1].normal, vecn );
			BSnorvec( &rc, vecn );
			cre_plan( string, vecn, md_env, &GRid_new_pl[2] ); 

			/*| ---  create the end boundary plane  --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			if( cre_flag == FALSE )
			{
				/*| ---  we place the constraint to have four planes passing by one point --- */

		       		plane_list[0] = GRid_end_pl[0];
		       		plane_list[1] = GRid_end_pl[2];
		       		plane_list[2] = GRid_new_pl[0];
		       		plane_list[3] = GRid_new_pl[2];
  
				status = place_cons( &msg, plane_list, md_env, 4, ( IGRint * ) NULL );
				as$status();
			}

			End
			return OM_S_SUCCESS;

		case 3:
			/*|===================================================*/
			/*|    seg belongs boundary plane and common plane    */
			/*|===================================================*/

			__DBGpr_com( " seg belongs boundary plane and common plane " );
			/*| ---  share vertical plane with the new start 
			boundary plane  --- */

			GRid_new_pl[0] = GRid_end_pl[2];

			/*| ---  share the common with the new common plane  --- */
			GRid_new_pl[1] = GRid_end_pl[1];

			/*| ---  share the end boundary plane with new vertical plane  --- */
			GRid_new_pl[2] = GRid_end_pl[0];

			/*| ---  create the end boundary plane  --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			End
			return OM_S_SUCCESS;

		case 4:
			/*|=====================================*/
			/*|    seg belongs the vertical plane   */
			/*|=====================================*/

			__DBGpr_com( " seg belongs the vertical plane " );

			/*| ---  create the start boundary plane --- */
			cre_plan( string, vcou, md_env, &GRid_new_pl[0] );

			/*| ---  create the vertical plane with th new common plane  --- */
			GRid_new_pl[1] = GRid_end_pl[2];

			/*| ---  create the new vertical plane  --- */
	        	BScrossp( &rc, vcou, &n_plans[2].normal[0], vecn );
			BSnorvec( &rc,vecn );
			cre_plan( string, vecn, md_env, &GRid_new_pl[2] ); 

			/*| ---  create the end boundary plane  --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			if( cre_flag == FALSE )
			{
				/*| ---  we place the constraint to have four planes passing by one point --- */

		       		plane_list[0] = GRid_end_pl[0];
		       		plane_list[1] = GRid_end_pl[1];
		       		plane_list[2] = GRid_new_pl[0];
		       		plane_list[3] = GRid_new_pl[2];

				status = place_cons( &msg, plane_list, md_env, 4, ( IGRint * ) NULL );
				as$status();
			}

			End
			return OM_S_SUCCESS;

		case 5:
			/*|===================================================*/
			/*|    seg belongs the vertical and boundary plane    */
			/*|===================================================*/

			__DBGpr_com( " seg belongs the vertical and boundary plane " );

			/* share the common plane with the new boundary plane */
			GRid_new_pl[0] = GRid_end_pl[1];

			/*| ---  share the vertical plane with the new 
			common plane  --- */
			GRid_new_pl[1] = GRid_end_pl[2];

			/*| ---  share the end boundary plane with the new 
			vertical plane  --- */
			GRid_new_pl[2] = GRid_end_pl[0];

			/*| ---  create the end boundary plane  --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			End
			return OM_S_SUCCESS;

		case 6:
			/*====================================================*/
			/*|    seg belongs the vertical and common plane      */
			/*====================================================*/

			__DBGpr_com( " seg belongs the vertical and common plane " );

			/*| ---  share end boundary plane with start 
			boundary plane  --- */
			GRid_new_pl[0] = GRid_end_pl[0];

			/*| ---  share common plane with new common plane  --- */
			GRid_new_pl[1] = GRid_end_pl[1];

			/*| ---  share vertical plane with the new vertical plane  --- */
			GRid_new_pl[2] = GRid_end_pl[2];

			/*| ---  create the end boundary plane  --- */
    			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[3] );

			End
			return OM_S_SUCCESS;

		default:
			/*|  BelongPlanesSwitch = 7  seg should be null vector */

			*sts = MSFAIL;

			End
			return OM_S_SUCCESS;
   	}
}


/******************************************************************************/

CheckCoinc_WithExtent( sts, GRid_end_pl, GRid_new_pl, md_env, n_plans, trav_string, SlaveExtent )

IGRlong				*sts;
struct		GRid		*GRid_end_pl;
struct		GRid		*GRid_new_pl;
struct		GRmd_env	*md_env;
struct 		IGRplane	*n_plans; 
IGRdouble			*trav_string;
IGRboolean			SlaveExtent;

/*.CheckCoinc_WithExtent */
{
	IGRint			equi_oms[6];
	IGRint			num_equi_oms;
	IGRint		 	i;
	IGRint			ind_found;
	IGRlong		 	status, msg;
	struct	GRid		GRid_dummy, GRid_tpl[10];

	*sts = MSSUCC;

	check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );
		
	/*^
		for(i=0;i<num_equi_oms;i++)
 			printf("num_equi_oms = %d, equi_oms[%d] = %d, %d\n",num_equi_oms, 
		   					     i,equi_oms[2*i],equi_oms[2*i+1]);
	*/

	for(i=0;i<3;i++)
	{
		is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
		if( ind_found != -1 ) GRid_new_pl[equi_oms[ind_found+1]] = GRid_end_pl[i+3];
	}

	dang_free( &msg, &GRid_end_pl[3], md_env, trav_string, TRUE, &GRid_new_pl[6] );
	
	if( SlaveExtent )
	{			   
		GRid_new_pl[9]  = GRid_new_pl[6];
		GRid_new_pl[6]  = GRid_new_pl[0];
	}
	else
	{	
		GRid_dummy     = GRid_new_pl[6];
		GRid_new_pl[6] = GRid_new_pl[9];
		GRid_new_pl[9] = GRid_dummy;
	}

	for( i=0;i<3;i++)
	{
                /*^ 
                  	printf("end new[%d] = %d, oldslv[%d] = %d\n",
                                      			i,GRid_new_pl[i].objid,
                                                 		(i+6),GRid_new_pl[i+6].objid);
           	*/

		GRabsg_del_by_objid(&GRid_new_pl[i+6].objid);

  		om$send( msg      = message GRvg.GRdetplane
					( &msg,&md_env->md_env.matrix_type,
		    			  md_env->md_env.matrix, &n_plans[i] ),
                	 senderid = NULL_OBJID,
		 	 targetid = GRid_new_pl[i+6].objid,
		 	 targetos = GRid_new_pl[i+6].osnum );

			 GRabsg_del_by_objid(&GRid_new_pl[i].objid);

  			 om$send( msg      = message GRvg.GRdetplane
						( &msg,&md_env->md_env.matrix_type,
		       				  md_env->md_env.matrix, &n_plans[i+3] ),
               	 		  senderid = NULL_OBJID,
	 	 		  targetid = GRid_new_pl[i].objid,
		 	 	  targetos = GRid_new_pl[i].osnum );
	}

	/* --- check the coincidence of new planes --- */
	check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );
		    	    
	/* --- set up the good GRids for the coincident planes --- */
	for(i=0;i<3;i++)
	{
		is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
		if( ind_found != -1 ) GRid_new_pl[equi_oms[ind_found+1]+6] = GRid_new_pl[i];
	}
	
	for(i=0;i<3;i++)
	{
		GRid_tpl[i]   = GRid_new_pl[i];
		GRid_tpl[i+3] = GRid_new_pl[i+6]; 
	}

	status = place_cons( &msg, GRid_tpl, md_env, num_equi_oms, equi_oms );
	as$status();

	return OM_S_SUCCESS;
}

/******************************************************************************/
/*
/* given two points and six planes, this fucntion calcul the four new planes to
/* create the next segment and try to share the three first given planes with 
/* the four new planes
/*
/**/

dang_dang( sts, GRid_end_pl, md_env, string, GRid_new_pl, ext_flag, ext_cre_flag )

IGRlong			*sts;		/* return code *rc = 1 SUCCES 	     */
struct GRid	        *GRid_end_pl;   /* GRids of the coordinate system    */
struct GRmd_env	   	*md_env;	/* construction list		     */
IGRdouble		*string;   	/* xyz coordinates of the string     */
struct GRid	        *GRid_new_pl;   /* list of new constructed plans     */
IGRboolean		ext_flag;       /* tell if we got an extent case     */
IGRboolean		ext_cre_flag;   /* we create intermediate planes     */
				        /* even if we are in extent case     */
/*. dang_dang */
{
	IGRint			equi_oms[6];
	IGRint			num_equi_oms;
	IGRint		 	i, ip;
	IGRint			BelongPlanesSwitch;
	IGRint			ind_found;
	IGRlong		 	status, msg, rc=MSSUCC;
	IGRdouble		vcou[3];
	IGRdouble		trav_string[6];
	IGRdouble		t_plan[36]; 
	IGRdouble		length;
	struct	GRid		GRid_dummy, GRid_tpl[10];
	struct IGRplane		n_plans[6]; 

	SetProc( Fn dang_dang ); Begin 
	__DBGpr_int(" Create intermediate planes?", ext_cre_flag );

	*sts = MSSUCC;

	/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*|  retrieve the IGRplane struct of slave and master planes     --- */
	/*   in this case we get S,S,S,M,M,M and string is a line seg going  */
	/*      from Slave dangling to Master dangling 			     */

	for( i=0;i<6;i++)
	{
		n_plans[i].point  = &t_plan[6*i];
		n_plans[i].normal  = &t_plan[6*i+3];
  		om$send( msg      = message GRvg.GRdetplane
					( &msg, &md_env->md_env.matrix_type,
					  md_env->md_env.matrix, &n_plans[i] ),
                	 senderid = NULL_OBJID,
		 	 targetid = GRid_end_pl[i].objid,
		 	 targetos = GRid_end_pl[i].osnum );

		GRid_new_pl[i] = GRid_end_pl[i];

		/*^
			printf("GRid_end_pl[%d] = %d, %d\n",
                                i,GRid_end_pl[i].objid, GRid_end_pl[i].osnum );
		*/

	}
	__DBGpr_objlist(" Got geom; resolving plane", 6, GRid_new_pl );

	for(i=0;i<3;i++)
	{
		trav_string[i]   = string[i+3];
		trav_string[i+3] = string[i];
		vcou[i] = string[i+3] - string[i];
	}

	BSnorvec( &rc, vcou );

	if( ext_flag == TRUE )
        {
           	/*| Extend flag is TRUE */
	    __DBGpr_com(" Extend flag is TRUE ");
           	goto ddext; /* +--- S ---+....+--- M ---+ */
        }

	/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*| check and solve when the two Dangling are coincident already  --- */

        length = BSdistptpt( &msg, &string[0], &string[3] );
	__DBGpr_com( " Check for Dangle Coincidence " );
	__DBGpr_dbl( " length between them ", length );

        if( length <= VRGetTol(VR_LENGTH_TOL) )
	{
		/*				
					 +
					/
				     M /
			   S	      /
			+------------+ A     Slave and Master in A
		*/ 

		/*| ---   check if we have coincident planes between master and slave   --- */

		check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );
		
		for(i=0;i<3;i++)
		{
		   	is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
		   	if( ind_found != -1 )
				 GRid_new_pl[equi_oms[ind_found+1]] = GRid_new_pl[i+3];
		}

		/* Resetting the value to zero would construct a VRcompoint 
		object having four or more planes as its parents. This would
		ensure the propagation to be proper. When planes are moved
		in case of skewed segments. Alwin */

		num_equi_oms = 0; //added by alwin
		__DBGpr_int( " Resetted value of num_equi_oms ", num_equi_oms );

		status = place_cons( &msg, GRid_new_pl, md_env, num_equi_oms, equi_oms );
		as$status();

		/* --- set the array GRid_new_pl --- */ 
		goto wrapup;

	}

	/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*| find the position of the line segment with the slave planes --- */

	seg_belong_planes( string, 3, &n_plans[0], &BelongPlanesSwitch );
    __DBGpr_int(" Magic number from seg_belong_planes (CS same, 1st 3 planes)", BelongPlanesSwitch);

	if( BelongPlanesSwitch == 6 )
	{
		/*| ---           we are in extent mode on the salve side        --- */
		/*				
					 +
					/
				     M /
			   S	      /
			+-----+.>....+
		*/ 


	   	if( ext_cre_flag == FALSE )
		{
			/*| ext_cre_flag is FALSE */

			/*- define data to create new slave end plane    --- */
			/* --- change the origine of the slave end plane  --- */
			/*  set the GRid_new_pl array with the original ids  */

			for( i=0, ip=3; i<3; i++,ip++ )
			{
		     		GRid_new_pl[i]      = GRid_end_pl[i];
		     		GRid_new_pl[ip]     = GRid_end_pl[ip];
				n_plans[0].point[i] = string[ip];
			}

			/* ---		create a new slave end plane       --- */
			cre_plan( &string[3], vcou, md_env, &GRid_new_pl[0] );

			check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );
		    	    
			for(i=0;i<3;i++)
			{
		   		is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
		   		if( ind_found != -1 )
					GRid_new_pl[equi_oms[ind_found+1]] = GRid_new_pl[i+3];
			}

			num_equi_oms = 0; // added by alwin
			__DBGpr_int( " Resetted value of  Equi OMS ", num_equi_oms );
			status = place_cons( &msg, GRid_new_pl, md_env, num_equi_oms, equi_oms );
			as$status();
		}
		else CheckCoinc_WithExtent
		     ( &msg, GRid_end_pl, GRid_new_pl, md_env, n_plans, trav_string, TRUE );

		goto wrapup;
	}

	/*| find the position of the reversed line segment with the master pl */
	
	seg_belong_planes( trav_string, 3, &n_plans[3], &BelongPlanesSwitch );
    __DBGpr_int(" Magic number from seg_belong_planes (CS opp, last 3 planes)", BelongPlanesSwitch);

	if( BelongPlanesSwitch == 6 )
	{
		/*| ---         we are in extent mode on the master side     --- */
		/*
					 +
					/
				     S /
			   M	      /
			+-----+....<.+
		*/

	   	if( ext_cre_flag == FALSE )
		{
			/* --- define data to create new master end plane       --- */
			/* --- change the origine of the master end plane       --- */
			/* --- set the GRid_new_pl array with the original ids  --- */

			for( i=0, ip=3; i<3; i++, ip++ )
			{
				GRid_new_pl[i]      = GRid_end_pl[i];
				GRid_new_pl[ip]     = GRid_end_pl[ip];
				n_plans[3].point[i] = string[i];
                	}

			/* create a new end plane for the master segment */
			cre_plan( &string[0], vcou, md_env, &GRid_new_pl[3] );

			/* check coincidence between master and slave planes */
			check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );

			for(i=0;i<3;i++)
			{
			   is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
			   if( ind_found != -1 )
					GRid_new_pl[equi_oms[ind_found+1]] = GRid_new_pl[i+3];
			}

			num_equi_oms = 0; // added by alwin
			__DBGpr_int( " Resetted value of  Equi OMS ", num_equi_oms );
			status = place_cons( &msg, GRid_new_pl, md_env, num_equi_oms, equi_oms );
			as$status();
	   	}
		else CheckCoinc_WithExtent
		     ( &msg, GRid_end_pl, GRid_new_pl, md_env, n_plans, trav_string, FALSE );

		goto wrapup;
	}

ddext:

	/*| --- 		we are in general skeewed mode                  --- */

	/* --- from the existing slave and master find and set 
	       the planes which are sharable			---*/

	check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );
		    
#ifdef vdsDEBUG
		for(i=0;i<num_equi_oms;i++)
		 	printf("num_equi_oms = %d, equi_oms[%d] = %d, %d\n",num_equi_oms, 
							    i,equi_oms[2*i],equi_oms[2*i+1]);

#endif

	for(i=0;i<3;i++)
	{
		is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
		if( ind_found != -1 )
			GRid_new_pl[equi_oms[ind_found+1]] = 
			GRid_end_pl[i+3];
	}

	/*^
		printf("after check_coin true S and true M \n");
		for(i=0;i<6;i++) printf("GRid_new_pl[%d] = %d, %d\n",i,
		GRid_new_pl[i].objid, GRid_new_pl[i].osnum );
	*/
	__DBGpr_objlist("after check_coin true S and true M",6,GRid_new_pl);

	/* --- evaluate the planes of the new segment, we do it from
	       the master planes to the slave planes		     --- */
 
	dang_free( &msg, &GRid_end_pl[3], md_env, trav_string, ext_flag, &GRid_new_pl[6] );

	/*^
		for(i=6;i<10;i++) printf("GRid_new_pl[%d] = %d, %d\n",i,
					GRid_new_pl[i].objid, GRid_new_pl[i].osnum );
	*/

        if( ext_cre_flag == 2 )
	{
		/* ---- CC ------ CC ---- */
		GRid_new_pl[9]  = GRid_new_pl[6];
		GRid_new_pl[6]  = GRid_new_pl[0];
                End
		return OM_S_SUCCESS;
	}
	else
	{
		GRid_dummy     = GRid_new_pl[6];
		GRid_new_pl[6] = GRid_new_pl[9];
		GRid_new_pl[9] = GRid_dummy;
	}

	/* --- set a new list of plane structures and GRids with the old
	   slave planes playing the role of master planes and the new planes
	   comming from the dangling being master 			--- */

	for( i=0;i<3;i++)
	{
		/*^ 
   			 printf("end new[%d] = %d, oldslv[%d] = %d\n",i,GRid_new_pl[i].objid,
                                                 		 (i+6),GRid_new_pl[i+6].objid);
		*/

		GRabsg_del_by_objid( &GRid_new_pl[i+6].objid );

  		om$send( msg      = message  GRvg.GRdetplane
						( &msg, &md_env->md_env.matrix_type,
						  md_env->md_env.matrix, &n_plans[i] ),
                	 senderid = NULL_OBJID,
		 	 targetid = GRid_new_pl[i+6].objid,
		 	 targetos = GRid_new_pl[i+6].osnum );

		GRabsg_del_by_objid( &GRid_new_pl[i].objid );

  		om$send( msg      = message  GRvg.GRdetplane
						( &msg, &md_env->md_env.matrix_type,
		       				  md_env->md_env.matrix, &n_plans[i+3] ),
                	 senderid = NULL_OBJID,
		 	 targetid = GRid_new_pl[i].objid,
		 	 targetos = GRid_new_pl[i].osnum );
	}

	/* --- check the coincidence of new planes --- */
	check_coin( &msg, 3, &n_plans[3], &n_plans[0], &num_equi_oms, equi_oms );

	/*^
		for(i=0;i<num_equi_oms;i++)
			printf("2-C-num_equi_oms = %d, equi_oms[%d] = %d, %d\n",num_equi_oms,
				i,equi_oms[2*i],equi_oms[2*i+1]);
	*/

	/* --- set up the good GRids for the coincident planes --- */
	for(i=0;i<3;i++)
	{
		is_founded( equi_oms, 0, num_equi_oms, i, &ind_found );
		if( ind_found != -1 ) GRid_new_pl[equi_oms[ind_found+1]+6] = GRid_new_pl[i];
	}
	
	for(i=0;i<3;i++)
	{
		GRid_tpl[i]   = GRid_new_pl[i]; 
		GRid_tpl[i+3] = GRid_new_pl[i+6];
	}

	num_equi_oms = 0; // added by alwin
	__DBGpr_int( " Resetted value of  Equi OMS ", num_equi_oms );

	status = place_cons( &msg, GRid_tpl, md_env, num_equi_oms, equi_oms );
	as$status();

wrapup:
	/*^
		for(i=0;i<6;i++) printf("GRid_end_pl[%d] = %d, %d\n",i,
						GRid_end_pl[i].objid, GRid_end_pl[i].osnum );
		printf("\n\n");

		for(i=0;i<10;i++) printf("GRid_new_pl[%d] = %d, %d\n",i,
						GRid_new_pl[i].objid, GRid_new_pl[i].osnum );
	*/
	
	End
	return OM_S_SUCCESS;
}


end implementation Root;


