class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimlinear.h"
#include "griodef.h"
#include "griomacros.h"

#argsused
print_grid_info (name,
                 grid)
      /*(
	 char  *name,
	 struct GRid  grid
	)
*/
char *name;
struct GRid grid;
/*.print_grid_info*/
{
	/*^
	{
		IGRint status;
		IGRchar classname[OM_K_MAXCLASS_LEN];

		status =
		om$get_classname(
			objid = grid.objid,
			osnum = grid.osnum,
			classname = classname);
		dm$status(action = RET_STATUS);

		printf("%s (%s) = %d, %d\n",
			name, classname, grid.objid, grid.osnum);
	}
	*/
        return(TRUE);
}

analyse_string (string,
		text_length)
	 IGRuchar  *string;
	 int  text_length;
/*.analyse_string*/
{
	int i;
	double dbl_val;
	short loc_font;
	printf("Analyse String:\n");	
	for( i = 0 ; i< text_length;)
	{
		if( string[i] == ESC )
		{
			printf("^");
		switch(string[i+1])
		{
		case 'H':
		case 'J':
		case 'j':
		case 'y':
		case 's':
		case 'v':
		case 'x':
		case 'h':
			   printf("%c",(IGRuchar)string[i+1]);
			   i = i + 2 ;
			   memcpy(&dbl_val, &string[i],8);
			   printf(",%lf@", dbl_val);
			   i = i + 8 ;
			   break;
		case 'w':
			   printf("%c",(IGRuchar)string[i+1]);
			   i = i + 2 ;
			   printf("%d,",(IGRuchar)string[i]);
			   i = i + 1 ;
			   break;
		case 'E':
			   printf("%c\n",(IGRuchar)string[i+1]);
			   i = i + 2 ;
			   break;
		case 'F':
			   printf("%c",(IGRuchar)string[i+1]);
			   i = i + 2 ;
			   printf("%d,",(IGRuchar)string[i]);
			   i = i + 1 ;
			   printf("%d,",(IGRuchar)string[i]);
			   i = i + 1 ;
			   break;
		case 'M':
			   printf("%c",(IGRuchar)string[i+1]);
			   i = i + 2 ;
			   printf("%d,",(IGRuchar)string[i]);
			   i = i + 1 ;
			   printf("%d,",(IGRuchar)string[i]);
			   i = i + 1 ;
			   memcpy(&dbl_val, &string[i],8);
			   printf("%lf@", dbl_val);
			   i = i + 8 ;
			   memcpy(&dbl_val, &string[i],8);
			   printf(",%lf@",dbl_val);
			   i = i + 8 ;
			   break;
		case 'm':
			   printf("%c",(IGRuchar)string[i+1]);
			   i = i + 2 ;
			   printf("%d,",(IGRuchar)string[i]);
			   i = i + 1 ;
			   memcpy(&dbl_val, &string[i],8);
			   printf("%lf@", dbl_val);
			   i = i + 8 ;
			   memcpy(&dbl_val, &string[i],8);
			   printf(",%lf@",dbl_val);
			   i = i + 8 ;
			   break;

		case 'f':
			   printf("%c",(IGRuchar)string[i+1]);
			   i = i + 2;
			   memcpy(&loc_font,&string[i],2);
			   printf("%d:",loc_font);
			   i = i +  2 ;
			   break;
		case 'p':
			   printf("%c",(IGRuchar)string[i+1]);
			   printf("%c",(IGRuchar)string[i+2]);
			   i = i +  3 ;
			   break;

		default: 
			   printf("%d:",(IGRuchar)string[i+1]);
			   i = i + 1 ;
		}
	    }
	    else
	    {
		   printf("%c:",string[i]);
		   i = i + 1 ;
	    }
	}
	printf("End of Analyse String\n");
	return(TRUE);
}

end implementation DMroot;

