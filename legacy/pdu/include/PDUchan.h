#ifndef PDMchan
#define PDMchan 	1


/* PDM channel declaration */
channel	owner_member
	{
	(rel_ordered,many_to_many,initial=20,increment=10)
	};

#endif

