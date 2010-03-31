/*
This file contains the options used during extraction of a loop after 
trimming (file implp/EMlpextyours.I). These options are conveyed via the
info field in the correspoing structure EMSsfintedpar representing the start
of a positive boundary on the loop. The info field if non NULL must therefore
point to a unsigned short which holds the options. Flexibility can exist
to use different options for different pairs of boundaries on the same
loop.
*/

#define EMLpExtrct_SinglePoint	0x0001	/* This pair of boundaries is
				        degenerate and should lead to the
				        creation of a point loop.
				        */
				
