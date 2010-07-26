class specification IGEuserramp (1:0) of Root;

#include "igrtypedef.h"

/*The IGEuserramps object has a single method which will return the values*/
/*of intensities in simulated ramps.  This object is for SIMULATED ramp user*/
/*tables.  You will give the rgb values for each of the intensities in the*/
/*simulated ramp.  The rasterizers will look up the intensity in the array*/
/*and find the 2 intensity "colors" it is between.  Then it will compute the*/
/*relative position of actual intensity in between those 2 intensities*/
/*(colors in ramp) and produce the correct dithered color.  Ems will only*/
/*make use of this object when it encounters FEM shaded contour elements.*/

instance IGEuserramp
{
   channel { (one_to_one) IGEcolor2; } to_IGEcolor2;
};

message get_sim_user_ramp(  IGRint *which_color_ramp;  IGRint *num_shades;  IGRint **packed_shades ); 

end specification IGEuserramp;

