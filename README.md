# gitFileRemoal
This is for removal of files before from GIT repository during conversion from CVS using Cygwin's cvs2git module.

# Secret Removal from file/s.
This is for removal of secret(password, ip, key, etc) from GIT repository using Cygwin's cvs2git module.

# CVS to GIT with secret/s file removal
We usually have CVS hosted in-house and are nowadays moving to GIT either on cloud or GIT in-premise.  When we move from on-premise to cloud, we would want to remove secrets(database username, password, IP addresses, etc) from code before moving to the cloud.

# Cygwin and GIT are required for this.
### Cygwin
You'll need the `git`, `cvs2git` and `git-cvs` packages.


### CentOS
 ```bash
sudo yum install git-cvs
```

#  cvs import
This example uses the project1 project from CVS, but you can substitute any other module.

To avoid hammering the remote pserver, I just copied the CVS directory straight from the server to a local directory.  You can specify the remote pserver as an argument to ```-d``` but it's rather slow.

## Some basic steps for cvs to git conversion.
## Step 1 - Copy Entire Repo To Local Disk
```bash
# use your own project and username...
module=project1
cvsusername=NidhiU
mkdir -p cvs/CVSROOT # CVS will consider cvs to be a valid repo now
scp -r $cvsusername@10.20.20.20:/usr/webdev/cvsroot/$module cvs
```
Where 10.20.20.20 = IP address of CVS server.

## Step 2 - Run git cvsimport
```bash
# filter is a set of python regular expressions separated by '|', NOT a file glob.
filter='.*jar|databaseConfig.*|secrets.properties|keysHelper.*'
( mkdir -p git/"$module" && cd git/"$module" && git cvsimport -v -a -k -S "$filter" -d `realpath ../..`/cvs "$module" )
```


```-v``` verbose
```-a``` all
```-k``` kill keywords
```-d``` the cvsroot directory; with a remote pserver, this would be something like ```:pserver:NidhiU@10.20.20.20:/usr/webdev/cvsroot```
```-S``` skip files using (python) regular expression; in this case I intend to convert this project to maven, so I've excluded jar files as well as config files which contain passwords and filtering step is completely optional.


# Troubleshooting
### Check Versions
Check git and CVS versions, and verify that your PATH isn't occluded, since we want to use pure cygwin binaries here.
```
 $ which git
/usr/bin/git
$ which cvs
/usr/bin/cvs

$ git --version
git version 2.17.0
$ cvs --version 
```

# How to use these scripts
> Step 1 - replace cvs and git credentials in start.sh file.

> Step 2 - mention your secret files for removal into conversion.sh
```bash
./start.sh  or sh start.sh
```
