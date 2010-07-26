/*
/*---------------------------------------------------------------------------
/*  ACpretend.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*    The pretend objects  are used for routing give_structure type messages
/*   to complexes that know how to find the desired object 
/*---------------------------------------------------------------------------*/
class specification ACpretend (0:0) of NDnodein;

#include "parametric.h"
#include "macro.h"

instance ACpretend 
{
  variable  char down_scan[2]; 
  int direct_index;
};

/* routed to ACgive_structure using downscan */
override 	NDgive_structure,
		NDcompute_node,
		NDcopy_to_root,
		NDget_state,
		ASreturn_go;

override 	NDprint_root,NDprint;
override 	unknown;

/* concatenates foot_name with my down_scan to ask parents */
/* supported for all graph traversing messages		   */

override 	ACgive_structure,
		ACreturn_foot;
override 	ACconsume,
		ACunconsume;
override	ACbubble_up;

message ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix);

message ACpconnect( IGRint prop; struct GRid father; char *downscan );
/*---------------------------------------------------------------------------
/* 		This method is used to physically connect the pretend
/*	tothe given father. The downscan will be used each times
/*	the pretend wants info from the father.
/*
/*      Argument description :
/*      --------------------
/*
/*	IGRint prop		I : 0 give normal behviour
/*				    1 do a Root.connect instead of NDnode
/*				    this is a much more faster place.
/*
/*	struct GRid father	I : object to connect to as a father
/*
/*	char *downscan		I : "." means father is the one I need
/*				else it must be a feet name of the father
/*
/*---------------------------------------------------------------------------*/

message ACplace(IGRint prop; OM_S_OBJID *list;char *downscan);
/*---------------------------------------------------------------------------
/*		This method is used to place an ACpretend
/*
/*	Argument description:
/*	---------------------
/*
/*	IGRint prop		I : 0 give normal behviour
/*				    1 do a Root.connect instead of NDnode
/*				    this is a much more faster place.
/*
/*	OM_S_OBJID *list	I : the object the pretend will be connected to.
/*				it is a usaly a symbol macro( class ACsym ).
/*
/*     char *downscan		I : the name of the foot that we want to access
/*
/*--------------------------------------------------------------------------*/

message ACgive_downscan(char *downscan);
/*---------------------------------------------------------------------------
/*		This method is used to place an ACpretend
/*
/*	Argument description:
/*	---------------------
/*
/*     char *downscan		O : give the downscan the pretend is representing
/*
/*--------------------------------------------------------------------------*/


message DIgive_output( char *out_s);

/*---------------------------------------------------------------------------
 ABSTRACT

  This message is sent with a "make_message to the expression

  ARGUMENTS

  out_s   I  : The name of the expression
          O  : the name of the expression concatenated with its syntax
/*--------------------------------------------------------------------------*/

message ACrebind(int *msg; struct GRid *old_hdr);

/*---------------------------------------------------------------------------
 ABSTRACT

  This message is sent to the pretend when the hdr is drop.
  It is up to the pretend to
  - rebind to a nested construction if any
  - transform to source and connect to the graphic object

  ARGUMENTS

  msg      OUT :  return code NOT IMPLEMENTED
  old_hdr  IN  :  GRid of the hdr that is droped (probably not necessary) 

/*--------------------------------------------------------------------------*/


end specification ACpretend;
