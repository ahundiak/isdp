	

class specification ASdelseg (0:1) of ASmodlin;

/*\
   ABSTRACT : 
              The ASdelseg class is the class of associative partial delete 
	      of a line.

	      These object has 3 roots :
	      - the line to be partially deleted 
	      - 2 points defining the area to delete

   NOTE This class may disappear in the near future. Therefore, yuo are
        encouraged to use the ASmodbsp class, which performs the same function
	on general b_spline.


   HISTORY :
	jla     21-jan-87 : Design date
\*/

 override GRvg;
 override NDplace;

/*\ OVERRIDE MOTIVATION

      NDplace : initialize the specific instance inherit from ASmodlin to 
                partial delete (typ_mod and par_mod) and call the
	 	ASmodlin.place method with respect to message.
\*/


end specification ASdelseg;
