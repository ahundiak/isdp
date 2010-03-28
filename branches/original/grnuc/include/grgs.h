/*
Name
        grgs.h

Description
        This include file defines structures used by the graphics
        set package.

Dependencies
        igrtypedef.h, igetypedef.h, GR.H

history
        hgw     long ago    creation
*/

#ifndef  grgs_include
#define  grgs_include

/*
 *  defines the action arguments to the right prism graphics set 
 *  action handler.
 */

struct GRrp_action_args
{
   IGRint            rp_relation;
   IGRint            clip_flag;
   struct GRid       gs_id;
   struct GRid       sv_id;
};

/*
 *  defines the action arguments to the symbology graphics set 
 *  action handler.
 */

struct GRsymb_action_args
{
   IGRint            flag;          /* 1 - weight                    */
                                    /* 2 - color                     */
                                    /* 4 - style                     */
   IGRuchar 	     weight[5];     /* each bit represents a weight  */
   IGRuchar	     color[16];     /* each bit represents a color   */
   IGRuchar 	     style[1];      /* each bit represents a style   */
   struct GRid       gs_id;         /* graphics set object id        */
   struct GRid       sv_id;         /* save set object id            */
};

struct GRdelete_action 
{
   IGRint            layers[32];
   struct GRid       gs_id;         /* Graphics set object id        */
   struct GRid       sv_id;         /* Save set object id            */
};

#endif
