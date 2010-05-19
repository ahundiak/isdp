KSH='.sh'
LOG='.log'
PAT="\$1"

HLP='h'
EXI='x'
RPT='r'
LGF='l'

export COLUMNS=132

echo "Loading available keys ..."
for ksh in [!p]*$KSH
do 
  root=`basename $ksh $KSH`
  list="$list $root"
done
   
while [ "$key" != $EXI ]
do
   key=""
   echo "\nVDS report Key or Help or Exit ? : (<key>/h/x) [h] \c"
   read key
   
   if [ "$key" = $HLP -o "$key" = "" ]; then
      echo ""
      echo "\tProduct			\tReport Type"
      echo "\t-------			\t-----------"
      echo "\t<BM> : I/STRUCT beam	\t<B> : bill of material"
      echo "\t<EQ> : I/VDS equipment	\t<D> : data report (I/ROUTE)"
      echo "\t<HV> : I/ROUTE hvac	\t<G> : drawing report (I/STRUCT)"
      echo "\t<NZ> : I/ROUTE nozzle	\t<E> : error report"
      echo "\t<OV> : overall report	\t<N> : NSTS type report"
      echo "\t<PL> : I/STRUCT plate	\t<R> : Reference Data (I/ROUTE)"
      echo "\t<PP> : I/ROUTE piping	\t<S> : User interface"
      echo "\t<RW> : I/ROUTE raceway	\t<V> : Valve report (I/ROUTE)"
      echo "\t<BP> : I/STRUCT beam & plate\t<W> : Weight report"
      echo "\t<CM> : I/VDS Compartment  \t<T> : Tracking (Comp Tracking)"
      echo "\t<VD> : User interface	\t<C> : Space Class (Compartments)"
      echo ""
      echo "Available keys :"
      echo "<$list>"
   else
     if [ "$key" != $EXI ]; then
        rptrun=0
        for file in $list
        do
           if [ "$file" = "$key" ]; then
              echo $key > /tmp/VDSrpt_key
	      RPTexec.4ge
	      report=`fgrep $PAT $key$KSH | cut -c13-80`
	      echo "\t\tVDS report <$report> generate with <$key$LOG> log file"
	      rptrun=1
              while [ "$look" != $EXI ]
                 do
	         look=""
	         echo "Look Report, Log_file or Exit (r/l/x) : ? [x] \c"
	         read look
	         if [ "$look" = "" ]; then
                    look=$EXI
                 fi

	         if [ "$look" = $RPT ]; then
                    cat $report
                 else
		    if [ "$look" = $LGF ]; then
		       cat $key$LOG
                    fi
                 fi
	      done
           fi
        done
        if [ "$rptrun" = "0" ]; then
	   echo "\t\t<$key> is not an available VDS report key"
        fi
     fi
   fi
done
