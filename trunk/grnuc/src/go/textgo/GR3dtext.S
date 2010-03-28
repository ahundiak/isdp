/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP%  CODE CLASSIFICATION                           
----
%HD%

      CLASS NAME:	GR3dtext

      SUBCLASS OF:	GRtext

-----
%CD%

      CHANNELS DECLARED:	
			none.
-----
%MD%

      MESSAGES DECLARED:
			none.

      METHODS OVERRIDDEN:
			 GRgetrang
			 GRgenabsg
			 GRpostabsg
			 GRclipto

-----
%NB%

      NOTES:
-----
%CH%

      CHANGE HISTORY:
	
	SDG	3/25/86:   Creation date.
        SCW    07/21/92:   removed copyright header
-----
%PD%
--------------------------------------------------------------------
                 C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

	The class GR3dtext is a subclass of GRtext and is a 
	3-D double precision representation of text.

----*/
/*EH*/

class specification GR3dtext (1:0) of GRtext;

/* 
 * Instance data defined for the GR3dtext subclass.
 */

instance GR3dtext		/* 3-D double object	*/
{
 struct				/* text geometry	*/
 {
    IGRdouble matrix[9];	/* transformation matrix*/
				/* from local to world  */
    IGRdouble origin[3];	/* origin of text	*/
    IGRdouble diag_pt1[2];	/* range block diagonal */
				/* point one (local)	*/
    IGRdouble diag_pt2[2];	/* range block diagonal */
				/* point two (local)	*/
 } geom;			/* text geometry	*/
};

/* 
 * Method declarations for the GR3dtext subclass.
 */

/* override GRgetrang, GRclipto; */

override GRpostabsg, GRgenabsg;

end specification GR3dtext;
