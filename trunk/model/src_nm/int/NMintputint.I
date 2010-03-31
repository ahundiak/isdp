class implementation NMinters;

/* This method accepts the intersection data in the NMinters format and
stores it in the instance data.

History
	SM	03-Apr-91	Genesis
*/

#include "EMSmsgdef.h"
#include "nmchandef.h"
#include "OMmacros.h"

from NMintcurve import NMput_curve;
from NMintpoly import NMput_poly;
from EMSsubbs import EMget_props;

extern OMuword OPP_NMintcurve_class_id, OPP_NMintpoly_class_id;
void		NMset_other_idx();

method NMput_inters(IGRlong *EMmsg; struct EMSinters *inters, *other_inters;
		    struct EMSobject_info *op;
                    enum NMbooltype *bool_type; IGRdouble *cht;
		    IGRushort options)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct EMSinters 	*this_inters = NULL;
 struct EMSintobj 	*this_intobj = NULL;
 struct EMSdataselect	*this_data = NULL;
 struct EMSsfintedpar	*this_edpar;
 IGRint 		num_inters = 0, num_intobjs = 0,
			num_objs = 0, num_doubles = 0, num_storage = 0, 
			num_sfedpars = 0, total_size = 0;
 IGRint			storage_idx = 0, i, j;

 IGRint			num_ints = 0, num_shorts = 0, num_longs = 0, 
			num_chars = 0, intsidx = 0, doublesidx = 0, 
			shortsidx = 0, charsidx = 0, longsidx = 0;
 IGRint			*intdata = NULL;
 IGRdouble		*doubledata = NULL;
 IGRshort		*shortdata = NULL;
 IGRchar		*chardata = NULL;
 IGRlong		*longdata = NULL;

 *EMmsg = EMS_S_Success;

 /* Get sizes for various arrays
 */
 this_inters = inters;
 while(this_inters)
  {
   for(i=0; i<2; i++)
    {
     this_intobj = i ? this_inters->cvs : this_inters->pts;
     while(this_intobj)
      {
       num_intobjs++;
       for(j=0; j<2; j++)
        {
         this_data = j ? &this_intobj->this_uvintobj : &this_intobj->this_xyzintobj;
         switch(this_data->datatype)
          {
           case EMSdata_poly2d:
           case EMSdata_poly3d:
           case EMSdata_curve3d:
           case EMSdata_curve2d:
            num_storage++;
            break;
           case EMSdata_object:
             (num_objs)++;
           break;

           case EMSdata_null:
           break;

           default:
            *EMmsg = EMS_E_InvalidArg;
           goto wrapup;

          } /* switch(this_data->datatype) */

         } /* for(j=0; j<2; j++) */

         this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
         while(this_edpar) 
          {
	   if(!IF_NULL_OBJID(this_edpar->edgeid))
	    {
	     num_sfedpars++;
	     num_objs++;
	     num_doubles+=2;
	    }
	   this_edpar = this_edpar->next;
          }
         this_intobj = this_intobj->next;

        } /* while(this_intobj) */

     } /* for(i=0; i<2; i++) */

    num_inters++;
    num_objs++;	/* GRid in the inters structure */

    this_inters = this_inters->next;

  } /* while(this_inters) */


 /*
  EMSinters.num_pts
  EMSinters.num_cvs
  OM_S_OBJID
  EMSintobj.props
 */
 num_longs = (num_inters * 2) + num_objs + num_intobjs; 

 /*
  other_node_idx for each intobj
  2 datatypes for each intobj
  EMSsfedpar.intloc
 */
 num_ints = num_intobjs + (num_intobjs * 2)
	    + num_sfedpars;

 /*
  EMSintobj.reversed
  EMSedgebound.span_inx
  GRspacenum
 */
 num_shorts = num_intobjs + num_sfedpars + num_objs;

 /*
  dangling flag for each intobj.
 */
 num_chars = num_intobjs;

 /*
  EMSsfintedpar.point  -- counted above
  EMSedgebound.param
 */  
 num_doubles += num_sfedpars;

 total_size = (num_ints * sizeof(IGRint)) +
              (num_shorts * sizeof(IGRshort)) +
              (num_chars * sizeof(IGRchar)) +
              (num_doubles * sizeof(IGRdouble)) +
              (num_longs * sizeof(IGRlong));

 om$vla_set_dimension(varray = ME.NMinters->data, size = total_size);
 doubledata = (IGRdouble *) ME.NMinters->data;
 longdata = (IGRlong *) (doubledata + num_doubles);
 intdata = (IGRint *) (longdata + num_longs);
 shortdata = (IGRshort *) (intdata + num_ints);
 chardata = (IGRchar *) (shortdata + num_shorts);


 ME.NMinters->num_datatypes[0] = num_doubles;
 ME.NMinters->num_datatypes[1] = num_longs;
 ME.NMinters->num_datatypes[2] = num_ints;
 ME.NMinters->num_datatypes[3] = num_shorts;

 om$vla_set_dimension(varray = ME.NMinters->storage_objs, size = num_storage);

 /* insert the intersection data into my instance data
 */
 ME.NMinters->num_inters = num_inters;
 this_inters = inters;
 while(this_inters)
  {
   shortdata[shortsidx++] = this_inters->this_obj.osnum;
   longdata[longsidx++] = this_inters->this_obj.objid;

   longdata[longsidx++] = this_inters->num_pts;
   longdata[longsidx++] = this_inters->num_cvs;

   for(i=0; i<2; i++)
    {
     this_intobj = i ? this_inters->cvs : this_inters->pts;
     while(this_intobj)
      {
       shortdata[shortsidx++] = this_intobj->reversed;
       longdata[longsidx++] = (IGRshort) this_intobj->props;

       if(other_inters)
        NMset_other_idx(this_intobj, other_inters, &intdata[intsidx++]);
       else intdata[intsidx++] = InvalidIntobjIndex;

       this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
       chardata[charsidx] = NULL;

       while(this_edpar)
        {
	 if(!IF_NULL_OBJID(this_edpar->edgeid))
	  {
	   intdata[intsidx++] = this_edpar->intloc;
	   longdata[longsidx++] = this_edpar->edgeid;
	   shortdata[shortsidx++] = this_edpar->edgepar.span_inx;
	   doubledata[doublesidx++] = this_edpar->edgepar.param;
	
	   OM_BLOCK_MOVE(this_edpar->point, 
			 &doubledata[doublesidx], 
	   2 * sizeof(IGRdouble));
	   doublesidx += 2;
	  }
	 else 
	  {
	   if(this_edpar == (struct EMSsfintedpar *) this_intobj->more_info)
	    chardata[charsidx] |= FirstDangling;
	   else
	    chardata[charsidx] |= SecondDangling;
	  }
	 this_edpar = this_edpar->next;
        }
       charsidx++;

       for(j=0; j<2; j++)
        {
	 this_data = j ? &this_intobj->this_uvintobj 
	               : &this_intobj->this_xyzintobj;
	 intdata[intsidx++] = this_data->datatype;

	 switch(this_data->datatype)
	  {
	   case EMSdata_object:
	    {
	     shortdata[shortsidx++] = 
		this_data->data.object->osnum;
	     longdata[longsidx++] = this_data->data.object->objid;
	
	    }
	   break;
	
	   case EMSdata_poly3d:
	   case EMSdata_poly2d:
	    {
	     struct IGRpolyline *junk;
	     unsigned char polyprops = NULL;
             GRobjid polyid;
          
	     junk = this_data->data.poly;
 	     polyprops = this_data->datatype == EMSdata_poly3d ? NULL :
						NMintobject_Is2d;
						
 	     sts = om$construct(classid = OPP_NMintpoly_class_id, 
		   p_objid = &polyid, msg = message NMintpoly.NMput_poly
		   (EMmsg, junk, polyprops));
	     if(!(1&*EMmsg&sts)) goto wrapup;
	     ME.NMinters->storage_objs[storage_idx++] = polyid;
	    }
	   break;
	
	   case EMSdata_curve2d:
	   case EMSdata_curve3d:
	    {
	     struct IGRbsp_curve *junk;
	     unsigned char cvprops = NULL;
	     GRobjid cvid;
	
	     junk = this_data->data.curve;
	     cvprops = this_data->datatype == EMSdata_curve3d ? NULL :
						NMintobject_Is2d;
						
 	     sts = om$construct(classid = OPP_NMintcurve_class_id, 
		   p_objid = &cvid, msg = message NMintcurve.NMput_curve
		   (EMmsg, junk, cvprops));
	     if(!(1&*EMmsg&sts)) goto wrapup;
	     ME.NMinters->storage_objs[storage_idx++] = cvid;
	    }
	   break;

	   case EMSdata_null:
	   break;
	
	   default:
	    *EMmsg = EMS_E_InvalidArg;
	    goto wrapup;
	
	  } /*switch(this_data->datatype)*/
	
        } /* for(j=0; j<2; j++) */

       this_intobj = this_intobj->next;
      } /* while(this_intobj) */

    } /* for(i=0; i<2; i++) */

   this_inters = this_inters->next;

  } /* while(this_inters) */


 if(bool_type) ME.NMinters->operation = *bool_type;
 if(cht) ME.NMinters->cht = *cht;


 /* Store the 'other inters' in the counterpart object and connect myself
    to it on the private channel.
 */
 if(options & NMputint_StoreOther)
  {
   GRobjid junk;
   OM_S_CHANSELECT to_other_int;
   OMuint count = 0;

   NMmake_chanselect(NMinters_to_other_int, &to_other_int);
   sts = om$get_channel_count(object = me, p_chanselect = &to_other_int, 
         count = &count);
   if(!(1&sts)) goto wrapup;
   if(!count)
    {
     unsigned char intprops = NMinters_IsVolInt;

     sts = om$construct(classid = OPP_NMinters_class_id, p_objid = &junk, 
           msg = message NMinters.NMprop(EMmsg, NMprop_SetOn, &intprops));
     if(!(1&sts)) goto wrapup;
     sts = om$send(msg = message Root.connect(to_other_int, 0, my_id, 
           OM_Gw_current_OS, to_other_int, 0), targetid = junk);
     if(!(1&sts)) goto wrapup;
    }
   sts = om$send(msg = message NMinters.NMput_inters
           (EMmsg, other_inters, inters, NULL, bool_type, cht, NULL), 
           p_chanselect = &to_other_int);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "NMinters.NMput_inters");
return(sts);
}





/* Given an intobj node, search the 'other' inters list and get the index
   of this intobj's counterpart in it.
*/
static void NMset_other_idx(intobj, other_inters, idx)
struct EMSintobj *intobj;
struct EMSinters *other_inters;
IGRint *idx;
{
 struct EMSintobj *search_intobj = NULL, *this_intobj;
 struct EMSinters *this_inters;
 IGRboolean bingo = FALSE;
 IGRint locidx = 0;

 *idx = InvalidIntobjIndex;
 search_intobj = intobj->other_intobj_node;
 if(!search_intobj) goto wrapup;

 this_inters = other_inters;
 while(this_inters && !bingo)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj && !bingo)
    {
     if(this_intobj == search_intobj)
      {
       bingo = TRUE;
       break;
      }
     this_intobj = this_intobj->next;
     locidx++;
    }
   this_inters = this_inters->next;
  }

 if(bingo) *idx = locidx;

wrapup:
;
}


end implementation NMinters;
