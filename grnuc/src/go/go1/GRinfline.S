/*
Abstract
	The class GRinfline is the subclass of GRlinear which corresponds
	to a line of infinite length.

Notes 
	None

History	
	MAS     11/12/85 : Design date.

*/

class specification GRinfline (1:1) of GRlinear;

instance GRinfline
{
    IGRchar inf_end;		/* indicator of end(s) considered
			 	 * infinite:
				 *  0 - both ends
				 *  1 - left end (first point)
				 *  2 - right end (second point)
				 *  3 - neither end infinite	*/
};

override GRgetobjinfo, GRcpparallel, GRstretch, GRdisyourself;

reject GRmoveseg,GRinsvertex;
reject GRfragment;


/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRstretch - overridden to allow operation to apply to only the 
	2 defining points

GRcpparallel - overridden to allow operation to apply to only the 
	2 defining points

*/

end specification GRinfline;

