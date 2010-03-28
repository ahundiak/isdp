/*
/*---------------------------------------------------------------------------
/*  ACconst.S
/*  robert patience
/*  24-auot-89
/*
/*  ABSTRACT
/*  Simplified macro correctly supporting ownership. 
/*  Uses copy_to_root and connect to to_components channel
/*	to retrieve results of compute.
/* 
/*  NAVSEA representation :-
/*    If the macro_name finishes with "$" it is allowed to support
/*   NAVSEA representation. The representations are defined as
/*   different macros supporting the following naming conventions :-
/*	<macro_name>$ext   For ext representation.
/*	<macro_name>$2d    For 2d representation.
/*      <macro_name>$3d    For 3d representation. 
/*      <macro_name>$env   For the interference envelop.
/* When any of these representation are defined the default definition is
/* created. Definition of further representation must support the same
/* template and will any new feet names to the default definition.
/*	Placement of an occurence of the default definition users the
/* appropiate definition to compute the feet. If a default rep cannot
/* be found the $ext is used if this does not exist a <macro_name> is used. 
/*---------------------------------------------------------------------------*/
class specification ACconst (0:0) of ACncpx;


message ACget_foot_in_mac (long *msg;struct GRid my_foot,*mac_foot);
/*************************************************************************/
/*  The support function for bubble up called after bubble_up
/*  has found list of parents.   
/*  
/*     ARGUMENTS
/*	long *msg	I : not used
/*	struct GRid my_foot	I : my foot
/*	struct GRid *mac_foot	O : *mac_foot
/*************************************************************************/



override 	ACconstruct_feet,        /* sets pretends and returns feet */
            ACcontext_compute_feet,  /* compute and copy feet to root  */
    		GRdrop,			         /* place instead associative graph */
            GRdisyourself;           /* create pointers if requested   */
 
/* 
 * Overrides for PDM copy and delete hooks.
 *
 * History: Jay Wallingford 10/15/93 Added override for PDM Hooks.
 */
override    GRdelete,                /* overriden from ASnode     */
            GRcopy,                  /* overriden from ACcpx      */
            GRcptform,               /* overriden from GRgraphics */
            ACdrop,                  /* overriden from AScpx      */
            GRchgname,               /* overriden from ASncpx     */
            GRflexconn;              /* overriden from GRconnector*/

end specification ACconst;
