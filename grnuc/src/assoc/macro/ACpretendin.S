/*
/*---------------------------------------------------------------------------
/*  ACpretendin.S
/*
/*  ABSTRACT
/*    The pretend objects  are used for routing ACCROSS reference files
/*    give_structure type messages to complexes that know how to find the
/*    desired object 
/*---------------------------------------------------------------------------*/
class specification ACpretendin (0:0) of ASsourcein,ACpretend;


reject 		NDprint,
		ACpconnect,
		ACrebind;


override        NDcompute_node,
		ACfind_parent,
		ACconsume,
		ACunconsume;


message ACiconnect(IGRint prop;
		   struct GRid father,context;
		   char *down_scan);

end specification ACpretendin;
