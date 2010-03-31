/*
Notes
	This method trims an edge with respect to the input element.The
objid of the element against which the trim is to take place is passed in.
This could potentailly be a loopset, a loop or an edge. The pairs of 
boundary points representing solid portions on 'me' are returned.These also
have a one-to-one correspondence with the structures which provide the
caller the information about the generation of these boundaries by the
input element.The information includes the edge belonging to the input
element which caused the boundary and the parameter value on that edge.
	Each boundary pair returned represents the portion of the edge in
area with respect to the input element.The extraction is handled by the 
method 'EMextractyourself', which operates on the link list of boundaries
produced by this method.

History
	SM	03/20/87	Creation Date.
        PP      05/08/87        Changed the method so that if th edge
                                is a bsedge it gets its bspline geometry
                                and trims itself against the incoming
                                objectid. 
	SM	06/03/87	Modified to return the UV point to the
				caller via the structure.
	SM	27-Sep-88	if the edge is reversed, change EMScvint
				for 'my_bdrys' after reversing the
				bdrys. Also instead of point checks to see
				if the bdrys match, use EMScvint.
	SM	13-Dec-88	Set the 'info' field in the sfintedpar
				structures to NULL. EMlsparttrim uses
				the fields.
	SM	22-Mar-89	Make use of static memory if possible, for
				poly.points (if linedge) and for poles, knots
				and weights (if bsedge). 
	SM      06-Jun-93       Do not merge any boundaries if there is
     	                        incedence on existing edges. This is to cause
                                maximum splits. This behavior is active only
                                if WANT_POST220_BEHAVIOR is set to TRUE.
        SM      23-Dec-93       Disable maximum split procedure
*/
class implementation EMSedge;

#include "EMS.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emssfint.h"
#include "emsinterdef.h"
#include "emsinter.h"


#define NodeAddress(start_add,node_num,address) \
  	 { \
	  IGRint i; \
	  (address) = (start_add); \
	  for(i=0;i<(node_num)-1;i++) \
   	   {\
     		(address) = (address)->next;\
   	   }\
	 }


#define IntLoc(props) \
	((props) & EMS_PYPT_ATMIDDLE) ? EMScvint_middle : \
	((props) & EMS_PYPT_ATSTOP) ? EMScvint_rtend : \
	((props) & EMS_PYPT_ATSTART) ? EMScvint_lfend : \
	((props) & EMS_PYPT_ATEND) ? EMScvint_end : EMScvint_unknown

#define PtsBuff	300
#define	MaxPts	150
#define MaxPoles 100
#define MaxKnots MaxPoles
#define MaxWts MaxPoles

from EMSloopset import EMlsparttrim;

extern OMuword OPP_EMSbsedge_class_id, OPP_EMSnatedge_class_id, 
	       OPP_EMSlinedge_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;

method EMtrimyourself(IGRlong *EMmsg;GRobjid *against;
                      IGRushort options;
		      struct EMSsfintedpar **against_bdrys,
					   **my_bdrys;
		      IGRint *num_bdrys;
		      struct EMSpartedinfo *part;
		      struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts;
  struct IGRpolyline	my_poly;
  struct EMSpypoint	*my_pypoints,*this_pypoint;
  GRobjid		user_id;
  struct IGRbsp_curve   my_curve;
  struct EMSdataselect  mygeom;
  struct EMSsfintedpar *EMsfintedpar_malloc(),*this_sfintedpar, 
			*against_sfintedpar;
  extern   void		EMpypoint_free();
  extern  void 		EMsfintedpar_free();
  void  		EMcnvtedpar();
  void			EMrevpypts(),EMrevsfintedpar();
  IGRint		i;
  struct EMSedgebound	in_par;
  IGRushort	user_props;
  IGRdouble		partollen,*begin_pt,*end_pt;
  IGRdouble		begin_pt_buff[2], end_pt_buff[2];
  IGRboolean		EFextract_par(),par_obtained;
  IGRboolean		in_area = TRUE, in_hole = FALSE, intersect;
  IGRdouble		ptsbuff[PtsBuff], polesbuff[PtsBuff], 
			knotsbuff[MaxKnots], wtsbuff[MaxWts];
  struct EMSedgeinfo	edinfo;

  my_poly.num_points = 0;
  my_poly.points = NULL;
  my_pypoints = NULL;

  my_curve.poles = NULL;
  my_curve.weights = NULL;
  my_curve.knots = NULL;
  my_curve.bdrys = NULL;

  this_sfintedpar = NULL;
  this_pypoint = NULL;
  par_obtained = FALSE;

  if(part)
   {
     user_id = part->edid;
     user_props = part->edprops;
   }
  else
   {
     user_id = my_id;
     user_props = ME.EMSedge->ed_props;
   }

  sts = om$send(msg = message EMSedge.EMgetedgedef(EMmsg, NULL, &edinfo), 
			targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

  if (edinfo.edgetype == EMSbs) 
    {
     IGRint num_poles, num_knots, num_wts;
     struct EMSbsedgedef	*info;

     info = &edinfo.specinfo.bsedge;
     num_poles = part ? info->num_poles + 2 * info->order-1 : info->num_poles;
     num_knots = info->order + num_poles;
     num_wts = info->bs_props & EMBS_RATIONAL ? num_poles : 0;

     if( (num_poles <= MaxPoles) && (num_knots <= MaxKnots) &&
     	 (num_wts <= MaxWts))
      {
       my_curve.poles = (IGRdouble *) polesbuff;
       my_curve.knots = (IGRdouble *) knotsbuff;
       my_curve.weights = (IGRdouble *) wtsbuff;
      }

     sts = om$send (msg = message EMSedge.EMgetbcgeom ( EMmsg,0,1,
                           (user_props & EMED_REVERSED) ? TRUE : FALSE,
                           part, &my_curve, partolbasis, NULL),
                     targetid = my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

     mygeom.datatype = EMSdata_curve3d;
     mygeom.data.curve = &my_curve;

 
     OM_BLOCK_MOVE (my_curve.poles, begin_pt_buff, 2 * sizeof(IGRdouble));
     OM_BLOCK_MOVE (&my_curve.poles[3 * (my_curve.num_poles - 1)], 
		     end_pt_buff, 2 * sizeof (IGRdouble));
     if (my_curve.rational)
      {
        for (i=0; i < 2; i++)
         {
          begin_pt_buff[i] /= my_curve.weights[0];
          end_pt_buff[i] /= my_curve.weights[my_curve.num_poles - 1];
         }
      }

     if(user_props & EMED_REVERSED)
      {
        begin_pt = &end_pt_buff[0];
        end_pt = &begin_pt_buff[0];
      }
     else
      {
        begin_pt = &begin_pt_buff[0];
        end_pt = &end_pt_buff[0];
      }

    } /* If bs edge */
              
   else 
    {
     /* Make use of static memory if possible. If nat edge, it will have
	max 2 points. If linedge see if num pts is less than MaxPts.
     */

     if( ((edinfo.edgetype == EMSlinear) && 
         (edinfo.specinfo.linedge.num_points <= MaxPts)) ||
	 (edinfo.edgetype == EMSnatural))
	my_poly.points = (IGRdouble *) ptsbuff;

     sts = om$send(msg=message EMSedge.EMgetpygeom
			(EMmsg,0,MAXINT,(user_props & EMED_REVERSED)?
 					TRUE :FALSE,part,&my_poly, 
                                        partolbasis, NULL),
			targetid = my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

     mygeom.datatype = EMSdata_poly2d;
     mygeom.data.poly = &my_poly;

     if(user_props & EMED_REVERSED)
      {
        end_pt = &my_poly.points[0];
        begin_pt = &my_poly.points[2*my_poly.num_points - 2];
      }
     else
      {
        begin_pt = &my_poly.points[0];
        end_pt = &my_poly.points[2*my_poly.num_points - 2];
      }
    }


  *num_bdrys = 0;
  if(my_bdrys) *my_bdrys = NULL;
  if(against_bdrys) *against_bdrys = NULL;
  
/* Trim my active polyline geometry with respect to the input element.
*/
  sts = om$send(msg=message EMSloopset.EMlsparttrim
		(EMmsg, &mygeom, partolbasis, options, num_bdrys,
		 my_bdrys ? &my_pypoints : NULL, against_bdrys), 
		 targetid=*against);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
  if(*EMmsg == EMS_I_InAreaTrim)
   { in_area = TRUE; in_hole = FALSE; intersect = FALSE;}
  else if(*EMmsg == EMS_I_InHoleTrim)
   { in_area = FALSE; in_hole = TRUE; intersect = FALSE;}
  else { in_area = FALSE; in_hole = FALSE; intersect = TRUE;}
	
  if(!(*num_bdrys))
   {
     in_area = FALSE;
     in_hole = TRUE;
     intersect = FALSE;
     goto wrapup;
   }

  if(!against_bdrys && !my_bdrys) goto wrapup;

/*create the link list of structures EMSsfintedpar 
  for all my boundaries.
*/

/* Even if the exact size of memory required is known here, the
   function EMsfintedpar_malloc is called so that mallocing and freeing
   of memory can be done in a centralized way.
*/
  if(my_bdrys)
   {
    *my_bdrys = EMsfintedpar_malloc(EMmsg,(*num_bdrys)*2);
    EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
   }

/* For each positive boundary on me,use a structure and initialize all the
   fields in it to return the information to the caller.
   If the user is a partedge, then
   the edge parameter returned by the partrim is with respect to the
   polyline which was extarcted. In that case convert the parameter into
   a value which is with respect to the full edge and return that to the
   caller.  If the edge using this method is reversed then the begin and
   end of a boundary need to be flipped around.
*/

  if(user_props & EMED_REVERSED)
   {
     EMrevpypts(EMmsg,&my_pypoints,MAXINT);
     if(!(1 & *EMmsg)) {*EMmsg = EMS_E_EdgeError; goto wrapup;}
     else *EMmsg = EMS_S_Success;
     if(against_bdrys) EMrevsfintedpar(EMmsg,against_bdrys,MAXINT);
     if(! (1 & *EMmsg)) goto wrapup;
   }

  this_pypoint = my_pypoints;
  this_sfintedpar = my_bdrys ? *my_bdrys : NULL;
  against_sfintedpar = against_bdrys ? *against_bdrys : NULL;
  for(i=0; (i<(*num_bdrys)*2) && this_sfintedpar ;i++)
   {
     this_sfintedpar->edgeid = user_id;
     this_sfintedpar->info = NULL;
     against_sfintedpar->info = NULL;
     if(part)
      {
        in_par.span_inx = this_pypoint->span_inx;
        in_par.param = this_pypoint->param;
	EMcnvtedpar(EMmsg,part->edbdry,&part->edbdry[1],&in_par,
		    &this_sfintedpar->edgepar);
	EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
      }
     else
      {
	this_sfintedpar->edgepar.span_inx = this_pypoint->span_inx;
	this_sfintedpar->edgepar.param = this_pypoint->param;
      }
     OM_BLOCK_MOVE(this_pypoint->point, this_sfintedpar->point, 
				2 * sizeof(IGRdouble));
     this_sfintedpar->intloc = IntLoc(this_pypoint->props);
     if(user_props & EMED_REVERSED)
      {
       if(this_sfintedpar->intloc == EMScvint_rtend)
         this_sfintedpar->intloc = EMScvint_lfend;
       else if(this_sfintedpar->intloc == EMScvint_lfend)
         this_sfintedpar->intloc = EMScvint_rtend;
      }

     this_pypoint = this_pypoint->next;
     this_sfintedpar = this_sfintedpar->next;
     against_sfintedpar = against_sfintedpar->next;
   }


/* If the edge is closed and it has more than one boundary then there
   may be a unnecessary duplicate boundary at the begin and at the
   end. So delete that boundary and rearrange the link list.

   28-Nov-87 --
   This removal of boundaries should take place only if it is at the endpoints
   of the edge. The internal duplicate boundaries might (and should) occur
   if there are coincedent edges in the loopset.

   30-Dec-87 --
   Removal of boundaries only if they are 'dangling' in space and have no
   intersections on the edges of the loop/loopset and addition to being
   coincedent.

   18-Oct-88 --
   If the option is to ignore the closure, the removal criteria for closed
   edges is not applied. - SS
*/
  if(!(user_props & EMED_OPEN) && 
     !(options & EMS_INTER_CLOSEOVERRIDE) && 
     *num_bdrys > 1)
   {
	struct EMSsfintedpar	*last_ed,*new_head,*sec_last_ed;
	struct EMSsfintedpar	*last_el,*sec_last_el;
	IGRlong			rc;
	
	if(!par_obtained)
	 {
  	  if(!partolbasis->is_valid)
   	   {
     	     sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
     	     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   	   }
  	  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
	  par_obtained = TRUE;
	 }

        NodeAddress(*my_bdrys,2*(*num_bdrys),last_ed);
        NodeAddress(*against_bdrys,2*(*num_bdrys),last_el);	

	if( (IF_NULL_OBJID(last_el->edgeid) ||
	     IF_NULL_OBJID( (*against_bdrys)->edgeid) ||
	     (IF_EQ_OBJID(last_el->edgeid, (*against_bdrys)->edgeid) /*&&
	       !WANT_POST220_BEHAVIOR*/)) &&
	    ((*my_bdrys)->intloc == EMScvint_lfend) &&
	     (last_ed->intloc == EMScvint_rtend)
	  )
	 {
	   NodeAddress(*my_bdrys,2*(*num_bdrys)-1,sec_last_ed);
	   NodeAddress(*against_bdrys,2*(*num_bdrys)-1,sec_last_el);
	   NodeAddress(*my_bdrys,3,new_head);
	   sec_last_ed->next = (*my_bdrys)->next;
	   (*my_bdrys)->next->next = NULL;
	   EMsfintedpar_free(*my_bdrys,1);
	   EMsfintedpar_free(last_ed,1);
	   (*my_bdrys) = new_head;
	    (*num_bdrys)--;
	   NodeAddress((*against_bdrys),3,new_head);
	   sec_last_el->next = (*against_bdrys)->next;
	   (*against_bdrys)->next->next = NULL;
	   EMsfintedpar_free((*against_bdrys),1);
	   EMsfintedpar_free(last_el,1);
	   (*against_bdrys) = new_head;
	 }
   }

/* After the boundaries on the edge have been finalised, see if the
   edge in completely in hole, completely in area or partially
   trimmed. Convey this message to the caller via the return code.
*/
   if( !(*num_bdrys)) { in_area = FALSE; in_hole = TRUE; intersect = FALSE;}
   else if( (*num_bdrys == 1) && (!in_area))
    {
      IGRlong	rc;
      struct EMSsfintedpar *last_el;

      if(!par_obtained)
       {
  	 if(!partolbasis->is_valid)
   	  {
            sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
     	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   	  }
  	 sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
       }

      NodeAddress(*against_bdrys,2*(*num_bdrys),last_el);
	
      if( my_bdrys && 
          ((*my_bdrys)->intloc == EMScvint_lfend) &&
	  ((*my_bdrys)->next->intloc == EMScvint_rtend))
	 { in_area = TRUE; in_hole = FALSE; intersect = FALSE;}
      else { in_area = FALSE; in_hole = FALSE; intersect = TRUE;}
    }
   else if(!in_area) { in_area = FALSE; in_hole = FALSE; intersect = TRUE;}
   
wrapup:
/* Deallocate the EMpypoint link list which was allocated in parttrim
*/
   if(my_pypoints)
       EMpypoint_free(my_pypoints,NULL);
   if(my_poly.points && (my_poly.points != ptsbuff)) 
       om$dealloc(ptr=my_poly.points);

   if (my_curve.poles && (my_curve.poles != polesbuff)) free (my_curve.poles);
   if (my_curve.knots && (my_curve.knots != knotsbuff)) free (my_curve.knots);
   if (my_curve.weights && (my_curve.weights != wtsbuff)) 
						free (my_curve.weights);
   if (my_curve.bdrys) free (my_curve.bdrys);

   if(1 & *EMmsg & sts)
    {
      if(in_area) *EMmsg = EMS_I_InAreaTrim;
      else if(in_hole) *EMmsg = EMS_I_InHoleTrim;
      else *EMmsg = EMS_I_IntersectTrim;
    }

   EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMtrimyourself");    
   return (sts);
}

end implementation EMSedge;
