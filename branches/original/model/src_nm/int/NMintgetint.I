
/* This method returns the intersection data, stored in its instance
data, in the NMinters format.

History
	SM	03-Apr-91	Genesis
        NP      18-Jun-93       Funtction "EMmkintlist" is now called by a new
                                name, "EMmakeintlist", due to addition of two
                                new curve type parameters.
                                NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN
                                      THE CALL (CURRENTLY SET TO NULL).
*/
class implementation NMinters;

#include "EMSmsgdef.h"
#include "nmchandef.h"
#include "OMmacros.h"
#include "emsmacros.h"

from NMintcurve import NMget_curve;
from NMintpoly import NMget_poly;

extern OMuword OPP_NMtrim_class_id, OPP_EMSsurface_class_id;
IGRint		NMis_data_uptodate();
void NMget_other_intobj();
method NMget_inters(IGRlong *EMmsg; struct EMSinters **inters, **other_inters;
		    struct EMSobject_info *op;
                    struct EMSsftracedata *tracedata; 
                    enum NMbooltype *bool_type; IGRdouble *cht;
		    IGRushort options)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct EMSinters 	*loc_other_inters = NULL;
 struct EMSdataselect	*this_data = NULL;
 IGRint			storage_idx = 0, i, j, l, m, n;
 IGRint			intsidx = 0, doublesidx = 0, shortsidx = 0, 
			charsidx = 0, longsidx = 0;
 IGRdouble		tracetol;
 IGRshort		mattyp;
 IGRmatrix		mat;
 struct EMSobject_info	locop[2], *opptr = NULL;
 IGRint			opcount = 0;
 IGRboolean		uptodate = TRUE;
 IGRdouble		*doubledata = NULL;
 IGRint			*intdata = NULL;
 IGRshort		*shortdata = NULL;
 IGRchar		*chardata = NULL;
 IGRlong		*longdata = NULL;


*EMmsg = EMS_S_Success;

*inters = NULL;
if(other_inters) *other_inters = NULL;

if(other_inters && (ME.NMinters->num_inters))
 {
  OM_S_CHANSELECT to_other_int;
 
  NMmake_chanselect(NMinters_to_other_int, &to_other_int);
  sts = om$send(msg = message NMinters.NMget_inters(EMmsg, other_inters, NULL, 
        NULL, NULL, NULL, NULL, options), p_chanselect = &to_other_int);
  if(!(1&*EMmsg&sts)) goto wrapup;
 }

if(ME.NMinters->num_inters)
 {
  doubledata = (IGRdouble *) ME.NMinters->data;
  longdata = (IGRlong *) (doubledata + ME.NMinters->num_datatypes[0]);
  intdata = (IGRint *) (longdata + ME.NMinters->num_datatypes[1]);
  shortdata = (IGRshort *) (intdata + ME.NMinters->num_datatypes[2]);
  chardata = (IGRchar *) (shortdata + ME.NMinters->num_datatypes[3]);
 }

for(i=0; i<ME.NMinters->num_inters; i++)
{
 struct GRid this_obj;
 IGRint num_pts, num_cvs;

 this_obj.objid = longdata[longsidx++];
 this_obj.osnum = shortdata[shortsidx++];

 sts = om$is_objid_valid(osnum = this_obj.osnum, objid = this_obj.objid);
 if(sts != OM_S_SUCCESS)
  {
   this_obj.objid = NULL_OBJID;
   sts = OM_S_SUCCESS;
  }
 if(!(1&sts)) goto wrapup;
 num_pts = longdata[longsidx++];
 num_cvs = longdata[longsidx++];

 for(m=0; m<2; m++)
  {
   IGRint num;
   IGRboolean is_curve;

	
   is_curve = m ? TRUE : FALSE;
   num = m ? num_cvs : num_pts;

   for(j=0; j<num; j++)
    {
     struct EMSdataselect this_xyzintobj, this_uvintobj;
     enum EMSdatatype dattyp;
     struct EMSsfintedpar *edpars = NULL, *this_edpar = NULL;
     unsigned char dangling;

     struct EMSinters **inters_a = NULL, **inters_b = NULL;
     struct GRid *object_a = NULL, *object_b = NULL;
     struct EMSdataselect *xyzintobj = NULL, *uv_a = NULL, *uv_b = NULL;
     IGRboolean rev_a = FALSE, rev_b = FALSE;
     struct EMSsfintedpar *more_a = NULL, *more_b = NULL;
     IGRushort props_a = NULL, props_b = NULL;

     struct EMSintobj *other_intobj = NULL;

     rev_a = shortdata[shortsidx++];
     props_a = (unsigned long) longdata[longsidx++];

     if(other_inters && *other_inters)
      NMget_other_intobj(*other_inters, intdata[intsidx++], &other_intobj);
     else
      {
       other_intobj = NULL;
       intsidx++;
      }

     dangling = (unsigned char) chardata[charsidx++];
     edpars =(struct EMSsfintedpar *)EMsfintedpar_malloc(EMmsg,MaxNumEdpars);
     this_edpar = edpars;
     for(n=0; n<MaxNumEdpars; n++)
      {
       if( (!n && (dangling & FirstDangling)) ||
	   (n &&  (dangling & SecondDangling)))
        this_edpar->edgeid = NULL_OBJID;
       else
        {
         this_edpar->intloc = (enum EMScvinttype) intdata[intsidx++];
         this_edpar->edgeid = longdata[longsidx++];
         sts = om$is_objid_valid(osnum = this_obj.osnum, 
	         objid = this_edpar->edgeid);
	 if(sts != OM_S_SUCCESS)
	  {
	   this_edpar->edgeid = NULL_OBJID;
	   sts = OM_S_SUCCESS;
	  }
         if(!(1&sts)) goto wrapup;
         this_edpar->edgepar.span_inx = shortdata[shortsidx++];
         this_edpar->edgepar.param = doubledata[doublesidx++];

         OM_BLOCK_MOVE(&doubledata[doublesidx], 
		       this_edpar->point, 2 * sizeof(IGRdouble));
         doublesidx += 2;
        }
       this_edpar = this_edpar->next;
      }

     for(l=0; l<2; l++)
      {
       this_data = l ? &this_uvintobj : &this_xyzintobj;
       switch( (dattyp = (enum EMSdatatype) intdata[intsidx++]))
        {
	 case EMSdata_object:
	  {
	   struct GRid *obj;
	
	   obj = (struct GRid *) om$malloc(size = sizeof(struct GRid));
	   obj->osnum = shortdata[shortsidx++];
	   obj->objid = longdata[longsidx++];
	
	   sts = om$is_objid_valid(osnum = obj->osnum, objid = obj->objid);
	   if(sts != OM_S_SUCCESS)
	    {
	     obj->objid = NULL_OBJID;
	     dattyp = EMSdata_null;
	     sts = OM_S_SUCCESS;     
	    }
	   if(!(1&sts)) goto wrapup;
	   this_data->data.object = obj;
	  }
	 break;
	
	 case EMSdata_poly2d:
	 case EMSdata_poly3d:
	  {
	   struct IGRpolyline *poly;

	   if(options & NMgetint_NoStorageObjs)
	    {
	     dattyp = EMSdata_null;
	     storage_idx++;
	     break;
	    }
	   poly = (struct IGRpolyline *) om$malloc(size = 
		  sizeof(struct IGRpolyline));
	   sts = om$send(msg = message NMintpoly.NMget_poly(EMmsg, poly, NULL),
		 targetid = ME.NMinters->storage_objs[storage_idx++]);
	   if(!(1&*EMmsg&sts)) goto wrapup;
	   this_data->data.poly = poly;

	  } /* case poly */
	 break;
	
	 case EMSdata_curve3d:
	 case EMSdata_curve2d:
	  {
	   struct IGRbsp_curve *cv;

	   if(options & NMgetint_NoStorageObjs)
	    {
	     dattyp = EMSdata_null;
	     storage_idx++;
	     break;
	    }
	
	   cv = (struct IGRbsp_curve *) om$malloc(size = 
		 sizeof(struct IGRbsp_curve));
	   sts = om$send(msg = message NMintcurve.NMget_curve(EMmsg, cv, NULL),
		 targetid = ME.NMinters->storage_objs[storage_idx++]);
	   if(!(1&*EMmsg&sts)) goto wrapup;
	   this_data->data.curve = cv;

	  } /* case curve */
	 break;
	
        } /* switch(dattyp) */

       this_data->datatype = dattyp;

      } /* for(l=0; l<2; l++) */

     inters_a = inters;
     object_a = &this_obj;
     xyzintobj = &this_xyzintobj;
     uv_a = &this_uvintobj;
     more_a = edpars;
     if(other_intobj)
      {
       inters_b = &loc_other_inters;
       object_b = &other_intobj->this_obj_node->this_obj;
       uv_b = &other_intobj->this_uvintobj;
       rev_b = other_intobj->reversed;
       more_b = (struct EMSsfintedpar *) other_intobj->more_info;
       props_b = other_intobj->props;
      }

     EMmakeintlist(EMmsg, inters_a, inters_b, object_a, object_b, NULL, NULL, 
		 NULL, NULL, xyzintobj, uv_a, uv_b, rev_a, rev_b, more_a, 
		 more_b, props_a, props_b, NULL, NULL, is_curve, FALSE);

    } /* for(j=0; j<num; j++)  -- for every intobj */

   } /* for(m=0; m<2; m++) -- for pts and cvs in each inters node */

  } /* for(i=0; i<ME.NMinters->num_inters; i++) */

if(bool_type) *bool_type = ME.NMinters->operation;
if(cht) *cht = ME.NMinters->cht;

if(op)
 {
  opptr = locop;
  sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &opptr, 2, 
        &opcount), targetid = my_id);
  if(!(1&*EMmsg&sts)) goto wrapup;
  EMerr_hndlr(opcount > 2, *EMmsg, EMS_E_Fail, wrapup);
  if(opcount) OM_BLOCK_MOVE(opptr, op, 2*sizeof(struct EMSobject_info));
 }

if(inters && *inters)
 {
  sts = NMis_data_uptodate(EMmsg, *inters, &uptodate);
  if(!(1&*EMmsg&sts)) goto wrapup;
 }

if(uptodate && other_inters && *other_inters)
 {
  sts = NMis_data_uptodate(EMmsg, *other_inters, &uptodate);
  if(!(1&*EMmsg&sts)) goto wrapup;
 }


if(other_inters && *other_inters && loc_other_inters)
 {
  EMinters_free(*other_inters, MAXINT);
  *other_inters = loc_other_inters;
  loc_other_inters = NULL;
 }

tracetol = ME.NMinters->cht * 2;

if( (1&*EMmsg&sts) && tracedata && inters && *inters)
 {
  EMidmatrix(EMmsg, &mattyp, mat);
  EMsfinttrace (EMmsg, &mattyp, mat, *inters, NULL, &tracetol,
     &tracedata->num_grps, &tracedata->num_subgrps_grp, 
     &tracedata->num_elems_subgrp, &tracedata->elems, &tracedata->subgrp_rev, 
     &tracedata->elem_rev, &tracedata->grp_closed, &tracedata->subgrp_closed);
 }
wrapup:
if(opptr && (opptr != locop)) om$dealloc(ptr = opptr);
if( (1&*EMmsg&sts) && !uptodate) *EMmsg = EMS_I_Modified;
EMWRAPUP(*EMmsg, sts, "NMinters.NMget_inters") ;
return(sts);
}




static void NMget_other_intobj(inters, idx, intobj)
struct EMSinters *inters;
IGRint idx;
struct EMSintobj **intobj;
{
 IGRint locidx = 0;
 struct EMSinters *this_inters = NULL;
 struct EMSintobj *this_intobj = NULL;
 IGRboolean bingo = FALSE;

 *intobj = NULL;
 if(idx == InvalidIntobjIndex) goto wrapup;

 this_inters = inters;
 while(this_inters && !bingo)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj && !bingo)
    {
     if(locidx == idx)
      {
       bingo = TRUE;
       break;
      }
     locidx++;
     this_intobj = this_intobj->next;
    }
   this_inters = this_inters->next;
  }
 *intobj = this_intobj;

wrapup:
;
}



static IGRint NMis_data_uptodate(EMmsg, inters, is_uptodate)
IGRlong *EMmsg;
struct EMSinters *inters;
IGRboolean *is_uptodate;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			num = 0;
 struct EMSinters	*this_inters = NULL;
 struct EMSintobj	*this_intobj = NULL;
 struct GRid		*this_edge = NULL;

 *EMmsg = EMS_S_Success;
 *is_uptodate = TRUE;

 this_inters = inters;
 while(this_inters)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     if(this_intobj->this_uvintobj.datatype == EMSdata_object)
      this_edge = this_intobj->this_uvintobj.data.object;
     else goto next_intobj;

     /* If any edge is owned by a partedge set out-of-date flag and exit.
     */
     sts = EMcount_partedges(EMmsg, this_edge->objid, &num, NULL, 
	   NULL, NULL, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(num) 
      {
       *is_uptodate = FALSE;
       goto wrapup;
      }

     num = 0;
     sts = NMcount_nmpartedges(EMmsg, this_edge->objid, this_edge->osnum, 
           &num, NULL, NULL, NULL, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(num) 
      {
       *is_uptodate = FALSE;
       goto wrapup;
      }

next_intobj:
     this_intobj = this_intobj->next;
    }
   this_inters = this_inters->next;
  }

wrapup:
return(sts);
}

end implementation NMinters;
