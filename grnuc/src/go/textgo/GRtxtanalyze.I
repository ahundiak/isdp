class implementation GRtext;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "grdpb.h"
#include  "csdef.h"
#include  "OMmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "OMerrordef.h" 
#include  "gotextdef.h"
#include  "dpbco.h"
#include  "fontdef.h"
#include  "font.h"
#include  "fontmacros.h"

method GRanalyze_element(IGRlong                *msg;
                         struct GRmd_env        *md_env;
                         FILE                   *rep_file_ptr;
                         enum GRanalyze_types   *analyze_option)
{
    IGRlong		status, long_rc,sizebuf;
    IGRuchar		*text_string;
    struct GRid		my_grid;
    short 		text_length;
    struct 		GRdpb_text_symb text_symb;
    struct 		vfont_entry font_info;

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);
 
    /* print the text */
    status = om$send(msg = message GRtext.GRgettxattr( msg,
						       NULL, &text_length,
						       &text_string),
		     targetid = my_id);
    if ( !(1 & status & *msg) )
       goto wrapup;
 
    fprintf(rep_file_ptr, " Text: ");
    GRanalyze_string(text_string, text_length, rep_file_ptr);
    if ( text_string )
       om$dealloc(ptr = text_string);

    if ( *analyze_option == DETAILED )
    {	
        IGRchar		buffer[80];
        IGRshort	font_num;
	
        font$get_info(msg = &long_rc,
        	      font_num = &ME.GRtext->attr.font,
        	      font_info = &font_info);
  
	fprintf(rep_file_ptr, " Text font : %s \n", font_info.vfontname);
	GRmap_justification(rep_file_ptr, ME.GRtext->attr.just);
        fprintf(rep_file_ptr, " Width : %lf \n", ME.GRtext->attr.width);
        fprintf(rep_file_ptr, " Height : %lf \n", ME.GRtext->attr.height);
	fprintf(rep_file_ptr, " Size :%lf \n", 
	  ME.GRtext->attr.height/ME.GRtext->attr.width);
	if ( me->properties & GRFILLED_DISPLAY )
 	    fprintf(rep_file_ptr, " Fill setting :  On \n");
	else
 	    fprintf(rep_file_ptr, " Fill setting :  Off \n");

	fprintf(rep_file_ptr, " Character spacing setting : %lf\n", ME.GRtext->attr.char_spac);
	fprintf(rep_file_ptr, " Line spacing setting : %lf \n", ME.GRtext->attr.line_spac);

	sizebuf = sizeof(text_symb);
	gr$get_text_symb(msg = &long_rc,
                        sizbuf = &sizebuf,
                        buffer = &text_symb,
                        nret = &long_rc);

	status = COdpb_get_font(buffer,&text_symb.Active_fraction_font, 
	                        CO_frac,CO_attr_to_name);
	fprintf(rep_file_ptr," Fraction font : %s \n", buffer);
	
    }
    return(OM_S_SUCCESS);

wrapup:
    return(status);

}

GRmap_justification( rep_file_ptr, justification)
FILE		*rep_file_ptr;
IGRshort	justification;
{
    switch (justification)
    {

	case 0:
	    fprintf(rep_file_ptr," Justification : Left,bottom\n");
	    break;
	case 1:
	    fprintf(rep_file_ptr," Justification : Left,base\n");
	    break;
	case 2:
	    fprintf(rep_file_ptr," Justification : Left,center\n");
	    break;
	case 3:
	    fprintf(rep_file_ptr," Justification : Left,cap\n");
	    break;
	case 4:
	    fprintf(rep_file_ptr," Justification : Left,top\n");
	    break;
	case 5:
	    fprintf(rep_file_ptr," Justification : Center,bottom\n");
	    break;
	case 6:
	    fprintf(rep_file_ptr," Justification : Center,base\n");
	    break;
	case 7:
	    fprintf(rep_file_ptr," Justification : Center,center\n");
	    break;
	case 8:
	    fprintf(rep_file_ptr," Justification : Center,cap\n");
	    break;
	case 9:
	    fprintf(rep_file_ptr," Justification : Center,top\n");
	    break;
	case 10:
	    fprintf(rep_file_ptr," Justification : Right,bottom\n");
	    break;
	case 11:
	    fprintf(rep_file_ptr," Justification : Right,base\n");
	    break;
	case 12:
	    fprintf(rep_file_ptr," Justification : Right,center\n");
	    break;
	case 13:
	    fprintf(rep_file_ptr," Justification : Right,cap\n");
	    break;
	case 14:
	    fprintf(rep_file_ptr," Justification : Right,top\n");
	    break;
        default:
	    break;
    }
    return(OM_S_SUCCESS);
}

GRanalyze_string(string, text_length, rep_file_ptr)
IGRuchar	*string;
IGRint		text_length;
FILE		*rep_file_ptr;
{
  IGRint 	i;
  IGRdouble     dbl_val;
  IGRshort      loc_font;

  for ( i = 0; i < text_length;)
  {
     if ( string[i] == ESC )
     {
         fprintf(rep_file_ptr,"^");
         switch (string[i+1])
         {
             case 'H':
             case 'J':
             case 'j':
             case 'y':
             case 's':
             case 'v':
             case 'x':
             case 'h':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   i = i + 2 ;
                   memcpy(&dbl_val, &string[i],8);
                   fprintf(rep_file_ptr,",%lf", dbl_val);
                   i = i + 8 ;
                   break;
             case 'w':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   i = i + 2 ;
                   fprintf(rep_file_ptr,"%d,",(IGRuchar)string[i]);
                   i = i + 1 ;
                   break;
             case 'E':
                   fprintf(rep_file_ptr,"%c\n",(IGRuchar)string[i+1]);
                   i = i + 2 ;
                   break;
             case 'F':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   i = i + 2 ;
                   fprintf(rep_file_ptr,"%d,",(IGRuchar)string[i]);
                   i = i + 1 ;
                   fprintf(rep_file_ptr,"%d,",(IGRuchar)string[i]);
                   i = i + 1 ;
                   break;
            case 'M':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   i = i + 2 ;
                   fprintf(rep_file_ptr,"%d,",(IGRuchar)string[i]);
                   i = i + 1 ;
                   fprintf(rep_file_ptr,"%d,",(IGRuchar)string[i]);
                   i = i + 1 ;
                   memcpy(&dbl_val, &string[i],8);
                   fprintf(rep_file_ptr,"%lf", dbl_val);
                   i = i + 8 ;
                   memcpy(&dbl_val, &string[i],8);
                   fprintf(rep_file_ptr,",%lf",dbl_val);
                   i = i + 8 ;
                   break;
            case 'm':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   i = i + 2 ;
                   fprintf(rep_file_ptr,"%d,",(IGRuchar)string[i]);
                   i = i + 1 ;
                   memcpy(&dbl_val, &string[i],8);
                   fprintf(rep_file_ptr,"%lf", dbl_val);
                   i = i + 8 ;
                   memcpy(&dbl_val, &string[i],8);
                   fprintf(rep_file_ptr,",%lf",dbl_val);
                   i = i + 8 ;
                   break;
           case 'f':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   i = i + 2;
                   memcpy(&loc_font,&string[i],2);
                   fprintf(rep_file_ptr,"%d:",loc_font);
                   i = i +  2 ;
                   break;
           case 'p':
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+1]);
                   fprintf(rep_file_ptr,"%c",(IGRuchar)string[i+2]);
                   i = i +  3 ;
                   break;
           default:
                   fprintf(rep_file_ptr,"%d:",(IGRuchar)string[i+1]);
                   i = i + 1 ;
         }
     } else {
         fprintf(rep_file_ptr,"%c:",string[i]);
         i = i + 1 ;
     }
  }
fprintf(rep_file_ptr,"\n");
return(TRUE);
}
end implementation GRtext;
