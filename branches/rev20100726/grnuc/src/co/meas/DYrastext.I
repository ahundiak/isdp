/* #######################    APOGEE COMPILED   ######################## */

class implementation Root;

#include "coimport.h"
#include <string.h>
#include "wl.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "exmacros.h"

static struct form_st
  { 
    struct DPele_header          elem;
   };

static  struct display_info
   {
    IGRshort                     num_entries;
    IGRshort                    *offset_array;
    IGRchar                    **string_array;
    IGRint                       font_descr;
   } text_list;

/*-------------------------------------------------------------------
 *
 *
 *-------------------------------------------------------------------
*/
#argsused
IGRint DYrastext(form_data,pnt2,mtx,objects,num_objects,buffers,num_buffers,
                       inflag1,inflag2,inflag3,outflag4,outflag5,outflag6)
  struct form_st     *form_data;
  struct EX_button    *pnt2;
  IGRdouble           *mtx;
  struct GRid         **objects;
  IGRint              *num_objects;
  struct DPele_header **buffers;
  IGRint              *num_buffers;
  IGRchar             *inflag1;
  IGRchar             *inflag2;
  IGRchar             *inflag3;
  IGRint              *outflag4;
  IGRchar             **outflag5;
  IGRchar             **outflag6;
   {
     IGRshort   i;

     int        xdit,ydit;
     int        in_win, key_buttons;

     *outflag4 |= DP_DONT_ERASE;

     WLmouse_position( pnt2->window, &xdit, &ydit, &in_win, &key_buttons );


     WLhide_cursor( pnt2->window, TRUE );

     WLclear_hilite( pnt2->window );

     for( i=0; i<text_list.num_entries; i++)
       {
         WLdraw_text( pnt2->window, xdit+text_list.offset_array[i*2],
                      ydit+text_list.offset_array[i*2+1],
                      text_list.string_array[i],
                      strlen( text_list.string_array[i] ) );
       }

      WLflush( pnt2->window );

     *num_buffers = 0;
      return(MSSUCC);
   }


/*-----------------------------------------------------------------------
 *
 *
 *-----------------------------------------------------------------------
*/ 
IGRlong DYrbrastext( num_entries, offset_array, string_array)

    IGRshort                    *num_entries;
    IGRshort                    *offset_array;
    IGRchar                    **string_array;
 
 {
  struct form_st               form_data;
  struct IGRbsp_curve          bspline;
  struct IGResbc               bsp_ele_spec;
  struct IGRdisplay            dis_attr;
  IGRlong                      msg;          /* return message               */
  IGRboolean                   inq_flag=1;
  IGRboolean                   set_flag=0;
  IGRboolean                   dyn_flag;
  IGRboolean                   turn_on=1;

#if 0
#ifdef X11
  Font                         font_info;
#endif
#define TEXT_FONT "-adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-1"

#ifndef X11
   Load_symbol_file("/usr/ip32/resrc/rfont/drake.10", 
                    &text_list.font_descr);
#else
    font_info = XLoadFont ( EXdisplay,TEXT_FONT );
    XSetFont ( EXdisplay,EXgc[EXenter_screen],font_info);
#endif
#endif

   text_list.num_entries  = *num_entries;

   text_list.offset_array = offset_array;

   if(*num_entries > 1)
    {
      text_list.string_array = string_array;
    }
   else if(*num_entries == 1)
    {
      text_list.string_array = (IGRchar **)&string_array;
    }
   
   dp$build_dis_buffer( buffer = &form_data.elem,
                        type = IGRBC,
                        display_att = &dis_attr,
                        ele_spec_att = (struct IGResbc *)&bsp_ele_spec,
                        geometry = (struct IGRbsp_curve *)&bspline);

   DPdynflags(&msg,&inq_flag,&dyn_flag,NULL);
   if(!dyn_flag)
     {
        DPdynflags(&msg,&set_flag,&turn_on,NULL);
      }

  dp$dynamics(dyn_fun =  DYrastext,
              information = &form_data);
  
  if(!dyn_flag)
    {
      DPdynflags(&msg,&set_flag,&dyn_flag,NULL);
    }
  
  return(1);
}
end implementation Root;
