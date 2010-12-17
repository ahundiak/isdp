#include "machine.h"
#include "NFMsysinc.h"
/************************************************************************
*			NFMbase36					*
* 	This function calculates a base36 number for a base10 number	*
*	and returns it as string					*
*	The numbers are							*
*	0-9		0-9						*
*	10-35		A-Z	(Returns uppercase			*
*	Return values							*
*	SUCCESS		>= 0						*
*	Error		<  0						*
************************************************************************/

NFMbase36(b10num , b36num)
	long b10num;  /* b10num >= 0 */
	char *b36num; /* Calling procedure responsible for allocating
			 enough space for the number MIN 8 characters */
{
	long i, j;	
	char c;
	long num,newnum,rem;
	
/*	check if the number is a positive */
	if(b10num < 0 )
		num= -b10num;
	else 	num = b10num ;
	i=0;
/* calculate the base36 number */
	while(num > 0)
	{
		newnum = num / 36;	
		rem = num - 36 * newnum;
		num=newnum;
		switch(rem)
		{
			case 0: b36num[i]='0';break;
			case 1: b36num[i]='1';break;
			case 2: b36num[i]='2';break;
			case 3: b36num[i]='3';break;
			case 4: b36num[i]='4';break;
			case 5: b36num[i]='5';break;
			case 6: b36num[i]='6';break;
			case 7: b36num[i]='7';break;
			case 8: b36num[i]='8';break;
			case 9: b36num[i]='9';break;
			case 10: b36num[i]='A';break;
			case 11: b36num[i]='B';break; 
			case 12: b36num[i]='C';break;
			case 13: b36num[i]='D';break;
			case 14: b36num[i]='E';break;
			case 15: b36num[i]='F';break;
			case 16: b36num[i]='G';break;
			case 17: b36num[i]='H';break;
			case 18: b36num[i]='I';break;
			case 19: b36num[i]='J';break;
			case 20: b36num[i]='K';break;
			case 21: b36num[i]='L';break;
			case 22: b36num[i]='M';break;
			case 23: b36num[i]='N';break;
			case 24: b36num[i]='O';break;
			case 25: b36num[i]='P';break;
			case 26: b36num[i]='Q';break;
			case 27: b36num[i]='R';break;
			case 28: b36num[i]='S';break;
			case 29: b36num[i]='T';break;
			case 30: b36num[i]='U';break;
			case 31: b36num[i]='V';break;
			case 32: b36num[i]='W';break;
			case 33: b36num[i]='X';break;
			case 34: b36num[i]='Y';break;
			case 35: b36num[i]='Z';break;
			default: return(-1); break;
		}
		i++;
	}
	b36num[i]='\0';
	j=i;
/* reverse the string in b36num */
	for (i=0;i < j/2 ; i++)
	{
		c=b36num[i];
		b36num[i]=b36num[j-i-1];
		b36num[j-i-1]=c;
	}
/* Add a - sign for negative number */
	if(b10num <0 )
	{ 
		for(i=j;i> 0 ; i--)
		 b36num[i+1] = b36num[i] ;
		b36num[0] ='-' ;
	}
		 
	return(1);
}

