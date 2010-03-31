/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This function accepts a surface and the intersection data on it and
copies the surface and the intersection data such that the copied data
is now valid for the copied surface. This includes the various objids found
in the data (surface ids, incedent edge ids etc.). The surface copy can
be made optionally as compressed (active entities only).

Arguments
	inters1		input	The intersection data on the original surf.
	inters2		output  The intersection data for the copy surface.
				All the memory is allocated by the
				function. Should be freed via
				EMinters_data_free and EMinters_free
				functions. If This argument is NULL,
				then the copied intersection data will
				overwrite the original data.
	copyintobjs	input	Flag indicating whether the intersection
				edges in inters1 be copied and
				transfered to the corresponding copy surfaces
				or the original edges themselves should be
				transferred. TRUE is valid only if the copy
				is being made into the same object space.
	delorigobjs	input	Flag indication whether the input (original)
				intersection are deletable or not. e.g
				When a copy is being made into a
				different object space with same memory of
				inters1 being overwritten, the original edges
				need to be deleted (if appropriate) by the
				function before they are lost due to
				overwrite. This argument makes sense only
				if inters2 is NULL.
	surfid		input	The original surface.
	copyid		output	Copied surface. If this argument is NULL, then
				no surface is copied. If however inters2
				is non NULL the intersection data is copied
				but it is now valid for the original
				surface.
	copmpressed_copy input  Only the active entities should be copied or
				the whole shibang. Makes sense only if the
				original surface is a DPR kinda guy.
	fromenv		input	env of origianl surface.
	const_list	input	construct list
	inorig_surfs	input	List of leaf surface nodes in the original
				object. If not known pass NULL.
	incopy_surfs	input	List of leaf surface nodes in the copy (if
				already made by the caller). If not known
				pass NULL.
	numin_surfs	input	Number of leaf surfaces being passed in.
	inorig_edges	input	Edges in the original object.
	incopy_edges	input	Edges in the copy (if already made by the 
				caller).
	numin_edges	input	number of edges being passed in.
	
	The surface lists being passed in should have a one to one
	correspondence, incopy_surfs[i] must be a copy of
	inorig_surfs[i]. If either lists is not passed in the function 
	'gets components' from the corresponding owner (copy or original)
	and assumes one to one correspondence.
		In case of edges, the method EMSsurface.EMgetedges is used
	on each leaf surface in the list and a similar correspondence between
	original edge and its copy is assumed.
		If all the above lists are passed in as NULL, the function
	ensures integrity of the above assumption.
	
Assumption
	inters.more_info is a pointer to the surface geometry.
	intobj.more_info is a pointer to a pair of sfintedpars.
	
Bugs
	The functiona as of now copies only the uv data and that too only
	if it is in object form.
	
Note that sfintedpar->info, and intobj->other_intobj_node 
remain NULL for the copy if inters1 is not being overwritten.

History
	SM	12-Jul-89	Creation.
	SM	17-Mar-92	If incedent edge (sfintedpar) cannot be mapped
				into one of the copied edges, set copyedpar
				edgeid to NULL_OBJID and continue;
*/
class implementation EMSsurface;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emsdattyp.h"
#include "emssfint.h"
#include "emsinter.h"
#include "OMmacros.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMStpmacros.h"
#include "EMSutlmacros.h"

%safe
static void		EMget_copynode();
%endsafe

extern  IGRint		EMdupdata();
extern IGRboolean	EMprepdupdata();

#define MaxNumSurfs	50

#ifndef DEBUG
#define DEBUG	0
#endif

from EMSboundary import EMtpcopy;
from EMSedge import EMptproject, EMset_props, EMreverse, EMget_props;
from EMSsubbs import EMpartolbasis;
from GRowner import GRget_number_components, GRget_components;

IGRlong EMdupinters(EMmsg, inters1, inters2, copyintobjs, delorigobjs, surfid, 
		    copyid, compressed_copy, fromenv, const_list,
		    inorig_surfs, incopy_surfs, innum_surfs, 
		    inorig_edges, incopy_edges, innum_edges)
IGRlong	*EMmsg;
struct EMSinters **inters1, **inters2;
IGRboolean copyintobjs, delorigobjs;
struct GRid *surfid, *copyid;
IGRboolean compressed_copy;
struct GRmd_env *fromenv;
struct GRvg_construct *const_list;
struct GRid *inorig_surfs, *incopy_surfs;
IGRint innum_surfs;
struct GRid *inorig_edges, *incopy_edges;
IGRint innum_edges;
{
 IGRlong		sts;
 struct EMSinters	*this_inters = NULL, *copy_inters = NULL;
 IGRint			i, m, n, num_surfs = 0, num_edges = 0;
 struct EMSintobj	*this_intobj = NULL, *copy_intobj = NULL;
 struct EMSdataselect	*this_data = NULL, *copy_data = NULL;
 struct EMSsfintedpar	*this_edpar = NULL, *copy_edpar = NULL;
 struct EMSproj_info	proj_info;
 struct EMSpartolbasis	partol;
 /*extern IGRlong		EFsspbtol_by_geom();*/
 IGRboolean		project  = FALSE, world = TRUE, 
			found = FALSE, ok = FALSE;
 OMuword		edclsid1, edclsid2;
 extern void		EMbreak_connection();
 struct GRid		*orig_surfs = NULL, 
			*copy_surfs = NULL,
			orig_surf_buff[MaxNumSurfs], 
			copy_surf_buff[MaxNumSurfs], 
			*orig_edges = NULL, 
			*copy_edges = NULL;
			
 void			EMgetActiveEdges(), EMgetLeafNodes();
 /*extern struct EMSinters *EMinters_malloc();*/
 extern struct EMSintobj *EMintobj_malloc();
 /*extern struct EMSsfintedpar *EMsfintedpar_malloc();*/
 GRspacenum		thisos, copyos;
 /*extern void		EMinters_free(), EMinters_data_free();*/ 
 extern void		EMsfintedpar_free();
 struct GRmd_env	*toenv = NULL;
 struct GRsymbology	newsymb;
 /*extern IGRint		EMgetvggeom();*/

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 if(inorig_surfs) orig_surfs = inorig_surfs;
 else orig_surfs = (struct GRid *) orig_surf_buff;

 if(incopy_surfs) copy_surfs = incopy_surfs;
 else copy_surfs = (struct GRid *) copy_surf_buff;
 if(innum_surfs) num_surfs = innum_surfs;
 
 if(inorig_edges) orig_edges = inorig_edges;
 if(incopy_edges) copy_edges = incopy_edges;
 if(innum_edges) num_edges = innum_edges;

 if(inters2) *inters2 = NULL;
 if(copyid) copyid->objid = NULL_OBJID;
 if(fromenv) thisos = fromenv->md_id.osnum;
 toenv = const_list ? const_list->env_info : fromenv;
 copyos = toenv->md_id.osnum;
 
 if(copyid)
  {
   /* If original leaf surfaces are not supplied get them.
   */
   if(orig_surfs == orig_surf_buff)
    {
     EMgetLeafNodes(EMmsg, &orig_surfs, &num_surfs, MaxNumSurfs, surfid, 
		  NULL, fromenv);
     if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}
    }

   if(!compressed_copy)
    sts = om$send(msg = message GRgraphics.GRcopy (EMmsg, fromenv, toenv, 
	  &copyid->objid), targetid = surfid->objid, targetos = surfid->osnum, 
	  senderid = surfid->objid);
   else 
    sts = om$send(msg = message EMSsurface.EMcompressed_copy (EMmsg, fromenv, 
	  toenv, &copyid->objid, NULL), targetid = surfid->objid, 
	  targetos = surfid->osnum, senderid = surfid->objid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   copyid->osnum = copyos;

   if(const_list && const_list->display)
    {
     newsymb.level = const_list->level;
     newsymb.display_attr = *(const_list->display);

     sts = om$send(msg = message GRvg.GRputsymb(EMmsg, &newsymb), 
		targetid = copyid->objid, targetos = copyos, 
		senderid = copyid->objid);
    }
   
   /* If copy leaf nodes are not supplied get them.
   */
   if(copy_surfs == copy_surf_buff)
    {
     EMgetLeafNodes(EMmsg, &copy_surfs, &num_surfs, MaxNumSurfs, copyid, 
		    NULL, toenv);
     if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}
    }

   if(!orig_edges)
    {
     EMgetActiveEdges(EMmsg, &num_edges, &orig_edges, num_surfs, orig_surfs);
     if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}
    }

   if(!copy_edges)
    {
     EMgetActiveEdges(EMmsg, &num_edges, &copy_edges, num_surfs, copy_surfs);
     if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}
    }

  }

 if(!inters1) goto wrapup;

 partol.mattyp = &fromenv->md_env.matrix_type;
 partol.mat = fromenv->md_env.matrix;
 this_inters = (struct EMSinters *) *inters1;
 while(this_inters)
  {
   if(num_surfs && compressed_copy)
    {
     if(this_inters->more_info)
/**************************************************************************
      sts = EFsspbtol_by_geom (EMmsg, this_inters->more_info, &partol.tol);
**************************************************************************/
      sts = ems$sspbtol_by_geom (
                            msg = EMmsg,
                    surface = (struct IGRbsp_surface *)this_inters->more_info,
                    partolbasis = &partol.tol);  
     if(!(1&sts&*EMmsg) || !this_inters->more_info)
      {
       sts = om$send(msg = message EMSsubbs.EMpartolbasis
		(EMmsg, partol.mattyp, partol.mat, &world, TRUE, &partol.tol), 
		targetid = this_inters->this_obj.objid, targetos = thisos, 
		senderid = this_inters->this_obj.objid);
       if(!(1&*EMmsg&sts)) partol.tol = 0.0000001;
      }
     partol.is_valid = TRUE;
     sts = OM_S_SUCCESS;
     *EMmsg = EMS_S_Success;
    }
   if(inters2)
    {
     struct EMSinters	*junk;
/***************************************************************************
     junk = (struct EMSinters *) EMinters_malloc(EMmsg, 1);
***************************************************************************/
     junk = ems$inters_malloc(msg = EMmsg,
                              num_nodes = 1);
     if(!*inters2) *inters2 = junk; 
     else copy_inters->next = junk; 
     copy_inters = junk;    
    }
   else copy_inters = this_inters;

   this_intobj = (struct EMSintobj *) this_inters->cvs;
   while(this_intobj)
    {
     if(inters2)
      {
       struct EMSintobj	*junk;
       junk = (struct EMSintobj *) EMintobj_malloc(EMmsg, 1);
       if(!copy_inters->cvs) copy_inters->cvs = junk; 
       else copy_intobj->next = junk;
       copy_intobj = junk;    
      }
     else copy_intobj = this_intobj;

     for(i=0; i<2; i++)
      {
       this_data = i ? &this_intobj->this_uvintobj :
		       &this_intobj->this_xyzintobj;
       copy_data = i ? &copy_intobj->this_uvintobj :
		       &copy_intobj->this_xyzintobj;
       if(inters2)
        {
          ok = EMprepdupdata(EMmsg, this_data, copy_data);
          if(!ok || !(1&*EMmsg)) goto wrapup;
        }
       
       sts = EMdupdata(EMmsg, this_data, copy_data, fromenv, toenv, 
		       copyintobjs, delorigobjs);
       if(!(1&*EMmsg&sts)) goto wrapup;

      } /* for(i=0; i<2; i++) */
     
     this_data = &this_intobj->this_uvintobj;
     copy_data = &copy_intobj->this_uvintobj;
     this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
     if(inters2)
      {
/***************************************************************************
       copy_edpar = EMsfintedpar_malloc(EMmsg, 2);
***************************************************************************/
       copy_edpar = ems$sfintedpar_malloc(
                                   msg = EMmsg,
                               num_nodes = 2);
       EMerr_hndlr(!copy_edpar, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       copy_intobj->more_info = (IGRchar *)copy_edpar;
      }
     else copy_edpar = this_edpar;

     for(m=0; m<2; m++)
      {
       project = FALSE;
       if(copy_edpar && (copy_edpar != this_edpar))
        {
	 copy_edpar->intloc = this_edpar->intloc;
	 copy_edpar->edgeid = this_edpar->edgeid;
	 OM_BLOCK_MOVE(&this_edpar->edgepar, &copy_edpar->edgepar, 
			sizeof(struct EMSedgebound));
	 OM_BLOCK_MOVE(this_edpar->point, copy_edpar->point,
			2*sizeof(IGRdouble));
	 copy_edpar->info = NULL;
        }

       if(IF_NULL_OBJID(this_edpar->edgeid) || !num_surfs)
	{
	 this_edpar = this_edpar->next;
	 copy_edpar = copy_edpar->next;
	 continue;
	}
       found = FALSE;
       for(n=0; n<num_edges; n++)
        {
         if(IF_EQ_OBJID(orig_edges[n].objid, this_edpar->edgeid))
          {
	   found = TRUE;
           break;
          }
        }

       if(!found)
	{
	 copy_edpar->edgeid = NULL_OBJID;	
	 this_edpar = this_edpar->next;
	 copy_edpar = copy_edpar->next;
	 continue;
	}

       if(compressed_copy)
        {
         sts = om$get_classid(objid = orig_edges[n].objid, osnum = thisos, 
			      p_classid = &edclsid1);
         sts = om$get_classid(objid = copy_edges[n].objid, osnum = copyos, 
			      p_classid = &edclsid2);

         project = edclsid1 != edclsid2 ? TRUE : FALSE;
		
	 /* Natural partedges are unchanged during compress.
	 */
	 if(project)
	  {
	   IGRushort props = NULL;
           sts = om$send(msg = message EMSedge.EMget_props (EMmsg, &props), 
		targetid = this_edpar->edgeid, senderid = this_edpar->edgeid, 
		targetos = thisos);
           project = props & EMED_NATURAL ? FALSE : TRUE;
	  }
	}
       copy_edpar->edgeid = copy_edges[n].objid;
       if(project)
        {
#if DEBUG
	 printf("Regenerating split param\n");
#endif
         sts = om$send(msg = message EMSedge.EMptproject
		(EMmsg, this_edpar->point, 1, &proj_info, NULL, &partol), 
		targetid = copy_edpar->edgeid, senderid = copy_edpar->edgeid, 
		targetos = copyos);
#if DEBUG
	 printf("%d %3.10lf -->", copy_edpar->edgepar.span_inx, 
				  copy_edpar->edgepar.param);
	 printf("%d %3.10lf\n\n", proj_info.param.span_inx, 
				proj_info.param.param);
#endif
         copy_edpar->intloc = proj_info.location;
         copy_edpar->edgepar = proj_info.param;
	}
       this_edpar = this_edpar->next;
       copy_edpar = copy_edpar->next;

      }/* for(m=0; m<2; m++) */

     if(this_intobj != copy_intobj)
      {
       copy_intobj->reversed = this_intobj->reversed;
       copy_intobj->props = this_intobj->props;
       copy_intobj->this_obj_node = copy_inters;
      }
     this_intobj = this_intobj->next;

    }/* while(this_intobj) */

   if(num_surfs)
    {
     for(n=0; n<num_surfs; n++)
      if(IF_EQ_OBJID(orig_surfs[n].objid, this_inters->this_obj.objid)) break;
     copy_inters->this_obj = copy_surfs[n];
    }
   else
    copy_inters->this_obj = this_inters->this_obj;

   copy_inters->num_cvs = this_inters->num_cvs;
   if( (copy_inters != this_inters) && this_inters->more_info)
    {
     enum EMSdatatype dattyp;

     copy_inters->more_info = NULL;
/************************************************************************
     sts = EMgetvggeom(EMmsg, &fromenv->md_env.matrix_type, 
		       fromenv->md_env.matrix, &this_inters->this_obj, 
		       &copy_inters->more_info, &dattyp);
************************************************************************/
     sts = ems$getvggeom(
                msg = EMmsg,
                matrixtype = &fromenv->md_env.matrix_type,
                matrix = fromenv->md_env.matrix,
                object = &this_inters->this_obj,
                geometry = &copy_inters->more_info,
                geomtype = &dattyp);
     EMerr_hndlr((!(1&*EMmsg&sts)) || (dattyp != EMSdata_surface), *EMmsg, 
		  EMS_E_Fail, wrapup);
    
    }
   this_inters = this_inters->next;

  }/* while(this_inters) */

wrapup:
if(orig_surfs && (orig_surfs != orig_surf_buff) &&  
  (orig_surfs != inorig_surfs)) om$dealloc(ptr = orig_surfs);

if(copy_surfs && (copy_surfs != copy_surf_buff) && 
  (copy_surfs != incopy_surfs)) om$dealloc(ptr = copy_surfs);

if(orig_edges && (orig_edges != inorig_edges)) om$dealloc(ptr = orig_edges);
if(copy_edges && (copy_edges != incopy_edges)) om$dealloc(ptr = copy_edges);

if(!(1&*EMmsg&sts) && inters2 && *inters2)
 {
  IGRlong rc;
/***********************************************************************
  EMinters_data_free(&rc, *inters2, MAXINT, NULL, EMsfintedpar_free);
  EMinters_free(*inters2, MAXINT);
***********************************************************************/
  ems$inters_data_free(
                   msg = &rc,
                  inters_list = *inters2,
                  num_nodes = MAXINT,
               userdfnd_func_to_free_intobj_moreinfo = EMsfintedpar_free);
  ems$inters_free(
              inters_list = *inters2,
              num_nodes = MAXINT);
 }
return(sts);
}



void EMgetLeafNodes(EMmsg, nodes, num_nodes, bufsize, sfid, is_single_surface, 
		    env)
IGRlong		*EMmsg;
struct GRid	**nodes;
IGRint		*num_nodes;
IGRint		bufsize;
struct GRid	*sfid;
IGRboolean	*is_single_surface;
struct GRmd_env	*env;
{
 IGRlong		sts;

 *EMmsg = EMS_S_Success;
 if(is_single_surface) *is_single_surface = FALSE;
 *num_nodes = 0;

 sts = OM_S_SUCCESS;
 sts = om$send(msg = message GRowner.GRget_number_components
            (EMmsg, num_nodes), targetid = sfid->objid, senderid = sfid->objid,
		targetos = sfid->osnum);
 if(sts == OM_W_UNKNOWN_MSG)
  {
   /* element is a single surface. Also see if it has a loopset
   */
   *num_nodes = 1;
   if(!bufsize) 
     *nodes = (struct GRid *)om$malloc(size = sizeof(struct GRid));
   EMerr_hndlr(!*nodes, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   (*nodes)[0] = *sfid;
   if(is_single_surface) *is_single_surface = TRUE;
   sts = om$send(msg = message EMSsurface.EMputLsIfNotThere
		(EMmsg, &env->md_env, NULL, NULL, NULL, NULL), 
		targetid = sfid->objid, senderid = sfid->objid, 
		targetos = sfid->osnum);
   if(!(1&*EMmsg)) goto wrapup;
  }
 else if(!(1&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
 else
  {
   if(*num_nodes > bufsize)
    {
     *nodes = (struct GRid *) om$malloc(size = *num_nodes * 
						   sizeof(struct GRid));
     bufsize = *num_nodes;
    }

   *num_nodes = 0;
   sts = om$send(msg = message GRowner.GRget_components
                   (EMmsg, env, *nodes, bufsize, num_nodes, 0, MAXINT), 
	targetid = sfid->objid, senderid = sfid->objid,targetos = sfid->osnum);
   if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   else if(!(1&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
  }

wrapup:
return;
}


void EMgetActiveEdges(EMmsg, num_edges, edges, num_sfs, sfs)
IGRlong			*EMmsg;
IGRint			*num_edges;
struct GRid		**edges;
IGRint			num_sfs;
struct GRid		*sfs;
{
 IGRlong	sts, i;
 IGRint		edbufsize = 0;

 *EMmsg = EMS_S_Success;

 *num_edges = 0;
 *edges = NULL;
 for(i=0; i<num_sfs; i++)
  {
   sts = om$send(msg = message EMSsurface.EMgetedges(EMmsg, 
		EMS_OPT_ALL, edges, &edbufsize, num_edges, NULL, NULL, 
		NULL, NULL), targetid = sfs[i].objid, senderid = sfs[i].objid, 
		targetos = sfs[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:
return;
}


IGRboolean EMprepdupdata(EMmsg, this_data, copy_data)
IGRlong *EMmsg;
struct EMSdataselect *this_data, *copy_data;
{
  struct IGRbsp_curve *crv = NULL;
  *EMmsg = EMS_S_Success;

  copy_data->datatype = EMSdata_null;

  switch(this_data->datatype)
  {
    case EMSdata_object:
 
     copy_data->data.object = (struct GRid *)om$malloc(size = sizeof(struct GRid));
     EMerr_hndlr(!copy_data->data.object, *EMmsg, EMS_E_NoDynamicMemory,
		wrapup);
    break;
	
    case EMSdata_curve3d:
    case EMSdata_curve2d:

      copy_data->data.curve = (struct IGRbsp_curve *)om$malloc(size = 
				      sizeof(struct IGRbsp_curve));
      EMerr_hndlr(!copy_data->data.curve, *EMmsg, EMS_E_NoDynamicMemory,
		wrapup);
      
      crv = copy_data->data.curve;
      crv->poles = NULL;
      crv->knots = NULL;
      crv->weights = NULL;
    break;
	
    case EMSdata_poly3d:
    case EMSdata_poly2d:

      copy_data->data.poly = (struct IGRpolyline *)om$malloc(size =sizeof(struct IGRpolyline));
      EMerr_hndlr(!copy_data->data.poly, *EMmsg, EMS_E_NoDynamicMemory,
		wrapup);
      copy_data->data.poly->points = NULL;
      copy_data->data.poly->num_points = 0;
    break;
	
    case EMSdata_null:
    break;
	
    default:
    *EMmsg = EMS_E_InvalidArg;
    break;
  }

wrapup:
  if(!(1&*EMmsg)) 
   return FALSE;
  else
    return TRUE;
} 

/* The following function duplicates the dataselect part of the intersection
   list. It assumes that all memory except the one for the actual data is
   allocated (i.e memory for the curve structure, polyline structure or the
   GRid structure as the case mey be.)

History
	SM	18-Jul-89	Creation.
        NP      18-Jul-92	While copying dataselect of type "curve3d", 
                                zero memory was being allocated to the "weights"                                parameter due to wrong arguments.
        NP	22-Jul-92	Modified error check for above.
*/

extern OMuword OPP_EMSboundary_class_id;

IGRint EMdupdata(EMmsg, data1, data2, fromenv, toenv, copyobjs, 
		delorigobjs)
IGRlong			*EMmsg;
struct EMSdataselect	*data1, *data2;
struct GRmd_env		*fromenv, *toenv;
IGRboolean		copyobjs, delorigobjs;
{
 IGRlong		sts;
 OMuword		clsid;
 struct GRid		*obj, *cpobj, junk;
 struct IGRbsp_curve	*crv, *cpcrv;
 struct IGRpolyline	*poly, *cppoly;
 GRspacenum		copyos;
 IGRint			dim;
 IGRdouble 		*junk1, *junk2, *junk3;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 if( (data1->datatype != EMSdata_object) && (data1 == data2))
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }

 switch(data1->datatype)
  {
   case EMSdata_object:

     copyos = toenv->md_id.osnum;

     obj = data1->data.object;
     cpobj = data2->data.object;
     junk = *obj;
     sts = om$get_classid(objid = obj->objid, osnum = obj->osnum, 
			p_classid = &clsid);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     if( (sts = om$is_ancestry_valid(subclassid = clsid, 
		superclassid = OPP_EMSboundary_class_id)) == OM_S_SUCCESS)
      {
       if(copyobjs || (copyos != obj->osnum))
        {
         sts = om$send(msg = message EMSboundary.EMtpcopy(EMmsg, fromenv, 
	    obj->osnum, copyos, NULL, &cpobj->objid), targetid = obj->objid, 
	    senderid = obj->objid, targetos = obj->osnum);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
       else {delorigobjs = FALSE; *cpobj = *obj;}

       if(delorigobjs)
        {
         sts = om$send(msg = message Root.delete(TRUE), targetid = junk.objid, 
	    senderid = junk.objid, targetos = junk.osnum);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
      }
     else
      {
       if(copyobjs || (copyos != obj->osnum))
        {
         sts = om$send(msg = message GRgraphics.GRcopy (EMmsg, fromenv, toenv, 
	  &cpobj->objid), targetid = obj->objid, targetos = obj->osnum, 
	  senderid = obj->objid);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
       else {delorigobjs = FALSE; *cpobj = *obj;}

       if(delorigobjs)
        {
         sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, fromenv), 
	     targetid = junk.objid, senderid = junk.objid, 
	     targetos = junk.osnum);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
      }
     data2->datatype = EMSdata_object;
     cpobj->osnum = copyos;
   break;

   case EMSdata_curve3d:
   case EMSdata_curve2d:

     dim = (data1->datatype == EMSdata_curve3d) ? 3 : 2;

     crv = data1->data.curve;
     cpcrv = data2->data.curve;
   
     if(!cpcrv->poles)
      cpcrv->poles = (IGRdouble *)om$malloc(size =crv->num_poles * dim * sizeof(IGRdouble));
     if(!cpcrv->knots)
      cpcrv->knots = (IGRdouble *)om$malloc(size = crv->num_knots * sizeof(IGRdouble));

     EMerr_hndlr(!cpcrv->poles || !cpcrv->knots, 
                             *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     if(crv->weights && !cpcrv->weights)
     {
      cpcrv->weights = (IGRdouble *)om$malloc(size = crv->num_poles * sizeof(IGRdouble));
      EMerr_hndlr(!cpcrv->weights, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     }

     junk1 = cpcrv->poles;
     junk2 = cpcrv->knots;
     junk3 = cpcrv->weights;
     *cpcrv = *crv;
     cpcrv->poles = junk1;
     cpcrv->knots = junk2;
     cpcrv->weights = junk3;
     OM_BLOCK_MOVE(crv->poles, cpcrv->poles, crv->num_poles * dim *
					   sizeof(IGRdouble));
     OM_BLOCK_MOVE(crv->knots, cpcrv->knots, 
		   crv->num_knots * sizeof(IGRdouble));
     if(cpcrv->weights)
       OM_BLOCK_MOVE(crv->weights, cpcrv->weights, crv->num_poles *
					sizeof(IGRdouble));
     data2->datatype = dim == 3 ? EMSdata_curve3d : EMSdata_curve2d;
   break;

   case EMSdata_poly2d:
   case EMSdata_poly3d:

     dim = (data1->datatype == EMSdata_poly3d) ? 3 : 2;
     poly = data1->data.poly;
     cppoly = data2->data.poly;
     if(!cppoly->points)    
       cppoly->points = (IGRdouble *)om$malloc(size = poly->num_points * dim * 
					(sizeof(IGRdouble)));
     EMerr_hndlr(!cppoly->points, *EMmsg, EMS_E_NoDynamicMemory, 
	       wrapup);
     cppoly->num_points = poly->num_points;
      OM_BLOCK_MOVE(poly->points, cppoly->points, poly->num_points * dim *
				sizeof(IGRdouble));
     data2->datatype = dim == 3 ? EMSdata_poly3d : EMSdata_poly2d;
   break;

   case EMSdata_null:
     data2->datatype = EMSdata_null;
     break;

   default:
     *EMmsg = EMS_E_InvalidArg;
   break;   
  }

wrapup:
return(sts);

}



/* Given two original inters lists and their copies, this function establishes
   the interrelationship between the copies via the 'other_intobj_node'
   'fwd' and the 'bwd' pointers.
*/
void EMinters_interrelate(EMmsg, inters1, copy1, inters2, copy2, fwd, bwd, 
			  other_intobj_node)
IGRlong			*EMmsg;
struct EMSinters	*inters1, *copy1, *inters2, *copy2;
IGRboolean		fwd, bwd, other_intobj_node;
{
 struct EMSinters	*this_inters1, *this_copyinters1; 
 struct EMSintobj	*this_intobj1, *this_intobj2, *this_copyintobj1, 
			*this_copyintobj2;
 IGRint			i;

 *EMmsg = EMS_S_Success;

 for(i=0; (i<2) && (1&*EMmsg); i++)
  {
   this_copyinters1 = i ? copy2 : copy1;
   this_inters1 = i ? inters2 : inters1;
   while(this_copyinters1 && (1&*EMmsg))
    {
     this_copyintobj1 = this_copyinters1->cvs;
     this_intobj1 = this_inters1->cvs;
     while(this_copyintobj1 && (1&*EMmsg))
      {
       if(fwd && (this_intobj2 = this_intobj1->fwd))
        {
         EMget_copynode(i ? inters2 :inters1, i ? copy2 : copy1, this_intobj2, 
			&this_copyintobj2);
	 if(!this_copyintobj2) {*EMmsg = EMS_E_Fail; break;}
         this_copyintobj1->fwd = this_copyintobj2;
         if(this_intobj1->props & EMSintobj_fwd_connectuv)
          this_copyintobj1->props |= EMSintobj_fwd_connectuv;
        }

       if(bwd && (this_intobj2 = this_intobj1->bwd))
        {
         EMget_copynode(i ? inters2 : inters1, i ? copy2 : copy1, this_intobj2,
			&this_copyintobj2);
	 if(!this_copyintobj2) {*EMmsg = EMS_E_Fail; break;}
         this_copyintobj1->bwd = this_copyintobj2;
         if(this_intobj1->props & EMSintobj_bwd_connectuv)
         this_copyintobj1->props |= EMSintobj_bwd_connectuv;
        }

      if(other_intobj_node && (this_intobj2 = this_intobj1->other_intobj_node))
        {
         EMget_copynode(i ? inters2 : inters1, i ? copy2 : copy1, this_intobj2,
			&this_copyintobj2);
	 if(!this_copyintobj2) {*EMmsg = EMS_E_Fail; break;}
         this_copyintobj1->other_intobj_node = this_copyintobj2;
        }
       this_copyintobj1 = this_copyintobj1->next;
       this_intobj1 = this_intobj1->next;     
      }
     this_copyinters1 = this_copyinters1->next;
     this_inters1 = this_inters1->next;

    } /* while(this_copyinters1) */

   } /* for(i=0; i<2; i++) */

}



static void EMget_copynode(inters1, inters2, intobj1, intobj2)
struct EMSinters	*inters1, *inters2;
struct EMSintobj	*intobj1, **intobj2;
{
 IGRboolean	found = FALSE;
 struct EMSinters	*this_inters1, *this_inters2;
 struct EMSintobj	*this_intobj1;

 *intobj2 = NULL;
 this_inters1 = inters1;
 this_inters2 = inters2;
 while(this_inters1 && !found)
  {
   this_intobj1 = this_inters1->cvs;
   *intobj2 = this_inters2->cvs;
   while(this_intobj1 && !found)
    {
     if(intobj1 == this_intobj1)
      { found = TRUE; break;}
     this_intobj1 = this_intobj1->next;
     *intobj2 = (*intobj2)->next;
    }
   this_inters1 = this_inters1->next;
   this_inters2 = this_inters2->next;
  }

if(!found)
 {
#if DEBUG
  printf("EMS_E_Fail -- EMget_copynode\n");
#endif
  *intobj2 = NULL;
 }

}
end implementation EMSsurface;
