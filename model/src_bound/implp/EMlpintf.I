/* ###################   APOGEE COMPILED   ################## */
/*
Notes
  This method will analyse the relationship between the input loop and the
  host loop such that - 
  1) if the two loops intersect, it will return information about maximum
     interference between the two loops.
  2) if the two loops are disjoint it will return the minimum clearance between
     them.
  3) if one of the loops is nested inside the other, it will return min and
     max clearances.

  The method will also return the points on two loops at which the distances
  returned are computed.

Arguments
	other		input		other loop id.
	type		input/output	one of the enums defined in
					EMSintf.h.
					If EMunknown, the type is determined
					and returned.
	outmycv		output		Merged bs geom of this loop is desired
					back. Memory should be freed via
					BSfreecv().
	outothercv	output		Merged bs geom for other loop. Memory
					should be freed via BSfreecv().
	inmycv		input		Merged bs geom of this loop if known.
	inothercv	input		Merged bs geom of other loop if known.
	maxdist		output		Maximum interference/clearance
					depending on the type.
	mindist		output		Minimum clearance. Valid only if
					type is EMnested_cl or EMdisjoint_cl.
	maxpts		output		Point on each loop where the maxdist
					was computed. (0, 1) my point, 
					(2, 3) other point.
	minpts		output		Point on each loop where the mindist
					was computed. (0, 1) my point, 
					(2, 3) other point.
	ptol		input		parametric tolerance.
	
Return Values
	EMS_S_Success			Everything was great.
	EMS_E_LoopError			Problem in finding the nesting.
	EMS_E_Fail			Problem i getting merged geom of
					the loops.
	EMS_I_Coincedent 		Loops were determined to be coincedent.
	EMS_I_Degenerate		Atleast one of the input loops was
					degenerate.
History
	SM	16-Oct-89		Creation.
*/

class implementation EMSloop;

#include "emsinterdef.h"
#include "bserr.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"

extern IGRboolean EMSintfWriteFlag;

method EMloopInterference(IGRlong *EMmsg; 
			  GRobjid other; 
			  enum EMSintfType *type;
			  struct IGRbsp_curve **outmycv, **outothercv, 
					      *inmycv, *inothercv;
			  IGRdouble *maxdist, *mindist;
			  IGRdouble *maxpts, *minpts;
			  struct EMSpartolbasis *ptol)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct EMSnest_info	locnest1, locnest2;
 IGRint			numint = 0, uvsize;
 struct IGRbsp_curve	*lp1cv = NULL, *lp2cv = NULL;
 extern void		BSvcdst2cvs(), BSmxdstcvcv(), BSmdistcvcv();
 IGRint			num = 0, ind1, ind2;
 IGRdouble		par1, par2, locmaxdist, locmindist;
 IGRpoint		locminpts[2], locmaxpts[2];
 IGRdouble		*par1ptr = NULL, *par2ptr = NULL, *pt1ptr = NULL, 
			*pt2ptr = NULL, bastol;

 BSEXTRACTPAR(&rc, BSTOLBASIS, bastol);			
 EMerr_hndlr(!type, *EMmsg, EMS_E_InvalidArg, wrapup);
 
 *EMmsg = EMS_S_Success;

 if(!ptol->is_valid)
  {
   sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg, NULL, ptol),
			targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
  }

 if(*type == EMunknown)
  {
   /* Do the loops intersect ?
   */
   sts = om$send(msg = message EMSloop.EMobint(EMmsg, ptol, other, ptol, 
			EMS_INTER_CUTTING, &numint, NULL, NULL), 
			targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
   if(numint) *type = EMintf;
   else
    {
     sts = om$send(msg = message EMSloop.EMgivenestinfo(EMmsg, &locnest1), 
			targetid = my_id);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

     sts = om$send(msg = message EMSloop.EMgivenestinfo(EMmsg, &locnest2), 
			targetid = other);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
   
     /* Is 2 nesting inside 1?
     */
     sts = om$send(msg = message EMSloop.EMnesting(EMmsg, &locnest2, ptol), 
			targetid = my_id);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

     if( (*EMmsg == EMS_S_Success) && IF_EQ_OBJID(locnest2.parent, my_id))
      *type = EMnested_cl;
     else if(*EMmsg == EMS_I_OutOfBounds)
      {
       /* Is 1 nested inside 2 ?
       */
       sts = om$send(msg = message EMSloop.EMnesting(EMmsg, &locnest1, ptol), 
			targetid = other);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
       if( (*EMmsg == EMS_S_Success) && IF_EQ_OBJID(locnest1.parent, other))
        *type = EMnested_cl;
       else if(*EMmsg == EMS_I_OutOfBounds)
        *type = EMdisjoint_cl;
      }
     else if(*EMmsg == EMS_I_Ambiguous)
      {
       *EMmsg = EMS_I_Coincident;
       goto wrapup;
      }
     else
      {
       *EMmsg = EMS_E_Fail;
       goto wrapup;
      }
    }

  } /* if(*type == EMunknown) */


 if((*type == EMnested_cl) || (*type == EMdisjoint_cl) || 
    (*type == EMnested_intf))
  {
   if(inmycv) lp1cv = inmycv;
   else
    {
     sts = om$send(msg = message EMSloop.EMgetbcgeom
		(EMmsg, &lp1cv, ptol, NULL), targetid = my_id);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     if(*EMmsg == EMS_I_Degenerate) goto wrapup;
    }
   if(inothercv) lp2cv = inothercv;
   else
    {
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     sts = om$send(msg = message EMSloop.EMgetbcgeom
		(EMmsg, &lp2cv, ptol, NULL), targetid = other);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     if(*EMmsg == EMS_I_Degenerate) goto wrapup;
    }

  }


 BSchgdeppar (ptol->tol, &rc);
 if(*type == EMintf)
  {
   *EMmsg = EMS_E_InvalidArg;		/* To be implemented */
   goto wrapup;
  }
 else if( (*type == EMnested_cl) || (*type == EMnested_intf))
  {
   BSmxdstcvcv(lp1cv, lp2cv, &num, &par1, &par2, locmaxpts[0], locmaxpts[1], 
	       &locmaxdist, &rc);
   if(EMSintfWriteFlag && (rc!=BSSUCC))
    {
     extern IGRint	prtbspc();

     printf("Problem in BSmxdstcvcv, writing out nested curves\n");
     prtbspc(lp1cv);
     prtbspc(lp2cv);
     printf("Tolerance is %2.13lf\n", ptol->tol);
    }
   EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   num = 0;
   BSmdistcvcv(lp1cv, lp2cv, &num, &par1ptr, &par2ptr, &pt1ptr, &pt2ptr, 
		  &locmindist, &rc);
   if(EMSintfWriteFlag && (rc!=BSSUCC))
    {
     extern IGRint	prtbspc();

     printf("Problem in BSmdistcvcv, writing out nested curves\n");
     prtbspc(lp1cv);
     prtbspc(lp2cv);
     printf("Tolerance is %2.13lf\n", ptol->tol);
    }
   EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   OM_BLOCK_MOVE(pt1ptr, locminpts[0], sizeof(IGRpoint));
   OM_BLOCK_MOVE(pt2ptr, locminpts[1], sizeof(IGRpoint));
  }
 else if(*type == EMdisjoint_cl)
  {
   BSmdistcvcv(lp1cv, lp2cv, &num, &par1ptr, &par2ptr, &pt1ptr, &pt2ptr, 
		  &locmindist, &rc);
   if(EMSintfWriteFlag && (rc!=BSSUCC))
    {
     extern IGRint	prtbspc();

     printf("Problem in BSmdistcvcv, writing out disjoint curves\n");
     prtbspc(lp1cv);
     prtbspc(lp2cv);
     printf("Tolerance is %2.13lf\n", ptol->tol);
    }
   EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   OM_BLOCK_MOVE(pt1ptr, locminpts[0], sizeof(IGRpoint));
   OM_BLOCK_MOVE(pt2ptr, locminpts[1], sizeof(IGRpoint));
  }
 else *EMmsg = EMS_E_Fail;


wrapup:
BSchgdeppar (bastol, &rc);

if( (1&*EMmsg&sts) && (*EMmsg != EMS_I_Degenerate))
 {
  if(maxdist) *maxdist = locmaxdist;
  if(mindist) *mindist = locmindist;
  uvsize = 2 * sizeof(IGRdouble);
  if(maxpts)
   {
    OM_BLOCK_MOVE(locmaxpts[0], maxpts, uvsize);
    OM_BLOCK_MOVE(locmaxpts[1], &maxpts[2], uvsize);
   }
  if(minpts)
   {
    OM_BLOCK_MOVE(locminpts[0], minpts, uvsize);
    OM_BLOCK_MOVE(locminpts[1], &minpts[2], uvsize);
   }
 }

if(outmycv) {*outmycv = lp1cv; lp1cv = NULL;}
if(outothercv) {*outothercv = lp2cv; lp2cv = NULL;}
	
if(lp1cv && (lp1cv != inmycv)) BSfreecv(&rc, lp1cv);
if(lp2cv && (lp2cv != inothercv)) BSfreecv(&rc, lp2cv);
if(par1ptr) om$dealloc(ptr = par1ptr);
if(par2ptr) om$dealloc(ptr = par2ptr);
if(pt1ptr) om$dealloc(ptr = pt1ptr);
if(pt2ptr) om$dealloc(ptr = pt2ptr);

EMWRAPUP(*EMmsg, sts, "In EMSloop.EMloopInterference");
return(sts);
}


end implementation EMSloop;
