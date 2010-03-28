#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#if defined( OPENGL )
#include <GL/gl.h>
#include <GL/glu.h>
#endif

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"


#if defined( X11 )
extern Display *EXdisplay;

#if defined( OPENGL )

/*--- DPglx_choose_visual --------------------------------------------------*/
int DPglx_choose_visual( struct WLcontext_info *context,
                         XVisualInfo *avail_visuals,
                         int num_avail,
                         int *chosen_index )
			   
/*
NAME
   DPglx_choose_visual

DESCRIPTION
   This function chooses which visual (out of the available visuals
   given) to use for the desired context.

SYNOPSIS
   int DPglx_choose_visual( struct WLcontext_info *context,
                            XVisualInfo *avail_visuals,
                            int num_avail,
                            int *chosen_index );

PARAMETERS
   context (in) - the desired context information
   avail_visuals (in) - an array of visuals to choose from
   num_avail (in) - the number of available visuals (size of array)
   chosen_index (out) - the index to use from the visual array
   
GLOBALS USED
   EXDisplay

RETURN VALUES
   WL_SUCCESS  Success
   WL_ERROR    Error

HISTORY
   05/18/93    Joel D. Underwood 
   Creation Date
*/

{
   int status = WL_SUCCESS, gl_status = 0;
   int index, attrib, value;
   int qualified[20], *qualified_ptr;
   int num_qualified, new_num_qualified;
   int test, num_tests;
   struct test_struct
   {
      int type_of_test;   /* the type of test to choose with. This is the attribute we are checking */
      int desired_value;  /* The desired_value to test against.  Depending on the case = >= or <= this value */
      IGRboolean crucial; /* Whether this attribute is crucial.  If there is a choice it will choose the */
                          /* visuals only with the desired_value, but if none of them pass this determines */
                          /* if it is still o.k. */
   };
   struct test_struct tests[20];
   int qual_mem_alloced = FALSE;
   int extreme_value, extreme_value_index, temp_index;
   int find_high, sorted = FALSE;
   
   if (!chosen_index )
   {
      status = WL_ERROR;
      goto wrapup;
   }
   else
   {
      /* initialize index to -1 */
      *chosen_index = -1;
   }
   
   if (!context)
   {
      status = WL_ERROR;
      goto wrapup;
   }
   
   if (!avail_visuals)
   {
      status = WL_ERROR;
      goto wrapup;
   }
   
   if (num_avail > 20)
   {
      qualified_ptr = (int *) malloc( sizeof(int) * num_avail);
      if (qualified_ptr)
      {
         qual_mem_alloced = TRUE;
      }
      else
      {
         /* couldn't allocate memory */
         status = WL_ERROR;
         goto wrapup;
      }
   }
   else
   {
      qualified_ptr = qualified;
   }
   
   num_qualified = num_avail;
   for (index = 0; index < num_avail; index++)
   {
      /* initialize in the order they were sent */
      qualified_ptr[index] = index;
   }   
   
   /* depending on the context information set up the tests */
   
   /* always test for open gl first */
   num_tests = 0;
   tests[ num_tests ].type_of_test = GLX_USE_GL;
   tests[ num_tests ].desired_value = TRUE;
   tests[ num_tests ].crucial = TRUE;
   num_tests++;
   
   if (context->flags & WL_DOUBLE_BUFFER_ABILITY)
   {
      /* if User requested double buffer ability, make it a high priority */
      tests[ num_tests ].type_of_test = GLX_DOUBLEBUFFER;
      tests[ num_tests ].desired_value = TRUE;
      tests[ num_tests ].crucial = TRUE;
      num_tests++;
   }
   
   if (context->base_cmap_type & WL_CMAP_TRUE_COLOR)
   {
      tests[ num_tests ].type_of_test = GLX_RGBA;
      tests[ num_tests ].desired_value = TRUE;
      tests[ num_tests ].crucial = TRUE;
      num_tests++;
   }
   else
   {
      tests[ num_tests ].type_of_test = GLX_RGBA;
      tests[ num_tests ].desired_value = FALSE;
      tests[ num_tests ].crucial = TRUE;
      num_tests++;
   }
   
   /* Check for Level of 0.  (Not overlay planes/pop up planes. */
   /* This function does NOT choose the highlight visual. */
   tests[ num_tests ].type_of_test = GLX_LEVEL;
   tests[ num_tests ].desired_value = 0;
   tests[ num_tests ].crucial = TRUE;
   num_tests++;
   
   tests[ num_tests ].type_of_test = GLX_BUFFER_SIZE;
   tests[ num_tests ].desired_value = context->base_depth;
   if ((context->hilite_used == TRUE) 
      && !(context->flags & WL_SEPARATE_HILITE) )
   {
      /* if using highlight for this visual add 1 to base depth */
      tests[ num_tests ].desired_value++;
   }
   tests[ num_tests ].crucial = FALSE;
   num_tests++;
   
   if (!(context->flags & WL_DOUBLE_BUFFER_ABILITY))
   {
      /* if User DID NOT request double buffer ability, place here for lower priority */
      tests[ num_tests ].type_of_test = GLX_DOUBLEBUFFER;
      tests[ num_tests ].desired_value = FALSE;
      tests[ num_tests ].crucial = FALSE;
      num_tests++;
   }
   
   if (context->base_cmap_type & WL_CMAP_TRUE_COLOR)
   {
      tests[ num_tests ].type_of_test = GLX_DEPTH_SIZE;
      tests[ num_tests ].desired_value = 1;
      tests[ num_tests ].crucial = TRUE;
      num_tests++;
   }
   else
   {
      tests[ num_tests ].type_of_test = GLX_DEPTH_SIZE;
      tests[ num_tests ].desired_value = 0;
      tests[ num_tests ].crucial = FALSE;
      num_tests++;
   }
   
   
   for (test = 0; ((test < num_tests) && (num_qualified > 0)); test++)
   {
      /* go through all of the tests while there are still qualified visuals */
#if defined( DEBUG )
      printf("test %d is attrib ",test);
      switch ( tests[test].type_of_test )
      {
         case GLX_USE_GL:
            printf("GLX_USE_GL");
            break;
         case GLX_RGBA:
            printf("GLX_RGBA");
            break;
         case GLX_BUFFER_SIZE:
            printf("GLX_BUFFER_SIZE");
            break;
         case GLX_DOUBLEBUFFER:
            printf("GLX_DOUBLEBUFFER");
            break;
         case GLX_DEPTH_SIZE:
            printf("GLX_DEPTH_SIZE");
            break;
         case GLX_STENCIL_SIZE:
            printf("GLX_STENCIL_SIZE");
            break;
         case GLX_LEVEL:
            printf("GLX_LEVEL");
            break;
         default:
            printf("%d",tests[test].type_of_test);
            break;
      }
      printf("\n");
#endif
   
      switch ( tests[test].type_of_test )
      {
         case GLX_USE_GL:
         case GLX_DOUBLEBUFFER:
         case GLX_RGBA:
         case GLX_LEVEL:
         default:
            /* check to see if value == desired value */
            new_num_qualified = 0;
            attrib = tests[test].type_of_test;
            value = 0;
            
            for (index = 0; index < num_qualified; index++)
            {
               /* go through all of remaining qualified visuals and test them */
               gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[index] ], attrib, &value);
         
#if defined( DEBUG )
               printf(" value %d == tests[test].desired_value %d\n",value,tests[test].desired_value);
#endif
            
               if (gl_status)
               {
                  status = WL_ERROR;
                  goto wrapup;
               }
               
               if (value == tests[test].desired_value)
               {
                  /* only add to the new qualified list if it passes the test */
                  qualified_ptr[new_num_qualified++] = qualified_ptr[index];
#if defined( DEBUG )
                  printf(" new_num_qualified %d qualified_ptr[new_num_qualified - 1] = %d index = %d\n",
                     new_num_qualified,qualified_ptr[new_num_qualified - 1],index);
#endif
               }
            }
            if (new_num_qualified > 0)
            {
               num_qualified = new_num_qualified;
            }
            else
            {
               /* all failed this test... try and break the tie by the next test */
               /* if not a crucial fail */
               if ( tests[ test ].crucial )
               {
                  num_qualified = 0;
               }
#if defined( DEBUG )
               printf("ALL FAILED THE TEST\n");
#endif
            }
            break;
   
         case GLX_BUFFER_SIZE:
         case GLX_DEPTH_SIZE:
            /* check to see if value >= desired value */
            new_num_qualified = 0;
            attrib = tests[test].type_of_test;
            value = 0;
            
            for (index = 0; index < num_qualified; index++)
            {
               /* go through all of remaining qualified visuals and test them */
               gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[index] ], attrib, &value);
               
#if defined( DEBUG )
               printf(" value %d >= tests[test].desired_value %d\n",value,tests[test].desired_value);
#endif
               
               if (gl_status)
               {
                  status = WL_ERROR;
                  goto wrapup;
               }
               
               if (value >= tests[test].desired_value)
               {
                  /* only add to the new qualified list if it passes the test */
                  qualified_ptr[new_num_qualified++] = qualified_ptr[index];
#if defined( DEBUG )
                  printf(" new_num_qualified %d qualified_ptr[new_num_qualified - 1] = %d index = %d\n",
                     new_num_qualified,qualified_ptr[new_num_qualified - 1],index);
#endif
               }
            }
            if (new_num_qualified > 0)
            {
               num_qualified = new_num_qualified;
               
               if (!sorted)
               {
                  /* sort in order now from the largest to the smallest */
                  for (index = 1; index < num_qualified; index++)
                  {
                     gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[index - 1] ], attrib, &value);
                     extreme_value = value;
                     extreme_value_index = index - 1;
                     for (find_high = index; find_high < num_qualified; find_high++ )
                     {
                        gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[find_high] ], attrib, &value);
                        if (extreme_value != value)
                        {
                           sorted = TRUE;
                        }
                        if (extreme_value < value)
                        {
                           extreme_value = value;
                           extreme_value_index = qualified_ptr[find_high];
                        }
                     }
                     if (extreme_value_index != index -1)
                     {
                        /* swap */
                        temp_index = qualified_ptr[extreme_value_index];
                        qualified_ptr[extreme_value_index] = qualified_ptr[index - 1];
                        qualified_ptr[index - 1] = temp_index;
                     }
#if defined( DEBUG )
                     if (sorted)
                     {
                        printf("SORTED\n");
                     }
#endif
                  }
               }
            }
            else
            {
               /* all failed this test... try and break the tie by the next test */
               /* if not a crucial fail */
               if ( tests[ test ].crucial )
               {
                  num_qualified = 0;
               }
#if defined( DEBUG )
               printf("ALL FAILED THE TEST\n");
#endif
            }
            break;
   
         case GLX_STENCIL_SIZE:
            /* check to see if value <= desired value */
            new_num_qualified = 0;
            attrib = tests[test].type_of_test;
            value = 0;
            
            for (index = 0; index < num_qualified; index++)
            {
               /* go through all of remaining qualified visuals and test them */
               gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[index] ], attrib, &value);
               
#if defined( DEBUG )
               printf(" value %d <= tests[test].desired_value %d\n",value,tests[test].desired_value);
#endif
               
               if (gl_status)
               {
                  status = WL_ERROR;
                  goto wrapup;
               }
               
               if (value <= tests[test].desired_value)
               {
                  /* only add to the new qualified list if it passes the test */
                  qualified_ptr[new_num_qualified++] = qualified_ptr[index];
#if defined( DEBUG )
                  printf(" new_num_qualified %d qualified_ptr[new_num_qualified - 1] = %d index = %d\n",
                     new_num_qualified,qualified_ptr[new_num_qualified - 1],index);
#endif
               }
            }
            if (new_num_qualified > 0)
            {
               num_qualified = new_num_qualified;
               
               if (!sorted)
               {
                  /* sort in order now from the largest to the smallest */
                  for (index = 1; index < num_qualified; index++)
                  {
                     gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[index - 1] ], attrib, &value);
                     extreme_value = value;
                     extreme_value_index = index - 1;
                     for (find_high = index; find_high < num_qualified; find_high++ )
                     {
                        gl_status = glXGetConfig(EXdisplay, &avail_visuals[ qualified_ptr[find_high] ], attrib, &value);
                        if (extreme_value != value)
                        {
                           sorted = TRUE;
                        }
                        if (extreme_value > value)
                        {
                           extreme_value = value;
                           extreme_value_index = qualified_ptr[find_high];
                        }
                     }
                     if (extreme_value_index != index - 1)
                     {
                        /* swap */
                        temp_index = qualified_ptr[extreme_value_index];
                        qualified_ptr[extreme_value_index] = qualified_ptr[index - 1];
                        qualified_ptr[index - 1] = temp_index;
                     }
#if defined( DEBUG )
                     if (sorted)
                     {
                        printf("SORTED\n");
                     }
#endif
                  }
               }
            }
            else
            {
               /* all failed this test... try and break the tie by the next test */
               /* if not a crucial fail */
               if ( tests[ test ].crucial )
               {
                  num_qualified = 0;
               }
#if defined( DEBUG )
               printf("ALL FAILED THE TEST\n");
#endif
            }
            break;

      }
   }
         
   if (num_qualified > 0)
   {
      /* a "tie" for qualified visuals just choose the first qualified one */
      /* Note: these may have been sorted if there was a >= or <= test     */
#if defined( DEBUG )
      printf("TOTAL QUALIFIED\nvisual");
      for (index = 0;index < num_qualified;index++)
      {
         printf(" %d",qualified_ptr[index]);
      }
      printf("\n");
#endif
      *chosen_index = qualified_ptr[0];
   }
   else
   {
      /* none were qualified for every crucial tests */
      *chosen_index = -1;
      status = WL_ERROR;
      goto wrapup;
   }
      
wrapup:
      
   if ( qual_mem_alloced )
   {
      free( qualified_ptr );
   }
   
   return( status );
}  /* DPglx_choose_visual */

#endif
#endif

