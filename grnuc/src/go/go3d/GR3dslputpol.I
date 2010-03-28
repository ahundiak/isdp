/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dlinestr
     METHOD NAME:  GRputpolyline

     Abstract: 
                This method posts the instance data for a 3-D 
        floating point line string object.
                The object will be transformed to local coordinates
        using the environment information structure.
-----
%SC%    
        GRputpolyline(msg,md_env,post_info,polyline,newobjid)     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
      *md_env    struct GRmd_env      structure defining the
                                      environment information
                                      about the object
      *post_info struct GRpost_info   processing control
                                      information
      *polyline  struct IGRpolyline   pointer to geometry
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg       IGRlong        completion code
                                    - MSSUCC if successful
                                    - GRSNOINVTRAN (severe) if input
                                      matrix is not invertible
                                    - GRSDGNEXCEED (severe) if range
                                      exceeds design limits
                                    - MSFAIL (severe) if failure
     *newobjid    GRobjid        object id after posting geometry
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  If error occurs, the object's instance data will 
                not be modified

-----
%CH%
     CHANGE HISTORY:
        
        MAS     10/08/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method stores the geometry of the object.
        Before the instance data is modified, the
        internal format may need to be transformed using
        the inverse of the matrix in the input structure.
        The new range for the object is then calculated and
        compared against the design limits.  If all operations
        succeed, the instance data for the object is posted.
        The object is updated in the r-tree if the module id
        is not NULL_OBJID.
----*/
/*EH*/

class implementation GR3dlinestr;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "mapriv.h"
#include "godef.h"
#include "grerr.h"
#include "OMmacros.h"
#include "gocmacros.h"

extern    IGRboolean    MAdetplane();
extern    IGRboolean    MAptsxform();
extern    IGRboolean    MA2pt2dis();

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
        struct GRpost_info *post_info; struct IGRpolyline *polyline; 
        GRobjid *newobjid)
{
    IGRint              i, j;           /* loop counter                 */

    IGRlong             OMmsg;          /* return OMmsg for method      */
    IGRlong             msg1;           /* internal message variable    */
    IGRlong             dimension;      

    GRrange             range;          /* new range of object          */
    GRrange             old_range;

    struct IGRplane     plane;

    IGRdouble           tol,
                        point[3],
                        normal[3];


/*
 * initialize variables
 */

        OMmsg = OM_S_SUCCESS;
        *msg = MSSUCC;
        *newobjid = my_id;        

/*
 *  transform the object to local coordinates
 *  and calculate the new range
 */

        OMmsg = GRposttransutil(&msg1,md_env,post_info,
                 &polyline->num_points,polyline->points,range);
 
        if ( ! (1 & OMmsg) )
        {
            *msg = MSFAIL;
            goto wrapup;
        }

/*
 *  if the object is not being constructed,
 *  update the range in the object and the R-tree
 */

        if ( ! post_info->construct_flag )
        {
            old_range[0] = old_range[3] = me->points[0][0];
            old_range[1] = old_range[4] = me->points[0][1];
            old_range[2] = old_range[5] = me->points[0][2];
            
            OMmsg = GRupdaterng(&msg1,md_env,post_info,&my_id,
                 &me->properties,old_range,range);

            if ( ! ( 1 & OMmsg ))
            {
                *msg = MSFAIL;
                goto wrapup;
            }
        }

/*
 *  update vertices in object
 */

        om$vla_set_dimension(varray = me->points, size = polyline->num_points);
    
        for(i=0, j=0; i < polyline->num_points; ++i)
        {
            me->points[i][0] = polyline->points[j++];
            me->points[i][1] = polyline->points[j++];
            me->points[i][2] = polyline->points[j++];
        }

/*
 *  update properties word
 */

        if (! post_info->construct_flag)
        {
            me->properties |= GRIS_MODIFIED;
        }
        me->properties |= GRIS_PLANAR;

        if (polyline->num_points > 2)
        {
            plane.point = point;
            plane.normal = normal;
            tol = MAETA * 1000;

            MAdetplane(&msg1,polyline->points,&polyline->num_points,
                &tol,&plane);
            if ( msg1 == MANONPLANAR)
            {
                me->properties &= ~GRIS_PLANAR;
            }
        }

        if (me->properties & GRFILLED_DISPLAY)
        {
            IGRdouble dis;

            MA2pt2dis(&msg1,polyline->points,
                &polyline->points[(polyline->num_points * -1) * 3],&dis);

            if (dis > MAETA)
            {
                me->properties &= (~GRFILLED_DISPLAY);
            }
        }

/*
 *  if environment matrix is not identity,
 *  transform the points back to world coordinates
 *
 *  this restores the abstract geometry
 */
        if ( md_env->md_env.matrix_type != MAIDMX )
        {
            MAptsxform (&msg1, &polyline->num_points,
                md_env->md_env.matrix, polyline->points, polyline->points);
        }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

wrapup:
    return(OMmsg);

}
end implementation GR3dlinestr;
