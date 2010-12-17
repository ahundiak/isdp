#ifndef FImcf_included
#define FImcf_included	1


/*
#define MCF_BEZEL_WIDTH     2

   Had to change this because of Jeff's changes to box_size.
        GMD 4/3/91
*/

#define MCF_BEZEL_WIDTH     3

struct FI_mcf_flags
{
  unsigned int uds :1;		      /* up/down scrolling	      */
  unsigned int lrs :1;		      /* left/right scrolling	      */
  unsigned int draw_vscrl :1;	      /* draw vert scroll bar	      */
  unsigned int draw_hscrl :1;	      /* draw hort scroll bar	      */

  unsigned int disable_vscrl :1;      /* disable vert scroll bar      */
  unsigned int disable_hscrl :1;      /* disable hort scroll bar      */
  unsigned int row_select:1;	      /* row select vs. cell select   */
  unsigned int no_row_buttons:1;      /* Whether to draw row buttons  */
};


#define FI_MCF_UDS              0x001
#define FI_MCF_LRS              0x002
#define FI_MCF_DRAW_VSCRL       0x004
#define FI_MCF_DRAW_HSCRL       0x008
#define FI_MCF_DISABLE_VSCRL    0x010
#define FI_MCF_DISABLE_HSCRL    0x020
#define FI_MCF_ROW_SELECT       0x040
#define FI_MCF_NO_ROW_BUTTONS   0x080


struct FImcf_instance
{
  unsigned short   ncol;	    /* # of columns		      */
  unsigned short   nvcol;	    /* current # of visible columns   */
  unsigned short   col_off;	    /* col display offset	      */

  struct FIscrl_obj *vscrl_id;	    /* vertical scroll bar obj ptr    */
  struct FIscrl_obj *hscrl_id;	    /* horizontal scroll bar obj ptr  */

  struct FI_mcf_flags flags;	    /* mcfield flags		      */
  struct FI_mcf_flags def_flags;    /* default mcfield flags	      */
};


struct FImcf_obj
{
  struct FIgadget_instance FIgadget;
  struct FIgroup_instance  FIgroup;
  struct FImcf_instance    FImcf;
};


#endif
