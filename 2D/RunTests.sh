#!/bin/bash


HOME="$(pwd)"
cd Test
Directories="$(ls -d */)"
RemovePW=1

for TestCase in $Directories
do

  if [ $TestCase != "src/" ]
  then
    cd $HOME/Test/$TestCase
    echo "Running test case $TestCase"

    if [ -f "*.su2" ]
    then
      rm *.su2
      rm *.pw
      rm *.txt
    fi

    cp -r $HOME/src . && cp $HOME/CreateMesh.glf .

    pointwise -b CreateMesh.glf

    CellsFile="$(ls *.txt)"
    if [ -z "$CellsFile" ]
    then
      echo "Failed test $TestCase"
      break
    else
      NCells="$(sed -n -e 's/^Number of cells is: //p' $CellsFile)"
      if [ $NCells != "0" ]
      then
        echo "Number of cells = $NCells"

        if [ $RemovePW == 1 ]
        then
          rm *.pw
        fi

        rm *.su2
        rm *.txt
        rm *.glf
        rm -r src

      else
        echo "Failed test $TestCase: 0 cells"
        break
      fi
    fi
  fi

echo " "
echo " "

done
