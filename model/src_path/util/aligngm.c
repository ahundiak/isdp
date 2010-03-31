/*
  OVERVIEW

  This file consists the functions for alignment of memory pointers and which 
  will be used internally to align a contiguous memory for curve and surface 
  data structures.
*/

/* Includes */

#include <stdio.h>
#include <alloca.h>      /* System */
#include <malloc.h>
#include <math.h>

#include "bs.h"
#include "bserr.h"
#include "bstypes.h"     /* BS */
#include "igrtypedef.h"
#include "igr.h"        

#include "PWminimum.h"
#include "PWerror.h"     /* Pathway */
#include "PWgmdata.h"

/* Prototypes */

#include "PWapi/aligngm.h"

/*
 * The following macros a memory pointer to align to the respective boundary
 * i.e. double, int, short etc. speciifed.
 */
#define PW_AlignBdry(bdry,ptr) (((unsigned long) (ptr) % (bdry)) ?   \
                                (bdry) - (unsigned long) (ptr) %     \
                                (bdry) + (char *) (ptr) : (char *)(ptr))

#define PW_AlignDouble(ptr)  PW_AlignBdry(sizeof(double),ptr)
#define PW_AlignInt(ptr)     PW_AlignBdry(sizeof(int),ptr)
#define PW_AlignShort(ptr)   PW_AlignBdry(sizeof(short),ptr)

/*
  ABSTRACT

  This function returns the number of bytes necessary to hold a B-spline
  curve data structure immediately followed by its poles, knots, weights,
  and boundary points (with proper alignment).

  ARGUMENTS  

  num_poles        I - number of poles
  order            I - order of curve
  rational         I - rational curve indicator
  num_boundaries   I - number of curve boundaries

  size            O  - number of bytes required

  NOTES

  Anybody who is to allocating the memory for the curve structure by a single 
  call to the memory allocation routine, he/she should call this routine to
  get the size of the memory to allocate. After allocating the memory one can
  use "pwAlignCvGeom" to align the allocated memory for different pointers in
  the structure definition.

  HISTORY

  Sanjay    11/07/95     Creation 
*/ 

int pwAlignCvSize 
(
  int num_poles, 
  short order, 
  PWboolean rational, 
  int num_boundaries
)
{ 
  int size=0;

  size = num_poles * (rational ? 4 : 3);
  size += num_poles + order + 2 * num_boundaries; 
  size *= sizeof(double); 
  size += sizeof(struct IGRbsp_curve) + 20;
  return size;
}

/*
  ABSTRACT
 
  This function returns the number of bytes necessary to hold a B-spline 
  surface data structure immediately followed by its poles, knots, weights, 
  and boundary points (with proper alignment).
 
  ARGUMENTS
 
  u_num_poles      I - number of poles in u
  v_num_poles      I - number of poles in v
  u_order          I - order in the u direction
  v_order          I - order in the v direction
  rational         I - rational indicator
  num_boundaries   I - number of boundaries
  points_per_bnd   I - number of points per boundary
 
  size             O - number of bytes required
 
  NOTES

  Anybody who is to allocating the memory for the surface structure by a single 
  call to the memory allocation routine, he/she should call this routine to
  get the size of the memory to allocate. After allocating the memory one can
  use "pwAlignSfGeom" to align the allocated memory for different pointers in
  the structure definition.

  HISTORY

  Sanjay    11/07/95     Creation 

*/

int pwAlignSfSize
(
  long u_num_poles, 
  long v_num_poles, 
  short u_order, 
  short v_order, 
  PWboolean rational, 
  int num_boundaries,
  int *points_per_bnd
)
{
  int size = 0;

  size = u_num_poles * v_num_poles * (rational ? 4 : 3);       
  size += u_num_poles + u_order + v_num_poles + v_order + 10; 
  size *= sizeof (double);                                            
  size += sizeof (struct IGRbsp_surface);                            
  if (num_boundaries)                                              
  {                                                               
    int i=0, j=0;                                            
                                                                
    while (i < num_boundaries) 
      j += points_per_bnd[i++];   
    size += 2 * j * sizeof(double);                           
    size += num_boundaries * sizeof(struct IGRbsp_bdry_pts);
  }                                                          
 
  return size;
}


/*
  ABSTRACT

  This function partitions a contiguous array of memory (starting at a B-spline
  curve structure) so that the structure is immediately followed by the curve's
  poles, knots, weights, and boundary points.  It is assumed that the curve is 
  properly aligned.  The internal pointers in the curve will be properly 
  aligned.

  ARGUMENTS
 
  num_poles        I - number of poles
  order            I - order of curve
  rational         I - rational curve indicator
  num_boundaries   I - number of curve boundaries
 
  curve           I/O- curve data structure
 
  NOTES

  Anybody who is to allocating the memory for the curve structure by a single 
  call to the memory allocation routine, he/she should call this routine to
  to align the allocated memory for different pointers in the structure 
  definition.

  HISTORY

  Sanjay    11/07/95     Creation 

*/

void pwAlignCvGeom
(
  long num_poles, 
  short order, 
  PWboolean rational, 
  int num_boundaries, 
  struct IGRbsp_curve  *p_curve
) 
{                                                                     
  p_curve->poles = (IGRdouble *) PW_AlignDouble(p_curve + 1);  
  p_curve->knots = &p_curve->poles[3 * (num_poles)];              
  if (rational)                                                     
  {                                                                   
    p_curve->weights = &p_curve->knots[num_poles + (order)];
    if (num_boundaries)
    {                                                                
      p_curve->bdrys = &p_curve->weights[num_poles];
    }                                                               
    else                                                           
    {                                                             
      p_curve->bdrys = 0;                                      
    }                                                           
  }                                                           
  else                                                         
  {                                                          
    p_curve->weights = 0;                                 
    if (num_boundaries)                                  
    {                                                     
      p_curve->bdrys = &p_curve->knots[num_poles + order]; 
    }                                                             
    else                                                         
    {                                                           
      p_curve->bdrys = 0;                                    
    }                                                         
  }                                                          
}


/*
  ABSTRACT

  This function partitions a contiguous array of memory (starting at a B-spline
  surface structure) so that the structure is immediately followed by the 
  surface's poles, knots, weights, and boundary points.  It is assumed that the
  surface is properly aligned.  The internal pointers in the surface will be 
  properly aligned.
 
  ARGUMENTS
 
  u_num_poles          I - number of poles in u
  v_num_poles          I - number of poles in v
  u_order              I - order in the u direction
  v_order              I - order in the v direction
  rational             I - rational indicator
  num_boundaries       I - number of boundaries
  points_per_bnd[]     I - number of points per boundary
 
  surface             I/O- aligned surface data structure

  NOTES

  Anybody who is to allocating the memory for the surface structure by a single 
  call to the memory allocation routine, he/she should call this routine to
  to align the allocated memory for different pointers in the structure 
  definition.

  HISTORY

  Sanjay    11/07/95     Creation 

*/

void pwAlignSfGeom
(
  long u_num_poles, 
  long v_num_poles, 
  short u_order, 
  short v_order, 
  PWboolean rational, 
  int num_boundaries, 
  int *points_per_bnd, 
  struct IGRbsp_surface *p_surface
) 
{                                                           
  long total_poles=0;                                      
  double *double_ptr=NULL;                                   
                                                        
  double_ptr = (double *) PW_AlignDouble(p_surface + 1); 
  p_surface->poles = double_ptr;                         
  total_poles = (u_num_poles) * (v_num_poles);            
  double_ptr += 3 * total_poles;                         
  if (rational)                                         
  {                                                   
      p_surface->weights = double_ptr;            
      double_ptr += total_poles;                   
  }                                               
  else                                           
      p_surface->weights = NULL;              
  p_surface->u_knots = double_ptr;           
  double_ptr += (u_num_poles) + (u_order);    
  p_surface->v_knots = double_ptr;         
  double_ptr += (v_num_poles) + (v_order);  
  if (num_boundaries)                      
  {                                       
    int i=0;                             

    p_surface->bdrys = (struct IGRbsp_bdry_pts *) double_ptr;
    double_ptr = (double *) PW_AlignDouble(p_surface->bdrys + (num_boundaries));
    for (i = 0; i < (num_boundaries); i++)                    
    {                                                        
      p_surface->bdrys[i].num_points = points_per_bnd[i];  
      p_surface->bdrys[i].points = double_ptr;              
      double_ptr += 2 * (points_per_bnd)[i];                 
    }                                                         
  }                                                            
  else                                                        
    p_surface->bdrys = NULL;                             
}
