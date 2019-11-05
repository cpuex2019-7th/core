SRCS = $(wildcard *.S)
OBJS = $(SRCS:.S=.o)
COES = $(SRCS:.S=.coe)
BINS = $(SRCS:.S=.bin)
SYMBOLS = $(SRCS:.S=.bin.symbols)

.PHONY: all

all: $(BINS) $(COES)

%.coe: %.bin
	cpuex_bin2coe $^ > $@

%.bin: %.S
	cpuex_asm $@ $^

clean:
	rm -rf $(BINS) $(COES) $(OBJS) $(SYMBOLS)
