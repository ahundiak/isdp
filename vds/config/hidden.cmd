BEGIN {FS = ","}

/^0.*VDCnTxLd/{		print "^" $0 ; next }
/^0.*VDChRtDsFs/{	print "^" $0 ; next }
/^0.*SMCnCmFrDB/{	print "^" $0 ; next }
/^0.*SMCnPlSs/{		print "^" $0 ; next }

/^0.*SMPlCrDc/{		print "^" $0 ; next }
/^0.*SMPlCmDcDX/{	print "^" $0 ; next }
/^0.*SMPlShDcDX/{	print "^" $0 ; next }
/^0.*SMPlShDcSl/{	print "^" $0 ; next }
/^0.*SMPlCmDcSl/{	print "^" $0 ; next }
/^0.*SMMdCrDc/{		print "^" $0 ; next }
/^0.*SMMdCmDcDX/{	print "^" $0 ; next }
/^0.*SMMdShDcDX/{	print "^" $0 ; next }
/^0.*SMMdShDcSl/{	print "^" $0 ; next }
/^0.*SMMdCmDcSl/{	print "^" $0 ; next }

/^0.*SMPlStLnBH/{	print "^" $0 ; next }
/^0.*SMPlCrLnBH/{	print "^" $0 ; next }
/^0.*SMPlStTrBH/{	print "^" $0 ; next }
/^0.*SMPlCrTrBH/{	print "^" $0 ; next }
/^0.*SMMdStLnBH/{	print "^" $0 ; next }
/^0.*SMMdCrLnBH/{	print "^" $0 ; next }
/^0.*SMMdStTrBH/{	print "^" $0 ; next }
/^0.*SMMdCrTrBH/{	print "^" $0 ; next }

/^0.*SMPlBndVol/{	print "^" $0 ; next }
/^0.*SMMdBndVol/{	print "^" $0 ; next }

/^0.*SMPlSmSl/{		print "^" $0 ; next }
/^0.*SMMdCmDcSl/{	print "^" $0 ; next }

/^0.*VDPlBnSr/{		print "^" $0 ; next }
/^0.*VDDpNtVr/{		print "^" $0 ; next }

/^0.*SMCrWtRp/{		print "^" $0 ; next }
/^0.*SMDfSrRp/{		print "^" $0 ; next }
/^0.*SMMdSrRp/{		print "^" $0 ; next }

/^0.*VDSelEq/{  	print "^" $0 ; next }
/^0.*VDLdPtFC/{		print "^" $0 ; next }

{print $0}

