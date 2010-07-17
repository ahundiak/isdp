#
#
#	I/ROUTE integration
#
#

BEGIN { 	s=0 ;
		OFS = "/" }

#/^NAME/ { print >> Update }

/^DIRECTORY/ { dir = $3 }

/^REMOVED/  { s=1; getline }

/^END_REMOVED/ { s=0 }


{
	if ( s==1 && $1 !~ /^#/ && NF > 0 )  print dir, $1;
}



