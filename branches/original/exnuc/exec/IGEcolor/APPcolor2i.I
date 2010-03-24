/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/

class implementation APPcolor2;

method get_color_table( IGRshort *cube_dimension; IGRshort *special_size;
   IGRushort **special_colors; IGRdouble *tolerance; IGRdouble *gamma_correction)
{
   *cube_dimension = 0x7FFF;
   *special_size = 0;
   *special_colors = (IGRushort *) NULL;
   tolerance[0] = 0.01;
   gamma_correction[0] = 2.2;
   gamma_correction[1] = 2.2;
   gamma_correction[2] = 2.2;
   
   return(1);
}

end implementation APPcolor2;
