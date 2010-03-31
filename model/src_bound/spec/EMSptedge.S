/*
  ABSTRACT

  This class represents edges as a point in parametric space.

 
  HISTORY

  DLB     07/10/91    Disable tagging.
  SM      14-Oct-87   1.1 Genesis
*/

class specification EMSptedge (1:1) of EMSedge;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSptedge
{
  IGRdouble    point[2];       
};

override	
  GRgraphics;

not_taggable;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgeomattr,
  EMendpts, 
  EMgetrange, 
  EMptatpr, 
  EMpratpt, 
  EMptproject, 
  EMgetpygeom, 
  EMgetgeom, 
  EMgetbcgeom, 
  EMget_bcxyz_geom,
  EMgetedgedef,
  EMisdegentol,
  EMpostgeom;

#ifndef BASE_EMS

message EMpteinit
(
  IGRlong *EMmsg;
  IGRushort props;
  IGRdouble *point;
);
		
override
  EMoffpoint, 
  EMsfintdata,
  debug,
  EMuv_transform, 
  EMdisplay, 
  EMlinintgrl, 		
  EMobint, 		
  EMpt_location, 
  EMgetbounds, 
  EMputpygeom,
  EMedpytrimint, 
  EMtrimyourself, 
  EMextractyourself, 
  EMedbstrimint, 
  EMbstobnd, 
  EMbndtobs;

#endif
	
end specification EMSptedge;
