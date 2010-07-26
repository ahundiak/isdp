/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:        GRtext

     METHOD NAME:        GRtxfillbuf

     Abstract:           This implementation file loads the data
                         necessary to display a text element.

-----
%SC%    

    VALUE = GRtxfillbuf(msg,matrix_type,matrix,ele_header)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type IGRshort       type of matrix 
     matrix       IGRmatrix      environment transformation matrix
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong         completion code:
                                     MSSUCC - successful completion
                                     MSFAIL - failure of routine
     *ele_header   struct DPele_header
                                   pointer to structure containing
                                   info. necessary to display the
                                   text element
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
        GRgetsymb
        GRgetrang
        GRgetgeom
-----
%RL%

     RELATIONS REFERENCED:
        none.
-----
%NB%

     NOTES:
             When ele_header is passed in, the memory for the range,
         level, display attributes structure, element specific attribute
         structure and the geometry structure must be declared by the
         calling routine and the addresses of these must be assigned to
         the appropriate members of the ele_header structure.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     12/31/86 : Design date.
        WBC     12/31/86 : Creation date.
        SCW     07/22/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method gathers all the information necessary to display a text
element and places in a "buffer" (struct DPele_header).

----*/
/*EH*/

class implementation GRtext;

#include   "msdef.h"
#include   "grimport.h"

method GRtxfillbuf(IGRlong *msg; IGRshort *matrix_type;
                   IGRmatrix matrix; struct DPele_header *ele_header)

{
    IGRboolean world;                  /* compute range in local or      */
                                       /* world coordinates              */
    IGRlong    OMreturn;               /* OM return value                */
    IGRlong    msg2;                   /* local return message           */
    struct     GRsymbology   symb;     /* symbology structure            */

    *msg = MSSUCC;                     /* initialize return codes        */
    OMreturn = OM_S_SUCCESS;

    /* get geometry of the local bounded system   */

    OMreturn = om$send(mode = OM_e_wrt_object,
                       msg = message GRvg.GRgetgeom(&msg2,matrix_type,
                             matrix,(IGRchar *)ele_header->geometry.lbsys),
                       senderid = my_id,
                       targetid = my_id);

    if ((1 & msg2) && (1 & OMreturn))
    {
        ele_header->type = IGRLB;              /* type of abstract geo   */
        ele_header->flags = 0;                 /* display flags         
        world = TRUE;
                                                 **** for now = 0 ********/
        OMreturn = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetrang(&msg2,matrix_type,
                                           matrix,&world,ele_header->range),
                           senderid = my_id,
                           targetid = my_id);
        if ((1 & msg2) && (1 & OMreturn))
        {
            OMreturn = om$send(mode = OM_e_wrt_object,
                       msg = message GRvg.GRgetsymb(&msg2,&symb),
                       senderid = my_id,
                       targetid = my_id);

            if ((1 & msg2) && (1 & OMreturn))
            {
                *(ele_header->level) = symb.level;    /* assign the level  */
                *(ele_header->dis_att) = symb.display_attr;

                /*
                 * assign element specific attributes
                 */

                ele_header->ele_spec_att.text->font_id = OM_Gw_current_OS;
                ele_header->ele_spec_att.text->flags = 0;
                ele_header->ele_spec_att.text->prev_font = me^^GRtext.attr.font;
                ele_header->ele_spec_att.text->estx->font = me^^GRtext.attr.font;
                ele_header->ele_spec_att.text->estx->just = me^^GRtext.attr.just;
                ele_header->ele_spec_att.text->estx->width = me^^GRtext.attr.width;
                ele_header->ele_spec_att.text->estx->height = me^^GRtext.attr.height;
                ele_header->ele_spec_att.text->estx->flag = me^^GRtext.attr.flag;
                ele_header->ele_spec_att.text->estx->num_char = me^^GRtext.attr.num_char;
                ele_header->ele_spec_att.text->estx->line_spac = me^^GRtext.attr.line_spac;
                ele_header->ele_spec_att.text->estx->char_spac = me^^GRtext.attr.char_spac;
                ele_header->ele_spec_att.text->estx->text_length = me^^GRtext.attr.text_length;
                ele_header->ele_spec_att.text->text_string = (IGRchar *)me^^GRtext.text_string;
            }
            else  /* get symbology failed */
            {
                *msg = MSFAIL;
            }
        }
        else     /* get range failed */
        {
            *msg = MSFAIL;
        }
    }
    else          /* get geometry failed */
    {
        *msg = MSFAIL;
    }

    return (OMreturn);
}

end implementation GRtext;
