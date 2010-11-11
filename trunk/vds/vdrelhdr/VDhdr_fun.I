/* $Id: VDhdr_fun.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDhdr_fun.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDhdr_fun.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	LLC & GJ :- march 93	 + creation date
/*               15 april 93 : Compile for 2.2
/*
/* */

class implementation VDrelat_hdr;

#include "nddef.h"
#include "asmacros.h"

/* Prototypes */
#include "mainvmx.h"
#include "mamulmx.h"

#define	EPS		0.000001

extern	struct	GRid	NULL_GRID;

from	GRgencs		import	GRgetmatrix;

#define MAX_DEP_LIST	100

/* ********************* FCT VDSconvert_coord () **********************	*/
/*
/*	Compute coordinate of point between cs and base cs
/*
/* */

VDSconvert_coord( vect, wld, type, cs, matrix )
IGRdouble	*vect;	/* I : point to convert 	*/
IGRdouble	*wld;	/* O : converted point		*/
int 		type;	/* I : conversion way; 1 base to cs else cs to base */
struct GRid	*cs;	/* I : coordinate system	*/
IGRdouble	*matrix; /* I : environement matrix */

{
IGRdouble	mat[16],inv_mat[16],wld1[4];
int 		status;
IGRlong		loc_msg;
IGRshort        four,one;

      /* get cs matrix */
      status = om$send(  msg = message GRgencs.GRgetmatrix( &loc_msg, mat ),
				senderid = NULL_OBJID,
                              targetid = cs->objid,
                              targetos = cs->osnum);
      if (!(status&loc_msg&1))	return	0;
      four = 4; one = 1;
      if (type == 1) { /* base to cs conversion */
        MAinvmx( &loc_msg, &four, matrix, inv_mat );
        if (!(loc_msg&1))	return	0;
        MAmulmx( &loc_msg, &four, &four, &one, inv_mat, vect, wld1);
        if (!(loc_msg&1))	return	0;
        MAinvmx( &loc_msg, &four, mat, inv_mat );
        if (!(loc_msg&1))	return	0;
        MAmulmx( &loc_msg, &four, &four, &one, inv_mat, wld1, wld);
        if (!(loc_msg&1))	return	0;
      }
      else { /* cs to base conversion */
        MAmulmx( &loc_msg, &four, &four, &one, mat, vect, wld1 );
        MAmulmx( &loc_msg, &four, &four, &one, matrix, wld1, wld );
        if (!(loc_msg&1))	return	0;
      }

        if (wld[3] > EPS || wld[3] < -EPS) {
          wld[0] = wld[0]/wld[3];
          wld[1] = wld[1]/wld[3];
          wld[2] = wld[2]/wld[3];
          wld[3] = 1;
        }
  return 1;
}

/* ************************* FCT VDSis_same_plane () ******************	*/
/*
/*	test if XZ plane of the given cs and plane define by 3 pts are
/*	identical.
/*	FCT return 1 if same plane else return 0 or 2;
/* */

VDSis_same_plane( obj, pl_point )
struct GRid *obj;		/* I : cs to test */
IGRdouble   *pl_point;		/* I : definition of reference plane */
{
long   		sts;
int             nb;
struct GRid     graph_obj;
IGRshort	mat_type;
IGRdouble	mat[16];
double          tmp_vect[4],wld[4];

        nb = 0;
        sts = om$send(  msg = message NDnode.ASreturn_go
                                  (&graph_obj,&mat_type,mat),
			senderid = NULL_OBJID,
                          targetid = obj->objid,
                          targetos = obj->osnum);
//      if (!(sts&1)) return 2;

        tmp_vect[0] = pl_point[0]; tmp_vect[1] = pl_point[1];
        tmp_vect[2] = pl_point[2]; tmp_vect[3] = 1;
        if (! VDSconvert_coord(tmp_vect,wld,1,&graph_obj, mat))
          return 2;
        if (wld[1] < EPS && wld[1] > -EPS)  nb = nb + 1;

        tmp_vect[0] = pl_point[3]; tmp_vect[1] = pl_point[4];
        tmp_vect[2] = pl_point[5]; tmp_vect[3] = 1;
        if(! VDSconvert_coord(tmp_vect,wld,1,&graph_obj, mat)) return 2;
        if(wld[1] < EPS && wld[1] > -EPS)  nb = nb + 1;

        tmp_vect[0] = pl_point[6]; tmp_vect[1] = pl_point[7];
        tmp_vect[2] = pl_point[8]; tmp_vect[3] = 1;
        if(! VDSconvert_coord(tmp_vect,wld,1,&graph_obj, mat)) return 2;
        if (wld[1] < EPS && wld[1] > -EPS)  nb = nb + 1;

        if( nb == 3 ) return 1; 
        else return 0;
}

/* ****************** FCT VDSis_there_image () ************************	*/
/*
/*	Answer to the question : is there an image already placed with the
/*	given model and given reference plane in the given environment ??
/*
/*	if image return 1 else return 0 or 2
/* */

int VDSis_there_image( mac, mac_env, pl_point, cur_os, img_id )
struct GRid		*mac;		/* I : Model */
struct GRmd_env		*mac_env;	/* I : Model_Env */
IGRdouble	 *pl_point;	/* I : plan reference */
IGRint			cur_os;
struct GRid		*img_id;

{
IGRlong		sts, loc_msg;
struct GRid 	list[MAX_DEP_LIST], list1, *ptr_list;
int		nmb,nb,j;
GRclassid	cid;
struct	GRid	ptr_mac;


	/*| initialization */
	img_id->objid	= NULL_OBJID;
	ptr_list	= list;
	loc_msg		= 0;

	as$make_source( go_grid	= *mac,
			mod_env	= mac_env,
			as_os	= cur_os,
			as_grid	= &ptr_mac );

	sts = om$send(msg = message NDnode.NDget_objects(
					ND_CHILDREN, list, MAX_DEP_LIST,
                                                      NULL, NULL,
                                                      OM_K_MAXINT, &nmb),
				senderid = NULL_OBJID,
                                targetid = ptr_mac.objid,
                                targetos = ptr_mac.osnum);
	if(!(sts&1))	return	2;

	if( nmb >=  MAX_DEP_LIST ){

		ptr_list = (struct GRid *) malloc( sizeof( struct GRid ) * nmb);
		if( ! ptr_list ) return 2;

		sts = om$send(	msg	 = message NDnode.NDget_objects(
						ND_CHILDREN,
						ptr_list, nmb, NULL, 
						0, OM_K_MAXINT, &nmb),
				senderid = NULL_OBJID,
                                targetid = ptr_mac.objid,
                                targetos = ptr_mac.osnum);
		if(!(sts&1)){ loc_msg = 2; goto wrapup; }
	}

    for (j=0; j < nmb; j=j+1)
    {
      sts = om$get_classid(	osnum     = ptr_list[j].osnum,
				objid     = ptr_list[j].objid,
				p_classid = &cid );

      if( om$is_ancestry_valid( subclassid   = cid,
				superclassid = OPP_VDrelat_hdr_class_id )
		== OM_S_SUCCESS) {
           sts = om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					&list1, 1, NULL,
					1, 1, &nb ),
				senderid = NULL_OBJID,
                                targetid = ptr_list[j].objid,
                                targetos = ptr_list[j].osnum);
            if( (!(sts&1)) || (nb==0) ) continue;

            if( VDSis_same_plane( &list1, pl_point )){
		*img_id = ptr_list[j];
		loc_msg	= 1;
		goto	wrapup;
	    }
      }
    }

wrapup :

	if( ptr_list != list )	free( ptr_list );

return	loc_msg;
}

/* ********************* FCT VDScheck_image_placement () **************	*/
/*
/*	Check if image is already placed.
/*
/*	return	1 if is image else return 0 or 2
/* */


int VDScheck_image_placement( mac, mac_env, pl_point, cur_os, img_id )
struct GRid		*mac;		/* I: Model */
struct GRmd_env		*mac_env;	/* I: Model_Env */
IGRdouble	 *pl_point;	/* I: plan reference */
IGRint			cur_os;
struct GRid		*img_id;
{
struct GRid 	list[100];
int		nmb;
IGRlong		sts;
GRclassid	cid;
IGRint		ret_int=0;

	sts = om$get_classid(	osnum = mac->osnum,
				objid = mac->objid,
				p_classid = &cid );
	if( ! (sts&1))	return	2;

	if( om$is_ancestry_valid( subclassid   = cid,
	   		    superclassid = OPP_VDrelat_hdr_class_id )
		== OM_S_SUCCESS) {

		sts = om$send(msg = message NDnode.NDget_objects(
						ND_ROOT, 
						list, 100, NULL,
                                             	NULL, OM_K_MAXINT, &nmb),
				senderid = NULL_OBJID,
				targetid = mac->objid,
				targetos = mac->osnum);
		if (!(sts&1))	return	2;
		if( ! nmb )	return	0;

		ret_int = VDSis_same_plane( &list[1], pl_point );
                *img_id = list[0];

	} 
        if (!ret_int) ret_int = VDSis_there_image( mac, mac_env, pl_point,
					               cur_os, img_id );

return ret_int;
}

end implementation VDrelat_hdr;

