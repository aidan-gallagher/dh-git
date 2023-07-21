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
1. In the debian/control file, add `dh-git` to the Build-Depndencies. 
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

2. In the debian/rules file, add `--with=git` to dh commands.

```
#!/usr/bin/make -f

%:
	dh $@ --with=git
                  ▲
                  │
               Add this
```

3. Build the package as normal
```
dpkg-buildpackage
```
4. Install the package as normal
```
sudo dpkg -i ../dpkg-buildenv_1.0.0_all.deb 
```


## Concerns
* This package is not hosted on debian servers therefore you will have to make it available to your build environment so step 1 doesn't complain that it can't find dh-git.
* This package assumes the program and debian packaing live in the repository. Many debian packages have the packaging information in a different repository to the upstream source; dh-git will not work for them.

# Implementation Explained

Before building the debian package the git repository and git commit are determined using the following commands:
* `GIT_REPO=$(git config --get remote.origin.url)`
* `GIT_COMMIT_ID=$(git rev-parse HEAD)`


dh-git then uses [Debian user-defined fields](https://www.debian.org/doc/debian-policy/ch-controlfields.html#user-defined-fields) to add this to the debian/control file.

After the debian package is built dh_git removes this information from the original debian/control file.


