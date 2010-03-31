class implementation EMSsurface;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsoffptdef.h"  

%safe
static void	EMcheck_surfaces(), EMclassify(), EMclear_marked();
static IGRboolean	EMdoublechk();
%endsafe

#ifndef DEBUG
#define DEBUG 0
#endif

#define XyzStepFactor	10
#define SamplePtBuff	90
#define OutPointBuff	90

#define Volume	1
#define OutOfVolume 2
#define Unknown 3

struct EMScheck_srf
{
 struct IGRbsp_surface *srf;
 IGRboolean alloced;
 struct GRid		sfid;
 struct EMSpartolbasis  partolb;
};

from EMSloopset import EMpt_location;
from EMSedge import EMgetsurface_info, EMinternalpt, EMoffpoint;

IGRint EMfix_volumeint(EMmsg, inters1, env1, inters2, env2, altxyztol, 
		       num_samplepts, checkthese, checkpresent, checkabsent, 
		       deloptions, nummarked, numdel, const_list, opswitched, 
		       delete)
IGRlong		*EMmsg;
struct EMSinters **inters1, **inters2;
struct GRmdenv_info *env1, *env2;
IGRdouble *altxyztol;
IGRint num_samplepts;
IGRushort checkthese, checkpresent, checkabsent, deloptions;
IGRint *nummarked, *numdel;
struct GRvg_construct *const_list;
IGRboolean opswitched, delete;
{
 IGRlong 		sts, rc;
 IGRdouble		uvpt[2][2], xyzpt[2][3], xyztol, step;
 struct EMSinters	*this_inters;
 struct EMSintobj	*this_intobj, *other_intobj = NULL;
 struct EMSdataselect	*uvdata;
 struct GRid		*obj, outpointbuff[OutPointBuff], *outpoint = NULL, 
			*othersfid, *thissfid;
 IGRushort	options = EMSoffpt_NoHole;
 IGRint			i, j, m, locnumdel = 0, numcheck;
#if DEBUG
 IGRint			numoutpts = 0;
 GRobjid		dummy;
#endif
 struct EMSpartolbasis	partolb;
 IGRdouble		sampleptbuff[SamplePtBuff], *samplept = NULL;
 IGRboolean		iscutting;
 IGRint			side[2], num_inters = 0;
 struct IGRbsp_surface	*other_srf, *this_srf;
 struct EMScheck_srf	check_srf[2];
 extern IGRlong		EMfixsfintout(), EFbuild_graphic_group();


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 for(i=0; i<2; i++)
  {
   check_srf[i].srf = NULL;
   check_srf[i].alloced = FALSE;
   check_srf[i].partolb.is_valid = FALSE;
   check_srf[i].partolb.mattyp = env2 ? &env2->matrix_type : NULL;
   check_srf[i].partolb.mat = env2 ? env2->matrix : NULL;
  }

 EMerr_hndlr(!inters1 || !inters2 || !env1 || !env2, *EMmsg, 
	     EMS_E_InvalidArg, wrapup);

 if(altxyztol) xyztol = *altxyztol;
 else BSEXTRACTPAR(&rc, BSTOLLENVEC, xyztol);

 step = XyzStepFactor * xyztol;
 this_inters = *inters1;
 partolb.mattyp = &env1->matrix_type;
 partolb.mat = env1->matrix;

 while(this_inters)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     num_inters++;
     this_intobj = this_intobj->next;
    }
   this_inters = this_inters->next;
  }
 this_inters = *inters1;

 /* We are going to use the marked property. Clear it if not a recursive
    call
 */
 if(!opswitched) EMclear_marked(*inters1, *inters2);

 if(num_samplepts*3 > SamplePtBuff)
  samplept = (IGRdouble *) om$malloc(size = num_samplepts * 3 * 
		sizeof(IGRdouble));
 else samplept = sampleptbuff;

 /* we are going to have 2 * num_samplepts of output points (one on each
    side) per intersection.
 */
#if DEBUG
 if(num_samplepts * 2 * num_inters > OutPointBuff)
  outpoint = (IGRdouble *) om$malloc(size = num_samplepts * 2 * num_inters * 
		       sizeof(struct GRid));
 else outpoint = outpointbuff;
#endif

 while(this_inters)
  {
   this_srf = (struct IGRbsp_surface *)this_inters->more_info;
   thissfid = &this_inters->this_obj;

   if(thissfid && IF_NULL_OBJID(thissfid->objid) && !this_srf)
    thissfid = NULL;

   if(!this_srf && !thissfid)
    {
     this_inters = this_inters->next;
     continue;
    }

   if(!this_srf)
    {
     sts = EMgetvggeom(EMmsg, &env1->matrix_type, env1->matrix, thissfid, 
           &this_srf, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;
     this_inters->more_info = (IGRchar *) this_srf;
    }

   if(!this_srf)
    {
     this_inters = this_inters->next;
     continue;
    }

   partolb.is_valid = FALSE;
   if(this_srf)
    {
     sts = EFsspbtol_by_geom(EMmsg, this_srf, &partolb.tol);
     if(1&*EMmsg&sts) partolb.is_valid = TRUE;
     else goto wrapup;
    }
   
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     uvdata = &this_intobj->this_uvintobj;
     iscutting = TRUE;
     other_intobj = this_intobj->other_intobj_node;
     other_srf = other_intobj ? 
		(struct IGRbsp_surface *)other_intobj->this_obj_node->more_info 
		: NULL;
     othersfid = other_intobj ? &other_intobj->this_obj_node->this_obj
			      : NULL;
		
#if DEBUG
     if(othersfid && IF_NULL_OBJID(othersfid->objid))
      printf("NULL OBJID for surfaceid in inters list\n");
#endif

     if(othersfid && IF_NULL_OBJID(othersfid->objid) && !other_srf)
       othersfid = NULL;

     if(!other_srf && !othersfid)
      {
       this_intobj = this_intobj->next;
       continue;
      }

     /* If this intobj has already been marked for deletion do not waste
	time on it.
	The deletable property could have been set external to this function.
	Also if the cutting/non cutting test has already been performed
	(possibly during previous recursion) ignore this intersection.
     */
     if( ((this_intobj->props & EMSintobj_deletable) &&
	 (other_intobj->props & EMSintobj_deletable)) ||
	 ((this_intobj->props & EMSintobj_marked) &&
	 (other_intobj->props & EMSintobj_marked)))
     {
#if DEBUG
	printf("Ignoring intersection\n");
#endif

       this_intobj = this_intobj->next;
       continue;
      }

     switch(uvdata->datatype)
      {
       case EMSdata_object:

        obj = uvdata->data.object;
	sts = om$send(msg = message EMSedge.EMinternalpt(EMmsg, num_samplepts, 
				NULL, samplept, NULL, &partolb), 
		targetid = obj->objid, targetos = obj->osnum, 
		senderid = obj->objid);
	if(!(1&*EMmsg&sts)) goto wrapup;
	
	for(i=0, j=0; (i<num_samplepts) && iscutting; i++, j+=2)
	 {
	  for(m=0; m<2; m++) side[m] = Unknown;

	  /* Select the surface for which the sample point is internal
	     i.e. not on an existing boundary. Ignore seam boundaries for
	     this check because they can be treated as internal. This needs
	     to be done because if the sample point happens to be on the
	     boundary of the 'other' surface, we have a situation similar
	     to the 'bermuda triangle' in loop point location.
	  */
          numcheck = 1;
	  if(other_srf != check_srf[0].srf)
	   {
            check_srf[0].srf = other_srf;
	    check_srf[0].alloced = FALSE;
	    check_srf[0].sfid = *othersfid;
	    check_srf[0].partolb.is_valid = FALSE;
	   }
	
	  EMcheck_surfaces(EMmsg, check_srf, &numcheck, *inters2, 
			   &samplept[j], this_srf, env2);
	  if(!(1&*EMmsg)) goto wrapup;
#if DEBUG
	  if(numcheck > 1)
	   {
	    printf("\nChecking against %d surfaces - \n", numcheck);
	    for(m=0; m<numcheck; m++)
	     printf("%d    %d\n", check_srf[m].sfid.osnum,
				  check_srf[m].sfid.objid);
	   }
	
#endif

	  for(m=0; m<2; m++)
	   {
	    sts = om$send(msg = message EMSedge.EMoffpoint(EMmsg, NULL, 
			&samplept[j], NULL, step, &this_inters->this_obj.objid,
			(struct IGRbsp_surface *)this_inters->more_info, env1, &partolb, NULL, 
			NULL, NULL, m ? options | EMSoffpt_Right : options, 
			uvpt[m], xyzpt[m], NULL), 
		targetid = obj->objid, targetos = obj->osnum, 
		senderid = obj->objid);
		
	    /* If this edge was degenerate, ignore it.
	    */
	    if(*EMmsg == EMS_I_Degenerate)
	     {
   	      side[0] = Unknown; 
	      side[1] = Unknown; 
	      iscutting = TRUE; 
	      *EMmsg = EMS_S_Success;
	      break;
	     }
	    if(!(1&*EMmsg&sts)) goto wrapup;
	    if(*EMmsg == EMS_I_NotFound)
	     {
	      if(opswitched) 
	       {
		side[0] = Unknown; 
		side[1] = Unknown; 
		iscutting = TRUE; 
		*EMmsg = EMS_S_Success;
		break;
	       }
	      else goto wrapup;
	     }
	
#if DEBUG
	    if(const_list)
	     sts = EMoutput_point(&rc, obj->objid, const_list, 1, xyzpt[m], 
			       &outpoint[numoutpts++]);
#endif
	    EMclassify(EMmsg, numcheck, check_srf, xyzpt[m], &side[m]);
	    if(!(1&*EMmsg)) goto wrapup;
	
	   } /* for(m=0; m<2; m++) */
	
	  /* If the two points on right and left of the intersection are
	     on opposite sides of the other surface, it is a cutting
	     intersection. If both the points are on the same side of other
	     surface, see if they are on the volume side of the other
	     surface. If so, it is a cutting intersection.
	  */
	  if( (side[0] == Unknown) || (side[1] == Unknown))
	   iscutting = TRUE;
	  else if(side[0] != side[1]) iscutting = TRUE;
	  else if( (side[0] == Volume) && (side[1] == Volume)) iscutting= TRUE;
	  else iscutting = FALSE;
	
	 } /* for(i=0, j=0; (i<num_samplepts) && iscutting; i++, j+=2) */
       break;

       default:
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;

      }/* switch(uvdata->datatype) */

     if(!iscutting) 
       {
	IGRboolean	doublechk = TRUE;
	
	/* If the intersection is determined to be deletable, double check
	   by reversing the operands. Do it only for this intersection.
	*/
	if(!opswitched) 
	 doublechk = EMdoublechk(EMmsg, this_intobj, env1, other_intobj, env2,
	 	       altxyztol, num_samplepts, checkthese, checkpresent, 
		       checkabsent, deloptions, nummarked, numdel, const_list, 
		       opswitched, delete);
	if(doublechk)
	 {
	  this_intobj->props |= EMSintobj_deletable; 
	  other_intobj->props |= EMSintobj_deletable; 	
	  locnumdel++;
	 }
	
       }
     /* Record the fact that this intersection has already been tested.
     */
     this_intobj->props |= EMSintobj_marked;
     other_intobj->props |= EMSintobj_marked;
     this_intobj = this_intobj->next;
      
    }/* while(this_intobj) */

   this_inters = this_inters->next;

  }/* while(this_inters) */


 if(locnumdel && delete)
  {
#if DEBUG
   printf("\n %d Non cutting intersections deleted\n", locnumdel);
#endif
   sts = EMfixsfintout(EMmsg, inters1, env1, inters2, env2, altxyztol, 
		num_samplepts, NULL, NULL, NULL, NULL,
		chk_deletable, NULL, nummarked, numdel);
  }

wrapup:
  for(i=0; i<2; i++)
    if(check_srf[i].alloced && check_srf[i].srf) 
     om$dealloc(ptr = check_srf[i].srf);

 if(samplept && (samplept != sampleptbuff))
  om$dealloc(ptr = samplept);

#if DEBUG
  if( (numoutpts > 1) && const_list)
  sts = EFbuild_graphic_group(numoutpts, NULL, outpoint, const_list, &dummy, 
			      &rc);
#endif

 if(outpoint && (outpoint != outpointbuff))
  om$dealloc(ptr = outpoint);

 /* If there was some problem or if an offset point was not found try switching
    around the operands if they have not been tried that way already.
 */
 if( (!(1&*EMmsg&sts) || (*EMmsg == EMS_I_NotFound)) && !opswitched)
  {
	
#if DEBUG
   printf("Switching operands\n");
#endif
   sts = EMfix_volumeint(EMmsg, inters2, env2, inters1, env1, altxyztol, 
	       num_samplepts, checkthese, checkpresent, checkabsent, 
	       deloptions, nummarked, numdel, const_list, TRUE, delete);
  }
 else EMclear_marked(inters1 ? *inters1 : NULL, inters2 ? *inters2 : NULL);

return(sts);
}




static void EMcheck_surfaces(EMmsg, check_srf, numcheck, inters, 
			    uvpt, thissrf, env)
IGRlong			*EMmsg;
struct EMScheck_srf	*check_srf;
IGRint			*numcheck;
struct EMSinters	*inters;
IGRdouble		*uvpt;
struct IGRbsp_surface	*thissrf;
struct GRmdenv_info	*env;
{
 IGRlong		sts, rc;
 IGRdouble		xyz[3], otuv[2], junkdist, junkbase[3];
 extern void		BSsfeval();
 OM_S_OBJECT_LINKAGE	ls, comm;
 IGRint			count = 0;
 struct EMSptloc_info	ptloc;
 struct GRid		otherid, *sfid;
 struct EMSinters	*this_inters;
 extern   IGRboolean    BSmdistptsf();
 OM_S_CHANSELECT	to_ls, to_comm;
 extern IGRint		EMgetvggeom();
 enum EMSdatatype	dummy;
	
 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 sfid = &check_srf[0].sfid;

 if(!check_srf[0].srf && !IF_NULL_OBJID(sfid->objid))
  {
   sts = EMgetvggeom(EMmsg, &env->matrix_type, env->matrix, sfid,
			&check_srf[0].srf, &dummy);
   if(!(1&*EMmsg&sts) || (dummy != EMSdata_surface) || !check_srf[0].srf)
        {*numcheck = 1;check_srf[0].alloced = FALSE;}
   else check_srf[0].alloced = TRUE;
  }
 
 if(check_srf[0].srf && !check_srf[0].partolb.is_valid)
  {
   sts = EFsspbtol_by_geom(EMmsg, check_srf[0].srf, &check_srf[0].partolb.tol);
   if(1&*EMmsg&sts) check_srf[0].partolb.is_valid = TRUE;
   else goto wrapup;
  }
 else if(!check_srf[0].srf){*EMmsg = EMS_E_InvalidArg; goto wrapup;} 
	
 BSsfeval(thissrf, uvpt[0], uvpt[1], 0, xyz, &rc);
 if(rc != BSSUCC)  {*EMmsg = EMS_E_Fail; goto wrapup;}
 BSmdistptsf(&rc, check_srf[0].srf, xyz, &otuv[0], &otuv[1], junkbase, 
	     &junkdist);
 if(rc != BSSUCC)  {*EMmsg = EMS_E_Fail; goto wrapup;}
	
 EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
 sts = om$get_channel_objects(objid = sfid->objid, osnum = sfid->osnum, 
			p_chanselect = &to_ls, list = &ls, size = 1, 
			count = (OMuint *)&count);
 if(!count) goto wrapup;

/* fix for umr */
 ptloc.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
                             EMS_PTLOC_USECHTTOL | EMS_PTLOC_INCHTTOL;
        
 sts = om$send(msg = message EMSloopset.EMpt_location(EMmsg, otuv, 
		&ptloc, &check_srf[0].partolb), senderid = sfid->objid, 
		targetid = ls.S_objid, targetos = sfid->osnum);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
 if( (ptloc.location == EMS_L_ONEDGE) || (ptloc.location == EMS_L_ONVRTX))
  {
   EMmake_chanselect(EMSedge_to_common_edge, &to_comm);
   sts = om$get_channel_objects(objid = ptloc.edge[0].edge_id, 
		p_chanselect = &to_comm, 
		osnum = sfid->osnum, list = &comm, 
		size = 1, count = (OMuint *)&count);
   if(!count) goto wrapup;
   sts = om$send(msg = message EMSedge.EMgetsurface_info
			(EMmsg, &otherid.objid, NULL), 
			targetid = comm.S_objid, targetos = sfid->osnum, 
			senderid = sfid->objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(IF_EQ_OBJID(otherid.objid, sfid->objid)) goto wrapup;

   otherid.osnum = sfid->osnum;
   *numcheck = 2;
   if(!IF_EQ_OBJID(check_srf[1].sfid.objid, otherid.objid) || 
      !check_srf[1].srf)
    {
     if(check_srf[1].alloced && check_srf[1].srf)
	om$dealloc(ptr = check_srf[1].srf);
     check_srf[1].srf = NULL;
     check_srf[1].alloced = FALSE;
     check_srf[1].sfid.objid = NULL_OBJID;
     check_srf[1].partolb.is_valid = FALSE;

     this_inters = inters;
     while(this_inters)   
      {
       if(IF_EQ_OBJID(this_inters->this_obj.objid, otherid.objid))
        {
         check_srf[1].srf = (struct IGRbsp_surface *)this_inters->more_info;
	 check_srf[1].alloced = FALSE;
	 check_srf[1].sfid = otherid;
         break;
        }
       this_inters = this_inters->next;
      }
     if(!check_srf[1].srf)
      {
       sts = EMgetvggeom(EMmsg, &env->matrix_type, env->matrix, &otherid, 
			&check_srf[1].srf, &dummy);
       if(!(1&*EMmsg&sts) || (dummy != EMSdata_surface) || !check_srf[1].srf)
        {*numcheck = 1;check_srf[1].alloced = FALSE;}
       else {check_srf[1].sfid = otherid; check_srf[1].alloced = TRUE;}
       sts = EFsspbtol_by_geom(EMmsg, check_srf[1].srf, 
			       &check_srf[1].partolb.tol);
       if(1&*EMmsg&sts) check_srf[1].partolb.is_valid = TRUE;
      }
    }

  }

wrapup:
return;
}

static void EMclassify(EMmsg, numcheck, check_srf, pt, side)
IGRlong			*EMmsg;
IGRint			numcheck;
struct EMScheck_srf	*check_srf;
IGRdouble		*pt;
IGRint			*side;
{
 IGRint			locside[2], i;
 IGRboolean		natside;
 extern void		BSptonnsdsf();
 IGRlong		rc;

 *EMmsg = EMS_S_Success;

 locside[0] = Unknown;
 locside[1] = Unknown;
 for(i=0; i<numcheck; i++)
  {
   natside = FALSE;
   BSptonnsdsf(check_srf[i].srf, pt, &natside, &rc);
   if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
	
   if( (check_srf[i].srf->pos_orient && natside) ||
       (!check_srf[i].srf->pos_orient && !natside))
    locside[i] = Volume;
   else locside[i] = OutOfVolume;
  }
 if(numcheck == 1) *side = locside[0];
 else if( (locside[0] == Volume) && (locside[1] == Volume))
  *side = Volume;
 else *side = OutOfVolume;

wrapup:
return;
}

static IGRboolean EMdoublechk(EMmsg, intobj1, env1, intobj2, env2, altxyztol, 
		       num_samplepts, checkthese, checkpresent, checkabsent, 
		       deloptions, nummarked, numdel, const_list, opswitched, 
		       delete)
IGRlong		*EMmsg;
struct EMSintobj *intobj1, *intobj2;
struct GRmdenv_info *env1, *env2;
IGRdouble *altxyztol;
IGRint num_samplepts;
IGRushort checkthese, checkpresent, checkabsent, deloptions;
IGRint *nummarked, *numdel;
struct GRvg_construct *const_list;
IGRboolean opswitched, delete;
{
 IGRlong		sts;
 IGRshort		saveprops1, saveprops2;
 struct EMSinters	inters[2], *intersptr[2];
 struct EMSintobj	junkintobj[2];
 IGRint			i;

 *EMmsg = EMS_S_Success;

 saveprops1 = intobj1->props;
 saveprops2 = intobj2->props;

#if DEBUG
 printf("Double Checking\n");
#endif

 /* set up dummy inters lists.
 */
 for(i=0; i<2; i++)
  {
   junkintobj[i] = i ? *intobj2 : *intobj1;
   junkintobj[i].this_obj_node = &inters[i];
   junkintobj[i].other_intobj_node = i ? &junkintobj[0] : &junkintobj[1];
   junkintobj[i].fwd = NULL;
   junkintobj[i].bwd = NULL;
   junkintobj[i].next = NULL;
   inters[i] = i ? *(intobj2->this_obj_node) : *(intobj1->this_obj_node);
   inters[i].num_cvs = 1;
   inters[i].cvs = &junkintobj[i];
   inters[i].next = NULL;
   intersptr[i] = &inters[i];
  }

 /* Call the fix_volume_int function with switched operands.
 */
 num_samplepts = 1;
 opswitched = TRUE;
 delete = FALSE;
 sts = EMfix_volumeint(EMmsg, &intersptr[1], env2, &intersptr[0], env1, 
		altxyztol, num_samplepts, checkthese, checkpresent, 
		checkabsent, deloptions, nummarked, numdel, const_list, 
		opswitched, delete);
		
 /* If after switching the operands if the first intobj is still marked
    deletable, the double check test is successfull else it is not.
 */
 if(junkintobj[0].props & EMSintobj_deletable)
  {
#if DEBUG
   printf("Double check successful\n");
#endif
   return(TRUE);
  }
 else 
  {
#if DEBUG
   printf("Double check not successful\n");
#endif
   return(FALSE);
  }

}


static void EMclear_marked(inters1, inters2)
struct EMSinters *inters1, *inters2;
{
 struct EMSinters	*this_inters;
 struct EMSintobj	*this_intobj;
 IGRint			i;

 for(i=0; i<2; i++)
  {
   this_inters = i ? inters2 : inters1;
   while(this_inters)   
    {
     this_intobj = this_inters->cvs;
     while(this_intobj) 
      {
       this_intobj->props &= ~EMSintobj_marked;
       this_intobj = this_intobj->next;
      }
     this_inters = this_inters->next;
    }
  }

}
end implementation EMSsurface;
