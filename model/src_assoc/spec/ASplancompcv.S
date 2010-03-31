/*
/*---------------------------------------------------------------------------
/*  ASplancompcv.S
/*  ludovic Le Corvec
/*  10_dec_91
/*
/*  Abstract
/*	New class for planar composite curve.
/*	Objects of this class are in the Rtree instead of its components.
/*	They have a special behaviors with display and plot.
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ASplancompcv (0:0) of AScompcurve;

instance ASplancompcv
{

	IGRchar		select_behav;		/* selector for the object */
						/* behavior		   */
};			

from GRvg inherit	GRaddwrng,
			GRremwrng,
			GRgetprops,
			GRlocate_processing;

override	GRownaddwrng,
		GRownremwrng,
		GRdisyourself,
		GRlocate,
		GRchgprops;

override	NDplace;

override	NDdrawing_copy_geom;

/* ********************************************************************	*/
/*
/*	This two messages are used to manipulate the instances data define
/*	in this class.
/*
/*
/* ********************************************************************	*/

message ASget_selector( IGRlong *msg; IGRint *selector );
message ASset_selector( IGRlong *msg; IGRint selector );


/* ********************************************************************	*/
/*
/*	ASis_visible 
/*
/*	Return the displayble state of the object when it is look in the 
/*	view_vector direction.
/*
/*	*msg		OUT	return code
/*	*mx_type	IN	type of environment matrix
/*	*matrix		IN	environment matrix
/*	*view_vector	IN	3 doubles; view direction
/*	*state		OUT	return state:
/*					TRUE	--> object is visible
/*					FALSE	--> else.
/*
/* ********************************************************************	*/

message ASis_visible( IGRlong *msg; IGRshort *mx_type; IGRdouble *matrix;
					IGRdouble *view_vect; IGRint *state );

end specification ASplancompcv;


