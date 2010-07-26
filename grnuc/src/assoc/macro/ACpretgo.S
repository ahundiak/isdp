/*
/*---------------------------------------------------------------------------
/*  ACpretgo.S
/*  robert patience
/*  12-12-88
/*
/*  ABSTRACT
/*    The pretgo objects  are used for routing go messages to go
/*   in complexes .
/*---------------------------------------------------------------------------*/

class specification ACpretgo (0:0) of GRnotify,GRconnector;

#include "parametric.h"

instance ACpretgo 
{
  int  index;
  struct GRid *go_ptr;
  struct GRid def_id;
};

/*
override    GRdelete;
*/

override 	GRgetobjinfo,GRgetprops,GRchgprops,GRptproject,GRlnproject,
	GRxform,GRgetrang,GRcopy;

reject	GRlocaldp,GRapprojpt,
	GRlocate,GRlocate_processing,GRdisyourself,
	GRclip,GRcptform,GRdisplay,GRgethprops,GRgentform,
	GRconstruct,GRaltconstruct,GRformatele,GRplotyourself,
	GRaddwrng,GRremwrng,GRcpforundo,GRundocp,
	GRfunction,GRprismrel,GRidchanged,GRlevelcount,
	GRreport,GRreport_defaults,GRupdate_gadgets,GRptprocess,
	GRlnprocess,GRplotprep,GRrcopy;
	
override 	unknown;



message ACplace(int *index);
/*---------------------------------------------------------------------------
/*		This method is used to place an ACpretgo or to change
/* simulated graphic object
/*
/*--------------------------------------------------------------------------*/

message ACset_def(struct GRid *def_id);

message  ACgive_info(struct GRid *go);

message  ACstore_info(struct GRid go);

message  ACload_go_ptr();

message  XYsleep();

end specification ACpretgo;
