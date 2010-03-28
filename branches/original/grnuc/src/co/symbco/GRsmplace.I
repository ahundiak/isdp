/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRsmplace

Description
   This method is used to place a symbol reference.

   *msg           IGRlong           return code 
   num_origins    IGRint            The number of origins (i.e. symbol
                                    references to be placed).
   origins[]      IGRpoint          The origins of the symbol references.
   *angle         IGRdouble         The angle (in radians).
   scale[]        IGRdouble         An array of x,y,z scales.
   rot_matrix     IGRmatrix         Matrix defining the way the symbol
                                    reference is viewed. (View rotation)
   name[]         IGRchar           The name of the symbol
   properties     unsigned short    The properties of the new symbol
   *display       struct IGRdisplay ptr to display attributes
   *class_attr    IGRchar           Class specifiec attributes.
   level          IGRshort          The level of the symbol ref.
   *symbol_env    GRmd_env          Original symbol environment.
   *target_env    GRmd_env          Environment to construct objects in.
   *classname     IGRchar           The class name of the symbol ref.
   *sdh_id        struct GRid       The symbol definition header.
   sm_id[]        struct GRid       The new symbol reference id's.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn  02/21/87    Creation date.
   dhm        11/20/91    Get the active level if level is NULL.
   scw        07/08/92    ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "grownerdef.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
 
from GRgraphics        import GRconstruct, GRdelete, GRcopy, GRgetrang;
from GRconnector       import GRflexconn;

IGRint GRsmplace (msg, num_origins,  origins, angle, scale, rot_matrix,
                   name, properties, display, class_attr, level, 
                   symbol_env, target_env, classname, sdh_id, sm_id)
IGRlong           *msg;
IGRint            num_origins;
IGRpoint          origins[];
IGRdouble         *angle;
IGRdouble         scale[];
IGRdouble         rot_matrix[];
IGRchar           name[];
unsigned short    properties;
struct IGRdisplay *display;
IGRchar           *class_attr;
IGRshort          level;
struct GRmd_env   *symbol_env;
struct GRmd_env   *target_env;
IGRchar           classname[];
struct GRid       *sdh_id;
struct GRid       sm_id[];
{
IGRlong                 om_msg;
IGRlong                 ret_msg;
IGRlong                 index;
IGRint                  i; 
IGRint                  constructed;
IGRint                  copied_sdh;
IGRlong                 flag;
IGRshort                world;
IGRpoint                temp_origin;
GRrange                 range;         /* symbol def extents     */
IGRmatrix               id_matrix;
IGRmatrix               place_matrix;  /* sym ref placement mat  */
OM_S_CHANSELECT         chansel;       /* sdh to_cpx channel     */
struct GRvg_construct   cnst_list;     /* construction list      */
struct IGRlbsys         geom;          /* symbol reference header*/
struct GRid             target_sdh_id;

   *msg = MSSUCC;
   index = OM_K_MAXINT;
   world = FALSE;
   flag = GR_NO_OVERRIDE;
   constructed = 0;
   copied_sdh = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   cnst_list.newflag = 0;
   cnst_list.name = name;
   cnst_list.properties = properties;
   cnst_list.msg = &ret_msg;
   cnst_list.env_info = target_env;
   cnst_list.class_attr = class_attr;
   cnst_list.geometry = (IGRchar *)&geom;
   cnst_list.display = display;

   /* TR 91N3684
    * Get the active level as the default.   dhm  11/20/91
    */

   if (!level)
   {
     gr$get_active_level( buffer = &cnst_list.level );
   }
   else
   {
     cnst_list.level = level;
   }

   /*
    * Create the symbol reference placement matrix
    */

   temp_origin[0] = 0;
   temp_origin[1] = 0;
   temp_origin[2] = 0;

   if (properties & GRIS_VIEW_INDEP)
   {
      MAidmx (&ret_msg, id_matrix);
      om_msg = GRsmplmat(&ret_msg, angle, scale, temp_origin, id_matrix,
               place_matrix);
   }else
   {
      om_msg = GRsmplmat(&ret_msg, angle, scale, temp_origin, rot_matrix,
               place_matrix);
   }

   if (om_msg & ret_msg & 1)
   {
      /*
       *  Copy the symbol definition to the target
       *  environment.
       */

      target_sdh_id.osnum = target_env->md_id.osnum;
      om_msg = om$send(
               msg = message GRgraphics.GRcopy (&ret_msg, 
               symbol_env, target_env, &target_sdh_id.objid),
               senderid = NULL_OBJID,
               targetid = sdh_id->objid,
               targetos = sdh_id->osnum);

      if (om_msg & ret_msg & 1)
      {
         copied_sdh = TRUE;
   
         /*
          *  Inquire the extents of the symbol definition.
          */

         om_msg = om$send (
                  msg = message GRgraphics.GRgetrang (&ret_msg, NULL,
                  NULL, &world, range),
                  senderid = NULL_OBJID,
                  targetid = target_sdh_id.objid,
                  targetos = target_sdh_id.osnum);
       
         if (om_msg & ret_msg & 1)
         {
            /*
             *  Build the symbol geometry.
             */

            for (i = 0; i < 16; ++i)
            {
               geom.matrix[i] = place_matrix[i];
            }

            for (i = 0; i < 3; ++i)
            {
               geom.diag_pt1[i] = range[i];
               geom.diag_pt2[i] = range[i+3];
            }

            for (i=0; i < num_origins; ++i)
            {
               /*
                *  Define the origin of the symbol reference.
                */

               geom.matrix[3] = origins[i][0];
               geom.matrix[7] = origins[i][1];
               geom.matrix[11] = origins[i][2];

               /*
                *  Construct the symbol reference object.
                */

               sm_id[i].osnum = target_env->md_id.osnum;
               om_msg = om$construct(osnum = target_env->md_id.osnum,
                        classname = classname,
                        p_objid = &sm_id[i].objid);

               if (om_msg & 1)
               {
                  constructed++;

                  /*
                   *  Initialize the symbol reference object
                   */

                  om_msg = om$send(
                           msg = message GRgraphics.GRconstruct (
                           &cnst_list),
                           senderid = NULL_OBJID,
                           targetid = sm_id[i].objid,
                           targetos = sm_id[i].osnum);

                  if (om_msg & 1)
                  {                                       
                     /*
                      *  Connect the symbol reference to the symbol 
                      *  definition header object.
                      */

                     om_msg = om$send(
                              msg = message GRconnector.GRflexconn (
                              &ret_msg, &flag, &sm_id[i], &index, &index),
                              senderid = NULL_OBJID,
                              targetid = target_sdh_id.objid,
                              targetos = target_sdh_id.osnum);
                  }
               }
            }
         }
      }
   }

   if (!(om_msg & ret_msg & 1))
   {
      if (copied_sdh)
      {
         ret_msg = om$send(
                   msg = message GRgraphics.GRdelete (&ret_msg, 
                   target_env),
                   senderid = NULL_OBJID,
                   targetid = target_sdh_id.objid,
                   targetos = target_sdh_id.osnum);
      }

      for (i = 0; i < constructed; ++i)
      {
         ret_msg = om$send(
                   msg = message GRgraphics.GRdelete (&ret_msg, 
                   target_env),
                   senderid = NULL_OBJID,
                   targetid = sm_id[i].objid,
                   targetos = sm_id[i].osnum);
      }
   }  
   return(om_msg);
}

end implementation Root;
