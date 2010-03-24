/*
------------------------------------------------------------------------------

	Name:			ddp_tcodes.c      
	Author:			R. Eade
	Creation Date:		December, 1987

	Abstract:
		Defines a list of names corresponding to the types of
		data items.

	Revisions:
				
------------------------------------------------------------------------------
*/
#include "ddp_defns.h"

char *ddp_GA_code_names[MAX_SIZE] = {
	"NULL",
	"CHAR",
	"UCHAR",
	"SHORT",
	"USHORT",
	"INT",
	"UINT",
	"LONG",
	"ULONG",
	"FLOAT",
	"DOUBLE",
	"CHANNEL",
	"POINTER",
	"ARRAY",
	"VARARRAY",
	"BITFIELD",
	"FUNCTION",
	"STRUCT",
	"UNION",
	"ENUMERATION",
	"ENUM_FIELD",
	"CLASS",
	0 };
