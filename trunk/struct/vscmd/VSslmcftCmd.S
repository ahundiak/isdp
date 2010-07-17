/*
	I/STRUCT
*/
class specification VSslmcftCmd (1:0) of VSpartopCmd ;


instance VSslmcftCmd {
	GRname	regExp ;
} ;

message checkRegExp( long *msg ) ;

message displaySet( enum GRdpmode dpMode ) ;

message putSetOntoQ() ;

message dissolveSet() ;

override operation ;

end specification VSslmcftCmd ;
