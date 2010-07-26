class specification ASsource (0:1) of GRlistener, NDnodein;

/*\
ABSTRACT : This class is the parent class for all the "source" object.
	   AS soon as a regular element is used as root of an associative
	   construction, an header is created in this class or in one of its
           sub class. It is connected to the corresponding graphic element
 	   using the notify channel.

\*/

instance ASsource
 {

/* channel to connect to notify channel of graphic objects  */

  channel { (many_to_many, initial=1, increment=1) } listeners;
 };

/* override Root message */

override  unknown;      /* send the message on the notify channel to the      */
			/* graphic object				      */

/* override GRlistener messages */ 

override GRnotifylis;   /* Listen to the message receive notify channel.      */
		        /* Call nd$wait_batch when the notified message is    */
			/* GRcopy, GRdelete, or modify (GRmodify,GRxform,     */
			/* GRpostabsg,GRputarc,GRputpolyline)                 */


/* override NDnode messages    */

override

	 NDgive_structure, /* returns geometry of object 		      */

	 NDcopy, 	   /* copies and connects source and graphic object   */
	 NDcopy_to_root,   /* Idem 					      */

	 NDconnect,        /* sends NDnode.NDconnect wrt_message              */
			   /* and connect if necessary go to contents         */

	 NDmove_to_root,   /* detach from coordinate system if any 	      */

         NDdelete, 	   /* delete graphic object and source		      */

         NDdisplay, 	   /* display the corresponding graphic object	      */

	 NDcompute_node,   /* does nothing				      */

	 NDprint, 	   /* print definition of object to PPL file with     */
			   /* attachmemt to coordinate system if any          */
	 NDprint_root, 	   /* print definition of object to PPL file without  */
			   /* attachmemt to coordinate system if any          */

         NDsleep, 	   /* if my state is ND_DEL_NO_CH, deletes the source */			   /* element and the graphic object if no children   */		           /*  if neither children */
			   /* nor parents (ref) remain. Does not touch go     */

         ASreturn_go, 	   /* Return Grid of graphic object and identity      */
			   /* matrix as environnement matrix		      */
	 NDupdate,	   /* change symbology if context defined 	      */
	 ACcopy_to_Groot;  /* transform graphic group into ASgroup            */

/* override NDtrans message     */

override NDattach_to_cs,   /* Attach object to contents 		      */
	 NDdetach_from_cs; /* Detach object from contents		      */

/* override NDmacro message     */

override ACreturn_foot; /* pass to the graphic object when this   */
			/* object is able to understand the msg   */


  message GRconstruct(struct GRvg_construct *arglist);

/* ABSTRACT
  construct the associative source object, send the NDplace message to himself
  to initialise associative,  and connect graphic to the source object via the
  channel "notify".

  ARGUMENTS
  IN arglist : usual construction list. In this structure the class_attr field
               is a pointer to a GRas structure described in parametric.h
*/
         
end specification ASsource;
