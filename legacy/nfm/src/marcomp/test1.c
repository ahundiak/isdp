
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
main()
{
FILE *fp1,*fp2;
char str[1024];

fp1 = fopen("marcomp.sco.mk","r");
fp2 = fopen("OUT","w");

while (fgets(str,1024,fp1))
{
	if (strncmp(str,"OSFLAG=-Dsco",12) == 0)
		fprintf(fp2,"OSFLAG=-Dsco -DSUFF -DAD3\n");
	else
		fprintf(fp2,"%s",str);
}
fclose(fp1);
fclose(fp2);
}
		
