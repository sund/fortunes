# fortune .dat makefile script
# from http://bradthemad.org/tech/notes/fortune_makefile.php



POSSIBLE += $(shell ls -1 | egrep -v '\.dat|README|Makefile|\.sh' | sed -e 's/$$/.dat/g')

all: ${POSSIBLE}

%.dat : %
	@strfile $< $@