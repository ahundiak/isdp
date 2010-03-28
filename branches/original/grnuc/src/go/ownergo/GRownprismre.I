/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
    This file contains the code to determine the relationship of the
    owner to a right prism.

History
    Gray Winn   09/15/87    Design date.
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"
#include "grerr.h"
#include "gocmacros.h"

#define  OUTSIDE        0
#define  INSIDE         1
#define  OVERLAPPING    2

extern IGRint   GRget_to_comp_info();

/*\
Name
    GRprismrel_owner

Description
    This method determines the relationship of a curve prism or a 
    right prism to an owner object. The type of prism is determined
    from the input variable, type prism.  

    *msg           IGRlong        completion code
    *mx_type       IGRshort       type of matrix
    matrix         IGRmatrix      environment matrix
    *prism_rel     IGRlong        If NULL then return true relationship
                                  of the object to the prism; else return
                                  the relationship that is being checked
                                  The flags for checking are defined in
                                  grgsdef.h
                                     -  TRUE_REL
                                     -  GO_INSIDE
                                     -  GO_OUTSIDE
                                     -  GO_OVERLAP
                                     -  GO_INSIDE | GO_OVERLAP
                                     -  GO_OUTSIDE | GO_OVERLAP
    *component_id  struct GRid    If NULL then ignore, if not NULL then
                                  contians the object id of a component
                                  which has already responded to the
                                  GRprismrel method.
    *component_rel IGRlong        The relationship of the component to
                                  the right prism
                                     0 - component is outside prism 
                                     1 - component is inside prism
                                     2 - component overlaps prism
    *type_prism    IGRshort       Type of prism 
                                     0 - right prism
                                     1 - curve prism
    *prism         IGRchar        The right or curve prism
    *relationship  IGRlong        The relationship of the curve to
                                  the right prism
                                     0 - curve is outside prism 
                                     1 - curve is inside prism
                                     2 - curve overlaps prism
 
Notes
    This method is a super set of the GRprismrel method.  This method
    allows the relationship of a component to be passed into the method.

Return Values
     MSSUCC - successful completion
     MSFAIL - error occured
     GR_E_INV_REQUEST - requested relationship was not met
\*/

method GRprismrel_owner (IGRlong *msg; 
                         IGRshort *mx_type; 
                         IGRmatrix matrix;
                         IGRlong *prism_rel; 
                         struct GRid *component_id;
                         IGRlong *component_rel; 
                         IGRshort *type_prism;
                         IGRchar *prism; 
                         IGRlong *relationship)
{
    IGRlong           om_msg; 
    IGRlong           ret_msg; 
    IGRlong           rel;
    IGRlong           rel_flag;
    IGRint            init;
    IGRint            count;
    IGRint            i;
    IGRint            component_index=-1;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    OM_S_CHANSELECT   chansel;
    IGRlong           true_component_rel = TRUE_REL;

    *msg = MSSUCC;

    if ( om_msg = GRget_to_comp_info( &chansel,
                                      OM_Gw_current_OS,
                                      my_id,
                                      &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                              mx_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        /*
         *  Was a component id supplied?  If so use it relationship to determine
         *  what can be done.
         */
        if (component_id && component_rel) {
            init = -1;
            rel = *component_rel;
            om$get_index ( objid_c = my_id, 
                                    p_chanselect = &chansel,
                                    objid = component_id->objid, 
                                    osnum2 = component_id->osnum,
                                    indexaddr = (OMuint *)&component_index);  
	    
        }
        else 
        {
            init = 0;
            component_index = -1;
        }

        if ((!prism_rel) || (*prism_rel == TRUE_REL)) 
        {
            rel_flag = 0;
            for (i=init; i < count; ++i) 
            {
                if ((i != component_index) && (i != -1)) 
                {
                    /*
                     *  Send a message to each component to get its relationship
                     *  to the prism.
                     */
                    om_msg = om$send ( msg = message GRgraphics.GRprismrel
                                                        (msg, 
                                                         &local_mx_type, 
                                                         local_matrix, 
                                                         prism_rel, 
                                                         type_prism,
                                                         prism, 
                                                         &rel), 
                                       p_chanselect = &chansel, 
                                       from = i, 
                                       to = i);
                }

                /*
                 *  Set up the relationship flag based on the graphics objects
                 *  relationship to the prism.  There are three possible bit
                 *  setting GO_INSIDE, GO_OUTSIDE, or GO_OVERLAP.
                 */
                rel_flag |= (rel == OUTSIDE) ? GO_OUTSIDE :
                            (rel == INSIDE)  ? GO_INSIDE  :
                                               GO_OVERLAP;

                /*
                 *  If the relation flag equals outside or inside then we must
                 *  continue looping to find out if all objects are outside
                 *  or inside.  Otherwise an overlapping condition has
                 *  occurred.
                 */

                if ((*relationship = (rel_flag == GO_OUTSIDE) ? OUTSIDE :
                                     (rel_flag == GO_INSIDE)  ? INSIDE  :
                                     OVERLAPPING) == OVERLAPPING )
                {
                    break;
                }
            }
        }
        else 
        {      
            switch (*prism_rel)
            {
            case GO_INSIDE:
            case GO_OUTSIDE:
                if (component_id && component_rel) 
                {
                    if (((*prism_rel == GO_INSIDE) && 
                         (*component_rel != INSIDE)) ||
                        ((*prism_rel == GO_OUTSIDE) &&
                         (*component_rel != OUTSIDE)))
                    {
                        *msg = GR_E_INV_REQUEST;
                        break;
                    }
                }

                /*
                 *  Must loop for through all components until an exception
                 *  is found.
                 */
                *msg = MSSUCC;
                *relationship = (*prism_rel & GO_INSIDE) ? INSIDE : OUTSIDE;
                for (i=0; i < count; ++i) 
                {
                    if (i != component_index) 
                    {
                        om_msg = om$send ( msg = message GRgraphics.GRprismrel
                                                           (msg, 
                                                            &local_mx_type, 
                                                            local_matrix, 
                                                            &true_component_rel, 
                                                            type_prism, 
                                                            prism, 
                                                            &rel), 
                                           p_chanselect = &chansel, 
                                           from = i, 
                                           to = i);
                    }

                    if (*msg == GR_E_INV_REQUEST) break;
                    else 
                    {
                        /*
                         *  Double check the prism relation to insure that the
                         *  object meets the requested relationship.
                         */
                        rel_flag = (rel == OUTSIDE) ? GO_OUTSIDE :
                                   (rel == INSIDE)  ? GO_INSIDE  :
                                                      GO_OVERLAP;

                        /*
                         *  If the graphic object relation to the prism 
                         *  was not one of the requested relationships.
                         */
                        if (! (rel_flag & *prism_rel)) 
                        {
                            *msg = GR_E_INV_REQUEST;
                            break;
                        }
                    }
                }
                break;
            
            case GO_OVERLAP:
                *msg = GR_E_INV_REQUEST;
                rel_flag = 0;
                for (i=init; i < count; ++i) 
                {
                    if ((i != component_index) && (i != -1)) 
                    {
                        /*
                         *  Send a message to each component to get its 
                         *  relationship to the prism.  Do not request 
                         *  that the overlapping relationship since one
                         *  could have an object inside and one outside
                         *  and be overlapping.
                         */
                        om_msg = om$send ( msg = message GRgraphics.GRprismrel
                                                              ( msg, 
                                                                &local_mx_type, 
                                                                local_matrix, 
                                                                &true_component_rel, 
                                                                type_prism, 
                                                                prism, 
                                                                &rel),
                                           p_chanselect = &chansel, 
                                           from = i, 
                                           to = i);
                    }

                    /*
                     *  Set up the relationship flag based on the graphics 
                     *  objects relationship to the prism.  There are three
                     *  possible bit setting GO_INSIDE, GO_OUTSIDE, or 
                     *  GO_OVERLAP.
                     */
                    rel_flag |= (rel == OUTSIDE) ? GO_OUTSIDE :
                                (rel == INSIDE)  ? GO_INSIDE  :
                                                   GO_OVERLAP;

                    /*
                     *  If the relation flag equals outside or inside then 
                     *  we must continue looping to find out if all objects 
                     *  are outside or inside.  Otherwise an overlapping 
                     *  condition has occurred.
                     */
                    if (!((rel_flag == GO_OUTSIDE) || (rel_flag == GO_INSIDE))) 
                    {
                        *msg = MSSUCC;
                        *relationship = OVERLAPPING;
                        break;
                    }
                }
                break;
            
            case GO_INSIDE | GO_OVERLAP:
                if (component_id && component_rel) 
                {
                    if ((*component_rel == INSIDE) ||
                        (*component_rel == OVERLAPPING))
                         *msg = MSSUCC;
                    else *msg = GR_E_INV_REQUEST;
                }

                /*
                 *  When the first occurance is found to be inside or 
                 *  overlapping then the entire object can be considered 
                 *  to be inside and overlapping.
                 */
                for (i=init; i < count; ++i) 
                {
                    if ((i != component_index) && (i != -1)) 
                    {
                        om_msg = om$send ( msg = message GRgraphics.GRprismrel
                                                          ( &ret_msg, 
                                                            &local_mx_type, 
                                                            local_matrix, 
                                                            &true_component_rel, 
                                                            type_prism, 
                                                            prism, 
                                                            &rel), 
                                           p_chanselect = &chansel, 
                                           from = i, 
                                           to = i);
                    }

                    /*
                     *  One of the objects is inside or overlapping.
                     */
                    if (*msg != GR_E_INV_REQUEST) 
                    {
                        *msg = MSSUCC;
                        *relationship = OVERLAPPING;
                        break;
                    }
                    else 
                    {
                        /*
                         *  Double check the prism relation to insure that the
                         *  object meets the requested relationship.
                         */
                        rel_flag = (rel == OUTSIDE) ? GO_OUTSIDE :
                                   (rel == INSIDE)  ? GO_INSIDE  :
                                                      GO_OVERLAP;
                        /*
                         *  If the graphic object relation to the prism 
                         *  was one of the requested relationships.
                         */
                        if (rel_flag & *prism_rel) 
                        {
                            *msg = MSSUCC;
                            *relationship = OVERLAPPING;
                            break;
                        }
                    }
                }
                break;

            case GO_OUTSIDE | GO_OVERLAP:
                if (component_id && component_rel) 
                {
                    *msg = ((*component_rel == OUTSIDE) ||
                            (*component_rel == OVERLAPPING)) ?
                            MSSUCC : GR_E_INV_REQUEST;
                }               

                /*
                 *  When the first occurance is found to be outside or 
                 *  overlapping then the entire object can be considered 
                 *  to be outside and overlapping.
                 */
                for (i=0; i < count; ++i) 
                {
                    if ((i != component_index) && (i != -1)) 
                    {
                        om_msg = om$send ( msg = message GRgraphics.GRprismrel
                                                              ( &ret_msg, 
                                                                &local_mx_type, 
                                                                local_matrix, 
                                                                &true_component_rel, 
                                                                type_prism, 
                                                                prism, 
                                                                &rel), 
                                           p_chanselect = &chansel, 
                                           from = i, 
                                           to = i);

/* TR#119421837, VDS having problems with Gexp class objects, needs to ignore
   these objects. We are going to hit this only if the owner is in Rtree
   and component does not understand this message,ignore rejected and unknown
   -gvk 30 Aug 94.
*/
			if(om_msg == OM_W_REJECTED_METHOD || 
			   om_msg == OM_W_UNKNOWN_MSG)
      					om_msg = OM_S_SUCCESS;


                    }

                    if (*msg != GR_E_INV_REQUEST) 
                    {
                        *msg = MSSUCC;
                        *relationship = OVERLAPPING;
                        break;
                    }
                    else 
                    {
                        /*
                         *  Double check the prism relation to insure that the
                         *  object meets the requested relationship.
                         */
                        rel_flag = (rel == OUTSIDE) ? GO_OUTSIDE :
                                   (rel == INSIDE)  ? GO_INSIDE  :
                                                      GO_OVERLAP;
                    }

                    /*
                     *  If the graphic object relation to the prism 
                     *  was one of the requested relationships.
                     */
                    if (rel_flag & *prism_rel) 
                    {
                        *msg = MSSUCC;
                        *relationship = OVERLAPPING;
                        break;
                    }
                }
                break;
            }
        }
    }

    return (om_msg);
}

method GRprismrel ( IGRlong *msg; 
                    IGRshort *mx_type; 
                    IGRmatrix matrix;
                    IGRlong *prism_rel; 
                    IGRshort *type_prism; 
                    IGRchar *prism; 
                    IGRlong *relationship)
{
    IGRlong  om_msg;

    om_msg = om$send (msg = message GRowner.GRprismrel_owner ( msg,
                                                               mx_type, 
                                                               matrix, 
                                                               prism_rel, 
                                                               NULL, 
                                                               NULL, 
                                                               type_prism,
                                                               prism, 
                                                               relationship),
                      targetid = my_id);

    return (om_msg);
}

end implementation GRowner;
