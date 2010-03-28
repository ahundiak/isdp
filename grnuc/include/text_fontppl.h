#ifndef textppl_include
#define textppl_include

#include "ciminimum.h"
#include "cimacros.h"
#include "cisend.h"
#include "exdef.h"
#include "exmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "cotxmacros.h"

#include "fontdef.h"

extern int GRget_font_info();
extern int GRstrip_esc_sequences();
extern int EX_get_super();
extern int EX_findmod();

#define get_font_manager(mod_id,font_mgr) \
{ \
\
	ex$get_cur_mod(id = &mod_id.objid, \
                      osnum = &mod_id.osnum); \
	ex$get_super(mod_id = mod_id.objid, \
		mod_osnum = mod_id.osnum, \
		super_name = FONTMGR_NO_NAME, \
		create = TRUE, \
		super_class = "GRfm", \
		super_id = &font_mgr.objid, \
		super_osnum = &font_mgr.osnum); \
\
}

/*  
Abstract
   This macro will change the text specific attributes of a text string 

Arguments
   *ret_msg	IGRlong		O 	Return Code
						   MSSUCC - successful
						   MSFAIL - error
   *module_env  struct GRmd_env	I	the enviorment information
   *text_id	struct GRid	I	the text object id, osnum
   attr_bit_mask IGRint		I	bit mask of attributes to change 
					   (defined in gotextdef.h)
					GRTEXT_FONT
					GRTEXT_JUST
					GRTEXT_LN_SP 
					GRTEXT_CHAR_SP 
					GRTEXT_HEIGHT
					GRTEXT_WIDTH
   *text_symb	struct GRdpb_text_symb
				I	text symbology structure containing
					attributes to change

   Only selected fields in the GRdpb_text_symb structure are used by
this macro. The fields along with the appropriate bit mask #define
from gotextdef.h are listed below.

   GRTEXT_FONT		  	Active_font  (specify the font index)
   GRTEXT_JUST	  	        Active_just
   GRTEXT_WIDTH			Active_width
   GRTEXT_HEIGHT	    	Active_height
   GRTEXT_CHAR_SP		Active_charspac
   GRTEXT_LN_SP			Active_linespac

*/

#omdef gr$chg_text_attr
		(ret_msg,
		 module_env,
		 text_id,
		 attr_bit_mask,
		 text_symb)
{
	ci$send(
	   msg=message GRtext.GRchgtextattr
		(ret_msg,module_env,attr_bit_mask,text_symb),
	   targetid=(text_id)->objid,
	   targetos=(text_id)->osnum);
}
#endomdef
 
/*
Abstract
   This macro will get the text specific attributes of a text object

Arguments
   *ret_msg	IGRlong		O 	Return Code
						   MSSUCC - successful
						   MSFAIL - error
   *text_id	struct GRid	I	the text object id, osnum
   remove_esc	IGRint		I	indicator of whether text
				          string should include escape 
					  sequences, 
					     0 - string has escape
						 sequences included 
						 (default)
					     1 - string has escape
						 sequences removed.
   *text_attr   struct IGRestx	O	the text specific attributes
					   (if NULL pointer, attributes
					    are not returned)
   *text_length   IGRshort	O       length of the text string in bytes
					   (if NULL pointer, length is not 
					    returned)
   **text_string  IGRchar	O	the text string (caller must 
					deallocate the memory) There
					is no null terminator on this 
					text string.
Notes:
   If you specify that you want escape sequences removed the
text_length variable will specify the new length but the text_attr
structure will still reflect the information about the string with
the escape sequences.

   There is no null terminator on the text string.

*/



struct IGRestx tmp_text_attr, *tmp_text_attr_ptr;
short	tmp_text_length;
struct GRid font_mgr;
struct vfont_entry font_info;
struct GRid mod_id;



#omdef gr$get_text_attr
		(ret_msg,
		 text_id,
		 remove_esc=0,
		 text_attr = 0,
		 text_length = 0,
		 text_string)
{

 
   *(ret_msg)=MSFAIL;

   tmp_text_attr_ptr=text_attr;

#   if (om$specified(remove_esc) && (! om$specified(text_attr)))
    {
        tmp_text_attr_ptr = &tmp_text_attr;
    }
#   endif

    ci$send( msg=message GRtext.GRgettxattr
		(ret_msg,tmp_text_attr_ptr,&tmp_text_length,(text_string)),
	   targetid=(text_id)->objid,
	   targetos=(text_id)->osnum);

    if ( 1 & *(ret_msg))
    {
#	if (om$specified(remove_esc) && om$equal(remove_esc,1))
	{
	    get_font_manager(mod_id,font_mgr)

	    font$get_info(msg=(ret_msg),
	  	font_num = &tmp_text_attr_ptr->font,
		fontmgr = &font_mgr,
		font_info = &font_info);

	    if ( 1 & *(ret_msg))
	    {
	    	co$rm_esc_seqs(msg=(ret_msg),
			font_num = tmp_text_attr_ptr->font,
			font_flags = font_info.flags,
			text_string = *(text_string),
	 	   	text_length = &tmp_text_length);

	     }
	}
#	endif

#	if (om$specified(text_length))
 	{
	    *(text_length)=tmp_text_length;
	}
#	endif
    }
}
#endomdef

/*
Abstract
     This routine searches the virtual font library for a specified
     virtual font name or number and returns the name or position 
     of the virtual font. 

Arguments
    *ret_msg       IGRlong           O  completion code
                                         MSSUCC  - successful
                                         MSFAIL  - failure (font not found)
                                         MSINARG - invalid virtual font number
    *vfont_name    IGRuchar          I/O  virtual font name (allow for
					    256 characters for output)
    *vfont_number  IGRshort          I/O  virtual font number
 					- initialize input variable 
					  to -1 if vfont_name is
					  input and you are searching 
					  for the virtual font number

*/

#omdef gr$font_virt_search(ret_msg,
		vfont_name,
		vfont_number)
{
       get_font_manager(mod_id,font_mgr);

       ci$send(msg=message GRfm.GRvirt_search(ret_msg,vfont_name,vfont_number),
		targetid= font_mgr.objid,
		targetos= font_mgr.osnum);
}
#endomdef

/*
Abstract
     This routine searches the virtual font library for a
     specified physical font. If the specified font is found,
     its virtual font name will be returned.

Arguments
    *ret_msg          IGRlong      O  completion code
                                       MSSUCC  - if successful
                                       MSFAIL  - if failure 
						(font not found)
    *fontfile     IGRuchar I  font file name
    *vfont_name   IGRuchar O  virtual font name, size of the
				         array is 256 characters
*/

#omdef gr$font_phy_search(ret_msg,
		font_file,
		virt_font_name)
{
       get_font_manager(mod_id,font_mgr);

       ci$send(msg=message GRfm.GRphy_search(ret_msg,font_file,virt_font_name),
		targetid= font_mgr.objid,
		targetos= font_mgr.osnum);
}
#endomdef

#endif
