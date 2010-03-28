/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

class implementation COcpattr;

#include "coimport.h"
#include "COcpattrdef.h"
#include "COerr.h"

from GRvg	import GRchglevel, GRchgcolor, GRchgweight, GRchgstyle, GRgetsymb;
from GRgraphics import GRdisplay;
from GRtext     import GRchgtextattr, GRgettxattr;

/*\
Abstract
     
     This method gets the symbology and text attributes from a located
     graphic object.

History

	Jay Wallingford           12/21/87  Design and Implementation.

\*/

method get_symb ()
{
     /* returned symbology structure */
     struct GRsymbology  symb;
     struct IGRestx      text_attr;
     struct GRmd_env     path;          /* Work space for gr$pass macro. */

     /* misc flags and macro arguments */
     IGRlong   ok, msg_ok;
     IGRlong   status;
     
     me->ret = OM_S_SUCCESS;

     /*
      * Get the symbology from the element.
      */
     status = gr$gspass( msg = &msg_ok,
                         pass_msg = message GRvg.GRgetsymb( &ok, &symb ),
                         path = NULL,
                         p_chanselect = &me->located_chansel);

     _error_ck2(status, msg_ok, &me->ret);                 
     _error_ck(ok, &me->ret);

     /*
      * Assign the appropriate symbologies to CS_symb.
      */
     if ( _active(LyTog) ) me->CS_symb.level = symb.level;
     if ( _active(CoTog) ) me->CS_symb.display_attr.color = symb.display_attr.color;
     if ( _active(WtTog) ) me->CS_symb.display_attr.weight = symb.display_attr.weight;
     if ( _active(StTog) ) me->CS_symb.display_attr.style = symb.display_attr.style;

     /*
      * If the active form is the text form.
      */
     if ( me->mytype == COPYTXSYMB )
     {

          /*
           * Get the text symbology from the element.
           */
          status = gr$gspass( msg = &msg_ok,
                              pass_msg = message GRtext.GRgettxattr( &ok, &text_attr, 
                                                                     NULL, NULL ),
                              path = &path,
                              p_chanselect = &me->located_chansel);

          _error_ck2(status, msg_ok, &me->ret);                 
          _error_ck(ok, &me->ret);

          /*
           * Assign the appropriate text symbology to CS_symb.
           */
          if ( _active(FtTog) ) me->CS_text.Active_font = text_attr.font;
          if ( _active(TjTog) ) me->CS_text.Active_just = text_attr.just;
          if ( _active(WdTog) ) me->CS_text.Active_width = text_attr.width;
          if ( _active(HtTog) ) me->CS_text.Active_height = text_attr.height;
          if ( _active(CsTog) ) me->CS_text.Active_charspac = text_attr.char_spac;
          if ( _active(LsTog) ) me->CS_text.Active_linespac = text_attr.line_spac;
     }

quit:
     return status;
}

/*\
Abstract
     
     This method changes the symbology and text attributes for located
     graphic object(s) according to the mask me->CS_mask.

History

	Jay Wallingford           12/21/87  Design and Implementation.

\*/

method copy_symb ()
{
     /* 
      * NOTE: At present to change specific graphic object symbology a symbology
      *       specific message must be sent to the graphic object for every parameter 
      *       that needs changing. In the future this may change with the introduction 
      *       of a general change symbology message with a mask indicating the symbology 
      *       to be changed.
      */
          
     /* misc flags and macro arguments */
     IGRlong             ok;
     IGRlong             status;
     enum GRdpmode       display_mode; 
     struct GRmd_env     path;          /* Work space for gr$pass macro. */
     unsigned IGRint     mask=0;
     OM_S_OBJID          id;            
     IGRint              i;

     me->ret = OM_S_SUCCESS;
     
     /* 
      * Erase the located object(s).
      */
     display_mode = GRbe;
     status = gr$gsdisplay ( msg = &ok, 
                             dpmode = display_mode,
                             display_id = &me->ModuleInfo.md_id,
                             p_chanselect = &me->located_chansel);

     _error_ck2(status, ok, &me->ret);
     

     /* 
      * Change the located object(s) symbology according to the copy 
      * symbology mask.
      */
     if ( _active(LyTog) )
     {
          status = gr$gspass (msg = &ok,
                              pass_msg = message GRvg.GRchglevel( &ok, &me->CS_symb.level),
                              path = NULL,
                              p_chanselect = &me->located_chansel);
          _error_ck2(status, ok, &me->ret);
     }

     if ( _active(CoTog) ) 
     {
          status = gr$gspass (msg = &ok,
                              pass_msg = message GRvg.GRchgcolor( &ok,
                                        0,
					&me->CS_symb.display_attr.color),
                              path = NULL,
                              p_chanselect = &me->located_chansel);
          _error_ck2(status, ok, &me->ret);

     }

     if ( _active(WtTog) ) 
     {
          status = gr$gspass (msg = &ok,
                              pass_msg = message GRvg.GRchgweight( &ok, 
                                        &me->CS_symb.display_attr.weight),
                              path = NULL,
                              p_chanselect = &me->located_chansel);
          _error_ck2(status, ok, &me->ret);
     }

     if ( _active(StTog) ) 
     {
          status = gr$gspass (msg = &ok,
                              pass_msg = message GRvg.GRchgstyle ( &ok, 
                                        &me->CS_symb.display_attr.style),
                              path = NULL,
                              p_chanselect = &me->located_chansel);
          _error_ck2(status, ok, &me->ret);
     }
     
     if ( me->mytype == COPYTXSYMB )
     {
          /* 
           * Change the text's symbology according to CS_mask.
           */
          if ( _active(FtTog) ) mask |= GRTEXT_FONT;
          if ( _active(TjTog) ) mask |= GRTEXT_JUST;
          if ( _active(HtTog) ) mask |= GRTEXT_HEIGHT;
          if ( _active(WdTog) ) mask |= GRTEXT_WIDTH;
          if ( _active(CsTog) ) mask |= GRTEXT_CHAR_SP;
          if ( _active(LsTog) ) mask |= GRTEXT_LN_SP;

          if (mask) {
               status = gr$gspass (msg = &ok,
                                   pass_msg = message GRtext.GRchgtextattr( 
                                                  &ok, 
                                                  &path,
                                                  mask,
                                                  &me->CS_text),
                                   path = &path,
                                   p_chanselect = &me->located_chansel);
               _error_ck2(status, ok, &me->ret);
          }          
     }

     /* 
      * Redisplay the located object(s) so it(they) will reflect any 
      * symbology changes.
      */
     display_mode = GRbd;
     status = gr$gsdisplay ( msg = &ok, 
                             dpmode = display_mode,
                             display_id = &me->ModuleInfo.md_id,
                             p_chanselect = &me->located_chansel);

     _error_ck2(status, ok, &me->ret);
                       
quit:
     return    status;
}                 

/*\
Abstract
     
     This method pushes the last data point onto the input queue.

\*/

method push_accept_pt ()
{
     IGRlong ok;
     IGRlong buffersize;

     buffersize = sizeof(struct GRevent) - ( 2 * sizeof(IGRlong) );
     ex$putque( msg = &ok,
                response = me->response,
                byte = &buffersize,
                buffer = &me->event1.event);

quit:
     return ok;
}

end implementation COcpattr;

