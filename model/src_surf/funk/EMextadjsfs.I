class  implementation EMSsubbs;
/*
  HISTORY

        Nirmal  02/93           Creation
	    Sudha	07/06/93    	Modified for BSprototypes ansification

        Hari    07/07/95        For surfaces,which are closed at one end
                                and having order more than two at the other
                                end,the extension factor has to be less,to
                                avoid self intersecting problems ,seam
                                intersection & invalid solid formation.

        Hari    07/07/95        Added check for self-intersection. If the 
                                extension results in self-intersection then
                                the surface is extended with less extension
                                value.  

        Hari    09/xx/95        Deextension is done only for self-intersec
                                ting surfaces. The revised extension value
                                is modified (made 70% of previous value).
                                The maximum iteration is restricted to 2.

        Hari    09/xx/95        Old code retained for Replace surface. New
                                function EMextend_adj_surfs_draft() for
                                draft functionality.

        Hari    09/xx/95        New functions added to avoid unwanted exten.
                                based on modified range box check. Details,

                                D_Check_Zero_Ext(): Main function for the 
                                modified range box check.

                                D_Is_Ext_Not_Req(): supporting function which
                                says extension requirement based on the surf.  
                                ranges.

                                D_Get_Solid_range(): supporting function, to
                                get the solid range; cummulative ranges of
                                the given surface and its adjacent draft surf.

        Hari    10/xx/95        New function D_Get_Ext_Dist(); to get the 
                                extention distance for the surfaces.    

                                Linear direction : Extention factor based on
                                the solid range. 
                                non-linear direc : Factor based on the surface
                                range and the radius of curvature & arc length
                                of the iso curve
                                Freeform surfaces: factor fixed based on 
                                experience.                 

        Hari    11/xx/95        Avoiding arbitrary extensions. Fix for
                                TR#119527929.
                
                    
*/

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "bsgeom_cvsf.h"
#include  <values.h>
#include  <math.h>

#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
#include "bssfxttpt.h"
#include "bssfarrevt.h"
#include "bssfarrevn.h"
#include "bsplptnorrg.h"
#include "bsnorvec.h"
#include "bsdotp.h"
 

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMAgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMAproject_class_id;
extern OMuword OPP_EMSproject_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMArevol_class_id;
extern OMuword OPP_EMSrevol_class_id;
extern OMuword OPP_EMAsphere_class_id;
extern OMuword OPP_EMApsphere_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMSpsphere_class_id;

from EMSedge import EMget_sf_edges, EMchkconvex;
from EMSedge import  EMgetsurface_info, EMxyz_endpt, EMendpts;

/*
 * Function declarations for some of the new added function calls
 */

extern IGRint  EMextend_adj_surfs_draft(IGRlong *,struct GRmd_env *,
                struct GRvg_construct *,IGRdouble,IGRdouble ,
                struct EMSadj_surf_info **,IGRint,OMuword,
                struct EMSadj_surf_info **,IGRint, IGRboolean);

extern IGRboolean D_Is_Ext_Not_Req(IGRdouble *, IGRdouble *);

extern IGRint D_Get_Ext_Dist(IGRlong *, struct GRmd_env *,
                           struct EMSadj_surf_info **,IGRint, IGRint,
                           struct IGRbsp_surface **, IGRdouble *);
extern IGRint D_Get_Min_Ext_Dist(IGRlong *, struct GRmd_env *,
                           struct EMSadj_surf_info **,IGRint, IGRint,
                           struct IGRbsp_surface **, IGRdouble *);

extern IGRboolean D_Check_Zero_Ext(IGRlong *,struct GRmd_env *,
                                   struct EMSadj_surf_info **,
                                   IGRint,IGRint);

extern IGRint D_Get_Solid_range(IGRlong *, struct GRmd_env *,
                                struct EMSadj_surf_info **,IGRint, IGRint,
                                IGRdouble *);


/*
 * This function is called from EMcopy_adj_surfs() for draft functionality
 * The surfaces which need to be extended are extended and the new surface
 * will be copied into cp_sf_info list.
 */
IGRint  EMextend_adj_surfs_draft(IGRlong                *EMmsg,
                                struct GRmd_env         *md_env,
                                struct GRvg_construct   *const_list,
                                IGRdouble               draft_angle,
                                IGRdouble               min_angle,
                                struct EMSadj_surf_info **adj_sf_info,
                                IGRint                  index,
                                OMuword                 class_id,
                                struct EMSadj_surf_info **cp_sf_info,
                                IGRint                  list_len,
                                IGRboolean              no_ext)
{
    /*
     * Variable declarations & initialization
     */
    IGRlong rc = BSSUCC, stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint  jjj,  ii, jj;
    struct EMSadj_surf_info *adj_info=NULL, *cp_info=NULL;
    IGRdouble surf_range[6],  ex_dist, dotp, u_par, v_par;
    IGRboolean  world = TRUE, pos_orient_bit = FALSE;
    IGRdouble nrml[3],  nrml1[3];
    IGRdouble pnts[3];
    struct IGRbsp_surface *surf_geom=NULL;
    IGRdouble dist_out;
    IGRint option;
    IGRushort sf_type;
    IGRdouble ext_dist[4];
    struct BSgeom_bsp_surf gmsf, xgmsf;

    /*
     * Function declaration
     */
    IGRboolean EFare_surfs_tan();
    IGRdouble BSdistptpt();
    IGRdouble BSdistptpts();
    extern void EFget_surf_geom();
    extern  void  BSxgmsfdst();
    extern void getsftype();
    extern void BSchkfxsf ();
    extern void BSplptnorrg();

    /*
     * Check for very large draft angle
     */
    if( (tan(min_angle) - tan(fabs(draft_angle))) < 0.0)
      EMerr_hndlr( TRUE, *EMmsg,EMS_E_SurfaceError, wrapup);

    /*
     * Initialize
     */
    gmsf.bspsf=NULL;
    xgmsf.bspsf=NULL;
    adj_info = adj_sf_info[index];
    cp_info  = cp_sf_info[index];

    /*
     * Get the surface type
     */
    getsftype(adj_info->myself.objid,adj_info->myself.osnum, &sf_type);

    /*
     * Get the surface geometry
     */
    EFget_surf_geom(EMmsg, md_env, adj_info->myself.objid,
                    adj_info->myself.osnum,  &surf_geom);
    adj_info->planar = surf_geom->planar;
    adj_info->pos_orient = surf_geom->pos_orient;

    /*
     * Get the surface range
     */
    stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &world,
                                    surf_range),
                        senderid = NULL_OBJID,
                        targetid = adj_info->myself.objid,
                        targetos = adj_info->myself.osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

    /*
     * Set the appropriate bits
     */
    u_par = v_par = 0.5;
    BSsfarrevn(&rc, surf_geom, 1, &u_par, 1, &v_par,
              (IGRdouble *)pnts, (IGRdouble *)nrml);
    EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    BSnorvec(&rc, nrml);
    pos_orient_bit = surf_geom->pos_orient;

    /*
     * Initialize the extension distance
     */
    for(ii=0;ii<4;++ii) ext_dist[ii] = 0.0;

    /*
     * If extension required for surfaces, check whether extension required
     * for surface under consideration using modified surface range check
     */
    if(!no_ext)
      no_ext = D_Check_Zero_Ext(EMmsg,md_env, adj_sf_info,index,list_len);

    //get the extension distance
    if(!no_ext && !surf_geom->planar)
      stat_OM = D_Get_Ext_Dist(EMmsg,md_env,adj_sf_info,list_len,index,
                               &surf_geom, ext_dist);
    else if(no_ext && !surf_geom->planar)
      stat_OM = D_Get_Min_Ext_Dist(EMmsg,md_env,adj_sf_info,list_len,index,
                                   &surf_geom, ext_dist);

    if( surf_geom->planar &&
        class_id != OPP_EMArevol_class_id &&
        class_id != OPP_EMSrevol_class_id)
    {
        /*
         * Process for planar surface
         */

         IGRdouble slrange[6];
         IGRint tt;
         IGRboolean in_range=TRUE;
         IGRshort   sfmat_type;
         IGRdouble  *sfmat = NULL;
         struct IGRplane pln_of_sf;
         pln_of_sf.point = NULL;pln_of_sf.normal = NULL;

         /*
          * Alloate memory 
          */
         pln_of_sf.point = (IGRdouble *) om$malloc(size = 3 * sizeof(double));
         pln_of_sf.normal = (IGRdouble *)om$malloc(size = 3 * sizeof(double));

         sfmat_type = const_list->env_info->md_env.matrix_type;
         sfmat = const_list->env_info->md_env.matrix;

         /*
          * Get the plane information
          */
         om$send( msg = message GRvg.GRdetplane(EMmsg,
                                  &sfmat_type,sfmat,&pln_of_sf ),
                                  senderid = NULL_OBJID,
                                  targetid = adj_info->myself.objid,
                                  targetos = adj_info->myself.osnum );

         /*
          * Initialize the solid range as the surface range
          */
         for(tt=0;tt<6;++tt) slrange[tt] = surf_range[tt];

         /*
          * If extension required get the modified solid range, which
          * considers the adjacent draft surface range also into account
          */ 
         if(!no_ext)
         {
           stat_OM = D_Get_Solid_range(&msg_loc,md_env,adj_sf_info,
                                       list_len,index,slrange);
           EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
         }

         //let the solid range be 10% more
         {
           IGRint ind3;
           for(ind3=0;ind3<3;ind3++) if(slrange[ind3]<0) slrange[ind3] *=1.1;
                                     else slrange[ind3] *=0.9;
           for(ind3=3;ind3<6;ind3++) if(slrange[ind3]<0) slrange[ind3] *=0.9;
                                     else slrange[ind3] *=1.1;
          }

         /*
          * Define a new plane for the solid range
          */
         BSplptnorrg( &slrange[0], &slrange[3], pln_of_sf.point,
                      pln_of_sf.normal, (IGRdouble)1.0, &in_range,
                        surf_geom,&rc );
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);          

         /*
          * Deallocate the allocated memory
          */
         if(pln_of_sf.point) {om$dealloc(ptr=pln_of_sf.point);
                              pln_of_sf.point=NULL;}
         if(pln_of_sf.normal) {om$dealloc(ptr=pln_of_sf.normal);
                               pln_of_sf.normal=NULL;}
         
         /*
          * Set the appopriate bits properly
          */
         u_par = v_par = 0.5;
         BSsfarrevn(&rc, surf_geom, 1, &u_par, 1, &v_par,
                      (IGRdouble *)pnts, (IGRdouble *)nrml1);
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         BSnorvec(&rc, nrml1);

         dotp = BSdotp(&rc, nrml, nrml1);

         cp_info->pos_orient = adj_info->pos_orient;
         if(dotp < 0.0)
             cp_info->pos_orient =  !(adj_info->pos_orient);

         if( (dotp < 0.0 && ( pos_orient_bit == surf_geom->pos_orient)) ||
             (dotp > 0.0 && ( pos_orient_bit != surf_geom->pos_orient)))
              surf_geom->pos_orient = !surf_geom->pos_orient;

         const_list->geometry = (IGRchar *)surf_geom;

         /*
          * Construct the new plane
          */
         stat_OM = om$construct(osnum = cp_info->myself.osnum,
         p_objid = &cp_info->myself.objid,
                     classid = OPP_EMSplane_class_id,
              msg = message GRgraphics.GRconstruct(const_list));
         if(!(1&msg_loc&stat_OM)) goto wrapup;

   }
   else
   {
      /*
       * Process for non-planar surfaces
       */

      if(class_id == OPP_EMAproject_class_id ||
         class_id == OPP_EMSproject_class_id)
             class_id = OPP_EMSgenbs_class_id;

      xgmsf.bspsf = surf_geom;
      gmsf.bspsf = surf_geom ;
      gmsf.sfgen_cv = NULL ;
      xgmsf.sfgen_cv = NULL ;
      gmsf.geom_prop=FALSE;
      gmsf.type=sf_type;
      gmsf.vrange[0]=0.;
      gmsf.vrange[1]=1.;
      gmsf.urange[0]=0.;
      gmsf.urange[1]=1.;
      gmsf.bounded= TRUE;

      xgmsf.geom_prop=FALSE;
      xgmsf.type=99;
      xgmsf.vrange[0]=0.;
      xgmsf.vrange[1]=1.;
      xgmsf.urange[0]=0.;
      xgmsf.urange[1]=1.;
      xgmsf.bounded= TRUE;

      /*
       * If the surface class is sphere then do nothing ???
       */
      if(class_id == OPP_EMSsphere_class_id ||
         class_id == OPP_EMAsphere_class_id )
      {
         /* do nothing */
      }
      else
      {
        /*
         * for each directions (u,v) of the surface under consideration
         */
        for (jj=0; jj<2; jj++)
        {
          /*
           * For each iso directions (left,right)
           */
          for(jjj=0;jjj<2; jjj++)
          {
            /*
             * Get the extension distance for that particular direction
             * and extend the surface
             */
            ex_dist = (jjj==0 ? ext_dist[jj] : ext_dist[jj+2]);
            option=1;
            if(jj==0)
            {
              gmsf.type=sf_type;
              if(ex_dist > 0.0)
              BSxgmsfdst (&gmsf, ex_dist, option, FALSE, FALSE,
                          (jjj==0 ? TRUE : FALSE), (jjj==0? FALSE :TRUE),
                          &xgmsf, &dist_out, &rc);
            }
            else if(jj==1)
            {
              gmsf.type=sf_type;
              if(ex_dist > 0.0)
              BSxgmsfdst (&gmsf, ex_dist, option,
                          (jjj==0? TRUE : FALSE), (jjj==0? FALSE :TRUE),
                          FALSE, FALSE, &xgmsf, &dist_out, &rc);
            }
            if( rc != BSSUCC)
            {
              gmsf.bspsf = gmsf.bspsf;
              xgmsf.bspsf = gmsf.bspsf;
            }
            else
            {
              gmsf.bspsf = xgmsf.bspsf;
            }
          }
        }
      }
      surf_geom = xgmsf.bspsf;
      if( gmsf.bspsf && (gmsf.bspsf!=xgmsf.bspsf))
             {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}

      /* check for self-intersection of the extended surface
       * if self-intersecting then error out
       */
       {
        IGRshort out_code = 0;
        BSrc rc;
        struct IGRbsp_surface *outsf = NULL;

        EFget_surf_geom(EMmsg, md_env, adj_info->myself.objid,
                        adj_info->myself.osnum,  &outsf);

        /*
         * If the out_code value is 16 then self-intersection
         */
        BSchkfxsf (surf_geom, 0, outsf, &out_code, &rc);
        EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        if(outsf) {om$dealloc(ptr = outsf); outsf=NULL;}

        /*
         * If self-intersecting then fail
         */
        if(out_code == 16)
         EMerr_hndlr( TRUE,  *EMmsg,EMS_E_SurfaceError, wrapup);
      }

     /*
      * Set the appropriate bits
      */
     u_par = v_par = 0.5;
     BSsfarrevn(&rc, surf_geom, 1, &u_par, 1, &v_par,
                                       (IGRdouble *)pnts, (IGRdouble *)nrml1);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml);

     dotp = BSdotp(&rc, nrml, nrml1);
     cp_info->pos_orient =  adj_info->pos_orient;
     cp_info->planar =  surf_geom->planar;
     if(dotp < 0.0)
             cp_info->pos_orient =  !(adj_info->pos_orient);

     if( (dotp < 0.0 && ( pos_orient_bit == surf_geom->pos_orient))
                                        ||
         (dotp > 0.0 && ( pos_orient_bit != surf_geom->pos_orient)))
      surf_geom->pos_orient = !surf_geom->pos_orient;

     const_list->geometry = (IGRchar *)surf_geom;
     cp_info->myself.osnum = adj_info->myself.osnum;

     /*
      * Construct new surface
      */
     stat_OM = om$construct(osnum = cp_info->myself.osnum,
           p_objid = &cp_info->myself.objid,
                  classid = class_id,
                    msg = message GRgraphics.GRconstruct(const_list));
     if(!(1&msg_loc&stat_OM)) goto wrapup;
  }

  wrapup:
    if( gmsf.bspsf) {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}
       EMWRAPUP( *EMmsg, stat_OM, "EMext_adj_sfs");
    return (stat_OM);
}


/*
 * This function checks for zero extension of the individual suraface,
 * following the modified range box check
 *
 * Algo :
 *
 *   o Let the range box of the surface under consideration S1 be R1
 *
 *   o If the surface S1 doesn't have drafted surface adjacents
 *         No extension required
 *     else
 *         for each of the drafted surface adjacents
 *             Get the drafted surface range box, let it be R2
 *             Apply the modified surface range check.
 *             Return the result reported by the range box check function
 *
 *  Return values:
 * 
 *       1 : Zero extension (no extension required)
 *       0 : Extension required
 */
IGRboolean D_Check_Zero_Ext(IGRlong  *EMmsg, struct GRmd_env *md_env,
                            struct EMSadj_surf_info **ssurf, IGRint index,
                            IGRint length)
{
  IGRboolean flag = TRUE;
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  IGRdouble range1[6],range2[6];
  IGRboolean world = TRUE;
  IGRint ii,kk,hh;
  GRobjid id_surf2;
  struct EMSadj_surf_info *surf=NULL;
  IGRint inn;

  /*  
   * Get the range box of the surface under consideration
   */
  surf = ssurf[index];
  stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                                  &world,range1),
                        senderid = NULL_OBJID,
                        targetid = surf->myself.objid,
                        targetos = surf->myself.osnum);
  EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

  /*
   * Consider all its drafted surface adjacents
   */
  for(hh=0;hh<length;++hh)
  {
    if(ssurf[index]->myself.objid == ssurf[hh]->myself.objid)
    {
      surf = ssurf[hh];
    }
    else continue;

    for(ii=0;ii<surf->num_adjacent;++ii)
    {
      inn = -1;
      id_surf2 = surf->adj_surfs[ii];

      for(kk=0;kk<length;++kk)
        if(id_surf2 == ssurf[kk]->myself.objid) { inn = kk; break;}

      if(inn == -1 || !(ssurf[inn]->affect&EM_ADDRFT_DRAFT_SRF)) continue;

      id_surf2 = ssurf[inn]->copy;

      /*
       * Get the range box of the drafted surface
       */
      stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                                  &world,range2),
                        senderid = NULL_OBJID,
                        targetid = id_surf2,
                        targetos = surf->myself.osnum);
      EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

      /*
       * Call the modified range box check function
       */
      if(D_Is_Ext_Not_Req(range1,range2) == FALSE) 
      {
         flag = FALSE;
         goto wrapup;
      }
      else flag = TRUE;
    } 
  }
  
 wrapup:
   return(flag);
  
}

/*
 * This function says whether extension required or not, for any surface
 * given the range box of the surface under consideration and a reference
 * surface range box, with which the extension requyirements have to be 
 * checked
 *
 * Algo:
 *
 *  If the surface ranges are such that they are large enough in atleast 
 *  one direction with respect to the other, and non of the ranges are
 *  overlapping then extension is not required, else extension required.
 *
 * Return Values
 * 
 *    0 : Extension required
 *    1 : Extension not required
 */
IGRboolean D_Is_Ext_Not_Req(IGRdouble *surf1_range,
                        IGRdouble *surf2_range)
{
  IGRboolean flag = FALSE,flg3 = TRUE;
  IGRint ii,tem_count1 = 0,tem_count2 = 0;
  IGRboolean flg1[3],flg2[3];

  /*
   * Check begins
   */
  for(ii=0;ii<3;++ii) {flg1[ii] = FALSE; flg2[ii] = FALSE;}
  for(ii=0;ii<3;++ii)
  {
    if(surf1_range[ii] < surf2_range[ii] && 
       surf1_range[ii+3] > surf2_range[ii+3]) {flg1[ii] = TRUE;tem_count1++;}
    if(surf2_range[ii] < surf1_range[ii] &&
       surf2_range[ii+3] > surf1_range[ii+3]) {flg2[ii] = TRUE;tem_count2++;}
  }
  
  for(ii=0;ii<3;++ii) if( !(flg1[ii] || flg2[ii])) flg3 = FALSE;

  if(flg3 && tem_count1 >=1 && tem_count2 >=1) flag = TRUE;

  return(flag); 
}

/*
 * This is to get the solid range of a surface. This return the union
 * range box of all the drafted surface adjacents with the range box of
 * the surface under consideration
 */ 

IGRint D_Get_Solid_range(IGRlong  *EMmsg,
                         struct GRmd_env *md_env,
                         struct EMSadj_surf_info **adj_sf_info,
                         IGRint list_len,
                         IGRint index,
                         IGRdouble *slrange)
{
   int hh,get_ind,tt;
   IGRdouble rrange[6];
   IGRlong stat_OM  = OM_S_SUCCESS,msg_loc =  EMS_S_Success;
   IGRboolean world = TRUE;
   struct EMSadj_surf_info *ssurf=NULL;
   int hhh;

   
   for(hhh=0;hhh<list_len;++hhh)
   {
     if(adj_sf_info[hhh]->myself.objid == adj_sf_info[index]->myself.objid)
       ssurf = adj_sf_info[hhh];
     else continue;
     
   for(tt=0;tt<ssurf->num_adjacent;++tt)
   {
     for(get_ind=0;get_ind<list_len;++get_ind)
      if(ssurf->adj_surfs[tt] == 
         adj_sf_info[get_ind]->myself.objid) break;
 
     if(get_ind < list_len &&
        adj_sf_info[get_ind]->affect&EM_ADDRFT_DRAFT_SRF)
     {
       stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,  
                                       &md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       &world, rrange),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info[get_ind]->copy,
                        targetos = adj_sf_info[get_ind]->myself.osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
        for(hh=0;hh<3;++hh)
        {
           if(rrange[hh]<slrange[hh]) slrange[hh]=rrange[hh];
           if(rrange[hh+3]>slrange[hh+3]) slrange[hh+3]=rrange[hh+3];
         }
       }
    } 
  }

 wrapup:
   EMWRAPUP( *EMmsg, stat_OM, "EMext_adj_sfs");
   return(stat_OM);       

}

/*
 * Get the minimum extension distance
 */
IGRint D_Get_Min_Ext_Dist(IGRlong *EMmsg,
                          struct GRmd_env *md_env,
                          struct EMSadj_surf_info **adj_sf_info,
                          IGRint list_len,
                          IGRint index,
                          struct IGRbsp_surface **surf_ge,
                          IGRdouble *ext_dist)
{
  struct IGRbsp_surface *surf_geom=NULL;
  IGRint jj;
  IGRdouble x_dist,xx_dist;
  IGRlong msg_loc = EMS_S_Success;
  IGRdouble srange[6],ref_ext;
  IGRboolean world = TRUE;
  IGRlong stat_OM  = OM_S_SUCCESS;
  BSrc rc;
  extern void EFget_surf_extent();
  IGRdouble BSdistptpt();

  surf_geom = *surf_ge;
  stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        &world,
                                        srange),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info[index]->myself.objid,
                        targetos = adj_sf_info[index]->myself.osnum);
  EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
  ref_ext= 0.05*fabs(BSdistptpt(&rc, &srange[0], &srange[3]));

  for (jj=0; jj<2; jj++)
  {
     if((jj == 0 && surf_geom->v_phy_closed) ||
        (jj == 1 && surf_geom->u_phy_closed)) continue;

     x_dist = ref_ext;xx_dist = x_dist;
     if ((jj == 0 && surf_geom->v_order == 2) ||
         (jj == 1 && surf_geom->u_order == 2))
     {
        x_dist = ref_ext; xx_dist = x_dist;
     }
     else if ((jj == 1 && surf_geom->v_order == 2) ||
              (jj == 0 && surf_geom->u_order == 2))
     {
        EFget_surf_extent(&msg_loc, surf_geom, NULL, NULL, &x_dist);
        if(x_dist > ref_ext || x_dist < 0.0) x_dist = ref_ext;
        xx_dist = x_dist;
     } 
     else
     {
        x_dist = ref_ext/2;xx_dist = x_dist;
     }
     ext_dist[jj] = x_dist; ext_dist[jj+2] = xx_dist;
   }
wrapup:
 EMWRAPUP( *EMmsg, stat_OM, "EMext_adj_sfs");
 return(stat_OM);
}
   
                       
/*
 * This function gives the extension distance required for non-planar
 * surfaces. This assumes that the extension check has been done already.
 */
IGRint D_Get_Ext_Dist( IGRlong *EMmsg,
                       struct GRmd_env *md_env,
                       struct EMSadj_surf_info **adj_sf_info,
                       IGRint list_len,
                       IGRint index,
                       struct IGRbsp_surface **surf_ge,
                       IGRdouble *ext_dist)
{
  struct IGRbsp_surface *surf_geom=NULL;
  IGRint jj,tt;
  IGRdouble x_dist,xx_dist,dist;
  IGRlong msg_loc = EMS_S_Success;
  IGRdouble srange[6],slrange[6],ref_ext,dist1,dist2;
  IGRboolean world = TRUE;
  IGRlong stat_OM  = OM_S_SUCCESS;
  BSrc rc;
  extern void EFget_surf_extent();
  IGRdouble BSdistptpt();
  
  surf_geom = *surf_ge;
  if(!surf_geom->planar) 
  {
    /*
     * range of the surface under consideration
     */
    stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        &world,
                                        srange),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info[index]->myself.objid,
                        targetos = adj_sf_info[index]->myself.osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

    /*
     * Initialize the extension distance
     */
    ref_ext=BSdistptpt(&rc, &srange[0], &srange[3]);
    
    for (jj=0; jj<2; jj++)
    {
      /*
       * If the surface is closed in that direction, let the extension
       * be zero
       */
      if(jj == 0 && surf_geom->v_phy_closed) continue;
      else if (jj == 1 && surf_geom->u_phy_closed) continue;

      dist = ref_ext/2;
      x_dist = dist;
      xx_dist = dist; 
      if ((jj == 0 && surf_geom->v_order == 2) ||
          (jj == 1 && surf_geom->u_order == 2))
      {
        /*
         * If the direction under consideration is linear, then
         * the extension distance is the maximum of the distance 
         * between the min point of the surface range and solid 
         * range and the distance between the max point of the
         * surface range and solid range

        for (tt=0; tt<6; tt++) slrange[tt] = srange[tt];

        stat_OM = D_Get_Solid_range(&msg_loc,md_env,adj_sf_info,
                                    list_len,index,slrange);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

        dist1 = fabs(BSdistptpt(&rc, &slrange[0], &srange[0])); 
        dist2 = fabs(BSdistptpt(&rc, &slrange[3], &srange[3]));
        x_dist = (dist1 >dist2) ? dist1:dist2; 
        xx_dist = x_dist;
        **************/

        /*
         * TO BE DONE: Project a ray along the linear direction to
         * the modified solid range. The distance between the old
         * and the intersection point gives the extension distance.
         * Need to be implemen. Atpresent just following the old stuff.
         */ 
        x_dist = dist; xx_dist = x_dist;
      }
      else if ((jj == 1 && surf_geom->v_order == 2) ||
                (jj == 0 && surf_geom->u_order == 2))
      {
        /*
         * if the direction under consideration is non-linear then
         * get the surface extension calculated based on its surface
         * range keeping the allowed extension distance calculated
         * based on the minimum radius of curvature of the iso curve
         */
        dist = ref_ext/5;
        x_dist = dist;
        EFget_surf_extent(&msg_loc, surf_geom, NULL, NULL, &x_dist);
        if(x_dist > dist ||  x_dist < 0.0) x_dist = dist;
        x_dist *=0.5;
        xx_dist= x_dist;
      }
      else
      {
        /*
         * Extension distance for free-form surfaces
         */
        x_dist = ref_ext/5;

        if((jj == 0 && surf_geom->u_phy_closed) ||
           (jj == 1 && surf_geom->v_phy_closed)) x_dist = ref_ext/20;

        xx_dist= x_dist;
      }
      ext_dist[jj] = x_dist;
      ext_dist[jj+2] = xx_dist;
    }
  } 

 wrapup:
 EMWRAPUP( *EMmsg, stat_OM, "EMext_adj_sfs");
 return(stat_OM);  
}


/*
 * This function is to extend and copy the surface, for replace surface
 * functionality
 */
IGRint   EMextend_adj_surfs(EMmsg,
                    md_env,
                    const_list,
                    draft_angle, min_angle,
                    adj_sf_info,
                    num_surfs,
                    index,
                    class_id,
                    cp_info)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   struct GRvg_construct *const_list;
   IGRdouble draft_angle, min_angle;
   IGRint index, num_surfs;
    OMuword class_id;
   struct EMSadj_surf_info **adj_sf_info, *cp_info;
{
    IGRlong rc = BSSUCC, stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint  jjj,  ii, jj;
    struct EMSadj_surf_info *adj_info;
    IGRdouble surf_range[6],  ex_dist, xx_dist, x_dist, dotp, u_par, v_par;
    IGRdouble surf_range1[6];
    IGRboolean  world = TRUE, pos_orient_bit = FALSE;
    IGRvector nrml[1][1],  nrml1[1][1];
    IGRpoint pnts[1][1];
    struct IGRbsp_surface *surf_geom=NULL;
    IGRpoint plane_pt1, plane_pt2, plane_pt3;
    IGRdouble dist, dist1, dist2, dist_max, extend_distance;
    IGRpoint point_1, point_2, point_3;
    IGRvector vec_1, vec_2, temp_vec;

    IGRdouble factor = 1.0;
    IGRint    num_iter = 0;

    IGRboolean EFare_surfs_tan();
    IGRdouble BSdistptpt();
    IGRdouble BSdistptpts();
    extern void EFget_surf_extent(),  EFget_surf_geom();
    struct BSgeom_bsp_surf gmsf, xgmsf;
    IGRdouble dist_out;
    IGRint option;
    IGRushort sf_type;
    extern  void  BSxgmsfdst();
    extern void getsftype();
    extern void BSchkfxsf ();


START:

    ++num_iter;
    if(surf_geom) {om$dealloc(ptr=surf_geom); surf_geom = NULL; }
    gmsf.bspsf=NULL;
    xgmsf.bspsf=NULL;
    world = TRUE;
    pos_orient_bit = FALSE;

    adj_info = adj_sf_info[index];
    getsftype(adj_info->myself.objid,adj_info->myself.osnum, &sf_type);

     EFget_surf_geom(EMmsg, md_env, adj_info->myself.objid,
                        adj_info->myself.osnum,  &surf_geom);
    
        adj_info->planar = surf_geom->planar;
        adj_info->pos_orient = surf_geom->pos_orient;

        stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &world,
                                    surf_range),
                        senderid = NULL_OBJID,
                        targetid = adj_info->myself.objid,
                        targetos = adj_info->myself.osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

        dist_max=0.0;
        for(ii=0; ii<num_surfs; ii++)
          {
           if(!adj_sf_info[ii]->affect&EM_ADDRFT_DRAFT_SRF)
              continue;
           stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &world,
                                    surf_range1),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info[ii]->myself.objid,
                        targetos = adj_sf_info[ii]->myself.osnum);
           EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
           dist=BSdistptpts(&rc, &surf_range1[0], &surf_range1[3]);
           if(dist_max < dist) dist_max=dist;
          }
        dist_max=sqrt(dist_max);

        u_par = v_par = 0.5;
        BSsfarrevn(&rc, surf_geom, 1, &u_par, 1, &v_par,
                                 (IGRdouble *)pnts, (IGRdouble *)nrml); 
        EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
        BSnorvec(&rc, nrml[0][0]);

        pos_orient_bit = surf_geom->pos_orient;

        dist=BSdistptpt(&rc, &surf_range[0], &surf_range[3]);
        extend_distance = dist;
        if(surf_geom->planar)
        {
          for(ii=0; ii<3;ii++)
                vec_2[ii] = surf_range[ii+3] - surf_range[ii];
          BSnorvec(&rc, vec_2);
          BScrossp(&rc, nrml[0][0], vec_2, temp_vec);

          for(ii=0; ii<3;ii++)
            {
            point_1[ii] = surf_range[ii] + (dist/2)*temp_vec[ii];
            point_2[ii] = surf_range[3+ii] + (dist/2)*temp_vec[ii];
            point_3[ii] = surf_range[3+ii] - (dist/2)*temp_vec[ii];
            }
          
          dist1=BSdistptpts(&rc, point_1, point_3);
          dist2=BSdistptpts(&rc, &surf_geom->poles[0], &surf_geom->poles[3]);

          if(dist2 < dist1)
             {
             for(ii=0; ii<3;ii++)
                {
                point_1[ii] = surf_geom->poles[0+ii];
                point_2[ii] = surf_geom->poles[6+ii];
                point_3[ii] = surf_geom->poles[3+ii];
                }
             }
        }

        dist = dist_max;
        if(min_angle < .01)         /** close to 0.0 degrees - tangential **/
           dist = dist_max;
        else if(min_angle >  1.57)  /*** close to 90.0 - perpendicular */
          dist = dist_max * tan(fabs(draft_angle));
        else
        {
          dist1 = tan(min_angle) - tan(fabs(draft_angle));
          if(dist1 < 0.0)
          {
            EMerr_hndlr( TRUE, *EMmsg, EMS_E_BSerror, wrapup);
          }
          dist = dist_max * (tan(fabs(draft_angle))/(cos(min_angle)* dist1));
        }

        if( surf_geom->planar &&
              class_id != OPP_EMArevol_class_id &&
                   class_id != OPP_EMSrevol_class_id)
        {
          dist *= 2.5;
          for(ii = 0; ii<3; ii++)
            {
             vec_1[ii] = point_2[ii] - point_1[ii];
             vec_2[ii] = point_3[ii] - point_1[ii];
            }
          BSnorvec(&rc, vec_1);
          BSnorvec(&rc, vec_2);
          
          for(ii = 0; ii<3; ii++)
            {
            plane_pt1[ii] = point_1[ii] - dist * vec_1[ii];
            plane_pt1[ii] = plane_pt1[ii] - dist * vec_2[ii];
            plane_pt2[ii] = point_2[ii] + dist * vec_1[ii];
            plane_pt2[ii] = plane_pt2[ii] - dist * vec_2[ii];
            plane_pt3[ii] = point_3[ii] - dist * vec_1[ii];
            plane_pt3[ii] = plane_pt3[ii] + dist * vec_2[ii];
            }
          BSplane3pt(&rc, plane_pt1, plane_pt2, plane_pt3, surf_geom);
          EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

           u_par = v_par = 0.5;
           BSsfarrevn(&rc, surf_geom, 1, &u_par, 1, &v_par,
                                      (IGRdouble *)pnts, (IGRdouble *)nrml1); 
           EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
           BSnorvec(&rc, nrml[0][0]);

           dotp = BSdotp(&rc, nrml[0][0], nrml1[0][0]);

           cp_info->pos_orient =  adj_info->pos_orient;
           if(dotp < 0.0)
             cp_info->pos_orient =  !(adj_info->pos_orient);

           if(
               (dotp < 0.0 && ( pos_orient_bit == surf_geom->pos_orient))
                                        ||
               (dotp > 0.0 && ( pos_orient_bit != surf_geom->pos_orient))
             )
               {
                 surf_geom->pos_orient = !surf_geom->pos_orient; 
               }
         const_list->geometry = (IGRchar *)surf_geom;

         stat_OM = om$construct(osnum = cp_info->myself.osnum,
           p_objid = &cp_info->myself.objid,
                     classid = OPP_EMSplane_class_id,
              msg = message GRgraphics.GRconstruct(const_list));
         if(!(1&msg_loc&stat_OM)) goto wrapup;

     }
     else
     {

if(class_id == OPP_EMAproject_class_id || class_id == OPP_EMSproject_class_id)
      class_id = OPP_EMSgenbs_class_id;
if(class_id == OPP_EMArevol_class_id || class_id == OPP_EMSrevol_class_id ||
  class_id == OPP_EMAsphere_class_id || class_id == OPP_EMSsphere_class_id ||
  class_id == OPP_EMApsphere_class_id || class_id == OPP_EMSpsphere_class_id)
         dist = extend_distance/8.0;
 else if(class_id == OPP_EMAgenbs_class_id || class_id == OPP_EMSgenbs_class_id)
         dist = extend_distance/5.0;
      
      xgmsf.bspsf = surf_geom;
      gmsf.bspsf = surf_geom ;
      gmsf.sfgen_cv = NULL ;
      /* xgmsf.bspsf =  NULL; */
      xgmsf.sfgen_cv = NULL ;

      gmsf.geom_prop=FALSE;
      gmsf.type=sf_type;
      gmsf.vrange[0]=0.;
      gmsf.vrange[1]=1.;
      gmsf.urange[0]=0.;
      gmsf.urange[1]=1.;
      gmsf.bounded= TRUE;

      xgmsf.geom_prop=FALSE;
      xgmsf.type=99;
      xgmsf.vrange[0]=0.;
      xgmsf.vrange[1]=1.;
      xgmsf.urange[0]=0.;
      xgmsf.urange[1]=1.;
      xgmsf.bounded= TRUE;

      for (jj=0; jj<2; jj++)
       {
       if(class_id == OPP_EMSsphere_class_id ||
               class_id == OPP_EMAsphere_class_id )
          continue;

       if(jj == 0 && surf_geom->v_phy_closed)
          continue;
       else if (jj == 1 && surf_geom->u_phy_closed)
          continue;
     
       x_dist = dist;
       xx_dist = dist;
       if ((jj == 0 && surf_geom->v_order == 2) || 
           (jj == 1 && surf_geom->u_order == 2))
          {
          if(class_id ==OPP_EMAgenbs_class_id || 
             class_id == OPP_EMSgenbs_class_id )
             dist *= 5.0;
          EFget_surf_extent(&msg_loc, surf_geom, &x_dist, &xx_dist,  NULL);
          if(x_dist > dist ||  x_dist < 0.0)
             x_dist = dist;
          if(xx_dist > dist ||  xx_dist < 0.0)
             xx_dist = dist;
          }
       else if ((jj == 1 && surf_geom->v_order == 2) || 
                (jj == 0 && surf_geom->u_order == 2))
          {
          EFget_surf_extent(&msg_loc, surf_geom, NULL, NULL, &x_dist);
          x_dist*=0.4;
          if(x_dist > dist ||  x_dist < 0.0)
             x_dist = dist;
          xx_dist= x_dist;
          }
        else
          {
             x_dist = extend_distance/5.0;
             xx_dist = x_dist;

          /*
             For surfaces which are closed at one end and having order
             more than two at the other end,(typical example : Torus)
             the extension factor has to be less to avoid seam related
             problems && self-intersection problem. Hari

             SCOPE FOR IMPROVEMENT :
             ---------------------
               o Check whether a surface has to be extended or not.
                 If yes in which direction && distance

               o Extend if required by the required distance in that
                 direction

             This avoids unnecessary extension of surfaces avoiding
             many problems (atpresent he is extending all surfaces in
             all directions by some magic factor)

             Actually speaking extension is not required for these
             surfaces as for as add-draft code is concerned, but as
             this function serves for replace surface code in which
             the adjacent surfaces are extended, we cannot totally
             say extension has to be nil. Hari
           */
             

          if((jj == 0 && surf_geom->u_phy_closed) ||
             (jj == 1 && surf_geom->v_phy_closed))
           {
             x_dist /= 4;
             xx_dist = x_dist;
           }
          }

       x_dist *= factor;
       xx_dist *= factor;

       for(jjj=0;jjj<2; jjj++)
       {
       ex_dist = (jjj==0 ? x_dist : xx_dist);
       option=1;
       if(jj==0)
         {
         gmsf.type=sf_type;
         if(ex_dist > 0.0)
         BSxgmsfdst (&gmsf, ex_dist, option, FALSE, FALSE,
             (jjj==0 ? TRUE : FALSE), (jjj==0? FALSE :TRUE),
                   &xgmsf, &dist_out, &rc);
         }
       else if(jj==1)
         {
         gmsf.type=sf_type;
         if(ex_dist > 0.0)
         BSxgmsfdst (&gmsf, ex_dist, option,
                (jjj==0? TRUE : FALSE), (jjj==0? FALSE :TRUE),
                 FALSE, FALSE, &xgmsf, &dist_out, &rc);
         }
         if( rc != BSSUCC)
           {
            gmsf.bspsf = gmsf.bspsf;
            xgmsf.bspsf = gmsf.bspsf;
           }
         else
           {
            gmsf.bspsf = xgmsf.bspsf;
           }
        }
       }
      surf_geom = xgmsf.bspsf;
     if( gmsf.bspsf && (gmsf.bspsf!=xgmsf.bspsf)) 
           {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}

     /* check for self-intersection of the extended surface
        if self-intersecting then reduce the extension value
        and start the above extension procedure. This prevents
        creating invalid-solid .Hari

        Note: This added code checks for self-intersection and if
              found reduces the extension value by 10% and proceeds
              until surface without self-intersection result. This
              reverse-iterative way is only for surfaces which are 
              self-intersecting after extention. Surfaces which are
              not self-intersecting after extension will not be 
              affected by this added code.
      */
     {
     IGRshort out_code = 0;
     BSrc rc;
     struct IGRbsp_surface *outsf = NULL;

     EFget_surf_geom(EMmsg, md_env, adj_info->myself.objid,
                        adj_info->myself.osnum,  &outsf);


     /* If the out_code value is 16 then self-intersection */

     BSchkfxsf (surf_geom, 0, outsf, &out_code, &rc);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if(outsf) {om$dealloc(ptr = outsf);outsf=NULL;}

    /*
     * If self-intersecting then proceed with less extension
     * value (the maximum no of iteration is 2)
     */

     if(out_code == 16) 
      {
        factor *= .7;
        if(num_iter < 3) goto START; 
        EMerr_hndlr( TRUE,  *EMmsg,EMS_E_SurfaceError, wrapup);
      }
     }
          
     
     u_par = v_par = 0.5;
     BSsfarrevn(&rc, surf_geom, 1, &u_par, 1, &v_par,
                                       (IGRdouble *)pnts, (IGRdouble *)nrml1); 
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml[0][0]);

     dotp = BSdotp(&rc, nrml[0][0], nrml1[0][0]);
     cp_info->pos_orient =  adj_info->pos_orient;
     cp_info->planar =  surf_geom->planar;
     if(dotp < 0.0)
             cp_info->pos_orient =  !(adj_info->pos_orient);

     if( (dotp < 0.0 && ( pos_orient_bit == surf_geom->pos_orient))
                                        ||
         (dotp > 0.0 && ( pos_orient_bit != surf_geom->pos_orient)))
      surf_geom->pos_orient = !surf_geom->pos_orient;

     const_list->geometry = (IGRchar *)surf_geom;
     cp_info->myself.osnum = adj_info->myself.osnum;

     stat_OM = om$construct(osnum = cp_info->myself.osnum,
           p_objid = &cp_info->myself.objid,
                  classid = class_id,
                    msg = message GRgraphics.GRconstruct(const_list));
     if(!(1&msg_loc&stat_OM)) goto wrapup;
     }

    wrapup:
     if( gmsf.bspsf) {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}
        EMWRAPUP( *EMmsg, stat_OM, "EMext_adj_sfs");
        return (stat_OM);
}


/*
 * This function is to get the surface extension for non-linear direction
 */
void EFget_surf_extent(EMmsg, surf_geom, order_2_ext1,
                       order_2_ext2, order_3_ext)
   IGRlong *EMmsg;
   struct  IGRbsp_surface *surf_geom;
   IGRdouble *order_2_ext1;
   IGRdouble *order_2_ext2;
   IGRdouble *order_3_ext;
{
   BSrc rc;
   struct IGRbsp_curve iso_crv;
   IGRvector surf_tan, iso_crv_nrml;
   IGRpoint points[3];
   IGRpoint point0, point1, l_center, r_center;
   IGRdouble radius=0.0, par, t, l_curvature, r_curvature, l_radius, r_radius,
          rad=0.0, u_par, v_par,  dotp, surf_len=0.0, angle=0.0, ext=0.0,
          max_allowable_len, arc_len, start_par, end_par, dir_par;
   IGRboolean status;
   IGRint num_points, ii, iii, jj;
   IGRshort  opt;
   IGRboolean tst_plan, boundary;
   extern IGRdouble BSdistptpt(), BSarclen();

    if(order_2_ext1) *order_2_ext1 = -1.0;
    if(order_2_ext2) *order_2_ext2 = -1.0;
    if(order_3_ext) *order_3_ext = -1.0;
   
   iso_crv.poles = NULL;
   iso_crv.knots = NULL;
   iso_crv.weights = NULL;

   for(iii=0; iii<2; iii++)
   {
     if(iii==0)
       {
       u_par = 0.0;
       v_par = 0.0;
       }
     else if (iii==1)
       {
       u_par = 1.0;
       v_par = 1.0;
       }
     BSsfarrevt(surf_geom, 1, &u_par, 1, &v_par, 1.0, points[0], &rc);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if( surf_geom->u_order == 2)
          {
          for(jj=0;jj<3;jj++)
            surf_tan[jj] = points[1][jj]- points[0][jj];
          opt =1;
          par = u_par;
          if(!iso_crv.poles)
          iso_crv.poles = (IGRdouble *)
              alloca(surf_geom->v_num_poles *3 * sizeof(IGRdouble));
          EMerr_hndlr (! iso_crv.poles, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          if(!iso_crv.knots)
          iso_crv.knots = (IGRdouble *)
              alloca(surf_geom->v_num_knots *3 * sizeof(IGRdouble));
          EMerr_hndlr (! iso_crv.knots, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          if(!iso_crv.weights)
          iso_crv.weights = (IGRdouble *)
              alloca(surf_geom->v_num_poles  * sizeof(IGRdouble));
          EMerr_hndlr (! iso_crv.weights, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          }
      else if( surf_geom->v_order == 2)
          {
          for(jj=0;jj<3;jj++)
            surf_tan[jj] = points[2][jj] - points[0][jj];
          opt = 2;
          par=v_par;
          if(!iso_crv.poles)
          iso_crv.poles = (IGRdouble *)
              alloca(surf_geom->u_num_poles *3 * sizeof(IGRdouble));
          EMerr_hndlr (! iso_crv.poles, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          if(!iso_crv.knots)
          iso_crv.knots = (IGRdouble *)
              alloca(surf_geom->u_num_knots *3 * sizeof(IGRdouble));
          EMerr_hndlr (! iso_crv.knots, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          if(!iso_crv.weights)
          iso_crv.weights = (IGRdouble *)
              alloca(surf_geom->u_num_poles  * sizeof(IGRdouble));
          EMerr_hndlr (! iso_crv.weights, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          }
       else 
         goto wrapup;
 
      BSnorvec(&rc, surf_tan);
  
      tst_plan = FALSE;
      BSconstprcv(&rc, surf_geom, &opt, &par, &tst_plan, &iso_crv);
      EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if(order_2_ext1)
      {
       BScvnormal(&rc, &iso_crv, iso_crv_nrml);
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       dotp = BSdotp(&rc,  surf_tan, iso_crv_nrml);
       angle = acos(fabs( dotp)); 

       if(angle <  0.000000001)
         {
         max_allowable_len =  -1.0;
         goto wrapup;
         }
       u_par=0; v_par=0;
       BSsfeval(surf_geom, u_par, v_par, 0, point0, &rc);
       u_par = (opt == 1 ? 0.0 : 1.0);
       v_par = (opt == 1 ? 1.0 : 0.0);
       BSsfeval(surf_geom, u_par, v_par, 0, point1, &rc);

       surf_len = BSdistptpt(&rc, point0, point1);
      }

      num_points = 6;
      if(iso_crv.rational)
        num_points = 1;
      t=0.0;
      for(ii=0; ii<num_points; ii++)
         {
         BSrdcencrcv(&rc, &iso_crv, &t, &boundary, &l_curvature,
          &r_curvature, &l_radius, &r_radius, l_center, r_center);

         if(l_radius < r_radius) radius = l_radius; else radius = r_radius;

         if(ii==0) rad = radius; else if(rad > radius) rad = radius;

         t += 0.15;
         }

      if(order_3_ext)
      {
       if(!iso_crv.phy_closed)
        {
         start_par =0.0; end_par = 1.0; dir_par = 0.5;
         BSarclen(&rc, &status, &iso_crv, &start_par,
                                  &end_par, &dir_par, &arc_len);
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         }
        ext = 2 * M_PI * radius - arc_len;
        if( *order_3_ext > 0.0 ) 
          {
           if(ext <  *order_3_ext )
             *order_3_ext = ext;
          }
          else
          {
             *order_3_ext = ext;
          }
       }
      else if(order_2_ext1)
       {
        max_allowable_len = .90 *  radius/tan(angle);
        ext = max_allowable_len - surf_len;
        /* if(ext >  *order_2_ext) *order_2_ext = ext; */
        if(iii==0) *order_2_ext1 = ext; else *order_2_ext2 = ext;
       }
   }
        if(order_3_ext)
        if(*order_3_ext<0.0)  *order_3_ext = 0.0;
        if(order_2_ext1)
        if(*order_2_ext1 < 0.0)  *order_2_ext1 = 0.0;
        if(order_2_ext2)
        if(*order_2_ext2 < 0.0)  *order_2_ext2 = 0.0;

    wrapup:
       *EMmsg = EMS_S_Success;
}

end implementation EMSsubbs;




