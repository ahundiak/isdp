#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdarg.h>
#include <errno.h>
#include <memory.h>
#include <malloc.h>

char    MultiTokenSeparator[16]={"\t"};
extern	long	DSdebug;

void	Old_Get_Multiple_Tokens(char *String, ...)
{
        va_list ap;
        char    *args[2], *token, *dup;
	long	count;
	count = 0;        va_start(ap,String);	args[0] = String;	if (strcmp(args[0],"") == 0)    return;
	dup = (char *)strdup(args[0]);	args[1] = va_arg(ap,char *);
	if (args[1] != (char *)NULL)
		{
		strcpy(args[1],strtok(dup,MultiTokenSeparator));
		while ((args[1] = va_arg(ap,char *)) != (char *)NULL)
			{
			if ( (token=strtok((char *)NULL,MultiTokenSeparator)) != (char *)NULL )
				{
				count++;
				strcpy(args[1],token);
				if (count > 8)
					{
					va_end(ap);
					free(dup);
					return;
					}
				}
			}
		va_end(ap);	free(dup);
		}
}

NFM2_format_debug_message(char *format, ...)
{
	va_list ap;
	char    *args[2],text[16384];
	int     loop;
	if (DSdebug)
		{
		strcpy(text,"");	va_start(ap,format);        args[0] = format;        if (strcmp(args[0],"") == 0)    return;
		for (loop = 0; loop < strlen(args[0]); loop++)
			{
			if (args[0][loop] == 37)
				{
				args[1] = va_arg(ap, char *);   loop++;
				switch (args[0][loop])
					{
					case 115:	strcat(text,args[1]);					break;
					case 100:	sprintf(text,"%s%d",text,args[1]);			break;
					case 120:	sprintf(text,"%s%x",text,args[1]);			break;
					case 68:	sprintf(text,"%s%d {%xx}",text,args[1],args[1]);	break;
					case 88:	sprintf(text,"%s%x {%d}",text,args[1],args[1]);		break;
					default:	strncat(text,&args[0][loop],1);				break;
					}
				}
			else	strncat(text,&args[0][loop],1);
			}
		va_end(ap);	NFM2_debug_message(text);
		}
}

void	Get_Multiple_Tokens(char *original, ...)
{
	va_list ap;
	char *args[2], *token, *dup;
	char SBL_Token_Separator[20];
	va_start(ap,original);
	args[0] = original;
	if (strcmp(args[0],"") == 0)    return;
	strcpy(SBL_Token_Separator,MultiTokenSeparator);
	dup = (char *)strdup(args[0]);  args[1] = va_arg(ap,char *);
	if (args[1] != (char *)NULL)
		{
		strcpy(args[1],strtok(dup,SBL_Token_Separator));
		while ((args[1] = va_arg(ap,char *)) != (char *)NULL)	{if ( (token = strtok((char *)NULL,SBL_Token_Separator)) != (char *)NULL )	{strcpy(args[1],token);}}
		va_end(ap);	free(dup);
		}
}

