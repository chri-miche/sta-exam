from random import random

max_rank = 3
max_graph_dist = 5
min_graph_dist = 2
max_graph_height = 10
max_graph_width = 16
n = 8

seed = (0, 0)

v_g = set([seed])
e_g = []

u = seed
added = 0
eligible = []
while True:
    times = int(random() * max_rank)
    for _ in range(0, times + 1):
        v = u
        ux, uy = u
        while v in v_g:
            # print(f"Discarded {v}")
            x = min(max_graph_width, ux + max(min_graph_dist, int(random() * 2 * max_graph_dist)) - max_graph_dist)
            y = min(max_graph_height, uy + max(min_graph_dist, int(random() * 2 * max_graph_dist)) - max_graph_dist)
            # print(f"Proposed {v}")
            v = (x, y)
        
        # print(f"Accepted {v}")
        v_g.add(v)
        e_g.append(set([u, v]))
    
        added += 1
    
    if added >= n:
        break
    else:
        if len(eligible) == 0:
            eligible = v_g

        u, *eligible = eligible

def arc(edge):
    v, u = edge
    return f"line({v}, {u})"

def node(node):
    return f"circle({node}, fill: teal.lighten(80%), radius: 0.7)"

out = ""

for e in e_g:
    out += arc(e) + "\n"

out += "\n"

for v in v_g:
    out += node(v) + "\n"

print(out)





