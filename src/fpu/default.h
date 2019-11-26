typedef struct {
    long long int val;
    int len;
} wire;

wire init(int l,long long int v);
wire concat(wire w1, wire w2);
wire extract(wire w, int s, int t);
void print_wire(wire w);
int eq(wire a,wire b);
int gt(wire a,wire b);
int ge(wire a,wire b);
int lt(wire a,wire b);
int le(wire a,wire b);
wire not(wire w);
int bitor(wire w);
int bitand(wire w);
wire add(wire a, wire b, int l);
wire sub(wire a, wire b, int l);