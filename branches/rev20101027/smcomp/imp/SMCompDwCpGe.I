/* $Id: SMCompDwCpGe.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCompDwCpGe.I
 *
 * Description:
 *
 *      This file implements methods and functions related to the drawing 
 *	of a compartment.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMCompDwCpGe.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  22:13:36  pinnacle
# UnInit warning
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/04/29  08:51:22  pinnacle
# Replaced: smcomp/imp/SMCompDwCpGe.I for:  by ksundar for vds.240
#
# Revision 1.2  1995/10/26  21:46:18  pinnacle
# Replaced: ./smcomp/imp/SMCompDwCpGe.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      04/24/92        Ch. Heraud      Creation date.
 *	10/31/97	ah		UnInit warning
 * -------------------------------------------------------------------------
 */

class implementation SMcomp ;

#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "ACrg_collect.h"
#include "EMStypedef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsimpdef.h"
#include "emsmapdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "grerr.h"
#include "emssfintdef.h"
#include "emsdattyp.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "SMDwDef.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include "SMmsg.h"
#include "VDmem.h"

#define AS_DEBUG       1

#define FAST_VER       1   /* If defined means that for floor extraction of compartment
                            the intersection list is not created . Faster but maybe
                            not completly safe. Remove if problem */

#include "AS_status.h"

extern OMuword	OPP_GR3dpoint_class_id,
		OPP_GRgrgrp_class_id,
		OPP_EMSplane_class_id,
		OPP_EMSgencompsf_class_id ;
extern long	EFproject_any_curve_on_planen() ;

from GRcurve	import GRarea;
from EMSplane	import EMplane_of_curve, EMplane;
from EMSsurface	import EMimpose_boundaries;
from GRlinear	import GRgetpolyline;
from EMSgencompsf  import EMmake_comp;


#define FLOOR_ANGLE	15	/* Means horizontal ~ 15 degrees */
#define SMALL_ANGLE	2	/* some small angle	*/
#define MAX_BOUND	100	/* Max. no. of boundaries for a composite surface */
#define FRACTION	0.001	/* small fraction */

#if 0
/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMflattenGraphicGroupsOfInters

  Abstract

	This function is used to separate the curves that are gathered 
	in graphic groups ( Because of the result of EMintplane message).

  Returns
         
         OM_S_SUCCESS if success
         OM_E_ABORT   if fails

 -------------------------------------------------------------------------
*/

static long SMflattenGraphicGroupsOfInters( msg, count, list,
						newcount, newlist )
long		*msg ;
int		count ;
struct GRid	list[] ;
int		*newcount ;
struct GRid	**newlist ; {

	long		sts ;
	int		i,
			j,
			ncnt	= 0,
			*nComps	= NULL ;
	struct GRid	*nlist	= NULL ;
	OMuword		classid ;
	struct GRmd_env	stupidEnv ;

	*newcount	= 0 ;
	*newlist	= NULL ;



	if( !( nComps = _MALLOC( count, int  ) ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	for( i = 0 ; i < count ; i++ ) {
		om$get_classid(	objid		= list[i].objid,
				osnum		= list[i].osnum,
				p_classid	= &classid ) ;

		if( om$is_ancestry_valid(
			superclassid	= OPP_GRgrgrp_class_id,
			subclassid	= classid ) != OM_S_SUCCESS ) {
			ncnt++ ;
			nComps[i] = 0 ;
			continue ;
		}

		sts = om$send(
			msg	= message GRowner.GRget_number_components(
							msg, nComps + i ),
			senderid= NULL_OBJID,
			targetid= list[i].objid,
			targetos= list[i].osnum ) ;
		if( !( sts & 1 & *msg ) ) goto wrapup ;

		ncnt += nComps[i] ;
	}

	if( !( nlist = _MALLOC(ncnt*(sizeof *nlist)/sizeof(struct GRid ),struct GRid))) {
		*msg = MSFAIL ; goto wrapup ;
	}

	MAidmx( msg, stupidEnv.md_env.matrix ) ;
	stupidEnv.md_env.matrix_type = MAIDMX ;

	for( i = j = 0 ; i < count ; i++ ) {
		if( !nComps[i] ) {
			nlist[j++] = list[i] ;
			continue ;
		}
		sts = om$send(
			msg	= message GRowner.GRget_components(
								msg,
								&stupidEnv,
								nlist + j,
								nComps[i],
								nComps + i,
								0,
								nComps[i] - 1 ),
			senderid= NULL_OBJID,
			targetid= list[i].objid,
			targetos= list[i].osnum ) ;
		if( !( sts & 1 & *msg ) ) goto wrapup ;

		j += nComps[i] ;

	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		_FREE( nComps ) ;
		if( sts & 1 & *msg ) {
			*newcount	= ncnt ;
			*newlist	= nlist ;
		} else {
			_FREE( nlist ) ;
		}
		return sts ;
} /* SMflattenGraphicGroupsOfInters */
#endif

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMFlGrGrOfInters

  Abstract

	This function is used to separate the curves that are gathered 
	in graphic groups ( Because of the result of EMintplane message).

  Returns
         
         OM_S_SUCCESS if success
         OM_E_ABORT   if fails

 -------------------------------------------------------------------------
*/
long SMFlGrGrOfInters( msg, count, list, cst, newcount, newlist )

long		        *msg ;	  /* (O) Completion code     */
int		        count ;   /* (I) Number of group     */
struct GRid	        list[] ;  /* (I) group id            */
struct GRvg_construct	*cst ;	  /* (I) For intersections   */
int		        *newcount;/* (O) new count of curves */
struct GRid	        **newlist;/* (O) new list of curves  */
/*
-fi */
{
 long		    sts ;
 int		    i, j, ncnt = 0, *nComps = NULL ;
 struct GRid	    *nlist = NULL ;
 OMuword	    classid ;
 struct GRmd_env    stupidEnv ;
 IGRshort           Type;
 IGRint             NbOutCv;
 struct GRobj_env   *CrvIn;
 struct GRid        *OutCv;

 *newcount	= 0;
 *newlist	= NULL;
 CrvIn 		= NULL;
 OutCv		= NULL;

 *msg           = MSFAIL;
  sts		= OM_E_ABORT;  // Lets init it just for grins

 if(count < 1) return OM_S_SUCCESS;

 /* Alloc to the number of group */
 if( !( nComps = _MALLOC( count, int ) ) ) 
  {
   *msg = MSFAIL; 
    goto wrapup ;
  }

 for( i = 0 ; i < count ; i++ ) 
  {
   /* Verify if valid (because of bug  GRvg.EMintplane which return crazy
    * things, therefore if one object is not valid or is not what is
    * expected, we can think the OBJ has not been allocated and go away
    * as fast as possible.
    */
   if(!(om$is_objid_valid(osnum = list[i].osnum,
                          objid = list[i].objid) & 1))
    {
     /* Object not valid !!! */
     /* list[i].objid = NULL_OBJID; 
      * nComps[i]     = 0 ;
      * continue;
      */
     goto wrapup ; /* return OM_W_ABORT; */
    }

   om$get_classid(objid		= list[i].objid,
		  osnum		= list[i].osnum,
		  p_classid	= &classid);

   if( om$is_ancestry_valid(superclassid = OPP_GRgrgrp_class_id,
			    subclassid	 = classid ) != OM_S_SUCCESS)
     {
      /* Not a group, as to be sub-class of GRcurve */
      if( om$is_ancestry_valid(superclassid = OPP_GRcurve_class_id,
			       subclassid   = classid ) != OM_S_SUCCESS)
       {
        /* Not a curve, I dream .... */
        /* list[i].objid = NULL_OBJID;
         * nComps[i]     = 0 ; 
         * continue;
	 */ 
        goto wrapup; /* return OM_W_ABORT; */
       }

      ncnt++ ;
      nComps[i] = 0 ; /* Not a composite */
      continue ;
     }

   sts = om$send(msg = message GRowner.GRget_number_components(msg, &nComps[i]),
			senderid= NULL_OBJID,
			targetid= list[i].objid,
			targetos= list[i].osnum ) ;
   if( !( sts & 1 & *msg ) ) goto wrapup ;

   ncnt += nComps[i] ;
  }

 /* Alloc to the number of curves */
 if(ncnt < 1) 
  {
   /* No output curve */
   *newcount = 0;
   _FREE( nComps ) ;
   *msg      = MSSUCC ;
   goto wrapup ; /* return OM_S_SUCCESS; */
  }

 nlist = _MALLOC( ncnt, struct GRid);
 if(nlist == NULL)
  {
   *msg = MSFAIL;
   goto wrapup ;
  }
 MAidmx( msg, stupidEnv.md_env.matrix ) ;
 stupidEnv.md_env.matrix_type = MAIDMX ;

 for( i = j = 0 ; i < count ; i++ )
  {
   if( !nComps[i] )
    {
     if(list[i].objid != NULL_OBJID) nlist[j++] = list[i] ;
     continue ;
    }

  sts = om$send(msg = message GRowner.GRget_components(msg, &stupidEnv,
                        nlist + j, nComps[i], nComps + i, 0, nComps[i] - 1 ),
                        senderid= NULL_OBJID,
                        targetid= list[i].objid,
                        targetos= list[i].osnum ) ;
  if( !( sts & 1 & *msg ) ) goto wrapup ;

  j += nComps[i] ;
 }

 _FREE( nComps ) ;


 if(1)
  {
   /*
    * BECAUSE the following does not work .... Just take it lake that.
    */
   *newcount = ncnt;
   *newlist  = nlist;

   sts    = OM_S_SUCCESS ;
   *msg	= MSSUCC ;

   return sts ;
  }



 CrvIn = _MALLOC(ncnt, struct GRobj_env);
 if(CrvIn == NULL) goto wrapup;
 
 for(i=0;i<ncnt;i++)
  {
   CrvIn[i].obj_id  = nlist[i];
   CrvIn[i].mod_env = *(cst->env_info);
  } 
 
 _FREE(nlist) ;

 Type = 1;  /* Merge and delete ... */
 /* Type = 3;  /* Composite ... but does not work */

 if(0)
  {
   /* Call the Jll ones (maintenance purpose ...) [take care to BSSUCC !!!) */
   /* But it does not work .... */
   SortAndBuildCrv(CrvIn, ncnt, Type, cst, &OutCv, &NbOutCv, msg);
   if(msg != BSSUCC)
    {
     printf("Error sorting curve\n");
     *msg = MSFAIL;
     sts  = OM_W_ABORT;
     goto wrapup;
    }
  }
 else
  {
   if(SMBidouilleCurves(ncnt, CrvIn, Type, cst, &NbOutCv, &OutCv) != 1)
    {
     /* Mauvaise bidouille */
     *msg = MSFAIL;
     sts  = OM_W_ABORT;
     goto wrapup;
    }
  }
 /* if(NbOutCv < ncnt) printf("Open curve closed\n"); */
 _FREE(CrvIn) ;
 *newcount = NbOutCv;
 *newlist  = OutCv;



 sts    = OM_S_SUCCESS ;
 *msg	= MSSUCC ;

 return sts ;

 wrapup :
 _FREE( nComps ) ;
 _FREE( *newlist ) ;

 return sts ;

} 

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMDelInterObj

  Abstract

	This function is used to delete intermediate objects.

  Returns
         1 always

 -------------------------------------------------------------------------
*/

int SMDelInterObj( 
int	NbObj,			/* [I] - no. of objects to be deleted	*/
struct  GRid	*ObjId,		/* [I] - GRid list to be deleted	*/
struct  GRmd_env *md_env,	/* [I] - module environment		*/
IGRboolean	FreeList	/* [I] - TRUE for freeing GRid list	*/
)
/*
-fi */
{
int	jj;
long	sts, msg;

 if(!NbObj || !ObjId) return 1;

 for ( jj=0; jj<NbObj; jj++ )
 {  sts = om$send(msg = message GRgraphics.GRdelete(&msg, md_env),
				senderid= NULL_OBJID,
				targetid= ObjId[jj].objid,
				targetos= ObjId[jj].osnum ) ;
  }
 if ( FreeList)
 { free ( ObjId ); ObjId = NULL; }

 return 1;
}


#define  SM_MAX_DW_PL   10		/* Max number of possible plane */
#define  SM_DWPAR_FILE  "SMCompDrawing"


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDdrawing_copy_geom from NDnode

  Abstract

  Whence elements entring a drawing sheet have been selected (by the
  logical selection above or by some other selection), this message is sent to
  selected elements.


  Arguments


  struct GRid	  *seletected_elements 	I 	elements selected for the 
						drawing sheet.

  int		  nb_elements         	I 	number of selected elements.

  struct GRid	  **drawing_elements    O 	list of elements created in 
						the drawing file by the target 
						of the message.
                          			Space deallocated by the caller.

  int		  *nb_drawing_elem     	O  	number of created elements

  double	  *vector              	O 	vector perpendicular to the 
						drawing plane.

  double	  * point               O 	point on the drawing plane.

  int		  *level               	I 	displayable levels. Only the
						components passing the test 
						DPlevel_check(me->level,level)

  struct IGRlbsys *lbsys		I	coord. system of the view plane.

  struct GRmd_env *from_env		I	modele environment.
  struct GRmd_env *to_env     		I 	
						drawing environnement.
						(!= MAIDMX to describe drawing 
						projection)


  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	if fails.

 -------------------------------------------------------------------------
-mo*/

method NDdrawing_copy_geom(	

struct GRid	*selected ;	/* IN : selected elements		*/
int		nbSel ;		/* IN : # of selected elements		*/
struct GRid	**drwElms ;	/* OUT: elements representing compart.	*/
int		*nbDrwElms ;	/* OUT: # of the above elements		*/
double		*drwNormal,	/* IN : normal to drawing sheet		*/
		*drwPoint ;	/* IN : some point on drawing sheet	*/
int		*levelMask ;	/* IN : accepted levels			*/
struct IGRlbsys *vwLbsys ;	/* IN : lbsys of view plane		*/
struct GRmd_env *myEnv,		/* IN : my module environment		*/
		*drwEnv ) 	/* IN : environment of drawing sheet	*/
{
 long			sts, msg, rc ;
 int			msg1;
 struct IGRplane	drwPlane,	/* Plane of sheet	*/
			vwPlane ;	/* Plane of view	*/
 struct GRsymbology	ObjSymb ;	/* My symbology		*/
 IGRpoint		vwPoint ;	/* Point on view plane	*/
 IGRvector		vwVector ;	/* The view vector	*/
 struct GRid		mySolid,	/* Solid output		*/
			*intersList,	/* Inters. solid/view	*/
			*projList,	/* Prj. of int. on drw. */
			outPlane[SM_MAX_DW_PL],	/* Pl. representing cprt*/
                        PtObj,          /* Point 		*/
                        TextId;          /* Text object		*/
 int			numInters,	/* # of intersections	*/
			numProjs,	/* # of projections	*/
			i, j, jj, kk,	/* Favorite loop index	*/
                        NbObj;          /* Number of possible extract */
 struct GRlc_info	objToIntersect ;/* Stupid EMS ...	*/
 struct GRvg_construct	cst;		/* For intersections	*/
 OMuword		pjClassid ;	/* Class of 1 projection*/
 IGRshort	        cmp_type;
 IGRdouble		mat[16];
 IGRshort		mat_type;

 struct GRmd_env	CstEnv;

 IGRboolean		CrPlane, CrCont, CrContLn, CrCog, CrName, ExtType;
 IGRint			NbCrPlane;
 struct SMDwSymb	PlaneSymb, ContSymb, ContLnSymb, CogSymb, NameSymb, ExtSymb;
 struct GRsymbology	MySymb;
 struct GRsymbology	CurSymb;
 IGRlong                sizebuf, nret;
 int			flatCount ;
 struct GRid		*flatList, CollId ;
 IGRchar		tpipo[81], CollName[81];
 GRspacenum		cur_os;


 *nbDrwElms	= 0 ;
 *drwElms	= NULL ;

 numInters	= 0 ;
 intersList	= NULL ;

 numProjs	= 0 ;
 projList	= NULL ;

 /* If it is a compartment hull, no drawing extraction */

 sts = om$send(msg = message SMmgr.SMGetAttTxt(&msg,"comp_type",tpipo, NULL),
	       targetid = my_id);
 if(!(sts & msg & 1))  tpipo[0] = '\0';  /* No type found !!! */
 if(tpipo[0]=='\0' || strcmp(tpipo,"compartment") == 0) cmp_type =  SM_REG;
 else                                                   cmp_type =  SM_HULL; 

 if(cmp_type & SM_HULL) return OM_S_SUCCESS;

 /* If compartment is pseudo,  no drawing extraction */
 sts = om$send(msg = message SMmgr.SMGetAttTxt(&msg,"pseudo",tpipo, NULL),
	       targetid = my_id);
 if(!(sts & msg & 1))  tpipo[0] = '\0';  /* attribute not found !!! */
 if(tpipo[0] != 'n')  return OM_S_SUCCESS;


 for(i=0;i<SM_MAX_DW_PL;i++) outPlane[i].objid = NULL_OBJID ;

 /* Get the object symbology */
 sts = om$send(msg = message GRvg.GRgetsymb( &msg, &ObjSymb ),
			targetid= my_id ) ;

 if( !( sts & 1 & msg ) ) return OM_S_SUCCESS ;

 /*
  * Am I on the desired level ?
  */
 if(!(DPlevel_check( ObjSymb.level, levelMask))) return OM_S_SUCCESS ;

 /* 
  * Get the current symbology 
  */
 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg     = &rc,
                       sizbuf  = &sizebuf,
                       buffer  = &CurSymb.display_attr,
                       nret    = &nret);

 /*| get the active level */
 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg     = &rc,
                     sizbuf  = &sizebuf,
                     buffer  = &CurSymb.level,
                     nret    = &nret);
  /* get the drawing parameters */
  /* Look if collection exists */
   VDSget_filename(CollName);
   strcat(CollName, SMDwCollName);

   sts = di$translate(objname = CollName,
	      p_objid = &CollId.objid,
              p_osnum = &CollId.osnum);
   if( sts & 1 )		/* collection exists	*/
   {
	sts = SMGetDwPr( &CrPlane, &PlaneSymb, &CrCont, &ContSymb, &CrContLn, 
		&ContLnSymb, &CrCog, &CogSymb, &CrName, &NameSymb, 
		&ExtType, &ExtSymb, &CollId );
   }
   else
   {
     /* The collection does not exit, create collection from default params file and
	then get params */
	ex$get_cur_mod( osnum = &cur_os );
	sts = SMReadDrawParam( SM_DWPAR_FILE, cur_os );
	if ( !(sts&1))
	{
	  printf("Error getting drawing set up info\n");
	  return OM_W_ABORT;
	}

	sts = SMGetDwPr( &CrPlane, &PlaneSymb, &CrCont, &ContSymb, &CrContLn,
		&ContLnSymb, &CrCog, &CogSymb, &CrName, &NameSymb,
		&ExtType, &ExtSymb, NULL );

	if ( !(sts&1))
	{
	  printf("Error getting drawing set up info\n");
	  return OM_W_ABORT;
	}
   }

 /*
  * Set up drawing and view plane structures.
  */
 drwPlane.point	 = drwPoint ;
 drwPlane.normal = drwNormal ;

 vwPlane.point	= vwPoint ;
 vwPlane.normal	= drwNormal ;

 vwPoint[0] = vwLbsys->matrix[ 3] ;
 vwPoint[1] = vwLbsys->matrix[ 7] ;
 vwPoint[2] = vwLbsys->matrix[11] ;

 memcpy( vwVector, drwNormal, sizeof( IGRvector ) ) ;

 sts = om$send(msg = message NDmacro.ACreturn_foot(&msg, "sol", &mySolid,
						    &mat_type, mat),
			targetid= my_id ) ;
 if( !( sts & 1 & msg ) ) return OM_S_SUCCESS ;

 /*
  * Intersect your solid with the view plane.
  */
  
 CstEnv		    = *drwEnv;		/* Construct outside of Rtree */
 CstEnv.md_id.objid = NULL_OBJID;  

 cst.msg	    = &msg;
 cst.env_info	    = &CstEnv;
 cst.level	    = ObjSymb.level;    	/* For tempory element */
 cst.display	    = &ObjSymb.display_attr;	/* For tempory element */
 cst.properties	    = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 cst.name	    = NULL;
 cst.geometry	    = NULL;
 cst.class_attr     = NULL;
 cst.newflag	    = FALSE;

 objToIntersect.located_obj		 = mySolid ;
 objToIntersect.geom_parms.leaf_id.objid = NULL_OBJID;
 objToIntersect.module_info		 = *myEnv ;

 
 if( ExtType && (ExtSymb.options & SMDWEXTFLR) ) 	/* Extract Floor */
  {
     IGRboolean	parallel;

    /* Check if the normal to view plane and SCS Vz are approx. parallel    */
    /* Jean 15 July 93 : In fact the vector is not vwPlane (always [0,0,1]) */
    /* But the Vz vector of myEnv which has to be tested                    */
    sts = SMCheckVector ( &myEnv->md_env.matrix[8], (IGRdouble)SMALL_ANGLE,
			 &parallel );
    if ( !(sts&1) || !parallel )  /* not parallel */
     { 
      ex$message(msgnumb = SM_W_CmExtHorz);
      ex$message(msgnumb = SM_W_CmFlIgn);
      ExtType = 0;
    }
  }

 if( ExtType && (ExtSymb.options & SMDWEXTFLR) ) 	/* Extract Floor */
  {
   IGRint 	NbFloor;
   struct GRid 	*Floor=NULL, *Floor_in_cstEnv=NULL;
   GRobjid	*Floor_objid=NULL;
   struct GRid  *BOUNDtab=NULL;
   IGRint	nb_bound;

   /* Continue only if there is an intersection between solid and plane */

#ifdef FAST_VER
   sts = SMCompIntersect( &cst, &vwPlane, &objToIntersect, &mySolid,
	&numInters, &msg1 );

   if ( !(sts & msg1 & 1) )
   { printf("Error SMFindInters\n"); goto wrapup; }

/**
   if ( !numInters ) return OM_S_SUCCESS;
 **/

#else
   
   sts = om$send(msg = message GRvg.EMintplane(&cst, &vwPlane,
			&objToIntersect, &numInters, &intersList, &msg1 ),
			targetid= mySolid.objid,
			targetos= mySolid.osnum ) ;


   if( !( sts & 1 & msg1 ) || !numInters ) return OM_S_SUCCESS ;
   SMDelInterObj ( numInters, intersList, cst.env_info, TRUE );
#endif

   /* Get the floor surfaces */
   if(SMGetFloor(&mySolid, myEnv, (IGRdouble) FLOOR_ANGLE, &NbFloor, &Floor) != 1)
    {
     printf("ERROR, Compartment floor extraction\n");
     return OM_W_ABORT;
    }

   if(NbFloor == 0)
    {
     /* No floor found */
        goto wrapup;
    }
   else
    {
      struct  GRid   comp_surf;

      Floor_in_cstEnv = _MALLOC ( NbFloor, struct GRid);
      if ( !Floor_in_cstEnv )
      { printf ( "Can not allocate memory\n");	goto wrapup; }

      /*  Make copy of floors in the construction env   */
      for ( jj = 0; jj < NbFloor; jj++ )
      {
	Floor_in_cstEnv[jj].osnum = (cst.env_info)->md_id.osnum;
	sts = om$send ( msg = message GRgraphics.GRcopy ( &msg, myEnv,
				cst.env_info, &Floor_in_cstEnv[jj].objid ),
			targetid = Floor[jj].objid,
			targetos = Floor[jj].osnum );
	as$status ( sts = (sts & msg));
      }
      _FREE ( Floor ) ;

      /* construct composite surface			*/
      comp_surf.osnum = (cst.env_info)->md_id.osnum;
      if ( NbFloor == 1 )
          comp_surf.objid = Floor_in_cstEnv[0].objid;
      else
      {
          Floor_objid = _MALLOC ( NbFloor, GRobjid );
	  if ( Floor_objid == NULL )
           { printf ( "Can not allocate memory\n"); goto wrapup;}

          for ( jj=0; jj<NbFloor; jj++)
		Floor_objid[jj] = Floor_in_cstEnv[jj].objid;
          sts = om$construct ( classid = OPP_EMSgencompsf_class_id,
			      p_objid = &comp_surf.objid,
			      osnum = comp_surf.osnum);
	  as$status(sts = sts, action = GOTO_VALUE, value = wrapup);

	  sts = om$send ( msg = message EMSgencompsf.EMmake_comp ( &msg,
					NbFloor, Floor_objid, cst.env_info ),
			 targetid = comp_surf.objid,
			 targetos = comp_surf.osnum);
	  as$status(sts = sts);
	  if( !( sts & 1 & msg ) )
          { SMDelInterObj( NbFloor, Floor_in_cstEnv, cst.env_info, TRUE );
	    SMDelInterObj( 1, &comp_surf, cst.env_info, FALSE );
            _FREE ( Floor_objid ) ;
            goto wrapup ;
          }

          _FREE ( Floor_objid ) ;
      }

      BOUNDtab = _MALLOC ( MAX_BOUND, struct GRid );
      if ( !BOUNDtab )
       { printf("Can not allocate memory\n"); goto wrapup; }

      sts = SMevaluate_xbound ( 0,comp_surf,cst.env_info,BOUNDtab,MAX_BOUND,&nb_bound );
      if ( !(sts & 1))
	{ printf("Error SMevaluate_xbound\n");
          SMDelInterObj( NbFloor, Floor_in_cstEnv, cst.env_info, TRUE );
	  if ( NbFloor > 1) SMDelInterObj( 1, &comp_surf, cst.env_info, FALSE );
          _FREE ( BOUNDtab ) ;
          goto wrapup ;
        }	
      /*   printf ( " No. of boundaries : %d\n", nb_bound ); */

      /* delete floors in construction env	*/
      SMDelInterObj( NbFloor, Floor_in_cstEnv, cst.env_info, TRUE );


      /* If more than one surfaces => create a composite */
      /* Extract the stitchable edge */
      /* Project on the drawing view plane */
      /* back to the regular process */

      /*
       * Now project intersection curves onto drawing sheet along view vector.
       */
      if( !( projList = _MALLOC(nb_bound, struct GRid))) 
      {
	msg = MSFAIL ;
    	goto wrapup ;
      }

      for( i = 0 ; i < nb_bound ; i++ ) projList[i].objid = NULL_OBJID ;

      for( i = numProjs = 0 ; i < nb_bound ; i++ ) 
      {
    	   if(IF_NULL_OBJID( BOUNDtab[i].objid)) continue;

/*  Drawing is not extracted when the active z-depth is not zero.
    The projection should be on drwPlane. vwPlane should be changed
    to drwPlane . The projection vector should be specified
    such that the curve is projected from view plane to drawing plane.
    In case of floor extraction, it should be from the floor to drawing
    plane.  Raju 08/27/93.
*/
    	   sts = EFproject_any_curve_on_planen(&msg, &cst, &BOUNDtab[i],
					cst.env_info, &vwPlane,	vwVector,
					&projList[numProjs], &pjClassid);
	   if(!(sts & 1 & msg)) 
     	   {
      	     printf("Warning, Bad curve projection\n");
      	     continue;
     	   }

    	   if(om$is_ancestry_valid(superclassid = OPP_GR3dpoint_class_id,
			    subclassid	 = pjClassid ) == OM_S_SUCCESS) 
     	   {
      	     om$send(msg = message GRgraphics.GRdelete(&rc, cst.env_info),
				targetid= projList[numProjs].objid,
				targetos= projList[numProjs].osnum);
     	   } 
    	   else 
     	   {
      	     numProjs++ ;
 	   }
      }

      /* delete composite surface and boundary curves	*/
      if ( NbFloor > 1) SMDelInterObj( 1, &comp_surf, cst.env_info, FALSE );

      SMDelInterObj( nb_bound, BOUNDtab, cst.env_info, TRUE );

    }
  }  /* end of FLOOR extraction  */
 else
  {
   /* Create the intersection with the drawing plane */

   /* Work now !!! */
   sts = om$send(msg = message GRvg.EMintplane(&cst, &vwPlane,
			&objToIntersect, &numInters, &intersList, &msg1 ),
			targetid= mySolid.objid,
			targetos= mySolid.osnum ) ;

   if( !( sts & 1 & msg1 ) || !numInters ) 
	goto wrapup; /* return OM_S_SUCCESS ; */


 /*
  * CAUTION : GRvg.EMintplane may return some intersections bundled
  * together in a graphic group (How convenient !).
  */
 sts = SMFlGrGrOfInters(&msg, numInters, intersList, &cst, &flatCount, &flatList);
 if( !( sts & 1 & msg ) ) 
 {  SMDelInterObj ( numInters, intersList, cst.env_info, TRUE );
    goto wrapup ;
 }

 _FREE(intersList ) ;
 numInters	= flatCount ;
 intersList	= flatList ;

 /*
  * Now project intersection curves onto drawing sheet along view vector.
  */
  if( !( projList = _MALLOC(numInters, struct GRid))) 
   {
    msg = MSFAIL ;
    goto wrapup ;
   }

  for( i = 0 ; i < numInters ; i++ ) projList[i].objid = NULL_OBJID ;

  for( i = numProjs = 0 ; i < numInters ; i++ ) 
   {
    if(IF_NULL_OBJID(intersList[i].objid)) continue;

/*  Drawing is not extracted when the active z-depth is not zero.
    The projection should be on drwPlane. vwPlane should be changed
    to drwPlane . The projection vector should be specified
    such that the curve is projected from view plane to drawing plane.
    In case of floor extraction, it should be from the floor to drawing
    plane.  Raju 08/27/93.
*/
    sts = EFproject_any_curve_on_planen(&msg, &cst, &intersList[i],
					cst.env_info, &vwPlane,	vwVector,
					&projList[numProjs], &pjClassid);
    if(!(sts & 1 & msg)) 
     {
      printf("Warnning, Bad curve projection\n");
      continue;
     }

    if(om$is_ancestry_valid(superclassid = OPP_GR3dpoint_class_id,
			    subclassid	 = pjClassid ) == OM_S_SUCCESS) 
     {
      om$send(msg = message GRgraphics.GRdelete(&rc, cst.env_info),
				targetid= projList[numProjs].objid,
				targetos= projList[numProjs].osnum);
     } 
    else 
     {
      numProjs++ ;
     }
    /* Delete the intersection curve */
    om$send(msg = message GRgraphics.GRdelete(&rc, cst.env_info),
				targetid= intersList[i].objid,
				targetos= intersList[i].osnum ) ;
   }

 /*
  * Free the allocated array of intersection curves
  */
 _FREE(intersList) ;
}  /* end cross section extraction */

 /* if(numProjs <= 0) return OM_S_SUCCESS;  */

 if(numProjs <= 0) CrPlane = FALSE;
 NbCrPlane = 0;  /* Number of created planes */
 if(CrPlane)
  {
   struct GRlc_info	cvInfo ;
   IGRboolean         	loopset;
   IGRboolean 		*CrvArea, *BelongTo;
   IGRint		NbBound;
   IGRmatrix		TransMat;
   IGRshort		MatType;
   struct GRid		TempObj;

   /*
    * Now create one or more than one plane encompassing
    */

   BelongTo = CrvArea = NULL;

   CrvArea  = _MALLOC(numProjs, IGRboolean);
   BelongTo = _MALLOC(numProjs, IGRboolean);
   if(CrvArea == NULL || BelongTo == NULL) 
    {
     printf("Error allocating space\n");
     msg = MSFAIL ;
     goto wrapup ;
    }

    
   if(!(SMFdEnCrv(numProjs, projList, cst.env_info, CrvArea, BelongTo) & 1))
    {
     printf("Error getting curve information\n");
     _FREE(CrvArea) ;
     _FREE(BelongTo) ;
     msg = MSFAIL ;
     return OM_W_ABORT;
    }

   NbCrPlane = 0;  /* Number of created planes */
   for(i=0;i<numProjs;i++) if(BelongTo[i] == -1 && CrvArea[i] == TRUE) NbCrPlane++;

   /* We have all the information concerning the curves, but we will only
    * concidere one level of dependancy...
    */

    /*
     * Just a small kludge to put the plane a little bit back (top view).
     * This will allow to see contour, name, cog when the plane is shaded.
     */
   MAidmx ( &msg, TransMat );
   TransMat[11] = -FRACTION * drwNormal[2];
   MAtypemx ( &msg, TransMat, &MatType );


   if(NbCrPlane > SM_MAX_DW_PL) NbCrPlane = SM_MAX_DW_PL;
   kk = 0;
   for(j=0;j<NbCrPlane;j++)
    {
     if(BelongTo[j] != -1 || CrvArea[j] != TRUE) continue;

     outPlane[kk].osnum = cst.env_info->md_id.osnum ;

     cvInfo.located_obj 	     = projList[j];
     cvInfo.module_info 	     = *cst.env_info;
     cvInfo.geom_parms.leaf_id	     = projList[j];

     loopset = TRUE;
     
     /*
      * Note : we only ask for the loopset to be constructed below
      * if there are more than one curve since we will need the plane
      * to have some topology for the impose boundary operation.
      */

     sts = om$construct(classid  = OPP_EMSplane_class_id,
			osnum	 = outPlane[kk].osnum,
			p_objid  = &outPlane[kk].objid);
     if(!(sts & 1))
      {
       printf("Error creating the EMSplane object\n");
       msg = MSFAIL ;
       goto wrapup ;
      }
       
     GRabsg_del_all();
     sts = om$send(msg = message EMSplane.EMplane_of_curve(
								   &msg,
				/* Construction list		*/ &cst,
				/* Encompassing curve		*/ &cvInfo,
				/* No imput BS curve		*/ NULL,
				/* No input curve type		*/ NULL,
				/* Test degeneracy ?		*/ TRUE,
				/* Construct loopset ?		*/ loopset,
				/* Don't care about orientation	*/ NULL,
				/* Don't want edges		*/ NULL ),
			targetid = outPlane[kk].objid,
			targetos = outPlane[kk].osnum);
     if( !( sts & 1 & msg ) )
      {
       printf("Error creating plane of curve\n");
       SMDelInterObj ( 1, &outPlane[kk], cst.env_info, FALSE );
       msg = MSFAIL ;
       goto wrapup ;
      }

     /* Take curves depending on this one if exist ... */
     NbBound=0;
     for(jj=0;jj<numProjs;jj++)
      {
       if(BelongTo[jj] == j)
        {
	 NbBound++;
	}
      }
      
     if(NbBound>0)
      {
       struct GRlc_info	*bndries	= NULL ;
       int		numBndries;
       long		mapOptions ;

       /* imcompasse a curve ... */

       numBndries = NbBound;  

       bndries = _MALLOC(numBndries, struct GRlc_info);
       if(bndries == NULL)
	{
	 msg = MSFAIL ;
	 goto wrapup ;
	}

       i = 0;
       for(jj=0;jj<numProjs;jj++)
        {
         if(BelongTo[jj] == j)
          {
	   bndries[i].located_obj = projList[jj];
	   bndries[i++].module_info = *cst.env_info ;
	  }
        }
       if(i!=NbBound){ printf("Grosse error getting the boundaries\n"); msg = MSFAIL; goto wrapup;}

       mapOptions = EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
		    EMMapBnd_WantStatMsg   | EMMapBnd_SurfIsPlane    |
		    EMImpBnd_NoStateTree;

       sts = om$send(msg = message EMSsurface.EMimpose_boundaries(
							&msg,
							numBndries,
			/* No bound. buffers	*/	NULL,	
							bndries,
			/* No point in area	*/	NULL,	
			/* No area: unused here	*/	TRUE,	
			/* Mod. env of plane	*/	cst.env_info,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							mapOptions,
							  EMImpBnd_NoStateTree
							| EMImpBnd_AutoNest
							| EMImpBnd_CloseReverse,
							NULL ),
			targetid= outPlane[kk].objid, 
			targetos= outPlane[kk].osnum ) ;

       /*
        * Free buffer then test restuen codes.
        */
       _FREE(bndries) ;
       if( !( sts & 1 & msg ) ) 
	{
	 printf("Error impose boundaries\n");
	 msg = MSFAIL ;
	 goto wrapup ;
	}
      
      }
      sts = om$send ( msg = message GRgraphics.GRxform ( &msg, cst.env_info,
				&MatType, TransMat, &TempObj.objid ),
			targetid= outPlane[kk].objid, 
			targetos= outPlane[kk].osnum ) ;
      outPlane[kk].objid = TempObj.objid;
      if( !( sts & 1 & msg ) ) 
	{
	 printf("Error GRxform\n");
	 msg = MSFAIL ;
	 goto wrapup ;
	}

     kk++;
    }
   _FREE(CrvArea) ;
   _FREE(BelongTo) ;
  }

if(CrContLn)
 {
  if(numProjs <= 0)
   {
    CrContLn = FALSE;
   }
  else
   {
    /*
     * We have and array of numProjs curves (projList), the firts one 
     * is the area, the others are holes.
     */

    printf("Contour with pos lines not yet imlemented\n");
    CrContLn = FALSE;
   }
 }


if(CrName || CrCog)
 {
  struct GRid       	TmpId;
  IGRchar		name[160];

  if(CrName)
   {
    /* Get the name of the object */

    if ( NameSymb.AttName[0] == '\0'  )
     {  sts = om$send(msg = message SMmgr.SMGetAttTxt(&msg,"name",name, NULL),
	       targetid = my_id);
	if(!(sts & msg & 1)) CrName = FALSE;
	if(name[0] == '\0')  CrName = FALSE;
     }
    else
     {  sts = om$send(msg = message SMmgr.SMGetAttTxt(&msg,NameSymb.AttName,name, NULL),
	       targetid = my_id);
        if(!(sts & msg & 1)) CrName = FALSE;
        if(name[0] == '\0')  CrName = FALSE;
     }
   }

  /* Get and copy the text point foot */
  sts = om$send(msg = message NDmacro.ACreturn_foot(&msg, "cog", &TmpId,
					NULL, NULL),
			targetid= my_id ) ;
  if(!(sts & 1 & msg)) goto wrapup;
 
  PtObj.osnum = cst.env_info->md_id.osnum;
  sts = om$send(msg = message GRgraphics.GRcopy(&msg, myEnv,
                                       cst.env_info, &PtObj.objid),
                        targetid = TmpId.objid,
                        targetos = TmpId.osnum);
  if(!(sts & msg &1))
   {
    printf("Error in GRcopy\n");
    goto wrapup;
   }
  /*
   * Now project onto drawing sheet along view vector.
   */
  if(CrCog)
   {
    if(!(SMCrvSymb(&CogSymb, &CurSymb, &ObjSymb, &MySymb) & 1)) goto wrapup;
    cst.level   = MySymb.level ;
    cst.display = &MySymb.display_attr ;
   }

/*  Drawing is not extracted when the active z-depth is not zero.
    The projection should be on drwPlane. vwPlane should be changed
    to drwPlane . The projection vector should be specified
    such that the curve is projected from view plane to drawing plane.
    In case of floor extraction, it should be from the floor to drawing
    plane.  Raju 08/27/93.
*/
  sts = EFproject_any_curve_on_planen(&msg, &cst, &PtObj,
				      cst.env_info, &vwPlane, vwVector,
				      &TmpId, &pjClassid);
  if(!(sts & 1 & msg))
   {
    printf("Bad point projection\n");
    msg = MSFAIL ;
    goto wrapup;
   }

  om$send(msg = message GRgraphics.GRdelete(&rc, cst.env_info),
				targetid= PtObj.objid,
				targetos= PtObj.osnum);
  PtObj = TmpId;

  if(CrName)
   {
    struct GRdpb_text_symb 	text_symb;
    IGRshort			text_len;
    struct IGRpolyline		polyline;
    IGRint			action;
    IGRdouble			pt[6];


    polyline.points = pt;

    /* Construct a text object */

    sizebuf = sizeof(text_symb);
    gr$get_text_symb(msg    = &msg,
                     sizbuf = &sizebuf,
                     buffer = &text_symb,
                     nret   = &nret);

    text_len = (IGRshort) strlen(name);

    if(NameSymb.options & SMDWTXUSR) text_symb.Active_just = NameSymb.TextJust;

    /* Get the point coord. */
    action = 1;
    sts = om$send(msg = message GRlinear.GRgetpolyline(&msg, 
     					&cst.env_info->md_env.matrix_type,
     					 cst.env_info->md_env.matrix,
					 &action, &polyline),
			targetid = PtObj.objid,
			targetos = PtObj.osnum);
    if(!(sts & msg & 1)) goto wrapup;

    if(!(SMCrvSymb(&NameSymb, &CurSymb, &ObjSymb, &MySymb) & 1)) goto wrapup;
    
/*  Text is not displayed properly when NAVY seed file is used.
    The text can be made view independent by specifying the properties
    as view independent. This will fix the problem.
    Raju 8/27/93
*/
    co$place_text(msg 		 = &msg,
                  text_string 	 = (IGRuchar *) name,
                  text_length 	 = &text_len,
                  rot_matrix 	 = drwEnv->md_env.matrix,
                  ActiveDisplay  = &MySymb.display_attr,
                  ActiveLevel 	 = MySymb.level,
                  TextSymb 	 = &text_symb,
                  origin 	 = polyline.points,
		  flags		 = 0,
		  ModuleInfo     = drwEnv,  /* Jean 17 june 93: problem if not put in range tree and add later (with cst.env_info) */
		  buffer 	 = &TextId);
 
    if(!(msg & 1))
     {
      printf("Error creating name as text\n");
      CrName = FALSE;
     }
   }
  if(CrCog == FALSE)
   {
    /* Delete the point */
    om$send(msg = message GRgraphics.GRdelete(&rc, cst.env_info),
				targetid= PtObj.objid,
				targetos= PtObj.osnum);
   }
 }

 NbObj = 0;
 if(CrCont && numProjs > 0) NbObj  = numProjs; 
 if(CrContLn  		  ) NbObj += 1;
 if(CrPlane 	          ) NbObj += NbCrPlane;
 if(CrName		  ) NbObj += 1;
 if(CrCog		  ) NbObj += 1;

 if(NbObj == 0) 
  {
   /* Nothing, bye, bye */
   _FREE(projList) ;
   *nbDrwElms = 0;
   *drwElms   = NULL;
   return OM_S_SUCCESS ;   
  }

 if( !(*drwElms = _MALLOC( NbObj, struct GRid))) 
  {
   msg = MSFAIL ;
   goto wrapup ;
  }
 
 *nbDrwElms = 0;
 if(CrCont && numProjs > 0)
  {
   /* Keep the curves */
   
   if(!(SMCrvSymb(&ContSymb, &CurSymb, &ObjSymb, &MySymb) & 1))
    {
     printf("Warning setting object symbology\n");
    }

   for(i=0;i<numProjs;i++) 
    {
     if(IF_NULL_OBJID(projList[i].objid)) continue ;
     (*drwElms)[*nbDrwElms] = projList[i];
     /* Modify the contour symbology */
     sts = om$send(msg = message GRvg.GRputsymb(&rc, &MySymb),
   				targetid = (*drwElms)[*nbDrwElms].objid,
   				targetos = (*drwElms)[*nbDrwElms].osnum);
     if(!(sts & rc & 1)) printf("Warning when setting the symbology\n");
     (*nbDrwElms)++;
    }
  }
 else
  {
   /* Get rid of projection curves */
   if( projList ) 
    {
     for( i = 0 ; i < numProjs ; i++ ) 
      {
       if(IF_NULL_OBJID(projList[i].objid)) continue ;

       om$send(msg = message GRgraphics.GRdelete(&rc, cst.env_info ),
				targetid= projList[i].objid,
				targetos= projList[i].osnum ) ;
       }
    }
  }
 _FREE(projList) ;

 if(CrPlane && NbCrPlane > 0) 
  {
   for(i=0;i<NbCrPlane;i++)
    {
     if(!(IF_NULL_OBJID(outPlane[i].objid)))
      {
       (*drwElms)[*nbDrwElms] = outPlane[i];

       /* Modify the contour symbology */
       if(!(SMCrvSymb(&PlaneSymb, &CurSymb, &ObjSymb, &MySymb) & 1))
        {
         printf("Warning setting object symbology\n");
        }
       sts = om$send(msg = message GRvg.GRputsymb(&rc, &MySymb),
   				targetid = (*drwElms)[*nbDrwElms].objid,
   				targetos = (*drwElms)[*nbDrwElms].osnum);
       if(!(sts & rc & 1)) printf("Warning when setting the symbology\n");
       (*nbDrwElms)++;
      }
    }
  }

if(CrCog)
 {
  (*drwElms)[*nbDrwElms] = PtObj;
  (*nbDrwElms)++;
 }

/* Put all object (except name already there) in range tree */
if(drwEnv->md_id.objid != NULL_OBJID)
 {
  for(i=0;i<*nbDrwElms;i++)
   {
    /* Add to the Rtree */
    sts = om$send(msg = message GRgraphics.GRaddwrng(&msg, drwEnv),
                                targetid = (*drwElms)[i].objid,
                                targetos = (*drwElms)[i].osnum);
    if(!(sts&1))
     {
      printf("Warning, failed adding to the rtree object %d %d\n",(*drwElms)[i].objid,(*drwElms)[i].osnum);
     }
   }
 }

/* Name is already in range tree */
if(CrName)
 {
  (*drwElms)[*nbDrwElms] = TextId;
  (*nbDrwElms)++;
 }

if(0) *nbDrwElms = 0;
return OM_S_SUCCESS ;
 
wrapup :

return OM_W_ABORT;
} /* method NDdrawing_copy_geom */

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMBidouilleCurves

  Abstract

	This function is used to modify the curve geometry of some
	curves.
 	That's because in the curves resulting from the surface/plane 
	intersections,	there are some gap between curves which should 
	not exist.
 	The following find this gap and reconnect curves when needed.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
SMBidouilleCurves(NbCv, CrvIn, Type, cst, NbOutCv, OutCv)
IGRint              NbCv;     /* Number of input curves                 (I) */
struct GRobj_env    CrvIn[];  /* Array of curves (can be composite)     (I) */
IGRshort            Type;     /* 0 => Merge, 1 => Merge, curves deleted (I) */ 
                              /* 2 => Comp , 2 => Comp , curves deleted (I) */ 
struct GRvg_construct *cst;   /* construction list                      (I) */
IGRint              *NbOutCv; /* Number of created curves               (O) */
struct GRid         **OutCv;  /* Output curves (allocated here)         (O) */
/*
-fi */
{

  struct GRobj_env      *CrvOut = NULL;
  IGRdouble             SearchTol, BaseTol;
  IGRint                NumSeg, *SegList = NULL;
  IGRshort              *iv = NULL;
  IGRboolean            *AdjPhy = NULL;
  IGRshort              *CreComp = NULL;
  IGRlong               nput, nret;
  struct GRlc_info      *entries = NULL;  
  IGRint                i, msg;
  IGRint                rc;

  *NbOutCv = 0;
  *OutCv   = NULL;

  if(NbCv <= 0) return 0;
  
  if(NbCv == 1)
   {
    *OutCv = _MALLOC(1, struct GRid);
    if(OutCv == NULL) goto wrapup;
    
    *NbOutCv = 1;
    (*OutCv)[0] = CrvIn[0].obj_id;
    return 1;
   }

  CrvOut = _MALLOC(NbCv, struct GRobj_env);
  if(CrvOut == NULL) goto wrapup;

  iv = _MALLOC(NbCv, IGRshort);
  if(iv == NULL) goto wrapup;

  SegList = _MALLOC(NbCv, IGRint);
  if(SegList == NULL) goto wrapup;

  AdjPhy = _MALLOC(2*NbCv, IGRboolean);
  if(AdjPhy == NULL) goto wrapup;

  nput = sizeof(BaseTol);
  gr$get_basis_tolerance(msg    = &msg    , sizbuf = &nput, 
                         buffer = &BaseTol, nret   = &nret);
    
  nput = sizeof(SearchTol);
  gr$get_chord_height_tolerance(msg    = &msg      , sizbuf = &nput,
                                buffer = &SearchTol, nret   = &nret);
  SearchTol = 2 * SearchTol; /* What it has to do */

  RngCrv(CrvIn, NbCv, SearchTol, BaseTol, CrvOut, iv, &NumSeg, SegList, 
         AdjPhy, &rc);
  if(rc != BSSUCC) goto wrapup;

  /* Create Merged curves */
  CreComp = _MALLOC(NbCv, IGRshort);
  if(CreComp == NULL) goto wrapup;

  *OutCv = _MALLOC(NumSeg, struct GRid);
  if(OutCv == NULL) goto wrapup;

  entries = _MALLOC(NbCv, struct GRlc_info);
  if(entries == NULL) goto wrapup;

  for(i=0;i<NbCv;i++) CreComp[i] = Type;

  BuildCrvFromList(CreComp, CrvOut, iv, NumSeg, SegList, AdjPhy, entries, 
                   cst, *OutCv, &rc);
  if(rc != BSSUCC) goto wrapup;

  _FREE(CrvOut) ;  
  _FREE(iv)       ;
  _FREE(SegList) ;
  _FREE(AdjPhy) ;
  _FREE(CreComp)  ;
  _FREE(entries) ;

  *NbOutCv = NumSeg;
  return 1;

  wrapup :

  _FREE(CrvOut)  ;
  _FREE(iv)      ;
  _FREE(SegList) ;
  _FREE(AdjPhy) ;
  _FREE(CreComp);
  _FREE(entries);

  *NbOutCv = 0; 
  _FREE(*OutCv)  ;
  return 0;
}

	
end implementation SMcomp ;
