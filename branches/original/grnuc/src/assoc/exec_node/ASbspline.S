

class specification ASbspline (0:1) of GRbspline, ASnode;

/*
   This is an abstract associative class which corresponds to the
   GRbspline graphics class. It is subclassed from ASnode and GRbspline
   because it needs to know the graph management method and GRgraphics
   method override provided by ASnode as well as the graphic methods
   provided by GRbspline.
   
 */

  override GRvg;

  override GRptseqspace,GRptalong,GRmidpoint,GRcenter,GRendpts,
	   GRperbis,GRinsvertex,GRdelvertex,GR2ptpartdel,GR3ptpartdel,GRarea,
	   GRarclength,GRptextend,GRdisextend,GRsplit,GRcpparallel,
	   GRrevparm,EMcvradcrv, EMcvtanorm,EMcvoffset,EMpartofcv,EMcrvcrvint,
	   EMcrvslfint;

/*
 * override GRcurve methods to perform additionnal operation
 */

   override GRendpts;     /*  when partial delete or extends */

/*
 * message of GRcurve not overriden

 GRendpoint : GRcurve method send a GRendpts and search the nearest.

 */
   

/*
 * override GRbspline methods just to send back the
 * message to the graphic object via complex channel
 */

  override EMbctobz,EMgetbcdef;

/* override GRchgprops method to check if a symbology override is being placed
 * on the element; if it is, place the symbology override on the component
 * element; this was done to fix TR#119301281
 */

  override GRchgprops;

/* override GRget_locate_properties method to specify the the components of
 * these owners can be located for read only operations
 */

  override GRget_locate_properties;

end specification ASbspline;
