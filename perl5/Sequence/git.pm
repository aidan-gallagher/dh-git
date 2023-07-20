#!/usr/bin/perl
use warnings;
use strict;
use Debian::Debhelper::Dh_Lib;

insert_after("dh_clean", "dh_git");
insert_after("dh_builddeb", "dh_git_clean");
