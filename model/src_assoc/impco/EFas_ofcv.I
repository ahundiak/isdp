class implementation EMSassoc;
/*
History


20 Aug 1993 dfl creation.
                recompute function for curve offset
*/

#include "ems_m_inc.h"
#include "bsicmpcvoff.h"
#include "EMSopt.h"
#include "grownmacros.h"
#include "EMSasmacros.h"


%safe
#include "math.h"
%endsafe


#define dflT1 0
#define dflT2 0

/* offset control bits */
#define ORIENTATION             1
#define PROJECTION              2
#define UNIFORM                 4
#define COMPOSITE               8
#define FILLET                  16
#define LOOPS                   32
#define RIGHTSIDE               64
#define PLANAR			128
#define CLOSED                  256

    struct 		as_offset_control {
      unsigned int        offset_control; /* contains a bit mask controlling                                             how to offset */
      IGRint              no_of_distances; /* number of offset distances for
                                              composite curves and 
                                              non-uniform mode */ 
      char                char_data[1];
    };
        

from GRcurve import 	EMcvoffset,   GRmidpoint;

extern OM_S_OBJID              current_creator;
extern OMuword			OPP_GRbcsubbc_class_id;
                      
IGRint EFas_ofcv(EMmsg,
                   options,
                   old_objid,
                   new_objid,
                   num_parents,
                   parent_info,
                   recomp_info,
                   const_list,
                   mod_new_id)

 	IGRlong 		*EMmsg;
 	IGRuint 		options;
	GRobjid			old_objid;
	GRobjid			new_objid;
	IGRint			num_parents;
	IGRchar			*parent_info;
	IGRchar			*recomp_info;
	struct GRvg_construct	*const_list;
	GRobjid			*mod_new_id;


/*
    comment


**************************************************************************/

{
 int				XXXXX;
 IGRuint			root_type[4];
 IGRuint			root_count;
 IGRint				tcount;
 IGRint				i;
 IGRint			        n;
 /*IGRint			dpmode;*/
 IGRint				*off_code = NULL;
 IGRlong			sts;
 IGRlong			stat_OM;
 IGRlong			msg_loc;
 IGRlong			size;
 IGRdouble			t;
 IGRdouble			*comp_dis = NULL;
 IGRchar			*char_info;
 IGRchar                        classname[OM_K_MAXCLASS_LEN];
 OMuword                        my_classid;
 IGRvector			plane_normal;
 IGRpoint			plane_point;
 OM_S_OBJID                     save_creator;
 struct IGResbc		        esbc;
 struct GRid			tmp_offset_id;
 struct GRid			pro_curve_id;
 struct IGRplane		plane;
 struct IGRbsp_curve		*bsp_curve = NULL;
 struct IGRbsp_curve		*proj_bsp_curve = NULL;
 union EMSparent_info		*roots = NULL;
 /*union EMSparent_info		*start_roots = NULL;*/
 struct 			as_offset_control {
      unsigned int        offset_control; /* contains a bit mask controlling  
                                             how to offset */
      IGRint              no_of_distances; /* number of offset distances for
                                              composite curves and 
                                              non-uniform mode */ 
      char                char_data[1];
 };

 struct as_offset_control	*offsetptr = NULL;

 *EMmsg = OM_S_SUCCESS;
 sts = OM_S_SUCCESS;

 /* get recompute control information */
 offsetptr = (struct as_offset_control *) recomp_info;

 if (offsetptr->offset_control & UNIFORM)
    tcount = 1;
 else
    tcount = offsetptr->no_of_distances;

#if dflT1
 /* test what came in */
 printf("offset control flags = %d\n", offsetptr->offset_control);
 printf("number of distances = %d\n", tcount);
 char_info = offsetptr->char_data;
 for(i=0;i<tcount;i++) {
   OM_BLOCK_MOVE(char_info, &t, sizeof(IGRdouble));
   char_info = char_info + sizeof(IGRdouble) + 1;
   printf("t = %f\n", t);
 }
 printf("off-codes \n");
 for(i=0;i<tcount;i++) {
   OM_BLOCK_MOVE(char_info, &n, sizeof(IGRint));
   char_info = char_info + sizeof(IGRint) + 1;
   printf("n = %d\n", n);
 }
 
#endif

 /* extract the parent_info */
 root_type[0] = EMSlcinfo;
 if (offsetptr->offset_control & PLANAR) 
   root_type[1] = EMSlcinfo;
 else
   root_type[1] = EMSlcinfo;
 if (offsetptr->offset_control & PROJECTION) 

   root_type[2] = EMSlcinfo;

 if (offsetptr->offset_control & UNIFORM) {
   if (offsetptr->offset_control & PROJECTION) 
     root_type[3] = EMSdistance;
   else
     root_type[2] = EMSdistance;
 }
 root_count = num_parents;

 roots = (union EMSparent_info *) stackalloc(root_count * sizeof
                                      (union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);


 stat_OM = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,
                                                        NULL,
                                                        root_count,
                                                        parent_info,
                                                        root_type,
                                                        roots),
               senderid = new_objid,
               targetid = new_objid);
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);

 /*return (stat_OM);*/

 /* derive plane normal and plane point from orientation plane */

 plane.point = (IGRdouble *) &plane_point[0];
 plane.normal = (IGRdouble *) &plane_normal[0];
 stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRdetplane(EMmsg,
                          &roots->lc_info.module_info.md_env.matrix_type,
                          roots->lc_info.module_info.md_env.matrix,
                          &plane),
                   senderid = new_objid,
                   targetid = (roots+1)->lc_info.located_obj.objid,
                   targetos = (roots+1)->lc_info.located_obj.osnum);
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);

 /* allocate memory for distances and off-codes */
 comp_dis = (IGRdouble *) stackalloc(tcount * sizeof (IGRdouble));
 EMerr_hndlr(!comp_dis, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 off_code = (IGRint *) stackalloc(tcount * sizeof (IGRint));
 EMerr_hndlr(!off_code, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);



 if ((offsetptr->offset_control & UNIFORM) == FALSE) {

   char_info = offsetptr->char_data;  /* get the distance(s) from the info buffer */
   for(i=0;i<tcount;i++) {
     OM_BLOCK_MOVE(char_info, (comp_dis + i),sizeof(IGRdouble));
     char_info = char_info + sizeof(IGRdouble) + 1;
   }

   /* get the off-code from the info buffer */
   for(i=0;i<tcount;i++) {
     OM_BLOCK_MOVE(char_info, (off_code + i),sizeof(IGRint));
     char_info = char_info + sizeof(IGRint) + 1;
   }
 } else {
    /* skip to the off-code value; the distance we will get from
       the expression object */
    char_info = offsetptr->char_data;
    char_info +=   sizeof(IGRdouble) + 1;
    OM_BLOCK_MOVE(char_info, off_code, sizeof(IGRint));

   /* distance is an expression object; it is one of the roots, which 
      the user can modify or replace */
   if (offsetptr->offset_control & PROJECTION) 
    *comp_dis = (roots + 3)->value;
   else 
    *comp_dis = (roots + 2)->value;
   
 }


 const_list->class_attr = NULL;
 /* construct offset */


 /* get curve attributes */
 /*stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetattr
                          (EMmsg, 
                          (char *)&esbc),
                   senderid = new_objid,
                   targetid = roots->lc_info.located_obj.objid,
                   targetos = roots->lc_info.located_obj.osnum);
    EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);


 const_list->class_attr = (char *) &esbc; */


 stat_OM = om$send(msg = message GRcurve.EMcvoffset(
                          EMmsg,
                          &roots->lc_info.module_info.md_env.matrix_type,
                          roots->lc_info.module_info.md_env.matrix,
                          const_list,
                          comp_dis, 
                          plane_normal, 
                          offsetptr->offset_control & RIGHTSIDE,
                          offsetptr->offset_control & UNIFORM, 
                          off_code,
                          offsetptr->offset_control & FILLET, 
                          offsetptr->offset_control & LOOPS, 
                          &tmp_offset_id,
                          NULL, NULL, NULL),
                   senderid = new_objid,
                   targetid = roots->lc_info.located_obj.objid,
                   targetos = roots->lc_info.located_obj.osnum);
 EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
 
#if dflT1
    sts = om$get_classid(objid = tmp_offset_id.objid,
                         osnum = tmp_offset_id.osnum,
                         p_classid = &my_classid);
    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror,wrapup);
    sts = om$get_classname(objid = tmp_offset_id.objid,
                         osnum = tmp_offset_id.osnum,
                         classname = classname);

    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror,wrapup);

    printf("objid = %d   osnum = %d \n", tmp_offset_id.objid, tmp_offset_id.osnum);
    printf("class_id = %d   classname = %s \n", my_classid, classname);
#endif

 /* project curve onto projection plane if requested */
 if (offsetptr->offset_control & PROJECTION) {


    /* determine projection plane normal */
    plane.point = (IGRdouble *) &plane_point[0];
    plane.normal = (IGRdouble *) &plane_normal[0];
    stat_OM = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRdetplane(
                             &msg_loc,
                             &(roots + 2)->lc_info.module_info.md_env.matrix_type,
                             (roots + 2)->lc_info.module_info.md_env.matrix,
                             &plane),
                      senderid = new_objid,
                      targetid = (roots + 2)->lc_info.located_obj.objid,
                      targetos = (roots + 2)->lc_info.located_obj.osnum);

    /* get geometry of the offset curve  */
    stat_OM = om$send( msg = message GRvg.GRgetsize(
                             EMmsg,
                             &roots->lc_info.module_info.md_env.matrix_type,
                             roots->lc_info.module_info.md_env.matrix,
                             &size ),
                       senderid = new_objid,
                       targetos = tmp_offset_id.osnum,
                       targetid = tmp_offset_id.objid );
    EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);


    bsp_curve = (struct IGRbsp_curve *) stackalloc( size );
    EMerr_hndlr(!bsp_curve, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
    stat_OM = om$send( msg = message GRvg.GRgetgeom(
                             EMmsg,
                             &roots->lc_info.module_info.md_env.matrix_type,
                             roots->lc_info.module_info.md_env.matrix,
                             (IGRchar *)bsp_curve ),
                       senderid = new_objid,
                       targetos = tmp_offset_id.osnum,
                       targetid = tmp_offset_id.objid );
    EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
         
    stat_OM = om$send (msg = message GRgraphics.GRdelete(
                              EMmsg,
                              const_list->env_info),
                       senderid = new_objid,
                       targetid = tmp_offset_id.objid,
                       targetos = tmp_offset_id.osnum);
    EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    BSalloccv( bsp_curve->order,
               bsp_curve->num_poles,
               bsp_curve->rational,
               bsp_curve->num_boundaries,
               &proj_bsp_curve,
               &msg_loc );

    sts = BSprj_cv_pl(&msg_loc,
                      bsp_curve,
                      plane.point,
                      plane.normal,
                      plane.normal,
                      proj_bsp_curve );

    EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);



    /*const_list->newflag = FALSE;*/
    pro_curve_id.osnum = const_list->env_info->md_id.osnum;
    const_list->geometry = (IGRchar *) proj_bsp_curve;

    stat_OM = om$construct (classid = OPP_GRbcsubbc_class_id,
                            msg = message GRvg.GRconstruct(const_list),
                            p_objid = &pro_curve_id.objid,
                            osnum = pro_curve_id.osnum);
    EMerr_hndlr(!(1&stat_OM), *const_list->msg, EMS_E_Fail, wrapup);


 }

 if (offsetptr->offset_control & PROJECTION)
     *mod_new_id = pro_curve_id.objid;
 else 
     *mod_new_id = tmp_offset_id.objid;

 wrapup:
  if (!(1&stat_OM&*EMmsg)) *mod_new_id = NULL_OBJID;
  return (stat_OM);
}

end implementation EMSassoc;
