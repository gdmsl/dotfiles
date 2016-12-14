#! /usr/bin/env python2
from subprocess import check_output

def get_pass(fname):
    return check_output("gpg -dq ~/usr/documents/id/" + fname, shell=True).strip("\n")
