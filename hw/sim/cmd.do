onerror {resume}


add list -r sim:/tb/*
#add list sim:/tb/*

configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5

radix -hexadecimal

do wave.do

run -all
