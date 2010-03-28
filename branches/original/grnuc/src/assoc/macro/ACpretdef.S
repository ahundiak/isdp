/*
/*---------------------------------------------------------------------------
/*  ACpretdef.S
/*  JL Ardoin
/*  04_Aug-9
/*
/*  ABSTRACT
/*   The pretend objects are used for routing give_structure type messages
/*   in macro definition to the real parent of the occurence
/*---------------------------------------------------------------------------*/
class specification ACpretdef (0:0) of ACpretend;

instance ACpretdef 
{
  struct GRid *map_ptr;
  int index;
};

override ACfind_parent,
	 NDcopy_to_root,
         NDprint,
	 NDsleep;
message ACload_map_ptr();


message ACsconnect(struct stemp *dtemp;int *count);
/*---------------------------------------------------------------------------
/* 		This method is used to symbolicaly connect the pretend
/*	to the temp object. this occurs for a pretend in the definition
/*	each times an occurence is mapped for compute.
/*
/*      Argument description :
/*      ---------------------
/*
/*	struct GRid *temp	I : the object I am going to ask info to.
/*
/*	struct stemp *dtemp	I : the structure containing the downscan.
/*
/*	int *count		I/O : incremented by one.
/*
/*---------------------------------------------------------------------------*/

end specification ACpretdef;
