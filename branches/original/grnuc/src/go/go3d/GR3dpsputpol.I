/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dpllnstr
     METHOD NAME:  GRputpolyline

     Abstract: 
                This method posts the 3-D floating point planar 
        line string graphics object into the object's instance data.  
        The input structure contains a transformation matrix that 
        may be applied to the object before posting.

-----
%SC%    
        GRputpolyline(msg,md_env,post_info,polyline,newobjid)     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env    struct GRmd_env      structure defining the transfor-
                                      mation and other info about
                                      the object
     *post_info struct GRpost_info   processing control information
     *polyline  struct IGRpolyline   pointer to buffer containing
                                     internal format representation
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
     *newobjid    GRobjid        used if object changes classes,
                                    otherwise is same as my_id
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

     NOTES:  If a failure occurs, the object's
             instance data will not be modified

             If it is determined that the planar
             line string needs to change class,
             a new object (GRlinestr) will be
             constructed, the channel linkages
             of the original object will be
             transferred to the new object, and
             the original object will be deleted.

-----
%CH%

     CHANGE HISTORY:

        MAS     10/19/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method posts a 3-D planar line string into
        the instance data.  Before the instance data is modified,
        the internal format is transformed to local coordinates
        using the inverse of the matrix in the input structure.  
        A new range for the object is calculated and compared against
        the design limits.  If all operations succeed, the instance 
        data for the object is posted.  The object is updated in the
        R-tree if the module_id is not NULL_OBJID.

----*/
/*EH*/

class implementation GR3dpllnstr;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "grerr.h"
#include "mapriv.h"
#include "OMmacros.h"
#include "gocmacros.h"

extern    IGRboolean    MAdetplane();
extern    IGRboolean    MA2ptdis();

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
        struct GRpost_info *post_info;
        struct IGRpolyline *polyline; GRobjid *newobjid)
{
    IGRlong             OMmsg;          /* return status for method     */
    IGRlong             msg1;           /* internal message variable    */
    IGRlong             dimension;      /* dimension of variable length */
                                        /* array                        */
    GRrange             range;
    GRrange             old_range;
    IGRint              i, j;           /* loop counter                 */

    IGRchar             classname[80];

    IGRshort            chan_flag = 1;
    IGRshort            del_flag = 1;

    IGRdouble           tol,
                        point[3],
                        normal[3];

    struct IGRplane     plane;


/*
 *  initialize variables
 */

        OMmsg = OM_S_SUCCESS;
        *msg = MSSUCC;
        *newobjid = my_id;                /* object didn't change classes  */
/*
 *  transform the object to local coordinates
 *  and calculate the new range
 */

        OMmsg = GRposttransutil(msg,md_env,post_info,&polyline->num_points,
                                 polyline->points,range);

        if (! (1 & OMmsg) )
        {
            goto wrapup;
        }

/*
 *  check to see if object needs to change class
 *
 *  if so,
 *      - if construct flag set, alter data and continue as normal
 *      - otherwise, construct a new object and fill-in instance data
 *              - transfer all channel linkages to new object
 *              - delete original object
 */

        if (! post_info->construct_flag)
        {
            tol = MAETA * 1000;
            plane.point = point;
            plane.normal = normal;

            if ( (polyline->num_points > 3) &&
                 (! MAdetplane(&msg1,polyline->points,
                        &polyline->num_points,&tol,&plane)))
            {
                /*
                 *  line string is not planar, change class if possible
                 *  if environment matrix is not identity
                 *  transform the points back to world coordinates
                 *
                 *  this restores the abstract geometry
                 */
        
                if ( md_env->md_env.matrix_type != MAIDMX )         
                {
                    MAptsxform(&msg1,&polyline->num_points,
                               md_env->md_env.matrix,polyline->points,
                               polyline->points);
                }

                /*
                 *  construct GRlinestr object
                 */

                strcpy ( classname, "GR3dlinestr" );

                OMmsg = GRaltchgclass(msg,md_env,&my_id,classname,
                        &me->properties,polyline,&chan_flag,&del_flag,
                        newobjid);

                goto wrapup;
            }
        }

/*
 *  if the object is not being constructed
 *  update the range in the object and the R-tree
 */

        if ( ! post_info->construct_flag )
        {

            old_range[0] = old_range[3] = me->points[0][0];
            old_range[1] = old_range[4] = me->points[0][1];
            old_range[2] = old_range[5] = me->points[0][2];

            OMmsg = GRupdaterng(&msg1,md_env,post_info,&my_id,
                                 &me->properties,old_range,range);
        
            if (! (1 & OMmsg) )
            {
                *msg =  MSFAIL;
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

        if (! post_info->construct_flag)
        {
            me->properties |= GRIS_MODIFIED;
            
        }
        me->properties |= GRIS_PLANAR;

/*
 *  if environment matrix is not identity
 *  transform the points back to world coordinates
 */

        if ( md_env->md_env.matrix_type != MAIDMX )
        {
            MAptsxform (&msg1,&polyline->num_points,md_env->md_env.matrix,
                polyline->points,polyline->points);
        }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

wrapup:
    return(OMmsg);
}

end implementation GR3dpllnstr;
