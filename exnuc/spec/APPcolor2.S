/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     APPcolor2
        SUBCLASS OF:    Root

        Abstract:  defines the Application color table class

-----
%CD%

        CHANNELS DECLARED:
-----
%MD%

        MESSAGES DECLARED:
-----
%NB%
 
        NOTES:

-----
%CH%

        CHANGE HISTORY

        AET    05/23/88  : Design date.

-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class specification APPcolor2 (1:0) of Root;
#include "igrtypedef.h"

/*   APPcolor2 is the generic object class that applications sub-class*/
/*off of in order to have their set up known.  If there is not such an*/
/*object in the file the default of IGEcolor is used.   */

/*NOTE: We will have this object for these reasons.  A color table will be*/
/*loaded only for the application that the file was created in (otherwise*/
/*we will use a default).  If we provide another object we are just*/
/*receiving the information of how they want the color table set up.  If*/
/*they subclass off of IGEcolor they will be changing the color table and*/
/*we will have to rewrite the methods in a way they can be overwritten. */
/*This will make things more complicated and unflexible in the future. */


   instance APPcolor2
   {
      channel { (one_to_one) IGEcolor2;} to_IGEcolor2;
   };
           
           


  /* MESSAGES */
   
   message get_color_table( IGRshort *cube_dimension; 
      IGRshort *special_size; IGRushort **special_colors;
      IGRdouble *tolerance; IGRdouble *gamma_correction);

end specification APPcolor2;


