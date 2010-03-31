/*
Take the top partedges from inters1 and regenerate intersection data for
inters2. Corresponding new lists are inters3 and inters4.
For parametric space, only object data is handled.
*/
class implementation NMinters;

/* HISTORY

 SM    ???????      Creation

 NP    6/17/93      Funtction "EMmkintlist" is now called by a new
                    name, "EMmakeintlist", due to addition of two
                    new curve type parameters.
                    NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN
                          THE CALL (CURRENTLY SET TO NULL).


*/


#include "emsmapdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsinterdef.h"

from EMSedge import EMget_bcxyz_geom, EMget_top_part_edges, EMtrimyourself;
from EMSboundary import EMtpcopy;

void		NMcopy_edpar_bdry();
IGRint NMregenerate_inters(EMmsg, inters1, inters2, inters3, inters4, cht, 
                           construct, ssi)
IGRlong *EMmsg;
struct EMSinters *inters1, *inters2, **inters3, **inters4;
IGRdouble cht;
struct GRvg_construct *construct;
struct NMgmSSI *ssi;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct EMSinters	*this_inters = NULL;
 struct EMSintobj	*this_intobj = NULL, *other_intobj = NULL;
 struct EMSdataselect	this_xyzintobj, this_uvintobj1, this_uvintobj2;
 GRobjid		*parted = NULL, *nmparted = NULL;
 IGRint			i, partedbufsize = 0, numparted = 0, j, 
			nmpartedbufsize = 0, numnmparted = 0;
 struct GRid		this_edge, this_sf, other_sf, clip_ls;
 struct IGRbsp_surface	*this_sfgeom = NULL, *other_sfgeom = NULL;
 struct IGRbsp_curve	*this_xyz = NULL;
 struct GRmdenv_info	*env;
 OM_S_CHANSELECT	to_ls, to_edges;
 struct EMSgetlp_output	out_loops;
 IGRushort 	mapopt = EMMapBnd_WantBadCurves | 
                                 EMMapBnd_StrokeIfNeeded |
				 EMMapBnd_NoValidate |
				 EMMapBnd_NoRmvColEds |
				 EMMapBnd_ClipBdryArea, 
				
			trmopt = EMS_INTER_BDRYISAREA | EMS_INTER_CUTTING
			         | EMS_INTER_STARTPT | EMS_INTER_STOPPT |
				   EMS_INTER_MOREPRECISE;
 OM_S_OBJECT_LINKAGE 	junk;
 IGRint 		num_bdry = 0, num_int = 0, num_edges = 0;
 struct EMSsfintedpar	*edpar1 = NULL, *edpar2 = NULL;
 struct EMSpartolbasis	partol;
 IGRboolean		atleast_one_changed = FALSE;
 IGRdouble		syscht;
 struct NMentities	*this_nm = NULL;
 OMuint			count = 0;

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, syscht);
 if(cht != syscht)
  (void) BSchangepar(&rc, BSTOLCHRDHT, cht);

 *inters3 = *inters4 = NULL;
 this_inters = inters1;
 while(this_inters)
  {
   num_int++;
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     num_edges++;
     this_intobj = this_intobj->next;
    }
   this_inters = this_inters->next;
  }

 env = &construct->env_info->md_env;
 EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
 EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

 out_loops.num_objs = 0;
 out_loops.objs = NULL;

 this_inters = inters1;
 while(this_inters)
  {
   this_sf = this_inters->this_obj;
   if(this_sfgeom) om$dealloc(ptr = this_sfgeom);
   this_sfgeom = NULL;
   sts = EMgetvggeom(EMmsg, &env->matrix_type, env->matrix, 
         &this_sf, &this_sfgeom, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     EMerr_hndlr(this_intobj->this_uvintobj.datatype != EMSdata_object, 
                 *EMmsg, EMS_E_InvalidArg, wrapup);
     EMerr_hndlr(!this_intobj->other_intobj_node, *EMmsg, EMS_E_InvalidArg, 
                 wrapup);

     this_edge = *(this_intobj->this_uvintobj.data.object);
     numparted = 0;     
     sts = om$send(msg = message EMSedge.EMget_top_part_edges(EMmsg, 
           &parted, &numparted, &partedbufsize), senderid = NULL_OBJID, 
           targetid = this_edge.objid, targetos = this_edge.osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* if this edge is not owned by any loop, consider it valid.
     */
     if(!numparted)
      {
       IGRint lpcount;

       sts = EMcount_loops(EMmsg, this_edge.objid, &lpcount, NULL, NULL, NULL, 
	     NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(!lpcount)
        {
	 if(!parted)
	  {
           parted = (GRobjid *) om$malloc(size = sizeof(GRobjid));
           EMerr_hndlr(!parted, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
           partedbufsize = 1;
	  }
	 parted[numparted++] = this_edge.objid;
        }
      }

     other_intobj = this_intobj->other_intobj_node;
     other_sf = other_intobj->this_obj_node->this_obj;
     if(other_sfgeom) om$dealloc(ptr = other_sfgeom);
     other_sfgeom = NULL;
     sts = EMgetvggeom(EMmsg, &env->matrix_type, env->matrix, 
           &other_sf, &other_sfgeom, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;
     sts = EFsspbtol_by_geom(EMmsg, other_sfgeom, &partol.tol);
     if(!(1&*EMmsg&sts)) goto wrapup;
     partol.is_valid = TRUE;
     clip_ls.objid = NULL_OBJID;

     sts = om$get_channel_objects(objid = other_sf.objid, 
            osnum = other_sf.osnum, p_chanselect = &to_ls, list = &junk, 
            size = 1, count = &count);
     if(!(1&sts)) goto wrapup;
     if(count)
      {
       clip_ls.objid = junk.S_objid;
       clip_ls.osnum = junk.osnum;
      }
     this_nm = NULL;
     if(ssi && numparted)
      {
       sts = NMsetUpSSI(EMmsg, &other_sf, ssi, &this_nm);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }/* if(ssi && numparted) */

     if(this_nm) this_nm->sfid = other_sf;

     /* Get xyz geometry from each partedge and map it onto the other surface.
      * I am always getting the 'bc' geom from the edge. As a result, the
      * xyz data in the new inters list will always be EMSdata_curve3d,
      * even if it was originally stroked polyline.
     */
     for(j=0; j<numparted; j++)
      {
       numnmparted = 0;
       sts = NMsend_to_partedges(&rc, message EMSedge.EMget_top_part_edges
             (&rc, &nmparted, &numnmparted, &nmpartedbufsize), 
	     parted[j], this_edge.osnum, 0, MAXINT, NULL, NULL, NULL);
       EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(!numnmparted)
        {
	 if(!nmparted)
	  {
           nmparted = (GRobjid *) om$malloc(size = sizeof(GRobjid));
           EMerr_hndlr(!nmparted, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
           nmpartedbufsize = 1;
	  }
	 nmparted[numnmparted++] = parted[j];
        }
     
       for(i=0; i<numnmparted; i++)
        {
         /* Structure malloced, so that it can be directly used in the new
            inters list.
         */
         this_xyz = (struct IGRbsp_curve *) om$malloc(size = 
                    sizeof(struct IGRbsp_curve));
         EMerr_hndlr(!this_xyz, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
         this_xyz->poles = NULL;
         this_xyz->knots = NULL;
         this_xyz->weights = NULL;
       
         sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, 
               env, &this_sf, this_sfgeom, 0, MAXINT, FALSE, NULL, 
	       this_xyz), senderid = NULL_OBJID, targetid = nmparted[i], 
               targetos = this_sf.osnum);
         if(!(1&*EMmsg&sts)) goto wrapup;

         this_xyzintobj.datatype = EMSdata_curve3d;
         this_xyzintobj.data.curve = this_xyz;
          {
	   atleast_one_changed = TRUE;
           if(out_loops.objs) om$dealloc(ptr = out_loops.objs);
           out_loops.objs = NULL;
           out_loops.num_objs = 0;
           sts = EMget_mapped_data(1, &this_xyz, NULL, construct, other_sfgeom, 
		 NULL, construct->env_info, NULL, NULL, &out_loops, NULL, clip_ls, 
		 mapopt, NULL, EMmsg);
           if(!(1&*EMmsg&sts)) goto wrapup;
           if(!out_loops.num_objs || !out_loops.objs) continue;
           EMerr_hndlr(out_loops.num_objs != 1, *EMmsg, EMS_E_Fail, wrapup);

           sts = om$get_channel_count(objid = out_loops.objs[0], 
	         osnum = other_sf.osnum, p_chanselect = &to_edges, 
	         count = &count);
           if(!(1&sts)) goto wrapup;
           EMerr_hndlr(count != 1, *EMmsg, EMS_E_Fail, wrapup);

           sts = om$get_channel_objects(objid = out_loops.objs[0], 
                 osnum = other_sf.osnum, p_chanselect = &to_edges, 
                 list = &junk, size = 1, count = &count);
           if(!(1&sts)) goto wrapup;
           this_uvintobj2.data.object = (struct GRid *) om$malloc(size = 
                                        sizeof(struct GRid));
           this_uvintobj2.data.object->objid = junk.S_objid;
           this_uvintobj2.data.object->osnum = junk.osnum;
           this_uvintobj2.datatype = EMSdata_object;

           if(this_nm)
            {
	     sts = NMstore_edges_created(EMmsg, ssi, &this_nm->sfid, 1, 
		   &junk.S_objid);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	    }

           edpar2 = NULL;
           sts = om$send(msg = message EMSedge.EMtrimyourself(EMmsg,
                 &clip_ls.objid, trmopt, &edpar2, NULL, &num_bdry, NULL, 
                 &partol), targetid = junk.S_objid, targetos = junk.osnum, 
                 senderid = NULL_OBJID);
           if(!(1&*EMmsg&sts)) goto wrapup;
           EMerr_hndlr(num_bdry!=1, *EMmsg, EMS_E_Fail, wrapup);

           sts = om$send(msg = message Root.wild_disconnect(to_edges), 
                 senderid = NULL_OBJID, targetid = out_loops.objs[0], 
                 targetos = other_sf.osnum);
           if(!(1&sts)) goto wrapup;
           sts = om$send(msg = message Root.delete(TRUE), 
                 senderid = NULL_OBJID, targetid = out_loops.objs[0], 
                 targetos = other_sf.osnum);
           if(!(1&sts)) goto wrapup;
          }

         this_uvintobj1.data.object = (struct GRid *) om$malloc(size = 
                                     sizeof(struct GRid));
         this_uvintobj1.data.object->objid = nmparted[i];
         this_uvintobj1.data.object->osnum = this_sf.osnum;
         this_uvintobj1.datatype = EMSdata_object;
         edpar1 = (struct EMSsfintedpar *) EMsfintedpar_malloc(EMmsg, 2);
         EMerr_hndlr(!edpar1, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
         (void) NMcopy_edpar_bdry(this_intobj->more_info, edpar1);

         EMmakeintlist(EMmsg, inters3, inters4, &this_sf, &other_sf, NULL, NULL,
		    NULL, NULL, &this_xyzintobj, &this_uvintobj1, 
		     &this_uvintobj2, this_intobj->reversed, 
		     other_intobj->reversed, edpar1, edpar2, 
		     this_intobj->props, other_intobj->props, 
                     NULL, NULL, TRUE, FALSE);
         if(!(1&*EMmsg)) goto wrapup;

        } /* for(i=0; i<numnmparted; i++) */

      } /* for(j=0; j<numparted; j++) */

     this_intobj = this_intobj->next;

    } /* while(this_intobj) */

   this_inters = this_inters->next;

  } /* while(this_inters) */

wrapup:

 if(cht != syscht)
  (void) BSchangepar(&rc, BSTOLCHRDHT, syscht);

if(parted) om$dealloc(ptr = parted);
if(nmparted) om$dealloc(ptr = nmparted);
if(this_sfgeom) om$dealloc(ptr = this_sfgeom);
if(out_loops.objs) om$dealloc(ptr = out_loops.objs);
if(other_sfgeom) om$dealloc(ptr = other_sfgeom);
if( (1&*EMmsg) && atleast_one_changed) *EMmsg = EMS_I_Modified;
EMWRAPUP(*EMmsg, sts, "NMregenerate_inters");
return(sts);
}


static void NMcopy_edpar_bdry(from_edpar, to_edpar)
struct EMSsfintedpar *from_edpar, *to_edpar;
 {
  struct EMSsfintedpar *junk;

  junk = to_edpar->next; /* save the ptr*/
  *to_edpar = *from_edpar;
  to_edpar->next = junk;
  from_edpar = from_edpar->next;
  *(to_edpar->next) = *from_edpar;
 }

end implementation NMinters;
