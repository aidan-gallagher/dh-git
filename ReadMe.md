# Overview

dh_git is a debhelper program that is responsible for embedding git information (git repository and commit SHA) into the Debian control file. This information is then available to the end user of the package (via `dpkg --status <MY_PACKAGE>`) to determine exactly which version of the package they are using. For example:
```
$ dpkg --status dpkg-buildenv

Package: dpkg-buildenv
Status: install ok installed
Priority: optional
Section: misc
Installed-Size: 21
Maintainer: Aidan Gallagher <aidgal2@gmail.com>
Architecture: all
Version: 1.0.0
Depends: docker.io, python3
Description: Builds debian packages in a docker container.
 Invoke without any arguments to simply build packages.
Git-Id: 44170b221e02283b5ff55813e5eb4cb0aaf8f459             ◄── info added by dh-git
Git-Repo: git@github.com:aidan-gallagher/dpkg-buildenv.git   ◄── info added by dh-git
```



## Usecases

### User Bug Reports  
When a developer is investigating a user's issue they can determine the exact version of the package the user is using. This allows the developer to generate the correct debug symbols if they want to use a debugger.

### Sanity Checks
During development when a program is not behaving as expected it can be useful to check the correct version of the program is definitely being installed. 

# Adding dh-git to your package

1. In the debian/source/format file, change the format to git
```
3.0 (git)
```  


2. In the debian/control file, add `dh-git` to the Build-Depndencies. 
```
Source: dpkg-buildenv
Section: misc
Priority: optional
Maintainer: Aidan Gallagher <aidgal2@gmail.com>
Build-Depends: debhelper-compat (= 12),
               dh-exec,
               dh-git    ◄── Add this
Standards-Version: 4.5.1
```

3. In the debian/rules file, add `--with=git` to dh commands.

```
#!/usr/bin/make -f

%:
	dh $@ --with=git
                  ▲
                  │
               Add this
```

4. Build the package as normal
```
dpkg-buildpackage
```
5. Install the package as normal
```
sudo dpkg -i ../dpkg-buildenv_1.0.0_all.deb 
```

# Implementation Explained

1. dh_git is invoked after the binary debian/control file is created.
2. dh_git uses git to detemine the git repo and git commit.
* `GIT_REPO=$(git config --get remote.origin.url)`
* `GIT_COMMIT_ID=$(git rev-parse HEAD)`
3. dh_git writes the git information to the binary debian/control file.


# Good resources
https://www.debian.org/doc/manuals/debmake-doc/ch05.en.html#workflow 