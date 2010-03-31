#ifndef FImcf_included
#define FImcf_included	1


#include "FIgadget.h"
#include "FIscroll.h"

#define MCF_BEZEL_WIDTH	 	2

extern int  _FI_mcf_activate();			/** In mcf.c        **/
extern int  _FI_mcf_adjust();			/** In mcf.c        **/
extern void _FI_mcf_adjust_xhi();		/** In mcf.c        **/
extern void _FI_mcf_adjust_cols();		/** In mcf.c        **/
extern void _FI_mcf_disable();			/** In mcf.c        **/
extern int  _FI_mcf_display();			/** In mcf.c        **/
extern void _FI_mcf_enable();			/** In mcf.c        **/
extern int  _FI_mcf_erase();			/** In mcf.c        **/
extern int  _FI_mcf_find_gadget();		/** In mcf.c        **/
extern void _FI_mcf_get_active_col();		/** In mcf.c        **/
extern void _FI_mcf_hilite();			/** In mcf.c        **/
extern void _FI_mcf_load();			/** In mcf.c        **/
extern void _FI_mcf_refresh_data();		/** In mcf.c        **/
extern void _FI_mcf_set_active_col();		/** In mcf.c        **/
extern void _FI_mcf_set_active_row();		/** In mcf.c        **/
extern void _FI_mcf_set_color();		/** In mcf.c        **/
extern void _FI_mcf_unhilite();			/** In mcf.c        **/
extern void _FI_mcf_un_select_all();		/** In mcf.c        **/

extern void _FI_mcf_add_hsrcl();		/** In mcfScrlTrk.c **/
extern void _FI_mcf_add_vsrcl();		/** In mcfScrlTrk.c **/
extern int  _FI_mcf_hsrcl();			/** In mcfScrlTrk.c **/
extern void _FI_mcf_set_hsrcl();		/** In mcfScrlTrk.c **/
extern void _FI_mcf_set_vsrcl();		/** In mcfScrlTrk.c **/
extern int  _FI_mcf_track_keyboard();		/** In mcfScrlTrk.c **/
extern int  _FI_mcf_track_kbd();		/** In mcfScrlTrk.c **/
extern int  _FI_mcf_track_mouse();		/** In mcfScrlTrk.c **/
extern void _FI_mcf_vsrcl();			/** In mcfScrlTrk.c **/


struct FI_mcf_flags
{
  unsigned int uds :1;		  /* up/down scrolling		 */
  unsigned int lrs :1;		  /* left/right scrolling	 */
  unsigned int draw_vscrl :1;	  /* draw vert scroll bar	 */
  unsigned int draw_hscrl :1;	  /* draw hort scroll bar	 */
  unsigned int disable_vscrl :1;  /* disable vert scroll bar	 */
  unsigned int disable_hscrl :1;  /* disable hort scroll bar	 */
  unsigned int row_select:1;	  /* row select vs. cell select  */
  unsigned int no_row_buttons:1;  /* Whether to draw row buttons */
                                  /* sml:09-10-93                */
                                  /* Code from Randy Hopper of   */
                                  /* Federal Systems             */
  unsigned int break_nav:1;       /* Use this instead of global  */
                                  /* variable to eliminate       */
                                  /* conflicts between MCFs.     */
                                  /* It determines whether to    */
                                  /* break of MCF event loop     */
};


struct FImcf_instance
{
  unsigned short   ncol;	/* # of columns			 */
  unsigned short   nvcol;	/* current # of visible columns	 */
  unsigned short   col_off;	/* col display offset		 */

  struct FIscrl_obj *vscrl_id;	/* vertical scroll bar obj ptr	 */
  struct FIscrl_obj *hscrl_id;	/* horizontal scroll bar obj ptr */

  struct FI_mcf_flags flags;	/* mcfield flags		 */
};


struct FImcf_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIgroup_instance	FIgroup;
  struct FImcf_instance		FImcf;
};


#endif
