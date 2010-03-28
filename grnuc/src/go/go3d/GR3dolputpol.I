/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dorthlnst
     METHOD NAME:  GRputpolyline

     Abstract: 
                This method posts the instance data for a 3-D double 
        precision floating point orthogonal line string object.
        The input structure contains a transformation
        matrix that may be applied to the object before posting.

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
     *polyline  struct IGRpolyline   pointer to polyline
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

     NOTES:  If a failure occurs, the object's permanent
             format will not be modified

             If the line string becomes non-orthogonal, a
             new object is constructed for a GR3dpllnstr.
             If the line string becomes a point, a GR3dpoint
             is constructed.
             If the line string becomes non-planar, a new
             GR3dlinestr is constructed.

             If a new object is constructed, the GRorthlnst 
             object is deleted.  Any channel linkage will 
             be moved to the new object. The new object will 
             also be inserted into the R-tree.
-----
%CH%

     CHANGE HISTORY:
        
        MAS     10/07/87 : Design date.
        MAS     03/23/88 : Changed to check for planarity

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method stores the polyline in the instance data 
        of the orthogonal line string.
        Before the instance data is modified, the internal format 
        may need to be transformed using the inverse of the matrix 
        in the input structure.
        The object is checked to see if it needs to change class.
        The range of the new object is compared against the
        design limits.  If all tests pass, the instance data for
        the object is posted.  

        The updated object is inserted into the R-tree using the 
        new range if the module id is not NULL_OBJID.

----*/
/*EH*/

class implementation GR3dorthlnst;


#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "grerr.h"
#include "mapriv.h"
#include "OMmacros.h"
#include "gocmacros.h"

extern    IGRboolean    MAoptsxform();
extern    IGRboolean    MA2pt2dis();

method GRputpolyline(IGRlong *msg; struct GRmd_env *md_env;
        struct GRpost_info *post_info; struct IGRpolyline *polyline; 
        GRobjid *newobjid)
{
    IGRboolean          ortho,
                        planar;

    IGRint              i, j;            /* loop counter                 */

    IGRlong             OMmsg;          /* return status for method     */
    IGRlong             msg1;           /* internal message variable    */
    IGRlong             dimension;      /* dimension of variable length */
                                        /* array                        */

    IGRdouble           dis;

    GRrange             range,          /* new range of object          */
                        old_range;



    IGRshort            chan_flag = 1;
    IGRshort            del_flag = 1;


        OMmsg = OM_S_SUCCESS;
        *msg = MSSUCC;
        *newobjid = my_id;        /* assume object won't change class  */ 

        if (polyline->num_points < 2)
        {                       
            /* construct a point object         
             */

            GRaltchgclass(msg,md_env,&my_id,"GR3dpoint",&me->properties,
                polyline,&chan_flag,&del_flag,newobjid);

            goto wrapup;
        }

        /*
         *  transform the object to local coordinates
         *  and calculate the new range
         */

        OMmsg = GRposttransutil(msg,md_env,post_info,
                 &polyline->num_points,polyline->points,range);

        if (! (1 & OMmsg) )
        {
            goto wrapup;
        }

        /*  Check to see if object needs to change class
         *  This function checks to see if the object is orthogonal 
         *  and if it is planar.
         */

        if (! post_info->construct_flag)
        {
            OMmsg = GRcheckortho(msg,polyline,post_info,&ortho);
        
            if (! ortho)
            {
                /*
                 *  if environment matrix is not identity
                 *  transform the points back to world coordinates
                 *
                 *  this restores the abstract geometry
                 */

                if ( md_env->md_env.matrix_type != MAIDMX )
                {
                    MAoptsxform(&msg1,&polyline->num_points,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,polyline->points,
                        polyline->points);
                }

                OMmsg = GRaltchgclass(&msg1,md_env,&my_id,
                        "GR3dpllnstr",&me->properties,polyline,
                        &chan_flag,&del_flag,newobjid);

                if (! (1 & OMmsg) )
                {                   
                    *msg = MSFAIL;
                }
                goto wrapup;
            }

            OMmsg = GRcheckplanar(msg,polyline,post_info,&planar);
        
            if (! planar)
            {
                /*
                 *  if environment matrix is not identity
                 *  transform the points back to world coordinates
                 *
                 *  this restores the abstract geometry
                 */

                if ( md_env->md_env.matrix_type != MAIDMX )
                {
                    MAoptsxform(&msg1,&polyline->num_points,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,polyline->points,
                        polyline->points);
                }

                OMmsg = GRaltchgclass(&msg1,md_env,&my_id,
                        "GR3dlinestr",&me->properties,polyline,
                        &chan_flag,&del_flag,newobjid);

                if (! (1 & OMmsg) )
                {                   
                    *msg = MSFAIL;
                }
                goto wrapup;
            }
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

            OMmsg = GRupdaterng(&msg1,md_env,post_info,&my_id,
                 &me->properties,old_range,range);
        
            if (! (1 & OMmsg) )
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

        if (me->properties & GRFILLED_DISPLAY)
        {
            MA2pt2dis(&msg1,&polyline->points[0],
                &polyline->points[(polyline->num_points * -1) * 3],&dis);

            if (dis > MAETA)
            {
                me->properties &= (~GRFILLED_DISPLAY);
            }
        }

        me->properties |= GRIS_PLANAR;

        /*
         *  if environment matrix is not identity
         *  transform the points back to world coordinates
         *
         *  this restores the geometry
         */

        if ( md_env->md_env.matrix_type != MAIDMX )
        {
            MAoptsxform (&msg1,&polyline->num_points,
                &md_env->md_env.matrix_type,md_env->md_env.matrix,
                polyline->points,polyline->points);
        }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_POSTED);

wrapup:

    return(OMmsg);
}

end implementation GR3dorthlnst;
