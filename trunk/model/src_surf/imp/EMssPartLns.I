/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# include "gocmacros.h"     /* GRgetabsg                    */
# include "emsinterdef.h"   /* EMS_INTER_...                */
# include "EMSopt.h"        /* EMStrim..., EMSuntrimmed...  */
# include "bsgeom_cvsf.h"
# include "bserr.h"       
# include <stdio.h>

#define TEST_BLOCK 0

extern int  EFold_math_routine();


extern OMuword OPP_EMSplane_class_id,
               OPP_EMSelpsoid_class_id,
               OPP_EMSelpcyl_class_id,
               OPP_EMSelpcone_class_id,
               OPP_EMSsphere_class_id,
               OPP_EMSpsphere_class_id,
               OPP_EMScylindr_class_id,
               OPP_EMScone_class_id,
               OPP_EMSpcylindr_class_id,
               OPP_EMSpcone_class_id,
               OPP_EMStorus_class_id,
               OPP_EMSproject_class_id,
               OPP_EMSrevol_class_id;


method EMpartingLines(IGRlong *EMmsg; struct GRmd_env *md_env;
                      IGRvector vector; IGRushort options;
                      struct EMSpartolbasis *partolbasis;
                      IGRint *numgrps; struct BSpartgrp **partgrps)
/*
Abstract

    This method calculates the parting lines for a surface based
    on a view vector.

Arguments

    md_env - input
        The surface's module environment information.

    vector - input
        The view vectro expressed in world coordinates.

    options - input
        EMStrimWorldData
        EMStrimParametricData
        EMSuntrimmedWorldData
        EMSuntrimmedParametricData

    partolbasis - input
        Surface parametric tolerance.

    numgrps - output
        The number of parting line groups.

    partgrps - output
        The list of parting line groups.

History
    10 Jun  94 Vidya Included one more ancestry-valid  check for partial
		     sphere, to fix TR 119418315, which is missing

    14 Jan  94 WBC    Fixed a problem of overwriting memory during the
                      assignment statement lptr->next = NULL.  This occurred
                      in some cases when weeding out the point curves
                      returned from BSprtlngmsf().  I also fixed a memory leak
                      problem reported by Purify.  When freeing memory for
                      xyz_cvs and uv_cvs, only the memory for the first curve
                      was being freed.
    08 Jul  93 WBC    Freeing the memory for the bspline curves contained
                      in the structures xyz_cvs and uv_cvs.
    28 Oct  92 Jack   Fixed indexing problem when weeding out the
                      point curves returned from BSprtlngmsf().
    25 Aug  92 NP     Modified for ANSI compliance. The "&srf" pointer in 
                      GRgetabsg had been typecast to "struct IGRchar *" by mistake.
    16 Feb  92 Jack   Initialized 4 pointers to NULL.  They were
                      being accessed if the surface was an EMSplane.
    13 Jan  92 Jack   Commented out TEST_BLOCK for delivery.
    06 Jan  92 Jack   Fixed some problems indexing through the 
                      arrays returned from BSprtlngmsf().
    02 Oct  91 Jack   Added code to check if no useful edges were
                      returned and leave gracefully.
    12 Sep  91 Jack   Added code to determine my class in order to 
                      take advantage of the special casing done by 
                      BSprtlngmsf().
    19 June 91 Jack   Replaced call to BSsfpartlns with a new, faster
                      parting lines routine called BSprtlngmsf().
    30 Aug 1988 AIC   Creation.
*/
{

  IGRlong                sts = OM_S_SUCCESS;
  BSrc                   rc;
  IGRint                 i, local_numgrps,
                         num1,num2,num3, original_numgrps = 0;
  struct BSpartgrp      *local_partgrps = NULL,
                        *lptr;
  struct IGRbsp_surface *surf = NULL;
  extern void            EFtrimPartingLines();
  extern void            BSsfpartgrps();
  extern void            BSprtlngmsf();
  extern void            BSprgeomsf();
  extern IGRboolean      BSfreecv();
  struct BSgeom_bsp_surf sf;  

  struct BSgeom_bsp_curve *xyz_cvs = NULL,
                          *uv_cvs = NULL;
  IGRshort               code,
                         cvscode;
  IGRpoint               eyept;
  IGRdouble              ang;
  IGRint                *numint= NULL,
                        *num_pts = NULL,
                         pnt_curve,
                         ind;
  IGRpoint              **pts = NULL;
  BSpair                **uvpars = NULL;
  OMuword               my_classid;


  /*
   * Check options validity.
   */
  if((options & (EMStrimParametricData | EMStrimWorldData)) &&
     (options & (EMSuntrimmedWorldData | EMSuntrimmedParametricData)))
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }

  if(! (options & (EMStrimParametricData | EMStrimWorldData |
                   EMSuntrimmedWorldData | EMSuntrimmedParametricData)))
  {
    *EMmsg = EMS_I_NoSolution;
    goto wrapup;
  }

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  /*
   * Get the geometry.
   */
  GRgetabsg(EMmsg, &md_env->md_env.matrix_type, md_env->md_env.matrix,
            (IGRchar **)&surf, i);
  if (! (1 & *EMmsg)) goto wrapup;



 if(EFold_math_routine())
  {
   BSsfpartlns(surf,vector,FALSE,1,&local_numgrps,&local_partgrps,&rc);
   if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }
  }
 else
  {

   /* determine my class so that I can take advantage of the special
      casing done by BSprtlngmsf().
    */
  sts = om$get_classid( objid = my_id,
                        p_classid = &my_classid );    

  /* Need to first check ancestry of classes that are not superclasses
     of other classes we are going to check.
   */  
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSplane_class_id))== OM_S_SUCCESS)
    sf.type = BSRECT_PLANE;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSpsphere_class_id))== OM_S_SUCCESS)
      sf.type = BSPART_SPHERE;
  else
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSsphere_class_id))== OM_S_SUCCESS)
      sf.type = BSSPHERE;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSpcylindr_class_id))== OM_S_SUCCESS)
      sf.type = BSPART_CYL;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSpcone_class_id))== OM_S_SUCCESS)
      sf.type = BSPART_CONE;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMScylindr_class_id))== OM_S_SUCCESS)
      sf.type = BSFULL_CYL;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMScone_class_id))== OM_S_SUCCESS)
      sf.type = BSFULL_CONE;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMStorus_class_id))== OM_S_SUCCESS)
      sf.type = BSTORUS;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSelpsoid_class_id))== OM_S_SUCCESS)
      sf.type = BSGEN_BSP_SF; /* no special case yet */
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSelpcyl_class_id))== OM_S_SUCCESS)
      sf.type = BSGEN_BSP_SF; /* no special case yet */
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSelpcone_class_id))== OM_S_SUCCESS)
      sf.type = BSGEN_BSP_SF; /* no special case yet */
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSproject_class_id))== OM_S_SUCCESS)
      sf.type = BSSF_OF_PROJ;
  else 
  if((sts = om$is_ancestry_valid(subclassid = my_classid, 
            superclassid = OPP_EMSrevol_class_id))== OM_S_SUCCESS)
      sf.type = BSSF_OF_REV;
  else sf.type = BSGEN_BSP_SF;  /* 99 general B-spline surface */
     
  if( sf.type == BSRECT_PLANE )
   {
     /* if the surface is an ancestor of EMSplane, it won't have
        any horizon edges(parting lines) so don't bother calling
        the parting lines math routine.  set local_numgrps = -1
        as a flag to the calling routine and exit. 
      */  
     local_numgrps = -1;
   }
  else
   {
  /* fill out the struct BSgeom_bsp_surf */
  sf.geom_prop = FALSE;
  sf.bounded   = TRUE;
  sf.urange[0] = surf->u_knots[surf->u_order - 1];
  sf.urange[1] = surf->u_knots[surf->u_num_poles];
  sf.vrange[0] = surf->v_knots[surf->v_order - 1];
  sf.vrange[1] = surf->v_knots[surf->v_num_poles];
  sf.bspsf     = surf;


 
  code    = 2;  /* non-perspective with input dirvec and ang specified */
  cvscode = 0; /* return no curves */
  ang     = PI/2.0;
  local_numgrps = 0;
  numint  = NULL;
  num_pts = NULL;
  pts     = NULL;
  uvpars  = NULL;

  /*
   * Calculate the parting lines.
   */
BSprtlngmsf(&sf,        /* I surface structure */
             code,      /* I flag indicating what data is input for part. lns */
            &cvscode,   /* I/O flag indicating which curves are desired */
             eyept,     /* I eye point for perspective part. lines */
             vector,    /* I direction vector for non-persp. part. lines */
             ang,       /* I angle for non-perspective parting lines */ 
            &local_numgrps,   /* O number of groups of parting lines */
            &numint,    /* O array of number of parting lines per group */
            &num_pts,   /* O array of number of pts per parting lines */
            &pts,       /* O array of ptrs to arrays of pts on parting lns */
            &uvpars,    /* O array of ptrs to arrays of uv parm vals of pts on sf */
            &xyz_cvs,   /* O parting lns in model space */
            &uv_cvs,    /* O parting lns in uv space */
            &rc);       /* O return code */              

  /* test block to output pts and uvpars returned from the above routine.
     I'll leave it commented out unless needed since delivery is here.
     Note: pathname for the output file will need to be specified. -Jack

  if(TEST_BLOCK)
   {
   FILE    *outfile;
   IGRint   i,j,k;

    if( !( outfile = fopen( "/usr/john/tube1.n", "w" )))
    {
       printf(" *** unable to open output file /usr/john/tube1.n \n");
       exit(4);
    }

     fprintf(outfile,"Number of groups of intersection curves : %d\n\n",
             local_numgrps);
     ind = 0;
     for (i = 0; i < local_numgrps; ++i)
     {
        fprintf(outfile, "Number of intersection curves for group %d : %d\n\n",
                i, numint[i]);
        for (j = 0; j < numint[i]; ++j)
        {
            fprintf(outfile, "Number of points for curve %d : %d \n",
                    (ind+j),  num_pts[ind+j]);
            for (k = 0; k < num_pts[ind+j]; ++k)
            {
                fprintf(outfile, "  pt[%d][%d] :  %lf   %lf   %lf \n", 
                        (ind+j), k, pts[ind+j][k][0], pts[ind+j][k][1], 
                        pts[ind+j][k][2]);
                fprintf(outfile, "  uvpars    :  %lf  %lf \n", 
                        uvpars[ind+j][k][0], uvpars[ind+j][k][1]);
            }
 
        } 
        ind = ind + numint[i];
     }
    fclose( outfile );
   }
*****END TEST_BLOCK***************************/
  


  if(rc==BSCOINCIDENT)
    { /* no solution returned, exit gracefully */
     *EMmsg = EMS_S_Success;
      goto wrapup;
    }

  /* remove this before delivery */
  if(rc==BSOUTOFDESN)
    {
     *EMmsg = EMS_S_Success;
      printf("\n\n rc = BSOUTOFDESN!!!\n\n");
      goto wrapup;     
    }

  if(rc) 
    { 
     *EMmsg = EMS_E_Fail; 
      goto wrapup; 
    }

  /* determine how many groups are not point curves(only one parm per 
     group).  We do this first pass to see how many groups to malloc. */
  original_numgrps = local_numgrps;
  num3 = 0;
  ind = 0;
  for(num1=0;num1<local_numgrps;num1++) 
  {
   pnt_curve=1;
   for(num2=0;num2<numint[num1];num2++) 
     if(num_pts[ind+num2] > 1)
       pnt_curve=0;
   if(!pnt_curve)
     num3++;
   ind = ind + numint[num1];
  }


  /* if no parms were returned or only point curves, don't do this code */
  if(num3 > 0)
   {
    /* create enough parting line group structures */
    local_partgrps = (struct BSpartgrp *) om$malloc(size = 
                                             num3 * sizeof(struct BSpartgrp));

    if (! local_partgrps)
    {
      *EMmsg = EMS_E_NoDynamicMemory;
      goto wrapup;
    }

    ind=0;
    lptr = NULL;

    for(num1=0;num1<local_numgrps;num1++) 
     {
     /* weed out point curves */  
     pnt_curve=1;
     for(num2=0;num2<numint[num1];num2++)
      if((num_pts[ind+num2] > 1) || (!pnt_curve))
      { 
       if(pnt_curve) /* only want to do this once per group */
        {
         /* if the local structure pointer has not been set, initialize it,
          * else initialize the pointer to the next structure and increment
          * the local structure pointer
          */

         if (! lptr)
           lptr = local_partgrps;
         else
         {
           lptr->next = lptr + 1;
           lptr++;
         }

         lptr->pts = pts[num1];
         lptr->par = uvpars[num1];
         lptr->num = 0;
         lptr->next = NULL;
         pnt_curve = 0;
        }
       lptr->num=lptr->num + num_pts[ind+num2];
      }

      ind = ind + numint[num1];
     } /* end for each group */
   } /* end if num3 > 0 */
  /* reset local_numgrps because I weeded out the point curves */
  local_numgrps = num3;
  } /* end else -- surf was not a plane */
 } /* end else -- using new math */



  /*
   * Trim the new parting lines, if requested.
   */
  if(options & (EMStrimParametricData | EMStrimWorldData))
  {
   if(local_numgrps > 0) 
    {
      EFtrimPartingLines(EMmsg, my_id, md_env, options, &local_numgrps,
                        &local_partgrps);
      if(! (1 & *EMmsg)) goto wrapup;
    }
  }

  /*
   * Add the results to the existing list
   */
  if(local_numgrps > 0)
  {
    struct BSpartgrp    *grp;

    /*
     * Get the last member of the new list.
     */
    for(i=1, grp=local_partgrps; i < local_numgrps; i++, grp=grp->next);

    /*
     * Concatinate the lists
     */
    grp->next = *partgrps;
    *partgrps = local_partgrps;
    *numgrps += local_numgrps;
  }
  else 
  {
    *EMmsg = EMS_I_NoSolution;    
    *numgrps = local_numgrps;
  }


wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMpartingLines")

 if(!EFold_math_routine())
  {
   /* need to deallocate the memory allocated by the call to BSprtlngmsf */
   if(pts) om$dealloc(ptr = pts);
   if(uvpars) om$dealloc(ptr = uvpars);  
   if(num_pts) om$dealloc(ptr = num_pts);
   if(numint)  om$dealloc(ptr = numint);
   if(xyz_cvs)
   {
     for (i = 0; i < original_numgrps; i++)
     {
       if (xyz_cvs[i].bspcv)
         BSfreecv(&rc, xyz_cvs[i].bspcv);
     }
     om$dealloc(ptr = xyz_cvs);
   }
   if(uv_cvs)
   {
     for (i = 0; i < original_numgrps; i++)
     {
       if (uv_cvs[i].bspcv)
         BSfreecv(&rc, uv_cvs[i].bspcv);
     }
     om$dealloc(ptr = uv_cvs);
   }
  }
  return sts;
}

end implementation EMSsubbs;
