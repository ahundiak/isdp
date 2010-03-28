/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <DIprims.h>
#include <DImacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <gotextdef.h>
#include "partdef.h"
#include "partmacros.h"

from GRlinear   import  GRgetpolyline, GRputpolyline;
from GRtext     import  GRreplace_text, GRchgtextattr;
from GRgraphics import  GRcopy, GRxform, GRdelete;
from GRvg       import  GRgenabsg;
from ACdiowner  import  ACadd_component;
from GRowner    import  GRdrop;

#define MAETA   1.0e-15

IGRint COpartslist_get_template ( partslist_id, 
                                  partslist_dir, 
                                  line_id, 
                                  line_no, 
                                  template )
    struct GRid * partslist_id;
    IGRchar     * partslist_dir;
    struct GRid * line_id;
    IGRint      * line_no;
    IGRint      * template;
{
    OM_S_CHANSELECT comp_chan;
    struct GRid     comp;
    OMuword         classid, gg_classid;
    IGRint          i, count;
    
    om$get_classid ( classname = "GRgrgrp",
                     p_classid = &gg_classid );
                     
    GRget_to_comp_info ( &comp_chan,
                         partslist_id->osnum, 
                         partslist_id->objid,
                         &count );
    *line_no = -1;
    *template = TRUE;
    line_id->osnum = partslist_id->osnum;
    line_id->objid = NULL_OBJID;
    
    /*
     * Find the last line in the partslist.
     */              
    for (i=0; i<count; ++i)
    {
        om$get_objid_at_index ( objid = partslist_id->objid,
                                osnum = partslist_id->osnum,
                                p_chanselect = &comp_chan,
                                index = i,
                                objidaddr = &comp.objid,
                                osnumaddr = &comp.osnum );
                                
        om$get_classid ( osnum = comp.osnum,
                         objid = comp.objid,
                         p_classid = &classid );
                         
        if (classid == gg_classid) 
        {
            ++(*line_no);
            line_id->objid = comp.objid;

            /*
             * If this is not the header.
             */
            if ( *line_no > 0 )
            {
                /*
                 * If the name is not found in the partslist directory
                 * this must be a blank line.
                 */
                if ( di$untranslate ( path = partslist_dir,
                                      objid = comp.objid,
                                      osnum = comp.osnum ) != DIR_S_SUCCESS )
                {
                    *template = FALSE;
                    break;
                }
            }
        }
    }

    return((*line_no != -1) ? 1 : 0);

}

IGRint COpartslist_get_line_info ( line_id, 
                                   block, 
                                   text, 
                                   num_texts, 
                                   divider, 
                                   num_dividers )
    struct GRid * line_id;
    struct GRid * block;
    struct GRid * text;
    IGRint      * num_texts;
    struct GRid * divider;
    IGRint      * num_dividers;
{
    OM_S_CHANSELECT comp_chan;
    struct GRid     comp;
    OMuword         classid, string_classid, text_classid, line_classid;
    IGRint          i, count;

    om$get_classid ( classname = "GR3dlineseg",
                     p_classid = &line_classid );
                     
    om$get_classid ( classname = "GR3dlinestr",
                     p_classid = &string_classid );
                     
    om$get_classid ( classname = "GR3dtext",
                     p_classid = &text_classid );
                     
    GRget_to_comp_info ( &comp_chan,
                         line_id->osnum, 
                         line_id->objid,
                         &count );

    if (text && num_texts)          *num_texts = 0;

    if (divider && num_dividers)    *num_dividers = 0;

    if (block)                      block->objid = NULL_OBJID;
        
    /*
     * Get all text ids and the block id.
     */              
    for (i=0; i<count; ++i)
    {
        om$get_objid_at_index ( objid = line_id->objid,
                                osnum = line_id->osnum,
                                p_chanselect = &comp_chan,
                                index = i,
                                objidaddr = &comp.objid,
                                osnumaddr = &comp.osnum );
                                
        om$get_classid ( osnum = comp.osnum,
                         objid = comp.objid,
                         p_classid = &classid );
                         
        if (classid == text_classid) 
        {
            if (text && num_texts)  
            {
                text[(*num_texts)++] = comp;
            }
        }
        else if (classid == line_classid)
        {
            if (divider && num_dividers)
            {
                divider[(*num_dividers)++] = comp;
            }
        }
        else if (classid == string_classid)
        {
            if (block) 
            {
                *block = comp;
            }
        }
    }

    return ( ( (block && (block->objid == NULL_OBJID)) ||
               (num_texts && (*num_texts == 0))        ||
               (num_dividers && (*num_dividers == 0)) ) ?
               0 : 1 );
}

IGRint COpartslist_add_line ( msg, 
                              mod_env, 
                              partslist_id, 
                              part_number, 
                              line_id, 
                              line_no )
    IGRint          * msg;
    struct GRmd_env * mod_env;
    struct GRid     * partslist_id;
    IGRchar         * part_number;
    struct GRid     * line_id;
    IGRint          * line_no;
{
    IGRint              om_msg = OM_S_SUCCESS;
    long                ok;
    struct GRid         template_id;
    IGRint              template;
    struct GRid         block;
    IGRdouble           points[15], dist1, dist2;
    IGRdouble           matrix[16];
    IGRint              matrix_type;
    struct IGRpolyline  polyline;
    IGRdouble           vector[3];
    OM_S_OBJID          objid;
    IGRchar             partslist_dir[DI_PATH_MAX];
    IGRint              action;
        
    *msg = MSSUCC;

    /*
     * Get the partslist_dir.
     */
    di$split ( pathname = part_number, dirname = partslist_dir );

    
    /*
     * Get the last line entry from the partslist.
     */

    if ( COpartslist_get_template ( partslist_id, 
                                    partslist_dir, 
                                    &template_id, 
                                    line_no,
                                    &template ) )
    {

        /*
         * If this is a template line ...
         */
        if (template)
        {
            /*
             * Make a copy of this line.
             */

            om_msg = om$send ( msg = message GRgraphics.GRcopy ( (long *)msg,
                                                                 mod_env,
                                                                 mod_env,
                                                                 &(line_id->objid)),
                               senderid = NULL_OBJID,
                               targetid = template_id.objid,
                               targetos = template_id.osnum );

            if (om_msg & *msg & 1)
            {
                line_id->osnum = template_id.osnum;

                /*
                 * Get the block id.
                 */            


                if (COpartslist_get_line_info (line_id, 
                                               &block, 
                                                (struct GRid *)NULL, 
                                                (IGRint *)NULL, 
                                                (struct GRid *)NULL, 
                                                (IGRint *)NULL))
                {
                    /*
                     * Get the points which make up the block.
                     */
                    action = 1;

                    polyline.num_points = 4;
                    polyline.points = points;

                    om_msg = om$send ( msg = message GRlinear.GRgetpolyline
                                                  ( (long *)msg,
                                                    &mod_env->md_env.matrix_type,
                                                    mod_env->md_env.matrix,
                                                    &action,
                                                    &polyline ),
                                       senderid = NULL_OBJID,
                                       targetid = block.objid,
                                       targetos = block.osnum );

                    if (om_msg & *msg & 1)
                    {
                        /*
                         * Determine the perpendicular to the build direction.
                         */
                        MA2ptdis ( msg, &points[0],  &points[3], &dist1 );
                        MA2ptdis ( msg, &points[0],  &points[9], &dist2 );

                        /*
                         * If the distance is longer between the 1st and 
                         * 2nd Pts than between the 1st and 4th Pts...
                         */
                        if (dist1 > dist2)
                        {
                            /* 4th Pt - 1st Pt */
                            vector[0] = points[9]  - points[0];
                            vector[1] = points[10] - points[1];
                            vector[2] = points[11] - points[2];
                        }
                        else
                        {
                            /* 2nd Pt - 1st Pt */
                            vector[0] = points[3]  - points[0];
                            vector[1] = points[4]  - points[1];
                            vector[2] = points[5]  - points[2];
                        }
    
                        MAtrlmx  (msg, vector, matrix);
                        MAtypemx (msg, matrix, &matrix_type);
            
                        /*
                         * Move the line to it's new position.
                         */
                        om_msg = om$send ( msg = message GRgraphics.GRxform 
                                                            ( (long *)msg,
                                                              mod_env,
                                                              (short *)&matrix_type,
                                                              matrix,
                                                              &objid ),
                                           senderid = NULL_OBJID,
                                           targetid = line_id->objid,
                                           targetos = line_id->osnum );
                                       
                        if (om_msg & *msg & 1)
                        {
                            /*
                             * Add the new line to the partslist.
                             */

                            om_msg = om$send ( msg = message ACdiowner.ACadd_component
                                                         ( (long *)msg, line_id ),
                                               senderid = NULL_OBJID,
                                               targetid = partslist_id->objid,
                                               targetos = partslist_id->osnum );

                        }
                    }
                }
                else *msg = CO_E_PARTSLIST_ERROR;


                if (!(om_msg & *msg & 1))
                {
                    om$send ( msg = message GRgraphics.GRdelete ( &ok, 
                                                                  mod_env ),
                              senderid = NULL_OBJID,
                              targetid = line_id->objid,
                              targetos = line_id->osnum );
                }
            }
        }
        else /* This is a blank line. */
        {
            *line_id = template_id;
        }

        if (om_msg & *msg & 1)
        {                
            /*
             * Add a name for this object in the partslist
             * directory.
             */

            di$add_name ( objname = part_number,
                          objid = line_id->objid,
                          osnum = line_id->osnum );
        }
    }
    else *msg = CO_E_PARTSLIST_ERROR;

    return(om_msg);
}


#argsused
IGRint COpartslist_add_info ( msg, 
                              mod_env, 
                              line_id, 
                              format, 
                              just, 
                              value,
                              num_cols )
    IGRint          * msg;
    struct GRmd_env * mod_env;
    struct GRid     * line_id;
    IGRchar        ** format;
    IGRchar        ** just;
    IGRchar        ** value;
    IGRint            num_cols;
{
    IGRint                  om_msg = OM_S_SUCCESS;
    struct GRid             block, text[25], divider[25];
    IGRint                  num_texts, num_dividers, len;
    struct GRdpb_text_symb  text_symb;
    IGRint                  mask = 0, action = 1, matrix_type;
    struct IGRpolyline      polyline;
    IGRdouble               points[15];
    IGRdouble               vector[3];
    IGRdouble               * col_pt1, * col_pt2;
    IGRdouble               matrix[16];
    IGRint                  i, j;
    OM_S_OBJID              objid;
    IGRdouble               height[3], to_point[3], from_point[3], unit[3];
    IGRdouble               offset;
    struct IGRlbsys         * lbsys;
    
    *msg = MSSUCC;

    block.objid = NULL_OBJID;
    
    /*
     * Get all text and divider ids from the line.
     */
    COpartslist_get_line_info ( line_id, 
                                &block, 
                                text, 
                                &num_texts, 
                                divider, 
                                &num_dividers );

    if ((num_dividers == (num_cols - 1)) && 
        (num_texts == num_cols)          &&
        (block.objid != NULL_OBJID) )
    {
        /*
         * Get the polyline from the block.
         */
        polyline.num_points = 4;
        polyline.points = points;
 
        om_msg = om$send ( msg = message GRlinear.GRgetpolyline
                                                  ( (long *)msg,
                                                    &mod_env->md_env.matrix_type,
                                                    mod_env->md_env.matrix,
                                                    &action,
                                                    &polyline ),
                           senderid = NULL_OBJID,
                           targetid = block.objid,
                           targetos = block.osnum );
        
        if (om_msg & *msg & 1)
        {
            /*
             * Get the partslist height vector.
             */
            for (i=0; i<3; ++i) 
            {
                height[i] = points[i+3] - points[i];
                if ((height[i] < MAETA) && (height[i] > -MAETA)) 
                {
                    height[i] = 0.0;
                }
            }
        
            /*
             * Get the partlist offset distance.
             */
            MA2ptdis (msg, &points[3], points, &offset);
            offset *= .25;
        
            col_pt1 = points;
        
            /*
             * For all columns...
             */
            for (i=0; i<num_cols; ++i)
            {
                if ( !strcmp(just[i], "center") )
                {
                    text_symb.Active_just = 7;
                }
                else if ( !strcmp(just[i], "right") )
                {
                    text_symb.Active_just = 12;
                }
                else
                {
                    text_symb.Active_just = 2;
                }

                mask = GRTEXT_JUST;
                om_msg =
                om$send ( msg = message GRtext.GRchgtextattr ( (long *)msg, 
                                                               mod_env, 
                                                               mask,
                                                               &text_symb ),
                          senderid = NULL_OBJID,
                          targetid = text[i].objid,
                          targetos = text[i].osnum );

                if (!(om_msg & *msg & 1)) goto quit;

                /*
                 * Replace the text for the appropriate column.
                 */
                len = strlen (value[i]);
                om_msg = om$send ( msg = message GRtext.GRreplace_text ( (long *)msg,
                                                                         mod_env,
                                                                         len,
                                                                         (IGRuchar *)value[i] ),
                                   senderid = NULL_OBJID,
                                   targetid = text[i].objid,
                                   targetos = text[i].osnum );

                if (!(om_msg & *msg & 1)) goto quit;

                /*
                 * Get the local bounded system from the text.
                 */
                om_msg = om$send ( msg = message GRvg.GRgenabsg ( (long *)msg,
                                                                  &mod_env->md_env.matrix_type,
                                                                  mod_env->md_env.matrix,
                                                                  (char **)&lbsys ),
                                   senderid = NULL_OBJID,
                                   targetid = text[i].objid,
                                   targetos = text[i].osnum );

                if (!(om_msg & *msg & 1)) goto quit;
    
                from_point[0] = lbsys->matrix[3];                            
                from_point[1] = lbsys->matrix[7];                            
                from_point[2] = lbsys->matrix[11];                            

                /*
                 * If this is the last point.
                 */
                if (i == num_cols - 1)
                {
                    col_pt2 = &points[9];
                }
                else
                {
                    col_pt2 = &points[3];
                    
                    polyline.num_points = 2;
                    polyline.points = col_pt2;
                
                    om_msg = om$send ( msg = message GRlinear.GRgetpolyline 
                                            ( (long *)msg,
                                              &mod_env->md_env.matrix_type,
                                              mod_env->md_env.matrix,
                                              &action,
                                              &polyline ),
                                       senderid = NULL_OBJID,
                                       targetid = divider[i].objid,
                                       targetos = divider[i].osnum );
                                   
                    if (!(om_msg & *msg & 1)) goto quit;
                }

                /*
                 * Get the initial to_point and the column width vector.
                 */
                for (j=0; j<3; ++j) 
                {
                    vector[j] = col_pt2[j] - col_pt1[j];
    
                    if ((vector[j] < MAETA) && (vector[j] > -MAETA)) 
                    {
                        vector[j] = 0.0;
                    }
                
                    to_point[j] = col_pt1[j] + (height[j]/2);
                }
            
                /*
                 * Determine the to_point.
                 */
                if (text_symb.Active_just == 2) /* Left Justified */
                {
                    MAunitvc(msg, vector, unit);
                    MAscalvc(msg, &offset, unit, unit);

                    to_point[0] += unit[0]; 
                    to_point[1] += unit[1]; 
                    to_point[2] += unit[2]; 
                }
                else if (text_symb.Active_just == 7) /* Center Justified */
                {
                    to_point[0] += (vector[0]/2);
                    to_point[1] += (vector[1]/2);
                    to_point[2] += (vector[2]/2);
                }
                else if (text_symb.Active_just == 12) /* Right Justified */
                {
                    MAunitvc(msg, vector, unit);
                    MAscalvc(msg, &offset, unit, unit);
                
                    to_point[0] += vector[0] - unit[0];
                    to_point[1] += vector[1] - unit[1];
                    to_point[2] += vector[2] - unit[2];
                }
                            
                for (j=0; j<3; ++j) 
                {
                    vector[j] = to_point[j] - from_point[j];

                    if ((vector[j] < MAETA) && (vector[j] > -MAETA)) 
                    {
                        vector[j] = 0.0;
                    }
                }
            
                MAtrlmx  (msg, vector, matrix);
                MAtypemx (msg, matrix, &matrix_type);
            
                /*
                 * Move the text to it's new position.
                 */
                om_msg = om$send ( msg = message GRgraphics.GRxform ( (long *)msg,
                                                                      mod_env,
                                                                      (short *)&matrix_type,
                                                                      matrix,
                                                                      &objid ),
                                   senderid = NULL_OBJID,
                                   targetid = text[i].objid,
                                   targetos = text[i].osnum );
                                       
                if (!(om_msg & *msg & 1)) goto quit;

                /*
                 * Make the first point equal to the second.
                 */
                col_pt1[0] = col_pt2[0];
                col_pt1[1] = col_pt2[1];
                col_pt1[2] = col_pt2[2];
            }
        }                
        else *msg = CO_E_PARTSLIST_ERROR;
    }
    else *msg = CO_E_PARTSLIST_ERROR;

quit:

    return(om_msg);
}


#argsused
COpart_pass_func ( msg,
                   pass_msg,
                   mod_env,
                   senderid,
                   senderos,
                   catalog,
                   number,
                   revision )
    IGRint          * msg;
    OM_p_MESSAGE      pass_msg;
    struct GRmd_env * mod_env;
    GRobjid           senderid;
    GRspacenum        senderos;
    IGRchar         * catalog;
    IGRchar         * number;
    IGRchar         * revision;
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRchar         partdir[DI_PATH_MAX];
    IGRchar         numrev[DI_PATH_MAX];
    
    di$give_pathname ( osnum = mod_env->md_id.osnum, pathname = partdir );
    di$strcat (to = partdir, from = "parts");

    if (!catalog)
    {
       di$strcat (to = partdir, from = "local");    
    }

    else
    {
       di$strcat (to = partdir, from = catalog);    
    }

    if (revision)
    {
       sprintf(numrev,"%s!%s",number, revision);
       strcpy(number,numrev);
    }

    di$strcat (to = partdir, from = number);
    di$strcat (to = partdir, from = "*");
    
    om_msg = di$pass ( msg = pass_msg, regexp = partdir );

    return (om_msg);
}
    
end implementation COpart;
