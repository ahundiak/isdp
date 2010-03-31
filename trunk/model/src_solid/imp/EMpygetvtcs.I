/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpolyhdrn;

#include "EMS.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "EMSommacros.h"

# define BOTTOMRIGHT 0
# define BOTTOMLEFT 1
# define TOPRIGHT 2
# define TOPLEFT 3

# define EMSCVX_4F_4V_POLYHEDRON 4
# define EMSCVX_5F_5V_POLYHEDRON 5
# define EMSCVX_5F_6V_POLYHEDRON 6
# define EMSCVX_6F_7V_POLYHEDRON 7
# define EMSCVX_6F_8V_POLYHEDRON 8

# define SIZE_OF_GRid_BUFFER 6

int check_ascending_order (grida, gridb)
struct GRid *grida, 
            *gridb;
{
 
 int ret_value;

 if ((grida->objid) < (gridb->objid))
  ret_value = -1;
 else if ((grida->objid) == (gridb->objid))
  ret_value = 0;
 else if ((grida->objid) > (gridb->objid))
  ret_value = 1;

  return (ret_value);
 }

  

method EMget_vertices (IGRlong *EMmsg; /* completion code */
                       struct GRmd_env *env; 
                                       /* module environment of the solid */
                       IGRint  array_size; /* max number of vertices */
                       IGRint *no_of_vertices; /* number of vertices */
                       IGRpoint *vertices) /* the array of vertices */

/* ******************************************************************

Description
            This method determines the vertices of the polyhedron.

            Input
             array_size : Maximum number of vertices. Necessary to
                          specify the amount of memory allocated for
                          the vertices array. 
             env 
          
            Output
             no_of_vertices : number of vertices
             vertices : array containing the vertices

Notes
            Upon exit the completion code will be one of the
            following:
             EMS_S_Success : if successful
             EMS_E_Fail : if severe failure
             EMS_E_InvalidArg : if the polyhedron type is invalid i.e if the
                          polyhedron has more than six faces or eight
                          vertices

             The memory for the vertices array needs to have
             been preallocated.
Notes
             The approach followed below in extracting vertices of polyhedrons
             is not an ideal approach to do the same. What would be really
             required is to go into the topological space and extract the
             information necessary.  However, this would require more time
             than I can afford right now, and also would be inefficient. Hence
             the below approach will be good enough until hell breaks loose.

Assumptions
             This method can only return vertices of the primitive gift
             polyhedrons.  
             
             Surface indices are not disturbed. i.e if a surface is connected
             at index 0 it will stay connected at index 0.
 
             As and when standards arise for translating solids, this 
             method might have to be rewritten.
Algorithm

             Decide the type of the polyhedron by counting the number
             of surfaces and the number of vertices.
             Based on the type of the polyhedron, get the vertices

       
History
            PP      : 08/15/89       Removed the below deadline kludge.
            PP      : 06/09/87       Changes due to the class structure
                                     and data structure. 

------------------------------------------------------------------------------

                 DEADLINE KLUDGE

              Objectids if constructed
            in an ascending order will stay
               in an ascending order.
 
                                      PP : 06/09/87

---------------------------------------------------------------------------


            PP      : 02/15/87       design date.

******************************************************************** */

{

 IGRshort               i;             /* index used in for loop */
 IGRint                 surf_count;    /* number of surfaces belonging
                                          to me */
 IGRint                 surf_buffer_size;   /* size of the surface buffer size */
 
 IGRint                 polyhedron_type;
                                       /* the type of the
                                          polyhedron */
 IGRlong                status;        /* OM completion code */

 IGRdouble              uv[2] ;        /* array for storing the parameters of
                                          the vertex */ 
 IGRint                 generic[8][2];
                                       /* pointer to the array representing
                                          the information about vertices */
 struct GRid            surf_GRid_buffer[6];
 struct GRid            *surf_GRids;
                                       /* the object ids and the object
                                          space numbers of the surfaces */

 static IGRint  cvx4f4v [4][2] = {
            /* vertex number */   /* surface number */   /* vertex position */
            /*       1       */   {        0,                  BOTTOMLEFT  },
            /*       2       */   {        0,                  BOTTOMRIGHT },
            /*       3       */   {        0,                  TOPRIGHT    },
            /*       4       */   {        1,                  BOTTOMRIGHT }
                               };

 static IGRint  cvx5f5v [5][2]= {
            /* vertex number */   /* surface number */   /* vertex position */
            /*       1       */   {        0,                  BOTTOMLEFT  },
            /*       2       */   {        0,                  BOTTOMRIGHT },
            /*       3       */   {        0,                  TOPRIGHT    },
            /*       4       */   {        0,                  TOPLEFT     },
            /*       5       */   {        1,                  BOTTOMRIGHT }
                                  };

 static IGRint  cvx5f6v [6][2] = {
            /* vertex number */   /* surface number */   /* vertex position */
            /*       1       */   {        0,                  BOTTOMLEFT  },
            /*       2       */   {        0,                  TOPLEFT     },
            /*       3       */   {        0,                  TOPRIGHT    },
            /*       4       */   {        0,                  BOTTOMRIGHT },
            /*       5       */   {        1,                  TOPLEFT     },
            /*       6       */   {        1,                  TOPRIGHT    }
                                   };

 static IGRint  cvx6f7v [7][2] = {
            /* vertex number */   /* surface number */   /* vertex position */
            /*       1       */   {        5,                  BOTTOMLEFT  },
            /*       2       */   {        5,                  TOPLEFT     },
            /*       3       */   {        5,                  TOPRIGHT    },
            /*       4       */   {        5,                  BOTTOMRIGHT },
            /*       5       */   {        0,                  TOPRIGHT    },
            /*       6       */   {        0,                  BOTTOMLEFT  },
            /*       7       */   {        0,                  BOTTOMRIGHT }
                                   };
     
 static IGRint  cvx6f8v [8][2] = {
            /* vertex number */   /* surface number */   /* vertex position */
            /*       1       */   {        0,                  BOTTOMLEFT  },
            /*       2       */   {        0,                  TOPLEFT     },
            /*       3       */   {        0,                  TOPRIGHT    },
            /*       4       */   {        0,                  BOTTOMRIGHT },
            /*       5       */   {        5,                  TOPLEFT     },
            /*       6       */   {        5,                  BOTTOMLEFT  },
            /*       7       */   {        5,                  BOTTOMRIGHT },
            /*       8       */   {        5,                  TOPRIGHT    }
                                 };

  extern  void qsort ();

 int check_ascending_order ();
 
                             
/* *****************

 Initialisation

   ***************** */

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 surf_GRids = NULL;

/* *******************************

 Decide the type of the polyhedron. 

   ******************************* */

 status = om$send (msg = message EMSsolid.EMcount_vertices (EMmsg,
                         no_of_vertices),
                   targetid = my_id);
 if ( ! (1 & status & *EMmsg)) goto wrapup;

 if ((*no_of_vertices > 8) || (*no_of_vertices > array_size))
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 status = om$send(msg = message GRowner.GRget_number_components(EMmsg,
                        &surf_count),
                  targetid = my_id);
 if ( ! (1 & status & *EMmsg)) goto wrapup; 

 ems$get_memory(rc = EMmsg, element_size = sizeof(struct GRid),
                num_elements = surf_count, 
                buffer = (IGRchar *)surf_GRid_buffer,
                buffer_size = sizeof(struct GRid) * SIZE_OF_GRid_BUFFER,
                ptr = (IGRchar **) &surf_GRids);
 if (! surf_GRids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}


 surf_buffer_size = surf_count;

 status = om$send(msg = message GRowner.GRget_components
                       (EMmsg, env, surf_GRids, surf_buffer_size,
                        &surf_count, 0, MAXINT), 
                 targetid = my_id); 
 if ( ! (1 & status & *EMmsg)) goto wrapup;

/*
 * Sort the surf_GRids in an ascending order. This is done to get around the
 * problem occuring due to
 * surfaces being removed from the solid and not being put back at the
 * same index when one comes back to the primitive state during the
 * course of dpr operations. I think it is
 * a kludge of the century and will have to be modified at a later stage
 * when we have time in our hands.
 *                                               PP
 */
 
/*
 qsort ((char *) surf_GRids, (unsigned) surf_count, sizeof (struct GRid),
         check_ascending_order);
*/

 if ((surf_count == 4) && (*no_of_vertices == 4))
  polyhedron_type = EMSCVX_4F_4V_POLYHEDRON;
 else if (surf_count == 5)
 {
  if (*no_of_vertices == 5)
   polyhedron_type = EMSCVX_5F_5V_POLYHEDRON;
  else if (*no_of_vertices == 6)
   polyhedron_type = EMSCVX_5F_6V_POLYHEDRON;
  else
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }
 }
 else if (surf_count == 6)
 {
  if (*no_of_vertices == 7)
   polyhedron_type = EMSCVX_6F_7V_POLYHEDRON;
  else if (*no_of_vertices == 8)
   polyhedron_type = EMSCVX_6F_8V_POLYHEDRON;
  else 
   {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
   }
 }
 else
 {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
 }

switch (polyhedron_type)
{
 case EMSCVX_4F_4V_POLYHEDRON:
 OM_BLOCK_MOVE (cvx4f4v, generic, 8 * sizeof (IGRint));
  break;

 case EMSCVX_5F_5V_POLYHEDRON:
 OM_BLOCK_MOVE (cvx5f5v, generic, 10 * sizeof (IGRint));
  break;

 case EMSCVX_5F_6V_POLYHEDRON:
 OM_BLOCK_MOVE (cvx5f6v, generic, 12 * sizeof (IGRint));
  break;

 case EMSCVX_6F_7V_POLYHEDRON:
 OM_BLOCK_MOVE (cvx6f7v, generic, 14 * sizeof (IGRint));
  break;

 case EMSCVX_6F_8V_POLYHEDRON:
 OM_BLOCK_MOVE (cvx6f8v, generic, 16 * sizeof (IGRint));
  break;
}

for (i=0 ; i < *no_of_vertices ; i++)
{
 switch (generic[i][1])
 {
  case BOTTOMLEFT:
   uv[0] = 0.0;
   uv[1] = 0.0;
  break;
  
  case BOTTOMRIGHT:
   uv[0] = 1.0;
   uv[1] = 0.0;
  break;

  case TOPLEFT:
   uv[0] = 0.0;
   uv[1] = 1.0;
  break;

  case TOPRIGHT:
   uv[0] = 1.0;
   uv[1] = 1.0;
  break;
 }

 status = om$send (msg = message GRvg.EMptatpr (EMmsg,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         uv, 2, &vertices[i][0]),
                   targetid = surf_GRids[generic[i][0]].objid,
                   targetos = surf_GRids[generic[i][0]].osnum);
 if ( ! (1 & status & *EMmsg)) goto wrapup;

}
 
    
 
wrapup:
 if(surf_GRids && (surf_GRids ISNT surf_GRid_buffer))
    om$dealloc (ptr = (IGRchar *) surf_GRids);
 EMWRAPUP (*EMmsg , status , "In EMSpolyhdrn : EMget_vertices error ");
 return (status);
}

end implementation EMSpolyhdrn;
