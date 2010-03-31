
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hssymb_include
#define hssymb_include 1

struct HS_symb
{
    unsigned short   tex_index;
    unsigned char   shad_style;
    unsigned char   tex_orient;
    unsigned char   finish;
    unsigned char   trans;
    unsigned char   diff_refl;
    unsigned char   spec_refl;
    unsigned char   red;
    unsigned char   green;
    unsigned char   blue;
   
};


struct HSbundsymb
{
    IGRint	hs_symb_index; /* index of regular symbology	*/
    IGRint	app_symb_index; /* index of applicatino symb	*/
    IGRint	csw_symb_index; /* index of applicatino symb	*/
};

struct HS_symb_and_app
{
    unsigned short   tex_index;
    unsigned char   shad_style;
    unsigned char   tex_orient;
    unsigned char   finish;
    unsigned char   trans;
    unsigned char   diff_refl;
    unsigned char   spec_refl;
    unsigned char   red;
    unsigned char   green;
    unsigned char   blue;
    int             app_symb_index;
    int             csw_symb_index;
   
};

#endif
