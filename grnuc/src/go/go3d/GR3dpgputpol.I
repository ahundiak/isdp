/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dpolygon
     METHOD NAME:  GRputpolyline

     Abstract: 
                This method posts the instance data for a 3-D double 
        precision floating point polygon object.
                The input structure contains a transformation matrix
        that may be applied to the object before posting.

-----
%SC%    
        GRputpolyline(msg,md_env,post_info,polyline,newobjid)     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env     struct GRmd_env     structure defining the environment
                                      information
     *post_info  struct GRpost_info  processing control information
     *polyline   struct IGRpolyline  pointer to polyline to post

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
     *newobjid    GRobjid        object id of object after posting
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

-----
%CH%

     CHANGE HISTORY:
        
        MAS     10/08/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method posts a polygon in the instance data.  Before 
        the instance data is modified, the internal format may be 
        transformed using the inverse of the matrix in the input 
        structure.

        A new range for the object is calculated and compared 
        against the design limits.  If all operations succeed, the 
        instance data for the object is posted.  

        The R-tree is also updated, if the module id sent in is not
        NULL_OBJID.
----*/
/*EH*/

class implementation GR3dpolygon;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "mapriv.h"
#include "godef.h"
#include "grerr.h"
#include "OMmacros.h"
#include "gocmacros.h"

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
        struct GRpost_info *post_info; struct IGRpolyline *polyline; 
        GRobjid *newobjid)
{
    IGRlong             status;         /* return status for method     */
    IGRlong             i, j;           /* loop counter                 */
    IGRlong             msg1;           /* internal message variable    */
    IGRlong             dimension;      /* dimension of variable length */
                                        /* array                        */
    GRrange             range;
    GRrange             old_range;

    IGRshort            chan_flag = 1;
    IGRshort            del_flag = 1;


    IGRboolean          planar;         /* return value for MA functions*/

extern    IGRboolean    MAptsxform();

/*
 *  initialize variables 
 */

        status = OM_S_SUCCESS;
        *msg = MSSUCC;
        *newobjid = my_id;
        
/*
 *  transform the object to local coordinates
 *  and calculate the new range
 */

        status = GRposttransutil(msg,md_env,post_info,
                &polyline->num_points, polyline->points,range);

        if ( 1 & status)
        {
            status = GRcheckplanar(msg,polyline,post_info,&planar);

            if ( !planar)
            {                   /* object is not planar                 */
                if ( md_env->md_env.matrix_type != MAIDMX )
                {
                    MAoptsxform(&msg1,&polyline->num_points,
                            &md_env->md_env.matrix_type,
                            md_env->md_env.matrix,polyline->points,
                            polyline->points);
                }
                status = GRaltchgclass(msg,md_env,&my_id,"GR3dlinestr",
                        &me->properties,polyline,&chan_flag,&del_flag,
                        newobjid);

                goto wrapup;
            }

/*
 *  if the object is not being constructed
 *  update the range in the object and the R-tree
 */
            if (! post_info->construct_flag )
            {
                old_range[0] = old_range[3] = me->points[0][0];
                old_range[1] = old_range[4] = me->points[0][1];
                old_range[2] = old_range[5] = me->points[0][2];

                status = GRupdaterng(&msg1,md_env,post_info,&my_id,
                        &me->properties,old_range,range);
            
                if (! (1 & status) )
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

/*
 *  if environment matrix is not identity
 *  transform the points back to world coordinates
 *
 *  this restores the abstract geometry
 */

            if ( md_env->md_env.matrix_type != MAIDMX )
            {
                MAptsxform (&msg1,&polyline->num_points,
                        md_env->md_env.matrix,polyline->points,
                        polyline->points);
            }
        }

wrapup:

    GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_POSTED);

    return(status);
}

end implementation GR3dpolygon;
