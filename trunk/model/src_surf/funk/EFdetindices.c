/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*

Name
   EFdetindices

Abstract
    This routine given an option, will determine the pole indices 
    according to the option specified
    The options that are currently 
    supported are:
     determine  the indices of the interior poles of a specified boundary
     determine the indices of the corner pole of a surface and all poles
               which are identical to the corner pole
     determine the indices of the interior poles on the surface

Synopsis
 
    void EFdetindices (EMmsg, option, ind, surf_info, indices_dimension)

    IGRlong		  *EMmsg
    IGRshort              option
    IGRint                ind
    IGRint		  indices_dimension
    struct   EMsurf_info  *surf_info 

Description

Return Values

Notes
   option
    0         determine the indices of the interior poles of the
              surface
    1         determine the indices of the interior poles of the
              specified boundary
    2         determine the indices of all poles on the surface
              which are equal to the corner pole specified .

If the dimension of the indices array in surf_info structure falls
short, memory is appropriately realloced and the dimension is
increased

History
   
            PP :  1/2/87              : design date  
            Sudha 7/06/93             : Sudha Modified for BSprototypes ansification

 I should mention the fact that BSmovsfpol.c was appropriately
 modified to result in this routine.

****************************************************************/

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "bsdefs.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "madef.h"
#include "emserr.h"
#include "bsdistptpts.h"

struct EMsurf_info
{
 struct IGRbsp_surface *surf;
 IGRlong no_of_indices;
 IGRint *indices;
 struct EMsurf_info *next;
};


void EFdetindices (EMmsg, option, ind, surf_info, indices_dimension)
 
IGRlong		     *EMmsg;

IGRshort              option; /* option = 0, det indices of interior poles 
                                          1  det indices of interior poles
                                             of the specified boundary
                                          2  det indices of corner pole and
                                             all poles identical to the
                                             corner pole */
IGRint                ind;  /*input-    if option == 1,
                                          BSULEFTBND means constant u[deg] bnd 
                                          BSURIGHTBND means constant u[np] bnd
                                          BSVLEFTBND means constant v[deg] bnd  
                                          BSVRIGHTBND means constant v[np] bnd
                                          if option == 2
                                          BSBTLEFTCOR means u[deg]/v[deg] corner
                                          BSBTRIGHTCOR means u[np]/v[deg] corner
                                          BSUPLEFTCOR means u[deg]/v[np] corner
                                          BSUPRIGHTCOR means u[np]/v[np] corner*/
struct EMsurf_info	*surf_info;     /* Contains the information about the
                                           surface structure and the pole
                                           indices which are affected
                                        
                                           The surface structure needs to
                                           be inputted.
         
                                           indices array of the structure
                                           is filled in appropriately 
                                        */
IGRint			*indices_dimension;
                                        /* dimension of the indices array */

{

#define INCRMNT 10;

  extern    void			free();
  extern    char			*realloc();

   BSrc rc;
   IGRint i,j,k;
   IGRint *indices;

   IGRlong	no_of_bytes;
   IGRdouble dist,dist_sqtol;
   IGRboolean same;
   IGRlong    indx;
   IGRpoint   testpoint;
   IGRpoint   refpoint;
   struct IGRbsp_surface *surf;

   
   *EMmsg = MSSUCC;
   surf = surf_info->surf;

   if( option == 0)
   {

      /* all the poles are to be modified  */

         for(i=1; i< surf->v_num_poles - 1; i++)
         {
            for(j=1; j< surf->u_num_poles - 1 ; j++)
            {
             if (surf_info->no_of_indices == *indices_dimension)
              {
               *indices_dimension += INCRMNT;
           
               no_of_bytes = *indices_dimension * sizeof (IGRint);

               indices = (IGRint *)realloc(surf_info->indices,
                                   no_of_bytes);
               if (!indices)
               {
                *EMmsg = MSNOMEM;
                goto wrapup;
               }
 
               surf_info->indices = indices;
              }

               surf_info->indices[surf_info->no_of_indices] =
                surf->u_num_poles*i + j;
               ++surf_info->no_of_indices;
            }
         }
   }
   else if (option == 1)
   {
         /* move interior poles of boundary  */
  
    if( ind == BSULEFTBND)
    {
     for(i=1; i< surf->v_num_poles-1; i++)
      {
       if (surf_info->no_of_indices == *indices_dimension)
        {
          *indices_dimension += INCRMNT;
           
          no_of_bytes = *indices_dimension * sizeof (IGRint);

          indices = (IGRint *)realloc(surf_info->indices,
                              no_of_bytes);
          if (!indices)
          {
            *EMmsg = MSNOMEM;
            goto wrapup;
          }
 
          surf_info->indices = indices;
         }

        surf_info->indices[surf_info->no_of_indices] =
               surf->u_num_poles*i ;
        ++surf_info->no_of_indices;
      }
     }
     else if (ind == BSURIGHTBND)
     { 
      for(i=1; i< surf->v_num_poles-1; i++)
       {
        if (surf_info->no_of_indices == *indices_dimension)
         {
           *indices_dimension += INCRMNT;
           
           no_of_bytes = *indices_dimension * sizeof (IGRint);

           indices = (IGRint *)realloc(surf_info->indices,
                               no_of_bytes);
           if (!indices)
           {
             *EMmsg = MSNOMEM;
             goto wrapup;
           }
 
           surf_info->indices = indices;
         }

         surf_info->indices[surf_info->no_of_indices] =
         i*surf->u_num_poles + surf->u_num_poles - 1;
         ++surf_info->no_of_indices;
        }
      }
     else if (ind == BSVLEFTBND)
     {
      for(i=1; i< surf->u_num_poles-1; i++)
       {          
        if (surf_info->no_of_indices == *indices_dimension)
         {
          *indices_dimension += INCRMNT;
           
          no_of_bytes = *indices_dimension * sizeof (IGRint);

          indices = (IGRint *)realloc(surf_info->indices,
                              no_of_bytes);
          if (!indices)
          {
           *EMmsg = MSNOMEM;
           goto wrapup;
          }
 
          surf_info->indices = indices;
         }

        surf_info->indices[surf_info->no_of_indices] =
                     i;
        ++surf_info->no_of_indices;
       }
     }
     else
     {
      for(i=1; i< surf->u_num_poles-1; i++)
       {          
        if (surf_info->no_of_indices == *indices_dimension)
         {
          *indices_dimension += INCRMNT;
        
          no_of_bytes = *indices_dimension * sizeof (IGRint);

          indices = (IGRint *)realloc(surf_info->indices,
                                      no_of_bytes);
          if (!indices)
           {
             *EMmsg = MSNOMEM;
             goto wrapup;
           }
 
           surf_info->indices = indices;
         }

         surf_info->indices[surf_info->no_of_indices] =
                (surf->v_num_poles - 1)  * surf->u_num_poles + i;
         ++surf_info->no_of_indices;
       }
     }
   }
   else
   {
         /* corner pole of surface is to be moved */

         (void)BSEXTRACTPAR(&rc,BSTOLSQLENVEC,dist_sqtol);
         if(BSERROR(rc))
         {
            *EMmsg = MSFAIL;
            goto wrapup;
         }

         if( ind == BSBTLEFTCOR)
               indx = 0;
         else if (ind == BSBTRIGHTCOR)
               indx = surf->u_num_poles - 1;
         else if (ind == BSUPLEFTCOR)
               indx = (surf->v_num_poles - 1) * surf->u_num_poles;
         else if (ind == BSUPRIGHTCOR)
               indx = (surf->v_num_poles - 1) * surf->u_num_poles +
                        surf->u_num_poles - 1;

         if (surf->rational)
         {
           for (i=0; i < 3; i++)
            {
             testpoint[i] = surf->poles[3*indx+i] / surf->weights[indx];
            }
         }
         else
         {
           for (i=0 ; i < 3 ; i++)
            {
             testpoint[i] = surf->poles[3*indx + i];
            }
         }

         for (i=0 ; i < (surf->u_num_poles * surf->v_num_poles); i++)
          {
            if (i != indx)
            {
             if (surf->rational)
             {
              for (k=0 ; k < 3 ; k++)
              {
              refpoint[k] = surf->poles[3*i + k]/ surf->weights[i];
              }
             }
             else
             {
              for (k=0 ; k < 3 ; k++)
              {
               refpoint[k] = surf->poles[3*i + k];
              }
             }

            dist = BSdistptpts (&rc, &testpoint[0],
                                    &refpoint[0]);
            if (BSERROR(rc))
             {
               *EMmsg = MSFAIL;
               goto wrapup;
             }
            
            if (dist < dist_sqtol)
             {
                 if (surf_info->no_of_indices == *indices_dimension)
                  {
                   *indices_dimension += INCRMNT;
           
                   no_of_bytes = *indices_dimension * sizeof (IGRint);

                   indices = (IGRint *)realloc(surf_info->indices,
                                    no_of_bytes);
                   if (!indices)
                   {
                    *EMmsg = MSNOMEM;
                    goto wrapup;
                   }
 
                   surf_info->indices = indices;
                  }
                  surf_info->indices[surf_info->no_of_indices] =
                     i;
                  ++surf_info->no_of_indices;
             }
            }
           }

                 if (surf_info->no_of_indices == *indices_dimension)
                  {
                   *indices_dimension += INCRMNT;
           
                   no_of_bytes = *indices_dimension * sizeof (IGRint);

                   indices = (IGRint *)realloc( surf_info->indices,
                                    no_of_bytes);
                   if (!indices)
                   {
                    *EMmsg = MSNOMEM;
                    goto wrapup;
                   }
 
                   surf_info->indices = indices;
                  }

                  surf_info->indices[surf_info->no_of_indices] =
                    indx;
                  ++surf_info->no_of_indices;
        }
   wrapup:
    if (! (1 & *EMmsg)) 
     {
      if (indices) free(indices);
      surf_info->indices = NULL;
     }

   return;
}
                        
