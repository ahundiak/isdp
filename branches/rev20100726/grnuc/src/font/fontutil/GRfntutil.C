/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
 
IGRushort KJ_u_computefont(in_char)
IGRuchar in_char;
{
	IGRuchar off_set;
	IGRuchar divisor;
	IGRushort out_temp;
	 
	off_set=160;
	divisor=2;
	out_temp=0;
	out_temp=((in_char-off_set)/2)+(in_char%divisor);
	return(out_temp);
}

char KJ_u_computechar(in_char,in_ku)
IGRuchar	in_char;
IGRuchar	in_ku;
{


	in_char-=160;
	if((in_ku%2)==0) in_char+=128;
	return(in_char);
}

KJ_u_sjistodec(ch)
IGRuchar ch[2];
{
	IGRushort sjis,jis;
	IGRuchar *tmp_ptr;
	IGRushort KJ_u_sjistojis();

	sjis=((IGRushort)ch[0]<<8 | ch[1]);
	jis=KJ_u_sjistojis(sjis);
	jis+=0x8080;
	tmp_ptr=(IGRuchar *)(&jis);
	memcpy(&ch[0],&tmp_ptr[1],1);
	memcpy(&ch[1],&tmp_ptr[0],1);
}

IGRushort KJ_u_sjistojis(sjis)
IGRushort sjis;
{
	IGRushort high,low;
	high=(sjis>>8)&0xff;
	low=(sjis&0xff);
	if(high>=0xe0)
		high-=(0xe0-0xa0);
	high<<=1;
	high-=0xe1;
	if(low>=0x9f){
		low-=(0x9f-0x40);
		high++;
	}
	else if (low>=0x80)
		low--;
	low-=(0x40-0x21);
	return((high<<8)|(low&0xff));
}


KJ_u_getfontchar(code,font,ch)
IGRuchar *code;
short	*font;
IGRuchar *ch;
{
	IGRuchar tmp_ch[2];
	
	tmp_ch[0]=code[0];
	tmp_ch[1]=code[1];
	KJ_u_sjistodec(tmp_ch);
	*font=KJ_u_computefont(tmp_ch[0]);
	*ch=KJ_u_computechar(tmp_ch[1],tmp_ch[0]);
}

KJ_u_FScharok(font,ch)
int	font;
IGRuchar ch;
{
	if(font==0)
	{
		if( ch>=32 && ch<=126)
		{
			return(1);
		}
		else
		{
			return(0);
		}
	}
	else
	{
		if( font>=1 && font<=42)
		{
			if( (ch>=0 && ch<=94) ||
			    (ch>=129 && ch<=222) )
			{
				return(1);
			}
			else
			{
				return(0);
			}
		}
		else
		{
			return(0);
		}
	}
}

