/*
This node can create intersection edges.

keying mechanism -
key[0] - inters node in the intersection list (the surface)
key[1] - intobj node on that surface.
*/
class implementation NMinters;

#include "OMmacros.h"
#include "EMSkey.h"

from EMSboundary import EMget_put_creator_id;

method EMtranslate_id_key(IGRlong *EMmsg; 
                          unsigned int options;
                          struct GRmd_env *md_env;
                          GRobjid *component_objid;
                          IGRint *key_size;
                          IGRchar **key)
{
 IGRlong		sts = OM_S_SUCCESS;
 GRobjid		creatorid;
 IGRint			i, locnuminters = 0, locnumcvs = 0;
 IGRboolean		bingo = FALSE;
 struct EMSinters	*inters[2], *this_inters = NULL;
 struct EMSintobj	*this_intobj = NULL;
 struct EMSdataselect	*this_data = NULL;
 struct EMSkey		lockey[2];

 *EMmsg = EMS_S_Success;
 for(i=0; i<2; i++)
  {
   inters[i] = NULL;
   lockey[i].chan_count = 0;
   lockey[i].chan_index = 0;
   lockey[i].sub_item_type = EMSkey_UNKNOWN;
  }


 if(options & EMS_OPT_KEY_FROM_ID)
  {
   /* We know that any edge created by this node will always have
      exactly 2 key counts. So if only the size is desired, return it.
   */
   if(key_size && !key)
    {
     *key_size = 2 * sizeof(struct EMSkey);
     goto wrapup;
    }

   if(!EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
       OPP_EMSboundary_class_id, FALSE))
    {
     *EMmsg = EMS_I_Useless;
     goto wrapup;
    }

   sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
         &creatorid, FALSE), targetid = *component_objid);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* If I am not the creator, why did this message come to me? Untill I find
      out, returning an error.
   */
   EMerr_hndlr(!IF_EQ_OBJID(creatorid, my_id), *EMmsg, EMS_E_InvalidSend,
               wrapup);


   /* Get my intersection data.
   */
   sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
         &inters[1], NULL, NULL, NULL, NULL, NULL), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   
   lockey[0].sub_item_type = EMSkey_CONNECTOR; /* used to be SURFACE */
   lockey[0].chan_index = 0;

   /* Set total number of intersecting surfaces.
   */
   lockey[0].chan_count = 0;
   for(i=0; i<2; i++)
    {
     this_inters = inters[i];
     while(this_inters)
      {
       lockey[0].chan_count++;
       this_inters = this_inters->next;
      }
    }

   for(i=0; i<2; i++)
    {
     this_inters = inters[i];
     while(this_inters)
      {
       lockey[1].sub_item_type = EMSkey_EDGE;
       lockey[1].chan_index = 0;
      
       /* Set total number of intersections on this surface.
       */
       lockey[1].chan_count = 0;
       this_intobj = this_inters->cvs;
       while(this_intobj)
        {
         lockey[1].chan_count++;
         this_intobj = this_intobj->next;
        }

       this_intobj = this_inters->cvs;
       while(this_intobj)
        {
         this_data = &this_intobj->this_uvintobj;
         if( (this_data->datatype == EMSdata_object) &&
	     (IF_EQ_OBJID(this_data->data.object->objid, *component_objid)))
          {
	   bingo = TRUE;
	   break;
	  }
         this_intobj = this_intobj->next;
         lockey[1].chan_index++;

        } /* while(this_intobj) */

       if(bingo) break;
       this_inters = this_inters->next;
       lockey[0].chan_index++;

      } /* while(this_inters) */

     if(bingo) break;

    } /* for(i=0; i<2; i++) */

   EMerr_hndlr(!bingo, *EMmsg, EMS_I_Fail, wrapup);

   if(key)
    {
     struct EMSkey *locptr = NULL;

     if(!*key)
      {
       locptr = (struct EMSkey *) om$malloc(size = 2 * sizeof(struct EMSkey));
       EMerr_hndlr(!locptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       *key = (IGRchar *) locptr;
      }
     else locptr = (struct EMSkey *) *key;
     OM_BLOCK_MOVE(lockey, locptr, 2 * sizeof(struct EMSkey));
    }
   if(key_size) *key_size = 2 * sizeof(struct EMSkey);

  }
 else if(options & EMS_OPT_ID_FROM_KEY)
  {
   struct EMSkey *locptr;

   *component_objid = NULL_OBJID;
   EMerr_hndlr(*key_size != 2 * sizeof(struct EMSkey), *EMmsg, 
               EMS_E_InvalidArg, wrapup);
   /* Get my intersection data.
   */
   sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
         &inters[1], NULL, NULL, NULL, NULL, NULL), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;

   locptr = (struct EMSkey *) *key;
   OM_BLOCK_MOVE(locptr, lockey, 2*sizeof(struct EMSkey));

   /* If the first key is not for a surface, or if the surface
      index coming in is greater than total number of surfaces with
      intersections, signal a mismatch and quit.
      I am not checking the count mismatch in number of surfaces
      so as to allow cases where the index coming in less then total surfaces
      with intersections, even if there is a count mismatch.
   */
   locnuminters = 0;
   for(i=0; i<2; i++)
    {
     this_inters = inters[i];
     while(this_inters)
      {
       locnuminters++;
       this_inters = this_inters->next;
      }
    }
   EMerr_hndlr( (locptr[0].sub_item_type != EMSkey_CONNECTOR) ||
                (locptr[0].chan_index > (locnuminters - 1)), *EMmsg,
                EMS_I_Fail, wrapup);

   for(i=0; i<2; i++)
    {
     this_inters = inters[i];
     while(this_inters)
      {
       /* Run down the surface index to reach the correct surface node.
       */
       if(lockey[0].chan_index)
        {
         this_inters = this_inters->next;
         lockey[0].chan_index--;
         continue;
        }

       locnumcvs = 0;
       this_intobj = this_inters->cvs;
       while(this_intobj)
        {
         locnumcvs++;
         this_intobj = this_intobj->next;
        }
       EMerr_hndlr( (locptr[1].sub_item_type != EMSkey_EDGE) ||
                    (locptr[1].chan_index > (locnumcvs - 1)), *EMmsg,
                    EMS_I_Fail, wrapup);

       this_intobj = this_inters->cvs;
       while(this_intobj)
        {
         /* Run down the edge index to reach the correct intersection node.
         */
         if(lockey[1].chan_index)
          {
           this_intobj = this_intobj->next;
           lockey[1].chan_index--;
           continue;
          }

         this_data = &this_intobj->this_uvintobj;
         bingo = TRUE;
         *component_objid = this_data->data.object->objid;
         break;

        } /* while (this_intobj) */

       break;

      } /* while(this_inters) */

     if(bingo) break;

    } /* for(i=0; i<2; i++) */

   EMerr_hndlr(!bingo, *EMmsg, EMS_I_Fail, wrapup);

   if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
       OPP_EMSboundary_class_id, FALSE))
    {
     sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* If I am not the creator, why did this message come to me? Untill I find
        out, returning an error.
     */
     EMerr_hndlr(!IF_EQ_OBJID(creatorid, my_id), *EMmsg, EMS_E_InvalidSend,
               wrapup);
    }

  }

wrapup:
 for(i=0; i<2; i++)
  {
   IGRlong rc;
   if(!inters[i]) continue;
   (void) NMset_object_data_to_null(inters[i], TRUE, TRUE);
   EMinters_data_free(&rc, inters[i], MAXINT, NULL, NULL);
   EMinters_free(inters[i], MAXINT);
  }

EMWRAPUP(*EMmsg, sts, "NMinters.EMtranslate_id_key");
return(sts);
}

end implementation NMinters;
