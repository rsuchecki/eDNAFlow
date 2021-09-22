#!/usr/bin/env nextflow

/*

Usage: nextflow run pull_containers.nf -resume -ansi-log false --singularityDir cache

*/

import nextflow.util.Escape
import nextflow.container.SingularityCache

//Container images specified in config files
def containers = []
session.getConfig().process.each {k, v ->
  if((k.startsWith('withLabel:') || k.startsWith('withName:')) && v.containsKey('container') ) {    
    containers << v.container
  }
}

SingularityCache scache = new SingularityCache() //to get NF-consitent image file names


process pull_container {
  tag { remote }
  maxForks 1  
  errorStrategy = 'terminate'
  storeDir "${params.singularityDir}"
  echo true

input:
  val(remote) from Channel.from(containers).unique()

output:
  file(img)

script:
img = scache.simpleName(remote)
"""
SINGULARITY_CACHEDIR=\$PWD singularity pull --name ${img} ${Escape.path(remote)}
"""
}
