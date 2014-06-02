#!/bin/sh

if [ $# -lt 3 ]
then
    echo "imagetyp and target filelist not specified!"
    echo "\$1 is the imagetyp (like jpg), \$2 is the list of lists file,  and \$3 is the prefix of class filelists , \$4 is (optionally) a second imagetyp "
else
  DIRS=$(find . -type d  | grep -v '/$' | sed -r 's/^.\///')
  #clear previous content
  echo -n "" > $2

  sndType=""
  if [ $# -ge 3 ]
  then
    sndType=$4
  fi 

   echo "sndType: ${sndType}"

  #now go over every class
  for subDir in $DIRS
    do 
      if test "$subDir" != "."
      then
	echo ${subDir}
	
	echo "${PWD}/${3}_${subDir}.txt" >> $2
	
	echo -n "" > "${3}_${subDir}.txt"
        files=$(find ./$subDir -name "*.$1" -type f | grep -v '/$' | sed -r 's/^.\///')
	for file in ${files}
	  do
            echo "${PWD}/$file">> "${3}_${subDir}.txt"
	  done   

	if [ "" != "${sndType}" ]
	then
	  files=$(find ./$subDir -name "*.${sndType}" -type f | grep -v '/$' | sed -r 's/^.\///')
	  for file in ${files}
	    do
	      echo "${PWD}/$file">> "${3}_${subDir}.txt"
	    done
	fi

      fi
    done

  #sort main filelist inplace according to string ordering
   sort $2 -o $2


  echo 
  echo "Filelists created"
  echo 
fi

