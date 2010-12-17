#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "MRPmacros.h"
#include "MRPgadlabs.h"
#include "MRPstr.h"
#include "MRPmessage.h"
#include "PDUstr.h"
#include "PDUproto.h"
#include "MRPintdef.h"


extern struct MRPvar *mrpvar;
extern void pcat_notify_routine();

/****************************************************************************

Document:	MRPdyn_text

Description:	Dynamically places text on a given form in a given position
		with a given font, size, and color.

Algorithm:

Return Status:	None

History:	10/1/90	Lynn Mettlen    Created

*****************************************************************************/

void MRPdyn_text( x_start_pos, y_start_pos, body_size, mrp_form_id, text_string, glabel, color)
int x_start_pos;
int y_start_pos;
int body_size;
Form mrp_form_id;
char *text_string;
int glabel;
char color;
{
struct standard_st std_var;
int sts;


 /*** Create text gadget  ***/
 sts = FIg_new( mrp_form_id, FI_TEXT, glabel);


 /*** Set up the standard characteristics of the checklist gadget ***/
 MRPdyn_gadget_init(&std_var);
 std_var.xlo = x_start_pos;
 std_var.ylo = y_start_pos + 50 ;
 std_var.bodysize = body_size;

 /*** Get text from buffer keyed from count ***/
/* d  strcpy (checktext, string_buffer[count]); */
/* d  sprintf(checktext, "Part %d", count); */
 std_var.text = text_string;
 std_var.attr_mask = FI_TEXT_GADGET;

 std_var.fontname = "swiss742b";
 std_var.off_color = color;

 /*** Implement those characteristics ***/
 sts = FIg_set_standard_variables ( mrp_form_id, glabel, &std_var );

 /*** Let the forms system preload the needed fonts ***/
 sts = FIg_activate ( mrp_form_id, glabel );

 sts = FIg_display ( mrp_form_id, glabel );
}


/****************************************************************************

Document:	MRPdyn_rect

Description:	Dynamically creates a rectangle with a given size and color.

Algorithm:

Return Status:

History:	10/1/90	Lynn Mettlen    Created

*****************************************************************************/
void MRPdyn_rect( x_lo_pos, y_lo_pos, x_hi_pos, y_hi_pos, mrp_form_id, glabel, color)
int x_lo_pos;
int y_lo_pos;
int x_hi_pos;
int y_hi_pos;
Form mrp_form_id;
int glabel;
char color;
{
struct standard_st std_var;
int sts;


 /*** Create text gadget  ***/
 sts = FIg_new( mrp_form_id, FI_RECT, glabel);


 /*** Set up the standard characteristics of the checklist gadget ***/
 MRPdyn_gadget_init(&std_var);
 std_var.xlo = x_lo_pos;
 std_var.ylo = y_lo_pos + 50;
 std_var.xhi = x_hi_pos;
 std_var.yhi = y_hi_pos + 50;

 std_var.off_color = color;

 /*** Implement those characteristics ***/
 sts = FIg_set_standard_variables ( mrp_form_id, glabel, &std_var );

 /*** 2D line for rectangle ***/
 sts = FIg_set_line_depth ( mrp_form_id, glabel, FI_2D_LINE  );

 /*** Implement those characteristics ***/
/* sts = FIg_set_line_style ( mrp_form_id, glabel, 1 ); */

 /*** Implement those characteristics ***/
/* sts = FIg_set_line_weight ( mrp_form_id, glabel, 2 ); */

 /*** Let the forms system preload the needed fonts ***/
/* sts = FIg_activate ( mrp_form_id, glabel ); */

 sts = FIg_display ( mrp_form_id, glabel );
}

