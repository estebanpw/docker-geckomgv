#!/bin/bash

FL=1000   # frequency limit
MG=0

if [ $# -lt 7 ]; then
   echo " ==== ERROR ... you called this script inappropriately."
   echo ""
   echo "   usage:  $0 seqXName seqYName lenght similarity WL fixedL CSVOutput"
   echo ""
   exit -1
fi

if [ $# == 8 ]; then
   MG=$8
fi

{

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MYRAND=$(( ( RANDOM % 10000000 )  + 1 ))

dirNameX=$(${BINDIR}/readlink.sh $1 | xargs dirname)
seqXName=$(basename "$1")
extensionX="${seqXName##*.}"
seqXName="${seqXName%.*}"

dirNameY=$(${BINDIR}/readlink.sh $2 | xargs dirname)
seqYName=$(basename "$2")
extensionY="${seqYName##*.}"
seqYName="${seqYName%.*}"
outputFile=$7

#seqXName=`basename $1 .fasta`
#seqYName=`basename $2 .fasta`

length=${3}
similarity=${4}
WL=${5} # wordSize
fixedL=${6}

REALINTER=intermediateFiles_${MYRAND}
REALSULTS=results_${MYRAND}
REALCSV=csv_${MYRAND}
REALCSB=csb_${MYRAND}
REALCOMP=comparaciones_${MYRAND}
REALHIST=hist_${MYRAND}

#mkdir intermediateFiles
mkdir $REALINTER

#mkdir intermediateFiles/${seqXName}-${seqYName}
mkdir $REALINTER/${seqXName}-${seqYName}
#mkdir results
mkdir $REALSULTS
#mkdir intermediateFiles/dictionaries
#mkdir intermediateFiles/hits
mkdir $REALINTER/dictionaries
mkdir $REALINTER/hits

#mkdir csv
#mkdir csb
#mkdir comparaciones
#mkdir hist
mkdir $REALCSV
mkdir $REALCSB
mkdir $REALCOMP
mkdir $REALHIST


# Copiamos los fastas
#ln -s ${dirNameX}/${seqXName}.${extensionX} intermediateFiles/${seqXName}-${seqYName}
#ln -s ${dirNameY}/${seqYName}.${extensionY} intermediateFiles/${seqXName}-${seqYName}

ln -s ${dirNameX}/${seqXName}.${extensionX} $REALINTER/${seqXName}-${seqYName}
ln -s ${dirNameY}/${seqYName}.${extensionY} $REALINTER/${seqXName}-${seqYName}

#cd intermediateFiles/${seqXName}-${seqYName}
cd $REALINTER/${seqXName}-${seqYName}


mkdir GRIMM
cd GRIMM
mkdir anchor
cd ..
###############


echo "${BINDIR}/reverseComplement ${seqYName}.${extensionX} ${seqYName}-revercomp.${extensionY}"
${BINDIR}/reverseComplement ${seqYName}.${extensionX} ${seqYName}-revercomp.${extensionY}

echo "${BINDIR}/reverseComplement ${seqXName}.${extensionX} ${seqXName}-revercomp.${extensionX}"
${BINDIR}/reverseComplement ${seqXName}.${extensionX} ${seqXName}-revercomp.${extensionX}

if [[ ! -f ../dictionaries/${seqXName}.d2hP ]];	then
	echo "${BINDIR}/dictionary.sh ${seqXName}.${extensionX} 8 &"
	${BINDIR}/dictionary.sh ${seqXName}.${extensionX} 8 &		
fi
		
if [[ ! -f ../dictionaries/${seqYName}.d2hP ]];	then
	echo "${BINDIR}/dictionary.sh ${seqYName}.${extensionY} 8 &"
	${BINDIR}/dictionary.sh ${seqYName}.${extensionY} 8 &
fi
		
if [[ ! -f ../dictionaries/${seqYName}-revercomp.d2hP ]];	then
	echo "${BINDIR}/dictionary.sh ${seqYName}-revercomp.${extensionY} 8 &"
	${BINDIR}/dictionary.sh ${seqYName}-revercomp.${extensionY} 8 &
fi		

echo "Waiting for the calculation of the dictionaries"

for job in `jobs -p`
do
    #echo $job
    wait $job
done


mv ${seqXName}.d2hP ../dictionaries/
mv ${seqXName}.d2hW ../dictionaries/
mv ${seqYName}.d2hP ../dictionaries/
mv ${seqYName}.d2hW ../dictionaries/
mv ${seqYName}-revercomp.d2hP ../dictionaries/
mv ${seqYName}-revercomp.d2hW ../dictionaries/
		
# Hacemos enlace simbolico
ln -s ../dictionaries/${seqXName}.d2hP .
ln -s ../dictionaries/${seqXName}.d2hW .

ln -s ../dictionaries/${seqYName}.d2hP .
ln -s ../dictionaries/${seqYName}.d2hW .

ln -s ../dictionaries/${seqYName}-revercomp.d2hP .
ln -s ../dictionaries/${seqYName}-revercomp.d2hW .

echo "${BINDIR}/comparison.sh ${seqXName}.${extensionX} ${seqYName}.${extensionY} ${length} ${similarity} ${WL} ${fixedL} f &"
${BINDIR}/comparison.sh ${seqXName}.${extensionX} ${seqYName}.${extensionY} ${length} ${similarity} ${WL} ${fixedL} f &

echo "${BINDIR}/comparison.sh ${seqXName}.${extensionX} ${seqYName}-revercomp.${extensionY} ${length} ${similarity} ${WL} ${fixedL} r &"
${BINDIR}/comparison.sh ${seqXName}.${extensionX} ${seqYName}-revercomp.${extensionY} ${length} ${similarity} ${WL} ${fixedL} r &

echo "Waiting for the comparisons"

for job in `jobs -p`
do
    #echo $job
    wait $job
done

#echo "rm ${seqYName}-revercomp.${extensionY}"
#rm ${seqYName}-revercomp.${extensionY}

echo "${BINDIR}/combineFrags ${seqXName}-${seqYName}-sf.frags ${seqXName}-${seqYName}-revercomp-sr.frags ${seqXName}-${seqYName}.frags"
${BINDIR}/combineFrags ${seqXName}-${seqYName}-sf.frags ${seqXName}-${seqYName}-revercomp-sr.frags ${seqXName}-${seqYName}.frags

#echo "${BINDIR}/newFragToBalazsVersion ${seqXName}-${seqYName}.frags ${seqXName}-${seqYName}.old.frags"
#${BINDIR}/newFragToBalazsVersion ${seqXName}-${seqYName}.frags ${seqXName}-${seqYName}.old.frags

#echo "${BINDIR}/af2pngrev ${seqXName}-${seqYName}.frags ${seqXName}-${seqYName}.png ${seqXName} ${seqYName}"
#${BINDIR}/af2pngrev ${seqXName}-${seqYName}.frags ${seqXName}-${seqYName}.png ${seqXName} ${seqYName}
	# Calc ACGT frequencies
        echo "${BINDIR}/getFreqFasta ${seqXName}.${extensionX} ${seqXName}.freq"
        ${BINDIR}/getFreqFasta ${seqXName}.${extensionX} ${seqXName}.freq

        #Calc karlin parameters
        echo "${BINDIR}/kar2test ${seqXName}.freq ${BINDIR}/matrix.mat 1 ${seqXName}.karpar"
        ${BINDIR}/kar2test ${seqXName}.freq ${BINDIR}/matrix.mat 1 ${seqXName}.karpar

        #rm -rf ${seqXName}.freq

        echo "----------- p-value filter --------------"
        ## Filtro por pvalue
        echo "${BINDIR}/pvalueFilter ${seqXName}-${seqYName}.frags ${seqXName}.karpar ${seqXName}-${seqYName}.fil.frags ${seqXName}-${seqYName}.trash.frags "
        ${BINDIR}/pvalueFilter ${seqXName}-${seqYName}.frags ${seqXName}.karpar ${seqXName}-${seqYName}.fil.frags ${seqXName}-${seqYName}.trash.frags 1

echo "-------"
echo ${BINDIR}
echo "-------"
${BINDIR}/fragstoMaster ${seqXName}-${seqYName}.fil.frags ${seqXName}-${seqYName}.original.master ${seqXName}.${extensionX} ${seqYName}.${extensionY}
echo "${BINDIR}/csb2csv ${seqXName}-${seqYName}.original.master ${seqXName}-${seqYName}.original.master 0 > ${seqXName}-${seqYName}.original.csv.tmp"
${BINDIR}/csb2csv ${seqXName}-${seqYName}.original.master ${seqXName}-${seqYName}.original.master ${seqXName}.${extensionX} ${seqXName} ${seqYName}.${extensionY} ${seqYName} ${seqXName}-${seqYName}.csv
#fragstoMaster frags/NC_014448.1-NC_019552.1.fil.frags master fastas/NC_014448.1.fasta fastas/NC_019552.1.fasta
#csb2csv master master fastas/NC_014448.1.fasta NC_014448.1 fastas/NC_019552.1.fasta NC_019552.1 master.csv
#cat ${seqXName}-${seqYName}.csb.frags.INF ${seqXName}-${seqYName}.original.csv.tmp > ${seqXName}-${seqYName}.original.csv
	
# calculamos hits en txt
#${BINDIR}/getHistogramFromHits ${seqXName}-${seqYName}-revercomp-K${WL}.hits.sorted ${seqXName}-${seqYName}-K${WL}.histXrever.txt ${seqXName}-${seqYName}-K${WL}.histYrever.txt r 0 

#${BINDIR}/getHistogramFromHits ${seqXName}-${seqYName}-K${WL}.hits.sorted ${seqXName}-${seqYName}-K${WL}.histX.txt ${seqXName}-${seqYName}-K${WL}.histY.txt f 0
 
#Borramos todo menos los frags y los diccionarios


#cat ${seqXName}-${seqYName}.frags.INF ${seqXName}-${seqYName}.original.csv > ${seqXName}-${seqYName}.csv

#MYRAND=$(( ( RANDOM % 1000000 ) + 1))
echo "Estoy en $PWD"
mv ${seqXName}-${seqYName}.csv ${outputFile}
#cp $outputFile ../../
#mv /home/sergiodiazdp/galaxycsv/${MYRAND}.csv $outputFile
mv ${seqXName}-${seqYName}.frags ../../results
mv ${seqXName}-${seqYName}.frags.INF ../../results
mv ${seqXName}-${seqYName}.frags.MAT ../../results
#mv ${seqXName}-${seqYName}-K${WL}.histXrever.txt ../../hist
#mv ${seqXName}-${seqYName}-K${WL}.histYrever.txt ../../hist
#mv ${seqXName}-${seqYName}-K${WL}.histX.txt ../../hist 
#mv ${seqXName}-${seqYName}-K${WL}.histY.txt ../../hist


echo "Deleting the tmp folder: ${seqXName}-${seqYName}"
cd ..

#rm -rf ${seqXName}-${seqYName}
#rm -r ../intermediateFiles


#rm -r ../intermediateFiles/${seqXName}-${seqYName}.v3.frags
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.joined
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.evol.frag2
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.evol.csb2

rm -r ../$REALINTER/${seqXName}-${seqYName}.v3.frags
rm -r ../$REALINTER/${seqXName}-${seqYName}.joined
rm -r ../$REALINTER/${seqXName}-${seqYName}.evol.frag2
rm -r ../$REALINTER/${seqXName}-${seqYName}.evol.csb2


} &> /dev/null
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.v3.frags
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.joined
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.evol.frag2
#rm -r ../intermediateFiles/${seqXName}-${seqYName}.evol.csb2

