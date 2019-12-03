#!/bin/bash
#set -x
cvsUsername=$1
cvsPassword=$2
cvsAppName=$3
gitRepoName=$4
gitRemoteURL=$5
filesToDelete=""

#------------------------------------------------------------------
# Define Files(+ its history) you want to remove from repository: 
#------------------------------------------------------------------
secretFilesToDelete=(README.docx src/com/cool/project/services/service/SomeHelper.java)

if [ ! -f "bfg.jar" ]; then
	echo -e '\e[96mdownloading bfg jar'
	curl http://repo1.maven.org/maven2/com/madgag/bfg/1.13.0/bfg-1.13.0.jar -o bfg.jar
fi

echo -e "\e[35m************ Getting project from CVS - start ************\e[0m"
mkdir -p cvs/CVSROOT
sshpass -v -p ${cvsPassword} scp -r ${cvsUsername}@10.20.20.20:/usr/webdev/cvsroot/$cvsAppName cvs
echo -e "\e[35m************ Getting project from CVS - done ************\e[0m"
echo
echo 

echo -e "\e[92m************ CVS TO GIT - start ************\e[0m"
if [ ! -d $PWD/git ]; then
		#mkdir -p git/"$gitRepoName" && cd git/"$gitRepoName" && git cvsimport -v -a -k -d `realpath ../..`/cvs "$gitRepoName" && cd ../../
		cvs2git \
			--blobfile=cvs2svn-tmp/git-blob.dat \
			--dumpfile=cvs2svn-tmp/git-dump.dat \
			--username=$cvsUsername \
			cvs/$cvsAppName
			
		mkdir -p git/"$gitRepoName".git  && cd git/"$gitRepoName".git && git init --bare
		cat  ../../cvs2svn-tmp/git-blob.dat  ../../cvs2svn-tmp/git-dump.dat | git fast-import
		
		cd ../ && git clone "$gitRepoName".git  $gitRepoName && rm -rf "$gitRepoName".git  && cd $gitRepoName
fi
echo -e "\e[92m************ CVS TO GIT - end ************\e[0m"

echo; echo -e "\e[44mWe are in this working directory\e[0m"; pwd;echo
 
echo 'secretFilesToDelete'; echo "$secretFilesToDelete[@]"
for FILE in "${secretFilesToDelete[@]}"
do
    echo "file $FILE"
	if [ ! -f "$FILE" ]
	then
		echo -e "\e[31m******** $FILE does not exist\e[0m"
		# exit 1
	else
		echo "******** $FILE does exist"
	fi
done

echo; echo -e "\e[45mBFG Operation starting\e[0m"; pwd; 
if [ -v secretFilesToDelete ]; then
	cd ..
	echo 'creating mirror repo'
	git clone --mirror ${gitRepoName} ${gitRepoName}.git 
	cd "${gitRepoName}"
	filesToDelete="{" 
	echo '===> there are secrets to remove' ${secretFilesToDelete[@]} ${filesToDelete}
	pwd
    for FILE in "${secretFilesToDelete[@]}"
	do
		if [ ! -f "$FILE" ]; then
			echo -e "\e[35m$FILE is not present\e[0m"
			exit 1
		else 
			filesToDelete=${filesToDelete}, 
			echo -e '\e[92m===> going to commit this file: \e[0m'$FILE 
			git rm --cached $FILE && git commit -m"REM $FILE"`basename $FILE`
			echo `basename $FILE` >> .gitignore && filesToDelete=${filesToDelete}`basename $FILE`
		fi
	done
	filesToDelete=${filesToDelete}"}"
	git add .gitignore && git commit -m"Files to ignore".gitignore
	echo; echo -e "\e[44m===> Running bfg deletion on these files  \e[0m"${filesToDelete}
	cd ..
	java -jar ../bfg.jar --delete-files ${filesToDelete} --no-blob-protection ${gitRepoName}.git
	echo; echo -e "\e[44mPruning and cleaning\e[0m"
	cd ${gitRepoName}.git && git reflog expire --expire=now --all && git gc --prune=now --aggressive
	git remote set-url origin $gitRemoteURL
	echo; echo -e "\e[44mPushing to remote.\e[0m"
	git push
	echo; echo -e "\e[45mBFG Operation finished, repository is pushed to remote.\e[0m"; 
else	
	git push -u origin -all
fi
