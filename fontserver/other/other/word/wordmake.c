#include <stdio.h>

char *text[] = { "Antidisestablishmentarianism!",
		 "Now is the time for all good men to come to the aid of their country.  The quick brown fox jumps over the lazy dog.  A stitch in time saves nine.",
		 "The quick brown fox jumps over the lazy dog.  Looks like we're in for some rain.  A man, a plan, a canal, panama.  A woman is a woman, but a cigar is a smoke.  A bird in the hand is worth two in the bush.",
		 "Macintosh, the computer for the rest of us.  Font Server, the greatest, most awesome, fantabulous, magnificent font manager in the world.",
		 "HyperCard is the greatest piece of software since the spreadsheet.  You hit the nail on the head.  Man who live in glass house dress in basement.  Tongue twisters twist tongues, trying to untangle twisted tangles.  My tangue's tungled, now."
	       };
	       
main ()
{
	FILE *f;
	int i;
	
	f = fopen ("wtext", "w");

	for (i = 0; i < 5; i++)
	{
		fwrite (text[i], 1, strlen (text[i]), f);
		fputc ('\r', f);
	}
	
	fclose (f);
}
