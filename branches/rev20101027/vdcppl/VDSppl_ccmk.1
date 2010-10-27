/*
	VDS 2.1 - PPM macro library - utilities
	Filename : VDSppl_ccmk.I

	Description : This library defines the OrderCrv() and BuildCrv()
		functions used by the ci macros crv_comp and crv_merge
		(if necessary the curves are modified within a tolerance
		equal to five times the chord height tolerance).

   	History :

	92/08/15 jll Add search mechanism to build a composite curve from 
			curves containing eventually gaps between them.
	92/10/05 jll fixes in BuildCrv()
		     new function RngCrv(), BuildCrvFromList(),
		     SortAndBuildCrv().	     
	92/10/14 alc Integration into VDS 2.1 (get rid again of NDcopy_to_root())
	93/02/25 alc Construct AScompcurve in BuildCrv()
 */



class implementation Root ;

#include <stdio.h>

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "bsparameters.h"

#include "msdef.h"			/* MSSUCC */
#include "grerr.h"			/* GRILLDEFINITION */
#include "madef.h"			/* MAIDMX */
#include "bserr.h"			/* BSSUCC for next .h */

#include "growner.h"			/* GRobj_env */
#include "AS_status.h"

#define AS_DEBUG

from GRgraphics		import GRconstruct;
from GRgraphics 	import GRaltconstruct;
from GRgraphics		import GRdelete;
from GRgraphics		import GRcopy;
from GRcurve		import GRendpts;
from AScompcurve	import EMmakecomp;
from GRconnector	import GRrigidconn;
from NDnode             import NDcopy_to_root;


from GRvg		import GRgetsize;
from GRvg		import GRgetgeom;
from GRvg		import GRputsymb;
from GRsubbc		import EMmerge_curves;

extern GRclassid	OPP_GR3dlinestr_class_id;
extern GRclassid	OPP_GRbcsubbc_class_id;
extern GRclassid	OPP_GRsubbc_class_id;
extern GRclassid	OPP_AScompcurve_class_id;


/* ----
%HD%
 
     MODULE NAME OrderCrv
 
     Abstract:
        From a list of non ordered curves and not necessarely connected,
	This function builds a new list of ordered curves with the
	right orientation related to each of it.
	The order and orientation are driven by the first curve in the
	input list.
	If the curve is Physicaly closed then the first input curve
	will stay the first output curve.
	Usually the CrvOut list should be different that the CrvIn.

-----
%SC%

     OrderCrv( CrvIn, NbCrv, SearchTol, BaseTol, 
	       I    , I    , I        , I
	
	       CrvOut, Orient, AdjNeeded, PhyClosed, rc)
	       O     , O     , O        , O        , O
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        CrvIn[]	   struct GRobj_env  List of the input curves to order
	
        NbCrv      IGRint 	     Number of curves

	SearchTol  IGRdouble	     Maximun permitted distance between
				     the end points of each curve.
				     this variable is used to search the
				     nearest end point from a given one.
				     If you want you can give a large value.

	BaseTol	   IGRdouble	     when can we say that two points
				     are coincident
	     	      
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	CrvOut[]   struct GRobj_env  List of the output curve in the good
				     order

	*Orient    IGRshort		list containing the direction flag
				     associated to each curve.
				     If Orient[i] == 1 then the CrvOut[i]
				     will remain the the orientation.
				     else if Orient[i] == -1 then CrvOut[i]
				     should be reverse to fit with the
				     direction of the first curve.

	*AdjNeeded IGRboolean	     Informs the caller that to have the curve
				     mactching with the BaseTol He will have
				     to do something.

	*PhyClosed IGRboolean	     It's often usefull to know if the 
				     resulting list is Physicaly closed
				     or not.

        *rc        IGRshort        completion code message
                                 	- if curve are within the SearchTol
				          we should get always BSSUCC
				        - else BSFAIL
  
-----
%MD%

     MODULES INVOKED: BSmkvec, BSdotp
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 14 august 1992 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/
/*
#include "bstypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
*/

void OrderCrv( CrvIn, NbCrv, SearchTol, BaseTol,
/*        I    , I    , I        , I      ,				*/
 
	  CrvOut, Orient, AdjNeeded, PhyClosed, rc)
/*        O     , O     , O        , O        , O			*/


struct 	  GRobj_env	CrvIn[];
IGRint			NbCrv;
IGRdouble		SearchTol;
IGRdouble		BaseTol;
struct	  GRobj_env	CrvOut[];
IGRshort		*Orient;
IGRboolean		*AdjNeeded;
IGRboolean		*PhyClosed;
IGRlong			*rc;


{

IGRint		i, iM6, imin, nbrg, j, je, jc, icou, k;
IGRdouble	*cou;
IGRlong		suc;
IGRdouble	sup;
IGRdouble	vect[3];
IGRdouble	diff;
IGRdouble	ext[6];
IGRdouble	BaseTol2;
IGRdouble	SearchTol2;

extern			BSmkvec();
extern  IGRdouble	BSdotp();

	*rc = BSFAIL;
	cou = NULL;
	*AdjNeeded = FALSE;
	*PhyClosed = FALSE;

	if( NbCrv < 1 ){
		*rc = BSFAIL;
		return;	
	}

	/* --- single case if just only one curve as input --- */

	if( NbCrv == 1 ){

		BaseTol2 = BaseTol * BaseTol;
		*rc = BSSUCC;
		Orient[0] = 1;
		CrvOut[0] = CrvIn[0];
		
		om$send ( msg = message GRcurve.GRendpts ( 
				  &suc,
				  &CrvIn[0].mod_env.md_env.matrix_type,
				  CrvIn[0].mod_env.md_env.matrix,
				  &ext[0],
				  &ext[3] ),
			  targetid = CrvIn[0].obj_id.objid,
			  targetos = CrvIn[0].obj_id.osnum,
			  senderid = NULL_OBJID );
		BSmkvec(&suc, vect, &ext[0],&ext[3]);
		diff = BSdotp(&suc,vect,vect);
		if( diff > BaseTol2 ) *PhyClosed = FALSE;
		else 		      *PhyClosed = TRUE;

		return;
	}


  	cou = (IGRdouble *)  om$malloc(size = 6*NbCrv * sizeof(IGRdouble) );
	if( cou == NULL ){
		printf("Error in OrderCrv to malloc cou\n");
		*rc = BSFAIL;
		return;
	}

	/* --- read the end points of each curve and store it --- */

	for(i=0;i<NbCrv;i=i+1){
		Orient[i] = i;
		iM6 = i * 6;
		om$send ( msg = message GRcurve.GRendpts ( 
				  &suc,
				  &CrvIn[i].mod_env.md_env.matrix_type,
				  CrvIn[i].mod_env.md_env.matrix,
				  &cou[iM6],
				  &cou[iM6+3] ),
			  targetid = CrvIn[i].obj_id.objid,
			  targetos = CrvIn[i].obj_id.osnum,
			  senderid = NULL_OBJID );

	}

	memcpy( (IGRchar*)&ext[0],(IGRchar *)&cou[0],
	        (IGRint) (6 * sizeof(IGRdouble)) );

	nbrg = 0;
	BaseTol2 = BaseTol * BaseTol;
	SearchTol2 = SearchTol * SearchTol;


Un:

	je = 3;

	if( nbrg >= (NbCrv-1) ){

		/* --- We got a well ordered Orient array containing the index
		       of the input GRobj_env with a negative sign or not
		       depending if the curve should be reverse or not.
		       Now We just fill corectly the output list.
		 --- */

		BSmkvec(&suc, vect, &ext[0],&ext[3]);
		diff = BSdotp(&suc,vect,vect);
		if( diff > SearchTol2 ) *PhyClosed = FALSE;
		else 		        *PhyClosed = TRUE;

		*rc = BSSUCC;

		for(i=0;i<NbCrv;i=i+1){

			j = Orient[i];

			if( j < 0 ){
				j = -j;
				k = -1;
			}
			else k = 1;

			CrvOut[i] = CrvIn[j];
			Orient[i] = k;
		}

		goto wrapup;
	}

	nbrg = nbrg + 1;


Deux:
	/*--- We try to find which curve within the non sorted curve is
	      matching with one of the two end points.
	      if the first end point is not matching with any, then
	      imin will be equal to -1 and we will try with the second
	      end point.
	---*/

	imin = -1;
	sup = SearchTol2;

	for(i=nbrg;i<=(NbCrv-1);i=i+1){

		icou = 6*Orient[i];

		for(j=0;j<6;j=j+3){
			BSmkvec(&suc, vect, &cou[icou+j],&ext[je]);
			diff = BSdotp(&suc,vect,vect);
			if( diff <= sup ){
				sup  = diff;
				imin = i;
				jc   = j;
			}
		}
	}

	if( imin < 0 ){
		je = je - 3;
		if( je == 0 ) goto Deux;
		else{
			printf("Error in OrderCrv no order curve\n");
			*rc = BSFAIL;
			goto wrapup;
		}
	}

	if( sup > BaseTol2 ) *AdjNeeded = TRUE; 

	/* --- rangement --- */

	icou = Orient[imin];
	
	/* --- Update the ext array containing my two end points --- */
	
	memcpy((IGRchar*)&ext[je],(IGRchar *)&cou[6*icou+3-jc],
	(IGRint) (3 * sizeof(IGRdouble)) );

	if( je == jc ) icou = -icou;
	
	/* --- Update Orient array:
		. IF the index of reference end point stored in the ext array
		  is equal to the index of the end point attach to the
		  curve solution THEN the should will be reverse.
		. IF the index of the reference end point is equal to 3 then
		  the curve will come in the next position in the list 
		  ElSE The curve solution should be in the first position
		  in the list.
	---*/

	if( je == 3 ){
		Orient[imin] = Orient[nbrg];
		Orient[nbrg] = icou;
	}
	else{
		Orient[imin] = Orient[nbrg];
		for(i=0; i<=(nbrg-1); i=i+1){
			j = nbrg - i - 1;
			Orient[j+1] = Orient[j];
		}

		Orient[0] = icou;
	}

	goto Un;


wrapup:
	if( cou != NULL ) om$dealloc( ptr = cou );
	return;
}

/* ======================================================================= */
 
/*  MODULE NAME BuildCrv()
 
     Abstract:
        From a list of ORDERED curves which are NOT necessary connected 
	in the sense of the BaseTol, this function creates, dependanding
	of the caller choise, via the argument ActionFlag a Bspline or a
	composite curve.
	The function will modify the extremities of the curves to match
	with the BaseTol or just the requested curve.
	To use this function the caller should call first the function
	OrderCrv() to get:
		. the curves in the good order
		. to know if We should adjust the ends of the curves.
		. if the resulting ordered curves are physicaly closed
		. if they should be reversed.

    Inputs :

	ActionFlag  IGRshort	     IF ActionFlag = 0 THEN a Bspline curve
					is created.
				     IF ActionFlag = 1 THEN a Bspline curve
				        is created and the Input curves
					in the OrdCrv array are deleted.

				     IF ActionFlag = 2 THEN a Composite curve
					is created.
				     IF ActionFlag = 3 THEN a Composite curve
				        is created and the Input curves
					in the OrdCrv array are deleted or
					owned depending of the flag
					AdjNeeded.
				     
        OrdCrv[]   struct GRobj_env  List of ordered curves not matching
				     perfectly
	
        NumCrv     IGRint 	     Number of curves

	*Orient    IGRshort	     list containing the direction flag
				     associated to each curve.
				     If Orient[i] == 1 then the OrdCrv[i]
				     will remain the the orientation.
				     else if Orient[i] == -1 then OrdCrv[i]
				     should be reverse to fit with the
				     direction of the first curve.

	AdjNeeded  IGRboolean	     If AdjNeeded then we will modify
				     all the necessary curves.

	PhyClosed  IGRboolean	     It's often usefull to know if the 
				     resulting list is Physicaly closed
				     or not, here for example to make
				     the start and the and perfectly
				     matching.
	     	      
	*Cst struct  GRvg_construct	Construction list.

 */

void BuildCrv( 
	ActionFlag, 	/* I */
        OrdCrv,		/* I */
	NumCrv,		/* I */
	Orient,		/* I */
	AdjNeeded,	/* I */
	PhyClosed,	/* I */
	OutCrv,		/* O - list of the modified curves      */
	Cst,		/* I */
	NewCrv,		/* O - created composite curve          */
	rc 		/* O - completion code BSSUCC or BSFAIL */ 
	     )

IGRshort		ActionFlag ;
struct	GRobj_env	OrdCrv[]   ;
IGRint			NumCrv     ;
IGRshort		Orient[]   ;
IGRboolean		AdjNeeded  ;
IGRboolean		PhyClosed  ;
struct  GRvg_construct  *Cst       ;
struct	GRlc_info	OutCrv[]   ;
struct	GRid		*NewCrv ;
IGRlong			*rc ;

/*.BuildCrv */
{

OMuword                 ft_cl;

IGRlong			rotten_one ;
IGRint			i, k, NumCrvM1;
IGRlong			stat, size, suc;
struct	IGRbsp_curve	**crv, *MergeCrv;
IGRint			ind1, ind2;

struct	GRvg_construct	const_list;
IGRlong			loc_msg;
struct   GRsymbology	symbology;

extern void		BSmergarrcv();
extern IGRboolean	BSfreecv();
extern			GRabsg_del_by_objid();


IGRchar			err_loc[80];


MergeCrv      = NULL;
*rc           = BSFAIL;
crv 	      = NULL;
NewCrv->objid = NULL_OBJID;
sprintf(err_loc, "BuildCrv");

const_list.msg 		= (IGRlong *)&loc_msg;
const_list.class_attr 	= NULL;
const_list.level	= Cst->level;
const_list.display	= Cst->display;
const_list.env_info	= Cst->env_info;
const_list.newflag	= FALSE; 
const_list.name		= NULL;
const_list.properties	= Cst->properties;
const_list.geometry	= NULL ;


if( AdjNeeded == TRUE ){

	/* --- here for ASSOC and EMS reasons I need to modify the extremities
	   of the given curves For that I:
		- depending of the inversion flag, I am able to get 
		  the corresponding ends and evaluate the mid point of them.
		  this mid point will become the new end of the according
		  curves.
		- construct new curves as Bspline because I cab't apply the
		  GRmodify mechanism for conics.
		- AScompcurve is an owner and then consume the parents
		  which is not the case for GRbcsubbc. To make this function
		  usable in the assoc or no assoc mode I provided all 
		  all these options via the ActionFlag argument
	--- */


	/* --- recover the BSgeometry of the ordered curves ---*/
 
	crv = (struct IGRbsp_curve **) om$malloc (
					    size = NumCrv * sizeof(char *) );
	if (crv == NULL) {
		stat = 0 ; as$status(sts = stat) ; *rc = BSFAIL ;
		return ;	
		}

	for (i=0 ; i<NumCrv ; i=i+1){

		GRabsg_del_by_objid( &OrdCrv[i].obj_id.objid,
				     &OrdCrv[i].obj_id.osnum ) ;

  		stat = om$send( msg = message GRvg.GRgetsize(
					&suc,
            				&OrdCrv[i].mod_env.md_env.matrix_type,
            				OrdCrv[i].mod_env.md_env.matrix,
					&size ),
			targetid = OrdCrv[i].obj_id.objid,
			targetos = OrdCrv[i].obj_id.osnum,
			senderid = NULL_OBJID );

		if( ! ( suc & stat & 1) ) {
			as$status(sts = stat) ; *rc = BSFAIL ; goto wrapup;
        		}

        	crv[i] = (struct IGRbsp_curve *)  om$malloc( size = size );
		if( crv[i] == NULL ) {
			as$status(sts = stat) ; *rc = BSFAIL ; goto wrapup;
			}

		stat = om$send( msg = message GRvg.GRgetgeom(
					&suc,
					&OrdCrv[i].mod_env.md_env.matrix_type,
					OrdCrv[i].mod_env.md_env.matrix,
					(char *)crv[i]
					),
        			targetid = OrdCrv[i].obj_id.objid,
				targetos = OrdCrv[i].obj_id.osnum,
				senderid = NULL_OBJID );

		if( ! ( suc & stat & 1) ){
			stat = 0 ; as$status(sts = stat) ;
			printf("GRvg.GRgetgeom Error for crv = %d \n", i); 
        		*rc = BSFAIL ; goto wrapup ;
			}
	}

	NumCrvM1 = NumCrv-1;

	/* --- Adjust the end points --- */

	for(i=0;i<NumCrvM1;i=i+1)
	{
		if( Orient[i] == -1 ) ind1 = 0;
		else		  ind1 = 3 * (crv[i]->num_poles - 1);

		if( Orient[i+1] ==  1 ) ind2 = 0;
		else		    ind2 = 3 * (crv[i+1]->num_poles - 1);

		for(k=0;k<3;k=k+1)
		{
		    crv[i]->poles[ind1+k] = ( crv[i]->poles[ind1+k] +
					      crv[i+1]->poles[ind2+k] ) * 0.5;
		    crv[i+1]->poles[ind2+k] = crv[i]->poles[ind1+k];
		}
	}

	
	if( PhyClosed == TRUE )
	{
		/* --- Adjust the "origin" of the first curve with the "end"
		       of the last one.
		--- */
 
		if( Orient[0] == 1 ) ind1 = 0;
		else		 ind1 = 3 * (crv[0]->num_poles - 1);

		if( Orient[NumCrvM1] == -1 ) ind2 = 0;
		else		         
				ind2 = 3 * (crv[NumCrvM1]->num_poles - 1);
		
		for(k=0;k<3;k=k+1){
		 crv[0]->poles[ind1+k] = ( crv[0]->poles[ind1+k] +
					   crv[NumCrvM1]->poles[ind2+k] ) * 0.5;
		 crv[NumCrvM1]->poles[ind2+k] = crv[0]->poles[ind1+k];
		}
	}

	if( (ActionFlag == 0) || (ActionFlag == 1) ){

		/* --- Build the curve as a merge_curve --- */

		BSmergarrcv(NumCrv, crv, &MergeCrv, &suc );
		if( suc != BSSUCC ) {
			stat = 0 ; as$status(sts = stat) ;
			*rc = BSFAIL ; goto wrapup ;
                	}

		NewCrv->objid = NULL_OBJID;
		NewCrv->osnum = Cst->env_info->md_id.osnum;
		Cst->geometry	      = (char *) MergeCrv;
		
		stat = om$construct( msg   = message GRgraphics.GRconstruct(Cst),
				classid	= OPP_GRbcsubbc_class_id,
				p_objid	= &NewCrv->objid,
				osnum	= NewCrv->osnum );

		if( ! (1 & stat ) )
		{
			stat = 0 ; as$status(sts = stat) ; *rc = BSFAIL ;
			goto wrapup;
                }

		if( ActionFlag == 1 )
		{
			/* --- delete the original parents if requested --- */
			for(k=0 ; k<NumCrv; k=k+1) 
			{
     			   stat = om$send(msg      = message GRgraphics.GRdelete(
					&suc, &OrdCrv[k].mod_env ),
				targetid = OrdCrv[k].obj_id.objid,
				targetos = OrdCrv[k].obj_id.osnum,
				senderid = NULL_OBJID ) ;
			  as$status( sts = stat, msg = 
			  	"GRdelete 1 of parents" );
                        }
	   	}

		if ( stat & 1 ) *rc = BSSUCC ;
		else *rc = BSFAIL ;

	}	/* if( (ActionFlag == 0) || (ActionFlag == 1) ) */
	else if ( (ActionFlag == 2) || (ActionFlag == 3 )  )
	{
		/* --- Build the curve as a comp_curve --- */
	
		for(i=0;i<NumCrv;i=i+1)
		{
	
			/*
			 *	Construct new component curves with modified
			 *	geometry
			 */
			
			OutCrv[i].located_obj.objid = NULL_OBJID;
			OutCrv[i].located_obj.osnum = 
				Cst->env_info->md_id.osnum;
			Cst->geometry	      = (char *) crv[i];
	
			stat = om$construct(
				msg   = message GRgraphics.GRconstruct(Cst),
				classid	= OPP_GRbcsubbc_class_id,
				p_objid = &OutCrv[i].located_obj.objid,
				osnum  = OutCrv[i].located_obj.osnum );
	
			if( ! (stat&1) ) {
				stat = 0 ; as$status(sts = stat) ;
				printf("Error in GRbcsubbc.GRconstruct for crv = %d \n", i) ;
	
				NewCrv->objid = NULL_OBJID;
				 			
				for(k=0 ; k<i ; k=k+1)
				{
					stat = om$send(
					 msg      = message GRgraphics.GRdelete(
							&suc, Cst->env_info ),
		             		 targetid = OutCrv[k].located_obj.objid,
					 targetos = OutCrv[k].located_obj.osnum,
					 senderid = NULL_OBJID ) ;
					as$status( sts = stat, msg =
						"Error at GRdelete 1 of OutCrv" );
				}
			    	*rc = BSFAIL ; goto wrapup ;
			}
	
			memcpy( (IGRchar*)&OutCrv[i].module_info,
				(IGRchar *)Cst->env_info,
				(IGRint) sizeof(struct GRmd_env) );

		} /* for i ... */

		/*
		 *	Construct the composite curve
		 */
		 
		NewCrv->objid = NULL_OBJID;
		NewCrv->osnum = Cst->env_info->md_id.osnum;

#if 0
	- Note 93/02/25 : ASnode.GRconstruct() failed in this case -
		stat = om$construct ( msg 	= message GRgraphics.GRconstruct
						( &const_list ),

				classid	= OPP_AScompcurve_class_id,	
				p_objid	= &NewCrv->objid,
 				osnum  	= NewCrv->osnum );
#endif
		stat = om$construct ( msg = OM_Gp_NULL_MESSAGE,
				classid	= OPP_AScompcurve_class_id,	
				p_objid	= &NewCrv->objid,
 				osnum  	= NewCrv->osnum );

		if ( !(stat&1)) {
			stat = 0 ; as$status(sts = stat) ;
		    	*rc = BSFAIL;
		    	goto wrapup;
			}	

		stat = om$send( msg      = message AScompcurve.EMmakecomp(  
							      &suc,
							      Cst->env_info,
							      NumCrv,
	   						      OutCrv,
							      &rotten_one  ),
			targetid = NewCrv->objid,
			targetos = NewCrv->osnum,
			senderid = NULL_OBJID );

		if (! (stat & suc & 1)) {

			stat = 0 ; as$status(sts = stat) ;
		  /*
		   *	If comp curve construction fails, delete new
		   *	curves, and keep old input curves
		   */

		  for(k=0 ; k<NumCrv; k=k+1)
		  {
     			stat = om$send(msg      = message GRgraphics.GRdelete(
					&suc, Cst->env_info ),
             		 targetid = OutCrv[k].located_obj.objid,
			 targetos = OutCrv[k].located_obj.osnum,
			 senderid = NULL_OBJID ) ;
			as$status( sts = stat, msg =
					"Error at GRdelete 2 of OutCrv" );
		  }
		  
		  *rc = BSFAIL;
		  goto wrapup;	    
		}
		

		if( ActionFlag == 3 )
		{
			/* --- delete the original parents if requested --- */
			for(k=0 ; k<NumCrv; k=k+1)
			{
	     			stat = om$send(msg      = message GRgraphics.GRdelete(
						&suc, &OrdCrv[k].mod_env ),
				 targetid = OrdCrv[k].obj_id.objid,
				 targetos = OrdCrv[k].obj_id.osnum,
				 senderid = NULL_OBJID ) ;
				
				as$status( sts = stat, msg = 
			  		"GRdelete 2 of parents" );
			}
		}

		*rc = BSSUCC;

	}/* end else if ( (ActionFlag == 1) || (ActionFlag == 2 )  ) */

	goto wrapup;

}/* --- end of AdjNeede == TRUE --- */

else{

	/* --- case where I do not need to modify the original curves --- */

	if( ActionFlag == 0 ){

		/* --- just created a merge_curve WITHOUT deleting the 
		       original parents 
		--- */

		for(i=0;i<NumCrv;i=i+1){
			OutCrv[i].located_obj = OrdCrv[i].obj_id;
			OutCrv[i].module_info = OrdCrv[i].mod_env;
 		}

	    	NewCrv->objid = NULL_OBJID;
	    	NewCrv->osnum = Cst->env_info->md_id.osnum;
		Cst->geometry = NULL;

		stat = om$construct( classid = OPP_GRbcsubbc_class_id,
				     p_objid = &NewCrv->objid,
				     osnum   = NewCrv->osnum,
				     msg     = message GRsubbc.EMmerge_curves(
                                                   NumCrv,OutCrv,Cst,&suc));

		if( !stat&suc&1 ){
			printf("error in GRsubbc.EMmerge_curves 0\n");
			stat = 0 ; as$status(sts = stat) ; *rc = BSFAIL ;
		    	goto wrapup;
			} 
	
	}
	else if( ActionFlag == 1){

		/* --- just created a merge_curve AND delete the 
		       original parents 
		--- */

		for(i=0;i<NumCrv;i=i+1){
			OutCrv[i].located_obj = OrdCrv[i].obj_id;
			OutCrv[i].module_info = OrdCrv[i].mod_env;
 		}

	    	NewCrv->objid = NULL_OBJID;
	    	NewCrv->osnum = Cst->env_info->md_id.osnum;
		Cst->geometry = NULL;

		stat = om$construct( classid = OPP_GRbcsubbc_class_id,
				     p_objid = &NewCrv->objid,
				     osnum   = NewCrv->osnum,
				     msg     = message GRsubbc.EMmerge_curves(
                                                   NumCrv,OutCrv,Cst,&suc));

		if( !stat&suc&1 ){
			printf("error in GRsubbc.EMmerge_curves 1\n");
			stat = 0 ; as$status(sts = stat) ; *rc = BSFAIL ;
		    	goto wrapup;
			} 


     		for(i=0 ; i<NumCrv; i=i+1) {
     			stat = om$send(msg      = message GRgraphics.GRdelete(
					&suc, &OrdCrv[i].mod_env ),
					targetid = OrdCrv[i].obj_id.objid,
					targetos = OrdCrv[i].obj_id.osnum,
					senderid = NULL_OBJID ) ;
			  as$status( sts = stat, msg = 
			  	"GRdelete 3 of parents" );
		}

	}
	else if( ActionFlag == 2 ){

		/* --- Create a comp_curve WITHOUT deleting or consuming the 
		       parents, I need first to make a copy of everybody
		note :	NDcopy_to_root() is  needed in 1.4.5
		--- */

		for (i=0 ; i<NumCrv ; i=i+1) {
                   om$get_classid( osnum     = OrdCrv[i].obj_id.osnum,
                                   objid     = OrdCrv[i].obj_id.objid,
                                   p_classid = &ft_cl   ) ;

		   
		   OutCrv[i].located_obj.objid = NULL_OBJID;

#if 0
not needed - not needed
                   if( om$is_ancestry_valid(
                                superclassid    = ass_cl,
                                subclassid      = ft_cl ) == OM_S_SUCCESS ) {
                        stat = om$send( msg = message NDnode.NDcopy_to_root(
                                        &suc,
                                        0,
                                        &OrdCrv[i].mod_env,
                                        Cst->env_info,
                                        &OutCrv[i].located_obj  ),
                                targetid = OrdCrv[i].obj_id.objid,
                                targetos = OrdCrv[i].obj_id.osnum,
                                senderid = NULL_OBJID ) ;
                        if( !(stat & suc & 1)){
			   printf("Error in NDnode.NDcopy_to_root\n");
			   as$status(sts = stat) ;

                           for(k=0 ; k<i; k=k+1)
                           {
                             stat = om$send(msg = message GRgraphics.GRdelete(
                                        &suc, &OutCrv[k].module_info ),
                                        targetid = OutCrv[k].located_obj.objid,
                                        targetos = OutCrv[k].located_obj.osnum,
                                        senderid = NULL_OBJID ) ;

                                as$status( sts = stat, msg =
                                        "Error at GRdelete 3 of OutCrv" );
                           }
                           goto wrapup;

                        }
                   }

                   else { /* non-associative parent */
not needed - not needed
#endif

		   OutCrv[i].located_obj.osnum = NULL_OBJID;
		   OutCrv[i].located_obj.osnum = Cst->env_info->md_id.osnum;

		   stat = om$send( msg	   = message GRgraphics.GRcopy(
						&suc,
					        &OrdCrv[i].mod_env,
                               	                Cst->env_info,
					        &OutCrv[i].located_obj.objid),
                        	targetid = OrdCrv[i].obj_id.objid,
				targetos = OrdCrv[i].obj_id.osnum,
				senderid = NULL_OBJID ) ; 

        	   if(! (stat & suc & 1)) {
			   printf("Error in GRgraphics.GRcopy\n");

			stat = 0 ; as$status(sts = stat) ; *rc = BSFAIL ;

			for(k=0 ; k<i; k=k+1)
			   {
     			     stat = om$send(msg = message GRgraphics.GRdelete(
					&suc, &OutCrv[k].module_info ),
             			  	targetid = OutCrv[k].located_obj.objid,
					targetos = OutCrv[k].located_obj.osnum,
					senderid = NULL_OBJID ) ;
			     as$status( sts = stat, msg =
					"Error at GRdelete 4 of OutCrv" );
                           }
			   goto wrapup;

        		}
#if 0
not needed - not needed
                  } /* end non-associative parent */
not needed - not needed
#endif

		  memcpy( (IGRchar*)&OutCrv[i].module_info,
		  	  (IGRchar *)Cst->env_info,
			  (IGRint) sizeof(struct GRmd_env) );


		}/* end loop on i */


		NewCrv->objid = NULL_OBJID;
		NewCrv->osnum = Cst->env_info->md_id.osnum;

#if 0
	- Note 93/02/25 : ASnode.GRconstruct() failed in this case -
		stat = om$construct ( msg 	= message GRgraphics.GRconstruct
						( &const_list ),

				      classid	= OPP_AScompcurve_class_id,	
				      p_objid	= &NewCrv->objid,
 				      osnum  	= NewCrv->osnum );
#endif
		stat = om$construct ( msg 	= OM_Gp_NULL_MESSAGE,
				      classid	= OPP_AScompcurve_class_id,	
				      p_objid	= &NewCrv->objid,
 				      osnum  	= NewCrv->osnum );


		if ( !(stat&1)) {
			printf("Error in GRconstruct for NewCrv\n");
			stat = 0 ; as$status(sts = stat) ;
		    	*rc = BSFAIL;
		    	goto wrapup;
			}	

   	    	stat = om$send(msg      = message AScompcurve.EMmakecomp(  
							      &suc,
							      Cst->env_info,
							      NumCrv,
	   						      OutCrv,
							      &rotten_one  ),
	               targetid = NewCrv->objid,
			targetos = NewCrv->osnum,
			senderid = NULL_OBJID );


		if( !stat&suc&1 ){
		    printf("Error in AScompcurve.EMmakecomp option 2\n");
		    stat = 0 ; as$status(sts = stat) ; *rc = BSFAIL ;
		    for(k=0 ; k<NumCrv; k=k+1)
		    {
     			   stat = om$send(msg = message GRgraphics.GRdelete(
					&suc, &OutCrv[k].module_info ),
             			targetid = OutCrv[k].located_obj.objid,
				targetos = OutCrv[k].located_obj.osnum,
				senderid = NULL_OBJID ) ;
			   as$status( sts = stat, msg =
					"Error at GRdelete 5 of OutCrv" );
                    }

		    NewCrv->objid = NULL_OBJID;
		    goto wrapup ;
		}
 
  		symbology.display_attr.color		= Cst->display->color;
  		symbology.display_attr.weight		= Cst->display->weight;
  		symbology.display_attr.style		= Cst->display->style;
  		symbology.level				= Cst->level;

  		om$send( msg = message GRvg.GRputsymb(	&suc, &symbology ),
           		targetid = NewCrv->objid,
	   		targetos = NewCrv->osnum,
			senderid = NULL_OBJID );

	}
	else if( ActionFlag == 3 ){

		/* --- trivial case when delete or consume requested,
		       I just need to create the comp_curve
		--- */

	    	NewCrv->objid = NULL_OBJID;
	    	NewCrv->osnum = Cst->env_info->md_id.osnum;

#if 0
	- Note 93/02/25 : ASnode.GRconstruct() failed in this case -
		stat = om$construct ( msg 	= message GRgraphics.GRconstruct
						( &const_list ),

				classid	= OPP_AScompcurve_class_id,	
				p_objid	= &NewCrv->objid,
 				osnum  	= NewCrv->osnum );
#endif
		stat = om$construct ( msg = OM_Gp_NULL_MESSAGE,
				classid	= OPP_AScompcurve_class_id,	
				p_objid	= &NewCrv->objid,
 				osnum  	= NewCrv->osnum );

		if ( !(stat&1))
		{
		    stat = 0 ; as$status(sts = stat) ;
		    *rc = BSFAIL;
		    goto wrapup;
		}

		/*
		 * Output curves and input curves are same
		 */
		
		for(i=0;i<NumCrv;i=i+1)
		{
			OutCrv[i].located_obj = OrdCrv[i].obj_id;
			OutCrv[i].module_info = OrdCrv[i].mod_env;
 		}

   	    	stat = om$send(msg      = message AScompcurve.EMmakecomp(
							      &suc,
							      Cst->env_info,
							      NumCrv,
	   						      OutCrv,
							      &rotten_one  ),
	                targetid = NewCrv->objid,
			targetos = NewCrv->osnum,
			senderid = NULL_OBJID );

		if( !stat&suc&1 ){
		    stat = 0 ; as$status(sts = stat) ;
		    *rc = BSFAIL;
		    goto wrapup;
		} 

  		symbology.display_attr.color		= Cst->display->color;
  		symbology.display_attr.weight		= Cst->display->weight;
  		symbology.display_attr.style		= Cst->display->style;
  		symbology.level				= Cst->level;

  		om$send( msg = message GRvg.GRputsymb(	&suc, &symbology ),
           		targetid = NewCrv->objid,
	   		targetos = NewCrv->osnum,
			senderid = NULL_OBJID );

	}

	*rc = BSSUCC;

}
	
wrapup:
	if( MergeCrv != NULL ){ BSfreecv(&suc,MergeCrv); MergeCrv = NULL;}
	if( crv != NULL ){
		for(i=0;i<NumCrv;i=i+1){
			if( crv[i] != NULL) {
				om$dealloc ( ptr = crv[i]);
				crv[i] = NULL; 
			}
		}
		om$dealloc ( ptr = crv );
	}
	return;
}

/*==========================================================================*/
/*----
%HD%
 
     MODULE NAME RngCrv
 
     Abstract:
        From a list of non ordered curves and not necessarely connected,
	This function build a new list of ordered curves with the
	right oriententation related to each of it.
	The order and orientation are driven by the first curve in the
	input list.
	If the curve is Physicaly closed then the first input curve
	will stay the first output curve.
	Usually the CrvOut list should be different that the CrvIn.
-----
%SC%

void  RngCrv( CrvIn, NbCrv, SearchTol, BaseTol, 
	     I    , I    , I        , I
	
	     CrvOut, iv, NumSeg, SegList, AdjPhy, rc)
	     O     , O  ,O     , O      , O     , O
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        CrvIn[]	   struct GRobj_env  List of the input curve to order
	
        NbCrv      IGRint 	     Number of curves

	SearchTol  IGRdouble	     Maximun permitted distance between
				     the end points of each curve.
				     this variable is used to search the
				     nearest end point from a given one.
				     If you want you can give a large value.

	BaseTol	   IGRdouble	     when can we say that two points
				     are coincident
	     	      
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	CrvOut[]   struct GRobj_env  List of the output curve in the good
				     order

	*iv 	   IGRshort	     list containing the direction flag
				     associated to each curve.
				     If iv[i] == 1 then the CrvOut[i]
				     will remain the the orientation.
				     else if iv[i] == -1 then CrvOut[i]
				     should be reverse to fit with the
				     direction of the first curve.

	*NumSeg	   IGRint	     Number of independant segments.

	SegList[]  IGRint	     list containing the number of spans
				     in each connected curve.

	AdjPhy[]   IGRboolean	     For each segment AdjPhy[2*i] and
				     AdjPhy[2*i+1] tells respectively if 
				     the curve needs to adjusted and 
				     if the curve is Physicaly closed.

        *rc        IGRlong           completion code message
                                 	- if curve are within the SearchTol
				          we should get always BSSUCC
				        - else BSFAIL
  
-----
%MD%

     MODULES INVOKED: BSmkvec, BSdotp
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 5 October 1992 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


void RngCrv( CrvIn, NbCrv, SearchTol, BaseTol,
/*           I    , I    , I        , I      ,				*/
 
	  CrvOut, iv, NumSeg, SegList, AdjPhy, rc)
/*        O     , O , O     , O      , O				*/


struct 	  GRobj_env	CrvIn[];
IGRint			NbCrv;
IGRdouble		SearchTol;
IGRdouble		BaseTol;
struct	  GRobj_env	CrvOut[];
IGRshort		*iv;
IGRint			*NumSeg;
IGRint			SegList[];
IGRboolean		AdjPhy[];
IGRlong			*rc;


{

IGRint		i, iM6, imin, nbrg, j, je, jc, icou, k, LoopNbrg;
IGRdouble	*cou;
IGRlong		suc;
IGRdouble	sup;
IGRdouble	vect[3];
IGRdouble	diff;
IGRdouble	ext[6];
IGRdouble	BaseTol2;
IGRdouble	SearchTol2;
IGRboolean	PhyClosed;
IGRboolean	AdjNeeded;
IGRboolean	istart;
IGRint		NbCrvM1;

extern			BSmkvec();
extern  IGRdouble	BSdotp();

	cou = NULL;
	AdjNeeded = FALSE;
	PhyClosed = FALSE;

	if( NbCrv < 1 ){
		*rc = BSFAIL;
		return;	
	}

	/* --- single case if just only one curve as input --- */

	if( NbCrv == 1 ){

		BaseTol2 = BaseTol * BaseTol;
		*rc = BSSUCC;
		iv[0] = 1;
		CrvOut[0] = CrvIn[0];
		om$send ( msg = message GRcurve.GRendpts ( 
				  &suc,
				  &CrvIn[0].mod_env.md_env.matrix_type,
				  CrvIn[0].mod_env.md_env.matrix,
				  &ext[0],
				  &ext[3] ),
			  targetid = CrvIn[0].obj_id.objid,
			  targetos = CrvIn[0].obj_id.osnum,
			  senderid = NULL_OBJID );

		BSmkvec(&suc, vect, &ext[0],&ext[3]);
		diff = BSdotp(&suc,vect,vect);
		if( diff > BaseTol2 ) PhyClosed = FALSE;
		else 		      PhyClosed = TRUE;

		return;
	}


  	cou = (IGRdouble *)  om$malloc(size = 6*NbCrv * sizeof(IGRdouble) );
	if( cou == NULL ){
		printf("Error in RngCrv to malloc cou\n");
		*rc = BSFAIL;
		return;
	}

	/* --- read the end points of each curve and store it --- */

	for(i=0;i<NbCrv;i=i+1){
		iv[i] = i;
		iM6 = i * 6;
		om$send ( msg = message GRcurve.GRendpts ( 
				  &suc,
				  &CrvIn[i].mod_env.md_env.matrix_type,
				  CrvIn[i].mod_env.md_env.matrix,
				  &cou[iM6],
				  &cou[iM6+3] ),
			  targetid = CrvIn[i].obj_id.objid,
			  targetos = CrvIn[i].obj_id.osnum,
			  senderid = NULL_OBJID );
	}

	memcpy( (IGRchar*)&ext[0],(IGRchar *)&cou[0],
	        (IGRint) (6 * sizeof(IGRdouble)) );

	nbrg = 0;
	BaseTol2 = BaseTol * BaseTol;
	SearchTol2 = SearchTol * SearchTol;
	*NumSeg = 0;
	SegList[0] = 0;
	istart = 0;
	LoopNbrg = 0;
	NbCrvM1 = NbCrv - 1;
Un:

	je = 3;

	if( nbrg >= NbCrvM1 ){

		/* --- We got a well ordered iv array containing the index
		       of the input GRobj_env with a negative sign or not
		       depending if the curve should be reverse or not.
		       Now We just fill corectly the output list.
		 --- */

		BSmkvec(&suc, vect, &ext[0],&ext[3]);
		diff = BSdotp(&suc,vect,vect);
		if( diff > SearchTol2 ) AdjPhy[2*(*NumSeg)+1] = FALSE;
		else 		        AdjPhy[2*(*NumSeg)+1] = TRUE;

		AdjPhy[2*(*NumSeg)] = AdjNeeded;

		*rc = BSSUCC;

		for(i=0;i<NbCrv;i=i+1){

			j = iv[i];

			if( j < 0 ){
				j = -j;
				k = -1;
			}
			else k = 1;

			CrvOut[i] = CrvIn[j];
			iv[i] = k;
		}

		SegList[*NumSeg] = LoopNbrg + 1;
		if( (SegList[*NumSeg] == 1) && (iv[NbCrvM1] < 0 ) )
						iv[NbCrvM1] = -iv[NbCrvM1];
		*NumSeg = *NumSeg + 1;

		goto wrapup;
	}

	nbrg = nbrg + 1;
	LoopNbrg = LoopNbrg + 1;

Deux:
	/*--- We try to find which curve within the non sorted curve is
	      matching with one of the two end points.
	      if the first end point is not matching with any, then
	      imin will be equal to -1 and we will try with the second
	      end point.
	---*/

	imin = -1;
	sup = SearchTol2;

	for(i=nbrg;i<=NbCrvM1;i=i+1){

		icou = 6*iv[i];

		for(j=0;j<6;j=j+3){
			BSmkvec(&suc, vect, &cou[icou+j],&ext[je]);
			diff = BSdotp(&suc,vect,vect);
			if( diff <= sup ){
				sup  = diff;
				imin = i;
				jc   = j;
			}
		}
	}

	if( imin < 0 ){
		je = je - 3;
		if( je == 0 ) goto Deux;
		else{

			BSmkvec(&suc, vect, &ext[0],&ext[3]);
			diff = BSdotp(&suc,vect,vect);
			if( diff > SearchTol2 ) AdjPhy[2*(*NumSeg)+1] = FALSE;
			else 		        AdjPhy[2*(*NumSeg)+1] = TRUE;

			AdjPhy[2*(*NumSeg)] = AdjNeeded;

			AdjNeeded = FALSE;

			memcpy( (IGRchar*)&ext[0],(IGRchar *)&cou[6*iv[nbrg]],
	        		(IGRint) (6 * sizeof(IGRdouble)) );

			istart = nbrg;
			SegList[*NumSeg] = LoopNbrg;
			LoopNbrg = 0;
			*NumSeg = *NumSeg + 1;

			goto Un;
		}
	}

	if( sup > BaseTol2 ) AdjNeeded = TRUE; 

	/* --- rangement --- */

	icou = iv[imin];
	
	/* --- Update the ext array containing my two end points --- */
	
	memcpy((IGRchar*)&ext[je],(IGRchar *)&cou[6*icou+3-jc],
	(IGRint) (3 * sizeof(IGRdouble)) );

	if( je == jc ) icou = -icou;
	
	/* --- Update iv array:
		. IF the index of reference end point stored in the ext array
		  is equal to the index of the end point attach to the
		  curve solution THEN the should will be reverse.
		. IF the index of the reference end point is equal to 3 then
		  the curve will come in the next position in the list 
		  ElSE The curve solution should be in the first position
		  in the list.
	---*/

	if( je == 3 ){
		iv[imin] = iv[nbrg];
		iv[nbrg] = icou;
	}
	else{
		
		iv[imin] = iv[nbrg];
		for(i=0; i<=(LoopNbrg-1); i=i+1){
			j = istart + LoopNbrg - i - 1;
			iv[j+1] = iv[j];
		}

		iv[istart] = icou;
	}

	goto Un;


wrapup:
	#ifdef DEBUG
	printf("NumSeg = %d\n",(*NumSeg));
	for(i=0;i<(*NumSeg);i=i+1)
	printf("SegList[%d] = %d, AdjPhy[%d] = %d,%d\n",
		i,SegList[i],i,AdjPhy[2*i],AdjPhy[2*i+1]);
	for(i=0;i<NbCrv;i=i+1)
	printf("iv[%d] = %d\n",i,iv[i]);
	#endif
	if( cou != NULL ) om$dealloc( ptr = cou );
	return;
}

/*=========================================================================*/
/*----
%HD%
 
     MODULE NAME BuildCrvFromList
 
     Abstract:
	This function is a generalisation of OrderCrv().
        From a list of ORDERED curves wich are NOT necessary connected 
	in the sense of the BaseTol, this function creates, dependanding
	of the caller choise, via the argument CreComp a Bspline or a
	set of composite curves.
	The function will modify the extremities of the curves to match
	with the BaseTol or just the requested curve if they are
	already matching.
	To use this function the caller should call first the function
	RngCrv(...) to get:
		. the curves in the good order
		. to know if We should adjust the ends of the curves.
		. if the resulting ordered curves are physicaly closed
		. if they should be reversed.

-----
%SC%
void	BuildCrvFromList( CreComp, OrdCrv, iv, NumSeg, SegList, AdjPhy, 
		          I      , I     , I , I     , I      , I
	entries, cst, NewCrv, rc )
	M      , I  , O     , O


-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*CreComp  IGRshort	     IF CreComp = 0 THEN a Bspline curve
					is created.
				     IF CreComp = 1 THEN a Bspline curve
				        is created and the Input curves
					in the OrdCrv array are deleted.

				     IF CreComp = 2 THEN a Composite curve
					is created.
				     IF CreComp = 3 THEN a Composite curve
				        is created and the Input curves
					in the OrdCrv array are deleted or
					owned depending of the flag
					AdjNeeded.
				     
        OrdCrv[]   struct GRobj_env  List of ordered curves not matching
				     perfectly
	

	*iv 	   IGRshort	     list containing the direction flag
				     associated to each curve.
				     If iv[i] == 1 then the OrdCrv[i]
				     will remain the the orientation.
				     else if iv[i] == -1 then OrdCrv[i]
				     should be reverse to fit with the
				     direction of the first curve.

	AdjPhy[]  		     If AdjNeeded then we will modify
				     all the necessary curves.

				     It's often usefull to know if the 
				     resulting list is Physicaly closed
				     or not, here for example to make
				     the start and the and perfectly
				     matching.
	     	      
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	*NewCrv    struct GRid     List of the output curve in the good
				   order



        *rc        IGRlong         completion code message
                                 	- BSSUCC or BSFAIL

  
-----
%MD%

     MODULES INVOKED: 
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 14 august 1992 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/
/*
#include "bstypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
*/

void BuildCrvFromList( CreComp, OrdCrv, iv, NumSeg, SegList, AdjPhy,
	          entries, cst, NewCrv, rc )

IGRshort		CreComp[];
struct	GRobj_env	OrdCrv[];
IGRshort		*iv;
IGRint			NumSeg;
IGRint			SegList[];
IGRboolean		AdjPhy[];
struct	GRlc_info	entries[];
struct  GRvg_construct  *cst;
struct	GRid		NewCrv[];
IGRlong			*rc;

{

IGRint	i;
IGRlong msg;
IGRint	indx;

	*rc = BSFAIL;
	indx = 0;

	for( i=0;i<NumSeg;i=i+1){
				
		BuildCrv( CreComp[i], &OrdCrv[indx], SegList[i], &iv[indx], 
		AdjPhy[2*i], AdjPhy[2*i+1], &entries[indx], cst, 
		&NewCrv[i], &msg );

		indx = indx + SegList[i];

	}

	*rc = BSSUCC;
	return ;
}

/* ======================================================================== */
/*----
%HD%
 
     MODULE NAME SortAndBuildCrv
 
     Abstract:
	This function is an encapsulation of RngCrv() and BuildCrvFromList()
	to make the liste easyer for the caller and avoid all malloc needed.

-----
%SC%
void	SortAndBuildCrv( Crvs, NumCrvs, TypeOfCurve, cst,  
		         I   , I      , I          , I  

			 ConCrvs, NumConCrvs, msg )
			 O      , O         , O

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
				     
        Crvs[]   struct GRobj_env    List of curves to sort and merge

	NumCrvs  IGRint		     Number of curve to sort
	

	TypeOfCurve  IGRshort	     IF CreComp = 0 THEN a Bspline curve
					is created.
				     IF CreComp = 1 THEN a Bspline curve
				        is created and the Input curves
					in the OrdCrv array are deleted.

				     IF CreComp = 2 THEN a Composite curve
					is created.
				     IF CreComp = 3 THEN a Composite curve
				        is created and the Input curves
					in the OrdCrv array are deleted or
					owned depending of the flag
					AdjNeeded.

	*cst	struct	GRvg_construct the construction list

	     	      
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	**ConCrvs  struct GRid	   List of the output curve in the good
				   order
	*NumConCrvs IGRint	   Number of curves created;

        *rc        IGRlong         completion code message
                                 	- BSSUCC or BSFAIL

  
-----
%MD%

     MODULES INVOKED: 
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 5 October 1992 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

void SortAndBuildCrv( Crvs, NumCrvs, TypeOfCurve, cst, 
		      ConCrvs, NumConCrvs, msg )

struct 	GRobj_env       Crvs[];
IGRint			NumCrvs;
IGRshort		TypeOfCurve;
struct 	GRvg_construct	*cst;
struct	GRid		**ConCrvs;
IGRint			*NumConCrvs;
IGRlong			*msg;

{

IGRlong			suc;
IGRint			i;
struct	GRobj_env	*OrdCrvs;
struct	GRid		*ConCrvsPtr;
IGRshort		*iv;
IGRdouble		SearchTol, BaseTol;
IGRint			*SegList;
IGRboolean		*AdjPhy;
IGRshort		*CreComp;
struct	GRlc_info	*entries;

	*msg       = BSFAIL;
	entries    = NULL;
	CreComp    = NULL;
	SegList    = NULL;
	AdjPhy     = NULL;
	OrdCrvs    = NULL;
	iv         = NULL;
	*ConCrvs   = NULL;
	ConCrvsPtr = NULL;
	*NumConCrvs   = 0;

	if( NumCrvs == 0 ) return;



	/* --- I malloc here the resulting curve, because I decide in case
		of Error to at list send back the original curves --- */
		 
	ConCrvsPtr = (struct GRid *) 
		 om$malloc( size =  NumCrvs * sizeof(struct GRid) );
	if (ConCrvsPtr == NULL) {
		printf("Unable to malloc %d bytes for ConCrvsPtr \n", 
			( NumCrvs * sizeof(struct GRid) )  ) ;
		return;
	}



	/* I got just only one curve, then it's trivial --- */

	if( NumCrvs == 1 ){
		ConCrvsPtr[0] = Crvs[0].obj_id;
		*ConCrvs      = ConCrvsPtr;
		*NumConCrvs   = 1;
		*msg          = BSSUCC;		
		return;
	}



	/* --- extract the active Base tolerance and chord Height --- */

 	BSxtractpar(&suc,BSTOLCHRDHT,&SearchTol);
	SearchTol = 5.0 * SearchTol;
  	BSxtractpar(&suc,BSTOLBASIS,&BaseTol);



	/* --- malloc orientation array to tell if curves are reverse or not */
	
	iv = (IGRshort *) om$malloc( size = NumCrvs * (sizeof(IGRshort)) );
	if (iv == NULL) {
		printf("Unable to malloc %d bytes for iv \n", 
			( NumCrvs*sizeof(IGRshort)) ) ;
		goto wrapup;
	}



	/* --- malloc the array where to store the ordered curves --- */
 
	OrdCrvs = (struct GRobj_env *) 
		    om$malloc( size = NumCrvs * (sizeof(struct GRobj_env)) );
	if (OrdCrvs == NULL) {
		printf("Unable to malloc %d bytes for OrdCrvs \n", 
			( NumCrvs*sizeof(struct GRobj_env)) ) ;
		goto wrapup;
	}



	/* --- malloc SegList, AdjPhy --- */
	
	SegList = (IGRint *) om$malloc( size = NumCrvs * sizeof(IGRint) );
	if (SegList == NULL) {
		printf("Unable to malloc %d bytes for SegList \n", 
			( NumCrvs*sizeof(IGRint)) ) ;
		goto wrapup;
	}


	AdjPhy = (IGRboolean *) om$malloc( size = 2*NumCrvs * sizeof(IGRboolean) );
	if (AdjPhy == NULL) {
		printf("Unable to malloc %d bytes for AdjPhy \n", 
			( 2*NumCrvs*sizeof(IGRboolean)) ) ;
		goto wrapup;
	}

	RngCrv( Crvs, NumCrvs, SearchTol, BaseTol,
	  	OrdCrvs, iv, NumConCrvs, SegList, AdjPhy, &suc);
	
	if( suc == BSFAIL ){
		printf("Error in RngCrv \n");
		goto wrapup;
	}



	/*--- malloc the GRlc_info structure and the type of curve to create */

	entries = (struct GRlc_info *) 
		    om$malloc( size = NumCrvs * (sizeof(struct GRlc_info)) );
	if (entries == NULL) {
		printf("Unable to malloc %d bytes for entries \n", 
			( NumCrvs*sizeof(struct GRlc_info)) ) ;
		goto wrapup;
	}

	CreComp = (IGRshort *) 
		    om$malloc( size = (*NumConCrvs) * sizeof(IGRshort) );
	if (CreComp == NULL) {
		printf("Unable to malloc %d bytes for CreComp \n", 
			( (*NumConCrvs) * sizeof(IGRshort) ) ) ;
		goto wrapup;
	}

	
	for(i=0;i<(*NumConCrvs);i=i+1) {
		if( SegList[i] == 1){
			if( TypeOfCurve == 2 )     CreComp[i] = 0;
			else if(TypeOfCurve == 3 ) CreComp[i] = 1;
		}
		else			CreComp[i] = TypeOfCurve;
	}

	BuildCrvFromList( CreComp, OrdCrvs, iv, (*NumConCrvs), SegList, AdjPhy,
	          entries, cst, ConCrvsPtr, &suc );
	if( suc == BSFAIL ){
		printf("Error in BuildCrvFromList \n");
		goto wrapup;
	}
	else{
		*msg = BSSUCC;
		*ConCrvs = ConCrvsPtr;
		goto wrapup1;
	}


wrapup:

	for(i=0;i<NumCrvs;i=i+1) ConCrvsPtr[i] = Crvs[i].obj_id;
	*ConCrvs = ConCrvsPtr;
	*NumConCrvs = NumCrvs;

wrapup1:

	if( entries != NULL )       om$dealloc( ptr = entries );
	if( CreComp != NULL )       om$dealloc( ptr = CreComp );
	if( SegList != NULL )       om$dealloc( ptr = SegList );
	if( AdjPhy  != NULL )       om$dealloc( ptr = AdjPhy );
	if( OrdCrvs != NULL ) 	    om$dealloc( ptr = OrdCrvs );
	if( iv      != NULL )       om$dealloc( ptr = iv );
			
	return;
}	

end implementation Root ;


