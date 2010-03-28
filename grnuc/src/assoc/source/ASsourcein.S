/*
 ABSTACT:

  When a graphic object is used as a root of an associative construction
  and if the graphic object is in a reference file, a header object of this
  class is created.
*/

class specification ASsourcein (0:1) of ASsource;

#define AC_CONSUMED 0x100       /* my object in the reference file is consumed*/

override NDgive_structure, /* Return the structure of the object	*/
         ASreturn_go,      /* return graphic object and matrix          */
	 NDdisplay, 	   /* Display the graphic object connected via  */
                           /* the notify channel		    	*/
	 NDdelete,	   /* delete the object				*/
	 GRconstruct,	   /* Construct the object and perform the 	*/
			   /* connection to the graphic object		*/
	 GRnotifylis,      /* to trigger batch update across ref. file  */
         ACconsume,
         ACunconsume,
         ACtest_consumed,
	 NDcompute_node;



reject unknown,
       NDattach_to_cs,   
       NDdetach_from_cs; 


end specification ASsourcein;
