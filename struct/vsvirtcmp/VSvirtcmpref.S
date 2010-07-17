/*
	I/STRUCT
*/
class specification VSvirtcmpref(0:0) of VSvirtcmp, ASsourcein ;

/*+c
	As class `VSvirtcmp' but handles links across reference files.
-c*/
from VSvirtcmp inherit NDmake_source ;

end specification VSvirtcmpref ;
